namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 71113 "HN Gestion Boletas"
{
    SingleInstance = true;

    procedure Preparar(var Cabecera: Record "Purchase Header")
    var
        Proveedor: Record Vendor;
    begin
        if not (Cabecera."Document Type" in [Cabecera."Document Type"::Order, Cabecera."Document Type"::Invoice]) then
            Error('La boleta de compra se emite desde un pedido o una factura de compra.');
        Cabecera.TestField("HN Vendor CAI", '');
        Cabecera.TestField("HN Codigo CAI Proveedor", '');
        Cabecera.TestField("Vendor Invoice No.", '');
        Cabecera."HN Boleta Compra" := true;
        if Proveedor.Get(Cabecera."Buy-from Vendor No.") then begin
            Cabecera."HN Identidad Boleta" := Proveedor."HN Identidad Boleta";
            if Cabecera."HN Identidad Boleta" = '' then
                Cabecera."HN Identidad Boleta" := Proveedor."VAT Registration No.";
            Cabecera."HN Telefono Boleta" := Proveedor."Phone No.";
        end;
    end;

    procedure Validar(Cabecera: Record "Purchase Header")
    var
        Configuracion: Record "HN Config. Facturacion";
        Autorizacion: Record "HN CAI Authorization";
        Gestion: Codeunit "HN CAI Management";
        Empresa: Record "Company Information";
        Proveedor: Record Vendor;
        Contabilidad: Record "General Ledger Setup";
    begin
        Cabecera.TestField("HN Boleta Compra", true);
        if not (Cabecera."Document Type" in [Cabecera."Document Type"::Order, Cabecera."Document Type"::Invoice]) then
            Error('La boleta solo admite pedidos y facturas de compra. Los documentos correctivos requieren su tratamiento fiscal específico.');
        Configuracion.Get('');
        Configuracion.TestField("Boletas habilitadas", true);
        Configuracion.TestField("CAI boletas");
        Cabecera.TestField("Document Date");
        Cabecera.TestField("Posting Date");
        Cabecera.TestField("Buy-from Vendor No.");
        Cabecera.TestField("Pay-to Vendor No.");
        Cabecera.TestField("Buy-from Vendor Name");
        Cabecera.TestField("Buy-from Address");
        Cabecera.TestField("HN Identidad Boleta");
        Cabecera.TestField("HN Telefono Boleta");
        Cabecera.TestField("HN Vendor CAI", '');
        Cabecera.TestField("HN Codigo CAI Proveedor", '');
        Cabecera.TestField("Vendor Invoice No.", '');
        Cabecera.TestField("Self-Billing Invoice", false);
        Proveedor.Get(Cabecera."Buy-from Vendor No.");
        Proveedor.TestField("HN Persona Natural Hondurena", true);
        Contabilidad.Get();
        Contabilidad.TestField("LCY Code", 'HNL');
        if Cabecera."Currency Code" <> '' then Cabecera.TestField("Currency Code", 'HNL');
        Empresa.Get();
        Empresa.TestField(Name);
        Empresa.TestField("VAT Registration No.");
        Empresa.TestField(Address);
        Empresa.TestField("Phone No.");
        Empresa.TestField("E-Mail");
        Autorizacion.Get(Configuracion."CAI boletas");
        Gestion.ValidateAuthorization(Autorizacion, "HN Fiscal Document Type"::BoletaCompra, Cabecera."Document Date");
        ValidarLineas(Cabecera);
    end;

    procedure ValidarLineas(Cabecera: Record "Purchase Header")
    var
        Linea: Record "Purchase Line";
    begin
        Linea.SetRange("Document Type", Cabecera."Document Type");
        Linea.SetRange("Document No.", Cabecera."No.");
        if Linea.FindSet() then
            repeat
                ValidarLinea(Linea);
            until Linea.Next() = 0;
    end;

    procedure ValidarLinea(Linea: Record "Purchase Line")
    begin
        if Linea.Type = Linea.Type::" " then exit;
        Linea.TestField(Description);
        if Linea.Quantity <= 0 then Error('La línea %1 de la boleta debe tener cantidad positiva.', Linea."Line No.");
        Linea.TestField("VAT %", 0);
        Linea.TestField("VAT Calculation Type", Linea."VAT Calculation Type"::"Normal VAT");
        if Linea."Amount Including VAT" <> Linea.Amount then
            Error('La boleta no puede generar crédito fiscal de ISV. Revise la línea %1.', Linea."Line No.");
        if Linea.Amount < 0 then Error('La boleta no admite importes negativos.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure AntesRegistro(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        EsVistaPrevia := PreviewMode;
        if PurchaseHeader."HN Boleta Compra" then
            if PurchaseHeader.Invoice then Validar(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCheckExtDocNo', '', false, false)]
    local procedure SinFacturaProveedor(PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        // No exigir ni inventar una factura del proveedor: el adquirente emitirá su boleta al registrar.
        if PurchaseHeader."HN Boleta Compra" then begin
            Validar(PurchaseHeader);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure Emitir(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header")
    var
        Configuracion: Record "HN Config. Facturacion";
        Autorizacion: Record "HN CAI Authorization";
        Gestion: Codeunit "HN CAI Management";
        Empresa: Record "Company Information";
        Movimiento: Record "HN Movimiento Fiscal";
    begin
        if not PurchHeader."HN Boleta Compra" then exit;
        Validar(PurchHeader);
        Configuracion.Get('');
        Autorizacion.Get(Configuracion."CAI boletas");
        PurchInvHeader."HN Boleta Compra" := true;
        PurchInvHeader."HN Numero Boleta" := Gestion.EmitirEnRegistro(Autorizacion.Code, "HN Fiscal Document Type"::BoletaCompra, PurchHeader."Document Date", EsVistaPrevia, Autorizacion);
        // No persistir el correlativo en el origen: cada facturación parcial emite uno nuevo.
        PurchInvHeader."HN CAI Boleta" := Autorizacion.CAI;
        PurchInvHeader."HN Autorizacion Boleta" := Autorizacion.Code;
        PurchInvHeader."HN Inicio Boleta" := Autorizacion."Starting No.";
        PurchInvHeader."HN Fin Boleta" := Autorizacion."Ending No.";
        PurchInvHeader."HN Vence Boleta" := Autorizacion."Valid Until";
        PurchInvHeader."HN Identidad Boleta" := PurchHeader."HN Identidad Boleta";
        PurchInvHeader."HN Telefono Boleta" := PurchHeader."HN Telefono Boleta";
        PurchInvHeader."Vendor Invoice No." := PurchInvHeader."HN Numero Boleta";
        if EsVistaPrevia then
            PurchHeader."Vendor Invoice No." := 'VISTA PREVIA'
        else
            PurchHeader."Vendor Invoice No." := PurchInvHeader."HN Numero Boleta";
        Empresa.Get();
        PurchInvHeader."HN Nombre Emisor Boleta" := Empresa.Name;
        PurchInvHeader."HN RTN Emisor Boleta" := Empresa."VAT Registration No.";
        PurchInvHeader."HN Direccion Emisor Boleta" := CopyStr(Empresa.Address + ' ' + Empresa."Address 2" + ' ' + Empresa.City, 1, 200);
        PurchInvHeader."HN Telefono Emisor Boleta" := Empresa."Phone No.";
        PurchInvHeader."HN Correo Emisor Boleta" := Empresa."E-Mail";
        if EsVistaPrevia then exit;
        // Es compra=false representa comprobantes EMITIDOS con CAI propio, también las boletas.
        Movimiento."Tipo documento" := Movimiento."Tipo documento"::BoletaCompra;
        Movimiento."No. documento" := PurchInvHeader."No.";
        Movimiento."Numero fiscal" := PurchInvHeader."HN Numero Boleta";
        Movimiento.CAI := Autorizacion.CAI;
        Movimiento."Codigo autorizacion" := Autorizacion.Code;
        Movimiento."Fecha emision" := PurchInvHeader."Document Date";
        Movimiento."Fecha registro" := PurchInvHeader."Posting Date";
        Movimiento."No. tercero" := PurchInvHeader."Buy-from Vendor No.";
        Movimiento."Nombre tercero" := PurchInvHeader."Buy-from Vendor Name";
        Movimiento."Rango inicial" := Autorizacion."Starting No.";
        Movimiento."Rango final" := Autorizacion."Ending No.";
        Movimiento.Vencimiento := Autorizacion."Valid Until";
        Movimiento.Usuario := UserId();
        Movimiento."Registrado el" := CurrentDateTime();
        Movimiento.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnFinalizePostingOnBeforeUpdateAfterPosting', '', false, false)]
    local procedure LimpiarReferenciaAbierta(var PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader."HN Boleta Compra" then
            Clear(PurchHeader."Vendor Invoice No.");
    end;

    var
        EsVistaPrevia: Boolean;
}
