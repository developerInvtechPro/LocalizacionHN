namespace INVTECH.Honduras;
page 71113 "HN Centro Informes"
{
    Caption = 'Centro de informes de localización HN';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    layout
    {
        area(Content)
        {
            group(Indicaciones)
            {
                Caption = 'Informes y comprobantes';
                label(Informacion) { ApplicationArea = All; Caption = 'En esta etapa V2 imprime retenciones y notas de débito. Para los demás documentos utilice las acciones habituales y los formatos anteriores hasta definir su migración.'; }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Informe0) { Caption = 'Comprobante de retención'; ApplicationArea = All; Image = Print; RunObject = report "HN Retention Certificate"; }
            action(Informe1) { Caption = 'Comprobante de nota de débito'; ApplicationArea = All; Image = Print; RunObject = report "HN Debit Note Certificate"; }
            action(Informe8) { Caption = 'Borrador de retención'; ApplicationArea = All; Image = Print; RunObject = report "HN Borrador Retencion"; }
        }
    }
}
