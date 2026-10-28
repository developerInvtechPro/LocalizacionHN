"""Crea una referencia visual ilustrativa; no ejecuta ni renderiza informes de BC."""
from pathlib import Path
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter

R = Path(__file__).resolve().parents[1]
ESTILOS = getSampleStyleSheet()
ESTILOS['Normal'].fontName = 'Helvetica'
ESTILOS['Normal'].fontSize = 8
ESTILOS['Normal'].leading = 11
ESTILOS['Heading2'].alignment = TA_CENTER


def p(texto): return Paragraph(texto, ESTILOS['Normal'])


def tabla(filas, anchos, encabezado=False, alto=None):
    t = Table([[p(str(v)) for v in fila] for fila in filas], colWidths=anchos, rowHeights=[alto]*len(filas) if alto else None)
    reglas = [('VALIGN', (0, 0), (-1, -1), 'TOP'), ('BOX', (0, 0), (-1, -1), .5, colors.grey),
              ('INNERGRID', (0, 0), (-1, -1), .3, colors.lightgrey),
              ('LEFTPADDING', (0, 0), (-1, -1), 5), ('RIGHTPADDING', (0, 0), (-1, -1), 5),
              ('TOPPADDING', (0, 0), (-1, -1), 5), ('BOTTOMPADDING', (0, 0), (-1, -1), 5)]
    if encabezado: reglas += [('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#DEDEDE'))]
    t.setStyle(TableStyle(reglas)); return t


def cabecera(titulo):
    identidad = tabla([['LOGO<br/>(desde configuración)',
                        '<para align="center"><font size="14"><b>EMPRESA DE EJEMPLO</b></font><br/><br/>'
                        '<b>RTN: 00000000000000</b><br/>Dirección de la empresa<br/>Teléfono | Correo electrónico</para>']], [85, 455])
    identidad.setStyle(TableStyle([('BOX',(0,0),(-1,-1),1,colors.black),
                                  ('LINEBEFORE',(1,0),(1,0),0,colors.white),
                                  ('TOPPADDING',(0,0),(-1,-1),12),('BOTTOMPADDING',(0,0),(-1,-1),12)]))
    titulo_caja = tabla([['<para align="center"><b>'+titulo+'</b></para>']], [540])
    titulo_caja.setStyle(TableStyle([('BOX',(0,0),(-1,-1),1,colors.black),('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#F0F0F0'))]))
    fiscal = '<b>Número fiscal:</b> EJEMPLO<br/><br/><b>Documento BC:</b> DEMO-001<br/><br/>' + \
             '<b>Fecha de emisión:</b> 27/10/2026<br/><br/><b>CAI:</b> EJEMPLO SIN VALIDEZ FISCAL<br/><br/>' + \
             '<b>Rango autorizado:</b> EJEMPLO — EJEMPLO<br/><br/><b>Fecha límite de emisión:</b> 31/12/2026'
    tercero = '<b>Cliente / proveedor:</b> Tercero de ejemplo<br/><br/><b>RTN / identidad:</b> 00000000000000<br/><br/><b>Dirección:</b> Dirección del tercero'
    izquierda = tabla([[fiscal]],[266],alto=132); derecha=tabla([[tercero]],[266],alto=132)
    for t in [izquierda,derecha]:
        t.setStyle(TableStyle([('BOX',(0,0),(-1,-1),1,colors.black)]))
    paneles=Table([[izquierda,'',derecha]],colWidths=[266,8,266])
    paneles.setStyle(TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),0)]))
    return [p('<b>VISTA ILUSTRATIVA — DATOS FICTICIOS — NO GENERADA POR BUSINESS CENTRAL</b>'), Spacer(1,10),
            identidad,Spacer(1,5),titulo_caja,Spacer(1,5),paneles,Spacer(1,10)]


def crear():
    elementos = cabecera('FACTURA DE VENTA')
    elementos += [tabla([['Código', 'Descripción', 'Unidad', 'Cantidad', 'Precio unit.', 'Descuento', 'Importe sin ISV'],
                         ['SERV-01', 'Servicio de ejemplo', 'UND', '1.00000', '1,000.0000', '0.00', '1,000.00']], [47, 180, 45, 51, 73, 64, 80], True),
                  Spacer(1, 8), p('<b>Moneda: HNL</b>'), p('Descuentos de línea y de factura. Precio unitario sin ISV.'),
                  tabla([['Base a tasa 0 %', '0.00'], ['Base gravada 15 %', '1,000.00'], ['ISV 15 %', '150.00'],
                         ['Base gravada 18 %', '0.00'], ['ISV 18 %', '0.00'], ['Subtotal sin ISV', '1,000.00'], ['TOTAL HNL', '<b>1,150.00</b>']], [440, 100]),
                  Spacer(1, 8), p('<b>Importe en letras:</b> MIL CIENTO CINCUENTA LEMPIRAS CON 00/100'), Spacer(1, 20),
                  p('Elaborado por: __________________ &nbsp;&nbsp;&nbsp; Recibido por: __________________'),
                  Spacer(1, 10), p('Original: cliente | Copia: obligado tributario emisor'), PageBreak()]
    elementos += cabecera('COMPROBANTE DE RETENCIÓN')
    elementos += [tabla([['Factura proveedor', 'CAI factura', 'Fecha', 'Concepto', 'Base', '%', 'Retenido'],
                         ['DEMO-F01', 'CAI-EJEMPLO-A', '20/10/26', 'Retención de ejemplo', '1,000.00', '12.50', '125.00'],
                         ['DEMO-F02', 'CAI-EJEMPLO-B', '21/10/26', 'Retención de ejemplo', '500.00', '12.50', '62.50']], [90, 104, 58, 115, 65, 40, 68], True),
                  Spacer(1, 12), p('<b>Moneda: HNL</b>'), tabla([['TOTAL RETENIDO HNL', '<b>187.50</b>']], [440, 100]),
                  Spacer(1, 10), p('<b>Importe en letras:</b> CIENTO OCHENTA Y SIETE LEMPIRAS CON 50/100'), Spacer(1, 25),
                  p('Elaborado por: __________________ &nbsp;&nbsp;&nbsp; Recibido por: __________________'),
                  Spacer(1, 10), p('Original: proveedor | Copia: agente de retención'), PageBreak()]
    elementos += cabecera('NOTA DE DÉBITO — MONEDA EXTRANJERA')
    elementos += [tabla([['Factura fiscal de origen: DEMO-FISCAL-001<br/>Fecha origen: 20/10/2026<br/>CAI de origen: EJEMPLO<br/>Motivo: diferencia de precio de ejemplo']], [540]),
                  Spacer(1, 8), tabla([['Código', 'Descripción', 'Unidad', 'Cantidad', 'Precio unit.', 'Descuento', 'Importe sin ISV'],
                                       ['SERV-01', 'Diferencia de precio', 'UND', '1.00000', '126.5000', '0.00', '126.50']], [47, 180, 45, 51, 73, 64, 80], True),
                  Spacer(1, 10), p('<b>Moneda: USD</b>'), tabla([['Subtotal sin ISV', '126.50'], ['Total ISV', '0.00'], ['TOTAL USD', '<b>126.50</b>']], [440, 100]),
                  Spacer(1, 10), p('<b>Importe en letras:</b> CIENTO VEINTISÉIS DÓLARES ESTADOUNIDENSES CON 50/100'),
                  Spacer(1, 25), p('Elaborado por: __________________ &nbsp;&nbsp;&nbsp; Recibido por: __________________'),
                  Spacer(1, 10), p('Original: cliente | Copia: obligado tributario emisor')]
    destino = R / 'documentacion/MUESTRA_FORMATOS_V2.pdf'
    doc = SimpleDocTemplate(str(destino), pagesize=letter, leftMargin=36, rightMargin=36, topMargin=30, bottomMargin=36,
                            title='Muestra ilustrativa de formatos V2', author='INVTECH')
    def pie(c, d):
        c.setFont('Helvetica', 8); c.drawRightString(576, 20, f'Página {d.page} — Vista ilustrativa')
    doc.build(elementos, onFirstPage=pie, onLaterPages=pie)
    print(destino)


if __name__ == '__main__': crear()
