namespace INVTECH.Honduras;
using Microsoft.Sales.History;

// Se incorporan también los módulos publicados anteriormente al registro de consumo fiscal.
codeunit 71112 "HN Trazabilidad Fiscal"
{
    [EventSubscriber(ObjectType::Table, Database::"HN Retention Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure RetencionRegistrada(var Rec: Record "HN Retention Header"; var xRec: Record "HN Retention Header")
    var
        Movimiento: Record "HN Movimiento Fiscal";
    begin
        if Rec.IsTemporary() then exit;
        if (Rec.Status <> Rec.Status::Posted) or (xRec.Status <> xRec.Status::Draft) then exit;
        Movimiento.Init();
        Movimiento."Tipo documento" := Movimiento."Tipo documento"::Retention;
        Movimiento."No. documento" := Rec."No.";
        Movimiento."Numero fiscal" := Rec."Fiscal No.";
        Movimiento.CAI := Rec.CAI;
        Movimiento."Codigo autorizacion" := Rec."CAI Code";
        Movimiento."Fecha emision" := Rec."Posting Date";
        Movimiento."Fecha registro" := Rec."Posting Date";
        Movimiento."No. tercero" := Rec."Vendor No.";
        Movimiento."Nombre tercero" := Rec."Vendor Name";
        Movimiento."Rango inicial" := Rec."CAI Starting No.";
        Movimiento."Rango final" := Rec."CAI Ending No.";
        Movimiento.Vencimiento := Rec."CAI Valid Until";
        Movimiento.Usuario := UserId();
        Movimiento."Registrado el" := CurrentDateTime();
        Movimiento.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure NotaDebitoRegistrada(var Rec: Record "Sales Invoice Header")
    var
        Movimiento: Record "HN Movimiento Fiscal";
    begin
        if Rec.IsTemporary() or not Rec."HN Debit Note" or (Rec."HN Fiscal No." = '') then exit;
        Movimiento.Init();
        Movimiento."Tipo documento" := Movimiento."Tipo documento"::"Debit Note";
        Movimiento."No. documento" := Rec."No.";
        Movimiento."Numero fiscal" := Rec."HN Fiscal No.";
        Movimiento.CAI := Rec."HN CAI";
        Movimiento."Codigo autorizacion" := Rec."HN CAI Code";
        Movimiento."Fecha emision" := Rec."Posting Date";
        Movimiento."Fecha registro" := Rec."Posting Date";
        Movimiento."No. tercero" := Rec."Bill-to Customer No.";
        Movimiento."Nombre tercero" := Rec."Bill-to Name";
        Movimiento."Rango inicial" := Rec."HN CAI Starting No.";
        Movimiento."Rango final" := Rec."HN CAI Ending No.";
        Movimiento.Vencimiento := Rec."HN CAI Valid Until";
        Movimiento.Usuario := UserId();
        Movimiento."Registrado el" := CurrentDateTime();
        Movimiento.Insert(true);
    end;
}
