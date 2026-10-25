namespace INVTECH.Honduras;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

table 50100 "HN Localization Setup"
{
    Caption = 'Configuración localización HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Clave principal'; }
        field(2; "Retentions Enabled"; Boolean) { Caption = 'Habilitar retenciones HN'; }
        field(3; "Retention Nos."; Code[20]) { Caption = 'Serie interna de retenciones'; TableRelation = "No. Series"; }
        field(4; "Debit Note Nos."; Code[20]) { Caption = 'Serie interna de notas de débito'; TableRelation = "No. Series"; }
        field(5; "Debit Notes Enabled"; Boolean) { Caption = 'Habilitar notas de débito HN'; }
    }
    keys { key(PK; "Primary Key") { Clustered = true; } }
}
page 50100 "HN Localization Setup"
{
    PageType = Card;
    SourceTable = "HN Localization Setup";
    Caption = 'Configuración localización HN';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Rec."Retentions Enabled") { ApplicationArea = All; ToolTip = 'Habilita este módulo. No modifica ni desactiva otras extensiones instaladas.'; }
                field(DebitEnabled; Rec."Debit Notes Enabled") { ApplicationArea = All; ToolTip = 'Habilita las notas de débito de esta extensión.'; }
                field(RetentionNos; Rec."Retention Nos.") { ApplicationArea = All; ToolTip = 'Serie interna independiente del número fiscal.'; }
                field(DebitNos; Rec."Debit Note Nos.") { ApplicationArea = All; ToolTip = 'Serie interna de documentos de nota de débito.'; }
            }
        }
    }
    trigger OnOpenPage()
    var
        Management: Codeunit "HN Setup Management";
    begin
        Management.GetSetup(Rec);
    end;
}
