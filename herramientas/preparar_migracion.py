"""Genera el mapa de campos desde símbolos locales, sin conectarse a Business Central."""
import json, re, zipfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
# La base ya se amplió: no reemplazar el mapa completo con el generador inicial de 68 campos.
mapa_actual = ROOT / 'migracion/mapa-campos.json'
if mapa_actual.exists() and len(json.loads(mapa_actual.read_text())['fields']) > 68:
    raise SystemExit('El mapa está ampliado. Use preparar_referencias_hn.py para conservar todos los destinos; no regenere solo la base.')
LEGACY = ROOT / '.alpackages/IT Invtech_Localizacion_HN_1.0.1.69.app'
if not LEGACY.exists():
    LEGACY = Path.home() / 'Downloads/IT Invtech_Localizacion_HN_1.0.1.69.app'
if not LEGACY.exists():
    raise SystemExit('Falta el paquete base 1.0.1.69. No se sustituye por versiones con lógica posterior.')

def objects(data, category):
    yield from data.get(category, [])
    for namespace in data.get('Namespaces', []):
        yield from objects(namespace, category)

headers = [
 ('TransactionNumber','INV POS Transaction No.','Code[30]'),
 ('Gas Station Code','INV POS Station','Code[5]'), ('POS Code','INV POS Terminal','Code[5]'),
 ('Batch','INV POS Shift','Integer'), ('POS Sales Doc_ Type','INV POS Document Type','Integer'),
 ('Billing Type','INV POS Billing Type','Integer'), ('AmountTotal','INV POS Received Total','Decimal'),
 ('VATAmount','INV POS Received VAT','Decimal'), ('Usuario','INV POS Operator','Text[60]'),
 ('OC','INV POS Purchase Order','Text[60]'), ('NumeroDePlaca','INV POS Plate','Text[60]'),
 ('Kilometraje','INV POS Mileage','Text[60]'), ('Chofer','INV POS Driver','Text[60]'),
 ('Comentario','INV POS Comment','Text[60]'), ('Código CAI','INV POS CAI Code','Code[20]'),
 ('No. CAI','INV POS CAI','Code[37]'), ('Fecha Límite Emisión','INV POS CAI Expiration','Date'),
 ('Factura Inicial','INV POS CAI Start','Code[20]'), ('Factura Final','INV POS CAI End','Code[20]'),
 ('Código Exoneración','INV POS Exemption Code','Code[20]'), ('Monto Exonerado','INV POS Exempted Amount','Decimal'),
 ('OrdenDeCompraEXENTA','INV POS Exempt Order','Code[50]'),
 ('OrdenDeRegistroExonerados','INV POS Exemption Register','Code[50]'),
 ('OrdenDeCompraSAG','INV POS SAG Reference','Code[50]'), ('CAI','INV POS Additional CAI','Code[37]'),
]
lines = [
 ('Pump_No','INV POS Pump','Code[10]'), ('Pump_Position_No','INV POS Pump Position','Code[10]'),
 ('Tank_No','INV POS Tank','Code[10]'), ('Usuario','INV POS Line Operator','Code[50]'),
 ('VAT_PROD_POSTING_GROUP','INV POS Received VAT Rate','Decimal'),
 ('VAT_AMOUNT','INV POS Line Received VAT','Decimal'),
 ('AMOUNT_INCLUDING_VAT','INV POS Line Received Total','Decimal'),
]
customer = [('RTN','INV HN RTN','Code[50]'), ('CLienteExonerado','INV HN Exempt Customer','Boolean')]
tables = [(36,'Sales Header',headers),(112,'Sales Invoice Header',headers),(114,'Sales Cr.Memo Header',headers),
          (37,'Sales Line',lines),(113,'Sales Invoice Line',lines),(115,'Sales Cr.Memo Line',lines),(18,'Customer',customer)]
with zipfile.ZipFile(LEGACY) as z:
    symbols = json.loads(z.read('SymbolReference.json'))
extensions = list(objects(symbols,'TableExtensions'))
namespace = 'namespace INVTECH.Honduras;\nusing Microsoft.Sales.Document;\nusing Microsoft.Sales.History;\nusing Microsoft.Sales.Customer;\n\n'
source = namespace
mapping = []
for index,(tableid,tablename,fields) in enumerate(tables):
    source += f'tableextension {71101+index} "HN POS Metadata {index+1}" extends "{tablename}"\n{{\n    fields\n    {{\n'
    legacy_fields = {f['Name']:f for o in extensions if o.get('TargetObject','').endswith('#'+tablename) for f in o.get('Fields',[])}
    for n,(old,new,datatype) in enumerate(fields):
        fid=71100+n
        readonly = ' Editable = false;' if tableid in [112,113,114,115] else ''
        source += f'        field({fid}; "{new}"; {datatype}) {{ Caption = \'{new}\'; DataClassification = CustomerContent;{readonly} }}\n'
        if old in legacy_fields:
            f=legacy_fields[old]
            assert f['TypeDefinition']['Name']==datatype,(tablename,old,f['TypeDefinition'])
            mapping.append(dict(tableId=tableid,table=tablename,sourceId=f['Id'],sourceName=old,
                                targetId=fid,targetName=new,type=datatype))
    source+='    }\n}\n\n'
(ROOT/'src/IntegracionPOS/CamposPOS.al').write_text(source)
(ROOT/'migracion/mapa-campos.json').write_text(json.dumps(dict(sourceAppId='ba215fdf-ea75-4dcd-875e-70dd8c5c9ff8',
    sourceSymbolVersion='1.0.1.69',fields=mapping),indent=2,ensure_ascii=False)+'\n')
# El mapeo es explícito por tabla y no copia campos antiguos por coincidencia numérica.
code='''namespace INVTECH.Honduras;
codeunit 71103 "HN Migration Field Map"
{
    procedure Fill(TableID: Integer; var Map: Record "HN Migration Field" temporary)
    begin
        Map.Reset();
        Map.DeleteAll();
        case TableID of
'''
for tableid,tablename,_ in tables:
    code+=f'            {tableid}:\n                begin\n'
    for m in mapping:
        if m['tableId']==tableid:
            code+=f'                    Add(Map, {m["sourceId"]}, \'{m["sourceName"]}\', {m["targetId"]}, \'{m["targetName"]}\');\n'
    code+='                end;\n'
code+='''            else Error('Tabla no autorizada para migración de metadatos.');
        end;
    end;
    local procedure Add(var Map: Record "HN Migration Field" temporary; SourceID: Integer; SourceName: Text[30]; TargetID: Integer; TargetName: Text[30])
    begin
        Map.Init();
        Map."Source ID" := SourceID;
        Map."Source Name" := SourceName;
        Map."Target ID" := TargetID;
        Map."Target Name" := TargetName;
        Map.Insert();
    end;
}
'''
(ROOT/'src/Migracion/MapaCamposOrigen.al').write_text(code)
# La copia explícita al registrar incluye facturas, abonos y sus líneas.
code=namespace+'''using Microsoft.Sales.Posting;
codeunit 71102 "HN POS Metadata Transfer"
{
'''
for event,param,typ,srcname,srctype,fields in [
 ('OnBeforeSalesInvHeaderInsert','SalesInvHeader','Sales Invoice Header','SalesHeader','Sales Header',headers),
 ('OnBeforeSalesCrMemoHeaderInsert','SalesCrMemoHeader','Sales Cr.Memo Header','SalesHeader','Sales Header',headers),
 ('OnBeforeSalesInvLineInsert','SalesInvLine','Sales Invoice Line','SalesLine','Sales Line',lines),
 ('OnBeforeSalesCrMemoLineInsert','SalesCrMemoLine','Sales Cr.Memo Line','SalesLine','Sales Line',lines),
]:
    code+=f'''    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", '{event}', '', false, false)]
    local procedure {event}(var {param}: Record "{typ}"; {srcname}: Record "{srctype}")
    begin
'''
    for _,field,_ in fields: code+=f'        {param}."{field}" := {srcname}."{field}";\n'
    code+='    end;\n\n'
code+='}\n'
(ROOT/'src/IntegracionPOS/TransferenciaMetadatos.al').write_text(code)
# Conserva tipos y longitudes y respeta el propietario del cierre y del detalle de pagos.
print(f'{len(mapping)} campos mapeados en {len(tables)} tablas, sin modificar datos de Business Central.')
