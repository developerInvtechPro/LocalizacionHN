namespace INVTECH.Honduras;

using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;

// Un proveedor puede conservar varias autorizaciones y puntos de emisión en su historial.
table 71111 "HN CAI Proveedor"
{
    Caption = 'Autorización CAI del proveedor';
    DataClassification = CustomerContent;
    LookupPageId = "HN CAI Proveedores";
    fields
    {
        field(1; "No. proveedor"; Code[20]) { Caption = 'N.º proveedor'; TableRelation = Vendor; NotBlank = true; }
        field(2; Codigo; Code[20]) { Caption = 'Código de autorización'; NotBlank = true; }
        field(3; "Nombre proveedor"; Text[100]) { Caption = 'Nombre del proveedor'; FieldClass = FlowField; CalcFormula = lookup(Vendor.Name where("No." = field("No. proveedor"))); Editable = false; }
        field(4; CAI; Code[37]) { Caption = 'CAI'; }
        field(5; "Numero inicial"; Code[20]) { Caption = 'Número inicial'; }
        field(6; "Numero final"; Code[20]) { Caption = 'Número final'; }
        field(7; "Vigente desde"; Date) { Caption = 'Vigente desde'; }
        field(8; "Fecha limite"; Date) { Caption = 'Fecha límite de emisión'; }
        field(9; "Tipo documento"; Enum "HN Fiscal Document Type") { Caption = 'Tipo de documento'; InitValue = Factura; }
        field(10; Habilitado; Boolean)
        {
            Caption = 'Habilitado';
            trigger OnValidate()
            var
                Gestion: Codeunit "HN Gestion CAI Proveedor";
            begin
                if Habilitado then Gestion.ValidarAutorizacion(Rec);
            end;
        }
        field(11; "Ultima utilizacion"; DateTime) { Caption = 'Última utilización'; Editable = false; }
    }
    keys { key(PK; "No. proveedor", Codigo) { Clustered = true; } }
    trigger OnModify()
    var
        Gestion: Codeunit "HN Gestion CAI Proveedor";
    begin
        if xRec."Ultima utilizacion" <> 0DT then begin
            TestField(CAI, xRec.CAI);
            TestField("Numero inicial", xRec."Numero inicial");
            TestField("Numero final", xRec."Numero final");
            TestField("Vigente desde", xRec."Vigente desde");
            TestField("Fecha limite", xRec."Fecha limite");
            TestField("Tipo documento", xRec."Tipo documento");
            TestField("Ultima utilizacion", xRec."Ultima utilizacion");
        end;
        if Habilitado then Gestion.ValidarAutorizacion(Rec);
    end;
    trigger OnDelete()
    begin
        TestField("Ultima utilizacion", 0DT);
    end;
    trigger OnRename()
    begin
        TestField("Ultima utilizacion", 0DT);
    end;
}

page 71111 "HN CAI Proveedores"
{
    Caption = 'Gestión de CAI de proveedores HN';
    SourceTable = "HN CAI Proveedor";
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            repeater(Autorizaciones)
            {
                field(Proveedor; Rec."No. proveedor") { ApplicationArea = All; }
                field(Nombre; Rec."Nombre proveedor") { ApplicationArea = All; }
                field(Codigo; Rec.Codigo) { ApplicationArea = All; }
                field(Tipo; Rec."Tipo documento") { ApplicationArea = All; }
                field(CAI; Rec.CAI) { ApplicationArea = All; }
                field(Inicio; Rec."Numero inicial") { ApplicationArea = All; }
                field(Fin; Rec."Numero final") { ApplicationArea = All; }
                field(Desde; Rec."Vigente desde") { ApplicationArea = All; }
                field(Limite; Rec."Fecha limite") { ApplicationArea = All; }
                field(Habilitado; Rec.Habilitado) { ApplicationArea = All; }
                field(Uso; Rec."Ultima utilizacion") { ApplicationArea = All; }
            }
        }
    }
}

codeunit 71111 "HN Gestion CAI Proveedor"
{
    SingleInstance = true;

    procedure ValidarAutorizacion(Autorizacion: Record "HN CAI Proveedor")
    var
        Gestion: Codeunit "HN CAI Management";
        Prefijo: Text;
    begin
        Autorizacion.TestField("No. proveedor");
        Autorizacion.TestField(Codigo);
        Gestion.ValidarClave(Autorizacion.CAI);
        Gestion.ValidateFiscalNo(Autorizacion."Numero inicial");
        Gestion.ValidateFiscalNo(Autorizacion."Numero final");
        if CopyStr(Autorizacion."Numero inicial", 1, 11) <> CopyStr(Autorizacion."Numero final", 1, 11) then
            Error('El rango debe mantener establecimiento, punto de emisión y tipo de documento.');
        if Autorizacion."Numero inicial" > Autorizacion."Numero final" then
            Error('El número inicial no puede superar el número final.');
        Autorizacion.TestField("Vigente desde");
        Autorizacion.TestField("Fecha limite");
        if Autorizacion."Vigente desde" > Autorizacion."Fecha limite" then
            Error('La fecha inicial no puede ser posterior al vencimiento.');
        case Autorizacion."Tipo documento" of
            Autorizacion."Tipo documento"::Factura: Prefijo := '01';
            Autorizacion."Tipo documento"::NotaCredito: Prefijo := '06';
            else Error('La autorización del proveedor debe corresponder a factura o nota de crédito.');
        end;
        if CopyStr(Autorizacion."Numero inicial", 9, 2) <> Prefijo then
            Error('El rango no corresponde al tipo de documento seleccionado.');
    end;

    procedure ComprobarDocumento(Autorizacion: Record "HN CAI Proveedor"; NumeroFiscal: Code[20]; FechaEmision: Date; Tipo: Enum "HN Fiscal Document Type")
    var
        Gestion: Codeunit "HN CAI Management";
    begin
        ValidarAutorizacion(Autorizacion);
        Autorizacion.TestField(Habilitado, true);
        Autorizacion.TestField("Tipo documento", Tipo);
        Gestion.ValidateFiscalNo(NumeroFiscal);
        if (FechaEmision = 0D) or (FechaEmision < Autorizacion."Vigente desde") or (FechaEmision > Autorizacion."Fecha limite") then
            Error('La fecha de emisión del documento está fuera de la vigencia del CAI del proveedor %1.', Autorizacion."No. proveedor");
        if (CopyStr(NumeroFiscal, 1, 11) <> CopyStr(Autorizacion."Numero inicial", 1, 11)) or
           (NumeroFiscal < Autorizacion."Numero inicial") or (NumeroFiscal > Autorizacion."Numero final") then
            Error('El documento %1 está fuera del rango autorizado del proveedor.', NumeroFiscal);
    end;

    procedure ProponerDatos(var Cabecera: Record "Purchase Header")
    var
        Autorizacion: Record "HN CAI Proveedor";
    begin
        if Cabecera."HN Codigo CAI Proveedor" = '' then begin
            Clear(Cabecera."HN Vendor CAI");
            Clear(Cabecera."HN Inicio CAI Proveedor");
            Clear(Cabecera."HN Fin CAI Proveedor");
            Clear(Cabecera."HN Vence CAI Proveedor");
            exit;
        end;
        Cabecera.TestField("Buy-from Vendor No.");
        Autorizacion.Get(Cabecera."Buy-from Vendor No.", Cabecera."HN Codigo CAI Proveedor");
        Autorizacion.TestField(Habilitado, true);
        CopiarDatos(Cabecera, Autorizacion);
    end;

    procedure ValidarCompra(var Cabecera: Record "Purchase Header")
    var
        Autorizacion: Record "HN CAI Proveedor";
        Configuracion: Record "HN Config. Facturacion";
        Numero: Code[20];
        NumeroOriginal: Text;
        Tipo: Enum "HN Fiscal Document Type";
        Coincidencias: Integer;
        CodigoElegido: Code[20];
        Movimiento: Record "HN Movimiento Fiscal";
    begin
        if Cabecera."HN Boleta Compra" then exit;
        if not Configuracion.Get('') then exit;
        if not Configuracion."Validar compras" then exit;
        if Cabecera."Document Type" in [Cabecera."Document Type"::"Credit Memo", Cabecera."Document Type"::"Return Order"] then begin
            NumeroOriginal := Cabecera."Vendor Cr. Memo No.";
            Tipo := Tipo::NotaCredito;
        end else begin
            NumeroOriginal := Cabecera."Vendor Invoice No.";
            Tipo := Tipo::Factura;
        end;
        if StrLen(NumeroOriginal) <> 19 then
            Error('Indique el número fiscal completo del proveedor: 000-000-00-00000000.');
        Numero := NumeroOriginal;
        Cabecera.TestField("Buy-from Vendor No.");
        if Cabecera."HN Codigo CAI Proveedor" = '' then begin
            Autorizacion.SetRange("No. proveedor", Cabecera."Buy-from Vendor No.");
            Autorizacion.SetRange("Tipo documento", Tipo);
            Autorizacion.SetRange(Habilitado, true);
            Autorizacion.SetFilter("Vigente desde", '<=%1', Cabecera."Document Date");
            Autorizacion.SetFilter("Fecha limite", '>=%1', Cabecera."Document Date");
            if Autorizacion.FindSet() then
                repeat
                    if (CopyStr(Numero, 1, 11) = CopyStr(Autorizacion."Numero inicial", 1, 11)) and
                       (Numero >= Autorizacion."Numero inicial") and (Numero <= Autorizacion."Numero final") then begin
                        Coincidencias += 1;
                        CodigoElegido := Autorizacion.Codigo;
                    end;
                until Autorizacion.Next() = 0;
            if Coincidencias <> 1 then
                Error('Se encontraron %1 autorizaciones aplicables. Seleccione un CAI del proveedor válido para ese documento y fecha.', Coincidencias);
            Cabecera."HN Codigo CAI Proveedor" := CodigoElegido;
        end;
        Autorizacion.Get(Cabecera."Buy-from Vendor No.", Cabecera."HN Codigo CAI Proveedor");
        ComprobarDocumento(Autorizacion, Numero, Cabecera."Document Date", Tipo);
        if (Cabecera."HN Vendor CAI" <> '') and (Cabecera."HN Vendor CAI" <> Autorizacion.CAI) then
            Error('El CAI capturado no coincide con la autorización seleccionada. Revise los datos de la factura original.');
        Movimiento.SetRange("Es compra", true);
        Movimiento.SetRange("No. tercero", Cabecera."Buy-from Vendor No.");
        Movimiento.SetRange("Numero fiscal", Numero);
        if not Movimiento.IsEmpty() then Error('El documento fiscal %1 ya se registró para este proveedor.', Numero);
        CopiarDatos(Cabecera, Autorizacion);
    end;

    local procedure CopiarDatos(var Cabecera: Record "Purchase Header"; Autorizacion: Record "HN CAI Proveedor")
    begin
        Cabecera."HN Vendor CAI" := Autorizacion.CAI;
        Cabecera."HN Inicio CAI Proveedor" := Autorizacion."Numero inicial";
        Cabecera."HN Fin CAI Proveedor" := Autorizacion."Numero final";
        Cabecera."HN Vence CAI Proveedor" := Autorizacion."Fecha limite";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure AntesRegistro(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        EsVistaPrevia := PreviewMode;
        // Recibir mercancía sin facturar no emite un documento fiscal del proveedor.
        if PurchaseHeader.Invoice then ValidarCompra(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure AntesFactura(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader."HN Boleta Compra" then exit;
        PurchInvHeader."HN Codigo CAI Proveedor" := PurchHeader."HN Codigo CAI Proveedor";
        PurchInvHeader."HN Inicio CAI Proveedor" := PurchHeader."HN Inicio CAI Proveedor";
        PurchInvHeader."HN Fin CAI Proveedor" := PurchHeader."HN Fin CAI Proveedor";
        PurchInvHeader."HN Vence CAI Proveedor" := PurchHeader."HN Vence CAI Proveedor";
        RegistrarUso(PurchHeader, PurchInvHeader."No.", "HN Fiscal Document Type"::Factura);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoHeaderInsert', '', false, false)]
    local procedure AntesAbono(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header")
    begin
        PurchCrMemoHdr."HN Vendor CAI" := PurchHeader."HN Vendor CAI";
        PurchCrMemoHdr."HN Codigo CAI Proveedor" := PurchHeader."HN Codigo CAI Proveedor";
        PurchCrMemoHdr."HN Inicio CAI Proveedor" := PurchHeader."HN Inicio CAI Proveedor";
        PurchCrMemoHdr."HN Fin CAI Proveedor" := PurchHeader."HN Fin CAI Proveedor";
        PurchCrMemoHdr."HN Vence CAI Proveedor" := PurchHeader."HN Vence CAI Proveedor";
        RegistrarUso(PurchHeader, PurchCrMemoHdr."No.", "HN Fiscal Document Type"::NotaCredito);
    end;

    local procedure RegistrarUso(Cabecera: Record "Purchase Header"; NumeroRegistrado: Code[20]; Tipo: Enum "HN Fiscal Document Type")
    var
        Autorizacion: Record "HN CAI Proveedor";
        Movimiento: Record "HN Movimiento Fiscal";
        Configuracion: Record "HN Config. Facturacion";
        Proveedor: Record Vendor;
    begin
        if EsVistaPrevia then exit;
        if Cabecera."HN Boleta Compra" then exit;
        if not Configuracion.Get('') then exit;
        if not Configuracion."Validar compras" then exit;
        Autorizacion.LockTable();
        Autorizacion.Get(Cabecera."Buy-from Vendor No.", Cabecera."HN Codigo CAI Proveedor");
        Autorizacion."Ultima utilizacion" := CurrentDateTime();
        Autorizacion.Modify(false);
        Proveedor.Get(Cabecera."Buy-from Vendor No.");
        Movimiento.Init();
        Movimiento."Es compra" := true;
        Movimiento."Tipo documento" := Tipo;
        Movimiento."No. documento" := NumeroRegistrado;
        if Tipo = Tipo::Factura then Movimiento."Numero fiscal" := Cabecera."Vendor Invoice No." else Movimiento."Numero fiscal" := Cabecera."Vendor Cr. Memo No.";
        Movimiento.CAI := Autorizacion.CAI;
        Movimiento."Codigo autorizacion" := Autorizacion.Codigo;
        Movimiento."Fecha emision" := Cabecera."Document Date";
        Movimiento."Fecha registro" := Cabecera."Posting Date";
        Movimiento."No. tercero" := Proveedor."No.";
        Movimiento."Nombre tercero" := Proveedor.Name;
        Movimiento."Rango inicial" := Autorizacion."Numero inicial";
        Movimiento."Rango final" := Autorizacion."Numero final";
        Movimiento.Vencimiento := Autorizacion."Fecha limite";
        Movimiento.Usuario := UserId();
        Movimiento."Registrado el" := CurrentDateTime();
        Movimiento.Insert(true);
    end;
    var
        EsVistaPrevia: Boolean;
}
