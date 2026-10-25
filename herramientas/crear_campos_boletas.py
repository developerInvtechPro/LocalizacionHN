"""Genera campos propios de boleta; conserva números y tipos publicados."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
campos=[(71160,'HN Boleta Compra','Boolean','Boleta de compra HN'),(71161,'HN Numero Boleta','Code[20]','Número fiscal de boleta'),(71162,'HN CAI Boleta','Code[37]','CAI de boleta'),(71163,'HN Autorizacion Boleta','Code[20]','Autorización de boleta'),(71164,'HN Inicio Boleta','Code[20]','Rango inicial de boleta'),(71165,'HN Fin Boleta','Code[20]','Rango final de boleta'),(71166,'HN Vence Boleta','Date','Fecha límite de boleta'),(71167,'HN Identidad Boleta','Text[20]','RTN o identidad del proveedor'),(71168,'HN Telefono Boleta','Text[30]','Teléfono del proveedor'),(71169,'HN Nombre Emisor Boleta','Text[100]','Nombre del emisor'),(71170,'HN RTN Emisor Boleta','Text[20]','RTN del emisor'),(71171,'HN Direccion Emisor Boleta','Text[200]','Dirección del emisor'),(71172,'HN Telefono Emisor Boleta','Text[30]','Teléfono del emisor'),(71173,'HN Correo Emisor Boleta','Text[80]','Correo del emisor'),(71174,'HN Orden Exenta Boleta','Text[100]','Orden de compra exenta'),(71175,'HN Registro Exento Boleta','Text[100]','Constancia de exonerados'),(71176,'HN Registro SAG Boleta','Text[100]','Registro SAG')]
s='namespace INVTECH.Honduras;\nusing Microsoft.Purchases.Document;\nusing Microsoft.Purchases.History;\nusing Microsoft.Purchases.Vendor;\n\n'
for num,name,table in [(71116,'HN Boleta Cabecera','Purchase Header'),(71117,'HN Boleta Registrada','Purch. Inv. Header')]:
 s+=f'tableextension {num} "{name}" extends "{table}"\n{{\n    fields\n    {{\n'
 for n,k,t,c in campos:
  if table=='Purchase Header' and n not in [71160,71167,71168,71174,71175,71176]:continue
  ed=' Editable = false;' if table!='Purchase Header' or n==71160 else ''
  s+=f'        field({n}; "{k}"; {t}) {{ Caption = \'{c}\'; DataClassification = CustomerContent;{ed} }}\n'
 s+='    }\n}\n\n'
s+='''tableextension 71118 "HN Proveedor Boleta" extends Vendor
{
    fields
    {
        field(71160; "HN Persona Natural Hondurena"; Boolean) { Caption = 'Persona natural hondureña para boletas'; DataClassification = CustomerContent; }
        field(71167; "HN Identidad Boleta"; Text[20]) { Caption = 'RTN o identidad para boletas'; DataClassification = CustomerContent; }
    }
}
'''
(R/'src/Compras/Boletas/CamposBoletas.al').write_text(s)
