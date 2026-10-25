"""Genera los campos aditivos y las páginas de compras sin renumerar datos publicados."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
s='namespace INVTECH.Honduras;\nusing Microsoft.Purchases.Document;\nusing Microsoft.Purchases.History;\nusing Microsoft.Purchases.Vendor;\n\n'
fields=[(71140,'HN Codigo CAI Proveedor','Code[20]','Autorización CAI del proveedor'),(71141,'HN Inicio CAI Proveedor','Code[20]','Rango inicial del proveedor'),(71142,'HN Fin CAI Proveedor','Code[20]','Rango final del proveedor'),(71143,'HN Vence CAI Proveedor','Date','Fecha límite CAI del proveedor')]
for no,name,target,posted in [(71110,'HN CAI Cabecera Compra','Purchase Header',False),(71111,'HN CAI Factura Compra','Purch. Inv. Header',True),(71112,'HN CAI Abono Compra','Purch. Cr. Memo Hdr.',True)]:
 s+=f'tableextension {no} "{name}" extends "{target}"\n{{\n    fields\n    {{\n'
 for fid,field,typ,caption in fields:
  s+=f'        field({fid}; "{field}"; {typ})\n        {{\n            Caption = \'{caption}\'; DataClassification = CustomerContent;\n'
  if posted or fid!=71140:s+='            Editable = false;\n'
  if not posted and fid==71140:
   s+='''            TableRelation = "HN CAI Proveedor".Codigo where("No. proveedor" = field("Buy-from Vendor No."));
            trigger OnValidate()
            var
                Gestion: Codeunit "HN Gestion CAI Proveedor";
            begin
                Gestion.ProponerDatos(Rec);
            end;
'''
  s+='        }\n'
 if target=='Purch. Cr. Memo Hdr.':s+='        field(71144; "HN Vendor CAI"; Code[37]) { Caption = \'CAI del proveedor\'; Editable = false; DataClassification = CustomerContent; }\n'
 s+='    }\n}\n\n'
(R/'src/Compras/CamposCAIProveedor.al').write_text(s)
s='namespace INVTECH.Honduras;\nusing Microsoft.Purchases.Document;\nusing Microsoft.Purchases.History;\nusing Microsoft.Purchases.Vendor;\n\n'
for no,pg,anchor,posted in [(71110,'Purchase Order','Vendor Invoice No.',False),(71111,'Purchase Invoice','Vendor Invoice No.',False),(71112,'Purchase Credit Memo','Vendor Cr. Memo No.',False),(71113,'Purchase Return Order','Vendor Cr. Memo No.',False),(71114,'Posted Purchase Invoice','Vendor Invoice No.',True),(71115,'Posted Purchase Credit Memo','Vendor Cr. Memo No.',True)]:
 s+=f'''pageextension {no} "HN CAI Compra Pagina {no}" extends "{pg}"
{{
    layout
    {{
        addafter("{anchor}")
        {{
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") {{ ApplicationArea = All; }}
        }}
    }}
    actions
    {{
        addlast(Processing)
        {{
'''
 if not posted:
  s+='''            action(ValidarCAIProveedor)
            {
                Caption = 'Validar CAI del proveedor'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion CAI Proveedor";
                begin
                    CurrPage.SaveRecord();
                    Gestion.ValidarCompra(Rec);
                    CurrPage.SaveRecord();
                    Message('La comprobación finalizó. Si la validación de compras está habilitada, el documento cumple las reglas configuradas.');
                end;
            }
'''
 s+='''            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
'''
 if posted:
  report='HN Comprobante Compra' if pg=='Posted Purchase Invoice' else 'HN Comprobante Abono Compra'
  s+=f'''            action(ImprimirComprobanteHN)
            {{
                Caption = 'Imprimir comprobante HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "{'Purch. Inv. Header' if pg=='Posted Purchase Invoice' else 'Purch. Cr. Memo Hdr.'}";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"{report}", true, false, Documento);
                end;
            }}
'''
 s+='        }\n    }\n}\n\n'
s+='''pageextension 71116 "HN Gestion CAI Ficha Proveedor" extends "Vendor Card"
{
    actions
    {
        addlast(Processing)
        {
            action(AutorizacionesCAI)
            {
                Caption = 'Gestionar CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("No.");
            }
        }
    }
}
'''
(R/'src/Compras/PaginasCAIProveedor.al').write_text(s)
