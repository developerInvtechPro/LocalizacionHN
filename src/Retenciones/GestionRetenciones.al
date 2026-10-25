namespace INVTECH.Honduras;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

codeunit 50101 "HN Retention Management"
{
    procedure CalculatePurchaseLine(var PurchaseLine: Record "Purchase Line")
    var
        Rule: Record "HN Retention Rule";
        Codes: List of [Text];
        Code: Text;
        Net: Decimal;
        Tax: Decimal;
        Header: Record "Purchase Header";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Precision: Decimal;
    begin
        if PurchaseLine.IsTemporary() then
            exit;
        Net := PurchaseLine.Amount;
        Tax := PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;
        Header.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if Header."Currency Code" = '' then begin
            GLSetup.Get();
            Precision := GLSetup."Amount Rounding Precision";
        end else begin
            Currency.Get(Header."Currency Code");
            Precision := Currency."Amount Rounding Precision";
        end;
        PurchaseLine."HN Retention Amount" := 0;
        Codes := NormalizeCodes(PurchaseLine."HN Retention Codes");
        foreach Code in Codes do begin
            Rule.Get(Code);
            Rule.TestField(Enabled, true);
            PurchaseLine."HN Retention Amount" += CalculateAmount(Rule, Net, Tax, Precision);
        end;
    end;

    procedure SelectCodes(var PurchaseLine: Record "Purchase Line")
    var
        Rule: Record "HN Retention Rule";
        Selection: Page "HN Retention Rules";
        Codes: Text;
    begin
        Rule.SetRange(Enabled, true);
        Selection.SetTableView(Rule);
        Selection.LookupMode(true);
        if Selection.RunModal() <> Action::LookupOK then exit;
        Selection.SetSelectionFilter(Rule);
        if Rule.FindSet() then
            repeat
                if Codes <> '' then Codes += ',';
                Codes += Rule.Code;
            until Rule.Next() = 0;
        if StrLen(Codes) > MaxStrLen(PurchaseLine."HN Retention Codes") then
            Error('La selección supera la longitud disponible.');
        PurchaseLine.Validate("HN Retention Codes", Codes);
    end;

    procedure NormalizeCodes(Input: Text): List of [Text]
    var
        Result: List of [Text];
        Parts: List of [Text];
        Part: Text;
    begin
        Parts := Input.Split(',');
        foreach Part in Parts do begin
            Part := UpperCase(DelChr(Part, '<>', ' '));
            if Part <> '' then begin
                if StrLen(Part) > 20 then
                    Error('El código de retención %1 excede 20 caracteres.', Part);
                if Result.Contains(Part) then
                    Error('El código de retención %1 está repetido.', Part);
                Result.Add(Part);
            end;
        end;
        exit(Result);
    end;

    procedure CalculateAmount(Rule: Record "HN Retention Rule"; Net: Decimal; Tax: Decimal; Precision: Decimal): Decimal
    var
        Base: Decimal;
    begin
        if (Rule.Percentage <= 0) or (Rule.Percentage > 100) then
            Error('Porcentaje inválido en la retención %1.', Rule.Code);
        if Rule."Calculation Base" = Rule."Calculation Base"::VAT then
            Base := Tax
        else
            Base := Net;
        if Base < Rule."Minimum Base" then
            exit(0);
        if Precision <= 0 then
            Error('La precisión de redondeo debe ser mayor que cero.');
        exit(Round(Base * Rule.Percentage / 100, Precision));
    end;

    procedure CreateFromInvoice(Invoice: Record "Purch. Inv. Header"): Code[20]
    var
        Setup: Record "HN Localization Setup";
        SetupManagement: Codeunit "HN Setup Management";
        Header: Record "HN Retention Header";
        Vendor: Record Vendor;
        Series: Codeunit "No. Series";
    begin
        SetupManagement.GetSetup(Setup);
        Setup.TestField("Retentions Enabled", true);
        Setup.TestField("Retention Nos.");
        Invoice.TestField("No.");
        Vendor.Get(Invoice."Pay-to Vendor No.");
        Header.Init();
        Header."No." := Series.GetNextNo(Setup."Retention Nos.", WorkDate());
        Header."Vendor No." := Vendor."No.";
        Header."Vendor Name" := Vendor.Name;
        Header."Vendor RTN" := Vendor."VAT Registration No.";
        Header."Posting Date" := WorkDate();
        Header."Currency Code" := Invoice."Currency Code";
        Header."Dimension Set ID" := Invoice."Dimension Set ID";
        Header.Insert(true);
        AddInvoice(Header, Invoice);
        exit(Header."No.");
    end;

    procedure AddInvoice(var Header: Record "HN Retention Header"; Invoice: Record "Purch. Inv. Header")
    var
        Source: Record "HN Retention Invoice";
        Existing: Record "HN Retention Header";
        Vendor: Record Vendor;
    begin
        Header.LockTable();
        Header.Get(Header."No.");
        Header.TestField(Status, Header.Status::Draft);
        Invoice.TestField("Pay-to Vendor No.", Header."Vendor No.");
        Invoice.TestField("Currency Code", Header."Currency Code");
        Vendor.Get(Header."Vendor No.");
        Vendor.TestField("HN Subject to Retention", true);
        if (Vendor."HN Retention Valid Until" <> 0D) and (Invoice."Posting Date" > Vendor."HN Retention Valid Until") then
            Error('La condición de retención del proveedor estaba vencida en la fecha de la factura.');
        Source.LockTable();
        Source.SetRange("Invoice No.", Invoice."No.");
        if Source.FindSet() then
            repeat
                Existing.Get(Source."Document No.");
                if Existing.Status <> Existing.Status::Cancelled then
                    Error('La factura %1 ya está incluida en el comprobante %2.', Invoice."No.", Existing."No.");
            until Source.Next() = 0;
        // Protege también los documentos anteriores a la actualización de facturas múltiples.
        Existing.Reset();
        Existing.SetRange("Invoice No.", Invoice."No.");
        Existing.SetFilter(Status, '<>%1', Existing.Status::Cancelled);
        if Existing.FindFirst() then
            Error('La factura %1 ya está incluida en el comprobante %2.', Invoice."No.", Existing."No.");
        Source.Reset();
        Source.Init();
        Source."Document No." := Header."No.";
        Source."Invoice No." := Invoice."No.";
        Source."Vendor Invoice No." := Invoice."Vendor Invoice No.";
        Source."Invoice CAI" := Invoice."HN Vendor CAI";
        Source."Invoice Date" := Invoice."Document Date";
        if Source."Invoice Date" = 0D then
            Source."Invoice Date" := Invoice."Posting Date";
        Source.Insert(true);
        RefreshSummary(Header);
        Recalculate(Header);
    end;

    procedure RemoveInvoice(var Header: Record "HN Retention Header"; InvoiceNo: Code[20])
    var
        Source: Record "HN Retention Invoice";
    begin
        Header.LockTable();
        Header.Get(Header."No.");
        Header.TestField(Status, Header.Status::Draft);
        Source.Get(Header."No.", InvoiceNo);
        Source.Delete(true);
        RefreshSummary(Header);
        Recalculate(Header);
    end;

    local procedure RefreshSummary(var Header: Record "HN Retention Header")
    var
        Source: Record "HN Retention Invoice";
    begin
        Clear(Header."Invoice No.");
        Clear(Header."Vendor Invoice No.");
        Clear(Header."Invoice CAI");
        Source.SetRange("Document No.", Header."No.");
        if Source.Count() = 1 then begin
            Source.FindFirst();
            Header."Invoice No." := Source."Invoice No.";
            Header."Vendor Invoice No." := Source."Vendor Invoice No.";
            Header."Invoice CAI" := Source."Invoice CAI";
        end;
        Header.Modify(true);
    end;

    procedure Recalculate(var Header: Record "HN Retention Header")
    var
        Source: Record "HN Retention Invoice";
        Invoice: Record "Purch. Inv. Header";
        InvoiceLine: Record "Purch. Inv. Line";
        Line: Record "HN Retention Line";
        Rule: Record "HN Retention Rule";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Codes: List of [Text];
        Code: Text;
        LineNo: Integer;
        BeforeInvoice: Integer;
        Precision: Decimal;
        Amount: Decimal;
    begin
        Header.TestField(Status, Header.Status::Draft);
        if Header."Currency Code" = '' then begin
            GLSetup.Get();
            Precision := GLSetup."Amount Rounding Precision";
        end else begin
            Currency.Get(Header."Currency Code");
            Precision := Currency."Amount Rounding Precision";
        end;
        Line.SetRange("Document No.", Header."No.");
        Line.DeleteAll(true);
        Source.SetRange("Document No.", Header."No.");
        if Source.FindSet() then
            repeat
                Invoice.Get(Source."Invoice No.");
                Invoice.TestField("Pay-to Vendor No.", Header."Vendor No.");
                Invoice.TestField("Currency Code", Header."Currency Code");
                if Invoice."Posting Date" > Header."Posting Date" then
                    Error('La emisión no puede ser anterior a la factura %1.', Invoice."No.");
                BeforeInvoice := LineNo;
                InvoiceLine.SetRange("Document No.", Source."Invoice No.");
                if InvoiceLine.FindSet() then
                    repeat
                        Codes := NormalizeCodes(InvoiceLine."HN Retention Codes");
                        foreach Code in Codes do begin
                            Rule.Get(Code);
                            Rule.TestField(Enabled, true);
                            Rule.TestField("G/L Account No.");
                            Amount := CalculateAmount(Rule, InvoiceLine.Amount, InvoiceLine."Amount Including VAT" - InvoiceLine.Amount, Precision);
                            if Amount > 0 then begin
                                LineNo += 10000;
                                Line.Init();
                                Line."Document No." := Header."No.";
                                Line."Line No." := LineNo;
                                Line."Invoice No." := Source."Invoice No.";
                                Line."Vendor Invoice No." := Source."Vendor Invoice No.";
                                Line."Invoice CAI" := Source."Invoice CAI";
                                Line."Invoice Date" := Source."Invoice Date";
                                Line."Invoice Line No." := InvoiceLine."Line No.";
                                Line."Retention Code" := Rule.Code;
                                Line.Description := Rule.Description;
                                if Rule."Calculation Base" = Rule."Calculation Base"::VAT then
                                    Line.Base := InvoiceLine."Amount Including VAT" - InvoiceLine.Amount
                                else
                                    Line.Base := InvoiceLine.Amount;
                                Line.Percentage := Rule.Percentage;
                                Line.Amount := Amount;
                                Line."G/L Account No." := Rule."G/L Account No.";
                                Line."Dimension Set ID" := InvoiceLine."Dimension Set ID";
                                Line.Insert(true);
                            end;
                        end;
                    until InvoiceLine.Next() = 0;
                if BeforeInvoice = LineNo then
                    Error('La factura %1 no tiene retenciones seleccionadas con importe positivo.', Source."Invoice No.");
            until Source.Next() = 0;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Post(var Header: Record "HN Retention Header")
    var
        Setup: Record "HN Localization Setup";
        SetupManagement: Codeunit "HN Setup Management";
        Line: Record "HN Retention Line";
        Source: Record "HN Retention Invoice";
        Entry: Record "Vendor Ledger Entry";
        InvoiceTotal: Decimal;
        Journal: Record "Gen. Journal Line";
        Authorization: Record "HN CAI Authorization";
        CAIMgt: Codeunit "HN CAI Management";
        PostLine: Codeunit "Gen. Jnl.-Post Line";
        Company: Record "Company Information";
    begin
        SetupManagement.GetSetup(Setup);
        Setup.TestField("Retentions Enabled", true);
        Header.LockTable();
        Header.Get(Header."No.");
        Header.TestField(Status, Header.Status::Draft);
        Header.TestField("Posting Date");
        Header.TestField("CAI Code");
        Header.TestField("Vendor RTN");
        Recalculate(Header);
        Header.CalcFields(Amount);
        if Header.Amount <= 0 then
            Error('El comprobante no tiene importe para registrar.');
        Entry.LockTable();
        Source.SetRange("Document No.", Header."No.");
        Source.FindSet();
        repeat
            Entry.Reset();
            Entry.SetRange("Vendor No.", Header."Vendor No.");
            Entry.SetRange("Document Type", Entry."Document Type"::Invoice);
            Entry.SetRange("Document No.", Source."Invoice No.");
            Entry.SetRange(Open, true);
            if not Entry.FindFirst() then
                Error('La factura %1 no tiene un movimiento de proveedor pendiente.', Source."Invoice No.");
            Entry.TestField("Currency Code", Header."Currency Code");
            Entry.CalcFields("Remaining Amount");
            Line.SetRange("Document No.", Header."No.");
            Line.SetRange("Invoice No.", Source."Invoice No.");
            Line.CalcSums(Amount);
            InvoiceTotal := Line.Amount;
            if InvoiceTotal > Abs(Entry."Remaining Amount") then
                Error('La retención de %1 supera el saldo pendiente de esa factura.', Source."Invoice No.");
        until Source.Next() = 0;
        Header."Fiscal No." := CAIMgt.Issue(Header."CAI Code", "HN Fiscal Document Type"::Retention, Header."Posting Date", Authorization);
        Header.CAI := Authorization.CAI;
        Header."CAI Starting No." := Authorization."Starting No.";
        Header."CAI Ending No." := Authorization."Ending No.";
        Header."CAI Valid Until" := Authorization."Valid Until";
        Line.Reset();
        Line.SetRange("Document No.", Header."No.");
        Line.FindSet();
        repeat
            InitJournal(Journal, Header, Line, Header."Posting Date", Line.Amount);
            Journal."HN Retention Doc." := Header."No.";
            Journal."HN Retention Line" := Line."Line No.";
            Journal."Applies-to Doc. Type" := Journal."Applies-to Doc. Type"::Invoice;
            Journal."Applies-to Doc. No." := Line."Invoice No.";
            PostLine.RunWithCheck(Journal);
        until Line.Next() = 0;
        Company.Get();
        Company.TestField("VAT Registration No.");
        Header."Issuer Name" := Company.Name;
        Header."Issuer RTN" := Company."VAT Registration No.";
        Header."Issuer Address" := CopyStr(Company.Address + ' ' + Company."Address 2" + ' ' + Company.City, 1, MaxStrLen(Header."Issuer Address"));
        Header.Status := Header.Status::Posted;
        Header."Registered At" := CurrentDateTime();
        Header."Registered By" := CopyStr(UserId(), 1, MaxStrLen(Header."Registered By"));
        Header.Modify(true);
    end;

    procedure InitJournal(var Journal: Record "Gen. Journal Line"; Header: Record "HN Retention Header"; Line: Record "HN Retention Line"; PostingDate: Date; Amount: Decimal)
    var
        SourceCodes: Record "Source Code Setup";
        Dimensions: Codeunit DimensionManagement;
    begin
        Clear(Journal);
        SourceCodes.Get();
        SourceCodes.TestField("General Journal");
        Journal."Posting Date" := PostingDate;
        Journal."Document Date" := PostingDate;
        Journal."Document No." := Header."No.";
        Journal."External Document No." := Header."Fiscal No.";
        Journal.Validate("Account Type", Journal."Account Type"::Vendor);
        Journal.Validate("Account No.", Header."Vendor No.");
        Journal.Validate("Currency Code", Header."Currency Code");
        Journal.Validate(Amount, Amount);
        Journal.Validate("Bal. Account Type", Journal."Bal. Account Type"::"G/L Account");
        Journal.Validate("Bal. Account No.", Line."G/L Account No.");
        Journal."Dimension Set ID" := Line."Dimension Set ID";
        Journal.Description := CopyStr(StrSubstNo('Retención %1 - %2', Line."Retention Code", Line."Vendor Invoice No."), 1, MaxStrLen(Journal.Description));
        Dimensions.UpdateGlobalDimFromDimSetID(Line."Dimension Set ID", Journal."Shortcut Dimension 1 Code", Journal."Shortcut Dimension 2 Code");
        Journal."Source Code" := SourceCodes."General Journal";
    end;
}
