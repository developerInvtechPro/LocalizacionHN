"""Genera las páginas de emisión y los accesos a comprobantes en español."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
s='namespace INVTECH.Honduras;\nusing Microsoft.Sales.Document;\nusing Microsoft.Sales.History;\n\n'
for no,pg,credit in [(71120,'Sales Order',False),(71121,'Sales Invoice',False),(71122,'Sales Credit Memo',True),(71123,'Sales Return Order',True)]:
 s+=f'''pageextension {no} "HN Facturacion Pagina {no}" extends "{pg}"
{{
    layout
    {{
        addlast(General)
        {{
            field(HNEmitirFiscal; Rec."HN Emitir Documento Fiscal") {{ ApplicationArea = All; }}
            field(HNCAIVenta; Rec."HN CAI Code") {{ ApplicationArea = All; }}
'''
 if credit:
  s+='''            field(HNFacturaOrigen; Rec."HN Original Invoice No.")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                begin
                    Gestion.EstablecerOrigen(Rec);
                end;
            }
            field(HNNumeroOrigen; Rec."HN Source Fiscal No.") { ApplicationArea = All; }
            field(HNCAIOrigen; Rec."HN Source CAI") { ApplicationArea = All; }
            field(HNMotivoAbono; Rec."HN Debit Reason") { ApplicationArea = All; Caption = 'Motivo de la nota de crédito'; }
'''
 s+='''        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ConfiguracionFacturacionHN)
            {
                Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Config. Facturacion";
            }
            action(ValidarFacturacionHN)
            {
                Caption = 'Validar facturación HN'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                begin
                    CurrPage.SaveRecord();
                    Rec.TestField("HN Emitir Documento Fiscal", true);
                    Gestion.ValidarDocumento(Rec);
                    CurrPage.SaveRecord();
                    Message('El documento cumple la configuración fiscal de esta extensión.');
                end;
            }
        }
    }
}

'''
for no,pg,table,report in [(71124,'Posted Sales Invoice','Sales Invoice Header','HN Factura Venta'),(71125,'Posted Sales Credit Memo','Sales Cr.Memo Header','HN Nota Credito Venta')]:
 s+=f'''pageextension {no} "HN Impresion Venta {no}" extends "{pg}"
{{
    layout
    {{
        addlast(General)
        {{
            field(HNNumeroFiscal; Rec."HN Fiscal No.") {{ ApplicationArea = All; }}
        }}
    }}
    actions
    {{
        addlast(Processing)
        {{
            action(ImprimirFiscalHN)
            {{
                Caption = 'Imprimir comprobante fiscal HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "{table}";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"{report}", true, false, Documento);
                end;
            }}
        }}
    }}
}}

'''
(R/'src/Ventas/Facturacion/PaginasFacturacion.al').write_text(s)
