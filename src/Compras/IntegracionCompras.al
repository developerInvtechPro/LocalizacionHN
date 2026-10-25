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
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

codeunit 50103 "HN Purchase Integration"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvLineInsert', '', false, false)]
    local procedure CopySelections(var PurchInvLine: Record "Purch. Inv. Line"; var PurchaseLine: Record "Purchase Line"; var PurchInvHeader: Record "Purch. Inv. Header")
    var
        Setup: Record "HN Localization Setup";
        Management: Codeunit "HN Retention Management";
        Rule: Record "HN Retention Rule";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Codes: List of [Text];
        Code: Text;
        Precision: Decimal;
    begin
        if not Setup.Get('') then exit;
        if not Setup."Retentions Enabled" then exit;
        PurchInvLine."HN Retention Codes" := PurchaseLine."HN Retention Codes";
        if PurchInvHeader."Currency Code" = '' then begin
            GLSetup.Get();
            Precision := GLSetup."Amount Rounding Precision";
        end else begin
            Currency.Get(PurchInvHeader."Currency Code");
            Precision := Currency."Amount Rounding Precision";
        end;
        PurchInvLine."HN Retention Amount" := 0;
        Codes := Management.NormalizeCodes(PurchInvLine."HN Retention Codes");
        foreach Code in Codes do begin
            Rule.Get(Code);
            Rule.TestField(Enabled, true);
            PurchInvLine."HN Retention Amount" += Management.CalculateAmount(Rule, PurchInvLine.Amount, PurchInvLine."Amount Including VAT" - PurchInvLine.Amount, Precision);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure CopyInvoiceCAI(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header")
    begin
        PurchInvHeader."HN Vendor CAI" := PurchHeader."HN Vendor CAI";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure RefreshPurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        Setup: Record "HN Localization Setup";
        Management: Codeunit "HN Retention Management";
        OldAmount: Decimal;
    begin
        if not RunTrigger or Rec.IsTemporary() then exit;
        if not Setup.Get('') then exit;
        if not Setup."Retentions Enabled" then exit;
        OldAmount := Rec."HN Retention Amount";
        Management.CalculatePurchaseLine(Rec);
        if OldAmount <> Rec."HN Retention Amount" then
            Rec.Modify(false);
        RefreshHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertPurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    begin
        RefreshPurchaseLine(Rec, RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeletePurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        Setup: Record "HN Localization Setup";
    begin
        if not RunTrigger or Rec.IsTemporary() then exit;
        if Setup.Get('') then
            if Setup."Retentions Enabled" then RefreshHeader(Rec);
    end;

    local procedure RefreshHeader(PurchaseLine: Record "Purchase Line")
    var
        Header: Record "Purchase Header";
        Lines: Record "Purchase Line";
    begin
        if not Header.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then exit;
        Lines.SetRange("Document Type", PurchaseLine."Document Type");
        Lines.SetRange("Document No.", PurchaseLine."Document No.");
        Lines.CalcSums("HN Retention Amount");
        Header."HN Retention Amount" := Lines."HN Retention Amount";
        Header.Modify(false);
    end;
}
