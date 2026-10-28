"""Verifica la independencia de V2, sus campos propios y los datasets de informes."""
import json, re, zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from validar_celdas_rdlc import validar_fila

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'app.json').read_text())
assert manifest.get('dependencies') == [], 'Se encontró una dependencia externa.'
package = root / 'artefactos' / f'INVTECH_LocalizacionHN_V2_{manifest["version"]}.app'
with zipfile.ZipFile(package) as archive:
    compiled_manifest = ET.fromstring(archive.read('NavxManifest.xml'))
    assert not compiled_manifest.findall('.//{*}Dependency'), 'El paquete compilado conserva dependencias.'
    symbols = json.loads(archive.read('SymbolReference.json'))
    disenos_empaquetados = {n: archive.read(n) for n in archive.namelist() if n.startswith('layout/')}

def objects(data, category):
    yield from data.get(category, [])
    for namespace in data.get('Namespaces', []):
        yield from objects(namespace, category)

rules = next(obj for obj in objects(symbols, 'Tables') if obj['Name'] == 'HN Retention Rule')
assert {'Code', 'Percentage', 'Calculation Base', 'G/L Account No.'} <= {f['Name'] for f in rules['Fields']}
required = {
    'HN Boleta Cabecera': {'HN Boleta Compra', 'HN Identidad Boleta', 'HN Telefono Boleta'},
    'HN Boleta Registrada': {'HN Numero Boleta', 'HN CAI Boleta', 'HN RTN Emisor Boleta'},
    'HN Proveedor Boleta': {'HN Persona Natural Hondurena', 'HN Identidad Boleta'},
    'HN Purchase Retention Line': {'HN Retention Codes', 'HN Retention Amount'},
    'HN Purchase Retention Header': {'HN Vendor CAI', 'HN Retention Amount'},
    'HN Posted Purchase Ret Line': {'HN Retention Codes', 'HN Retention Amount'},
    'HN Posted Purchase Ret Header': {'HN Vendor CAI'},
    'HN Vendor Retentions': {'HN Subject to Retention', 'HN Retention Valid Until'},
    'HN Debit Sales Header': {'HN Original Invoice No.', 'HN Debit Reason', 'HN Fiscal No.', 'HN CAI'},
    'HN Debit Posted Header': {'HN Original Invoice No.', 'HN Debit Reason', 'HN Fiscal No.', 'HN CAI'},
}
for obj in objects(symbols, 'TableExtensions'):
    if obj['Name'] in required:
        assert required.pop(obj['Name']) <= {field['Name'] for field in obj['Fields']}, obj['Name']
assert not required, f'Extensiones de tabla faltantes: {required}'
for source in (root / 'src').rglob('*.al'):
    if source.name == 'MapaCamposOrigen.al':
        continue  # Solo el mapa auditado de migración puede referirse a nombres de campos anteriores.
    text = re.sub(r"(?:Caption|ToolTip)\s*=\s*'(?:''|[^'])*';", '', source.read_text())
    for forbidden in ['HN Legacy', 'Config. Retenciones', 'CAI Facturación', 'Historico Comp.',
                      'Retenciones Aplicadas', 'Importe Retención', 'Is Debit Note',
                      'TransactionNumber', 'Requiere Retención', 'No. CAI']:
        assert forbidden not in text, f'Referencia anterior en {source.name}: {forbidden}'
print('Sin dependencias externas; conceptos y campos de compra, proveedor y venta declarados por V2.')

# Verifica cada formato referenciado y evita diseños con columnas o celdas incoherentes.
informes = []
for archivo in (root / 'src').rglob('*.al'):
    texto = archivo.read_text()
    for tipo, numero, nombre in re.findall(r'(?m)^(table|tableextension|page|pageextension|codeunit|report|enum|permissionset)\s+(\d+)\s+"([^"\n]+)"', texto):
        assert len(nombre) <= 30, f'Identificador demasiado largo: {archivo.name}/{nombre}'
    partes = re.split(r'(?m)^report \d+ ', texto)[1:]
    for parte in partes:
        columnas = set(re.findall(r'column\((\w+);', parte))
        columnas |= {columna + 'Format' for columna in columnas}
        rutas = re.findall(r"LayoutFile\s*=\s*'([^']+)'", parte)
        if rutas:
            nombre_informe = re.match(r'"([^"\n]+)"', parte)[1]
            activos = {'HN Retention Certificate', 'HN Debit Note Certificate', 'HN Borrador Retencion'}
            if nombre_informe in activos:
                assert 'UsageCategory = ReportsAndAnalysis;' in parte, f'Formato activo oculto: {nombre_informe}'
            else:
                assert 'UsageCategory = None;' in parte, f'Formato pospuesto visible: {nombre_informe}'
                assert 'DatosFormato.ComprobarFormatoActivo(' in parte, f'Formato pospuesto ejecutable: {nombre_informe}'
        for ruta in rutas:
            assert disenos_empaquetados.get('layout/' + ruta) == (root / ruta).read_bytes(), f'Diseño sin recompilar en el paquete: {ruta}'
            diseno = ET.parse(root / ruta)
            ns_rdlc = '{http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition}'
            assert diseno.getroot().tag == ns_rdlc + 'Report', f'Esquema RDLC anterior o incompatible: {ruta}'
            secciones = diseno.find('./' + ns_rdlc + 'ReportSections')
            assert secciones is not None and len(secciones) == 1, f'Se necesita una sección RDLC: {ruta}'
            for elemento in ['Body', 'Width', 'Page']:
                assert secciones[0].find(ns_rdlc + elemento) is not None, f'Falta {elemento} en ReportSection: {ruta}'
                assert diseno.getroot().find(ns_rdlc + elemento) is None, f'Estructura RDLC anterior: {ruta}'
            campos = {campo.attrib['Name'] for campo in diseno.findall('.//{*}Field')}
            assert campos <= columnas, f'Columnas faltantes en {ruta}: {campos-columnas}'
            for valor in diseno.findall('.//{*}Value'):
                for usado in re.findall(r'Fields!(\w+)\.Value', valor.text or ''):
                    assert usado in campos, f'Expresión sin campo {usado} en {ruta}'
            nombres = [c.attrib['Name'] for c in diseno.findall('.//{*}Textbox')]
            assert len(nombres) == len(set(nombres)), f'Cuadros de texto repetidos en {ruta}'
            for tabla in diseno.findall('.//{*}Tablix'):
                cuerpo = tabla.find('./{*}TablixBody')
                if cuerpo is None: continue
                jerarquia = tabla.find('./{*}TablixRowHierarchy')
                hojas = [m for m in jerarquia.findall('.//{*}TablixMember') if m.find('./{*}TablixMembers') is None]
                assert len(hojas) == len(cuerpo.findall('./{*}TablixRows/{*}TablixRow')), f'Filas y jerarquía incompatibles: {ruta}'
                ancho = len(cuerpo.findall('./{*}TablixColumns/{*}TablixColumn'))
                for fila in cuerpo.findall('./{*}TablixRows/{*}TablixRow'):
                    validar_fila(fila, ancho, ruta)
            informes.append(ruta)
assert len(informes) == 20, f'Se esperaban 20 formatos, se encontraron {len(informes)}'
print(f'{len(informes)} formatos RDLC: datasets, expresiones y estructura XML coherentes.')
for name in [f'INVTECH_LocalizacionHN_V2_{manifest["version"]}', f'INVTECH_LocalizacionHN_V2_Pruebas_{manifest["version"]}']:
    data = json.loads((root / 'artefactos' / (name + '.diagnostics.json')).read_text())
    results = [result for run in data.get('runs', []) for result in run.get('results', [])]
    assert not results and not data.get('issues', []), f'Diagnósticos pendientes: {name}'
print('Compilación sin diagnósticos. Falta ejecutar pruebas y renderizar comprobantes en Business Central.')

# Las identidades y tipos de datos V2 deben conservarse; compilar no acredita convivencia.
baseline = json.loads((root / 'migracion/esquema-v2-base.json').read_text())
for category in ['Tables', 'TableExtensions']:
    current = {obj['Name']: obj for obj in objects(symbols, category)}
    for old in baseline[category]:
        now = current[old['Name']]
        assert now['Id'] == old['Id'], f'Objeto renumerado: {old["Name"]}'
        current_fields = {field['Id']: field for field in now['Fields']}
        for field in old['Fields']:
            assert field['Id'] in current_fields, f'Campo retirado: {old["Name"]}/{field["Id"]}'
            new = current_fields[field['Id']]
            assert (new['Name'], new['TypeDefinition']) == (field['Name'], field['TypeDefinition']), f'Campo incompatible: {old["Name"]}/{field["Id"]}'
print('IDs, nombres y tipos de la versión V2 anterior conservados.')

mapping = json.loads((root / 'migracion/mapa-campos.json').read_text())['fields']
destinos = {}
for obj in objects(symbols, 'TableExtensions'):
    tabla = obj['TargetObject'].split('#')[-1]
    destinos.setdefault(tabla, {}).update({f['Id']:f for f in obj.get('Fields',[])})
for obj in objects(symbols, 'Tables'):
    destinos[obj['Id']] = {f['Id']:f for f in obj.get('Fields',[])}
for field in mapping:
    tabla = field['table'] if field.get('targetTableId',field['tableId'])==field['tableId'] else field['targetTableId']
    target = destinos[tabla][field['targetId']]
    assert (target['Name'],target['TypeDefinition']['Name'])==(field['targetName'],field['type']), field
print(f'{len(mapping)} destinos verificados con tipos y longitudes de origen.')
print('ATENCIÓN: migracion/inventario.json documenta conflictos de IDs con API_BCPOS; no desplegar juntos hasta resolverlos.')

mapa_al = (root / 'src/Migracion/MapaCamposOrigen.al').read_text()
pares_al = set(); tabla_actual = None
for linea in mapa_al.splitlines():
    numero = re.match(r'            (\d+):', linea)
    if numero: tabla_actual = int(numero.group(1))
    campo = re.search(r"Add\(Map, (\d+), '([^']+)', (\d+), '([^']+)', (\d+), (true|false)\)", linea)
    if campo: pares_al.add((tabla_actual, int(campo[1]), campo[2], int(campo[3]), campo[4], int(campo[5]), campo[6]=='true'))
esperados = {(f['tableId'],f['sourceId'],f['sourceName'],f['targetId'],f['targetName'],f.get('targetTableId',f['tableId']),f.get('referenceOnly',False)) for f in mapping}
assert pares_al == esperados, 'El mapa AL y el JSON no coinciden.'
assert len({(f.get('targetTableId',f['tableId']),f['targetId']) for f in mapping}) == len(mapping), 'Destinos repetidos en el mapa.'
print('Mapa AL y contrato JSON coinciden; destinos sin repeticiones por tabla.')
