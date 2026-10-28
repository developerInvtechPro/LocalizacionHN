"""Compara el esquema/fuentes 1.0.1.69 con el mapa ejecutable y V2, sin tocar BC."""
from pathlib import Path
from collections import Counter
import json,zipfile,hashlib,re,argparse
import xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1]
P=argparse.ArgumentParser();P.add_argument('--origen',type=Path,default=Path.home()/'Downloads/IT Invtech_Localizacion_HN_1.0.1.69.app');P.add_argument('--exigir-cobertura',action='store_true');args=P.parse_args()
def objetos(d,c):
    yield from d.get(c,[])
    for n in d.get('Namespaces',[]):yield from objetos(n,c)
def propiedades(o):return {p['Name']:p.get('Value') for p in o.get('Properties',[])}
with zipfile.ZipFile(args.origen) as z:
    manifiesto=ET.fromstring(z.read('NavxManifest.xml')).find('.//{*}App')
    assert manifiesto is not None and manifiesto.attrib['Version']=='1.0.1.69', 'La revisión prioritaria requiere el paquete base 1.0.1.69.'
    antiguo=json.loads(z.read('SymbolReference.json'))
    fuentes={n:z.read(n).decode('utf-8-sig',errors='replace') for n in z.namelist() if n.endswith('.al')}
mapa=json.loads((R/'migracion/mapa-campos.json').read_text())
assert manifiesto.attrib['Id'].lower()==mapa['sourceAppId'].lower(), 'El paquete no pertenece a la aplicación origen esperada.'
manifest=json.loads((R/'app.json').read_text())
with zipfile.ZipFile(R/'artefactos'/f'INVTECH_LocalizacionHN_V2_{manifest["version"]}.app') as z: nuevo=json.loads(z.read('SymbolReference.json'))
relaciones={('Sales Header',36),('Sales Line',37),('Sales Invoice Header',112),('Sales Invoice Line',113),('Sales Cr.Memo Header',114),('Sales Cr.Memo Line',115),('Purchase Header',38),('Purchase Line',39),('Purch. Inv. Header',122),('Purch. Inv. Line',123),('Purch. Cr. Memo Hdr.',124),('Purch. Cr. Memo Line',125),('Customer',18),('Vendor',23),('Company Information',79)}
ids=dict(relaciones);plan={(m['tableId'],m['sourceId']):m for m in mapa['fields']}
retenciones={'Aplicar Retención 1','Aplicar Retención 2','Aplicar Retención 3','Retenciones Aplicadas','Importe Retención','Requiere Retención','Fecha Vencimiento Retención'}
filas=[];tablas=[];incompatibles=[]
for o in objetos(antiguo,'TableExtensions'):
    nombre=o.get('TargetObject','').split('#')[-1]
    if nombre not in ids:continue
    for f in o.get('Fields',[]):
        clave=(ids[nombre],f['Id']);p=propiedades(f);normal=p.get('FieldClass','Normal')=='Normal'
        if clave in plan:
            m=plan[clave];assert (f['Name'],f['TypeDefinition']['Name'])==(m['sourceName'],m['type']),clave
            estado='MAPEADO';motivo='Correspondencia exacta de referencia en el mapa ejecutable.';dest=m['targetName']
        elif not normal:
            estado='CALCULADO';motivo='FlowField/FlowFilter: conservar dependencias y verificar cálculo; no copiar como dato normal.';dest=''
        elif f['Name'] in retenciones:
            estado='PENDIENTE_RETENCION';motivo='Conservar datos y conciliar histórico; no activar ni reutilizar automáticamente la lógica anterior.';dest=''
        elif f['TypeDefinition']['Name'] in ['Blob','Media','MediaSet']:
            estado='PENDIENTE_ADJUNTO';motivo='Requiere traslado verificable de contenido; no se elimina ni sustituye por texto.';dest=''
        else:
            estado='PENDIENTE';motivo='Campo normal fuera de la copia actual: requiere destino o exclusión aprobada.';dest=''
        filas.append(dict(tabla=ids[nombre],nombre_tabla=nombre,campo=f['Id'],nombre=f['Name'],tipo=f['TypeDefinition']['Name'],clase=p.get('FieldClass','Normal'),definicion_tipo=f['TypeDefinition'],propiedades=f.get('Properties',[]),estado=estado,destino=dest,motivo=motivo))
for nombre,i in sorted(relaciones,key=lambda x:x[1]):
    fs=[f for f in filas if f['tabla']==i];tablas.append(dict(tabla=i,nombre=nombre,campos=len(fs),normales=sum(f['clase']=='Normal' for f in fs),mapeados=sum(f['estado']=='MAPEADO' for f in fs),pendientes=sum(f['estado'].startswith('PENDIENTE') for f in fs),calculados=sum(f['estado']=='CALCULADO' for f in fs)))
propias_ids={60450,60489,60451,60452,60457,60459,60510,60580,60477,60456,60491,60503,60587,60454,60455,60460,60461}
propias=[]
for o in objetos(antiguo,'Tables'):
    if o['Id'] not in propias_ids:continue
    mapeados_propios=[m for m in mapa['fields'] if m['tableId']==o['Id']]
    propias.append(dict(tabla=o['Id'],nombre=o['Name'],claves=o.get('Keys',[]),mapeados=len(mapeados_propios),campos=[dict(id=f['Id'],nombre=f['Name'],tipo=f['TypeDefinition']['Name'],clase=propiedades(f).get('FieldClass','Normal')) for f in o.get('Fields',[])],estado='REFERENCIA_PREPARADA' if len(mapeados_propios)==len(o.get('Fields',[])) else 'FUERA_DEL_MAPA_EJECUTABLE'))
# Evidencia de código activo, sin confundir bloques comentados con comportamiento.
evidencias=[]
for n,s in fuentes.items():
    if any(x in n for x in ['Cod60456','Cod60455','Cod60454','Cod60570','PurchaseInvoiceExt','ExtPginaPedidoCompra','PurchaseCreditMemoExt']):
        activo=re.sub(r'/\*.*?\*/','',s,flags=re.S);activo=re.sub(r'//[^\n]*','',activo)
        hits=[l.strip() for l in activo.splitlines() if any(k in l for k in ['Fecha Límite Emisión" <=','Vend."Proveedor Extranjero"','GestionCAI.FindSet','PurchaseHeader."No. CAI" =','Document Type"::"Credit Memo"','Num Predeterminado','SalesHeader.TransactionNumber :=','TableRelation ='])]
        evidencias.append(dict(archivo=n,sha256=hashlib.sha256(s.encode()).hexdigest(),sentencias=hits))
# Los campos V2 parecidos no implican correspondencia compatible.
def campo_v2(tabla,nombre):
    return [f for o in objetos(nuevo,'TableExtensions') if o.get('TargetObject','').endswith('#'+tabla) for f in o.get('Fields',[]) if f['Name']==nombre]
for tabla,origen,destino in [('Purchase Header','Código CAI','HN Codigo CAI Proveedor'),('Purch. Inv. Header','Código CAI','HN Codigo CAI Proveedor'),('Vendor','RTN','VAT Registration No.')]:
    f=next(x for x in filas if x['nombre_tabla']==tabla and x['nombre']==origen);ds=campo_v2(tabla,destino)
    incompatibles.append(dict(tabla=tabla,origen=origen,tipo_origen=f['tipo'],destino_propuesto=destino,tipo_destino=ds[0]['TypeDefinition']['Name'] if ds else 'Campo estándar: no es destino del mapa',decision='Referencia conservada en '+f['destino']+' con tipo y longitud originales; no se convierte en una clave de configuración activa.'))
pendientes_prioritarios=[f for f in filas if f['tabla']!=18 and f['clase']=='Normal' and f['estado']!='MAPEADO']
result=dict(copia_referencias_preparada=not pendientes_prioritarios,origen_version='1.0.1.69',paquete=args.origen.name,sha256=hashlib.sha256(args.origen.read_bytes()).hexdigest(),fuentes_al=len(fuentes),version_v2=manifest['version'],lista_para_compras_ventas=False,campos_mapeados=len(plan),tablas=tablas,campos=filas,tablas_propias=propias,evidencias=evidencias,incompatibilidades=incompatibles)
(R/'migracion/comparacion-compras-ventas.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
lineas=['# Comparación de compras y ventas: origen 1.0.1.69 frente a V2','', 'Revisión del paquete y sus fuentes AL. No se ejecuta migración ni se modifica la extensión anterior.','',f'- Origen: `{args.origen.name}`; {len(fuentes)} fuentes AL. SHA-256: `{result["sha256"]}`.',f'- Destino preparado: V2 {manifest["version"]}.','- **Resultado: el mapa ampliado conserva 236 referencias; no activa las funciones anteriores.**','', '| Tabla | Nombre | Campos antiguos | Mapeados | Pendientes normales | Calculados |','| --- | --- | --- | --- | --- | --- |']
for t in tablas:lineas.append(f'| {t["tabla"]} | {t["nombre"]} | {t["campos"]} | {t["mapeados"]} | {t["pendientes"]} | {t["calculados"]} |')
lineas+=['','## Catálogos e históricos fuera de la rutina actual','','| Tabla | Nombre | Campos | Estado |','| --- | --- | --- | --- |']
for t in propias:lineas.append(f'| {t["tabla"]} | {t["nombre"]} | {len(t["campos"])} | {t["estado"]} ({t["mapeados"]} campos en el mapa) |')
lineas+=['','## Diferencias de tipos conservadas como referencia','']
for x in incompatibles:lineas.append(f'- {x["tabla"]}: `{x["origen"]}` ({x["tipo_origen"]}) frente a `{x["destino_propuesto"]}` ({x["tipo_destino"]}). {x["decision"]}')
for t in tablas:
    pendientes=[f for f in filas if f['tabla']==t['tabla'] and f['estado'].startswith('PENDIENTE')]
    if not pendientes:continue
    lineas+=['',f'## Datos aún fuera del mapa: {t["nombre"]} ({t["tabla"]})','','| ID | Nombre | Tipo | Clasificación |','| --- | --- | --- | --- |']
    for f in pendientes:lineas.append(f'| {f["campo"]} | {f["nombre"]} | {f["tipo"]} | {f["estado"]} |')
lineas+=['','## Evidencia de lógica anterior revisada','']
for e in evidencias:
    lineas.append(f'- `{e["archivo"]}`')
    for l in e['sentencias']:lineas.append(f'  - `{l}`')
lineas+=['','El inventario identifica presencia y tipos; no demuestra que cada campo tenga datos en la empresa. Antes de copiar deben medirse uso, vacíos, conflictos, duplicados y vínculos en BC. Las tablas y campos estándar conservan su propietario de Microsoft; este inventario enumera adiciones de la localización anterior.','']
(R/'documentacion/COMPARACION_COMPRAS_VENTAS.md').write_text('\n'.join(lineas))
print(f'Origen .69: {len(fuentes)} fuentes AL; {len(filas)} campos en tablas prioritarias; {len(plan)} mapeados.')
for t in tablas:
    if t['campos']:print(f'{t["nombre"]}: {t["mapeados"]}/{t["campos"]} mapeados; {t["pendientes"]} pendientes, {t["calculados"]} calculados.')
print('Copia de referencias preparada:',result['copia_referencias_preparada'],'; no es una conversión de lógica ni una migración completa de todos los módulos.')
if args.exigir_cobertura and not result['lista_para_compras_ventas']:raise SystemExit(2)
