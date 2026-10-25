namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;

codeunit 71110 "HN Gestion Facturacion"
{
    SingleInstance = true;

    procedure PrepararDocumento(var Cabecera: Record "Sales Header")
    var
        Configuracion: Record "HN Config. Facturacion";
    begin
        if not Configuracion.Get('') then
            Error('Abra Configuración de facturación HN, complete las autorizaciones y habilite la facturación antes de registrar el documento.');
        Configuracion.TestField("Ventas habilitadas", true);
        if Cabecera."HN Debit Note" then
            Error('La nota de débito usa su propia configuración y autorización.');
        if (StrLen(Cabecera."External Document No.") = 19) and
           (CopyStr(Cabecera."External Document No.", 4, 1) = '-') and
           (CopyStr(Cabecera."External Document No.", 8, 1) = '-') and
           (CopyStr(Cabecera."External Document No.", 11, 1) = '-') then
            Error('El documento ya contiene una referencia fiscal externa. Revise su procedencia y la migración antes de generar otra numeración.');
        if Cabecera."INV POS Transaction No." <> '' then
            Error('Este documento conserva una identidad fiscal POS. Complete su adaptación antes de activar una nueva emisión fiscal.');
        // Siempre resolver desde la configuración vigente al registrar; no reservar en borradores.
        if EsAbono(Cabecera) then
            Cabecera."HN CAI Code" := Configuracion."CAI abonos"
        else
            Cabecera."HN CAI Code" := Configuracion."CAI facturas";
    end;

    procedure EstablecerOrigen(var Cabecera: Record "Sales Header")
    var
        Factura: Record "Sales Invoice Header";
    begin
        Factura.Get(Cabecera."HN Original Invoice No.");
        Factura.TestField("Bill-to Customer No.", Cabecera."Bill-to Customer No.");
        Factura.TestField("Sell-to Customer No.", Cabecera."Sell-to Customer No.");
        Factura.TestField("Currency Code", Cabecera."Currency Code");
        Cabecera."HN Source Fiscal No." := Factura."HN Fiscal No.";
        Cabecera."HN Source CAI" := Factura."HN CAI";
        if Cabecera."HN Source Fiscal No." = '' then begin
            Cabecera."HN Source Fiscal No." := Factura."INV POS Transaction No.";
            Cabecera."HN Source CAI" := Factura."INV POS CAI";
        end;
        Cabecera."HN Original Invoice Date" := Factura."Document Date";
    end;

    procedure ValidarDocumento(var Cabecera: Record "Sales Header")
    var
        Autorizacion: Record "HN CAI Authorization";
        GestionCAI: Codeunit "HN CAI Management";
        Empresa: Record "Company Information";
        Factura: Record "Sales Invoice Header";
    begin
        PrepararDocumento(Cabecera);
        Cabecera.TestField("Document Date");
        Cabecera.TestField("Posting Date");
        Cabecera.TestField("Sell-to Customer No.");
        Cabecera.TestField("Bill-to Customer No.");
        Cabecera.TestField("HN CAI Code");
        Autorizacion.Get(Cabecera."HN CAI Code");
        GestionCAI.ValidateAuthorization(Autorizacion, ObtenerTipo(Cabecera), Cabecera."Document Date");
        Empresa.Get();
        Empresa.TestField("VAT Registration No.");
        if EsAbono(Cabecera) then begin
            Cabecera.TestField("HN Original Invoice No.");
            Factura.Get(Cabecera."HN Original Invoice No.");
            Factura.TestField("Bill-to Customer No.", Cabecera."Bill-to Customer No.");
            Factura.TestField("Sell-to Customer No.", Cabecera."Sell-to Customer No.");
            Factura.TestField("Currency Code", Cabecera."Currency Code");
            Cabecera.TestField("HN Debit Reason");
            Cabecera.TestField("HN Source Fiscal No.");
            if StrLen(Cabecera."HN Source Fiscal No.") <> 19 then
                Error('Indique el número fiscal completo de la factura de origen.');
            GestionCAI.ValidateFiscalNo(Cabecera."HN Source Fiscal No.");
            GestionCAI.ValidarClave(Cabecera."HN Source CAI");
            if Factura."HN Fiscal No." <> '' then begin
                Factura.TestField("HN Fiscal No.", Cabecera."HN Source Fiscal No.");
                Factura.TestField("HN CAI", Cabecera."HN Source CAI");
            end;
            if Cabecera."Document Date" < Factura."Document Date" then
                Error('La nota de crédito no puede emitirse antes de la factura de origen.');
        end;
    end;

    procedure DebeEmitir(Cabecera: Record "Sales Header"): Boolean
    var
        Configuracion: Record "HN Config. Facturacion";
    begin
        if Cabecera."HN Debit Note" then exit(false);
        if not (Cabecera."Document Type" in [Cabecera."Document Type"::Order, Cabecera."Document Type"::Invoice,
            Cabecera."Document Type"::"Credit Memo", Cabecera."Document Type"::"Return Order"]) then exit(false);
        // El receptor POS conserva su identidad y no debe emitir un segundo comprobante.
        if Cabecera."INV POS Transaction No." <> '' then exit(false);
        if not Configuracion.Get('') then exit(false);
        exit(Configuracion."Ventas habilitadas");
    end;

    local procedure EsAbono(Cabecera: Record "Sales Header"): Boolean
    begin
        exit(Cabecera."Document Type" in [Cabecera."Document Type"::"Credit Memo", Cabecera."Document Type"::"Return Order"]);
    end;

    local procedure ObtenerTipo(Cabecera: Record "Sales Header"): Enum "HN Fiscal Document Type"
    begin
        if EsAbono(Cabecera) then exit("HN Fiscal Document Type"::NotaCredito);
        exit("HN Fiscal Document Type"::Factura);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure AntesRegistro(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
        EsVistaPrevia := PreviewMode;
        if not DebeEmitir(SalesHeader) then exit;
        if SalesHeader.Invoice then
            ValidarDocumento(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure AntesFactura(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header")
    var
        Autorizacion: Record "HN CAI Authorization";
        GestionCAI: Codeunit "HN CAI Management";
        Empresa: Record "Company Information";
    begin
        SalesInvHeader."HN Emitir Documento Fiscal" := false;
        if not DebeEmitir(SalesHeader) then exit;
        ValidarDocumento(SalesHeader);
        SalesInvHeader."HN Emitir Documento Fiscal" := true;
        SalesInvHeader."HN CAI Code" := SalesHeader."HN CAI Code";
        Autorizacion.Get(SalesHeader."HN CAI Code");
        SalesInvHeader."HN Fiscal No." := GestionCAI.EmitirEnRegistro(Autorizacion.Code, "HN Fiscal Document Type"::Factura, SalesHeader."Document Date", EsVistaPrevia, Autorizacion);
        SalesInvHeader."HN CAI" := Autorizacion.CAI;
        SalesInvHeader."HN CAI Starting No." := Autorizacion."Starting No.";
        SalesInvHeader."HN CAI Ending No." := Autorizacion."Ending No.";
        SalesInvHeader."HN CAI Valid Until" := Autorizacion."Valid Until";
        SalesInvHeader."HN RTN Destinatario" := ObtenerRTN(SalesHeader);
        Empresa.Get();
        SalesInvHeader."HN Issuer Name" := Empresa.Name;
        SalesInvHeader."HN Issuer RTN" := Empresa."VAT Registration No.";
        SalesInvHeader."HN Issuer Address" := CopyStr(Empresa.Address + ' ' + Empresa."Address 2" + ' ' + Empresa.City, 1, 200);
        if not EsVistaPrevia then
            RegistrarMovimiento(SalesHeader, SalesInvHeader."No.", SalesInvHeader."HN Fiscal No.", Autorizacion);
        // El pedido mantiene su número interno; cada facturación parcial obtiene un correlativo distinto.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure AntesAbono(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header")
    var
        Autorizacion: Record "HN CAI Authorization";
        GestionCAI: Codeunit "HN CAI Management";
        Empresa: Record "Company Information";
    begin
        SalesCrMemoHeader."HN Emitir Documento Fiscal" := false;
        if not DebeEmitir(SalesHeader) then exit;
        ValidarDocumento(SalesHeader);
        Autorizacion.Get(SalesHeader."HN CAI Code");
        SalesCrMemoHeader."HN Emitir Documento Fiscal" := true;
        SalesCrMemoHeader."HN CAI Code" := Autorizacion.Code;
        SalesCrMemoHeader."HN Fiscal No." := GestionCAI.EmitirEnRegistro(Autorizacion.Code, "HN Fiscal Document Type"::NotaCredito, SalesHeader."Document Date", EsVistaPrevia, Autorizacion);
        SalesCrMemoHeader."HN CAI" := Autorizacion.CAI;
        SalesCrMemoHeader."HN CAI Starting No." := Autorizacion."Starting No.";
        SalesCrMemoHeader."HN CAI Ending No." := Autorizacion."Ending No.";
        SalesCrMemoHeader."HN CAI Valid Until" := Autorizacion."Valid Until";
        SalesCrMemoHeader."HN RTN Destinatario" := ObtenerRTN(SalesHeader);
        SalesCrMemoHeader."HN Source Fiscal No." := SalesHeader."HN Source Fiscal No.";
        SalesCrMemoHeader."HN Source CAI" := SalesHeader."HN Source CAI";
        SalesCrMemoHeader."HN Original Invoice No." := SalesHeader."HN Original Invoice No.";
        SalesCrMemoHeader."HN Original Invoice Date" := SalesHeader."HN Original Invoice Date";
        SalesCrMemoHeader."HN Motivo" := SalesHeader."HN Debit Reason";
        Empresa.Get();
        SalesCrMemoHeader."HN Issuer Name" := Empresa.Name;
        SalesCrMemoHeader."HN Issuer RTN" := Empresa."VAT Registration No.";
        SalesCrMemoHeader."HN Issuer Address" := CopyStr(Empresa.Address + ' ' + Empresa."Address 2" + ' ' + Empresa.City, 1, 200);
        if not EsVistaPrevia then
            RegistrarMovimiento(SalesHeader, SalesCrMemoHeader."No.", SalesCrMemoHeader."HN Fiscal No.", Autorizacion);
    end;

    local procedure ObtenerRTN(Cabecera: Record "Sales Header"): Text[50]
    var
        Cliente: Record Customer;
    begin
        Cliente.Get(Cabecera."Bill-to Customer No.");
        if Cliente."INV HN RTN" <> '' then exit(Cliente."INV HN RTN");
        exit(Cabecera."VAT Registration No.");
    end;

    local procedure RegistrarMovimiento(Cabecera: Record "Sales Header"; NumeroRegistrado: Code[20]; NumeroFiscal: Code[20]; Autorizacion: Record "HN CAI Authorization")
    var
        Movimiento: Record "HN Movimiento Fiscal";
    begin
        Movimiento.Init();
        Movimiento."Tipo documento" := ObtenerTipo(Cabecera);
        Movimiento."No. documento" := NumeroRegistrado;
        Movimiento."Numero fiscal" := NumeroFiscal;
        Movimiento.CAI := Autorizacion.CAI;
        Movimiento."Codigo autorizacion" := Autorizacion.Code;
        Movimiento."Fecha emision" := Cabecera."Document Date";
        Movimiento."Fecha registro" := Cabecera."Posting Date";
        Movimiento."No. tercero" := Cabecera."Bill-to Customer No.";
        Movimiento."Nombre tercero" := Cabecera."Bill-to Name";
        Movimiento."Rango inicial" := Autorizacion."Starting No.";
        Movimiento."Rango final" := Autorizacion."Ending No.";
        Movimiento.Vencimiento := Autorizacion."Valid Until";
        Movimiento.Usuario := UserId();
        Movimiento."Registrado el" := CurrentDateTime();
        Movimiento.Insert(true);
    end;
    var
        EsVistaPrevia: Boolean;
}
