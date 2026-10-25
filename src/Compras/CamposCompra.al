namespace INVTECH.Honduras;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

tableextension 50104 "HN Purchase Retention Line" extends "Purchase Line"
{
    fields
    {
        field(50100; "HN Retention Codes"; Text[250])
        {
            Caption = 'Códigos de retención HN';
            trigger OnValidate()
            var
                Management: Codeunit "HN Retention Management";
            begin
                Management.CalculatePurchaseLine(Rec);
            end;
        }
        field(50101; "HN Retention Amount"; Decimal) { Caption = 'Retención HN estimada'; Editable = false; }
    }
}
tableextension 50105 "HN Purchase Retention Header" extends "Purchase Header"
{
    fields
    {
        field(50100; "HN Retention Amount"; Decimal) { Caption = 'Retención HN estimada'; Editable = false; }
        field(50102; "HN Vendor CAI"; Code[37]) { Caption = 'CAI del documento del proveedor HN'; }
    }
}
tableextension 50106 "HN Posted Purchase Ret Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(50100; "HN Retention Codes"; Text[250]) { Caption = 'Códigos de retención HN'; Editable = false; }
        field(50101; "HN Retention Amount"; Decimal) { Caption = 'Retención HN calculada'; Editable = false; }
    }
}
tableextension 50107 "HN Posted Purchase Ret Header" extends "Purch. Inv. Header"
{
    fields { field(50102; "HN Vendor CAI"; Code[37]) { Caption = 'CAI del documento del proveedor HN'; Editable = false; } }
}
pageextension 50104 "HN Purchase Invoice CAI" extends "Purchase Invoice"
{
    layout { addafter("Vendor Invoice No.") { field(HNVendorCAI; Rec."HN Vendor CAI") { ApplicationArea = All; } } }
}
pageextension 50105 "HN Purchase Order CAI" extends "Purchase Order"
{
    layout { addafter("Vendor Invoice No.") { field(HNVendorCAI; Rec."HN Vendor CAI") { ApplicationArea = All; } } }
}
pageextension 50106 "HN Posted Purchase Invoice CAI" extends "Posted Purchase Invoice"
{
    layout { addafter("Vendor Invoice No.") { field(HNVendorCAI; Rec."HN Vendor CAI") { ApplicationArea = All; Editable = false; } } }
}
