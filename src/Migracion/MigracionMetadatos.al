namespace INVTECH.Honduras;

using System.Reflection;
using System.Apps;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;

table 71102 "HN Migration Field"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;
    fields
    {
        field(1; "Source ID"; Integer) { Caption = 'Identificador de origen'; }
        field(2; "Source Name"; Text[30]) { Caption = 'Nombre del campo de origen'; }
        field(3; "Target ID"; Integer) { Caption = 'Identificador de destino'; }
    }
    keys { key(PK; "Source ID") { Clustered = true; } }
}

table 71103 "HN Metadata Migration Log"
{
    Caption = 'Verificación de migración de metadatos HN';
    DataClassification = SystemMetadata;
    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Número de movimiento'; AutoIncrement = true; }
        field(2; "Run ID"; Guid) { Caption = 'Identificador de ejecución'; }
        field(3; "Created At"; DateTime) { Caption = 'Fecha y hora de creación'; }
        field(4; "User ID"; Code[50]) { Caption = 'Usuario'; }
        field(5; "Table ID"; Integer) { Caption = 'Identificador de tabla'; }
        field(6; "Record ID"; RecordId) { Caption = 'Identificador de registro'; DataClassification = CustomerContent; }
        field(7; "Field ID"; Integer) { Caption = 'Identificador de campo'; }
        field(8; Detail; Text[250]) { Caption = 'Detalle'; }
        field(9; "Apply Changes"; Boolean) { Caption = 'Aplicar cambios'; }
        field(10; "Rows Checked"; Integer) { Caption = 'Registros verificados'; }
        field(11; "Fields To Copy"; Integer) { Caption = 'Campos por copiar'; }
        field(12; Conflicts; Integer) { Caption = 'Conflictos'; }
    }
    keys { key(PK; "Entry No.") { Clustered = true; } }
}

codeunit 71104 "HN Metadata Migration"
{
    // Esta herramienta requiere permisos de migración separados y se ejecuta expresamente.
    Permissions = tabledata "Sales Header" = rm, tabledata "Sales Line" = rm,
        tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm,
        tabledata "Sales Cr.Memo Header" = rm, tabledata "Sales Cr.Memo Line" = rm,
        tabledata Customer = rm;

    [CommitBehavior(CommitBehavior::Error)]
    procedure RunMigration(TableID: Integer; ApplyChanges: Boolean)
    var
        Ref: RecordRef;
        Map: Record "HN Migration Field" temporary;
        Mapping: Codeunit "HN Migration Field Map";
        SchemaConflicts: Integer;
        Rows: Integer;
        Changes: Integer;
        Conflicts: Integer;
        Changed: Boolean;
    begin
        CurrentRun := CreateGuid();
        Applying := ApplyChanges;
        Mapping.Fill(TableID, Map);
        Ref.Open(TableID);
        if ApplyChanges then
            Ref.LockTable();
        CheckSchema(Ref, Map, SchemaConflicts);
        if (SchemaConflicts = 0) and Ref.FindSet() then
            repeat
                Rows += 1;
                Changed := CompareRecord(Ref, Map, false, Changes, Conflicts);
            until Ref.Next() = 0;
        Conflicts += SchemaConflicts;
        if ApplyChanges and (Conflicts > 0) then
            Error('No se copió información: se detectaron %1 conflictos. Ejecute primero la verificación sin aplicar para conservar el detalle de incidencias.', Conflicts);
        if ApplyChanges and (Changes > 0) then begin
            Ref.FindSet();
            repeat
                Changed := CompareRecord(Ref, Map, true, Changes, Conflicts);
                if Changed then
                    Ref.Modify(false); // Solo copia metadatos propios autorizados, sin disparar validaciones ni registros de otros módulos.
            until Ref.Next() = 0;
        end;
        LogSummary(TableID, Rows, Changes, Conflicts);
        Ref.Close();
    end;

    local procedure CheckSchema(var Ref: RecordRef; var Map: Record "HN Migration Field" temporary; var Conflicts: Integer)
    var
        Source: FieldRef;
        Target: FieldRef;
        Metadata: Record Field;
        InstalledApp: Record "NAV App Installed App";
        ExpectedApp: Guid;
        EmptyID: RecordId;
    begin
        ExpectedApp := 'ba215fdf-ea75-4dcd-875e-70dd8c5c9ff8';
        InstalledApp.SetRange("App ID", ExpectedApp);
        if not InstalledApp.FindFirst() then begin
            Conflicts += 1;
            LogIssue(Ref.Number, EmptyID, 0, 'La localización origen debe permanecer instalada y sus datos disponibles durante la copia.');
            exit;
        end;
        if Map.FindSet() then
            repeat
                if not Ref.FieldExist(Map."Source ID") or not Ref.FieldExist(Map."Target ID") then begin
                    Conflicts += 1;
                    LogIssue(Ref.Number, EmptyID, Map."Source ID", 'Falta el campo de origen o de destino; revise la versión instalada y el mapeo.');
                end else begin
                    Source := Ref.Field(Map."Source ID");
                    Target := Ref.Field(Map."Target ID");
                    Metadata.Get(Ref.Number, Map."Source ID");
                    if (Source.Name <> Map."Source Name") or (Source.Type <> Target.Type) or
                       (Source.Length <> Target.Length) or
                       (Source.Class <> FieldClass::Normal) or (Target.Class <> FieldClass::Normal) or
                       ((Metadata."App Package ID" <> InstalledApp."Package ID") and
                        (Metadata."App Runtime Package ID" <> InstalledApp."Package ID")) then begin
                        Conflicts += 1;
                        LogIssue(Ref.Number, EmptyID, Map."Source ID", 'No coincide el propietario, nombre, tipo, longitud o clase del campo de origen. No se copiará.');
                    end;
                end;
            until Map.Next() = 0;
    end;

    local procedure CompareRecord(var Ref: RecordRef; var Map: Record "HN Migration Field" temporary; WriteValues: Boolean; var Changes: Integer; var Conflicts: Integer): Boolean
    var
        Source: FieldRef;
        Target: FieldRef;
        Changed: Boolean;
    begin
        if Map.FindSet() then
            repeat
                Source := Ref.Field(Map."Source ID");
                Target := Ref.Field(Map."Target ID");
                if not IsEmptyValue(Source) then
                    if IsEmptyValue(Target) then begin
                        if WriteValues then begin
                            Target.Value := Source.Value;
                            Changed := true;
                        end else
                            Changes += 1;
                    end else
                        if Format(Target.Value, 0, 9) <> Format(Source.Value, 0, 9) then begin
                            Conflicts += 1;
                            LogIssue(Ref.Number, Ref.RecordId, Map."Target ID", 'Origen y destino tienen valores diferentes. Se conserva el destino y se requiere conciliación.');
                        end;
            until Map.Next() = 0;
        exit(Changed);
    end;

    local procedure IsEmptyValue(Value: FieldRef): Boolean
    var
        TextValue: Text;
        NumberValue: Decimal;
        DateValue: Date;
        BooleanValue: Boolean;
    begin
        case Value.Type of
            FieldType::Code, FieldType::Text:
                begin TextValue := Value.Value; exit(TextValue = ''); end;
            FieldType::Decimal, FieldType::Integer:
                begin NumberValue := Value.Value; exit(NumberValue = 0); end;
            FieldType::Date:
                begin DateValue := Value.Value; exit(DateValue = 0D); end;
            FieldType::Boolean:
                begin BooleanValue := Value.Value; exit(not BooleanValue); end;
            else Error('Tipo no autorizado para migración.');
        end;
    end;

    local procedure LogIssue(TableID: Integer; RecordID: RecordId; FieldID: Integer; Detail: Text[250])
    var
        Log: Record "HN Metadata Migration Log";
    begin
        InitLog(Log, TableID);
        Log."Record ID" := RecordID;
        Log."Field ID" := FieldID;
        Log.Detail := Detail;
        Log.Insert();
    end;

    local procedure LogSummary(TableID: Integer; Rows: Integer; Changes: Integer; Conflicts: Integer)
    var
        Log: Record "HN Metadata Migration Log";
    begin
        InitLog(Log, TableID);
        Log.Detail := 'Resumen de la ejecución. La copia no modifica importes estándar, movimientos contables ni datos de origen.';
        Log."Rows Checked" := Rows;
        Log."Fields To Copy" := Changes;
        Log.Conflicts := Conflicts;
        Log.Insert();
    end;

    local procedure InitLog(var Log: Record "HN Metadata Migration Log"; TableID: Integer)
    begin
        Log.Init();
        Log."Run ID" := CurrentRun;
        Log."Created At" := CurrentDateTime();
        Log."User ID" := CopyStr(UserId(), 1, MaxStrLen(Log."User ID"));
        Log."Table ID" := TableID;
        Log."Apply Changes" := Applying;
    end;
    var
        CurrentRun: Guid;
        Applying: Boolean;
}

page 71102 "HN Migration Log"
{
    PageType = List;
    SourceTable = "HN Metadata Migration Log";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Verificación de migración HN';
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Log)
            {
                field(Date; Rec."Created At") { ApplicationArea = All; }
                field(Run; Rec."Run ID") { ApplicationArea = All; }
                field(TableID; Rec."Table ID") { ApplicationArea = All; }
                field(RecordID; Rec."Record ID") { ApplicationArea = All; }
                field(FieldID; Rec."Field ID") { ApplicationArea = All; }
                field(Detail; Rec.Detail) { ApplicationArea = All; }
                field(Apply; Rec."Apply Changes") { ApplicationArea = All; }
                field(Rows; Rec."Rows Checked") { ApplicationArea = All; }
                field(Fields; Rec."Fields To Copy") { ApplicationArea = All; }
                field(Conflicts; Rec.Conflicts) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Verify)
            {
                Caption = 'Verificar o copiar metadatos'; ApplicationArea = All; Image = Check;
                RunObject = report "HN Migrate POS Metadata";
            }
        }
    }
}

report 71100 "HN Migrate POS Metadata"
{
    Caption = 'Verificar o copiar metadatos POS';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                Caption = 'Opciones';
                    field(TableID; TableID) { ApplicationArea = All; Caption = 'Tabla: 18, 36, 37, 112, 113, 114 o 115'; }
                    field(Apply; ApplyChanges) { ApplicationArea = All; Caption = 'Aplicar copia'; ToolTip = 'Desactivado: solo verifica y registra conflictos. Activado: copia únicamente destinos vacíos si no hay conflictos.'; }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        Management: Codeunit "HN Metadata Migration";
    begin
        Management.RunMigration(TableID, ApplyChanges);
    end;
    var
        TableID: Integer;
        ApplyChanges: Boolean;
}

permissionset 71100 "HN MIGRATION"
{
    Assignable = true;
    Caption = 'Migración de metadatos HN';
    Permissions = tabledata "HN Metadata Migration Log" = RI,
        table "HN Metadata Migration Log" = X, table "HN Migration Field" = X,
        codeunit "HN Metadata Migration" = X, codeunit "HN Migration Field Map" = X,
        report "HN Migrate POS Metadata" = X, page "HN Migration Log" = X,
        tabledata "Sales Header" = Rm, tabledata "Sales Line" = Rm,
        tabledata "Sales Invoice Header" = Rm, tabledata "Sales Invoice Line" = Rm,
        tabledata "Sales Cr.Memo Header" = Rm, tabledata "Sales Cr.Memo Line" = Rm,
        tabledata Customer = Rm;
}
