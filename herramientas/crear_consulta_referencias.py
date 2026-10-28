"""Añade consulta de campos propios sin leer la extensión anterior."""
from pathlib import Path
R=Path(__file__).resolve().parents[1]
s='''namespace INVTECH.Honduras;
using System.Reflection;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
'''
for n,pagina in enumerate(['Purchase Order','Purchase Invoice','Purchase Credit Memo','Posted Purchase Invoice','Vendor Card','Sales Order','Sales Invoice','Sales Credit Memo','Posted Sales Invoice','Posted Sales Credit Memo','Company Information','Purchase Order Subform','Purch. Invoice Subform','Posted Purch. Invoice Subform','Sales Order Subform','Sales Invoice Subform','Posted Sales Invoice Subform'],71131):
 s+=f'''pageextension {n} "HN Consulta Ref {n}" extends "{pagina}"
{{
    actions
    {{
        addlast(Processing)
        {{
            action(ConsultarReferenciasAnteriores)
            {{
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }}
        }}
    }}
}}
'''
(R/'src/Migracion/AccionesReferencias.al').write_text(s)
