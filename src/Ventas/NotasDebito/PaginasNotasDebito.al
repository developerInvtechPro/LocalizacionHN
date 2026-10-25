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

page 50106 "HN Debit Notes"
{
    PageType = List;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "HN Debit Note" = const(true));
    Caption = 'Notas de débito HN';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "HN Debit Note Card";
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                Editable = false;
                field(No; Rec."No.") { ApplicationArea = All; }
                field(Customer; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Original; Rec."HN Original Invoice No.") { ApplicationArea = All; }
                field(Amount; Rec."Amount Including VAT") { ApplicationArea = All; }
                field(Currency; Rec."Currency Code") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ConfigureCAI)
            {
                Caption = 'Configurar CAI'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Authorizations";
                RunPageView = where("Document Type" = const("Debit Note"));
            }

            action(NewDebit)
            {
                Caption = 'Nueva nota de débito'; ApplicationArea = All; Image = NewDocument;
                RunObject = page "HN Debit Note Card";
                RunPageMode = Create;
            }
            action(History) { Caption = 'Notas de débito registradas'; ApplicationArea = All; Image = History; RunObject = page "HN Posted Debit Notes"; }
            action(Setup) { Caption = 'Configuración general'; ApplicationArea = All; Image = Setup; RunObject = page "HN Localization Setup"; }
        }
    }
    trigger OnOpenPage()
    var
        Setup: Record "HN Localization Setup";
        Management: Codeunit "HN Setup Management";
    begin
        Management.GetSetup(Setup);
    end;
}
page 50107 "HN Debit Note Card"
{
    PageType = Document;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "HN Debit Note" = const(true));
    Caption = 'Nota de débito HN';
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(No; Rec."No.") { ApplicationArea = All; Editable = false; }
                field(Customer; Rec."Sell-to Customer No.") { ApplicationArea = All; }
                field(Name; Rec."Sell-to Customer Name") { ApplicationArea = All; Editable = false; }
                field(RTN; Rec."VAT Registration No.") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(DocumentDate; Rec."Document Date") { ApplicationArea = All; }
                field(DueDate; Rec."Due Date") { ApplicationArea = All; }
                field(Currency; Rec."Currency Code") { ApplicationArea = All; }
                field(PricesVAT; Rec."Prices Including VAT") { ApplicationArea = All; }
                field(Original; Rec."HN Original Invoice No.") { ApplicationArea = All; Editable = false; }
                field(OriginalDate; Rec."HN Original Invoice Date") { ApplicationArea = All; Editable = false; }
                field(SourceFiscal; Rec."HN Source Fiscal No.") { ApplicationArea = All; ToolTip = 'Número fiscal de la factura origen; complételo para facturas históricas que no tengan datos fiscales de este módulo.'; }
                field(Reason; Rec."HN Debit Reason") { ApplicationArea = All; }
            }
            part(Lines; "Sales Invoice Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ConfigureCAI)
            {
                Caption = 'Configurar CAI'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Authorizations";
                RunPageView = where("Document Type" = const("Debit Note"));
            }

            action(FiscalData)
            {
                Caption = 'Datos fiscales'; ApplicationArea = All; Image = Document;
                RunObject = page "HN Debit Fiscal Data";
                RunPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
            }
            action(Setup)
            {
                Caption = 'Configuración general'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Localization Setup";
            }
            action(SelectOriginal)
            {
                Caption = 'Seleccionar factura origen'; ApplicationArea = All; Image = GetSourceDoc;
                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Management.SelectOriginal(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Preview)
            {
                Caption = 'Vista previa de registro'; ApplicationArea = All; Image = ViewPostedOrder;
                trigger OnAction()
                var
                    PostYesNo: Codeunit "Sales-Post (Yes/No)";
                begin
                    CurrPage.SaveRecord();
                    PostYesNo.Preview(Rec);
                end;
            }
            action(PostPrint)
            {
                Caption = 'Registrar e imprimir'; ApplicationArea = All; Image = PostPrint;
                trigger OnAction()
                begin
                    PostDocument(true);
                end;
            }
            action(Post)
            {
                Caption = 'Registrar'; ApplicationArea = All; Image = Post;
                trigger OnAction()
                begin
                    PostDocument(false);
                end;
            }
        }
    }
    local procedure PostDocument(PrintAfter: Boolean)
    var
        Invoice: Record "Sales Invoice Header";
        PostedNo: Code[20];
    begin
        CurrPage.SaveRecord();
        Management.ValidateDocument(Rec);
        if not Confirm('¿Registrar la nota de débito?', false) then exit;
        PostedNo := Management.Post(Rec);
        Commit();
        if PrintAfter then begin
            Invoice.Get(PostedNo);
            Invoice.SetRecFilter();
            Report.RunModal(Report::"HN Debit Note Certificate", true, false, Invoice);
        end;
        CurrPage.Close();
    end;

    trigger OnOpenPage()
    var
        SetupManagement: Codeunit "HN Setup Management";
    begin
        if not SetupManagement.EnsureDebitConfiguration() then
            CurrPage.Close();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := Rec."Document Type"::Invoice;
        Rec."HN Debit Note" := true;
    end;
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Setup: Record "HN Localization Setup";
        Series: Codeunit "No. Series";
        SetupManagement: Codeunit "HN Setup Management";
    begin
        SetupManagement.CheckDebitConfiguration(Setup);
        Rec."No." := Series.GetNextNo(Setup."Debit Note Nos.", WorkDate());
        Rec."No. Series" := Setup."Debit Note Nos.";
        exit(true);
    end;
    var
        Management: Codeunit "HN Debit Note Management";
}
page 50108 "HN Posted Debit Notes"
{
    PageType = List;
    SourceTable = "Sales Invoice Header";
    SourceTableView = where("HN Debit Note" = const(true));
    Caption = 'Notas de débito registradas HN';
    ApplicationArea = All;
    UsageCategory = History;
    CardPageId = "HN Posted Debit Note";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field(No; Rec."No.") { ApplicationArea = All; }
                field(FiscalNo; Rec."HN Fiscal No.") { ApplicationArea = All; }
                field(Customer; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Original; Rec."HN Original Invoice No.") { ApplicationArea = All; }
                field(Amount; Rec."Amount Including VAT") { ApplicationArea = All; }
                field(NewModule; Rec."HN Debit Note") { ApplicationArea = All; Caption = 'Registrada por V2'; }
            }
        }
    }
}
page 50109 "HN Posted Debit Note"
{
    PageType = Document;
    SourceTable = "Sales Invoice Header";
    SourceTableView = where("HN Debit Note" = const(true));
    Caption = 'Nota de débito registrada HN';
    Editable = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(No; Rec."No.") { ApplicationArea = All; }
                field(FiscalNo; Rec."HN Fiscal No.") { ApplicationArea = All; }
                field(Customer; Rec."Sell-to Customer Name") { ApplicationArea = All; }
                field(RTN; Rec."VAT Registration No.") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Original; Rec."HN Original Invoice No.") { ApplicationArea = All; }
                field(SourceFiscal; Rec."HN Source Fiscal No.") { ApplicationArea = All; ToolTip = 'Número fiscal de la factura origen; complételo para facturas históricas que no tengan datos fiscales de este módulo.'; }
                field(SourceCAI; Rec."HN Source CAI") { ApplicationArea = All; ToolTip = 'CAI de la factura origen.'; }
                field(Reason; Rec."HN Debit Reason") { ApplicationArea = All; }
                field(CAI; Rec."HN CAI") { ApplicationArea = All; }
                field(FirstNo; Rec."HN CAI Starting No.") { ApplicationArea = All; }
                field(LastNo; Rec."HN CAI Ending No.") { ApplicationArea = All; }
                field(Expiration; Rec."HN CAI Valid Until") { ApplicationArea = All; }
            }
            part(Lines; "Posted Sales Invoice Subform") { ApplicationArea = All; SubPageLink = "Document No." = field("No."); }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Print)
            {
                Caption = 'Imprimir nota de débito'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Header: Record "Sales Invoice Header";
                begin
                    Header := Rec;
                    Header.SetRecFilter();
                    Report.RunModal(Report::"HN Debit Note Certificate", true, false, Header);
                end;
            }
            action(Navigate)
            {
                Caption = 'Buscar movimientos'; ApplicationArea = All; Image = Navigate;
                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
    }
}
