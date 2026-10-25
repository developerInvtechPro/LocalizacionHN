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

tableextension 50101 "HN Debit Sales Header" extends "Sales Header"
{
    fields
    {
        field(50105; "HN Source Fiscal No."; Code[30]) { Caption = 'Número fiscal factura origen'; }
        field(50106; "HN Source CAI"; Code[37]) { Caption = 'CAI factura origen'; }
        field(50100; "HN Debit Note"; Boolean) { Caption = 'Nota de débito HN'; Editable = false; }
        field(50107; "HN Original Invoice No."; Code[20]) { Caption = 'Factura origen'; TableRelation = "Sales Invoice Header"; }
        field(50108; "HN Original Invoice Date"; Date) { Caption = 'Fecha factura origen'; }
        field(50109; "HN Debit Reason"; Text[250]) { Caption = 'Motivo nota de débito'; }
        field(50112; "HN Fiscal No."; Code[20]) { Caption = 'Número fiscal HN'; Editable = false; }
        field(50113; "HN CAI"; Code[37]) { Caption = 'CAI HN'; Editable = false; }
        field(50114; "HN CAI Starting No."; Code[20]) { Caption = 'Rango inicial CAI HN'; Editable = false; }
        field(50115; "HN CAI Ending No."; Code[20]) { Caption = 'Rango final CAI HN'; Editable = false; }
        field(50116; "HN CAI Valid Until"; Date) { Caption = 'Fecha límite CAI HN'; Editable = false; }
        field(50101; "HN CAI Code"; Code[20]) { Caption = 'Autorización CAI'; TableRelation = if ("HN Debit Note" = const(true)) "HN CAI Authorization" where("Document Type" = const("Debit Note"))
            else if ("Document Type" = const("Credit Memo")) "HN CAI Authorization" where("Document Type" = const(NotaCredito))
            else if ("Document Type" = const("Return Order")) "HN CAI Authorization" where("Document Type" = const(NotaCredito))
            else "HN CAI Authorization" where("Document Type" = const(Factura)); }
    }
}
tableextension 50102 "HN Debit Posted Header" extends "Sales Invoice Header"
{
    fields
    {
        field(50100; "HN Debit Note"; Boolean) { Caption = 'Nota de débito HN'; Editable = false; }
        field(50107; "HN Original Invoice No."; Code[20]) { Caption = 'Factura origen'; TableRelation = "Sales Invoice Header"; }
        field(50108; "HN Original Invoice Date"; Date) { Caption = 'Fecha factura origen'; }
        field(50109; "HN Debit Reason"; Text[250]) { Caption = 'Motivo nota de débito'; }
        field(50112; "HN Fiscal No."; Code[20]) { Caption = 'Número fiscal HN'; Editable = false; }
        field(50113; "HN CAI"; Code[37]) { Caption = 'CAI HN'; Editable = false; }
        field(50114; "HN CAI Starting No."; Code[20]) { Caption = 'Rango inicial CAI HN'; Editable = false; }
        field(50115; "HN CAI Ending No."; Code[20]) { Caption = 'Rango final CAI HN'; Editable = false; }
        field(50116; "HN CAI Valid Until"; Date) { Caption = 'Fecha límite CAI HN'; Editable = false; }
        field(50101; "HN CAI Code"; Code[20]) { Caption = 'Autorización CAI'; Editable = false; }
        field(50102; "HN Issuer Name"; Text[100]) { Caption = 'Emisor'; Editable = false; }
        field(50103; "HN Issuer RTN"; Text[20]) { Caption = 'RTN emisor'; Editable = false; }
        field(50104; "HN Issuer Address"; Text[200]) { Caption = 'Dirección emisor'; Editable = false; }
        field(50105; "HN Source Fiscal No."; Code[30]) { Caption = 'Número fiscal factura origen'; Editable = false; }
        field(50106; "HN Source CAI"; Code[37]) { Caption = 'CAI factura origen'; Editable = false; }
    }
}
codeunit 50102 "HN Debit Note Management"
{
    SingleInstance = true;
    procedure Post(var Header: Record "Sales Header"): Code[20]
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        ValidateDocument(Header);
        LastPostedNo := '';
        Header.Invoice := true;
        SalesPost.SetSuppressCommit(true);
        SalesPost.Run(Header);
        exit(LastPostedNo);
    end;

    procedure SelectOriginal(var Header: Record "Sales Header")
    var
        Original: Record "Sales Invoice Header";
        Invoices: Page "Posted Sales Invoices";
    begin
        Header.TestField("HN Debit Note", true);
        Header.TestField("Sell-to Customer No.");
        Original.SetRange("Sell-to Customer No.", Header."Sell-to Customer No.");
        Original.SetRange("HN Debit Note", false);
        Invoices.SetTableView(Original);
        Invoices.LookupMode(true);
        if Invoices.RunModal() = Action::LookupOK then begin
            Invoices.GetRecord(Original);
            Header."HN Original Invoice No." := Original."No.";
            Header."HN Original Invoice Date" := Original."Posting Date";
            Header."HN Source Fiscal No." := Original."HN Fiscal No.";
            Header."HN Source CAI" := Original."HN CAI";
            if Header."HN Source Fiscal No." = '' then
                Header."HN Source Fiscal No." := CopyStr(Original."External Document No.", 1, MaxStrLen(Header."HN Source Fiscal No."));
            Header.Modify(true);
        end;
    end;

    procedure ValidateDocument(Header: Record "Sales Header")
    var
        Original: Record "Sales Invoice Header";
        Authorization: Record "HN CAI Authorization";
        CAIMgt: Codeunit "HN CAI Management";
        Setup: Record "HN Localization Setup";
        SetupManagement: Codeunit "HN Setup Management";
    begin
        SetupManagement.CheckDebitConfiguration(Setup);
        Header.TestField("Document Type", Header."Document Type"::Invoice);
        Header.TestField("HN Debit Note", true);
        Header.TestField("HN Original Invoice No.");
        Header.TestField("HN Debit Reason");
        Header.TestField("HN Source Fiscal No.");
        if StrLen(Header."HN Source Fiscal No.") <> 19 then
            Error('Indique el número fiscal completo de la factura origen.');
        CAIMgt.ValidateFiscalNo(CopyStr(Header."HN Source Fiscal No.", 1, 20));
        Header.TestField("HN Source CAI");
        if StrLen(Header."HN Source CAI") <> 37 then
            Error('El CAI de la factura origen debe tener 37 caracteres.');
        Header.TestField("HN CAI Code");
        Header.TestField("VAT Registration No.");
        Original.Get(Header."HN Original Invoice No.");
        Original.TestField("HN Debit Note", false);
        if Original."HN Fiscal No." <> '' then begin
            Original.TestField("HN Fiscal No.", Header."HN Source Fiscal No.");
            Original.TestField("HN CAI", Header."HN Source CAI");
        end;
        Original.TestField("Sell-to Customer No.", Header."Sell-to Customer No.");
        Original.TestField("Bill-to Customer No.", Header."Bill-to Customer No.");
        Original.TestField("Currency Code", Header."Currency Code");
        if Header."Posting Date" < Original."Posting Date" then
            Error('La fecha de la nota de débito no puede ser anterior a su factura origen.');
        Header.CalcFields(Amount);
        if Header.Amount <= 0 then
            Error('La nota de débito debe tener un importe positivo.');
        Authorization.Get(Header."HN CAI Code");
        CAIMgt.ValidateAuthorization(Authorization, "HN Fiscal Document Type"::"Debit Note", Header."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure BeforePost(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
        Preview := PreviewMode;
        if SalesHeader."HN Debit Note" then
            ValidateDocument(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure BeforeInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    var
        Authorization: Record "HN CAI Authorization";
        CAIMgt: Codeunit "HN CAI Management";
        Original: Record "Sales Invoice Header";
        FiscalNo: Code[20];
        Company: Record "Company Information";
    begin
        if not SalesHeader."HN Debit Note" then exit;
        SalesInvHeader."HN Debit Note" := true;
        SalesInvHeader."HN CAI Code" := SalesHeader."HN CAI Code";
        SalesInvHeader."HN Debit Reason" := SalesHeader."HN Debit Reason";
        SalesInvHeader."HN Original Invoice No." := SalesHeader."HN Original Invoice No.";
        Original.Get(SalesHeader."HN Original Invoice No.");
        SalesInvHeader."HN Original Invoice Date" := Original."Posting Date";
        SalesInvHeader."HN Source Fiscal No." := SalesHeader."HN Source Fiscal No.";
        SalesInvHeader."HN Source CAI" := SalesHeader."HN Source CAI";
        if Preview then exit;
        Company.Get();
        Company.TestField("VAT Registration No.");
        SalesInvHeader."HN Issuer Name" := Company.Name;
        SalesInvHeader."HN Issuer RTN" := Company."VAT Registration No.";
        SalesInvHeader."HN Issuer Address" := CopyStr(Company.Address + ' ' + Company."Address 2" + ' ' + Company.City, 1, MaxStrLen(SalesInvHeader."HN Issuer Address"));
        LastPostedNo := SalesInvHeader."No.";
        FiscalNo := CAIMgt.Issue(SalesHeader."HN CAI Code", "HN Fiscal Document Type"::"Debit Note", SalesHeader."Posting Date", Authorization);
        SalesHeader."HN CAI" := Authorization.CAI;
        SalesHeader."HN CAI Starting No." := Authorization."Starting No.";
        SalesHeader."HN CAI Ending No." := Authorization."Ending No.";
        SalesHeader."HN CAI Valid Until" := Authorization."Valid Until";
        SalesHeader."HN Fiscal No." := FiscalNo;
        SalesHeader."External Document No." := FiscalNo;
        SalesInvHeader."HN CAI" := Authorization.CAI;
        SalesInvHeader."HN CAI Starting No." := Authorization."Starting No.";
        SalesInvHeader."HN CAI Ending No." := Authorization."Ending No.";
        SalesInvHeader."HN CAI Valid Until" := Authorization."Valid Until";
        SalesInvHeader."HN Fiscal No." := FiscalNo;
        SalesInvHeader."External Document No." := FiscalNo;
    end;

    var
        Preview: Boolean;
        LastPostedNo: Code[20];
}
