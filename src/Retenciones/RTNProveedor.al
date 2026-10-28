namespace INVTECH.Honduras;
using Microsoft.Purchases.Vendor;
using System.Reflection;
using System.Apps;

tableextension 71129 "HN RTN Propio Proveedor" extends Vendor
{
    fields
    {
        field(71180; "HN RTN Proveedor"; Code[50]) { Caption = 'RTN proveedor HN (V2)'; DataClassification = CustomerContent; }
    }
}
pageextension 71149 "HN RTN Ficha Proveedor" extends "Vendor Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field(HNRTNPropio; Rec."HN RTN Proveedor") { ApplicationArea = All; ToolTip = 'RTN propio de V2. Se conserva el campo de la localización anterior; el borrador de retención permite elegir entre los valores disponibles.'; }
        }
    }
}
table 71123 "HN Opcion RTN Proveedor"
{
    TableType = Temporary; DataClassification = CustomerContent;
    fields
    {
        field(1; Numero; Integer) { Caption = 'Opción'; }
        field(2; RTN; Code[50]) { Caption = 'RTN'; }
        field(3; Origen; Text[150]) { Caption = 'Disponible en'; }
    }
    keys { key(PK; Numero) { Clustered = true; } }
}
page 71127 "HN Elegir RTN Proveedor"
{
    Caption = 'Seleccionar RTN del proveedor'; PageType = List; Editable = false;
    SourceTable = "HN Opcion RTN Proveedor"; SourceTableTemporary = true; ApplicationArea = All;
    layout
    {
        area(Content)
        {
            repeater(Opciones)
            {
                field(RTN; Rec.RTN) { ApplicationArea = All; }
                field(Origen; Rec.Origen) { ApplicationArea = All; }
            }
        }
    }
    procedure Establecer(var Opciones: Record "HN Opcion RTN Proveedor" temporary)
    begin Rec.Copy(Opciones,true); end;
}
codeunit 71116 "HN Gestion RTN Proveedor"
{
    Permissions = tabledata Field = R, tabledata "NAV App Installed App" = R;

    procedure ObtenerOpciones(Proveedor: Record Vendor; var Opciones: Record "HN Opcion RTN Proveedor" temporary)
    var EstadoAnterior: Text;
    begin
        ObtenerOpcionesConEstado(Proveedor,Opciones,EstadoAnterior);
    end;

    local procedure ObtenerOpcionesConEstado(Proveedor: Record Vendor; var Opciones: Record "HN Opcion RTN Proveedor" temporary; var EstadoAnterior: Text)
    var Anterior: Code[50];
    begin
        Opciones.Reset(); Opciones.DeleteAll();
        Agregar(Opciones,Proveedor."HN RTN Proveedor",'RTN propio de V2');
        Agregar(Opciones,Proveedor."HN Ref 60450",'Referencia migrada a V2');
        if LeerRTNAnterior(Proveedor,Anterior,EstadoAnterior) then Agregar(Opciones,Anterior,'Localización anterior');
        Agregar(Opciones,Proveedor."VAT Registration No.",'Registro fiscal estándar');
    end;

    procedure Proponer(var Cabecera: Record "HN Retention Header")
    var Proveedor: Record Vendor; Opciones: Record "HN Opcion RTN Proveedor" temporary;
    begin
        Cabecera.TestField(Status,Cabecera.Status::Draft);
        if Cabecera.ObtenerRTNProveedor() <> '' then exit;
        Proveedor.Get(Cabecera."Vendor No."); ObtenerOpciones(Proveedor,Opciones);
        // Un único valor puede proponerse; valores diferentes requieren elección del usuario.
        if Opciones.Count()=1 then begin Opciones.FindFirst(); Cabecera.Validate("RTN proveedor completo",Opciones.RTN); end;
    end;

    procedure Seleccionar(var Cabecera: Record "HN Retention Header"): Boolean
    var Proveedor: Record Vendor; Opciones: Record "HN Opcion RTN Proveedor" temporary; Pagina: Page "HN Elegir RTN Proveedor"; EstadoAnterior: Text;
    begin
        Cabecera.TestField(Status,Cabecera.Status::Draft);
        Proveedor.Get(Cabecera."Vendor No."); ObtenerOpcionesConEstado(Proveedor,Opciones,EstadoAnterior);
        if Opciones.IsEmpty() then
            Error('El proveedor %1 no tiene RTN disponibles. %2 Abra su ficha y complete «RTN proveedor HN (V2)»; luego vuelva a seleccionar el RTN en este borrador.',Proveedor."No.",EstadoAnterior);
        Pagina.Establecer(Opciones); Pagina.LookupMode(true);
        if Pagina.RunModal() <> Action::LookupOK then exit(false);
        Pagina.GetRecord(Opciones);
        Cabecera.Validate("RTN proveedor completo",Opciones.RTN); Cabecera.Modify(true);
        exit(true);
    end;

    procedure ValidarEleccion(Cabecera: Record "HN Retention Header"; Valor: Text[50])
    var Proveedor: Record Vendor; Opciones: Record "HN Opcion RTN Proveedor" temporary; EstadoAnterior: Text;
    begin
        Cabecera.TestField(Status,Cabecera.Status::Draft);
        if Valor='' then exit;
        Proveedor.Get(Cabecera."Vendor No."); ObtenerOpcionesConEstado(Proveedor,Opciones,EstadoAnterior);
        if Opciones.IsEmpty() then
            Error('El proveedor %1 no tiene RTN disponibles. %2 Complete «RTN proveedor HN (V2)» en su ficha y vuelva a seleccionar el RTN.',Proveedor."No.",EstadoAnterior);
        Opciones.SetRange(RTN,Valor);
        if Opciones.IsEmpty() then Error('El RTN ingresado no coincide con los disponibles del proveedor %1. Use el selector o corrija «RTN proveedor HN (V2)» en su ficha.',Proveedor."No.");
    end;

    local procedure Agregar(var Opciones: Record "HN Opcion RTN Proveedor" temporary; Valor: Code[50]; Origen: Text)
    var Numero: Integer;
    begin
        if Valor='' then exit;
        Opciones.SetRange(RTN,Valor);
        if Opciones.FindFirst() then begin
            Opciones.Origen := CopyStr(Opciones.Origen+' / '+Origen,1,150); Opciones.Modify(); Opciones.SetRange(RTN); exit;
        end;
        Opciones.SetRange(RTN); Numero := Opciones.Count()+1;
        Opciones.Init(); Opciones.Numero := Numero; Opciones.RTN := Valor; Opciones.Origen := CopyStr(Origen,1,150); Opciones.Insert();
    end;

    local procedure LeerRTNAnterior(Proveedor: Record Vendor; var RTN: Code[50]; var Estado: Text): Boolean
    var Datos: RecordRef; CampoRTN: FieldRef; Metadatos: Record Field; Aplicacion: Record "NAV App Installed App"; IdOrigen: Guid;
    begin
        Clear(RTN); Clear(Estado);
        // Consultar en la base el campo de la otra extensión, sin depender del búfer
        // tipado Vendor que recibe V2 ni de sus campos cargados parcialmente.
        Datos.Open(Database::Vendor);
        if not Datos.FieldExist(60450) then begin
            Estado := 'El campo RTN de la localización anterior no está disponible.'; exit(false);
        end;
        CampoRTN := Datos.Field(60450);
        if (CampoRTN.Name <> 'RTN') or (CampoRTN.Type <> FieldType::Code) or (CampoRTN.Length <> 50) or (CampoRTN.Class <> FieldClass::Normal) then begin
            Estado := 'La definición del RTN anterior no corresponde a la localización prevista.'; exit(false);
        end;
        Metadatos.Get(Database::Vendor,60450);
        IdOrigen := 'ba215fdf-ea75-4dcd-875e-70dd8c5c9ff8'; Aplicacion.SetRange("App ID",IdOrigen);
        // Puede coexistir información de publicación normal y de desarrollo.
        // Buscar el paquete propietario, no comparar solo con la primera fila.
        Aplicacion.SetFilter("Package ID",'%1|%2',Metadatos."App Package ID",Metadatos."App Runtime Package ID");
        if Aplicacion.IsEmpty() then begin
            Estado := 'No se pudo verificar la aplicación propietaria del RTN anterior.'; exit(false);
        end;
        if Proveedor.IsTemporary() then begin
            Estado := 'El proveedor temporal no tiene un RTN anterior guardado.'; exit(false);
        end;
        if not Datos.Get(Proveedor.RecordId) then begin
            Estado := 'No se encontró el proveedor guardado para consultar su RTN anterior.'; exit(false);
        end;
        CampoRTN := Datos.Field(60450); RTN := CampoRTN.Value;
        if RTN='' then Estado := 'El RTN de la localización anterior está vacío en la ficha de este proveedor.';
        exit(RTN<>'');
    end;
}
