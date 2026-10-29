"""Genera destinos propios de referencia desde .69, sin activar configuración ni registrar documentos."""
from pathlib import Path
import json,re,zipfile,hashlib
R=Path(__file__).resolve().parents[1]
paquete=Path.home()/'Downloads/IT Invtech_Localizacion_HN_1.0.1.69.app'
with zipfile.ZipFile(paquete) as z:simbolos=json.loads(z.read('SymbolReference.json'))
def objetos(d,c):
 yield from d.get(c,[])
 for n in d.get('Namespaces',[]):yield from objetos(n,c)
def props(f):return {p['Name']:p.get('Value') for p in f.get('Properties',[])}
p=R/'migracion/mapa-campos.json';contrato=json.loads(p.read_text());base=[f for f in contrato['fields'] if not f.get('referenceOnly') and not f.get('extendedReference')]
# Mantener las 68 correspondencias publicadas y sus IDs.
assert len(base)==68
mapa=list(base)
for f in mapa:f['targetTableId']=f['tableId']
existentes={}
for archivo in (R/'src').rglob('*.al'):
 if archivo.name=='ReferenciasGeneradas.al':continue
 s=archivo.read_text()
 for trozo in re.split(r'(?m)^tableextension \d+ ',s)[1:]:
  t=re.search(r'extends "?([^"\n{]+)"?',trozo)
  if t:existentes.setdefault(t[1].strip(),set()).update(int(x) for x in re.findall(r'field\((\d+);',trozo))
tablas={'Sales Header':36,'Sales Line':37,'Sales Invoice Header':112,'Sales Invoice Line':113,'Purchase Header':38,'Purchase Line':39,'Purch. Inv. Header':122,'Purch. Inv. Line':123,'Vendor':23,'Company Information':79}
s='''namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;

'''
especificos={(38,60450):(50102,'HN Vendor CAI'),(38,60461):(71143,'HN Vence CAI Proveedor'),(38,60462):(71141,'HN Inicio CAI Proveedor'),(38,60463):(71142,'HN Fin CAI Proveedor'),(122,60450):(50102,'HN Vendor CAI'),(122,60461):(71143,'HN Vence CAI Proveedor'),(122,60462):(71141,'HN Inicio CAI Proveedor'),(122,60463):(71142,'HN Fin CAI Proveedor')}
captiones={'CompanyPhone':'Teléfono anterior de empresa','CompanyRTN':'RTN anterior de empresa','Batch':'Lote','Expected Receipt Date (Hdr)':'Fecha esperada de recepción','LabelSalesInvoice':'Etiqueta de factura','Image1':'Identificador anterior de imagen','Gas Station Code':'Código de sucursal','Retenciones Aplicadas':'Selección histórica de retenciones','Importe Retención':'Monto histórico retenido','Is Debit Note':'Indicador anterior de nota de débito','Debit Note Reason':'Motivo anterior de nota de débito','Debit Original Invoice No.':'Factura anterior de origen','Debit Original Invoice Date':'Fecha anterior de factura origen'}
for i,(nombre,tid) in enumerate(tablas.items()):
 campos=[f for o in objetos(simbolos,'TableExtensions') if o.get('TargetObject','').endswith('#'+nombre) for f in o.get('Fields',[]) if props(f).get('FieldClass','Normal')=='Normal']
 ocupados=existentes.get(nombre,set()).copy();nuevos=[]
 for f in campos:
  if any(x['tableId']==tid and x['sourceId']==f['Id'] for x in base):continue
  if (tid,f['Id']) in especificos:nid,nn=especificos[(tid,f['Id'])];estricto=False
  else:
   nid=next(n for n in range(71100,71200) if n not in ocupados);ocupados.add(nid);nn='HN Ref '+str(f['Id']);estricto=True
   caption=captiones.get(f['Name'],props(f).get('Caption',f['Name']))
   nuevos.append((nid,nn,f['TypeDefinition']['Name'],caption))
  mapa.append(dict(tableId=tid,table=nombre,sourceId=f['Id'],sourceName=f['Name'],targetId=nid,targetName=nn,type=f['TypeDefinition']['Name'],targetTableId=tid,referenceOnly=estricto,extendedReference=True))
 if nuevos:
  s+=f'tableextension {71119+i} "HN Ref Tabla {tid}" extends "{nombre}"\n{{\n    fields\n    {{\n'
  for nid,nn,tipo,caption in nuevos:
   s+=f'        field({nid}; "{nn}"; {tipo}) {{ Caption = \'Referencia: {caption.replace(chr(39),chr(39)*2)}\'; DataClassification = CustomerContent;{" Editable = false;" if tipo != "Blob" else ""} }}\n'
  s+='    }\n}\n\n'
# Catálogos e históricos se copian como referencias independientes, nunca como documentos activos.
seleccion=[60450,60489,60451,60452,60459,60510,60477,60457]
referencias=[]
for i,original in enumerate(seleccion):
 o=next(o for o in objetos(simbolos,'Tables') if o['Id']==original);nuevo=71113+i
 nombre='HN Ref Catalogo '+str(original); caption={60450:'CAI de proveedores (referencia)',60489:'CAI de ventas (referencia)',60451:'Grupos de impuesto (referencia)',60452:'Exoneraciones (referencia)',60459:'Medios de pago POS (referencia)',60510:'Distribución de pagos (ref.)',60477:'Boletas de compra (referencia)',60457:'Configuración fiscal (ref.)'}[original];fs=o['Fields']
 s+=f'table {nuevo} "{nombre}"\n{{\n    Caption = \'{caption}\'; DataClassification = CustomerContent;\n    fields\n    {{\n'
 for f in fs:
  tipo=f['TypeDefinition']['Name'];tipocodigo=tipo
  if tipo=='Enum':tipocodigo='Enum "'+f['TypeDefinition']['Subtype']['Name']+'"'
  cap={'Document Type':'Tipo de documento','Document No.':'Número de documento','Line No.':'Número de línea','Payment Method Code':'Forma de pago','Amount Including VAT':'Importe con impuestos','Percentage':'Porcentaje','Currency Code':'Moneda','Description':'Descripción','PaymentMethodsCode':'Código forma de pago','SalesHeaderNo':'Documento de venta','Amount':'Importe','TransactionNumber':'Número fiscal anterior','salesPaymentMethodId':'Identificador anterior'}.get(f['Name'],props(f).get('Caption',f['Name'])).replace(chr(39),chr(39)*2)
  s+=f'        field({f["Id"]}; "Ref {f["Id"]}"; {tipocodigo})\n        {{\n            Caption = \'{cap}\'; DataClassification = CustomerContent; Editable = false;\n'
  if tipo=='Option':
   opciones=','.join(chr(34)+m.replace(chr(34),chr(34)*2)+chr(34) for m in f['TypeDefinition']['OptionMembers'])
   opcion_caption=props(f).get('OptionCaption', ','.join(f['TypeDefinition']['OptionMembers'])).replace(chr(39),chr(39)*2)
   s+=f"            OptionMembers = {opciones};\n            OptionCaption = '{opcion_caption}';\n"
  s+='        }\n'
  mapa.append(dict(tableId=original,table=o['Name'],sourceId=f['Id'],sourceName=f['Name'],targetId=f['Id'],targetName='Ref '+str(f['Id']),type=tipo,targetTableId=nuevo,referenceOnly=True,extendedReference=True))
 s+='    }\n    keys\n    {\n        key(PK; '+', '.join('"Ref '+str(next(f['Id'] for f in fs if f['Name']==n))+'"' for n in o['Keys'][0]['FieldNames'])+') { Clustered = true; }\n    }\n}\n\n'
 s+=f'page {71117+i} "HN Ref Lista {original}"\n{{\n    Caption = \'{caption}\'; PageType = List; SourceTable = "{nombre}"; Editable = false;\n    ApplicationArea = All; UsageCategory = History;\n    layout\n    {{\n        area(Content)\n        {{\n            repeater(Referencias)\n            {{\n'
 for f in fs:s+=f'                field(Referencia{f["Id"]}; Rec."Ref {f["Id"]}") {{ ApplicationArea = All; }}\n'
 s+='            }\n        }\n    }\n}\n\n'
 referencias.append(dict(sourceTableId=original,targetTableId=nuevo,targetName=nombre,page='HN Ref Lista '+str(original)))
(R/'src/Migracion/ReferenciasGeneradas.al').write_text(s)
firma=hashlib.sha256(json.dumps(mapa,sort_keys=True,ensure_ascii=False).encode()).hexdigest()[:20].upper()
contrato['mapVersion']=firma
contrato['fields']=mapa;contrato['referenceTables']=referencias;contrato['sourceSymbolVersion']='1.0.1.69';p.write_text(json.dumps(contrato,indent=2,ensure_ascii=False)+'\n')
# Un único mapa controla todas las copias, con destino propio explícito.
s='''namespace INVTECH.Honduras;
codeunit 71103 "HN Migration Field Map"
{
    procedure Fill(TableID: Integer; var Map: Record "HN Migration Field" temporary)
    begin
        Map.Reset(); Map.DeleteAll();
        case TableID of
'''
for tid in sorted({f['tableId'] for f in mapa}|{115}):
 s+=f'            {tid}:\n                begin\n'
 for m in mapa:
  if m['tableId']==tid:s+=f'                    Add(Map, {m["sourceId"]}, \'{m["sourceName"]}\', {m["targetId"]}, \'{m["targetName"]}\', {m["targetTableId"]}, '+('true' if m.get('referenceOnly') else 'false')+');\n'
 s+='                end;\n'
s+='''            else Error('Tabla no autorizada para migración de referencias.');
        end;
    end;
    procedure TargetTable(TableID: Integer): Integer
    begin
        case TableID of
'''
for c in referencias:s+=f'            {c["sourceTableId"]}: exit({c["targetTableId"]});\n'
s+='''        end;
        exit(TableID);
    end;
    procedure VersionMap(): Code[20]
    begin
        exit('''+"'"+firma+"'"+''');
    end;
    local procedure Add(var Map: Record "HN Migration Field" temporary; SourceID: Integer; SourceName: Text[30]; TargetID: Integer; TargetName: Text[30]; TargetTable: Integer; ReferenceOnly: Boolean)
    begin
        Map.Init(); Map."Source ID" := SourceID; Map."Source Name" := SourceName;
        Map."Target ID" := TargetID; Map."Target Name" := TargetName;
        Map."Target Table ID" := TargetTable; Map."Reference Only" := ReferenceOnly; Map.Insert();
    end;
}
'''
(R/'src/Migracion/MapaCamposOrigen.al').write_text(s)
print(len(mapa),'campos; tablas de referencia:',len(referencias))

# Aplicar el plan publicado después de regenerar: nunca reactivar campos incompatibles.
from corregir_referencias_transferencia import main as corregir_transferencia
corregir_transferencia()
