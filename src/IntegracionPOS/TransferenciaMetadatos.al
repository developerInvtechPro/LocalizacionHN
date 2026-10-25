namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;

using Microsoft.Sales.Posting;
codeunit 71102 "HN POS Metadata Transfer"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    begin
        SalesInvHeader."INV POS Transaction No." := SalesHeader."INV POS Transaction No.";
        SalesInvHeader."INV POS Station" := SalesHeader."INV POS Station";
        SalesInvHeader."INV POS Terminal" := SalesHeader."INV POS Terminal";
        SalesInvHeader."INV POS Shift" := SalesHeader."INV POS Shift";
        SalesInvHeader."INV POS Document Type" := SalesHeader."INV POS Document Type";
        SalesInvHeader."INV POS Billing Type" := SalesHeader."INV POS Billing Type";
        SalesInvHeader."INV POS Received Total" := SalesHeader."INV POS Received Total";
        SalesInvHeader."INV POS Received VAT" := SalesHeader."INV POS Received VAT";
        SalesInvHeader."INV POS Operator" := SalesHeader."INV POS Operator";
        SalesInvHeader."INV POS Purchase Order" := SalesHeader."INV POS Purchase Order";
        SalesInvHeader."INV POS Plate" := SalesHeader."INV POS Plate";
        SalesInvHeader."INV POS Mileage" := SalesHeader."INV POS Mileage";
        SalesInvHeader."INV POS Driver" := SalesHeader."INV POS Driver";
        SalesInvHeader."INV POS Comment" := SalesHeader."INV POS Comment";
        SalesInvHeader."INV POS CAI Code" := SalesHeader."INV POS CAI Code";
        SalesInvHeader."INV POS CAI" := SalesHeader."INV POS CAI";
        SalesInvHeader."INV POS CAI Expiration" := SalesHeader."INV POS CAI Expiration";
        SalesInvHeader."INV POS CAI Start" := SalesHeader."INV POS CAI Start";
        SalesInvHeader."INV POS CAI End" := SalesHeader."INV POS CAI End";
        SalesInvHeader."INV POS Exemption Code" := SalesHeader."INV POS Exemption Code";
        SalesInvHeader."INV POS Exempted Amount" := SalesHeader."INV POS Exempted Amount";
        SalesInvHeader."INV POS Exempt Order" := SalesHeader."INV POS Exempt Order";
        SalesInvHeader."INV POS Exemption Register" := SalesHeader."INV POS Exemption Register";
        SalesInvHeader."INV POS SAG Reference" := SalesHeader."INV POS SAG Reference";
        SalesInvHeader."INV POS Additional CAI" := SalesHeader."INV POS Additional CAI";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header")
    begin
        SalesCrMemoHeader."INV POS Transaction No." := SalesHeader."INV POS Transaction No.";
        SalesCrMemoHeader."INV POS Station" := SalesHeader."INV POS Station";
        SalesCrMemoHeader."INV POS Terminal" := SalesHeader."INV POS Terminal";
        SalesCrMemoHeader."INV POS Shift" := SalesHeader."INV POS Shift";
        SalesCrMemoHeader."INV POS Document Type" := SalesHeader."INV POS Document Type";
        SalesCrMemoHeader."INV POS Billing Type" := SalesHeader."INV POS Billing Type";
        SalesCrMemoHeader."INV POS Received Total" := SalesHeader."INV POS Received Total";
        SalesCrMemoHeader."INV POS Received VAT" := SalesHeader."INV POS Received VAT";
        SalesCrMemoHeader."INV POS Operator" := SalesHeader."INV POS Operator";
        SalesCrMemoHeader."INV POS Purchase Order" := SalesHeader."INV POS Purchase Order";
        SalesCrMemoHeader."INV POS Plate" := SalesHeader."INV POS Plate";
        SalesCrMemoHeader."INV POS Mileage" := SalesHeader."INV POS Mileage";
        SalesCrMemoHeader."INV POS Driver" := SalesHeader."INV POS Driver";
        SalesCrMemoHeader."INV POS Comment" := SalesHeader."INV POS Comment";
        SalesCrMemoHeader."INV POS CAI Code" := SalesHeader."INV POS CAI Code";
        SalesCrMemoHeader."INV POS CAI" := SalesHeader."INV POS CAI";
        SalesCrMemoHeader."INV POS CAI Expiration" := SalesHeader."INV POS CAI Expiration";
        SalesCrMemoHeader."INV POS CAI Start" := SalesHeader."INV POS CAI Start";
        SalesCrMemoHeader."INV POS CAI End" := SalesHeader."INV POS CAI End";
        SalesCrMemoHeader."INV POS Exemption Code" := SalesHeader."INV POS Exemption Code";
        SalesCrMemoHeader."INV POS Exempted Amount" := SalesHeader."INV POS Exempted Amount";
        SalesCrMemoHeader."INV POS Exempt Order" := SalesHeader."INV POS Exempt Order";
        SalesCrMemoHeader."INV POS Exemption Register" := SalesHeader."INV POS Exemption Register";
        SalesCrMemoHeader."INV POS SAG Reference" := SalesHeader."INV POS SAG Reference";
        SalesCrMemoHeader."INV POS Additional CAI" := SalesHeader."INV POS Additional CAI";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure OnBeforeSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesLine: Record "Sales Line")
    begin
        SalesInvLine."INV POS Pump" := SalesLine."INV POS Pump";
        SalesInvLine."INV POS Pump Position" := SalesLine."INV POS Pump Position";
        SalesInvLine."INV POS Tank" := SalesLine."INV POS Tank";
        SalesInvLine."INV POS Line Operator" := SalesLine."INV POS Line Operator";
        SalesInvLine."INV POS Received VAT Rate" := SalesLine."INV POS Received VAT Rate";
        SalesInvLine."INV POS Line Received VAT" := SalesLine."INV POS Line Received VAT";
        SalesInvLine."INV POS Line Received Total" := SalesLine."INV POS Line Received Total";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoLineInsert(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesLine: Record "Sales Line")
    begin
        SalesCrMemoLine."INV POS Pump" := SalesLine."INV POS Pump";
        SalesCrMemoLine."INV POS Pump Position" := SalesLine."INV POS Pump Position";
        SalesCrMemoLine."INV POS Tank" := SalesLine."INV POS Tank";
        SalesCrMemoLine."INV POS Line Operator" := SalesLine."INV POS Line Operator";
        SalesCrMemoLine."INV POS Received VAT Rate" := SalesLine."INV POS Received VAT Rate";
        SalesCrMemoLine."INV POS Line Received VAT" := SalesLine."INV POS Line Received VAT";
        SalesCrMemoLine."INV POS Line Received Total" := SalesLine."INV POS Line Received Total";
    end;

}
