namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Foundation.Company;
report 71126 "HN Boleta Compra"
{
    Caption = 'BOLETA DE COMPRA'; ApplicationArea = All; UsageCategory = None;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Purch. Inv. Header")
        {
            DataItemTableView = where("HN Boleta Compra" = const(true));
            RequestFilterFields = "No.";
            column(Print_Date; FechaImpresionFormato) { }
            column(Logo_Base64; LogoFormato) { }
            column(Logo_MIME; TipoLogoFormato) { }
            column(Issuer_Contact; ContactoFormato) { }
            column(Currency_Label; DatosFormato.RotuloMoneda('HNL')) { }
            column(Amount_In_Words; DatosFormato.Letras("Amount Including VAT",'HNL')) { }
            column(Due_Date; Format("Due Date")) { }
            column(Prices_Include_Tax; "Prices Including VAT") { }
            column(Document_No; "No.") { }
            column(Fiscal_No; "HN Numero Boleta") { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Buy-from Vendor Name") { }
            column(Party_RTN; "HN Identidad Boleta") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; "HN CAI Boleta") { }
            column(CAI_Range; "HN Inicio Boleta" + ' / ' + "HN Fin Boleta") { }
            column(CAI_Expiration; Format("HN Vence Boleta")) { }
            column(Currency_Code; 'HNL') { }
            column(Issuer_Name; "HN Nombre Emisor Boleta") { }
            column(Issuer_RTN; "HN RTN Emisor Boleta") { }
            column(Issuer_Address; "HN Direccion Emisor Boleta") { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Buy-from Address" + ' ' + "Buy-from Address 2" + ' ' + "Buy-from City") { }
            column(Total_Amount; "Amount Including VAT") { }
            column(Party_Phone; "HN Telefono Boleta") { }
            column(Issuer_Phone; "HN Telefono Emisor Boleta") { }
            column(Issuer_Email; "HN Correo Emisor Boleta") { }
            column(Amount_Words; Letras.Convertir("Amount Including VAT")) { }
            column(Exempt_Order; "HN Orden Exenta Boleta") { }
            column(Exempt_Register; "HN Registro Exento Boleta") { }
            column(SAG_Register; "HN Registro SAG Boleta") { }
            dataitem(Linea; "Purch. Inv. Line")
            {
                DataItemLink = "Document No." = field("No.");
            column(Line_Code; "No.") { }
                column(Line_Unit; "Unit of Measure Code") { }
                column(Line_Discount; "Line Discount Amount" + "Inv. Discount Amount") { }
                column(Line_Tax; "Amount Including VAT" - Amount) { }
                column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Direct Unit Cost") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                TestField("HN Boleta Compra", true);
                TestField("HN Numero Boleta");
                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/BoletaCompra.rdlc'; Caption = 'BOLETA DE COMPRA'; } }
    trigger OnPreReport()
    begin
        DatosFormato.ComprobarFormatoActivo(71126);
        FechaImpresionFormato := Format(CurrentDateTime());
        DatosFormato.CargarEmpresa(LogoFormato,TipoLogoFormato,ContactoFormato);
        Empresa.Get();
    end;
    var
        FechaImpresionFormato: Text;
        DatosFormato: Codeunit "HN Datos Formatos";
        LogoFormato: Text;
        TipoLogoFormato: Text;
        ContactoFormato: Text;
        Empresa: Record "Company Information";
        Letras: Codeunit "HN Importe En Letras";
}
report 71127 "HN Borrador Boleta"
{
    Caption = 'BORRADOR DE BOLETA — SIN VALIDEZ FISCAL'; ApplicationArea = All; UsageCategory = None;
    DefaultRenderingLayout = Formato;
    dataset
    {
        dataitem(Cabecera; "Purchase Header")
        {
            DataItemTableView = where("HN Boleta Compra" = const(true));
            RequestFilterFields = "Document Type", "No.";
            column(Print_Date; FechaImpresionFormato) { }
            column(Logo_Base64; LogoFormato) { }
            column(Logo_MIME; TipoLogoFormato) { }
            column(Issuer_Contact; ContactoFormato) { }
            column(Currency_Label; DatosFormato.RotuloMoneda('HNL')) { }
            column(Amount_In_Words; DatosFormato.Letras("Amount Including VAT",'HNL')) { }
            column(Due_Date; Format("Due Date")) { }
            column(Prices_Include_Tax; "Prices Including VAT") { }
            column(Document_No; "No.") { }
            column(Fiscal_No; 'SIN EMITIR') { }
            column(Issue_Date; Format("Document Date")) { }
            column(Party_Name; "Buy-from Vendor Name") { }
            column(Party_RTN; "HN Identidad Boleta") { }
            column(Source_No; '') { }
            column(Source_CAI; '') { }
            column(Source_Date; '') { }
            column(Reason; '') { }
            column(CAI_Value; '') { }
            column(CAI_Range; '') { }
            column(CAI_Expiration; '') { }
            column(Currency_Code; 'HNL') { }
            column(Issuer_Name; Empresa.Name) { }
            column(Issuer_RTN; Empresa."VAT Registration No.") { }
            column(Issuer_Address; Empresa.Address) { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Buy-from Address" + ' ' + "Buy-from Address 2" + ' ' + "Buy-from City") { }
            column(Total_Amount; "Amount Including VAT") { }
            column(Party_Phone; "HN Telefono Boleta") { }
            column(Issuer_Phone; Empresa."Phone No.") { }
            column(Issuer_Email; Empresa."E-Mail") { }
            column(Amount_Words; Letras.Convertir("Amount Including VAT")) { }
            column(Exempt_Order; "HN Orden Exenta Boleta") { }
            column(Exempt_Register; "HN Registro Exento Boleta") { }
            column(SAG_Register; "HN Registro SAG Boleta") { }
            dataitem(Linea; "Purchase Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            column(Line_Code; "No.") { }
                column(Line_Unit; "Unit of Measure Code") { }
                column(Line_Discount; "Line Discount Amount" + "Inv. Discount Amount") { }
                column(Line_Tax; "Amount Including VAT" - Amount) { }
                column(Line_Quantity; Quantity) { }
            column(Line_Unit_Price; "Direct Unit Cost") { }
            column(Line_Description; Description) { }
            column(Line_Base; Amount) { }
            column(Line_Rate; "VAT %") { }
            column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                TestField("HN Boleta Compra", true);

                CalcFields(Amount, "Amount Including VAT");
            end;
        }
    }
    rendering { layout(Formato) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/BorradorBoleta.rdlc'; Caption = 'BORRADOR DE BOLETA — SIN VALIDEZ FISCAL'; } }
    trigger OnPreReport()
    begin
        DatosFormato.ComprobarFormatoActivo(71127);
        FechaImpresionFormato := Format(CurrentDateTime());
        DatosFormato.CargarEmpresa(LogoFormato,TipoLogoFormato,ContactoFormato);
        Empresa.Get();
    end;
    var
        FechaImpresionFormato: Text;
        DatosFormato: Codeunit "HN Datos Formatos";
        LogoFormato: Text;
        TipoLogoFormato: Text;
        ContactoFormato: Text;
        Empresa: Record "Company Information";
        Letras: Codeunit "HN Importe En Letras";
}
