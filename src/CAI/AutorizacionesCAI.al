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

table 50101 "HN CAI Authorization"
{
    Caption = 'Autorización CAI HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; Code; Code[20]) { Caption = 'Código'; NotBlank = true; }
        field(2; "Document Type"; Enum "HN Fiscal Document Type") { Caption = 'Tipo de documento'; }
        field(3; CAI; Code[37]) { Caption = 'CAI'; }
        field(4; "Starting No."; Code[20]) { Caption = 'Número inicial'; }
        field(5; "Ending No."; Code[20]) { Caption = 'Número final'; }
        field(6; "Next No."; Code[20]) { Caption = 'Próximo número'; }
        field(7; "Valid From"; Date) { Caption = 'Vigente desde'; }
        field(8; "Valid Until"; Date) { Caption = 'Fecha límite de emisión'; }
        field(9; Enabled; Boolean)
        {
            Caption = 'Habilitado';
            trigger OnValidate()
            var
                Management: Codeunit "HN CAI Management";
            begin
                if Enabled then
                    Management.ValidateAuthorization(Rec, "Document Type", "Valid From");
            end;
        }
        field(10; "Last Issued No."; Code[20]) { Caption = 'Último número emitido'; Editable = false; }
    }
    keys { key(PK; Code) { Clustered = true; } }
    trigger OnModify()
    begin
        if xRec."Last Issued No." <> '' then begin
            TestField("Document Type", xRec."Document Type");
            TestField(CAI, xRec.CAI);
            TestField("Starting No.", xRec."Starting No.");
            TestField("Ending No.", xRec."Ending No.");
            TestField("Valid From", xRec."Valid From");
            TestField("Valid Until", xRec."Valid Until");
            TestField("Next No.", xRec."Next No.");
            TestField("Last Issued No.", xRec."Last Issued No.");
        end;
    end;
    trigger OnDelete()
    begin
        TestField("Last Issued No.", '');
    end;
    trigger OnRename()
    begin
        TestField("Last Issued No.", '');
    end;
}
codeunit 50100 "HN CAI Management"
{
    procedure ValidateAuthorization(Authorization: Record "HN CAI Authorization"; DocType: Enum "HN Fiscal Document Type"; IssueDate: Date)
    begin
        Authorization.TestField("Document Type", DocType);
        Authorization.TestField(Enabled, true);
        Authorization.TestField(CAI);
        ValidarClave(Authorization.CAI);
        if IssueDate = 0D then
            Error('Indique la fecha de emisión.');
        Authorization.TestField("Valid From");
        Authorization.TestField("Valid Until");
        if (IssueDate < Authorization."Valid From") or (IssueDate > Authorization."Valid Until") then
            Error('La fecha de emisión está fuera de la vigencia del CAI %1.', Authorization.Code);
        if (Authorization."Last Issued No." <> '') and (Authorization."Next No." <= Authorization."Last Issued No.") then
            Error('El correlativo ya fue emitido. Registre una nueva autorización.');
        ValidateFiscalNo(Authorization."Starting No.");
        ValidateFiscalNo(Authorization."Ending No.");
        ValidateFiscalNo(Authorization."Next No.");
        if (CopyStr(Authorization."Starting No.", 1, 11) <> CopyStr(Authorization."Ending No.", 1, 11)) or
           (CopyStr(Authorization."Starting No.", 1, 11) <> CopyStr(Authorization."Next No.", 1, 11)) then
            Error('Los números inicial, final y próximo deben tener el mismo establecimiento, punto de emisión y tipo.');
        if (Authorization."Next No." < Authorization."Starting No.") or (Authorization."Next No." > Authorization."Ending No.") then
            Error('El CAI %1 no tiene un correlativo disponible dentro del rango autorizado.', Authorization.Code);
        if (DocType = DocType::Retention) and (CopyStr(Authorization."Next No.", 9, 2) <> '05') then
            Error('El comprobante de retención debe utilizar el tipo fiscal 05.');
        if (DocType = DocType::"Debit Note") and (CopyStr(Authorization."Next No.", 9, 2) <> '07') then
            Error('La nota de débito debe utilizar el tipo fiscal 07.');
        if (DocType = DocType::Factura) and (CopyStr(Authorization."Next No.", 9, 2) <> '01') then
            Error('La factura debe utilizar el tipo fiscal 01.');
        if (DocType = DocType::NotaCredito) and (CopyStr(Authorization."Next No.", 9, 2) <> '06') then
            Error('La nota de crédito debe utilizar el tipo fiscal 06.');
        if (DocType = DocType::BoletaCompra) and (CopyStr(Authorization."Next No.", 9, 2) <> '11') then
            Error('La boleta de compra debe utilizar el tipo fiscal 11.');
    end;

    procedure EmitirEnRegistro(Codigo: Code[20]; Tipo: Enum "HN Fiscal Document Type"; Fecha: Date; VistaPrevia: Boolean; var Autorizacion: Record "HN CAI Authorization"): Code[20]
    begin
        if not VistaPrevia then exit(Issue(Codigo, Tipo, Fecha, Autorizacion));
        Autorizacion.Get(Codigo);
        ValidateAuthorization(Autorizacion, Tipo, Fecha);
        // La vista previa valida el rango sin asignar ni mostrar un número especulativo.
        exit('');
    end;

    procedure Issue(Code: Code[20]; DocType: Enum "HN Fiscal Document Type"; IssueDate: Date; var Authorization: Record "HN CAI Authorization"): Code[20]
    var
        OtherAuthorization: Record "HN CAI Authorization";
        Number: Code[20];
        Sequence: Integer;
        Retention: Record "HN Retention Header";
        SalesInvoice: Record "Sales Invoice Header";
        Abono: Record "Sales Cr.Memo Header";
        Movimiento: Record "HN Movimiento Fiscal";
        Boleta: Record "Purch. Inv. Header";
    begin
        Authorization.LockTable();
        Authorization.Get(Code);
        ValidateAuthorization(Authorization, DocType, IssueDate);
        Number := Authorization."Next No.";
        Movimiento.SetRange("Es compra", false);
        Movimiento.SetRange("Numero fiscal", Number);
        if not Movimiento.IsEmpty() then
            Error('El número fiscal %1 ya existe en el registro fiscal.', Number);
        if DocType = DocType::Retention then begin
            Retention.SetRange("Fiscal No.", Number);
            if not Retention.IsEmpty() then
                Error('El número fiscal %1 ya existe en un comprobante registrado.', Number);
        end else begin
            SalesInvoice.SetRange("HN Fiscal No.", Number);
            if not SalesInvoice.IsEmpty() then
                Error('El número fiscal %1 ya existe en una factura o nota de débito registrada.', Number);
            SalesInvoice.Reset();
            SalesInvoice.SetRange("INV POS Transaction No.", Number);
            if not SalesInvoice.IsEmpty() then Error('El número fiscal %1 ya existe en el histórico POS migrado.', Number);
            Abono.SetRange("HN Fiscal No.", Number);
            if not Abono.IsEmpty() then Error('El número fiscal %1 ya existe en una nota de crédito registrada.', Number);
            Abono.Reset();
            Abono.SetRange("INV POS Transaction No.", Number);
            if not Abono.IsEmpty() then Error('El número fiscal %1 ya existe en un abono POS migrado.', Number);
        end;
        Boleta.SetRange("HN Numero Boleta", Number);
        if not Boleta.IsEmpty() then Error('El número fiscal %1 ya existe en una boleta de compra registrada.', Number);
        OtherAuthorization.SetFilter(Code, '<>%1', Code);
        OtherAuthorization.SetRange("Document Type", DocType);
        if OtherAuthorization.FindSet() then
            repeat
                if CopyStr(OtherAuthorization."Starting No.", 1, 11) = CopyStr(Number, 1, 11) then
                    if (OtherAuthorization."Last Issued No." <> '') and
                       (Number >= OtherAuthorization."Starting No.") and (Number <= OtherAuthorization."Last Issued No.") then
                        Error('El número %1 ya pertenece a otra autorización utilizada.', Number);
            until OtherAuthorization.Next() = 0;
        Authorization."Last Issued No." := Number;
        Evaluate(Sequence, CopyStr(Number, 12, 8));
        if (Number = Authorization."Ending No.") or (Sequence = 99999999) then
            Authorization.Enabled := false
        else
            Authorization."Next No." := IncStr(Number);
        // El consumo del correlativo se realiza aquí; la edición manual pasa por la validación de tabla.
        Authorization.Modify(false);
        exit(Number);
    end;

    procedure ValidateFiscalNo(Number: Code[20])
    var
        Index: Integer;
    begin
        if StrLen(Number) <> 19 then
            Error('El número fiscal debe tener el formato 000-000-00-00000000.');
        for Index := 1 to 19 do
            if Index in [4, 8, 11] then begin
                if Number[Index] <> '-' then
                    Error('Formato de número fiscal inválido.');
            end else
                if not (Number[Index] in ['0' .. '9']) then
                    Error('Formato de número fiscal inválido.');
    end;

    procedure ValidarClave(Clave: Code[37])
    var
        Posicion: Integer;
    begin
        if StrLen(Clave) <> 37 then
            Error('El CAI debe tener 37 caracteres con formato XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XX.');
        for Posicion := 1 to 37 do
            if Posicion in [7, 14, 21, 28, 35] then begin
                if Clave[Posicion] <> '-' then Error('La separación de los grupos del CAI no es válida.');
            end else
                if not (Clave[Posicion] in ['0' .. '9', 'A' .. 'Z']) then
                    Error('El CAI contiene caracteres no válidos.');
    end;
}
page 50101 "HN CAI Setup Part"
{
    PageType = ListPart;
    SourceTable = "HN CAI Authorization";
    Caption = 'Configuración CAI';
    AutoSplitKey = false;
    layout
    {
        area(Content)
        {
            repeater(Authorizations)
            {
                field(Tipo; Rec."Document Type") { ApplicationArea = All; }
                field(Code; Rec.Code) { ApplicationArea = All; ToolTip = 'Identificador de la autorización; cree un registro por cada autorización del SAR.'; }
                field(CAI; Rec.CAI) { ApplicationArea = All; ToolTip = 'Clave de autorización de impresión.'; }
                field(StartingNo; Rec."Starting No.") { ApplicationArea = All; ToolTip = 'Primer número autorizado, incluyendo establecimiento y punto de emisión.'; }
                field(EndingNo; Rec."Ending No.") { ApplicationArea = All; ToolTip = 'Último número autorizado.'; }
                field(NextNo; Rec."Next No.") { ApplicationArea = All; ToolTip = 'Próximo correlativo de la autorización. Al iniciar, verifique que no haya sido utilizado.'; }
                field(ValidFrom; Rec."Valid From") { ApplicationArea = All; ToolTip = 'Fecha inicial de vigencia.'; }
                field(ValidUntil; Rec."Valid Until") { ApplicationArea = All; ToolTip = 'Fecha límite de emisión.'; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; ToolTip = 'Permite emitir documentos con esta autorización.'; }
                field(LastNo; Rec."Last Issued No.") { ApplicationArea = All; ToolTip = 'Último número emitido por esta extensión.'; }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter("Document Type") <> '' then
            if StrPos(Rec.GetFilter("Document Type"), '|') = 0 then
                Rec."Document Type" := Rec.GetRangeMin("Document Type")
            else
                Rec."Document Type" := Rec."Document Type"::Factura;
    end;
}

page 50111 "HN CAI Authorizations"
{
    PageType = List;
    SourceTable = "HN CAI Authorization";
    Caption = 'Configuración CAI HN';
    ApplicationArea = All;
    AutoSplitKey = false;
    layout
    {
        area(Content)
        {
            repeater(Authorizations)
            {
                field(Tipo; Rec."Document Type") { ApplicationArea = All; }
                field(Code; Rec.Code) { ApplicationArea = All; ToolTip = 'Identificador de la autorización; cree un registro por cada autorización del SAR.'; }
                field(CAI; Rec.CAI) { ApplicationArea = All; ToolTip = 'Clave de autorización de impresión.'; }
                field(StartingNo; Rec."Starting No.") { ApplicationArea = All; ToolTip = 'Primer número autorizado, incluyendo establecimiento y punto de emisión.'; }
                field(EndingNo; Rec."Ending No.") { ApplicationArea = All; ToolTip = 'Último número autorizado.'; }
                field(NextNo; Rec."Next No.") { ApplicationArea = All; ToolTip = 'Próximo correlativo de la autorización. Al iniciar, verifique que no haya sido utilizado.'; }
                field(ValidFrom; Rec."Valid From") { ApplicationArea = All; ToolTip = 'Fecha inicial de vigencia.'; }
                field(ValidUntil; Rec."Valid Until") { ApplicationArea = All; ToolTip = 'Fecha límite de emisión.'; }
                field(Enabled; Rec.Enabled) { ApplicationArea = All; ToolTip = 'Permite emitir documentos con esta autorización.'; }
                field(LastNo; Rec."Last Issued No.") { ApplicationArea = All; ToolTip = 'Último número emitido por esta extensión.'; }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter("Document Type") <> '' then
            if StrPos(Rec.GetFilter("Document Type"), '|') = 0 then
                Rec."Document Type" := Rec.GetRangeMin("Document Type")
            else
                Rec."Document Type" := Rec."Document Type"::Factura;
    end;
}
