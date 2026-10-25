"""Genera comprobante fiscal y borrador de boleta con datos exigidos por SAR, arts. 20–22."""
from pathlib import Path
import xml.etree.ElementTree as E
R=Path(__file__).resolve().parents[1];D=R/'src/Informes/Disenos'
NS='http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition';E.register_namespace('',NS)
def q(n):return '{'+NS+'}'+n
base=['Document_No','Fiscal_No','Issue_Date','Party_Name','Party_RTN','Source_No','Source_CAI','Source_Date','Reason','CAI_Value','CAI_Range','CAI_Expiration','Currency_Code','Issuer_Name','Issuer_RTN','Issuer_Address','Subtotal_Amount','Tax_Amount','Party_Address','Total_Amount']
extra=['Party_Phone','Issuer_Phone','Issuer_Email','Amount_Words','Exempt_Order','Exempt_Register','SAG_Register']
s='namespace INVTECH.Honduras;\nusing Microsoft.Purchases.Document;\nusing Microsoft.Purchases.History;\nusing Microsoft.Foundation.Company;\n'
for draft in [False,True]:
 no=71127 if draft else 71126;name='HN Borrador Boleta' if draft else 'HN Boleta Compra';file='BorradorBoleta.rdlc' if draft else 'BoletaCompra.rdlc';title='BORRADOR DE BOLETA — SIN VALIDEZ FISCAL' if draft else 'BOLETA DE COMPRA';header='Purchase Header' if draft else 'Purch. Inv. Header';line='Purchase Line' if draft else 'Purch. Inv. Line'
 cols=dict(zip(base,['"No."',"'SIN EMITIR'" if draft else '"HN Numero Boleta"','Format("Document Date")','"Buy-from Vendor Name"','"HN Identidad Boleta"',"''","''","''","''","''" if draft else '"HN CAI Boleta"',"''" if draft else '"HN Inicio Boleta" + \' / \' + "HN Fin Boleta"',"''" if draft else 'Format("HN Vence Boleta")',"'HNL'",'Empresa.Name' if draft else '"HN Nombre Emisor Boleta"','Empresa."VAT Registration No."' if draft else '"HN RTN Emisor Boleta"','Empresa.Address' if draft else '"HN Direccion Emisor Boleta"','Amount','"Amount Including VAT" - Amount','"Buy-from Address" + \' \' + "Buy-from Address 2" + \' \' + "Buy-from City"','"Amount Including VAT"']))
 cols.update(Party_Phone='"HN Telefono Boleta"',Issuer_Phone='Empresa."Phone No."' if draft else '"HN Telefono Emisor Boleta"',Issuer_Email='Empresa."E-Mail"' if draft else '"HN Correo Emisor Boleta"',Amount_Words='Letras.Convertir("Amount Including VAT")',Exempt_Order='"HN Orden Exenta Boleta"',Exempt_Register='"HN Registro Exento Boleta"',SAG_Register='"HN Registro SAG Boleta"')
 details={'Line_Quantity':'Quantity','Line_Unit_Price':'"Direct Unit Cost"','Line_Description':'Description','Line_Base':'Amount','Line_Rate':'"VAT %"','Line_Amount':'"Amount Including VAT"'}
 t=E.parse(D/'NotaDebito.rdlc');root=t.getroot()
 vals=root.findall('.//'+q('Value'))
 for v in vals:
  if not v.text:continue
  v.text=v.text.replace('NOTA DE DÉBITO',title).replace('Cliente/proveedor','Proveedor').replace('Cliente','Proveedor').replace('cliente','proveedor')
  if 'Factura origen:' in v.text:v.text='="Documento BC: " & First(Fields!Document_No.Value)'
  if 'Fecha factura origen:' in v.text:v.text='="Moneda: LEMPIRAS (HNL)"'
  if 'Motivo:' in v.text:v.text='="Importe en letras: " & First(Fields!Amount_Words.Value)'
  if 'Fields!Party_Address.Value' in v.text:v.text+=' & vbCrLf & "Teléfono proveedor: " & First(Fields!Party_Phone.Value)'
  if 'Fields!Issuer_Address.Value' in v.text:v.text+=' & vbCrLf & "Tel.: " & First(Fields!Issuer_Phone.Value) & " | Correo: " & First(Fields!Issuer_Email.Value)'
  if 'Original:' in v.text or 'Copia:' in v.text:v.text='Original: Contribuyente Adquirente | Copia: Proveedor'
 # Añadir requisitos en filas de ancho completo del tablix con nombres únicos.
 table=root.find('.//'+q('Tablix'));rows=table.find('./'+q('TablixBody')+'/'+q('TablixRows'));template=next(r for r in rows if len(r.findall('./'+q('TablixCells')+'/'+q('TablixCell')))==1)
 import copy
 for i,expr in enumerate(['="Firma del proveedor: ______________________    Huella digital: ______________________"','="Orden exenta: " & First(Fields!Exempt_Order.Value) & " | Registro exonerados: " & First(Fields!Exempt_Register.Value) & " | SAG: " & First(Fields!SAG_Register.Value)','="Original: Contribuyente Adquirente | Copia: Proveedor. No respalda crédito fiscal de ISV."']):
  row=copy.deepcopy(template)
  for j,tb in enumerate(row.findall('.//'+q('Textbox'))):tb.set('Name',f'BoletaExtra{i}_{j}')
  row.find('.//'+q('Value')).text=expr
  for font in row.findall('.//'+q('FontSize')):font.text='9pt'
  for color in row.findall('.//'+q('Color')):color.text='#203743'
  rows.append(row)
  members=table.find('./'+q('TablixRowHierarchy')+'/'+q('TablixMembers'));E.SubElement(members,q('TablixMember'))
 fields=root.find('.//'+q('Fields'))
 for n in extra:
  f=E.SubElement(fields,q('Field'),Name=n);E.SubElement(f,q('DataField')).text=n
 t.write(D/file,encoding='utf-8',xml_declaration=True)
 c=lambda d:'\n'.join(f'            column({k}; {v}) {{ }}' for k,v in d.items())
 link=('"Document Type" = field("Document Type"), ' if draft else '')+'"Document No." = field("No.")'
 filt='"HN Boleta Compra" = const(true)'
 s+=f'''report {no} "{name}"
{{
    Caption = '{title}'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {{
        dataitem(Cabecera; "{header}")
        {{
            DataItemTableView = where({filt});
            RequestFilterFields = {chr(34)+'Document Type'+chr(34)+', ' if draft else ''}"No.";
{c(cols)}
            dataitem(Linea; "{line}")
            {{
                DataItemLink = {link};
{c(details)}
            }}
            trigger OnAfterGetRecord()
            begin
                TestField("HN Boleta Compra", true);
{'' if draft else '                TestField("HN Numero Boleta");'}
                CalcFields(Amount, "Amount Including VAT");
            end;
        }}
    }}
    rendering {{ layout(Formato) {{ Type = RDLC; LayoutFile = 'src/Informes/Disenos/{file}'; Caption = '{title}'; }} }}
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
        Letras: Codeunit "HN Importe En Letras";
}}
'''
(R/'src/Informes/BoletasCompra.al').write_text(s)
