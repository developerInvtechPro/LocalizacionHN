namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Foundation.Company;
using Microsoft.Finance.VAT.Ledger;

report 71110 "HN Factura Venta"
{
    Caption = 'Factura de venta HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Sales Invoice Header")
        {
            DataItemTableView = where("HN Emitir Documento Fiscal" = const(true), "HN Debit Note" = const(false));
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "HN Fiscal No.") { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Bill-to Name") { }
            column(Party_RTN; "HN RTN Destinatario") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; "HN CAI") { }
            column(CAI_Range; "HN CAI Starting No." + ' / ' + "HN CAI Ending No.") { }
            column(CAI_Expiration; Format("HN CAI Valid Until")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; "HN Issuer Name") { }
            column(Issuer_RTN; "HN Issuer RTN") { }
            column(Issuer_Address; "HN Issuer Address") { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Bill-to Address" + ' ' + "Bill-to Address 2" + ' ' + "Bill-to City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Unit Price") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                TestField("HN Emitir Documento Fiscal", true);
                TestField("HN Debit Note", false);
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/FacturaVenta.rdlc'; Caption = 'Factura de venta HN'; } }
    trigger OnPreReport()
    begin
    end;
    var
        Empresa: Record "Company Information";
}

report 71111 "HN Nota Credito Venta"
{
    Caption = 'Nota de crédito de venta HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Sales Cr.Memo Header")
        {
            DataItemTableView = where("HN Emitir Documento Fiscal" = const(true));
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "HN Fiscal No.") { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Bill-to Name") { }
            column(Party_RTN; "HN RTN Destinatario") { }
            column(Source_No; "HN Source Fiscal No.") { }
            column(Source_CAI; "HN Source CAI") { }
            column(Source_Date; Format("HN Original Invoice Date")) { }
            column(Reason; "HN Motivo") { }
            column(CAI_Value; "HN CAI") { }
            column(CAI_Range; "HN CAI Starting No." + ' / ' + "HN CAI Ending No.") { }
            column(CAI_Expiration; Format("HN CAI Valid Until")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; "HN Issuer Name") { }
            column(Issuer_RTN; "HN Issuer RTN") { }
            column(Issuer_Address; "HN Issuer Address") { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Bill-to Address" + ' ' + "Bill-to Address 2" + ' ' + "Bill-to City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Unit Price") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                TestField("HN Emitir Documento Fiscal", true);
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/NotaCreditoVenta.rdlc'; Caption = 'Nota de crédito de venta HN'; } }
    trigger OnPreReport()
    begin
    end;
    var
        Empresa: Record "Company Information";
}

report 71112 "HN Comprobante Compra"
{
    Caption = 'Comprobante interno de factura de compra HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Purch. Inv. Header")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "Vendor Invoice No.") { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Buy-from Vendor Name") { }
            column(Party_RTN; "VAT Registration No.") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; "HN Vendor CAI") { }
            column(CAI_Range; "HN Inicio CAI Proveedor" + ' / ' + "HN Fin CAI Proveedor") { }
            column(CAI_Expiration; Format("HN Vence CAI Proveedor")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address + ' ' + Empresa.City) { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Buy-from Address" + ' ' + "Buy-from Address 2" + ' ' + "Buy-from City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Purch. Inv. Line")
            {
                DataItemLink = "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Direct Unit Cost") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/FacturaCompra.rdlc'; Caption = 'Comprobante interno de factura de compra HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71113 "HN Comprobante Abono Compra"
{
    Caption = 'Comprobante interno de abono de compra HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Purch. Cr. Memo Hdr.")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "Vendor Cr. Memo No.") { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Buy-from Vendor Name") { }
            column(Party_RTN; "VAT Registration No.") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; "HN Vendor CAI") { }
            column(CAI_Range; "HN Inicio CAI Proveedor" + ' / ' + "HN Fin CAI Proveedor") { }
            column(CAI_Expiration; Format("HN Vence CAI Proveedor")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address + ' ' + Empresa.City) { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Buy-from Address" + ' ' + "Buy-from Address 2" + ' ' + "Buy-from City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Purch. Cr. Memo Line")
            {
                DataItemLink = "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Direct Unit Cost") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/AbonoCompra.rdlc'; Caption = 'Comprobante interno de abono de compra HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71114 "HN Borrador Venta"
{
    Caption = 'Borrador de venta HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Sales Header")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; 'SIN EMITIR') { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Bill-to Name") { }
            column(Party_RTN; "VAT Registration No.") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; '') { }
            column(CAI_Range; '') { }
            column(CAI_Expiration; '') { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address + ' ' + Empresa.City) { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Bill-to Address" + ' ' + "Bill-to Address 2" + ' ' + "Bill-to City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Unit Price") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/BorradorVenta.rdlc'; Caption = 'Borrador de venta HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71115 "HN Borrador Compra"
{
    Caption = 'Borrador de compra HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Purchase Header")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; 'SIN EMITIR') { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Buy-from Vendor Name") { }
            column(Party_RTN; "VAT Registration No.") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; '') { }
            column(CAI_Range; '') { }
            column(CAI_Expiration; '') { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address + ' ' + Empresa.City) { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Buy-from Address" + ' ' + "Buy-from Address 2" + ' ' + "Buy-from City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Linea; "Purchase Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Direct Unit Cost") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/BorradorCompra.rdlc'; Caption = 'Borrador de compra HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71116 "HN Borrador Retencion"
{
    Caption = 'Borrador de retención HN';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = Certificate;
    dataset
    {
        dataitem(Header; "HN Retention Header")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; 'SIN EMITIR') { }
            column(Issue_Date; Format("Posting Date")) { }
            column(Party_Name; "Vendor Name") { }
            column(Party_RTN; "Vendor RTN") { }
            column(Source_No; "Vendor Invoice No.") { }
            column(Source_CAI; "Invoice CAI") { }
            column(CAI_Value; CAI) { }
            column(CAI_Range; "CAI Starting No." + ' / ' + "CAI Ending No.") { }
            column(CAI_Expiration; Format("CAI Valid Until")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address) { }
            column(Total_Amount; Amount) { }
            column(Cancellation_Label; CancellationLabel) { }
            column(Cancellation_Reason; "Cancellation Reason") { }
            column(Cancellation_Date; Format("Cancellation Date")) { }
            dataitem(Line; "HN Retention Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Line_Invoice; "Vendor Invoice No.") { }
                column(Line_Invoice_CAI; "Invoice CAI") { }
                column(Line_Invoice_Date; Format("Invoice Date")) { }
                column(Line_Description; Description) { }
                column(Line_Base; Base) { }
                column(Line_Rate; Percentage) { }
                column(Line_Amount; Amount) { }
            }
            trigger OnAfterGetRecord()
            begin
                TestField(Status, Status::Draft);
                CancellationLabel := 'BORRADOR';
                if Status = Status::Cancelled then
                    CancellationLabel := 'ANULADA';
                CalcFields(Amount);
            end;
        }
    }
    rendering
    {
        layout(Certificate) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/BorradorRetencion.rdlc'; Caption = 'Borrador de retención HN'; }
    }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
        CancellationLabel: Text[20];
}
report 71117 "HN Movimientos Contables"
{
    Caption = 'Movimientos contables HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "G/L Entry")
        {
            RequestFilterFields = "Posting Date", "Document No.", "G/L Account No.";
            column(Titulo_Informe; 'Movimientos contables HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "G/L Account No.") { }
            column(Descripcion; "G/L Account No." + ' | ' + Description + ' | Transacción: ' + Format("Transaction No.")) { }
            column(Debe; "Debit Amount") { }
            column(Haber; "Credit Amount") { }
            column(Saldo; Amount) { }
            column(Moneda; 'ML') { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/MovimientosContables.rdlc'; Caption = 'Movimientos contables HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71118 "HN Movimientos Proveedor"
{
    Caption = 'Movimientos de proveedores HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "Vendor Ledger Entry")
        {
            RequestFilterFields = "Vendor No.", "Posting Date", "Document No.";
            column(Titulo_Informe; 'Movimientos de proveedores HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "Vendor No.") { }
            column(Descripcion; "Vendor No." + ' | ' + Description + ' | Documento externo: ' + "External Document No.") { }
            column(Debe; "Debit Amount") { }
            column(Haber; "Credit Amount") { }
            column(Saldo; "Remaining Amount") { }
            column(Moneda; "Currency Code") { }
            trigger OnAfterGetRecord()
            begin
                CalcFields("Debit Amount", "Credit Amount", "Remaining Amount");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/MovimientosProveedores.rdlc'; Caption = 'Movimientos de proveedores HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71119 "HN Movimientos Cliente"
{
    Caption = 'Movimientos de clientes HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "Cust. Ledger Entry")
        {
            RequestFilterFields = "Customer No.", "Posting Date", "Document No.";
            column(Titulo_Informe; 'Movimientos de clientes HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "Customer No.") { }
            column(Descripcion; "Customer No." + ' | ' + Description + ' | Documento externo: ' + "External Document No.") { }
            column(Debe; "Debit Amount") { }
            column(Haber; "Credit Amount") { }
            column(Saldo; "Remaining Amount") { }
            column(Moneda; "Currency Code") { }
            trigger OnAfterGetRecord()
            begin
                CalcFields("Debit Amount", "Credit Amount", "Remaining Amount");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/MovimientosClientes.rdlc'; Caption = 'Movimientos de clientes HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71120 "HN Inf. Movimientos Fiscales"
{
    Caption = 'Movimientos fiscales y CAI HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "HN Movimiento Fiscal")
        {
            RequestFilterFields = "Es compra", "Fecha emision", "Numero fiscal", "No. tercero";
            column(Titulo_Informe; 'Movimientos fiscales y CAI HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "No. movimiento") { }
            column(Fecha; Format("Fecha emision")) { }
            column(Documento; "Numero fiscal") { }
            column(Tercero; "No. tercero") { }
            column(Descripcion; Format("Tipo documento") + ' | ' + "Nombre tercero" + ' | CAI: ' + CAI + ' | BC: ' + "No. documento" + ' | Rango: ' + "Rango inicial" + ' / ' + "Rango final" + ' | Límite: ' + Format(Vencimiento)) { }
            column(Debe; 0) { }
            column(Haber; 0) { }
            column(Saldo; 0) { }
            column(Moneda; '') { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/MovimientosFiscales.rdlc'; Caption = 'Movimientos fiscales y CAI HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71121 "HN Listado CAI Ventas"
{
    Caption = 'Autorizaciones CAI de ventas HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "HN CAI Authorization")
        {
            RequestFilterFields = "Document Type", Code, Enabled;
            column(Titulo_Informe; 'Autorizaciones CAI de ventas HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; 0) { }
            column(Fecha; Format("Valid Until")) { }
            column(Documento; Code) { }
            column(Tercero; '') { }
            column(Descripcion; Format("Document Type") + ' | CAI: ' + CAI + ' | Rango: ' + "Starting No." + ' / ' + "Ending No." + ' | Próximo: ' + "Next No." + ' | Habilitado: ' + Format(Enabled)) { }
            column(Debe; 0) { }
            column(Haber; 0) { }
            column(Saldo; 0) { }
            column(Moneda; '') { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/AutorizacionesVentas.rdlc'; Caption = 'Autorizaciones CAI de ventas HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71122 "HN Listado CAI Proveedores"
{
    Caption = 'Autorizaciones CAI de proveedores HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "HN CAI Proveedor")
        {
            RequestFilterFields = "No. proveedor", Codigo, Habilitado;
            column(Titulo_Informe; 'Autorizaciones CAI de proveedores HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; 0) { }
            column(Fecha; Format("Fecha limite")) { }
            column(Documento; Codigo) { }
            column(Tercero; "No. proveedor") { }
            column(Descripcion; "No. proveedor" + ' | ' + "Nombre proveedor" + ' | CAI: ' + CAI + ' | Rango: ' + "Numero inicial" + ' / ' + "Numero final" + ' | Habilitado: ' + Format(Habilitado)) { }
            column(Debe; 0) { }
            column(Haber; 0) { }
            column(Saldo; 0) { }
            column(Moneda; '') { }
            trigger OnAfterGetRecord()
            begin
                CalcFields("Nombre proveedor");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/AutorizacionesProveedores.rdlc'; Caption = 'Autorizaciones CAI de proveedores HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71123 "HN Det. Aplicacion Proveedor"
{
    Caption = 'Aplicaciones y desliquidaciones de proveedores HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "Detailed Vendor Ledg. Entry")
        {
            RequestFilterFields = "Vendor No.", "Posting Date", "Document No.", "Vendor Ledger Entry No.";
            column(Titulo_Informe; 'Aplicaciones y desliquidaciones de proveedores HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "Vendor No.") { }
            column(Descripcion; "Vendor No." + ' | ' + Format("Entry Type") + ' | Movimiento proveedor: ' + Format("Vendor Ledger Entry No.") + ' | Desliquidado: ' + Format(Unapplied)) { }
            column(Debe; "Debit Amount") { }
            column(Haber; "Credit Amount") { }
            column(Saldo; Amount) { }
            column(Moneda; "Currency Code") { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/AplicacionesProveedores.rdlc'; Caption = 'Aplicaciones y desliquidaciones de proveedores HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71124 "HN Det. Aplicacion Cliente"
{
    Caption = 'Aplicaciones y desliquidaciones de clientes HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "Detailed Cust. Ledg. Entry")
        {
            RequestFilterFields = "Customer No.", "Posting Date", "Document No.", "Cust. Ledger Entry No.";
            column(Titulo_Informe; 'Aplicaciones y desliquidaciones de clientes HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "Customer No.") { }
            column(Descripcion; "Customer No." + ' | ' + Format("Entry Type") + ' | Movimiento cliente: ' + Format("Cust. Ledger Entry No.") + ' | Desliquidado: ' + Format(Unapplied)) { }
            column(Debe; "Debit Amount") { }
            column(Haber; "Credit Amount") { }
            column(Saldo; Amount) { }
            column(Moneda; "Currency Code") { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/AplicacionesClientes.rdlc'; Caption = 'Aplicaciones y desliquidaciones de clientes HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}

report 71125 "HN Movimientos ISV"
{
    Caption = 'Movimientos de impuestos ISV HN'; ApplicationArea = All; UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Movimiento; "VAT Entry")
        {
            RequestFilterFields = "Posting Date", "Document No.", Type, "VAT Prod. Posting Group";
            column(Titulo_Informe; 'Movimientos de impuestos ISV HN') { }
            column(Empresa; Empresa.Name) { }
            column(Numero_Movimiento; "Entry No.") { }
            column(Fecha; Format("Posting Date")) { }
            column(Documento; "Document No.") { }
            column(Tercero; "Bill-to/Pay-to No.") { }
            column(Descripcion; "Bill-to/Pay-to No." + ' | ' + Format(Type) + ' | Base: ' + Format(Base) + ' | Grupo: ' + "VAT Prod. Posting Group") { }
            column(Debe; Base) { }
            column(Haber; Amount) { }
            column(Saldo; 0) { }
            column(Moneda; 'ML') { }
            trigger OnAfterGetRecord()
            begin
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/MovimientosISV.rdlc'; Caption = 'Movimientos de impuestos ISV HN'; } }
    trigger OnPreReport()
    begin
        Empresa.Get();
    end;
    var
        Empresa: Record "Company Information";
}
