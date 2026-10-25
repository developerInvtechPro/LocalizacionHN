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

codeunit 50105 "HN Setup Management"
{
    procedure GetSetup(var Setup: Record "HN Localization Setup")
    begin
        if Setup.Get('') then exit;
        Setup.LockTable();
        if Setup.Get('') then exit;
        Setup.Init();
        Setup."Primary Key" := '';
        Setup.Insert(true);
    end;

    procedure CheckDebitConfiguration(var Setup: Record "HN Localization Setup")
    begin
        GetSetup(Setup);
        if not Setup."Debit Notes Enabled" or (Setup."Debit Note Nos." = '') then
            Error('Abra Configuración general en el menú de acciones, habilite Notas de débito HN y seleccione la serie interna antes de crear el documento.');
    end;

    procedure EnsureDebitConfiguration(): Boolean
    var
        Setup: Record "HN Localization Setup";
    begin
        GetSetup(Setup);
        if Setup."Debit Notes Enabled" and (Setup."Debit Note Nos." <> '') then exit(true);
        // Se ejecuta al abrir el documento, antes de editarlo o registrarlo.
        // Conserva la configuración inicial antes de abrir la ventana de configuración.
        Commit();
        Page.RunModal(Page::"HN Localization Setup", Setup);
        GetSetup(Setup);
        exit(Setup."Debit Notes Enabled" and (Setup."Debit Note Nos." <> ''));
    end;
}
