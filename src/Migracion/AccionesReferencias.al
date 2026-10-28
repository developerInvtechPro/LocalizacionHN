namespace INVTECH.Honduras;
using System.Reflection;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
pageextension 71131 "HN Consulta Ref 71131" extends "Purchase Order"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71132 "HN Consulta Ref 71132" extends "Purchase Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71133 "HN Consulta Ref 71133" extends "Purchase Credit Memo"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71134 "HN Consulta Ref 71134" extends "Posted Purchase Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71135 "HN Consulta Ref 71135" extends "Vendor Card"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71136 "HN Consulta Ref 71136" extends "Sales Order"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71137 "HN Consulta Ref 71137" extends "Sales Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71138 "HN Consulta Ref 71138" extends "Sales Credit Memo"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71139 "HN Consulta Ref 71139" extends "Posted Sales Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71140 "HN Consulta Ref 71140" extends "Posted Sales Credit Memo"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71141 "HN Consulta Ref 71141" extends "Company Information"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71142 "HN Consulta Ref 71142" extends "Purchase Order Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71143 "HN Consulta Ref 71143" extends "Purch. Invoice Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71144 "HN Consulta Ref 71144" extends "Posted Purch. Invoice Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71145 "HN Consulta Ref 71145" extends "Sales Order Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71146 "HN Consulta Ref 71146" extends "Sales Invoice Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
pageextension 71147 "HN Consulta Ref 71147" extends "Posted Sales Invoice Subform"
{
    actions
    {
        addlast(Processing)
        {
            action(ConsultarReferenciasAnteriores)
            {
                Caption = 'Referencias anteriores'; ApplicationArea = All; Image = View;
                trigger OnAction()
                var Datos: RecordRef; Gestion: Codeunit "HN Consultar Referencias";
                begin
                    CurrPage.SaveRecord();
                    Commit(); // Guardar únicamente el borrador antes de consultar una página modal.
                    Datos.GetTable(Rec);
                    Gestion.Mostrar(Datos);
                end;
            }
        }
    }
}
