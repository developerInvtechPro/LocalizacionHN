"""Diseños V2 basados en las muestras entregadas: identidad, cajas, tabla y firmas.

No importa datasets ni código de los informes anteriores. Lee las columnas AL
actuales y conserva los números de informe y nombres de diseño publicados.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as E

R = Path(__file__).resolve().parents[1]
D = R / 'src/Informes/Disenos'
NS = 'http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition'
E.register_namespace('', NS)
def q(n): return '{' + NS + '}' + n
def nodo(p, n, texto=None, **atributos):
    e = E.SubElement(p, q(n), atributos)
    if texto is not None: e.text = str(texto)
    return e


def cuadro(p, nombre, valor, ancho=None, alto=None, izquierda=None, arriba=None,
           negrita=False, tamano=8, fondo=None, alineacion='Left', formato=None, borde=True,
           lineas=None, color_borde='#B8B8B8', grosor_borde='0.5pt'):
    t = nodo(p, 'Textbox', Name=nombre)
    nodo(t, 'CanGrow', 'true'); nodo(t, 'KeepTogether', 'true')
    parrafos = nodo(t, 'Paragraphs'); parrafo = nodo(parrafos, 'Paragraph')
    runs = nodo(parrafo, 'TextRuns'); run = nodo(runs, 'TextRun'); nodo(run, 'Value', valor)
    estilo = nodo(run, 'Style'); nodo(estilo, 'FontFamily', 'Arial'); nodo(estilo, 'FontSize', f'{tamano}pt')
    if negrita: nodo(estilo, 'FontWeight', 'Bold')
    if formato: nodo(estilo, 'Format', formato)
    nodo(nodo(parrafo, 'Style'), 'TextAlign', alineacion)
    if lineas:
        # Etiquetas destacadas sin poner en negrita los valores del documento.
        parrafos.clear()
        for etiqueta, expresion in lineas:
            parrafo = nodo(parrafos, 'Paragraph'); runs = nodo(parrafo, 'TextRuns')
            for texto, destacado in [(etiqueta, True), (expresion, False)]:
                run = nodo(runs, 'TextRun'); nodo(run, 'Value', texto)
                estilo = nodo(run, 'Style'); nodo(estilo, 'FontFamily', 'Arial'); nodo(estilo, 'FontSize', f'{tamano}pt')
                if destacado: nodo(estilo, 'FontWeight', 'Bold')
            estilo = nodo(parrafo, 'Style'); nodo(estilo, 'TextAlign', alineacion); nodo(parrafo, 'SpaceAfter', '4pt')
    for n, v in [('Top', arriba), ('Left', izquierda), ('Height', alto), ('Width', ancho)]:
        if v is not None: nodo(t, n, f'{v}in')
    estilo = nodo(t, 'Style')
    nodo(estilo, 'VerticalAlign', 'Middle')
    if borde and (valor != '' or lineas):
        linea = nodo(estilo, 'Border'); nodo(linea, 'Color', color_borde); nodo(linea, 'Style', 'Solid'); nodo(linea, 'Width', grosor_borde)
    if fondo: nodo(estilo, 'BackgroundColor', fondo)
    for n in ['PaddingLeft', 'PaddingRight', 'PaddingTop', 'PaddingBottom']: nodo(estilo, n, '3pt')
    return t


class Diseno:
    def __init__(self, titulo, campos, documento=True, retencion=False):
        self.campos = campos; self.documento = documento; self.retencion = retencion; self.filas = []
        self.scope = 'Documento' if documento else 'DataSet_Result'
        self.ancho = 7.5 if documento else 10
        self.pesos = ([1.25, 1.45, .8, 1.6, .9, .55, .95] if retencion else [.7, 2.65, .55, .65, 1, .9, 1.05]) if documento else [.85, 1.4, 1, 3, .9, .9, .95, 1]
        self.root = E.Element(q('Report'))
        fuentes = nodo(self.root, 'DataSources'); fuente = nodo(fuentes, 'DataSource', Name='DataSource')
        con = nodo(fuente, 'ConnectionProperties'); nodo(con, 'DataProvider', 'SQL'); nodo(con, 'ConnectString', '')
        datasets = nodo(self.root, 'DataSets'); dataset = nodo(datasets, 'DataSet', Name='DataSet_Result')
        fields = nodo(dataset, 'Fields')
        for campo in sorted(campos): nodo(nodo(fields, 'Field', Name=campo), 'DataField', campo)
        consulta = nodo(dataset, 'Query'); nodo(consulta, 'DataSourceName', 'DataSource'); nodo(consulta, 'CommandText', '')
        seccion = nodo(nodo(self.root, 'ReportSections'), 'ReportSection')
        cuerpo = nodo(seccion, 'Body'); items = nodo(cuerpo, 'ReportItems')
        self.tabla = nodo(items, 'Tablix', Name='ComprobanteHN' if documento else 'MovimientosHN')
        body = nodo(self.tabla, 'TablixBody'); columnas = nodo(body, 'TablixColumns')
        for w in self.pesos: nodo(nodo(columnas, 'TablixColumn'), 'Width', f'{w}in')
        self.rows = nodo(body, 'TablixRows')
        self.fila([(7 if documento else 8, '', {})], alto=1.15, logo=True)
        self.fila([(len(self.pesos), '', {'borde': False})], alto=.05)
        self.fila([(len(self.pesos), titulo, {'negrita': True, 'tamano': 13, 'fondo': '#F0F0F0', 'alineacion': 'Center', 'color_borde': '#000000', 'grosor_borde': '1pt'})], alto=.30)
        self.fila([(len(self.pesos), '', {'borde': False})], alto=.07)
        self.seccion = seccion; self.cuerpo = cuerpo

    def f(self, campo):
        return f'First(Fields!{campo}.Value, "{self.scope}")' if campo in self.campos else '""'

    def dato(self, etiqueta, campo): return f'"{etiqueta}" & {self.f(campo)}'

    def fila(self, celdas, alto=.28, detalle=False, logo=False, ocultar=None, paneles=None):
        fila = nodo(self.rows, 'TablixRow'); nodo(fila, 'Height', f'{alto}in'); cells = nodo(fila, 'TablixCells')
        for i, (span, valor, opciones) in enumerate(celdas):
            cell = nodo(cells, 'TablixCell'); contents = nodo(cell, 'CellContents'); name = f'Fila{len(self.filas)}Col{i}'
            if paneles:
                rect = nodo(contents, 'Rectangle', Name=name); its = nodo(rect, 'ReportItems')
                ancho = self.ancho/2-.04
                for j, lineas in enumerate(paneles):
                    tb = cuadro(its, 'DatosFiscales' if j == 0 else 'DatosTercero', '',
                                ancho=ancho, alto=alto, izquierda=0 if j == 0 else self.ancho/2+.04,
                                arriba=0, lineas=lineas, tamano=8,
                                color_borde='#000000', grosor_borde='1pt')
                    estilo = tb.find(q('Style')); estilo.find(q('VerticalAlign')).text = 'Top'
                nodo(rect, 'KeepTogether', 'true'); nodo(rect, 'Style')
            elif logo:
                rect = nodo(contents, 'Rectangle', Name=name); its = nodo(rect, 'ReportItems')
                img = nodo(its, 'Image', Name='LogoEmpresa')
                nodo(img, 'Source', 'Database')
                nodo(img, 'Value', '=System.Convert.FromBase64String(' + self.f('Logo_Base64') + ')')
                nodo(img, 'MIMEType', '=' + self.f('Logo_MIME'))
                nodo(img, 'Sizing', 'FitProportional'); nodo(img, 'Top', '.08in'); nodo(img, 'Left', '.08in')
                nodo(img, 'Height', '.95in'); nodo(img, 'Width', '1.05in')
                nodo(nodo(img, 'Visibility'), 'Hidden', '=Len(' + self.f('Logo_Base64') + ')=0')
                nombre = 'Issuer_Name' if self.documento else 'Empresa'
                rtn = 'Issuer_RTN' if self.documento else 'Report_RTN'
                comun = dict(ancho=self.ancho-1.25, izquierda=1.18, alineacion='Center', borde=False)
                cuadro(its, 'IdentidadEmpresa', '=' + self.f(nombre), alto=.43, arriba=.02, negrita=True, tamano=14, **comun)
                cuadro(its, 'RTNEmpresa', '="RTN: " & ' + self.f(rtn), alto=.20, arriba=.46, negrita=True, tamano=8, **comun)
                cuadro(its, 'DireccionEmpresa', '=' + self.f('Issuer_Address'), alto=.22, arriba=.66, tamano=8, **comun)
                cuadro(its, 'ContactoEmpresa', '=' + self.f('Issuer_Contact'), alto=.20, arriba=.89, tamano=8, **comun)
                nodo(rect, 'KeepTogether', 'true')
                borde = nodo(nodo(rect, 'Style'), 'Border'); nodo(borde, 'Color', '#000000'); nodo(borde, 'Style', 'Solid'); nodo(borde, 'Width', '1pt')
            else:
                cuadro(contents, name, valor, **opciones)
            if span > 1:
                nodo(contents, 'ColSpan', span)
                # RDL conserva una celda física por columna. Las cubiertas
                # por ColSpan no pueden contener CellContents.
                for _ in range(span - 1): nodo(cells, 'TablixCell')
        self.filas.append({'detalle': detalle, 'ocultar': ocultar})

    def cerrar(self, ruta):
        cols = nodo(nodo(self.tabla, 'TablixColumnHierarchy'), 'TablixMembers')
        for _ in self.pesos: nodo(cols, 'TablixMember')
        miembros = nodo(nodo(self.tabla, 'TablixRowHierarchy'), 'TablixMembers')
        if self.documento:
            member = nodo(miembros, 'TablixMember'); grupo = nodo(member, 'Group', Name='Documento')
            nodo(nodo(grupo, 'GroupExpressions'), 'GroupExpression', '=Fields!Document_No.Value')
            nodo(nodo(grupo, 'PageBreak'), 'BreakLocation', 'Between')
            miembros = nodo(member, 'TablixMembers')
        detalle_visto = False
        for fila in self.filas:
            m = nodo(miembros, 'TablixMember')
            if fila['detalle']:
                nodo(m, 'Group', Name='Lineas'); detalle_visto = True
            else:
                nodo(m, 'KeepWithGroup', 'Before' if detalle_visto else 'After')
                if not detalle_visto: nodo(m, 'RepeatOnNewPage', 'true')
            if fila['ocultar'] is not None: nodo(nodo(m, 'Visibility'), 'Hidden', fila['ocultar'])
        nodo(self.tabla, 'DataSetName', 'DataSet_Result'); nodo(self.tabla, 'Top', '0in'); nodo(self.tabla, 'Left', '0in')
        nodo(self.tabla, 'Height', sum(float(r.find(q('Height')).text[:-2]) for r in self.rows).__str__()+'in')
        nodo(self.tabla, 'Width', f'{self.ancho}in'); nodo(self.tabla, 'Style')
        nodo(self.cuerpo, 'Height', '2in'); nodo(self.cuerpo, 'Style'); nodo(self.seccion, 'Width', f'{self.ancho}in')
        pagina = nodo(self.seccion, 'Page'); pie = nodo(pagina, 'PageFooter'); nodo(pie, 'Height', '.35in')
        nodo(pie, 'PrintOnFirstPage', 'true'); nodo(pie, 'PrintOnLastPage', 'true')
        items = nodo(pie, 'ReportItems')
        cuadro(items, 'Paginacion', '="Página " & Globals!PageNumber & " de " & Globals!TotalPages', ancho=2, alto=.25, izquierda=self.ancho-2, arriba=0, tamano=8, alineacion='Right', borde=False)
        cuadro(items, 'Impresion', '="Impreso: " & First(Fields!Print_Date.Value,"DataSet_Result")', ancho=3.5, alto=.25, izquierda=0, arriba=0, tamano=8, borde=False)
        nodo(pie, 'Style')
        nodo(pagina, 'PageHeight', '11in' if self.documento else '8.5in'); nodo(pagina, 'PageWidth', '8.5in' if self.documento else '11in')
        for n in ['LeftMargin', 'RightMargin', 'TopMargin', 'BottomMargin']: nodo(pagina, n, '.5in')
        nodo(pagina, 'Style'); nodo(self.root, 'Language', 'es-HN')
        nodo(self.root, 'ConsumeContainerWhitespace', 'true')
        E.indent(self.root, space='  '); E.ElementTree(self.root).write(ruta, encoding='utf-8', xml_declaration=True)


def crear_retencion_compacta(ruta, campos):
    # Diseño anterior elegido por el usuario; se conserva el CAI de cabecera
    # y el dato histórico de líneas, pero no se imprime la columna CAI factura.
    arbol = E.parse(R / 'herramientas/plantillas/RetencionCompacta.rdlc')
    raiz = arbol.getroot()
    borrador = 'Borrador' in ruta.stem
    for valor in raiz.findall('.//' + q('Value')):
        if valor.text == 'COMPROBANTE DE RETENCIÓN' and borrador:
            valor.text = 'BORRADOR DE RETENCIÓN'
        if borrador and valor.text == 'Original: proveedor | Copia: agente de retención':
            valor.text = 'BORRADOR — SIN VALIDEZ FISCAL'
    fields = raiz.find('.//' + q('Fields')); fields.clear()
    for campo in sorted(campos): nodo(nodo(fields, 'Field', Name=campo), 'DataField', campo)
    E.indent(raiz, space='  '); arbol.write(ruta, encoding='utf-8', xml_declaration=True)


def crear_documento(ruta, titulo, campos):
    if ruta.name == 'NotaDebito.rdlc':
        from nota_debito_compacta import crear_nota_debito
        crear_nota_debito(ruta, campos)
        return
    retencion = 'Line_Invoice' in campos
    if retencion:
        crear_retencion_compacta(ruta, campos)
        return
    d = Diseno(titulo, campos, retencion=retencion)
    compra = any(s in ruta.stem for s in ['Compra', 'Boleta', 'Retencion'])
    boleta = 'Boleta' in ruta.stem
    fiscal = [('Número fiscal: ', '='+d.f('Fiscal_No')),
              ('Documento BC: ', '='+d.f('Document_No')),
              ('Fecha de emisión: ', '='+d.f('Issue_Date'))]
    if 'Due_Date' in campos: fiscal.append(('Fecha de vencimiento: ', '='+d.f('Due_Date')))
    fiscal += [('CAI: ', '='+d.f('CAI_Value')),
               ('Rango autorizado: ', '='+d.f('CAI_Range')),
               ('Fecha límite de emisión: ', '='+d.f('CAI_Expiration'))]
    tercero = [('Proveedor: ' if compra else 'Cliente: ', '='+d.f('Party_Name')),
               ('RTN / identidad: ', '='+d.f('Party_RTN'))]
    if 'Party_Address' in campos: tercero.append(('Dirección: ', '='+d.f('Party_Address')))
    if 'Exempt_Order' in campos:
        tercero += [('Orden de compra exenta: ', '='+d.f('Exempt_Order')),
                    ('Registro SAG: ', '='+d.f('SAG_Register')),
                    ('Constancia de exonerados: ', '='+d.f('Exempt_Register'))]
    d.fila([(7, '', {})], alto=1.65, paneles=[fiscal, tercero])
    d.fila([(7, '', {'borde': False})], alto=.10)
    if 'Reason' in campos:
        expr = '=' + d.dato('Factura de origen: ', 'Source_No') + ' & "  |  " & ' + d.dato('Fecha origen: ', 'Source_Date') + ' & vbCrLf & ' + d.dato('CAI de origen: ', 'Source_CAI') + ' & vbCrLf & ' + d.dato('Motivo: ', 'Reason')
        ocultar = '=Len(' + d.f('Source_No') + ' & ' + d.f('Reason') + ')=0'
        d.fila([(7, expr, {})], alto=.5, ocultar=ocultar)
    if 'Cancellation_Label' in campos:
        d.fila([(7, '=' + d.f('Cancellation_Label') + ' & "  " & ' + d.f('Cancellation_Reason') + ' & "  " & ' + d.f('Cancellation_Date'), {'negrita': True, 'alineacion': 'Center'})], ocultar='=Len(' + d.f('Cancellation_Label') + ')=0')
    if retencion:
        etiquetas = ['Factura proveedor', 'CAI factura', 'Fecha factura', 'Concepto de retención', 'Base', '%', 'Retenido']
        campos_linea = ['Line_Invoice', 'Line_Invoice_CAI', 'Line_Invoice_Date', 'Line_Description', 'Line_Base', 'Line_Rate', 'Line_Amount']
    else:
        etiquetas = ['Código', 'Descripción', 'Unidad', 'Cantidad', 'Precio unit.', 'Descuento*', 'Importe sin ISV']
        campos_linea = ['Line_Code', 'Line_Description', 'Line_Unit', 'Line_Quantity', 'Line_Unit_Price', 'Line_Discount', 'Line_Base']
    d.fila([(1, e, {'negrita': True, 'fondo': '#DEDEDE', 'tamano': 8}) for e in etiquetas], alto=.35)
    numericos = {'Line_Quantity': 'N5', 'Line_Unit_Price': 'N4', 'Line_Discount': 'N2', 'Line_Base': 'N2', 'Line_Rate': 'N2', 'Line_Amount': 'N2'}
    d.fila([(1, '=Fields!'+f+'.Value', {'formato': numericos.get(f), 'alineacion': 'Right' if f in numericos else 'Left'}) for f in campos_linea], detalle=True, alto=.3)
    d.fila([(7, '=' + d.dato('Moneda de los importes: ', 'Currency_Label'), {'negrita': True})])
    if not retencion:
        expr = '="* Descuentos de línea y de factura. Precio unitario " & IIF(' + d.f('Prices_Include_Tax') + ',"con ISV incluido.","sin ISV.")'
        d.fila([(7, expr, {'tamano': 7})])
        # Calcular sobre las líneas reales, sin confundir una tasa cero con una exoneración.
        if not boleta:
            for etiqueta, expr in [
                ('Base a tasa 0 %', 'Sum(IIF(Fields!Line_Rate.Value=0,Fields!Line_Base.Value,0),"Documento")'),
                ('Base gravada 15 %', 'Sum(IIF(Fields!Line_Rate.Value=15,Fields!Line_Base.Value,0),"Documento")'),
                ('ISV 15 %', 'Sum(IIF(Fields!Line_Rate.Value=15,Fields!Line_Tax.Value,0),"Documento")'),
                ('Base gravada 18 %', 'Sum(IIF(Fields!Line_Rate.Value=18,Fields!Line_Base.Value,0),"Documento")'),
                ('ISV 18 %', 'Sum(IIF(Fields!Line_Rate.Value=18,Fields!Line_Tax.Value,0),"Documento")'),
                ('Base otras tasas', 'Sum(IIF(Fields!Line_Rate.Value<>0 And Fields!Line_Rate.Value<>15 And Fields!Line_Rate.Value<>18,Fields!Line_Base.Value,0),"Documento")'),
                ('ISV otras tasas', 'Sum(IIF(Fields!Line_Rate.Value<>0 And Fields!Line_Rate.Value<>15 And Fields!Line_Rate.Value<>18,Fields!Line_Tax.Value,0),"Documento")'),
            ]:
                d.fila([(4, '', {}), (2, etiqueta, {'fondo': '#F0F0F0'}), (1, '='+expr, {'formato': 'N2', 'alineacion': 'Right'})], alto=.24)
        for etiqueta, campo in [('Subtotal sin ISV', 'Subtotal_Amount'), ('Total ISV', 'Tax_Amount')]:
            d.fila([(4, '', {}), (2, etiqueta, {'fondo': '#F0F0F0'}), (1, '='+d.f(campo), {'formato': 'N2', 'alineacion': 'Right'})], alto=.25)
    d.fila([(4, '', {}), (2, 'TOTAL RETENIDO' if retencion else 'TOTAL', {'negrita': True, 'fondo': '#D8D8D8'}), (1, '='+d.f('Total_Amount'), {'negrita': True, 'formato': 'N2', 'alineacion': 'Right'})], alto=.3)
    d.fila([(7, '=' + d.dato('Importe en letras: ', 'Amount_In_Words'), {'negrita': True})], alto=.4)
    if boleta:
        d.fila([(7, 'Documento sin crédito fiscal de ISV. Firma del proveedor: __________________ Huella: __________', {})], alto=.45)
    else:
        d.fila([(3, 'Elaborado por: __________________', {}), (4, 'Recibido / autorizado por: __________________', {})], alto=.65)
    leyenda = ('Original: proveedor | Copia: agente de retención' if retencion else
               'Original: contribuyente adquirente | Copia: proveedor' if boleta else
               'Documento de control interno; no sustituye el comprobante del proveedor' if compra else
               'Original: cliente | Copia: obligado tributario emisor')
    if 'Borrador' in ruta.stem: leyenda = 'BORRADOR — SIN VALIDEZ FISCAL'
    d.fila([(7, leyenda, {'tamano': 7, 'alineacion': 'Center'})])
    d.cerrar(ruta)


def crear_movimientos(ruta, titulo, campos):
    d = Diseno(titulo, campos, documento=False)
    impuesto = 'ISV' in ruta.stem
    etiquetas = ['Fecha / límite', 'Documento', 'Tercero', 'Descripción / referencia', 'Base' if impuesto else 'Debe', 'ISV' if impuesto else 'Haber', 'Importe' if any(x in ruta.stem for x in ['Contables', 'Aplicaciones']) else 'Saldo pendiente', 'Moneda']
    d.fila([(1, e, {'negrita': True, 'fondo': '#DCE6EE'}) for e in etiquetas], alto=.35)
    detalle = ['Fecha', 'Documento', 'Tercero', 'Descripcion', 'Debe', 'Haber', 'Saldo', 'Moneda']
    d.fila([(1, '=Fields!'+f+'.Value', {'formato': 'N2' if f in ['Debe', 'Haber', 'Saldo'] else None, 'alineacion': 'Right' if f in ['Debe', 'Haber', 'Saldo'] else 'Left'}) for f in detalle], detalle=True, alto=.3)
    d.fila([(8, 'Importes en la moneda indicada por fila. Los saldos pendientes corresponden a la consulta actual.', {'tamano': 7})])
    d.cerrar(ruta)


def sustituir():
    cantidad = 0
    for archivo in (R / 'src/Informes').glob('*.al'):
        for informe in re.split(r'(?m)^report \d+ ', archivo.read_text())[1:]:
            campos = set(re.findall(r'column\((\w+);', informe))
            rutas = re.findall(r"LayoutFile\s*=\s*'([^']+)'", informe)
            for ruta in rutas:
                destino = R / ruta
                titulo = re.search(r"Caption\s*=\s*'((?:''|[^'])*)'", informe)[1].replace("''", "'")
                (crear_documento if 'Document_No' in campos else crear_movimientos)(destino, titulo.upper(), campos)
                cantidad += 1
    print(f'{cantidad} formatos sustituidos con datasets propios V2 y esquema RDLC 2016.')


if __name__ == '__main__':
    sustituir()
