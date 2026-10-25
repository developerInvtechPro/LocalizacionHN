namespace INVTECH.Honduras;

// Este registro conserva los datos fiscales emitidos/recibidos sin depender de catálogos futuros.
table 71112 "HN Movimiento Fiscal"
{
    Caption = 'Movimiento fiscal HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "No. movimiento"; Integer) { Caption = 'N.º movimiento'; AutoIncrement = true; }
        field(2; "Es compra"; Boolean) { Caption = 'Documento de compra'; }
        field(3; "Tipo documento"; Enum "HN Fiscal Document Type") { Caption = 'Tipo de documento'; }
        field(4; "No. documento"; Code[20]) { Caption = 'Documento registrado'; }
        field(5; "Numero fiscal"; Code[20]) { Caption = 'Número fiscal'; }
        field(6; CAI; Code[37]) { Caption = 'CAI'; }
        field(7; "Codigo autorizacion"; Code[20]) { Caption = 'Código de autorización'; }
        field(8; "Fecha emision"; Date) { Caption = 'Fecha de emisión'; }
        field(9; "Fecha registro"; Date) { Caption = 'Fecha de registro'; }
        field(10; "No. tercero"; Code[20]) { Caption = 'Cliente o proveedor'; }
        field(11; "Nombre tercero"; Text[100]) { Caption = 'Nombre del cliente o proveedor'; }
        field(12; "Rango inicial"; Code[20]) { Caption = 'Rango inicial'; }
        field(13; "Rango final"; Code[20]) { Caption = 'Rango final'; }
        field(14; Vencimiento; Date) { Caption = 'Fecha límite de emisión'; }
        field(15; Usuario; Text[100]) { Caption = 'Usuario'; DataClassification = EndUserIdentifiableInformation; }
        field(16; "Registrado el"; DateTime) { Caption = 'Registrado el'; }
    }
    keys
    {
        key(PK; "No. movimiento") { Clustered = true; }
        key(Fiscal; "Es compra", "Numero fiscal", "No. tercero") { Unique = true; }
        key(Documento; "Es compra", "No. documento") { }
    }
    trigger OnModify()
    begin
        Error('Los movimientos fiscales registrados no se pueden modificar.');
    end;
    trigger OnDelete()
    begin
        Error('Los movimientos fiscales registrados no se pueden eliminar.');
    end;
    trigger OnRename()
    begin
        Error('Los movimientos fiscales registrados no se pueden renombrar.');
    end;
}

page 71112 "HN Movimientos Fiscales"
{
    Caption = 'Movimientos fiscales HN';
    PageType = List;
    SourceTable = "HN Movimiento Fiscal";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Movimientos)
            {
                field(Numero; Rec."No. movimiento") { ApplicationArea = All; }
                field(Compra; Rec."Es compra") { ApplicationArea = All; }
                field(Tipo; Rec."Tipo documento") { ApplicationArea = All; }
                field(Documento; Rec."No. documento") { ApplicationArea = All; }
                field(Fiscal; Rec."Numero fiscal") { ApplicationArea = All; }
                field(Tercero; Rec."No. tercero") { ApplicationArea = All; }
                field(Nombre; Rec."Nombre tercero") { ApplicationArea = All; }
                field(Fecha; Rec."Fecha emision") { ApplicationArea = All; }
                field(Registro; Rec."Fecha registro") { ApplicationArea = All; }
                field(CAI; Rec.CAI) { ApplicationArea = All; }
                field(Inicio; Rec."Rango inicial") { ApplicationArea = All; }
                field(Fin; Rec."Rango final") { ApplicationArea = All; }
                field(Vencimiento; Rec.Vencimiento) { ApplicationArea = All; }
                field(Usuario; Rec.Usuario) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Imprimir)
            {
                Caption = 'Imprimir movimientos fiscales'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Seleccion: Record "HN Movimiento Fiscal";
                begin
                    CurrPage.SetSelectionFilter(Seleccion);
                    Report.RunModal(Report::"HN Inf. Movimientos Fiscales", true, false, Seleccion);
                end;
            }
        }
    }
}
