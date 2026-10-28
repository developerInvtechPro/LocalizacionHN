namespace INVTECH.Honduras;
using System.Reflection;
using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

table 71121 "HN Valor Referencia"
{
    TableType = Temporary;
    DataClassification = CustomerContent;
    fields
    {
        field(1; Campo; Integer) { Caption = 'Campo de origen'; }
        field(2; Concepto; Text[100]) { Caption = 'Referencia'; }
        field(3; Valor; Text[2048]) { Caption = 'Valor conservado'; }
    }
    keys { key(PK; Campo) { Clustered = true; } }
}
page 71125 "HN Valores Referencia"
{
    Caption = 'Referencias anteriores conservadas';
    PageType = List; SourceTable = "HN Valor Referencia"; SourceTableTemporary = true;
    Editable = false; ApplicationArea = All;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Concepto; Rec.Concepto) { ApplicationArea = All; }
                field(Valor; Rec.Valor) { ApplicationArea = All; }
                field(Campo; Rec.Campo) { ApplicationArea = All; }
            }
        }
    }
    procedure Establecer(var Valores: Record "HN Valor Referencia" temporary)
    begin Rec.Copy(Valores, true); end;
}
codeunit 71115 "HN Consultar Referencias"
{
    procedure Mostrar(var Datos: RecordRef)
    var
        Mapa: Record "HN Migration Field" temporary;
        Gestor: Codeunit "HN Migration Field Map";
        Valores: Record "HN Valor Referencia" temporary;
        Pagina: Page "HN Valores Referencia";
        Campo: FieldRef;
        Temporal: Codeunit "Temp Blob";
    begin
        Gestor.Fill(Datos.Number, Mapa);
        if Mapa.FindSet() then repeat
            Campo := Datos.Field(Mapa."Target ID");
            Valores.Init(); Valores.Campo := Mapa."Source ID";
            Valores.Concepto := CopyStr(Campo.Caption, 1, 100);
            if Campo.Type = FieldType::Blob then begin
                Temporal.FromFieldRef(Campo);
                Valores.Valor := StrSubstNo('Contenido adjunto conservado: %1 bytes', Temporal.Length());
            end else Valores.Valor := CopyStr(Format(Campo.Value), 1, 2048);
            Valores.Insert();
        until Mapa.Next() = 0;
        Pagina.Establecer(Valores); Pagina.RunModal();
    end;
}
