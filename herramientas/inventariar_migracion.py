"""Inspecciona manifiestos, símbolos y referencias AL sin modificar los proyectos de origen."""
import hashlib, json, re, zipfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = Path.home() / 'Downloads'
API = DOWNLOADS / 'API_BCPOS_INVTECH_1-2'
VALIDATION = DOWNLOADS / 'Validacion_Facturas_Default Publisher_1-2'

def objects(data, category):
    yield from data.get(category, [])
    for namespace in data.get('Namespaces', []):
        yield from objects(namespace, category)

def symbols(path):
    with zipfile.ZipFile(path) as archive:
        return json.loads(archive.read('SymbolReference.json'))

def fields(data):
    return {(o['TargetObject'].split('#')[-1], f['Id']): f['Name']
            for o in objects(data, 'TableExtensions') for f in o.get('Fields', [])}

manifest=json.loads((ROOT/'app.json').read_text())
v2=symbols(ROOT/'artefactos'/f'INVTECH_LocalizacionHN_V2_{manifest["version"]}.app')
api=symbols(API/'INVTECH_API_BCPOS_1.0.0.41.app')
collisions=[]
a,b=fields(v2),fields(api)
for table,field in sorted(a.keys() & b.keys()):
    collisions.append(dict(kind='field',table=table,id=field,v2=a[(table,field)],api=b[(table,field)]))
for category in ['Tables','Pages','Codeunits','TableExtensions','PageExtensions','Enums','PermissionSets','Reports']:
    a={o['Id']:o['Name'] for o in objects(v2,category)}
    b={o['Id']:o['Name'] for o in objects(api,category)}
    for i in sorted(a.keys() & b.keys()):collisions.append(dict(kind=category,id=i,v2=a[i],api=b[i]))
references=[]
# Las referencias encontradas son un inventario, no una validación completa de funcionamiento.
pattern=re.compile(r'TransactionNumber|No\. CAI|Código CAI|Pump_No|Pump_Position_No|Tank_No|VAT_PROD_POSTING_GROUP|VAT_AMOUNT|AMOUNT_INCLUDING_VAT|\.RTN\b|TryGetSalesHeaderFieldText|IsBomberoField|IsPosCloseIdField|GetOperationalDateFromPosClose')
projects=[]
for project in [API,VALIDATION]:
    app=json.loads((project/'app.json').read_text())
    projects.append(dict(path=str(project),id=app['id'],name=app['name'],version=app['version'],dependencies=app.get('dependencies',[])))
    for p in sorted(project.rglob('*.al')):
        if any(part in ['.git','.alpackages'] for part in p.parts):continue
        body=p.read_text(encoding='utf-8-sig')
        for line,text in enumerate(body.splitlines(),1):
            if pattern.search(text):references.append(dict(project=app['name'],file=str(p.relative_to(project)),line=line,reference=text.strip()))
result=dict(status='PREPARACION_NO_DESPLEGAR',projects=projects,collisions=collisions,references=references,
            fieldMapSHA256=hashlib.sha256((ROOT/'migracion/mapa-campos.json').read_bytes()).hexdigest(),
            blockers=['Conflictos de IDs ya presentes entre V2 y API_BCPOS; resolver sin renumeración directa ni ForceSync.',
                      'Resolver catálogo Código CAI → CAI completo y conservar CAI adicional; no copiar el código como autorización completa.',
                      'Adaptar y validar receptor, páginas de clientes, revisión/cierre y filtros dinámicos antes del corte.',
                      'Ejecutar conciliación de datos y pruebas de registro/devoluciones/T3 en sandbox.'])
(ROOT/'migracion/inventario.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
assert not [c for c in collisions if c['id']>=71100], 'El rango nuevo también colisiona.'
print(f'{len(collisions)} colisiones preexistentes; {len(references)} referencias para revisar. Sin escrituras en Descargas ni en BC.')
