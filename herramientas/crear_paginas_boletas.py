"""Integra pedidos/facturas estándar e impresión del comprobante registrado."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
s='namespace INVTECH.Honduras;\nusing Microsoft.Purchases.Document;\nusing Microsoft.Purchases.History;\n'
for n,page in [(71127,'Purchase Order'),(71128,'Purchase Invoice')]:
 s+=f'''pageextension {n} "HN Boleta Pagina {n}" extends "{page}"
{{
    layout
    {{
        addlast(General)
        {{
            field(HNBoleta; Rec."HN Boleta Compra") {{ ApplicationArea = All; }}
            field(HNIdentidadBoleta; Rec."HN Identidad Boleta") {{ ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }}
            field(HNTelefonoBoleta; Rec."HN Telefono Boleta") {{ ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }}
        }}
    }}
    actions
    {{
        addlast(Processing)
        {{
            action(PrepararBoleta)
            {{
                Caption = 'Emitir como boleta de compra'; ApplicationArea = All; Image = Purchase;
                trigger OnAction()
                var Gestion: Codeunit "HN Gestion Boletas";
                begin CurrPage.SaveRecord(); Gestion.Preparar(Rec); Rec.Modify(true); CurrPage.Update(false); end;
            }}
            action(BorradorBoleta)
            {{
                Caption = 'Imprimir borrador de boleta'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var Documento: Record "Purchase Header";
                begin CurrPage.SaveRecord(); Documento := Rec; Documento.SetRecFilter(); Report.RunModal(Report::"HN Borrador Boleta", true, false, Documento); end;
            }}
            action(QuitarBoleta)
            {{
                Caption = 'Volver a factura de proveedor'; ApplicationArea = All; Image = Cancel;
                trigger OnAction()
                begin Rec."HN Boleta Compra" := false; Rec.Modify(true); CurrPage.Update(false); end;
            }}
        }}
    }}
}}
'''
s+='''pageextension 71129 "HN Boleta Historico Pagina" extends "Posted Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field(HNBoleta; Rec."HN Boleta Compra") { ApplicationArea = All; }
            field(HNNumeroBoleta; Rec."HN Numero Boleta") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ImprimirBoleta)
            {
                Caption = 'Imprimir boleta de compra HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var Documento: Record "Purch. Inv. Header";
                begin Documento := Rec; Documento.SetRecFilter(); Report.RunModal(Report::"HN Boleta Compra", true, false, Documento); end;
            }
        }
    }
}
'''
(R/'src/Compras/Boletas/IntegracionPaginas.al').write_text(s)
