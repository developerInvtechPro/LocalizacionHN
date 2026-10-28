namespace INVTECH.Honduras;

using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Text;

codeunit 71117 "HN Datos Formatos"
{
    procedure FormatoActivo(NumeroInforme: Integer): Boolean
    begin
        exit(NumeroInforme in [Report::"HN Retention Certificate", Report::"HN Debit Note Certificate", Report::"HN Borrador Retencion"]);
    end;

    procedure ComprobarFormatoActivo(NumeroInforme: Integer)
    begin
        if not FormatoActivo(NumeroInforme) then
            Error('Este formato de V2 está en espera del plan de migración. Utilice el formato anterior configurado para este documento.');
    end;

    procedure CargarEmpresa(var Logo: Text; var TipoImagen: Text; var Contacto: Text)
    var Empresa: Record "Company Information"; Flujo: InStream; Codificador: Codeunit "Base64 Convert"; PrimerByte: Byte;
    begin
        Clear(Logo); TipoImagen := 'image/png'; Clear(Contacto);
        if not Empresa.Get() then exit;
        if Empresa."Phone No." <> '' then Contacto := 'Tel.: ' + Empresa."Phone No.";
        if Empresa."E-Mail" <> '' then begin
            if Contacto <> '' then Contacto += ' | ';
            Contacto += Empresa."E-Mail";
        end;
        Empresa.CalcFields(Picture);
        if not Empresa.Picture.HasValue() then exit;
        Empresa.Picture.CreateInStream(Flujo); Flujo.Read(PrimerByte);
        case PrimerByte of
            137: TipoImagen := 'image/png';
            255: TipoImagen := 'image/jpeg';
            71: TipoImagen := 'image/gif';
            66: TipoImagen := 'image/bmp';
            else exit; // No enviar al renderizador un formato no reconocido.
        end;
        Empresa.Picture.CreateInStream(Flujo); Logo := Codificador.ToBase64(Flujo);
    end;

    procedure Moneda(Codigo: Code[10]): Text
    var Configuracion: Record "General Ledger Setup";
    begin
        if Codigo <> '' then exit(Codigo);
        if Configuracion.Get() then
            if Configuracion."LCY Code" <> '' then exit(Configuracion."LCY Code");
        exit('MONEDA LOCAL');
    end;

    procedure RotuloMoneda(Codigo: Code[10]): Text
    var CodigoEfectivo: Text;
    begin
        CodigoEfectivo := Moneda(Codigo);
        case CodigoEfectivo of
            'HNL': exit('Lempiras (HNL)');
            'USD': exit('Dólares estadounidenses (USD)');
            'EUR': exit('Euros (EUR)');
        end;
        exit(CodigoEfectivo);
    end;

    procedure Letras(Importe: Decimal; Codigo: Code[10]): Text
    var Conversor: Codeunit "HN Importe En Letras";
    begin
        exit(Conversor.ConvertirMoneda(Importe,Moneda(Codigo)));
    end;
}
