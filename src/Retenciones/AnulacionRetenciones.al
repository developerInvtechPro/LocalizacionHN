namespace INVTECH.Honduras;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.History;

tableextension 71100 "HN Retention Journal Link" extends "Gen. Journal Line"
{
    fields
    {
        field(71180; "HN Retention Doc."; Code[20]) { DataClassification = CustomerContent; }
        field(71181; "HN Retention Line"; Integer) { DataClassification = SystemMetadata; }
    }
}

codeunit 71101 "HN Retention Cancellation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterVendLedgEntryInsert', '', false, false)]
    local procedure CaptureEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        Line: Record "HN Retention Line";
    begin
        if GenJournalLine."HN Retention Doc." = '' then
            exit;
        Line.Get(GenJournalLine."HN Retention Doc.", GenJournalLine."HN Retention Line");
        Line.TestField("Vendor Entry No.", 0);
        Line."Vendor Entry No." := VendorLedgerEntry."Entry No.";
        Line.Modify(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Cancel(var Header: Record "HN Retention Header"; Reason: Text[250]; CancellationDate: Date; TaxCorrectionReference: Text[100])
    var
        Line: Record "HN Retention Line";
        Entry: Record "Vendor Ledger Entry";
        ApplyingEntry: Record "Vendor Ledger Entry";
        Detail: Record "Detailed Vendor Ledg. Entry";
        Parameters: Record "Apply Unapply Parameters";
        Journal: Record "Gen. Journal Line";
        ApplyManagement: Codeunit "VendEntry-Apply Posted Entries";
        SetApplication: Codeunit "Vend. Entry-SetAppl.ID";
        PostLine: Codeunit "Gen. Jnl.-Post Line";
        Management: Codeunit "HN Retention Management";
        ApplicationID: Code[50];
    begin
        Header.LockTable();
        Header.Get(Header."No.");
        Header.TestField(Status, Header.Status::Posted);
        if DelChr(Reason, '<>', ' ') = '' then
            Error('Indique el motivo de anulación.');
        if (CancellationDate = 0D) or (CancellationDate < Header."Posting Date") then
            Error('La fecha de anulación debe ser igual o posterior a la emisión.');
        if Header."Tax Reported" and (DelChr(TaxCorrectionReference, '<>', ' ') = '') then
            Error('La retención está declarada o enterada. Registre la referencia de la revisión/rectificación fiscal realizada fuera de Business Central.');
        Line.SetRange("Document No.", Header."No.");
        if not Line.FindSet() then
            Error('El comprobante no tiene movimientos vinculados.');
        repeat
            Line.TestField("Vendor Entry No.");
            Entry.Get(Line."Vendor Entry No.");
            Entry.TestField("Vendor No.", Header."Vendor No.");
            Entry.TestField("Document No.", Header."No.");
            Entry.TestField("Currency Code", Header."Currency Code");
            Entry.TestField(Reversed, false);
            Entry.CalcFields(Amount);
            Entry.TestField(Amount, Line.Amount);
            // La desliquidación utiliza el motor estándar de Business Central para conservar la integridad de los saldos.
            Detail.Reset();
            Detail.SetRange("Vendor Ledger Entry No.", Entry."Entry No.");
            Detail.SetRange("Entry Type", Detail."Entry Type"::Application);
            Detail.SetRange(Unapplied, false);
            if not Detail.IsEmpty() then begin
                ApplyManagement.CheckVendorLedgerEntryToUnapply(Entry."Entry No.", Detail);
                Parameters.Init();
                Parameters."Document No." := Header."No.";
                Parameters."Posting Date" := CancellationDate;
                ApplyManagement.PostUnApplyVendorCommit(Detail, Parameters, false);
            end;
            Entry.Get(Line."Vendor Entry No.");
            Entry.CalcFields("Remaining Amount");
            Entry.TestField("Remaining Amount", Line.Amount);
            Entry.TestField("Applies-to ID", '');
            Entry.SetRecFilter();
            ApplicationID := Format(CreateGuid());
            SetApplication.SetApplId(Entry, ApplyingEntry, ApplicationID);
            Management.InitJournal(Journal, Header, Line, CancellationDate, -Line.Amount);
            Journal."Currency Factor" := Entry."Original Currency Factor";
            Journal."Applies-to ID" := ApplicationID;
            Journal.Correction := true;
            Journal.Description := CopyStr('Anulación ' + Header."Fiscal No.", 1, MaxStrLen(Journal.Description));
            PostLine.RunWithCheck(Journal);
            Entry.Reset();
            Entry.Get(Line."Vendor Entry No.");
            Entry.CalcFields("Remaining Amount");
            Entry.TestField("Remaining Amount", 0);
        until Line.Next() = 0;
        Header.Status := Header.Status::Cancelled;
        Header."Cancelled At" := CurrentDateTime();
        Header."Cancelled By" := CopyStr(UserId(), 1, MaxStrLen(Header."Cancelled By"));
        Header."Cancellation Reason" := Reason;
        Header."Cancellation Date" := CancellationDate;
        Header."Tax Correction Ref." := TaxCorrectionReference;
        // Este servicio controla el cambio de estado de un comprobante emitido y conservado para auditoría.
        Header.Modify(false);
    end;

    procedure MarkReported(var Header: Record "HN Retention Header")
    begin
        Header.LockTable();
        Header.Get(Header."No.");
        Header.TestField(Status, Header.Status::Posted);
        Header."Tax Reported" := true;
        Header.Modify(false);
    end;

    procedure CreateReplacement(Header: Record "HN Retention Header"): Code[20]
    var
        Source: Record "HN Retention Invoice";
        Invoice: Record "Purch. Inv. Header";
        Replacement: Record "HN Retention Header";
        Management: Codeunit "HN Retention Management";
    begin
        Header.TestField(Status, Header.Status::Cancelled);
        Source.SetRange("Document No.", Header."No.");
        Source.FindSet();
        repeat
            Invoice.Get(Source."Invoice No.");
            if Replacement."No." = '' then
                Replacement.Get(Management.CreateFromInvoice(Invoice))
            else
                Management.AddInvoice(Replacement, Invoice);
        until Source.Next() = 0;
        Management.CopiarSeleccion(Header,Replacement);
        Management.Recalculate(Replacement);
        Replacement."Replaces No." := Header."No.";
        Replacement.Modify(true);
        exit(Replacement."No.");
    end;
}

page 71101 "HN Cancel Retention"
{
    PageType = StandardDialog;
    Caption = 'Anular comprobante de retención';
    layout
    {
        area(Content)
        {
            group(Details)
            {
                Caption = 'Detalle';
                field(Reason; Reason) { ApplicationArea = All; Caption = 'Motivo'; ShowMandatory = true; }
                field(CancellationDate; CancellationDate) { ApplicationArea = All; Caption = 'Fecha contable'; }
                field(TaxReference; TaxReference)
                {
                    ApplicationArea = All; Caption = 'Referencia de revisión/rectificación fiscal';
                    ToolTip = 'Si ya se declaró o enteró al SAR, indique la referencia del tratamiento fiscal realizado. Esta acción no modifica declaraciones del SAR.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CancellationDate := WorkDate();
    end;
    procedure GetParameters(var ResultReason: Text[250]; var ResultDate: Date; var ResultReference: Text[100])
    begin
        ResultReason := Reason;
        ResultDate := CancellationDate;
        ResultReference := TaxReference;
    end;
    var
        Reason: Text[250];
        CancellationDate: Date;
        TaxReference: Text[100];
}
