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

page 50102 "HN Retentions"
{
    PageType = List;
    SourceTable = "HN Retention Header";
    SourceTableView = where(Status = const(Draft));
    Caption = 'Retenciones HN';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "HN Retention Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field(No; Rec."No.") { ApplicationArea = All; }
                field(Vendor; Rec."Vendor Name") { ApplicationArea = All; }
                field(InvoiceCount; Rec."Invoice Count") { ApplicationArea = All; }
                field(Invoice; Rec."Invoice No.") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Currency; Rec."Currency Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
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
                RunPageView = where("Document Type" = const(Retention));
            }

            action(Generate)
            {
                Caption = 'Generar desde factura registrada'; ApplicationArea = All; Image = CreateDocument;
                trigger OnAction()
                var
                    Invoice: Record "Purch. Inv. Header";
                    Header: Record "HN Retention Header";
                    Invoices: Page "Posted Purchase Invoices";
                    Management: Codeunit "HN Retention Management";
                begin
                    Invoices.LookupMode(true);
                    if Invoices.RunModal() = Action::LookupOK then begin
                        Invoices.SetSelectionFilter(Invoice);
                        if Invoice.FindSet() then
                            repeat
                                if Header."No." = '' then
                                    Header.Get(Management.CreateFromInvoice(Invoice))
                                else
                                    Management.AddInvoice(Header, Invoice);
                            until Invoice.Next() = 0;
                        Page.Run(Page::"HN Retention Card", Header);
                    end;
                end;
            }
            action(History) { Caption = 'Retenciones registradas'; ApplicationArea = All; Image = History; RunObject = page "HN Posted Retentions"; }
            action(Rules) { Caption = 'Configurar retenciones'; ApplicationArea = All; Image = Setup; RunObject = page "HN Retention Rules"; }
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
page 50103 "HN Retention Card"
{
    PageType = Document;
    SourceTable = "HN Retention Header";
    Caption = 'Comprobante de retención HN';
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = IsDraft;
                field(No; Rec."No.") { ApplicationArea = All; Editable = false; }
                field(Vendor; Rec."Vendor No.") { ApplicationArea = All; }
                field(Name; Rec."Vendor Name") { ApplicationArea = All; }
                field(RTN; RTNMostrar)
                {
                    Caption = 'RTN proveedor'; ApplicationArea = All; Lookup = true;
                    ToolTip = 'Seleccione el RTN propio de V2, el anterior disponible o el registro estándar. Si hay valores distintos, elija el que corresponde al comprobante.';
                    trigger OnLookup(var Text: Text): Boolean
                    var GestionRTN: Codeunit "HN Gestion RTN Proveedor";
                    begin
                        CurrPage.SaveRecord(); Commit();
                        if not GestionRTN.Seleccionar(Rec) then exit(false);
                        RTNMostrar := Rec.ObtenerRTNProveedor(); Text := RTNMostrar;
                        CurrPage.Update(false); exit(true);
                    end;
                    trigger OnValidate()
                    begin Rec.Validate("RTN proveedor completo",RTNMostrar); end;
                }
                field(InvoiceCount; Rec."Invoice Count") { ApplicationArea = All; }
                field(Invoice; Rec."Invoice No.") { ApplicationArea = All; }
                field(VendorInvoice; Rec."Vendor Invoice No.") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Currency; Rec."Currency Code") { ApplicationArea = All; }
                field(CAI; Rec."CAI Code") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
            }
            part(Invoices; "HN Retention Invoices") { ApplicationArea = All; SubPageLink = "Document No." = field("No."); }
            part(Lines; "HN Retention Lines") { ApplicationArea = All; SubPageLink = "Document No." = field("No."); }
            group(Fiscal)
            {
                Caption = 'Documento emitido';
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(FiscalNo; Rec."Fiscal No.") { ApplicationArea = All; }
                field(State; Rec.Status) { ApplicationArea = All; }
                field(IssuedCAI; Rec.CAI) { ApplicationArea = All; }
                field(FirstNo; Rec."CAI Starting No.") { ApplicationArea = All; }
                field(LastNo; Rec."CAI Ending No.") { ApplicationArea = All; }
                field(Expiration; Rec."CAI Valid Until") { ApplicationArea = All; }
                field(Registered; Rec."Registered At") { ApplicationArea = All; }
                field(Replaces; Rec."Replaces No.") { ApplicationArea = All; }
                field(Reported; Rec."Tax Reported") { ApplicationArea = All; }
                field(CancelledAt; Rec."Cancelled At") { ApplicationArea = All; }
                field(CancelledBy; Rec."Cancelled By") { ApplicationArea = All; }
                field(CancelReason; Rec."Cancellation Reason") { ApplicationArea = All; }
                field(CancelDate; Rec."Cancellation Date") { ApplicationArea = All; }
                field(TaxCorrection; Rec."Tax Correction Ref.") { ApplicationArea = All; }
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
                RunPageView = where("Document Type" = const(Retention));
            }

            action(SeleccionarRetencionesRegistradas)
            {
                Caption = 'Seleccionar retenciones'; ApplicationArea = All; Image = SelectEntries; Enabled = IsDraft;
                trigger OnAction()
                var Gestion: Codeunit "HN Retention Management"; Seleccion: Record "HN Seleccion Ret. Factura"; Pagina: Page "HN Conceptos Factura Ret.";
                begin
                    CurrPage.SaveRecord(); Gestion.PrepararSeleccion(Rec); Commit();
                    Seleccion.SetRange(Documento,Rec."No."); Pagina.SetTableView(Seleccion); Pagina.RunModal();
                    Rec.Get(Rec."No."); Gestion.Recalculate(Rec); CurrPage.Update(false);
                end;
            }
            action(AddInvoice)
            {
                Caption = 'Agregar facturas'; ApplicationArea = All; Image = NewDocument; Enabled = IsDraft;
                trigger OnAction()
                var
                    Invoice: Record "Purch. Inv. Header";
                    Selection: Page "Posted Purchase Invoices";
                begin
                    CurrPage.SaveRecord();
                    Invoice.SetRange("Pay-to Vendor No.", Rec."Vendor No.");
                    Invoice.SetRange("Currency Code", Rec."Currency Code");
                    Selection.SetTableView(Invoice);
                    Selection.LookupMode(true);
                    if Selection.RunModal() <> Action::LookupOK then exit;
                    Selection.SetSelectionFilter(Invoice);
                    if Invoice.FindSet() then
                        repeat
                            Management.AddInvoice(Rec, Invoice);
                        until Invoice.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(CancelRetention)
            {
                Caption = 'Anular'; ApplicationArea = All; Image = Cancel; Enabled = IsPosted;
                trigger OnAction()
                var
                    Dialog: Page "HN Cancel Retention";
                    Cancellation: Codeunit "HN Retention Cancellation";
                    Reason: Text[250];
                    Date: Date;
                    Reference: Text[100];
                begin
                    if Dialog.RunModal() <> Action::OK then exit;
                    Dialog.GetParameters(Reason, Date, Reference);
                    Cancellation.Cancel(Rec, Reason, Date, Reference);
                    CurrPage.Update(false);
                end;
            }
            action(ReplaceRetention)
            {
                Caption = 'Crear sustituto'; ApplicationArea = All; Image = CopyDocument; Enabled = IsCancelled;
                trigger OnAction()
                var
                    Cancellation: Codeunit "HN Retention Cancellation";
                    Replacement: Record "HN Retention Header";
                begin
                    Replacement.Get(Cancellation.CreateReplacement(Rec));
                    Page.Run(Page::"HN Retention Card", Replacement);
                end;
            }
            action(MarkTaxReported)
            {
                Caption = 'Marcar declarada o enterada al SAR'; ApplicationArea = All; Image = Check; Enabled = IsPosted;
                trigger OnAction()
                var
                    Cancellation: Codeunit "HN Retention Cancellation";
                begin
                    if not Confirm('¿Confirma que esta retención ya fue declarada o enterada al SAR?', false) then exit;
                    Cancellation.MarkReported(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Recalculate)
            {
                Caption = 'Recalcular'; ApplicationArea = All; Image = Calculate; Enabled = IsDraft;
                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Management.Recalculate(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(PreviewPosting)
            {
                Caption = 'Vista previa de registro'; ApplicationArea = All; Image = ViewPostedOrder; Enabled = IsDraft;
                trigger OnAction()
                var
                    Preview: Codeunit "HN Retention Preview";
                begin
                    CurrPage.SaveRecord();
                    Commit();
                    Preview.Preview(Rec);
                end;
            }
            action(LedgerEntries)
            {
                Caption = 'Movimientos del proveedor'; ApplicationArea = All; Image = VendorLedger;
                RunObject = page "Vendor Ledger Entries";
                RunPageLink = "Document No." = field("No."), "Vendor No." = field("Vendor No.");
            }
            action(Post)
            {
                Caption = 'Registrar'; ApplicationArea = All; Image = Post; Enabled = IsDraft;
                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    if not Confirm('¿Registrar el comprobante y aplicar la retención a las facturas incluidas?', false) then exit;
                    Management.Post(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Print)
            {
                Caption = 'Imprimir borrador o comprobante'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Header: Record "HN Retention Header";
                begin
                    Header := Rec;
                    Header.SetRecFilter();
                    if Header.Status = Header.Status::Draft then
                        Report.RunModal(Report::"HN Borrador Retencion", true, false, Header)
                    else
                        Report.RunModal(Report::"HN Retention Certificate", true, false, Header);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        RTNMostrar := Rec.ObtenerRTNProveedor();
        IsDraft := Rec.Status = Rec.Status::Draft;
        IsPosted := Rec.Status = Rec.Status::Posted;
        IsCancelled := Rec.Status = Rec.Status::Cancelled;
    end;
    var
        RTNMostrar: Text[50];
        Management: Codeunit "HN Retention Management";
        IsDraft: Boolean;
        IsPosted: Boolean;
        IsCancelled: Boolean;
}
page 50104 "HN Retention Lines"
{
    PageType = ListPart;
    SourceTable = "HN Retention Line";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(InvoiceNo; Rec."Invoice No.") { ApplicationArea = All; }
                field(VendorInvoiceNo; Rec."Vendor Invoice No.") { ApplicationArea = All; }
                field(InvoiceLine; Rec."Invoice Line No.") { ApplicationArea = All; }
                field(Code; Rec."Retention Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Base; Rec.Base) { ApplicationArea = All; }
                field(Percentage; Rec.Percentage) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Account; Rec."G/L Account No.") { ApplicationArea = All; }
            }
        }
    }
}
page 50105 "HN Posted Retentions"
{
    PageType = List;
    SourceTable = "HN Retention Header";
    SourceTableView = where(Status = filter(Posted | Cancelled));
    Caption = 'Retenciones registradas HN';
    ApplicationArea = All;
    UsageCategory = History;
    CardPageId = "HN Retention Card";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field(No; Rec."No.") { ApplicationArea = All; }
                field(FiscalNo; Rec."Fiscal No.") { ApplicationArea = All; }
                field(State; Rec.Status) { ApplicationArea = All; }
                field(Vendor; Rec."Vendor Name") { ApplicationArea = All; }
                field(Invoice; Rec."Invoice No.") { ApplicationArea = All; }
                field(Date; Rec."Posting Date") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Currency; Rec."Currency Code") { ApplicationArea = All; }
            }
        }
    }
}
