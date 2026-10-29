namespace INVTECH.Honduras;
using System.Upgrade;

codeunit 71118 "HN Upgrade Referencias"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        Etiquetas: Codeunit "Upgrade Tag";
        Pares: Dictionary of [Integer, Integer];
    begin
        if Etiquetas.HasUpgradeTag('INVTECH-REFERENCIAS-TRANSFERENCIA-20261029') then
            exit;
        Clear(Pares);
        Pares.Add(71125, 74050);
        Pares.Add(71126, 74053);
        Pares.Add(71127, 74051);
        Pares.Add(71128, 74052);
        Pares.Add(71129, 74047);
        Pares.Add(71130, 74048);
        Pares.Add(71131, 74049);
        Pares.Add(71132, 74054);
        Pares.Add(71133, 74055);
        Pares.Add(71134, 74056);
        Pares.Add(71135, 74057);
        Pares.Add(71136, 74058);
        Pares.Add(71137, 74059);
        Pares.Add(71138, 74060);
        Pares.Add(71139, 74061);
        Pares.Add(71141, 74062);
        Pares.Add(71142, 74063);
        Pares.Add(71143, 74064);
        Pares.Add(71144, 74065);
        Pares.Add(71145, 74066);
        Pares.Add(71146, 74067);
        Pares.Add(71147, 74068);
        Pares.Add(71148, 74069);
        CopiarYValidar(36, Pares);
        Clear(Pares);
        Pares.Add(71107, 74070);
        Pares.Add(71108, 74071);
        Pares.Add(71109, 74072);
        Pares.Add(71111, 74074);
        Pares.Add(71112, 74073);
        CopiarYValidar(37, Pares);
        Clear(Pares);
        Pares.Add(71100, 74005);
        Pares.Add(71101, 74000);
        Pares.Add(71102, 74001);
        Pares.Add(71103, 74002);
        Pares.Add(71104, 74003);
        Pares.Add(71105, 74004);
        Pares.Add(71106, 74006);
        Pares.Add(71107, 74012);
        Pares.Add(71108, 74007);
        Pares.Add(71109, 74008);
        Pares.Add(71110, 74009);
        Pares.Add(71111, 74010);
        Pares.Add(71112, 74011);
        Pares.Add(71113, 74013);
        Pares.Add(71114, 74021);
        Pares.Add(71115, 74022);
        Pares.Add(71116, 74023);
        Pares.Add(71117, 74040);
        Pares.Add(71118, 74024);
        Pares.Add(71119, 74025);
        Pares.Add(71120, 74026);
        Pares.Add(71121, 74027);
        Pares.Add(71122, 74028);
        Pares.Add(71123, 74014);
        Pares.Add(71124, 74015);
        Pares.Add(71125, 74041);
        Pares.Add(71126, 74016);
        Pares.Add(71127, 74017);
        Pares.Add(71128, 74018);
        Pares.Add(71129, 74019);
        Pares.Add(71130, 74020);
        Pares.Add(71131, 74032);
        Pares.Add(71132, 74029);
        Pares.Add(71133, 74030);
        Pares.Add(71134, 74031);
        Pares.Add(71135, 74033);
        Pares.Add(71136, 74034);
        Pares.Add(71137, 74035);
        Pares.Add(71138, 74036);
        Pares.Add(71139, 74037);
        Pares.Add(71144, 74038);
        Pares.Add(71145, 74039);
        CopiarYValidar(38, Pares);
        Clear(Pares);
        Pares.Add(71100, 74042);
        Pares.Add(71101, 74043);
        Pares.Add(71102, 74044);
        Pares.Add(71103, 74046);
        Pares.Add(71104, 74045);
        CopiarYValidar(39, Pares);
        Clear(Pares);
        Pares.Add(71125, 74056);
        Pares.Add(71126, 74057);
        Pares.Add(71127, 74058);
        Pares.Add(71128, 74059);
        Pares.Add(71129, 74060);
        Pares.Add(71130, 74061);
        Pares.Add(71131, 74062);
        Pares.Add(71132, 74063);
        Pares.Add(71133, 74064);
        Pares.Add(71134, 74065);
        Pares.Add(71135, 74066);
        Pares.Add(71136, 74067);
        Pares.Add(71137, 74068);
        Pares.Add(71138, 74069);
        CopiarYValidar(112, Pares);
        Clear(Pares);
        Pares.Add(71107, 74071);
        CopiarYValidar(113, Pares);
        Clear(Pares);
        Pares.Add(71100, 74005);
        Pares.Add(71101, 74021);
        Pares.Add(71102, 74022);
        Pares.Add(71103, 74003);
        CopiarYValidar(122, Pares);
        Clear(Pares);
        Pares.Add(71100, 74046);
        Pares.Add(71101, 74045);
        CopiarYValidar(123, Pares);
        Etiquetas.SetUpgradeTag('INVTECH-REFERENCIAS-TRANSFERENCIA-20261029');
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CopiarYValidar(Tabla: Integer; Pares: Dictionary of [Integer, Integer])
    var
        Transferencia: DataTransfer;
        Origen: Integer;
        Destino: Integer;
    begin
        // No cambia claves, importes contables, CAI ni campos de la extensión anterior.
        Comprobar(Tabla, Pares, true);
        Transferencia.SetTables(Tabla, Tabla);
        foreach Origen in Pares.Keys do begin
            Destino := Pares.Get(Origen);
            Transferencia.AddFieldValue(Origen, Destino);
        end;
        Transferencia.CopyFields();
        Comprobar(Tabla, Pares, false);
    end;

    local procedure Comprobar(Tabla: Integer; Pares: Dictionary of [Integer, Integer]; Antes: Boolean)
    var
        Datos: RecordRef;
        Inicial: RecordRef;
        Origen: Integer;
        Destino: Integer;
        CampoOrigen: FieldRef;
        CampoDestino: FieldRef;
        CampoInicial: FieldRef;
    begin
        Datos.Open(Tabla);
        Datos.LockTable();
        Inicial.Open(Tabla, true);
        Inicial.Init();
        if Datos.FindSet() then repeat
            foreach Origen in Pares.Keys do begin
                Destino := Pares.Get(Origen);
                CampoOrigen := Datos.Field(Origen);
                CampoDestino := Datos.Field(Destino);
                CampoInicial := Inicial.Field(Destino);
                if Format(CampoOrigen.Value, 0, 9) <> Format(CampoDestino.Value, 0, 9) then
                    if (not Antes) or (Format(CampoDestino.Value, 0, 9) <> Format(CampoInicial.Value, 0, 9)) then
                        Error('No se pudo validar la copia de referencias. Tabla %1, registro %2, campo %3 hacia %4. La actualización se detuvo para conservar la información.', Tabla, Datos.RecordId, Origen, Destino);
            end;
        until Datos.Next() = 0;
        Inicial.Close();
        Datos.Close();
    end;
}

codeunit 71119 "HN Install Referencias"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        Etiquetas: Codeunit "Upgrade Tag";
    begin
        // En una primera instalación no hay valores anteriores que trasladar.
        // Evita que una actualización futura sustituya referencias creadas con el esquema nuevo.
        if not Etiquetas.HasUpgradeTag('INVTECH-REFERENCIAS-TRANSFERENCIA-20261029') then
            Etiquetas.SetUpgradeTag('INVTECH-REFERENCIAS-TRANSFERENCIA-20261029');
    end;
}
