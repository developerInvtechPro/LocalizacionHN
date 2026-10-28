namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;

tableextension 71119 "HN Ref Tabla 36" extends "Sales Header"
{
    fields
    {
        field(71125; "HN Ref 60109"; Boolean) { Caption = 'Referencia: Campo Booleano'; DataClassification = CustomerContent; Editable = false; }
        field(71126; "HN Ref 60132"; Code[50]) { Caption = 'Referencia: Orden De Compras'; DataClassification = CustomerContent; Editable = false; }
        field(71127; "HN Ref 60124"; Date) { Caption = 'Referencia: Fecha Inicio'; DataClassification = CustomerContent; Editable = false; }
        field(71128; "HN Ref 60125"; Date) { Caption = 'Referencia: Fecha Fin'; DataClassification = CustomerContent; Editable = false; }
        field(71129; "HN Ref 60102"; Decimal) { Caption = 'Referencia: Monto histórico retenido'; DataClassification = CustomerContent; Editable = false; }
        field(71130; "HN Ref 60104"; Code[20]) { Caption = 'Referencia: Nuevo Código Exoneración'; DataClassification = CustomerContent; Editable = false; }
        field(71131; "HN Ref 60105"; Code[20]) { Caption = 'Referencia: Grupo Impuestos Honduras'; DataClassification = CustomerContent; Editable = false; }
        field(71132; "HN Ref 60455"; Code[20]) { Caption = 'Referencia: Etiqueta de factura'; DataClassification = CustomerContent; Editable = false; }
        field(71133; "HN Ref 60486"; Code[30]) { Caption = 'Referencia: Identificador anterior de imagen'; DataClassification = CustomerContent; Editable = false; }
        field(71134; "HN Ref 60507"; Text[60]) { Caption = 'Referencia: Fuente'; DataClassification = CustomerContent; Editable = false; }
        field(71135; "HN Ref 60508"; Text[60]) { Caption = 'Referencia: Proyecto'; DataClassification = CustomerContent; Editable = false; }
        field(71136; "HN Ref 60509"; Text[90]) { Caption = 'Referencia: ProyectoUbicacion'; DataClassification = CustomerContent; Editable = false; }
        field(71137; "HN Ref 60510"; Decimal) { Caption = 'Referencia: Total IVA 18%'; DataClassification = CustomerContent; Editable = false; }
        field(71138; "HN Ref 60511"; Decimal) { Caption = 'Referencia: Total IVA 0%'; DataClassification = CustomerContent; Editable = false; }
        field(71139; "HN Ref 60512"; Decimal) { Caption = 'Referencia: Total IVA Otros'; DataClassification = CustomerContent; Editable = false; }
        field(71141; "HN Ref 60513"; Text[250]) { Caption = 'Referencia: Resumen Impuestos'; DataClassification = CustomerContent; Editable = false; }
        field(71142; "HN Ref 60514"; Decimal) { Caption = 'Referencia: Total Exento'; DataClassification = CustomerContent; Editable = false; }
        field(71143; "HN Ref 60515"; Decimal) { Caption = 'Referencia: Total IVA 15%'; DataClassification = CustomerContent; Editable = false; }
        field(71144; "HN Ref 60516"; Decimal) { Caption = 'Referencia: Total Exonerado'; DataClassification = CustomerContent; Editable = false; }
        field(71145; "HN Ref 60517"; Boolean) { Caption = 'Referencia: Indicador anterior de nota de débito'; DataClassification = CustomerContent; Editable = false; }
        field(71146; "HN Ref 60518"; Text[100]) { Caption = 'Referencia: Motivo anterior de nota de débito'; DataClassification = CustomerContent; Editable = false; }
        field(71147; "HN Ref 60519"; Code[20]) { Caption = 'Referencia: Factura anterior de origen'; DataClassification = CustomerContent; Editable = false; }
        field(71148; "HN Ref 60520"; Date) { Caption = 'Referencia: Fecha anterior de factura origen'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71120 "HN Ref Tabla 37" extends "Sales Line"
{
    fields
    {
        field(71107; "HN Ref 60101"; Decimal) { Caption = 'Referencia: Importe Impuesto'; DataClassification = CustomerContent; Editable = false; }
        field(71108; "HN Ref 60450"; Decimal) { Caption = 'Referencia: Importe excentoLine'; DataClassification = CustomerContent; Editable = false; }
        field(71109; "HN Ref 60458"; Guid) { Caption = 'Referencia: TenantMedia ID'; DataClassification = CustomerContent; Editable = false; }
        field(71110; "HN Ref 60459"; Blob) { Caption = 'Referencia: Thumbail'; DataClassification = CustomerContent; }
        field(71111; "HN Ref 60531"; Text[2048]) { Caption = 'Referencia: ZY Extended Description'; DataClassification = CustomerContent; Editable = false; }
        field(71112; "HN Ref 60530"; Text[250]) { Caption = 'Referencia: Tiempo de Entrega'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71121 "HN Ref Tabla 112" extends "Sales Invoice Header"
{
    fields
    {
        field(71125; "HN Ref 60507"; Text[60]) { Caption = 'Referencia: Fuente'; DataClassification = CustomerContent; Editable = false; }
        field(71126; "HN Ref 60508"; Text[60]) { Caption = 'Referencia: Proyecto'; DataClassification = CustomerContent; Editable = false; }
        field(71127; "HN Ref 60509"; Text[90]) { Caption = 'Referencia: ProyectoUbicacion'; DataClassification = CustomerContent; Editable = false; }
        field(71128; "HN Ref 60510"; Decimal) { Caption = 'Referencia: Total IVA 18%'; DataClassification = CustomerContent; Editable = false; }
        field(71129; "HN Ref 60511"; Decimal) { Caption = 'Referencia: Total IVA 0%'; DataClassification = CustomerContent; Editable = false; }
        field(71130; "HN Ref 60512"; Decimal) { Caption = 'Referencia: Total IVA Otros'; DataClassification = CustomerContent; Editable = false; }
        field(71131; "HN Ref 60513"; Text[250]) { Caption = 'Referencia: Resumen Impuestos'; DataClassification = CustomerContent; Editable = false; }
        field(71132; "HN Ref 60514"; Decimal) { Caption = 'Referencia: Total Exento'; DataClassification = CustomerContent; Editable = false; }
        field(71133; "HN Ref 60515"; Decimal) { Caption = 'Referencia: Total IVA 15%'; DataClassification = CustomerContent; Editable = false; }
        field(71134; "HN Ref 60516"; Decimal) { Caption = 'Referencia: Total Exonerado'; DataClassification = CustomerContent; Editable = false; }
        field(71135; "HN Ref 60517"; Boolean) { Caption = 'Referencia: Indicador anterior de nota de débito'; DataClassification = CustomerContent; Editable = false; }
        field(71136; "HN Ref 60518"; Text[100]) { Caption = 'Referencia: Motivo anterior de nota de débito'; DataClassification = CustomerContent; Editable = false; }
        field(71137; "HN Ref 60519"; Code[20]) { Caption = 'Referencia: Factura anterior de origen'; DataClassification = CustomerContent; Editable = false; }
        field(71138; "HN Ref 60520"; Date) { Caption = 'Referencia: Fecha anterior de factura origen'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71122 "HN Ref Tabla 113" extends "Sales Invoice Line"
{
    fields
    {
        field(71107; "HN Ref 60450"; Decimal) { Caption = 'Referencia: Importe excentoLine'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71123 "HN Ref Tabla 38" extends "Purchase Header"
{
    fields
    {
        field(71100; "HN Ref 60460"; Code[37]) { Caption = 'Referencia: Código CAI'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60451"; Decimal) { Caption = 'Referencia: Monto histórico retenido'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "HN Ref 60452"; Date) { Caption = 'Referencia: CAI Fecha Inicio'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "HN Ref 60453"; Date) { Caption = 'Referencia: CAI Fecha Fin'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "HN Ref 60454"; Decimal) { Caption = 'Referencia: Total99 Amount99'; DataClassification = CustomerContent; Editable = false; }
        field(71105; "HN Ref 60459"; Decimal) { Caption = 'Referencia: Monto Exonerado'; DataClassification = CustomerContent; Editable = false; }
        field(71106; "HN Ref 60464"; Code[50]) { Caption = 'Referencia: Orden De Compras'; DataClassification = CustomerContent; Editable = false; }
        field(71107; "HN Ref 60477"; Code[50]) { Caption = 'Referencia: ORDEN DE COMPRA EXENTA'; DataClassification = CustomerContent; Editable = false; }
        field(71108; "HN Ref 60466"; Code[50]) { Caption = 'Referencia: CONSTANCIA REGISTRO EXONERADOS'; DataClassification = CustomerContent; Editable = false; }
        field(71109; "HN Ref 60467"; Code[50]) { Caption = 'Referencia: IDENTIFICACION DE LA SAG'; DataClassification = CustomerContent; Editable = false; }
        field(71110; "HN Ref 60473"; Date) { Caption = 'Referencia: Fecha Inicio'; DataClassification = CustomerContent; Editable = false; }
        field(71111; "HN Ref 60474"; Date) { Caption = 'Referencia: Fecha Fin'; DataClassification = CustomerContent; Editable = false; }
        field(71112; "HN Ref 60476"; Code[20]) { Caption = 'Referencia: Código Exoneración'; DataClassification = CustomerContent; Editable = false; }
        field(71113; "HN Ref 60478"; Code[20]) { Caption = 'Referencia: Grupo Impuestos Honduras'; DataClassification = CustomerContent; Editable = false; }
        field(71114; "HN Ref 60491"; Integer) { Caption = 'Referencia: Lote'; DataClassification = CustomerContent; Editable = false; }
        field(71115; "HN Ref 60492"; Code[30]) { Caption = 'Referencia: No Factura'; DataClassification = CustomerContent; Editable = false; }
        field(71116; "HN Ref 60495"; Code[20]) { Caption = 'Referencia: Etiqueta de factura'; DataClassification = CustomerContent; Editable = false; }
        field(71117; "HN Ref 60563"; Date) { Caption = 'Referencia: Fecha esperada de recepción'; DataClassification = CustomerContent; Editable = false; }
        field(71118; "HN Ref 60498"; Integer) { Caption = 'Referencia: POS Sales Doc_ Type'; DataClassification = CustomerContent; Editable = false; }
        field(71119; "HN Ref 60499"; Integer) { Caption = 'Referencia: Billing Type'; DataClassification = CustomerContent; Editable = false; }
        field(71120; "HN Ref 60500"; Decimal) { Caption = 'Referencia: AmountTotal'; DataClassification = CustomerContent; Editable = false; }
        field(71121; "HN Ref 60501"; Decimal) { Caption = 'Referencia: VATAmount'; DataClassification = CustomerContent; Editable = false; }
        field(71122; "HN Ref 60502"; Code[5]) { Caption = 'Referencia: Código de sucursal'; DataClassification = CustomerContent; Editable = false; }
        field(71123; "HN Ref 60482"; Code[5]) { Caption = 'Referencia: POS Code'; DataClassification = CustomerContent; Editable = false; }
        field(71124; "HN Ref 60483"; Text[60]) { Caption = 'Referencia: Comentario'; DataClassification = CustomerContent; Editable = false; }
        field(71125; "HN Ref 60564"; Boolean) { Caption = 'Referencia: Proveedor extranjero sin CAI'; DataClassification = CustomerContent; Editable = false; }
        field(71126; "HN Ref 60486"; Code[30]) { Caption = 'Referencia: Identificador anterior de imagen'; DataClassification = CustomerContent; Editable = false; }
        field(71127; "HN Ref 60487"; Text[60]) { Caption = 'Referencia: OC'; DataClassification = CustomerContent; Editable = false; }
        field(71128; "HN Ref 60488"; Text[60]) { Caption = 'Referencia: NumeroDePlaca'; DataClassification = CustomerContent; Editable = false; }
        field(71129; "HN Ref 60489"; Text[60]) { Caption = 'Referencia: Kilometraje'; DataClassification = CustomerContent; Editable = false; }
        field(71130; "HN Ref 60490"; Text[60]) { Caption = 'Referencia: Chofer'; DataClassification = CustomerContent; Editable = false; }
        field(71131; "HN Ref 60506"; Text[60]) { Caption = 'Referencia: Usuario'; DataClassification = CustomerContent; Editable = false; }
        field(71132; "HN Ref 60503"; Boolean) { Caption = 'Referencia: Campo Booleano'; DataClassification = CustomerContent; Editable = false; }
        field(71133; "HN Ref 60504"; Code[20]) { Caption = 'Referencia: Nuevo Código Exoneración'; DataClassification = CustomerContent; Editable = false; }
        field(71134; "HN Ref 60505"; Code[35]) { Caption = 'Referencia: External Document No.'; DataClassification = CustomerContent; Editable = false; }
        field(71135; "HN Ref 60507"; Decimal) { Caption = 'Referencia: Total Exento'; DataClassification = CustomerContent; Editable = false; }
        field(71136; "HN Ref 60508"; Decimal) { Caption = 'Referencia: Total IVA 15%'; DataClassification = CustomerContent; Editable = false; }
        field(71137; "HN Ref 60509"; Decimal) { Caption = 'Referencia: Total IVA 18%'; DataClassification = CustomerContent; Editable = false; }
        field(71138; "HN Ref 60510"; Decimal) { Caption = 'Referencia: Total IVA 0%'; DataClassification = CustomerContent; Editable = false; }
        field(71139; "HN Ref 60511"; Decimal) { Caption = 'Referencia: Total IVA Otros'; DataClassification = CustomerContent; Editable = false; }
        field(71144; "HN Ref 60512"; Text[250]) { Caption = 'Referencia: Resumen Impuestos'; DataClassification = CustomerContent; Editable = false; }
        field(71145; "HN Ref 60513"; Decimal) { Caption = 'Referencia: Total Exonerado'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71124 "HN Ref Tabla 39" extends "Purchase Line"
{
    fields
    {
        field(71100; "HN Ref 60100"; Boolean) { Caption = 'Referencia: Aplicar Retención 1'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60101"; Boolean) { Caption = 'Referencia: Aplicar Retención 2'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "HN Ref 60102"; Boolean) { Caption = 'Referencia: Aplicar Retención 3'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "HN Ref 60104"; Text[250]) { Caption = 'Referencia: Selección histórica de retenciones'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "HN Ref 60103"; Decimal) { Caption = 'Referencia: Monto histórico retenido'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71125 "HN Ref Tabla 122" extends "Purch. Inv. Header"
{
    fields
    {
        field(71100; "HN Ref 60460"; Code[37]) { Caption = 'Referencia: Código CAI'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60491"; Integer) { Caption = 'Referencia: Lote'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "HN Ref 60492"; Code[30]) { Caption = 'Referencia: No Factura'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "HN Ref 60454"; Decimal) { Caption = 'Referencia: Total99 Amount99'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71126 "HN Ref Tabla 123" extends "Purch. Inv. Line"
{
    fields
    {
        field(71100; "HN Ref 60104"; Text[250]) { Caption = 'Referencia: Selección histórica de retenciones'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60103"; Decimal) { Caption = 'Referencia: Monto histórico retenido'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71127 "HN Ref Tabla 23" extends "Vendor"
{
    fields
    {
        field(71100; "HN Ref 60450"; Code[50]) { Caption = 'Referencia: RTN'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60451"; Code[50]) { Caption = 'Referencia: Código de Proveedor'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "HN Ref 60452"; Boolean) { Caption = 'Referencia: Proveedor extranjero sin CAI'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "HN Ref 60453"; Boolean) { Caption = 'Referencia: Proveedor requiere retención'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "HN Ref 60454"; Date) { Caption = 'Referencia: Fecha Vencimiento Retención'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71128 "HN Ref Tabla 79" extends "Company Information"
{
    fields
    {
        field(71100; "HN Ref 60482"; Code[30]) { Caption = 'Referencia: Teléfono anterior de empresa'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "HN Ref 60483"; Code[30]) { Caption = 'Referencia: RTN anterior de empresa'; DataClassification = CustomerContent; Editable = false; }
    }
}

table 71113 "HN Ref Catalogo 60450"
{
    Caption = 'CAI de proveedores (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[20])
        {
            Caption = 'No. Proveedor'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Code[37])
        {
            Caption = 'No. CAI'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Date)
        {
            Caption = 'Fecha Límite Emisión'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Code[20])
        {
            Caption = 'Factura Inicial'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Code[20])
        {
            Caption = 'Factura Final'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Code[20])
        {
            Caption = 'Código Sucursal'; DataClassification = CustomerContent; Editable = false;
        }
        field(7; "Ref 7"; Date)
        {
            Caption = 'Fecha Inicio'; DataClassification = CustomerContent; Editable = false;
        }
        field(8; "Ref 8"; Date)
        {
            Caption = 'Fecha Fin'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1", "Ref 2", "Ref 6") { Clustered = true; }
    }
}

page 71117 "HN Ref Lista 60450"
{
    Caption = 'CAI de proveedores (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60450"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
                field(Referencia7; Rec."Ref 7") { ApplicationArea = All; }
                field(Referencia8; Rec."Ref 8") { ApplicationArea = All; }
            }
        }
    }
}

table 71114 "HN Ref Catalogo 60489"
{
    Caption = 'CAI de ventas (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[20])
        {
            Caption = 'Código'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Code[37])
        {
            Caption = 'No. CAI'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Date)
        {
            Caption = 'Fecha Límite Emisión'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Code[20])
        {
            Caption = 'Factura Inicial'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Code[20])
        {
            Caption = 'Factura Final'; DataClassification = CustomerContent; Editable = false;
        }
        field(9; "Ref 9"; Code[50])
        {
            Caption = 'No De Factura Preterminado'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Boolean)
        {
            Caption = 'Habilitado'; DataClassification = CustomerContent; Editable = false;
        }
        field(7; "Ref 7"; Date)
        {
            Caption = 'Fecha Inicio'; DataClassification = CustomerContent; Editable = false;
        }
        field(8; "Ref 8"; Date)
        {
            Caption = 'Fecha Fin'; DataClassification = CustomerContent; Editable = false;
        }
        field(10; "Ref 10"; Option)
        {
            Caption = 'Este campo ya no se utiliza.'; DataClassification = CustomerContent; Editable = false;
            OptionMembers = "Pending","Processed","Canceled";
            OptionCaption = 'Pendiente,Procesado,Anulado';
        }
        field(20; "Ref 20"; Boolean)
        {
            Caption = 'Predeterminado'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1") { Clustered = true; }
    }
}

page 71118 "HN Ref Lista 60489"
{
    Caption = 'CAI de ventas (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60489"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia9; Rec."Ref 9") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
                field(Referencia7; Rec."Ref 7") { ApplicationArea = All; }
                field(Referencia8; Rec."Ref 8") { ApplicationArea = All; }
                field(Referencia10; Rec."Ref 10") { ApplicationArea = All; }
                field(Referencia20; Rec."Ref 20") { ApplicationArea = All; }
            }
        }
    }
}

table 71115 "HN Ref Catalogo 60451"
{
    Caption = 'Grupos de impuesto (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[20])
        {
            Caption = 'Código'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Text[100])
        {
            Caption = 'Descripción'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Decimal)
        {
            Caption = 'Tasa Impuesto'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Option)
        {
            Caption = 'Tipo Impuesto'; DataClassification = CustomerContent; Editable = false;
            OptionMembers = "ISV","Retención","Exoneración";
            OptionCaption = 'ISV,Retención,Exoneración';
        }
    }
    keys
    {
        key(PK; "Ref 1") { Clustered = true; }
    }
}

page 71119 "HN Ref Lista 60451"
{
    Caption = 'Grupos de impuesto (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60451"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
            }
        }
    }
}

table 71116 "HN Ref Catalogo 60452"
{
    Caption = 'Exoneraciones (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[20])
        {
            Caption = 'Código'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Text[100])
        {
            Caption = 'Descripción'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Option)
        {
            Caption = 'Tipo Exoneración'; DataClassification = CustomerContent; Editable = false;
            OptionMembers = "Total","Parcial","Por Monto";
            OptionCaption = 'Total,Parcial,Por Monto';
        }
        field(4; "Ref 4"; Decimal)
        {
            Caption = 'Porcentaje Exoneración'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Decimal)
        {
            Caption = 'Monto Máximo'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Date)
        {
            Caption = 'Fecha Inicio'; DataClassification = CustomerContent; Editable = false;
        }
        field(7; "Ref 7"; Date)
        {
            Caption = 'Fecha Fin'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1") { Clustered = true; }
    }
}

page 71120 "HN Ref Lista 60452"
{
    Caption = 'Exoneraciones (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60452"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
                field(Referencia7; Rec."Ref 7") { ApplicationArea = All; }
            }
        }
    }
}

table 71117 "HN Ref Catalogo 60459"
{
    Caption = 'Medios de pago POS (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(60450; "Ref 60450"; Integer)
        {
            Caption = 'Identificador anterior'; DataClassification = CustomerContent; Editable = false;
        }
        field(60451; "Ref 60451"; Code[10])
        {
            Caption = 'Código forma de pago'; DataClassification = CustomerContent; Editable = false;
        }
        field(60452; "Ref 60452"; Code[20])
        {
            Caption = 'Documento de venta'; DataClassification = CustomerContent; Editable = false;
        }
        field(60453; "Ref 60453"; Code[30])
        {
            Caption = 'Número fiscal anterior'; DataClassification = CustomerContent; Editable = false;
        }
        field(28; "Ref 28"; Decimal)
        {
            Caption = 'Importe'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 60450") { Clustered = true; }
    }
}

page 71121 "HN Ref Lista 60459"
{
    Caption = 'Medios de pago POS (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60459"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia60450; Rec."Ref 60450") { ApplicationArea = All; }
                field(Referencia60451; Rec."Ref 60451") { ApplicationArea = All; }
                field(Referencia60452; Rec."Ref 60452") { ApplicationArea = All; }
                field(Referencia60453; Rec."Ref 60453") { ApplicationArea = All; }
                field(Referencia28; Rec."Ref 28") { ApplicationArea = All; }
            }
        }
    }
}

table 71118 "HN Ref Catalogo 60510"
{
    Caption = 'Distribución de pagos (ref.)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Enum "Sales Document Type")
        {
            Caption = 'Tipo de documento'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Code[20])
        {
            Caption = 'Número de documento'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Integer)
        {
            Caption = 'Número de línea'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Code[10])
        {
            Caption = 'Forma de pago'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Decimal)
        {
            Caption = 'Importe con impuestos'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Decimal)
        {
            Caption = 'Porcentaje'; DataClassification = CustomerContent; Editable = false;
        }
        field(7; "Ref 7"; Code[10])
        {
            Caption = 'Moneda'; DataClassification = CustomerContent; Editable = false;
        }
        field(8; "Ref 8"; Text[100])
        {
            Caption = 'Descripción'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1", "Ref 2", "Ref 3") { Clustered = true; }
    }
}

page 71122 "HN Ref Lista 60510"
{
    Caption = 'Distribución de pagos (ref.)'; PageType = List; SourceTable = "HN Ref Catalogo 60510"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
                field(Referencia7; Rec."Ref 7") { ApplicationArea = All; }
                field(Referencia8; Rec."Ref 8") { ApplicationArea = All; }
            }
        }
    }
}

table 71119 "HN Ref Catalogo 60477"
{
    Caption = 'Boletas de compra (referencia)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[20])
        {
            Caption = 'No.'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Date)
        {
            Caption = 'Fecha'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Text[100])
        {
            Caption = 'Nombre Vendedor'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Text[20])
        {
            Caption = 'Identidad Vendedor'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Text[250])
        {
            Caption = 'Descripción Compra'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Decimal)
        {
            Caption = 'Monto Total'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1") { Clustered = true; }
    }
}

page 71123 "HN Ref Lista 60477"
{
    Caption = 'Boletas de compra (referencia)'; PageType = List; SourceTable = "HN Ref Catalogo 60477"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
            }
        }
    }
}

table 71120 "HN Ref Catalogo 60457"
{
    Caption = 'Configuración fiscal (ref.)'; DataClassification = CustomerContent;
    fields
    {
        field(1; "Ref 1"; Code[10])
        {
            Caption = 'Clave Primaria'; DataClassification = CustomerContent; Editable = false;
        }
        field(2; "Ref 2"; Integer)
        {
            Caption = 'Versión Actual DAI'; DataClassification = CustomerContent; Editable = false;
        }
        field(3; "Ref 3"; Text[250])
        {
            Caption = 'Ruta Exportación Informes'; DataClassification = CustomerContent; Editable = false;
        }
        field(4; "Ref 4"; Code[20])
        {
            Caption = 'Serie Comprobantes Retención'; DataClassification = CustomerContent; Editable = false;
        }
        field(5; "Ref 5"; Boolean)
        {
            Caption = 'Validar Número de Factura'; DataClassification = CustomerContent; Editable = false;
        }
        field(6; "Ref 6"; Code[10])
        {
            Caption = 'Template Diario Recepción Efectivos'; DataClassification = CustomerContent; Editable = false;
        }
        field(7; "Ref 7"; Code[10])
        {
            Caption = 'Batch Diario Recepción Efectivos'; DataClassification = CustomerContent; Editable = false;
        }
    }
    keys
    {
        key(PK; "Ref 1") { Clustered = true; }
    }
}

page 71124 "HN Ref Lista 60457"
{
    Caption = 'Configuración fiscal (ref.)'; PageType = List; SourceTable = "HN Ref Catalogo 60457"; Editable = false;
    ApplicationArea = All; UsageCategory = History;
    layout
    {
        area(Content)
        {
            repeater(Referencias)
            {
                field(Referencia1; Rec."Ref 1") { ApplicationArea = All; }
                field(Referencia2; Rec."Ref 2") { ApplicationArea = All; }
                field(Referencia3; Rec."Ref 3") { ApplicationArea = All; }
                field(Referencia4; Rec."Ref 4") { ApplicationArea = All; }
                field(Referencia5; Rec."Ref 5") { ApplicationArea = All; }
                field(Referencia6; Rec."Ref 6") { ApplicationArea = All; }
                field(Referencia7; Rec."Ref 7") { ApplicationArea = All; }
            }
        }
    }
}

