namespace INVTECH.Honduras;

codeunit 71114 "HN Importe En Letras"
{
    procedure Convertir(Importe: Decimal): Text
    var Entero: Decimal; Centavos: Integer; Enlace: Text;
    begin
        Importe := Round(Importe, 0.01);
        if (Importe < 0) or (Importe >= 1000000000000.0) then Error('El importe debe ser positivo y menor de un billón de lempiras.');
        Entero := Round(Importe, 1, '<');
        Centavos := Round((Importe - Entero) * 100, 1);
        if (Entero >= 1000000) and ((Entero mod 1000000) = 0) then Enlace := ' DE' ;
        exit(Grupo(Entero) + Enlace + ' LEMPIRAS CON ' + PadStr('', 2 - StrLen(Format(Centavos, 0, 9)), '0') + Format(Centavos, 0, 9) + '/100');
    end;

    local procedure Grupo(Numero: Decimal): Text
    var Parte: Integer; Resto: Decimal; Texto: Text;
    begin
        if Numero < 1000 then exit(Centena(Numero));
        if Numero >= 1000000 then begin
            Parte := Round(Numero / 1000000, 1, '<');
            Resto := Numero - Parte * 1000000.0;
            if Parte = 1 then Texto := 'UN MILLÓN' else Texto := Grupo(Parte) + ' MILLONES';
        end else begin
            Parte := Round(Numero / 1000, 1, '<');
            Resto := Numero - Parte * 1000;
            if Parte = 1 then Texto := 'MIL' else Texto := Centena(Parte) + ' MIL';
        end;
        if Resto <> 0 then Texto += ' ' + Grupo(Resto);
        exit(Texto);
    end;

    local procedure Centena(Numero: Integer): Text
    var Centenas: Integer; Resto: Integer; Texto: Text;
    begin
        if Numero < 100 then exit(Decena(Numero));
        if Numero = 100 then exit('CIEN');
        Centenas := Numero div 100;
        Resto := Numero mod 100;
        Texto := SelectStr(Centenas, 'CIENTO,DOSCIENTOS,TRESCIENTOS,CUATROCIENTOS,QUINIENTOS,SEISCIENTOS,SETECIENTOS,OCHOCIENTOS,NOVECIENTOS');
        if Resto <> 0 then Texto += ' ' + Decena(Resto);
        exit(Texto);
    end;

    local procedure Decena(Numero: Integer): Text
    var Texto: Text;
    begin
        case Numero of
            0: exit('CERO');
            1 .. 29: exit(SelectStr(Numero, 'UN,DOS,TRES,CUATRO,CINCO,SEIS,SIETE,OCHO,NUEVE,DIEZ,ONCE,DOCE,TRECE,CATORCE,QUINCE,DIECISÉIS,DIECISIETE,DIECIOCHO,DIECINUEVE,VEINTE,VEINTIÚN,VEINTIDÓS,VEINTITRÉS,VEINTICUATRO,VEINTICINCO,VEINTISÉIS,VEINTISIETE,VEINTIOCHO,VEINTINUEVE'));
        end;
        Texto := SelectStr((Numero div 10) - 2, 'TREINTA,CUARENTA,CINCUENTA,SESENTA,SETENTA,OCHENTA,NOVENTA');
        if (Numero mod 10) <> 0 then Texto += ' Y ' + Decena(Numero mod 10);
        exit(Texto);
    end;
}
