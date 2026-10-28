namespace INVTECH.Honduras;
using Microsoft.Purchases.History;

table 71122 "HN Seleccion Ret. Factura"
{
    Caption = 'Conceptos de retención de factura registrada'; DataClassification = CustomerContent;
    fields
    {
        field(1; Documento; Code[20]) { Caption = 'Comprobante'; TableRelation = "HN Retention Header"; }
        field(2; Factura; Code[20]) { Caption = 'Factura registrada'; TableRelation = "Purch. Inv. Header"; }
        field(3; Linea; Integer) { Caption = 'Línea de factura'; }
        field(4; Conceptos; Text[250])
        {
            Caption = 'Conceptos de retención';
            trigger OnValidate()
            var Gestion: Codeunit "HN Retention Management"; Regla: Record "HN Retention Rule"; Codigos: List of [Text]; Codigo: Text;
            begin
                ComprobarBorrador();
                Codigos := Gestion.NormalizeCodes(Conceptos);
                Clear(Conceptos);
                foreach Codigo in Codigos do begin
                    Regla.Get(Codigo); Regla.TestField(Enabled, true); Regla.TestField("G/L Account No.");
                    if Conceptos <> '' then Conceptos += ',';
                    Conceptos += Codigo;
                end;
            end;
        }
        field(5; Descripcion; Text[100]) { Caption = 'Descripción de la línea'; Editable = false; }
        field(6; Base; Decimal) { Caption = 'Importe sin impuestos'; Editable = false; }
        field(7; Impuesto; Decimal) { Caption = 'Importe de impuesto'; Editable = false; }
    }
    keys { key(PK; Documento,Factura,Linea) { Clustered = true; } }
    trigger OnInsert()
    begin ComprobarBorrador(); end;
    trigger OnModify()
    begin ComprobarBorrador(); TestField(Documento,xRec.Documento); TestField(Factura,xRec.Factura); TestField(Linea,xRec.Linea); end;
    trigger OnDelete()
    begin ComprobarBorrador(); end;
    trigger OnRename()
    begin Error('No se puede cambiar la identidad de una selección de retenciones.'); end;
    local procedure ComprobarBorrador()
    var Cabecera: Record "HN Retention Header"; Origen: Record "HN Retention Invoice"; LineaFactura: Record "Purch. Inv. Line";
    begin
        Cabecera.LockTable(); Cabecera.Get(Documento); Cabecera.TestField(Status,Cabecera.Status::Draft);
        Origen.Get(Documento,Factura);
        LineaFactura.Get(Factura,Linea);
    end;
}

page 71126 "HN Conceptos Factura Ret."
{
    Caption = 'Seleccionar retenciones de facturas registradas'; PageType = List;
    SourceTable = "HN Seleccion Ret. Factura"; ApplicationArea = All;
    InsertAllowed = false; DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Lineas)
            {
                field(Factura; Rec.Factura) { ApplicationArea = All; Editable = false; }
                field(Linea; Rec.Linea) { ApplicationArea = All; Editable = false; }
                field(Descripcion; Rec.Descripcion) { ApplicationArea = All; }
                field(Base; Rec.Base) { ApplicationArea = All; }
                field(Impuesto; Rec.Impuesto) { ApplicationArea = All; }
                field(Conceptos; Rec.Conceptos)
                {
                    ApplicationArea = All; Lookup = true;
                    ToolTip = 'Seleccione los conceptos aplicables. La elección pertenece al borrador de retención y no modifica la factura registrada.';
                    trigger OnLookup(var Text: Text): Boolean
                    var Reglas: Record "HN Retention Rule"; Pagina: Page "HN Retention Rules"; Codigos: Text[250];
                    begin
                        CurrPage.SaveRecord(); Commit();
                        Reglas.SetRange(Enabled,true); Pagina.SetTableView(Reglas); Pagina.LookupMode(true);
                        if Pagina.RunModal() <> Action::LookupOK then exit(false);
                        Pagina.SetSelectionFilter(Reglas);
                        if not Reglas.FindSet() then exit(false);
                        repeat
                            if Codigos <> '' then Codigos += ',';
                            Codigos += Reglas.Code;
                        until Reglas.Next()=0;
                        Rec.Validate(Conceptos,Codigos);
                        Rec.Modify(true);
                        // OnLookup debe devolver el valor al control; un texto vacío puede borrar lo guardado.
                        Text := Rec.Conceptos;
                        CurrPage.Update(false);
                        exit(true);
                    end;
                }
            }
        }
    }
}
