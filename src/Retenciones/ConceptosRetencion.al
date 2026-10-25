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

table 50104 "HN Retention Rule"
{
    Caption = 'Concepto de retención HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; Code; Code[20]) { Caption = 'Código'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Descripción'; }
        field(3; Percentage; Decimal) { Caption = 'Porcentaje'; DecimalPlaces = 0 : 5; MinValue = 0; MaxValue = 100; }
        field(4; "Minimum Base"; Decimal) { Caption = 'Base mínima'; MinValue = 0; }
        field(5; Enabled; Boolean) { Caption = 'Activo'; }
        field(6; "G/L Account No."; Code[20]) { Caption = 'Cuenta de retención por pagar'; TableRelation = "G/L Account" where("Account Type" = const(Posting), "Direct Posting" = const(true), Blocked = const(false)); }
        field(7; "Calculation Base"; Enum "HN Retention Base") { Caption = 'Base de cálculo'; }
    }
    keys { key(PK; Code) { Clustered = true; } }
}
page 50110 "HN Retention Rules"
{
    PageType = List;
    SourceTable = "HN Retention Rule";
    Caption = 'Conceptos de retención HN';
    ApplicationArea = All;
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            repeater(Rules)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Base; Rec."Calculation Base") { ApplicationArea = All; }
                field(Percentage; Rec.Percentage) { ApplicationArea = All; }
                field(Minimum; Rec."Minimum Base") { ApplicationArea = All; }
                field(Account; Rec."G/L Account No.") { ApplicationArea = All; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; }
            }
        }
    }
}
tableextension 50103 "HN Vendor Retentions" extends Vendor
{
    fields
    {
        field(50100; "HN Subject to Retention"; Boolean) { Caption = 'Sujeto a retención HN'; }
        field(50101; "HN Retention Valid Until"; Date) { Caption = 'Vencimiento condición de retención HN'; }
    }
}
pageextension 50103 "HN Vendor Retention Card" extends "Vendor Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field(HNSubject; Rec."HN Subject to Retention") { ApplicationArea = All; }
            field(HNValidUntil; Rec."HN Retention Valid Until") { ApplicationArea = All; }
        }
    }
}
