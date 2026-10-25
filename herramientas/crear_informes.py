"""Genera formatos RDLC y datasets completos para documentos y movimientos HN."""
from pathlib import Path
import xml.etree.ElementTree as E
import copy
R=Path(__file__).resolve().parents[1]; D=R/'src/Informes/Disenos';D.mkdir(exist_ok=True)
NS='http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition';E.register_namespace('',NS)
def q(n):return '{'+NS+'}'+n
def adaptar_diseno(nombre,titulo,compra=False,borrador=False):
 t=E.parse(D/'NotaDebito.rdlc');r=t.getroot()
 for v in r.findall('.//'+q('Value')):
  if v.text:
   v.text=v.text.replace('NOTA DE DÉBITO',titulo).replace('Nota de débito',titulo)
   if compra:v.text=v.text.replace('Cliente','Proveedor').replace('cliente','proveedor')
   if 'Factura origen:' in v.text and 'CRÉDITO' not in titulo:
    v.text='="Documento BC: " & First(Fields!Document_No.Value)'
   if borrador and 'CAI:' in v.text:v.text='="DOCUMENTO DE TRABAJO — SIN VALIDEZ FISCAL"'
 t.write(D/nombre,encoding='utf-8',xml_declaration=True)

def columnas(expr):return '\n'.join(f'            column({k}; {v}) {{ }}' for k,v in expr.items())
comunes={'Document_No':'"No."','Fiscal_No':'"HN Fiscal No."','Issue_Date':'Format("Document Date")','Party_Name':'"Bill-to Name"','Party_RTN':'"HN RTN Destinatario"','Source_No':"''",'Source_CAI':"''",'Source_Date':"''",'Reason':"''",'CAI_Value':'"HN CAI"','CAI_Range':'"HN CAI Starting No." + \' / \' + "HN CAI Ending No."','CAI_Expiration':'Format("HN CAI Valid Until")','Currency_Code':'"Currency Code"','Issuer_Name':'"HN Issuer Name"','Issuer_RTN':'"HN Issuer RTN"','Issuer_Address':'"HN Issuer Address"','Subtotal_Amount':'Amount','Tax_Amount':'"Amount Including VAT" - Amount','Party_Address':'"Bill-to Address" + \' \' + "Bill-to Address 2" + \' \' + "Bill-to City"','Total_Amount':'"Amount Including VAT"'}
ventas={'Line_Quantity':'Quantity','Line_Unit_Price':'"Unit Price"','Line_Description':'Description','Line_Base':'Amount','Line_Rate':'"VAT %"','Line_Amount':'"Amount Including VAT"'}
namespace='''namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Foundation.Company;
using Microsoft.Finance.VAT.Ledger;
'''
code=namespace+'\n'
config=[(71110,'HN Factura Venta','Factura de venta HN','Sales Invoice Header','Sales Invoice Line','FacturaVenta.rdlc','FACTURA',False,False),
(71111,'HN Nota Credito Venta','Nota de crédito de venta HN','Sales Cr.Memo Header','Sales Cr.Memo Line','NotaCreditoVenta.rdlc','NOTA DE CRÉDITO',False,False),
(71112,'HN Comprobante Compra','Comprobante interno de factura de compra HN','Purch. Inv. Header','Purch. Inv. Line','FacturaCompra.rdlc','FACTURA DE COMPRA — CONTROL INTERNO',True,False),
(71113,'HN Comprobante Abono Compra','Comprobante interno de abono de compra HN','Purch. Cr. Memo Hdr.','Purch. Cr. Memo Line','AbonoCompra.rdlc','ABONO DE COMPRA — CONTROL INTERNO',True,False),
(71114,'HN Borrador Venta','Borrador de venta HN','Sales Header','Sales Line','BorradorVenta.rdlc','BORRADOR DE VENTA — SIN VALIDEZ FISCAL',False,True),
(71115,'HN Borrador Compra','Borrador de compra HN','Purchase Header','Purchase Line','BorradorCompra.rdlc','BORRADOR DE COMPRA — CONTROL INTERNO',True,True)]
for no,name,caption,header,line,layout,title,compra,borrador in config:
 assert len(name)<=30, f'El nombre técnico supera 30 caracteres: {name}'
 adaptar_diseno(layout,title,compra,borrador)
 cols=dict(comunes);details=dict(ventas);where='';pre=''
 if compra or borrador:
  cols.update(Issuer_Name='Empresa.Name',Issuer_RTN='Empresa."VAT Registration No."',Issuer_Address="Empresa.Address + ' ' + Empresa.City")
  pre='        Empresa.Get();\n'
 if compra:
  cols.update(Fiscal_No='"Vendor Invoice No."' if no!=71113 else '"Vendor Cr. Memo No."',Party_Name='"Buy-from Vendor Name"',Party_RTN='"VAT Registration No."',Party_Address='"Buy-from Address" + \' \' + "Buy-from Address 2" + \' \' + "Buy-from City"',CAI_Value='"HN Vendor CAI"',CAI_Range='"HN Inicio CAI Proveedor" + \' / \' + "HN Fin CAI Proveedor"',CAI_Expiration='Format("HN Vence CAI Proveedor")')
  details['Line_Unit_Price']='"Direct Unit Cost"'
 if borrador:
  cols.update(Fiscal_No="'SIN EMITIR'",CAI_Value="''",CAI_Range="''",CAI_Expiration="''")
  if not compra:cols['Party_RTN']='"VAT Registration No."'
 if no==71110:where='            DataItemTableView = where("HN Emitir Documento Fiscal" = const(true), "HN Debit Note" = const(false));\n'
 if no==71111:
  where='            DataItemTableView = where("HN Emitir Documento Fiscal" = const(true));\n'
  cols.update(Source_No='"HN Source Fiscal No."',Source_CAI='"HN Source CAI"',Source_Date='Format("HN Original Invoice Date")',Reason='"HN Motivo"')
 link='"Document No." = field("No.")'
 if borrador:link='"Document Type" = field("Document Type"), '+link
 check=''
 if no==71110:check='                TestField("HN Emitir Documento Fiscal", true);\n                TestField("HN Debit Note", false);\n'
 if no==71111:check='                TestField("HN Emitir Documento Fiscal", true);\n'
 code+=f'''report {no} "{name}"
{{
    Caption = '{caption}'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {{
        dataitem(Cabecera; "{header}")
        {{
{where}            RequestFilterFields = "No.";
{columnas(cols)}
            dataitem(Linea; "{line}")
            {{
                DataItemLink = {link};
{columnas(details)}
            }}
            trigger OnAfterGetRecord()
            begin
{check}                CalcFields(Amount, "Amount Including VAT");
            end;
        }}
    }}
    rendering {{ layout(Formato) {{ Type = RDLC; LayoutFile = 'src/Informes/Disenos/{layout}'; Caption = '{caption}'; }} }}
    trigger OnPreReport()
    begin
{pre}    end;
    var
        Empresa: Record "Company Information";
}}

'''
# El borrador de retención nunca utiliza el diseño como si fuera un comprobante emitido.
s=(R/'src/Informes/Comprobantes.al').read_text();start=s.index('report 50100');end=s.index('report 50101');ret=s[start:end].replace('report 50100 "HN Retention Certificate"','report 71116 "HN Borrador Retencion"').replace("Caption = 'Comprobante de retención HN'", "Caption = 'Borrador de retención HN'").replace("'src/Informes/Disenos/Retencion.rdlc'","'src/Informes/Disenos/BorradorRetencion.rdlc'")
ret=ret.replace('                if Status = Status::Draft then\n                    Error(\'No se puede imprimir un borrador como comprobante fiscal.\');','                TestField(Status, Status::Draft);')
ret=ret.replace("column(Fiscal_No; \"Fiscal No.\")", "column(Fiscal_No; 'SIN EMITIR')").replace('Clear(CancellationLabel);',"CancellationLabel := 'BORRADOR';")
ret=ret.replace('column(Issuer_Name; "Issuer Name")', 'column(Issuer_Name; Empresa.Name)').replace('column(Issuer_RTN; "Issuer RTN")', 'column(Issuer_RTN; Empresa."VAT Registration No.")').replace('column(Issuer_Address; "Issuer Address")', 'column(Issuer_Address; Empresa.Address)')
ret=ret.replace('    var\n        CancellationLabel:', '    trigger OnPreReport()\n    begin\n        Empresa.Get();\n    end;\n    var\n        Empresa: Record "Company Information";\n        CancellationLabel:')
code+=ret
layout=(D/'Retencion.rdlc').read_text().replace('COMPROBANTE DE RETENCIÓN','BORRADOR DE RETENCIÓN — SIN VALIDEZ FISCAL');(D/'BorradorRetencion.rdlc').write_text(layout)
# Informes de movimientos: moneda visible por línea, sin sumar saldos de divisas diferentes.
campos=['Titulo_Informe','Empresa','Numero_Movimiento','Fecha','Documento','Tercero','Descripcion','Debe','Haber','Saldo','Moneda']
def diseno_movimientos(nombre,titulo):
 compacto = any(x in nombre for x in ['Fiscales','Autorizaciones'])
 impuesto = nombre=='MovimientosISV.rdlc'
 importe = any(x in nombre for x in ['Contables','Aplicaciones'])
 t=E.parse(D/'Retencion.rdlc');r=t.getroot();tabla=r.find('.//'+q('Tablix'));body=tabla.find(q('TablixBody'))
 oldrow=body.find(q('TablixRows')).find(q('TablixRow'));cell=oldrow.find('.//'+q('TablixCell'))
 for e in list(body):body.remove(e)
 columns=E.SubElement(body,q('TablixColumns'))
 weights=[0.8,1.35,4.85] if compacto else ([0.68,1.05,3.75,0.76,0.76] if impuesto else [0.68,1.05,2.55,0.76,0.76,0.76,0.44])
 for w in weights:E.SubElement(E.SubElement(columns,q('TablixColumn')),q('Width')).text=f'{w}in'
 rows=E.SubElement(body,q('TablixRows'))
 def row(values,bold=False):
  rr=E.SubElement(rows,q('TablixRow'));E.SubElement(rr,q('Height')).text='0.28in';cells=E.SubElement(rr,q('TablixCells'))
  for i,v in enumerate(values):
   cc=copy.deepcopy(cell);cells.append(cc);tb=cc.find('.//'+q('Textbox'));tb.set('Name',f'Celda{len(rows)}_{i}')
   v0=tb.find('.//'+q('Value'));v0.text=v
   style=tb.find('.//'+q('TextRun')+'/'+q('Style'))
   if style is not None:
    fs=style.find(q('FontSize'))
    if fs is not None:fs.text='8pt'
    if bold:E.SubElement(style,q('FontWeight')).text='Bold'
   span=cc.find('.//'+q('ColSpan'))
   if span is not None:
    for parent in cc.iter():
     if span in list(parent):parent.remove(span);break
   if len(values)==1:E.SubElement(cc.find(q('CellContents')),q('ColSpan')).text=str(len(weights))
   if v in ['=Fields!Debe.Value','=Fields!Haber.Value','=Fields!Saldo.Value'] and style is not None:E.SubElement(style,q('Format')).text='N2'
 row([titulo],True)
 row(['=First(Fields!Empresa.Value)'],True)
 row(['Fecha / límite','Documento','Detalle / tercero'] if compacto else (['Fecha','Documento','Detalle / tercero','Base','Impuesto'] if impuesto else ['Fecha','Documento','Detalle / tercero','Debe','Haber','Importe' if importe else 'Saldo pendiente actual','Moneda']),True)
 row(['=Fields!Fecha.Value','=Fields!Documento.Value','=Fields!Descripcion.Value'] if compacto else (['=Fields!Fecha.Value','=Fields!Documento.Value','=Fields!Descripcion.Value','=Fields!Debe.Value','=Fields!Haber.Value'] if impuesto else ['=Fields!Fecha.Value','=Fields!Documento.Value','=Fields!Descripcion.Value','=Fields!Debe.Value','=Fields!Haber.Value','=Fields!Saldo.Value','=Fields!Moneda.Value']))
 hierarchy=tabla.find(q('TablixColumnHierarchy'));hierarchy.clear();members=E.SubElement(hierarchy,q('TablixMembers'))
 for _ in weights:E.SubElement(members,q('TablixMember'))
 hierarchy=tabla.find(q('TablixRowHierarchy'));hierarchy.clear();members=E.SubElement(hierarchy,q('TablixMembers'))
 E.SubElement(members,q('TablixMember'));E.SubElement(members,q('TablixMember'));E.SubElement(members,q('TablixMember'));detail=E.SubElement(members,q('TablixMember'));E.SubElement(detail,q('Group'),Name='DetalleMovimientos')
 fields=r.find('.//'+q('Fields'));fields.clear()
 for n in campos:
  f=E.SubElement(fields,q('Field'),Name=n);E.SubElement(f,q('DataField')).text=n
 t.write(D/nombre,encoding='utf-8',xml_declaration=True)

ledger=[(71117,'HN Movimientos Contables','Movimientos contables HN','G/L Entry','MovimientosContables.rdlc','"Posting Date", "Document No.", "G/L Account No."',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"G/L Account No."','Descripcion':'"G/L Account No." + \' | \' + Description + \' | Transacción: \' + Format("Transaction No.")','Debe':'"Debit Amount"','Haber':'"Credit Amount"','Saldo':'Amount','Moneda':"'ML'"},''),
(71118,'HN Movimientos Proveedor','Movimientos de proveedores HN','Vendor Ledger Entry','MovimientosProveedores.rdlc','"Vendor No.", "Posting Date", "Document No."',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"Vendor No."','Descripcion':'"Vendor No." + \' | \' + Description + \' | Documento externo: \' + "External Document No."','Debe':'"Debit Amount"','Haber':'"Credit Amount"','Saldo':'"Remaining Amount"','Moneda':'"Currency Code"'},'                CalcFields("Debit Amount", "Credit Amount", "Remaining Amount");\n'),
(71119,'HN Movimientos Cliente','Movimientos de clientes HN','Cust. Ledger Entry','MovimientosClientes.rdlc','"Customer No.", "Posting Date", "Document No."',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"Customer No."','Descripcion':'"Customer No." + \' | \' + Description + \' | Documento externo: \' + "External Document No."','Debe':'"Debit Amount"','Haber':'"Credit Amount"','Saldo':'"Remaining Amount"','Moneda':'"Currency Code"'},'                CalcFields("Debit Amount", "Credit Amount", "Remaining Amount");\n'),
(71120,'HN Inf. Movimientos Fiscales','Movimientos fiscales y CAI HN','HN Movimiento Fiscal','MovimientosFiscales.rdlc','"Es compra", "Fecha emision", "Numero fiscal", "No. tercero"',
 {'Numero_Movimiento':'"No. movimiento"','Fecha':'Format("Fecha emision")','Documento':'"Numero fiscal"','Tercero':'"No. tercero"','Descripcion':'Format("Tipo documento") + \' | \' + "Nombre tercero" + \' | CAI: \' + CAI + \' | BC: \' + "No. documento" + \' | Rango: \' + "Rango inicial" + \' / \' + "Rango final" + \' | Límite: \' + Format(Vencimiento)','Debe':'0','Haber':'0','Saldo':'0','Moneda':"''"},''),
(71121,'HN Listado CAI Ventas','Autorizaciones CAI de ventas HN','HN CAI Authorization','AutorizacionesVentas.rdlc','"Document Type", Code, Enabled',
 {'Numero_Movimiento':'0','Fecha':'Format("Valid Until")','Documento':'Code','Tercero':"''",'Descripcion':'Format("Document Type") + \' | CAI: \' + CAI + \' | Rango: \' + "Starting No." + \' / \' + "Ending No." + \' | Próximo: \' + "Next No." + \' | Habilitado: \' + Format(Enabled)','Debe':'0','Haber':'0','Saldo':'0','Moneda':"''"},''),
(71122,'HN Listado CAI Proveedores','Autorizaciones CAI de proveedores HN','HN CAI Proveedor','AutorizacionesProveedores.rdlc','"No. proveedor", Codigo, Habilitado',
 {'Numero_Movimiento':'0','Fecha':'Format("Fecha limite")','Documento':'Codigo','Tercero':'"No. proveedor"','Descripcion':'"No. proveedor" + \' | \' + "Nombre proveedor" + \' | CAI: \' + CAI + \' | Rango: \' + "Numero inicial" + \' / \' + "Numero final" + \' | Habilitado: \' + Format(Habilitado)','Debe':'0','Haber':'0','Saldo':'0','Moneda':"''"},'                CalcFields("Nombre proveedor");\n')]
ledger += [
(71123,'HN Det. Aplicacion Proveedor','Aplicaciones y desliquidaciones de proveedores HN','Detailed Vendor Ledg. Entry','AplicacionesProveedores.rdlc','"Vendor No.", "Posting Date", "Document No.", "Vendor Ledger Entry No."',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"Vendor No."','Descripcion':'"Vendor No." + \' | \' + Format("Entry Type") + \' | Movimiento proveedor: \' + Format("Vendor Ledger Entry No.") + \' | Desliquidado: \' + Format(Unapplied)','Debe':'"Debit Amount"','Haber':'"Credit Amount"','Saldo':'Amount','Moneda':'"Currency Code"'},''),
(71124,'HN Det. Aplicacion Cliente','Aplicaciones y desliquidaciones de clientes HN','Detailed Cust. Ledg. Entry','AplicacionesClientes.rdlc','"Customer No.", "Posting Date", "Document No.", "Cust. Ledger Entry No."',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"Customer No."','Descripcion':'"Customer No." + \' | \' + Format("Entry Type") + \' | Movimiento cliente: \' + Format("Cust. Ledger Entry No.") + \' | Desliquidado: \' + Format(Unapplied)','Debe':'"Debit Amount"','Haber':'"Credit Amount"','Saldo':'Amount','Moneda':'"Currency Code"'},''),
(71125,'HN Movimientos ISV','Movimientos de impuestos ISV HN','VAT Entry','MovimientosISV.rdlc','"Posting Date", "Document No.", Type, "VAT Prod. Posting Group"',
 {'Numero_Movimiento':'"Entry No."','Fecha':'Format("Posting Date")','Documento':'"Document No."','Tercero':'"Bill-to/Pay-to No."','Descripcion':'"Bill-to/Pay-to No." + \' | \' + Format(Type) + \' | Base: \' + Format(Base) + \' | Grupo: \' + "VAT Prod. Posting Group"','Debe':'Base','Haber':'Amount','Saldo':'0','Moneda':"'ML'"},'')]
for no,name,title,table,layout,filters,expr,calc in ledger:
 assert len(name)<=30, f'El nombre técnico supera 30 caracteres: {name}'
 diseno_movimientos(layout,title)
 cols={'Titulo_Informe':f"'{title}'",'Empresa':'Empresa.Name',**expr}
 code+=f'''report {no} "{name}"
{{
    Caption = '{title}'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {{
        dataitem(Movimiento; "{table}")
        {{
            RequestFilterFields = {filters};
{columnas(cols)}
            trigger OnAfterGetRecord()
            begin
{calc}            end;
        }}
    }}
    rendering {{ layout(Formato) {{ Type = RDLC; LayoutFile = 'src/Informes/Disenos/{layout}'; Caption = '{title}'; }} }}
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}}

'''
(R/'src/Informes/DocumentosYMovimientos.al').write_text(code)
print('16 formatos RDLC adicionales generados; total del proyecto: 18.')
