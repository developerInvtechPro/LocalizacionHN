"""Prepara una variante para primera instalación sin cambiar el esquema del sandbox.

No publica, sincroniza, desinstala ni modifica API_BCPOS. Compila en una carpeta
temporal y conserva un paquete fuente revisable de la variante de producción.
"""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PROFILE = json.loads((ROOT/'migracion/perfil-produccion.json').read_text())
CATEGORIES = ['Tables','TableExtensions','Pages','PageExtensions','Codeunits','Reports','Enums','EnumExtensions','PermissionSets']


def mover(numero):
    origen = PROFILE['originalRange']
    return PROFILE['destinationRange']['from'] + numero-origen['from'] if origen['from'] <= numero <= origen['to'] else numero


def objetos(datos, categoria):
    yield from datos.get(categoria, [])
    for espacio in datos.get('Namespaces', []): yield from objetos(espacio, categoria)


def simbolos(paquete):
    with zipfile.ZipFile(paquete) as archivo: return json.loads(archivo.read('SymbolReference.json'))


def inventario(datos):
    objetos_id = {(c,o['Id']):o['Name'] for c in CATEGORIES for o in objetos(datos,c)}
    campos = {(o['TargetObject'].split('#')[-1],f['Id']):f['Name'] for o in objetos(datos,'TableExtensions') for f in o.get('Fields',[])}
    return objetos_id,campos


def colisiones(primero, segundo):
    a,fa=inventario(primero);b,fb=inventario(segundo)
    return ([dict(kind=c,id=i,v2=a[(c,i)],other=b[(c,i)]) for c,i in sorted(a.keys() & b.keys())] +
            [dict(kind='field',table=t,id=i,v2=fa[(t,i)],other=fb[(t,i)]) for t,i in sorted(fa.keys() & fb.keys())])


def reemplazar_fuente(texto):
    # Solo identidades de declaración: no cambiar IDs de campos de origen ni valores.
    texto=re.sub(r'(?m)^(table|tableextension|page|pageextension|report|codeunit|enum|enumextension|permissionset) (501\d\d)\b',
                 lambda m:m[1]+' '+str(mover(int(m[2]))),texto)
    texto=re.sub(r'\bfield\((501\d\d);',lambda m:'field('+str(mover(int(m[1])))+';',texto)
    # El mapa de migración guarda por separado origen y destino; mover solo destino.
    texto=re.sub(r"(Add\(Map, \d+, '(?:''|[^'])*', )(501\d\d)(,)",lambda m:m[1]+str(mover(int(m[2])))+m[3],texto)
    assert not re.search(r'\b501\d\d\b',texto), 'Hay una referencia numérica 501xx que requiere revisión explícita.'
    return texto


def mover_esquema(valor):
    if isinstance(valor,list): return [mover_esquema(v) for v in valor]
    if isinstance(valor,dict): return {k:(mover(v) if k=='Id' and isinstance(v,int) else mover_esquema(v)) for k,v in valor.items()}
    return valor


def comparar_esquemas(base, nuevo):
    cambios=[]
    for categoria in CATEGORIES:
        anteriores={o['Name']:o for o in objetos(base,categoria)}
        actuales={o['Name']:o for o in objetos(nuevo,categoria)}
        assert anteriores.keys()==actuales.keys(),categoria
        for nombre,antes in anteriores.items():
            despues=actuales[nombre]
            assert despues['Id']==mover(antes['Id']), (categoria,nombre)
            if antes['Id']!=despues['Id']: cambios.append(dict(kind=categoria,name=nombre,before=antes['Id'],after=despues['Id']))
            if categoria in ['Tables','TableExtensions']:
                campos={f['Name']:f for f in despues.get('Fields',[])}
                assert set(campos)=={f['Name'] for f in antes.get('Fields',[])},nombre
                for campo in antes.get('Fields',[]):
                    actual=campos[campo['Name']]
                    assert actual['Id']==mover(campo['Id']), (nombre,campo['Name'])
                    assert actual['TypeDefinition']==mover_esquema(campo['TypeDefinition']), (nombre,campo['Name'],'tipo')
                    if actual['Id']!=campo['Id']: cambios.append(dict(kind='field',table=nombre,name=campo['Name'],before=campo['Id'],after=actual['Id']))
    return cambios


def main():
    manifest=json.loads((ROOT/'app.json').read_text())
    base_package=ROOT/'artefactos'/f'INVTECH_LocalizacionHN_V2_{manifest["version"]}.app'
    assert base_package.exists(),'Compile primero la versión base con herramientas/compilar.py.'
    base=simbolos(base_package)
    api=Path(PROFILE['apiPackage']);assert api.is_file(),'Falta el paquete API_BCPOS inventariado.'
    api_symbols=simbolos(api)
    assert api_symbols['AppId']=='3e09c0fc-c1a5-4107-84fd-8d8ad29be1fb','Paquete API inesperado.'
    original_files=list((ROOT/'src').rglob('*'))+[ROOT/'app.json',ROOT/'migracion/mapa-campos.json',ROOT/'migracion/esquema-v2-base.json']
    hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in original_files if p.is_file()}
    with tempfile.TemporaryDirectory(prefix='hn-produccion-primera-instalacion-') as folder:
        stage=Path(folder)
        for nombre in ['src','herramientas','pruebas','migracion']:
            shutil.copytree(ROOT/nombre,stage/nombre,ignore=shutil.ignore_patterns('__pycache__','*.pyc'))
        manifest['version']=PROFILE['version']
        manifest['idRanges']=PROFILE['keepRanges']+[PROFILE['destinationRange']]
        (stage/'app.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
        for archivo in (stage/'src').rglob('*.al'): archivo.write_text(reemplazar_fuente(archivo.read_text()))
        mapa=stage/'migracion/mapa-campos.json';contrato=json.loads(mapa.read_text())
        for campo in contrato['fields']:
            campo['targetId']=mover(campo['targetId']);campo['targetTableId']=mover(campo.get('targetTableId',campo['tableId']))
        firma=hashlib.sha256(json.dumps(contrato['fields'],sort_keys=True,ensure_ascii=False).encode()).hexdigest()[:20].upper()
        contrato['mapVersion']=firma;mapa.write_text(json.dumps(contrato,ensure_ascii=False,indent=2)+'\n')
        codigo=stage/'src/Migracion/MapaCamposOrigen.al';texto=codigo.read_text()
        texto=re.sub(r"(procedure VersionMap\(\): Code\[20\]\s*begin\s*exit\(')[^']+",lambda m:m[1]+firma,texto)
        codigo.write_text(texto)
        baseline=stage/'migracion/esquema-v2-base.json'
        baseline.write_text(json.dumps(mover_esquema(json.loads(baseline.read_text())),ensure_ascii=False,indent=2)+'\n')
        # El proyecto base conserva su aviso de colisiones. Esta copia se valida con su auditoría propia.
        verificador=stage/'herramientas/verificar_artefactos.py';texto=verificador.read_text()
        texto=texto.replace("print('ATENCIÓN: migracion/inventario.json documenta conflictos de IDs con API_BCPOS; no desplegar juntos hasta resolverlos.')",
                            "print('Variante de primera instalación: consultar auditoria-produccion.json para las colisiones contrastadas.')")
        verificador.write_text(texto)
        (stage/'.alpackages').mkdir()
        for paquete in (ROOT/'.alpackages').glob('Microsoft_*.app'): (stage/'.alpackages'/paquete.name).symlink_to(paquete.resolve())
        subprocess.run([sys.executable,str(stage/'herramientas/compilar.py')],check=True)
        subprocess.run([sys.executable,str(verificador)],check=True)
        subprocess.run([sys.executable,'-m','unittest','discover','-s',str(stage/'pruebas'),'-p','test_celdas_rdlc.py'],cwd=stage,check=True)
        compiled=stage/'artefactos'/f'INVTECH_LocalizacionHN_V2_{PROFILE["version"]}.app'
        nuevo=simbolos(compiled);cambios=comparar_esquemas(base,nuevo)
        conflictos=colisiones(nuevo,api_symbols)
        assert not conflictos,conflictos
        # Inventario local de aplicaciones: evidencia de contraste, no lista del servidor.
        lista=subprocess.run(['rg','--files',str(Path.home()/'Downloads'),'-g','*.app'],capture_output=True,text=True,check=True).stdout.splitlines()
        revisados=[];incidencias=[]
        for ruta in lista:
            if Path(ruta).name.startswith('Microsoft_'): continue
            try: otro=simbolos(ruta)
            except (ValueError,KeyError,zipfile.BadZipFile): continue
            if otro.get('AppId')==nuevo['AppId']:continue
            diferencias=colisiones(nuevo,otro)
            revisados.append(dict(path=ruta,appId=otro.get('AppId'),name=otro.get('Name')))
            if diferencias:incidencias.append(dict(path=ruta,collisions=diferencias))
        assert not incidencias,incidencias
        auditoria=dict(profile=PROFILE,firstInstallOnly=True,baseVersion=base.get('Version'),productionVersion=PROFILE['version'],
                       appId=manifest['id'],basePackageSHA256=hashlib.sha256(base_package.read_bytes()).hexdigest(),
                       packageSHA256=hashlib.sha256(compiled.read_bytes()).hexdigest(),
                       apiPackage=str(api),apiSHA256=hashlib.sha256(api.read_bytes()).hexdigest(),
                       collisionsBefore=colisiones(base,api_symbols),collisionsAfter=conflictos,
                       changes=cambios,migrationMapVersion=firma,examinedPackages=revisados,otherCollisions=incidencias,
                       limitation='Inventario local; no acredita aplicaciones no facilitadas ni ejecución/instalación en Business Central.')
        (stage/'migracion/auditoria-produccion.json').write_text(json.dumps(auditoria,ensure_ascii=False,indent=2)+'\n')
        destino=ROOT/'artefactos';destino.mkdir(exist_ok=True)
        for archivo in (stage/'artefactos').iterdir():
            if archivo.is_file():shutil.copy2(archivo,destino/archivo.name)
        shutil.copy2(stage/'migracion/auditoria-produccion.json',destino/f'auditoria-produccion-{PROFILE["version"]}.json')
        fuente=destino/f'LocalizacionHN_V2_Produccion_{PROFILE["version"]}_fuentes.zip'
        (stage/'README_PRODUCCION.md').write_text((ROOT/'documentacion/PRIMERA_INSTALACION_PRODUCCION.md').read_text())
        with zipfile.ZipFile(fuente,'w',zipfile.ZIP_DEFLATED) as archivo:
            # El snapshot de producción incluye herramientas de compilación/validación,
            # no generadores del esquema base que podrían reintroducir IDs 501xx.
            for carpeta in ['src','pruebas','migracion']:
                for p in (stage/carpeta).rglob('*'):
                    if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc':archivo.write(p,p.relative_to(stage))
            for nombre in ['compilar.py','verificar_artefactos.py','validar_celdas_rdlc.py']:
                p=stage/'herramientas'/nombre;archivo.write(p,p.relative_to(stage))
            for nombre in ['app.json','README_PRODUCCION.md']:archivo.write(stage/nombre,nombre)
        assert hashes=={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in original_files if p.is_file()},'Se modificó el proyecto base.'
        print(f'PRODUCCIÓN: {compiled.name}; {len(cambios)} identidades trasladadas; cero colisiones con API_BCPOS y {len(revisados)} paquetes locales.')
        print(f'Fuentes revisables: {fuente}')
        print('Base del sandbox conservada. No se ha publicado, instalado ni migrado información en ningún entorno.')


if __name__=='__main__': main()
