"""Añade datos de presentación a los informes existentes, sin cambiar sus IDs."""
from pathlib import Path
import re

RAIZ = Path(__file__).resolve().parents[1]


def ampliar():
    for nombre in ['Comprobantes.al', 'DocumentosYMovimientos.al', 'BoletasCompra.al']:
        ruta = RAIZ / 'src/Informes' / nombre
        partes = re.split(r'(?m)(?=^report \d+ )', ruta.read_text())
        for i, informe in enumerate(partes):
            if not informe.startswith('report '): continue
            if 'column(Logo_Base64;' in informe:
                if 'column(Print_Date;' not in informe:
                    informe = informe.replace('column(Logo_Base64;', 'column(Print_Date; FechaImpresionFormato) { }\n            column(Logo_Base64;')
                    informe = informe.replace('        DatosFormato: Codeunit', '        FechaImpresionFormato: Text;\n        DatosFormato: Codeunit')
                    informe = informe.replace('        DatosFormato.CargarEmpresa(', '        FechaImpresionFormato := Format(CurrentDateTime());\n        DatosFormato.CargarEmpresa(')
                    partes[i] = informe
                continue
            documento = 'column(Document_No;' in informe
            campos = {'Print_Date': 'FechaImpresionFormato', 'Logo_Base64': 'LogoFormato', 'Logo_MIME': 'TipoLogoFormato', 'Issuer_Contact': 'ContactoFormato'}
            if documento:
                moneda = re.search(r'column\(Currency_Code; (.*?)\)', informe)[1]
                total = re.search(r'column\(Total_Amount; (.*?)\)', informe)[1]
                campos.update(Currency_Label=f'DatosFormato.RotuloMoneda({moneda})', Amount_In_Words=f'DatosFormato.Letras({total},{moneda})')
                retencion = '"HN Retention Header"' in informe
                if not retencion:
                    campos['Due_Date'] = 'Format("Due Date")'
                    # Solo se muestran las referencias propias guardadas; no se leen campos antiguos.
                    boleta = 'column(Exempt_Order;' in informe
                    if not boleta:
                        compra = 'dataitem(Cabecera; "Purch' in informe
                        campos['Exempt_Order'] = "''" if compra else '"INV POS Exempt Order"'
                        campos['Exempt_Register'] = "''" if compra else '"INV POS Exemption Register"'
                        campos['SAG_Register'] = "''" if compra else '"INV POS SAG Reference"'
                    campos['Prices_Include_Tax'] = '"Prices Including VAT"'
                    lineas = {
                        'Line_Code': '"No."', 'Line_Unit': '"Unit of Measure Code"',
                        'Line_Discount': '"Line Discount Amount" + "Inv. Discount Amount"',
                        'Line_Tax': '"Amount Including VAT" - Amount',
                    }
                    punto = informe.index('column(Line_Quantity;')
                    informe = informe[:punto] + '\n                '.join(f'column({k}; {v}) {{ }}' for k, v in lineas.items()) + '\n                ' + informe[punto:]
                else:
                    punto = informe.index('column(Line_Invoice;')
                    informe = informe[:punto] + 'column(Line_Code; "Retention Code") { }\n                ' + informe[punto:]
            else:
                campos['Report_RTN'] = 'Empresa."VAT Registration No."'
                # Los códigos vacíos representan moneda local; no fijar lempiras en informes de divisas.
                informe = re.sub(r"column\(Moneda; (.*?)\) \{ \}", lambda m: 'column(Moneda; DatosFormato.Moneda(' + ("''" if m[1] in ["'ML'"] else m[1]) + ')) { }', informe)
            punto = informe.index('column(')
            informe = informe[:punto] + '\n            '.join(f'column({k}; {v}) {{ }}' for k, v in campos.items()) + '\n            ' + informe[punto:]
            inicializar = '        FechaImpresionFormato := Format(CurrentDateTime());\n        DatosFormato.CargarEmpresa(LogoFormato,TipoLogoFormato,ContactoFormato);\n'
            if 'trigger OnPreReport()' in informe:
                informe = informe.replace('trigger OnPreReport()\n    begin\n', 'trigger OnPreReport()\n    begin\n' + inicializar)
            else:
                punto = informe.rfind('\n    var\n')
                if punto < 0: punto = informe.rfind('\n}')
                informe = informe[:punto] + '\n    trigger OnPreReport()\n    begin\n' + inicializar + '    end;\n' + informe[punto:]
            variables = ('        FechaImpresionFormato: Text;\n        DatosFormato: Codeunit "HN Datos Formatos";\n'
                         '        LogoFormato: Text;\n        TipoLogoFormato: Text;\n        ContactoFormato: Text;\n')
            if '\n    var\n' in informe:
                punto = informe.rfind('\n    var\n') + len('\n    var\n')
                informe = informe[:punto] + variables + informe[punto:]
            else:
                punto = informe.rfind('\n}')
                informe = informe[:punto] + '\n    var\n' + variables + informe[punto:]
            partes[i] = informe
        ruta.write_text(''.join(partes))


if __name__ == '__main__':
    ampliar()
