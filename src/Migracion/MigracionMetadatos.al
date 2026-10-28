namespace INVTECH.Honduras;

using System.Reflection;
using System.Apps;
using System.Utilities;
using System.Security.Encryption;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;
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
        field(4; "Target Name"; Text[30]) { Caption = 'Nombre del campo de destino'; }
        field(5; "Target Table ID"; Integer) { Caption = 'Tabla de destino'; }
        field(6; "Reference Only"; Boolean) { Caption = 'Referencia anterior'; }
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
        field(13; Fase; Text[30]) { Caption = 'Fase'; }
        field(14; Resumen; Boolean) { Caption = 'Resumen'; }
        field(15; Comparados; Integer) { Caption = 'Campos comparados'; }
        field(16; Coincidentes; Integer) { Caption = 'Campos coincidentes'; }
        field(17; "Origen vacio"; Integer) { Caption = 'Origen vacío'; }
        field(18; Copiados; Integer) { Caption = 'Campos copiados'; }
        field(19; Resultado; Enum "HN Resultado Migracion") { Caption = 'Resultado'; }
        field(20; Modo; Enum "HN Modo Migracion") { Caption = 'Modo'; }
        field(21; "Paquete origen"; Guid) { Caption = 'Paquete de origen'; }
        field(22; "Paquete destino"; Guid) { Caption = 'Paquete de destino'; }
        field(23; "Copia de referencia"; Guid) { Caption = 'Copia de referencia'; }
        field(24; "Tabla solicitada"; Integer) { Caption = 'Tabla solicitada (0 = todas)'; }
        field(25; "Version mapa"; Code[20]) { Caption = 'Versión del mapa'; }
    }
    keys { key(PK; "Entry No.") { Clustered = true; } }
}

codeunit 71104 "HN Metadata Migration"
{
    // Esta herramienta requiere permisos de migración separados y se ejecuta expresamente.
    Permissions = tabledata "Sales Header" = rm, tabledata "Sales Line" = rm,
        tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm,
        tabledata "Sales Cr.Memo Header" = rm, tabledata "Sales Cr.Memo Line" = rm,
        tabledata Customer = rm, tabledata Vendor = rm, tabledata "Purchase Header" = rm,
        tabledata "Purchase Line" = rm, tabledata "Purch. Inv. Header" = rm, tabledata "Purch. Inv. Line" = rm,
        tabledata "Company Information" = rm;

    // Se conserva la entrada anterior para integraciones ya preparadas.
    [CommitBehavior(CommitBehavior::Error)]
    procedure RunMigration(TableID: Integer; ApplyChanges: Boolean)
    var Modo: Enum "HN Modo Migracion"; Ejecucion: Guid;
    begin
        if ApplyChanges then Modo := Modo::Copiar else Modo := Modo::Verificar;
        Ejecucion := Ejecutar(Modo, TableID);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Ejecutar(Modo: Enum "HN Modo Migracion"; TableID: Integer): Guid
    var
        Tablas: List of [Integer];
        Tabla: Integer;
        Conflictos: Integer;
        Pendientes: Integer;
        Filas: Integer;
        Comparados: Integer;
        Iguales: Integer;
        Vacios: Integer;
        Copiados: Integer;
        TotalConflictos: Integer;
        TotalPendientes: Integer;
        TotalCopiados: Integer;
        TotalFilas: Integer; TotalComparados: Integer; TotalIguales: Integer; TotalVacios: Integer;
        Mapa: Record "HN Migration Field" temporary;
        GestorMapa: Codeunit "HN Migration Field Map";
        Vacio: RecordId;
    begin
        Clear(TotalConflictos);
        Clear(PaqueteOrigen); Clear(PaqueteDestino);
        CurrentRun := CreateGuid();
        Applying := Modo = Modo::Copiar;
        ModoActual := Modo;
        TablaSolicitada := TableID;
        Clear(CopiaReferencia);
        if Modo = Modo::Validar then CopiaReferencia := BuscarCopiaAnterior(TableID);
        if TableID = 0 then begin
            Tablas.Add(18); Tablas.Add(23); Tablas.Add(36); Tablas.Add(37); Tablas.Add(38); Tablas.Add(39); Tablas.Add(79);
            Tablas.Add(112); Tablas.Add(113); Tablas.Add(114); Tablas.Add(115); Tablas.Add(122); Tablas.Add(123);
            Tablas.Add(60450); Tablas.Add(60489); Tablas.Add(60451); Tablas.Add(60452);
            Tablas.Add(60459); Tablas.Add(60510); Tablas.Add(60477); Tablas.Add(60457);
        end else begin
            GestorMapa.Fill(TableID, Mapa);
            Tablas.Add(TableID);
        end;
        FaseActual := 'VERIFICACIÓN PREVIA';
        if Modo = Modo::Validar then FaseActual := 'VALIDACIÓN POSTERIOR';
        // Revisar todas las tablas seleccionadas antes de tocar el primer destino.
        // En copia, los bloqueos se conservan hasta terminar toda la transacción.
        foreach Tabla in Tablas do begin
            RevisarTabla(Tabla, Applying, Filas, Pendientes, Conflictos, Comparados, Iguales, Vacios);
            TotalFilas += Filas; TotalComparados += Comparados; TotalIguales += Iguales; TotalVacios += Vacios;
            TotalConflictos += Conflictos;
            TotalPendientes += Pendientes;
            LogSummary(Tabla, Filas, Pendientes, Conflictos, Comparados, Iguales, Vacios, 0);
        end;
        if Applying and (TotalConflictos = 0) then begin
            foreach Tabla in Tablas do begin
                Copiados := CopiarTabla(Tabla);
                TotalCopiados += Copiados;
                FaseActual := 'VALIDACIÓN AUTOMÁTICA';
                RevisarTabla(Tabla, true, Filas, Pendientes, Conflictos, Comparados, Iguales, Vacios);
                if (Pendientes <> 0) or (Conflictos <> 0) then
                    Error('La validación de la tabla %1 detectó %2 pendientes y %3 conflictos. Se revierte toda la copia de esta ejecución.', Tabla, Pendientes, Conflictos);
                LogSummary(Tabla, Filas, Pendientes, Conflictos, Comparados, Iguales, Vacios, Copiados);
            end;
            TotalPendientes := 0;
        end;
        if (Modo = Modo::Validar) and IsNullGuid(CopiaReferencia) then begin
            TotalConflictos += 1;
            LogIssue(0, Vacio, 0, 'No se encontró una copia correcta previa con el mismo alcance. Ejecute Verificar y luego Copiar; una comparación aislada no acredita una ejecución de migración.');
        end;
        FaseActual := 'RESULTADO DE EJECUCIÓN';
        LogSummary(0, TotalFilas, TotalPendientes, TotalConflictos, TotalComparados, TotalIguales + TotalCopiados, TotalVacios, TotalCopiados);
        exit(CurrentRun);
    end;

    local procedure BuscarCopiaAnterior(Tabla: Integer): Guid
    var Registro: Record "HN Metadata Migration Log"; Vacio: Guid; Gestor: Codeunit "HN Migration Field Map";
    begin
        Registro.SetRange("Table ID", 0);
        Registro.SetRange(Resumen, true);
        Registro.SetRange("Version mapa", Gestor.VersionMap());
        Registro.SetRange(Modo, "HN Modo Migracion"::Copiar);
        Registro.SetRange(Resultado, "HN Resultado Migracion"::Correcto);
        Registro.SetFilter("Tabla solicitada", '%1|%2', 0, Tabla);
        if Registro.FindLast() then exit(Registro."Run ID");
        exit(Vacio);
    end;

    procedure PrepararDestino(var Origen: RecordRef; var Destino: RecordRef; var Mapa: Record "HN Migration Field" temporary): Boolean
    var Clave: KeyRef; CampoOrigen: FieldRef; CampoDestino: FieldRef; Indice: Integer; Identidad: RecordId;
    begin
        if Origen.Number = Destino.Number then exit(Destino.Get(Origen.RecordId));
        Destino.Init();
        Clave := Origen.KeyIndex(1);
        for Indice := 1 to Clave.FieldCount do begin
            CampoOrigen := Clave.FieldIndex(Indice);
            Mapa.Get(CampoOrigen.Number);
            CampoDestino := Destino.Field(Mapa."Target ID");
            CampoDestino.Value := CampoOrigen.Value;
        end;
        Identidad := Destino.RecordId;
        if Destino.Get(Identidad) then exit(true);
        Destino.Init();
        Clave := Destino.KeyIndex(1);
        for Indice := 1 to Clave.FieldCount do begin
            CampoDestino := Clave.FieldIndex(Indice);
            case CampoDestino.Type of
                FieldType::Code, FieldType::Text: CampoDestino.Value := '';
                FieldType::Integer, FieldType::Option: CampoDestino.Value := 0;
                else Error('Tipo de clave no admitido para la copia de referencias.');
            end;
        end;
        exit(false);
    end;

    local procedure RevisarTabla(TableID: Integer; Bloquear: Boolean; var Filas: Integer; var Pendientes: Integer; var Conflictos: Integer; var Comparados: Integer; var Iguales: Integer; var Vacios: Integer)
    var
        Ref: RecordRef; Destino: RecordRef; Mapa: Record "HN Migration Field" temporary; GestorMapa: Codeunit "HN Migration Field Map";
        Cambio: Boolean; Existe: Boolean; Antes: Integer;
    begin
        Clear(Filas); Clear(Pendientes); Clear(Conflictos); Clear(Comparados); Clear(Iguales); Clear(Vacios);
        GestorMapa.Fill(TableID, Mapa);
        Ref.Open(TableID); Destino.Open(GestorMapa.TargetTable(TableID));
        if Bloquear then begin Ref.LockTable(); Destino.LockTable(); end;
        CheckSchema(Ref, Destino, Mapa, Conflictos);
        if (Conflictos = 0) and Ref.FindSet() then repeat
            Filas += 1;
            Existe := PrepararDestino(Ref, Destino, Mapa);
            Antes := Pendientes;
            Cambio := CompareRecord(Ref, Destino, Mapa, false, Pendientes, Conflictos, Comparados, Iguales, Vacios);
            if not Existe and (Antes = Pendientes) then begin
                Pendientes += 1;
                if ModoActual = ModoActual::Validar then
                    LogIssue(TableID, Ref.RecordId, 0, 'La fila de referencia todavía no existe en destino.');
            end;
        until Ref.Next() = 0;
        Destino.Close(); Ref.Close();
    end;

    local procedure CopiarTabla(TableID: Integer): Integer
    var
        Ref: RecordRef; Destino: RecordRef; Mapa: Record "HN Migration Field" temporary; GestorMapa: Codeunit "HN Migration Field Map";
        Copiados: Integer; Conflictos: Integer; Comparados: Integer; Iguales: Integer; Vacios: Integer; Existe: Boolean; Cambio: Boolean;
    begin
        GestorMapa.Fill(TableID, Mapa);
        Ref.Open(TableID); Destino.Open(GestorMapa.TargetTable(TableID));
        Ref.LockTable(); Destino.LockTable();
        CheckSchema(Ref, Destino, Mapa, Conflictos);
        if Conflictos <> 0 then Error('El esquema de la tabla %1 cambió durante la ejecución. No se conserva ninguna copia parcial.', TableID);
        if Ref.FindSet() then repeat
            Existe := PrepararDestino(Ref, Destino, Mapa);
            Cambio := CompareRecord(Ref, Destino, Mapa, true, Copiados, Conflictos, Comparados, Iguales, Vacios);
            if not Existe then Destino.Insert(false)
            else if Cambio then Destino.Modify(false);
        until Ref.Next() = 0;
        if Conflictos <> 0 then Error('Se detectaron diferencias al copiar la tabla %1. Se revierte toda esta ejecución.', TableID);
        Destino.Close(); Ref.Close();
        exit(Copiados);
    end;

    local procedure CheckSchema(var Ref: RecordRef; var Destino: RecordRef; var Map: Record "HN Migration Field" temporary; var Conflicts: Integer)
    var
        Source: FieldRef;
        Target: FieldRef;
        Metadata: Record Field;
        InstalledApp: Record "NAV App Installed App";
        ExpectedApp: Guid;
        Modulo: ModuleInfo;
        DestinoMetadata: Record Field;
        EmptyID: RecordId;
    begin
        NavApp.GetCurrentModuleInfo(Modulo);
        PaqueteDestino := Modulo.PackageId;
        ExpectedApp := 'ba215fdf-ea75-4dcd-875e-70dd8c5c9ff8';
        InstalledApp.SetRange("App ID", ExpectedApp);
        if not InstalledApp.FindFirst() then begin
            Conflicts += 1;
            LogIssue(Ref.Number, EmptyID, 0, 'La localización origen debe permanecer instalada y sus datos disponibles durante la copia.');
            exit;
        end;
        PaqueteOrigen := InstalledApp."Package ID";
        if Map.FindSet() then
            repeat
                if not Ref.FieldExist(Map."Source ID") or not Destino.FieldExist(Map."Target ID") then begin
                    Conflicts += 1;
                    LogIssue(Ref.Number, EmptyID, Map."Source ID", 'Falta el campo de origen o de destino; revise la versión instalada y el mapeo.');
                end else begin
                    Source := Ref.Field(Map."Source ID");
                    Target := Destino.Field(Map."Target ID");
                    Metadata.Get(Ref.Number, Map."Source ID");
                    DestinoMetadata.Get(Destino.Number, Map."Target ID");
                    if (Map."Target Table ID" <> Destino.Number) or (Source.Name <> Map."Source Name") or (Target.Name <> Map."Target Name") or
                       ((Ref.Number = Destino.Number) and (Map."Source ID" = Map."Target ID")) or
                       ((DestinoMetadata."App Package ID" <> Modulo.PackageId) and
                        (DestinoMetadata."App Runtime Package ID" <> Modulo.PackageId)) or
                       (Source.Type <> Target.Type) or
                       ((Source.Type <> FieldType::Blob) and (Source.Length <> Target.Length)) or
                       (Source.Class <> FieldClass::Normal) or (Target.Class <> FieldClass::Normal) or
                       ((Metadata."App Package ID" <> InstalledApp."Package ID") and
                        (Metadata."App Runtime Package ID" <> InstalledApp."Package ID")) then begin
                        Conflicts += 1;
                        LogIssue(Ref.Number, EmptyID, Map."Source ID", 'No coincide el propietario, nombre, tipo, longitud o clase del campo de origen. No se copiará.');
                    end;
                    if (Source.Type = FieldType::Option) and (Target.Type = FieldType::Option) then begin
                        if Source.IsEnum() <> Target.IsEnum() then begin
                            Conflicts += 1;
                            LogIssue(Ref.Number, EmptyID, Map."Source ID", 'El origen y el destino no usan la misma clase de opción o enumeración.');
                        end else
                            if not Source.IsEnum() then
                                if Source.OptionMembers <> Target.OptionMembers then begin
                                    Conflicts += 1;
                                    LogIssue(Ref.Number, EmptyID, Map."Source ID", 'Las opciones del origen y destino tienen distinto orden o significado.');
                                end;
                    end;
                end;
            until Map.Next() = 0;
    end;

    local procedure CompareRecord(var Ref: RecordRef; var Destino: RecordRef; var Map: Record "HN Migration Field" temporary; WriteValues: Boolean; var Changes: Integer; var Conflicts: Integer; var Comparados: Integer; var Iguales: Integer; var Vacios: Integer): Boolean
    var Source: FieldRef; Target: FieldRef; Changed: Boolean; Estado: Enum "HN Comparacion Migracion"; Detalle: Record "HN Metadata Migration Log";
    begin
        if Map.FindSet() then repeat
            Source := Ref.Field(Map."Source ID");
            Target := Destino.Field(Map."Target ID");
            Comparados += 1;
            if Map."Reference Only" then Estado := CompararReferencia(Source, Target, WriteValues)
            else Estado := CompararCampo(Source, Target, WriteValues);
            case Estado of
                Estado::OrigenVacio: Vacios += 1;
                Estado::Igual: Iguales += 1;
                Estado::Pendiente:
                    begin
                        Changes += 1;
                        if (not WriteValues) and (ModoActual = ModoActual::Validar) then begin
                            InitLog(Detalle, Ref.Number);
                            Detalle."Record ID" := Ref.RecordId;
                            Detalle."Field ID" := Map."Target ID";
                            Detalle.Detail := 'El origen tiene información y el destino sigue vacío. La validación posterior no copia ni corrige este registro.';
                            Detalle.Insert();
                        end;
                        if WriteValues then begin
                            Changed := true;
                        end;
                    end;
                Estado::Conflicto:
                    begin
                        Conflicts += 1;
                        LogIssue(Ref.Number, Ref.RecordId, Map."Target ID", 'Origen y destino tienen valores diferentes. Se conserva el destino y se requiere conciliación.');
                    end;
            end;
        until Map.Next() = 0;
        exit(Changed);
    end;

    procedure CompararCampo(Origen: FieldRef; var Destino: FieldRef; Aplicar: Boolean): Enum "HN Comparacion Migracion"
    begin exit(CompararValor(Origen, Destino, Aplicar, false)); end;

    procedure CompararReferencia(Origen: FieldRef; var Destino: FieldRef; Aplicar: Boolean): Enum "HN Comparacion Migracion"
    begin exit(CompararValor(Origen, Destino, Aplicar, true)); end;

    local procedure CompararValor(Origen: FieldRef; var Destino: FieldRef; Aplicar: Boolean; Estricto: Boolean): Enum "HN Comparacion Migracion"
    var
        Estado: Enum "HN Comparacion Migracion"; VacioOrigen: Boolean; VacioDestino: Boolean; Iguales: Boolean;
        BlobOrigen: Codeunit "Temp Blob"; BlobDestino: Codeunit "Temp Blob";
        Criptografia: Codeunit "Cryptography Management"; EntradaOrigen: InStream; EntradaDestino: InStream;
    begin
        if (Origen.Type <> Destino.Type) or ((Origen.Type <> FieldType::Blob) and (Origen.Length <> Destino.Length)) or
           (Origen.Class <> FieldClass::Normal) or (Destino.Class <> FieldClass::Normal) then
            Error('No se puede copiar entre campos de distinto tipo, longitud o clase.');
        VacioOrigen := IsEmptyValue(Origen); VacioDestino := IsEmptyValue(Destino);
        if Origen.Type = FieldType::Blob then begin
            BlobOrigen.FromFieldRef(Origen); BlobDestino.FromFieldRef(Destino);
            if not VacioOrigen and not VacioDestino then begin
                BlobOrigen.CreateInStream(EntradaOrigen); BlobDestino.CreateInStream(EntradaDestino);
                Iguales := Criptografia.GenerateHash(EntradaOrigen, 2) = Criptografia.GenerateHash(EntradaDestino, 2);
            end else Iguales := VacioOrigen and VacioDestino;
        end else Iguales := Format(Origen.Value, 0, 9) = Format(Destino.Value, 0, 9);
        if Estricto and VacioOrigen and not VacioDestino then exit(Estado::Conflicto);
        Estado := ClasificarValores(VacioOrigen, VacioDestino, Iguales);
        if Aplicar and (Estado = Estado::Pendiente) then
            if Origen.Type = FieldType::Blob then BlobOrigen.ToFieldRef(Destino)
            else Destino.Value := Origen.Value;
        exit(Estado);
    end;

    procedure ClasificarValores(OrigenVacio: Boolean; DestinoVacio: Boolean; ValoresIguales: Boolean): Enum "HN Comparacion Migracion"
    begin
        if OrigenVacio then exit("HN Comparacion Migracion"::OrigenVacio);
        if ValoresIguales then exit("HN Comparacion Migracion"::Igual);
        if DestinoVacio then exit("HN Comparacion Migracion"::Pendiente);
        exit("HN Comparacion Migracion"::Conflicto);
    end;

    procedure ObtenerResultado(Pendientes: Integer; Conflictos: Integer): Enum "HN Resultado Migracion"
    begin
        if Conflictos > 0 then exit("HN Resultado Migracion"::Bloqueado);
        if Pendientes > 0 then exit("HN Resultado Migracion"::Pendiente);
        exit("HN Resultado Migracion"::Correcto);
    end;

    local procedure IsEmptyValue(Value: FieldRef): Boolean
    var
        TextValue: Text;
        NumberValue: Decimal;
        DateValue: Date;
        BooleanValue: Boolean;
        GuidValue: Guid;
        OptionValue: Integer;
        BlobValue: Codeunit "Temp Blob";
    begin
        if Value.Type = FieldType::Blob then begin BlobValue.FromFieldRef(Value); exit(not BlobValue.HasValue()); end;
        case Value.Type of
            FieldType::Code, FieldType::Text:
                begin TextValue := Value.Value; exit(TextValue = ''); end;
            FieldType::Decimal, FieldType::Integer:
                begin NumberValue := Value.Value; exit(NumberValue = 0); end;
            FieldType::Date:
                begin DateValue := Value.Value; exit(DateValue = 0D); end;
            FieldType::Guid:
                begin GuidValue := Value.Value; exit(IsNullGuid(GuidValue)); end;
            FieldType::Option:
                begin OptionValue := Value.Value; exit(OptionValue = 0); end;
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
        Log.Resultado := Log.Resultado::Bloqueado;
        Log.Insert();
    end;

    local procedure LogSummary(TableID: Integer; Rows: Integer; Changes: Integer; Conflicts: Integer; Comparados: Integer; Iguales: Integer; Vacios: Integer; Copiados: Integer)
    var
        Log: Record "HN Metadata Migration Log";
        Mapa: Record "HN Migration Field" temporary;
        GestorMapa: Codeunit "HN Migration Field Map";
    begin
        InitLog(Log, TableID);
        Log.Detail := 'Resumen de la ejecución. La copia no modifica importes estándar, movimientos contables ni datos de origen.';
        Log.Resumen := true;
        Log.Comparados := Comparados;
        Log.Coincidentes := Iguales;
        Log."Origen vacio" := Vacios;
        Log.Copiados := Copiados;
        Log.Resultado := ObtenerResultado(Changes, Conflicts);
        if TableID <> 0 then begin
            GestorMapa.Fill(TableID, Mapa);
            if Mapa.IsEmpty() and (Conflicts = 0) then begin
                Log.Resultado := Log.Resultado::SinMapa;
                Log.Detail := 'Esta tabla no tiene correspondencias confirmadas en el mapa actual. No se copió ni se acredita la migración de sus datos.';
            end;
        end;
        Log."Rows Checked" := Rows;
        Log."Fields To Copy" := Changes;
        Log.Conflicts := Conflicts;
        Log.Insert();
    end;

    procedure ExportarResultado(Ejecucion: Guid)
    var
        Registro: Record "HN Metadata Migration Log";
        Temporal: Codeunit "Temp Blob";
        Salida: OutStream;
        Entrada: InStream;
        Nombre: Text;
    begin
        Registro.SetRange("Run ID", Ejecucion);
        if Registro.IsEmpty() then Error('No hay registros para la ejecución seleccionada.');
        Temporal.CreateOutStream(Salida, TextEncoding::UTF8);
        Salida.WriteText('Empresa;Ejecucion;Fecha;Fase;Tabla;Registro;Campo;Resumen;Resultado;Filas;Comparados;Coincidentes;OrigenVacio;Pendientes;Copiados;Conflictos;PaqueteOrigen;PaqueteDestino;CopiaReferencia;TablaSolicitada;VersionMapa;Detalle');
        Salida.WriteText();
        if Registro.FindSet() then repeat
            Salida.WriteText(CeldaCSV(CompanyName()) + ';' + CeldaCSV(Format(Registro."Run ID")) + ';' + CeldaCSV(Format(Registro."Created At", 0, 9)) + ';' +
                CeldaCSV(Registro.Fase) + ';' + Format(Registro."Table ID", 0, 9) + ';' + CeldaCSV(Format(Registro."Record ID")) + ';' + Format(Registro."Field ID", 0, 9) + ';' +
                CeldaCSV(Format(Registro.Resumen)) + ';' + CeldaCSV(Format(Registro.Resultado)) + ';' + Format(Registro."Rows Checked", 0, 9) + ';' +
                Format(Registro.Comparados, 0, 9) + ';' + Format(Registro.Coincidentes, 0, 9) + ';' + Format(Registro."Origen vacio", 0, 9) + ';' +
                Format(Registro."Fields To Copy", 0, 9) + ';' + Format(Registro.Copiados, 0, 9) + ';' + Format(Registro.Conflicts, 0, 9) + ';' +
                CeldaCSV(Format(Registro."Paquete origen")) + ';' + CeldaCSV(Format(Registro."Paquete destino")) + ';' + CeldaCSV(Format(Registro."Copia de referencia")) + ';' + Format(Registro."Tabla solicitada", 0, 9) + ';' + CeldaCSV(Registro."Version mapa") + ';' + CeldaCSV(Registro.Detail));
            Salida.WriteText();
        until Registro.Next() = 0;
        Temporal.CreateInStream(Entrada, TextEncoding::UTF8);
        Nombre := 'Validacion_migracion_HN_' + DelChr(Format(Ejecucion), '=', '{}') + '.csv';
        DownloadFromStream(Entrada, '', '', '', Nombre);
    end;

    local procedure CeldaCSV(Valor: Text): Text
    begin
        // También impedir fórmulas al abrir identificadores y texto en una hoja de cálculo.
        if Valor <> '' then
            if CopyStr(Valor, 1, 1) in ['=', '+', '-', '@'] then Valor := '''' + Valor;
        exit('"' + Valor.Replace('"', '""') + '"');
    end;

    local procedure InitLog(var Log: Record "HN Metadata Migration Log"; TableID: Integer)
    var Gestor: Codeunit "HN Migration Field Map";
    begin
        Log.Init();
        Log."Version mapa" := Gestor.VersionMap();
        Log."Copia de referencia" := CopiaReferencia;
        Log."Tabla solicitada" := TablaSolicitada;
        Log.Fase := FaseActual;
        Log.Modo := ModoActual;
        Log."Paquete origen" := PaqueteOrigen;
        Log."Paquete destino" := PaqueteDestino;
        Log."Run ID" := CurrentRun;
        Log."Created At" := CurrentDateTime();
        Log."User ID" := CopyStr(UserId(), 1, MaxStrLen(Log."User ID"));
        Log."Table ID" := TableID;
        Log."Apply Changes" := Applying;
    end;
    var
        CurrentRun: Guid;
        Applying: Boolean;
        ModoActual: Enum "HN Modo Migracion";
        FaseActual: Text[30];
        PaqueteOrigen: Guid;
        PaqueteDestino: Guid;
        CopiaReferencia: Guid;
        TablaSolicitada: Integer;
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
                field(CopiaReferencia; Rec."Copia de referencia") { ApplicationArea = All; }
                field(VersionMapa; Rec."Version mapa") { ApplicationArea = All; }
                field(Alcance; Rec."Tabla solicitada") { ApplicationArea = All; }
                field(Fase; Rec.Fase) { ApplicationArea = All; }
                field(Resultado; Rec.Resultado) { ApplicationArea = All; }
                field(Resumen; Rec.Resumen) { ApplicationArea = All; }
                field(Modo; Rec.Modo) { ApplicationArea = All; }
                field(Copiados; Rec.Copiados) { ApplicationArea = All; }
                field(Iguales; Rec.Coincidentes) { ApplicationArea = All; }
                field(Comparados; Rec.Comparados) { ApplicationArea = All; }
                field(OrigenVacio; Rec."Origen vacio") { ApplicationArea = All; }
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
            action(Exportar)
            {
                Caption = 'Exportar ejecución a CSV'; ApplicationArea = All; Image = Export;
                trigger OnAction()
                var Gestion: Codeunit "HN Metadata Migration";
                begin Gestion.ExportarResultado(Rec."Run ID"); end;
            }
            action(ValidarTodo)
            {
                Caption = 'Validar referencias copiadas'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var Gestion: Codeunit "HN Metadata Migration"; Ejecucion: Guid;
                begin
                    Ejecucion := Gestion.Ejecutar("HN Modo Migracion"::Validar, 0);
                    CurrPage.Update(false);
                    Message('Validación %1 finalizada. Revise el resultado y exporte la ejecución. No se copió información.', Ejecucion);
                end;
            }
            action(Verify)
            {
                Caption = 'Preparar, copiar o validar migración'; ApplicationArea = All; Image = Check;
                RunObject = report "HN Migrate POS Metadata";
            }
        }
    }
}

report 71100 "HN Migrate POS Metadata"
{
    Caption = 'Preparar, copiar o validar migración HN';
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
                    label(Alcance)
                    {
                        ApplicationArea = All;
                        Caption = 'Alcance actual: Referencias de compras y ventas, proveedores y catálogos anteriores. Solo copia valores; no activa autorizaciones ni registra documentos.';
                    }
                    field(Modo; Modo) { ApplicationArea = All; Caption = 'Operación'; ToolTip = 'Verificar no copia; copiar revisa todo antes de escribir y valida automáticamente; validar posterior compara origen y destino sin copiar.'; }
                    field(TableID; TableID) { ApplicationArea = All; Caption = 'Tabla (0 = conjunto del mapa)'; ToolTip = '0 para todo el mapa ampliado de referencias. También puede seleccionar una tabla de origen del mapa.'; }
                }
            }
        }
    }
    trigger OnPreReport()
    var
        Management: Codeunit "HN Metadata Migration";
        Ejecucion: Guid;
    begin
        Ejecucion := Management.Ejecutar(Modo, TableID);
        Message('Ejecución %1 finalizada. Revise RESULTADO DE EJECUCIÓN en Verificación de migración HN. CORRECTO acredita únicamente los metadatos del mapa seleccionado; no autoriza retirar la extensión anterior.', Ejecucion);
    end;
    var
        TableID: Integer;
        Modo: Enum "HN Modo Migracion";
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
        table "HN Valor Referencia" = X, page "HN Valores Referencia" = X, codeunit "HN Consultar Referencias" = X,
        tabledata Vendor = Rm, tabledata "Purchase Header" = Rm, tabledata "Purchase Line" = Rm,
        tabledata "Purch. Inv. Header" = Rm, tabledata "Purch. Inv. Line" = Rm, tabledata "Company Information" = Rm,
        tabledata Customer = Rm,
        tabledata "NAV App Installed App" = R, tabledata Field = R,
        tabledata "HN Ref Catalogo 60450" = RIM,
        table "HN Ref Catalogo 60450" = X,
        page "HN Ref Lista 60450" = X,
        tabledata "HN Ref Catalogo 60489" = RIM,
        table "HN Ref Catalogo 60489" = X,
        page "HN Ref Lista 60489" = X,
        tabledata "HN Ref Catalogo 60451" = RIM,
        table "HN Ref Catalogo 60451" = X,
        page "HN Ref Lista 60451" = X,
        tabledata "HN Ref Catalogo 60452" = RIM,
        table "HN Ref Catalogo 60452" = X,
        page "HN Ref Lista 60452" = X,
        tabledata "HN Ref Catalogo 60459" = RIM,
        table "HN Ref Catalogo 60459" = X,
        page "HN Ref Lista 60459" = X,
        tabledata "HN Ref Catalogo 60510" = RIM,
        table "HN Ref Catalogo 60510" = X,
        page "HN Ref Lista 60510" = X,
        tabledata "HN Ref Catalogo 60477" = RIM,
        table "HN Ref Catalogo 60477" = X,
        page "HN Ref Lista 60477" = X,
        tabledata "HN Ref Catalogo 60457" = RIM,
        table "HN Ref Catalogo 60457" = X,
        page "HN Ref Lista 60457" = X;
}
