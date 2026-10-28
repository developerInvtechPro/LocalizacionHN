"""Contrasta el mapa contra paquetes locales de origen; no accede a datos de BC."""
from pathlib import Path
import json,zipfile
import xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1]
mapa=json.loads((R/'migracion/mapa-campos.json').read_text())
def objetos(datos,clase='TableExtensions'):
    yield from datos.get(clase,[])
    for n in datos.get('Namespaces',[]):yield from objetos(n,clase)
paquetes=sorted((R/'.alpackages').glob('*Localizacion_HN_*.app'))
base=Path.home()/'Downloads/IT Invtech_Localizacion_HN_1.0.1.69.app'
if base.exists() and not any(p.name==base.name for p in paquetes):paquetes.insert(0,base)
if not paquetes:raise SystemExit('Faltan paquetes locales del origen para contrastar su esquema.')
resultados=[]
for paquete in paquetes:
    with zipfile.ZipFile(paquete) as z:
        simbolos=json.loads(z.read('SymbolReference.json'))
        manifiesto=ET.fromstring(z.read('NavxManifest.xml'))
        app=manifiesto.find('.//{*}App')
        assert app is not None and app.attrib['Id'].lower()==mapa['sourceAppId'].lower(), f'Propietario inesperado: {paquete.name}'
    diferencias=[]
    for campo in mapa['fields']:
        encontrados=[f for o in objetos(simbolos) if o.get('TargetObject','').endswith('#'+campo['table']) for f in o.get('Fields',[]) if f['Id']==campo['sourceId']]
        encontrados += [f for o in objetos(simbolos,'Tables') if o['Id']==campo['tableId'] for f in o.get('Fields',[]) if f['Id']==campo['sourceId']]
        if len(encontrados)!=1 or (encontrados[0]['Name'],encontrados[0]['TypeDefinition']['Name'])!=(campo['sourceName'],campo['type']):
            diferencias.append({'tabla':campo['tableId'],'campo':campo['sourceId']})
    resultados.append({'paquete':paquete.name,'campos_mapa':len(mapa['fields']),'diferencias':diferencias})
    print(f'{paquete.name}: {len(mapa["fields"])-len(diferencias)} campos compatibles, {len(diferencias)} diferencias.')
(R/'artefactos').mkdir(exist_ok=True)
(R/'artefactos/validacion_mapa_origen.json').write_text(json.dumps(resultados,indent=2,ensure_ascii=False)+'\n')
if any(x['diferencias'] for x in resultados):raise SystemExit('Existen diferencias: revisar el mapa antes de ejecutar la copia.')
print('La coincidencia local de esquema no acredita datos copiados ni autoriza desinstalar el origen.')
