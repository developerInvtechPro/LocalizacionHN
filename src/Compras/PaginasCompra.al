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

pageextension 50101 "HN Purchase Order Retentions" extends "Purchase Order Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field(HNSelectedRetentions; Rec."HN Retention Codes")
            {
                Caption = 'Retenciones aplicadas'; ApplicationArea = All; Visible = UseV2;
                ToolTip = 'Seleccione una o varias retenciones. También puede escribir códigos separados por comas.';
                trigger OnLookup(var Text: Text): Boolean
                var
                    Management: Codeunit "HN Retention Management";
                begin
                    Management.SelectCodes(Rec);
                    CurrPage.Update(true);
                    exit(true);
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        Setup: Record "HN Localization Setup";
    begin
        if Setup.Get('') then UseV2 := Setup."Retentions Enabled";
    end;
    var
        UseV2: Boolean;
}
pageextension 50102 "HN Purchase Invoice Retentions" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field(HNSelectedRetentions; Rec."HN Retention Codes")
            {
                Caption = 'Retenciones aplicadas'; ApplicationArea = All; Visible = UseV2;
                ToolTip = 'Seleccione una o varias retenciones para la línea de factura.';
                trigger OnLookup(var Text: Text): Boolean
                var
                    Management: Codeunit "HN Retention Management";
                begin
                    Management.SelectCodes(Rec);
                    CurrPage.Update(true);
                    exit(true);
                end;
            }
            field(HNRetentionAmount; Rec."HN Retention Amount") { ApplicationArea = All; Visible = UseV2; Editable = false; }
        }
    }
    trigger OnOpenPage()
    var
        Setup: Record "HN Localization Setup";
    begin
        if Setup.Get('') then UseV2 := Setup."Retentions Enabled";
    end;
    var
        UseV2: Boolean;
}
