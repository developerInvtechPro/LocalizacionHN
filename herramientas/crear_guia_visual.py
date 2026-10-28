"""Genera una guía ilustrada a partir del código AL; no captura pantallas de Business Central.
Requiere ReportLab. La revisión opcional del PDF utiliza PyMuPDF.
"""
from pathlib import Path
import json
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, Color, white
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import simpleSplit

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'documentacion/Guia_visual_LocalizacionHN_V2.pdf'
VERSION = json.loads((ROOT / 'app.json').read_text())['version']
FONTROOT = Path('/System/Library/Fonts/Supplemental')
for name, filename in [('UI', 'Arial.ttf'), ('Bold', 'Arial Bold.ttf')]:
    pdfmetrics.registerFont(TTFont(name, str(FONTROOT / filename)))
W, H = landscape(A4)
NAVY = HexColor('#102B3B'); TEAL = HexColor('#008478'); BLUE = HexColor('#2174A5')
INK = HexColor('#203743'); MUTED = HexColor('#617580'); LINE = HexColor('#D7E2E7')
BG = HexColor('#F2F6F7'); PALE = HexColor('#E6F3EF'); ORANGE = HexColor('#AC6417')
TOTAL = 25
c = canvas.Canvas(str(OUT), pagesize=(W, H), pageCompression=1)
c.setTitle('Guía visual | Localización Honduras V2')
c.setAuthor('INVTECH')
c.setSubject('Procesos, pantallas ilustrativas y funciones implementadas. Sin capturas de Business Central.')


def text(x, y, s, size=10, color=INK, bold=False):
    c.setFillColor(color); c.setFont('Bold' if bold else 'UI', size)
    c.drawString(x, y, str(s))


def para(x, y, s, width, size=10, color=INK, leading=None, bold=False):
    leading = leading or size * 1.42
    lines = simpleSplit(str(s), 'Bold' if bold else 'UI', size, width)
    for line in lines:
        text(x, y, line, size, color, bold); y -= leading
    return y


def box(x, y, w, h, fill=white, stroke=LINE, radius=7):
    c.setFillColor(fill)
    c.setStrokeColor(stroke or fill)
    c.roundRect(x, y, w, h, radius, fill=1, stroke=bool(stroke))


def rule(x1, y1, x2, y2, color=LINE, width=0.6):
    c.setStrokeColor(color); c.setLineWidth(width); c.line(x1, y1, x2, y2)


def pill(x, y, label, fill=PALE, color=TEAL, size=8):
    w = pdfmetrics.stringWidth(label, 'Bold', size) + 20
    box(x, y, w, 20, fill, None, 10)
    text(x + 10, y + 6, label, size, color, True)
    return w


def arrow(x1, y1, x2, y2, color=TEAL):
    import math
    rule(x1, y1, x2, y2, color, 1.4)
    a = math.atan2(y2-y1, x2-x1)
    path = c.beginPath(); path.moveTo(x2, y2)
    for d in [-0.45, 0.45]: path.lineTo(x2-7*math.cos(a+d), y2-7*math.sin(a+d))
    path.close(); c.setFillColor(color); c.drawPath(path, stroke=0, fill=1)


def page(n, section, title, subtitle):
    c.setFillColor(BG); c.rect(0, 0, W, H, fill=1, stroke=0)
    text(40, H-32, 'INVTECH  /  LOCALIZACIÓN HONDURAS', 9, TEAL, True)
    c.setFont('UI', 8); c.setFillColor(MUTED); c.drawRightString(W-40, H-32, f'Versión {VERSION}  |  27 octubre 2026')
    text(40, H-69, title, 24, NAVY, True)
    para(40, H-91, subtitle, W-80, 10, MUTED)
    rule(40, 42, W-40, 42)
    text(40, 27, 'PANTALLAS ILUSTRATIVAS · Basadas en el código AL; no son capturas de Business Central.', 7, MUTED)
    c.setFont('Bold', 8); c.drawRightString(W-40, 27, f'{n:02d} / {TOTAL}')
    c.bookmarkPage(f'p{n}'); c.addOutlineEntry(section, f'p{n}', level=0)


def end(): c.showPage()


def notes(items, y=64, h=74):
    gap=14; width=(W-80-gap*(len(items)-1))/len(items)
    for i,(title,body) in enumerate(items):
        x=40+i*(width+gap)
        box(x,y,width,h,white,None)
        text(x+13,y+h-20,title,10,TEAL,True)
        para(x+13,y+h-37,body,width-26,9,MUTED,12)


def screen(x,y,w,h,title,actions=(),caption='Empresa de ejemplo', zoom=1):
    box(x+2,y-2,w,h,HexColor('#DCE5E8'),None)
    box(x,y,w,h,white,LINE,6)
    c.setFillColor(NAVY);c.roundRect(x,y+h-29,w,29,6,fill=1,stroke=0)
    c.rect(x,y+h-29,w,12,fill=1,stroke=0)
    text(x+15,y+h-19,'Dynamics 365  |  Business Central',8,white)
    c.setFont('UI',7);c.drawRightString(x+w-13,y+h-19,caption)
    text(x+17,y+h-55,title,15 if w>500 else 12,NAVY,True)
    c.setFont('Bold',6);c.setFillColor(MUTED);c.drawRightString(x+w-14,y+h-52,'ILUSTRACIÓN')
    ax=x+17
    for i,label in enumerate(actions):
        size=8 if w>500 else 7
        aw=pdfmetrics.stringWidth(label,'UI',size)+18
        if i==0:
            box(ax,y+h-83,aw,20,TEAL,None,3);text(ax+9,y+h-76,label,size,white)
        else:text(ax+5,y+h-76,label,size,TEAL)
        ax+=aw+7
    rule(x+15,y+h-94,x+w-15,y+h-94)
    return (x+18,y+h-111,w-36)


def field(x,y,label,value,w=220,highlight=False):
    text(x,y,label,7.5,MUTED)
    box(x,y-26,w,20,PALE if highlight else white,TEAL if highlight else LINE,2)
    text(x+7,y-19,value,8.3,INK)


def group(x,y,label,w):
    text(x,y,label,10,NAVY,True);rule(x,y-7,x+w,y-7)


def table(x,y,width,headers,rows,weights=None,size=8,rowh=24):
    weights=weights or [1]*len(headers)
    widths=[width*z/sum(weights) for z in weights]
    c.setFillColor(HexColor('#E9F1F3'));c.rect(x,y-rowh,width,rowh,fill=1,stroke=0)
    xpos=x
    for label,cw in zip(headers,widths):
        text(xpos+7,y-rowh+8,label,size,MUTED,True);xpos+=cw
    y-=rowh
    for ri,row in enumerate(rows):
        if ri%2==1:
            c.setFillColor(HexColor('#F7F9FA'));c.rect(x,y-rowh,width,rowh,fill=1,stroke=0)
        xpos=x
        for value,cw in zip(row,widths):
            value=str(value)
            while pdfmetrics.stringWidth(value,'UI',size)>cw-13 and len(value)>1:
                value=value[:-2]+'…'
            text(xpos+7,y-rowh+8,value,size,INK);xpos+=cw
        rule(x,y-rowh,x+width,y-rowh)
        y-=rowh
    return y


def section_strip(x,y,w,label):
    box(x,y-22,w,27,PALE,None,3);text(x+9,y-12,label,9,TEAL,True)


def ledger(x,y,w,rows,total_label=None):
    return table(x,y,w,['Movimiento / cuenta','Debe','Haber'],rows,[4,1.3,1.3],9,27)


# 1 — Portada
c.setFillColor(NAVY);c.rect(0,0,W,H,fill=1,stroke=0)
c.bookmarkPage('p1');c.addOutlineEntry('01 · Presentación','p1',0)
text(45,H-48,'INVTECH  /  GUÍA FUNCIONAL',11,HexColor('#77DDD0'),True)
text(45,H-123,'Localización',40,white,True);text(45,H-170,'Honduras V2',40,white,True)
para(47,H-213,'Retenciones y notas de débito\nProceso completo, pantallas y comprobantes',430,18,HexColor('#BFD4DC'),27)
pill(47,206,'VERSIÓN '+VERSION,TEAL,white,9)
pill(47,173,'INDEPENDIENTE DE LA LOCALIZACIÓN ANTERIOR',HexColor('#214757'),white,8)
# Trazado vectorial de la portada.
for yy,label in [(399,'CONFIGURAR'),(318,'PREPARAR'),(237,'REGISTRAR')]:
    box(580,yy,190,53,HexColor('#214757'),None,8)
    text(599,yy+21,label,12,white,True)
    if yy>237:arrow(675,yy-3,675,yy-25,HexColor('#77DDD0'))
box(45,64,W-90,76,HexColor('#E7F3EF'),None)
text(62,117,'Cómo leer este documento',11,TEAL,True)
para(62,98,'Las pantallas son representaciones vectoriales del código desarrollado. No son capturas reales ni evidencias de pruebas en Business Central. Todos los datos e importes son ficticios.',W-125,10,INK,14)
text(47,32,'24 OCTUBRE 2026  ·  DOCUMENTO DE REVISIÓN FUNCIONAL',8,HexColor('#BFD4DC'))
end()

# 2 — Resumen gráfico e índice enlazado.
page(2,'02 · Mapa del proceso','Dos módulos, una base común','Las páginas, configuraciones, campos y comprobantes de la nueva extensión son propios.')
for row_y,label,steps,color in [
    (365,'RETENCIONES',['Configurar','Compra','Factura registrada','Borrador','Registro e histórico'],TEAL),
    (246,'NOTAS DE DÉBITO',['Configurar','Seleccionar origen','Agregar cargos','Registrar','Histórico e imprimir'],BLUE)]:
    text(42,row_y+65,label,10,color,True)
    stepw=139;gap=16
    for i,s in enumerate(steps):
        x=40+i*(stepw+gap)
        box(x,row_y,stepw,49,white,LINE)
        text(x+11,row_y+31,f'{i+1:02d}',9,color,True)
        para(x+11,row_y+16,s,stepw-20,9,INK,11)
        if i<4:arrow(x+stepw+2,row_y+24,x+stepw+gap-2,row_y+24,color)
box(40,157,W-80,61,PALE,None)
text(55,195,'CAI disponible desde el menú de acciones',12,TEAL,True)
text(55,177,'Configuración a demanda; el número fiscal se asigna al registrar.',10)
notes([('Páginas 03–06','Configuración, conceptos, CAI y campos de compra.'),('Páginas 07–10','Generación, borrador, registro y comprobante de retención.'),('Páginas 11–16','Notas de débito, controles, estado y prueba del proceso.')],y=62,h=74)
for x,target in [(40,3),(299,7),(558,11)]:c.linkRect('',f'p{target}',(x,62,x+245,136),relative=0,thickness=0)
end()

# 3 — Configuración y proveedor.
page(3,'03 · Configuración y proveedor','Preparar la empresa y el proveedor','Primero se habilitan los módulos y sus series; luego se configura la condición de retención de cada proveedor.')
a=screen(40,166,369,307,'Configuración localización HN')
x,y,w=a
field(x,y,'Habilitar retenciones HN','Sí',w,True);field(x,y-53,'Habilitar notas de débito HN','Sí',w,True)
field(x,y-106,'Serie interna de retenciones','HN-RET',155);field(x+173,y-106,'Serie de notas de débito','HN-ND',155)
a=screen(431,166,370,307,'Ficha de proveedor')
x,y,w=a
field(x,y,'Proveedor','P-DEMO · Proveedor de ejemplo',w)
field(x,y-53,'Sujeto a retención HN','Sí',w,True)
field(x,y-106,'Vencimiento condición de retención HN','31/12/2026',w)
notes([('Campos propios','Los indicadores anteriores no se leen ni se copian automáticamente.'),('Serie interna','Identifica el documento de trabajo; es diferente del número fiscal del CAI.'),('Convivencia','Habilitar V2 no desactiva el motor anterior; debe resolverse aparte.')])
end()

# 4 — Conceptos.
page(4,'04 · Conceptos de retención','Definir cómo se calcula cada retención','Catálogo propio: código, porcentaje, base, mínimo, cuenta y estado activo.')
x,y,w=screen(40,166,W-80,307,'Conceptos de retención HN',['Nuevo','Editar lista'])
table(x,y,w,['Código','Descripción','Base','%','Mínimo','Cuenta fiscal','Activo'],[
    ['RET-A','Ejemplo sobre neto','Sin impuesto','12,50','0,00','FISCAL-A','Sí'],
    ['RET-B','Ejemplo sobre ISV','Impuesto','50,00','0,00','FISCAL-B','Sí']],
    [1,2.3,1.6,.7,.8,1.2,.6],8,28)
section_strip(x,y-102,w,'Fórmula: importe = redondear(base seleccionada × porcentaje / 100)')
para(x+8,y-148,'En el ejemplo: base neta 10.000,00 e impuesto 1.500,00. RET-A = 1.250,00; RET-B = 750,00. Total retenido = 2.000,00.',w-16,11,INK,16)
notes([('Selección explícita','Se aplican únicamente los códigos seleccionados en la línea.'),('Mínimo y redondeo','Se evalúa el mínimo y se usa la precisión de la moneda.'),('Datos de demostración','Estos porcentajes ilustran el cálculo; no constituyen tasas legales recomendadas.')])
end()

# 5 — CAI disponible desde las acciones.
page(5,'05 · CAI desde acciones','Configurar el CAI solo cuando se necesita','La lista permanece limpia; Acciones > Configurar CAI abre las autorizaciones del tipo correspondiente.')
x,y,w=screen(40,166,W-80,307,'Retenciones HN',['Generar desde factura registrada','Retenciones registradas','Acciones'])
table(x,y,w,['Número interno','Proveedor','Factura registrada','Retenido','Estado'],[
    ['RET-0001','Proveedor de ejemplo','FC-00040','2.000,00','Borrador']],
    [1.1,2,1.4,1,.9],8,25)
box(115,190,612,163,white,TEAL,6)
text(132,329,'Acciones > Configurar CAI · Retenciones',12,TEAL,True)
table(132,311,577,['Código','CAI','Número inicial','Número final','Próximo número','Hasta'],[
    ['RET-2026','XXXXXX-…-XX','000-001-05-00000001','000-001-05-00000100','000-001-05-00000001','31/12/2026']],
    [1,1,2,2,2,1.1],7,26)
para(132,230,'La ventana permite editar vigencia, rango, habilitación y próximo correlativo. El CAI mostrado es un dato ficticio.',575,9,MUTED,13)
notes([('Sin panel permanente','La configuración aparece solo después de elegir la acción.'),('Filtro por módulo','Retenciones y notas de débito abren sus propias autorizaciones.'),('Al registrar','Se valida y consume un correlativo dentro de la operación de registro.')])
end()

# 6 — Compra.
page(6,'06 · Compra y selección de conceptos','Indicar retenciones en las líneas de compra','Se usan campos nuevos en pedidos y facturas de compra, sin reutilizar los de otra extensión.')
x,y,w=screen(40,166,W-80,307,'Pedido de compra · PC-00040',['Registrar'],caption='Compra de ejemplo')
field(x,y,'Proveedor','P-DEMO · Proveedor de ejemplo',280)
field(x+304,y,'CAI del documento del proveedor HN','XXXXXX-XXXXXX-…-XX',w-304,True)
table(x,y-55,w,['Línea','Descripción','Importe neto','ISV','Códigos de retención HN','Retención estimada'],[
    ['10000','Servicio de ejemplo','10.000,00','1.500,00','RET-A,RET-B','2.000,00']],
    [.7,2.3,1.2,1,2,1.5],8,27)
section_strip(x,y-131,w,'Compra 11.500,00  |  Retención estimada 2.000,00  |  Códigos seleccionados: 2')
para(x,y-173,'Al registrar la factura se conservan las selecciones en campos propios. Si el pedido se factura parcialmente, la retención definitiva usa solo lo facturado.',w,10,INK,14)
notes([('Selección múltiple','El selector permite uno o varios conceptos; también se pueden escribir códigos separados por comas.'),('Factura directa','Los mismos campos están disponibles al trabajar con facturas de compra sin pedido.'),('Control de códigos','Se rechazan códigos duplicados, inexistentes o inactivos.')])
end()

# 7 — Generación.
page(7,'07 · Generar el comprobante','Partir de una factura de compra registrada','La generación es manual y crea un borrador; no registra la retención ni emite todavía el número fiscal.')
x,y,w=screen(40,166,W-80,307,'Retenciones HN',['Generar desde factura registrada','Retenciones registradas'])
table(x,y,w,['Número interno','Proveedor','Factura','Retenido','Estado'],[],[1,2,1.5,1,1],8,24)
# Ventana superpuesta.
box(179,195,482,202,white,TEAL,7)
text(197,371,'Seleccionar factura de compra registrada',13,NAVY,True)
table(195,352,450,['Factura','Proveedor','Neto','Total'],[
    ['FC-00040','Proveedor de ejemplo','10.000,00','11.500,00']],
    [1.2,2.4,1.2,1.2],8,28)
para(197,270,'Al aceptar, el sistema revisa el proveedor y las selecciones; después crea las líneas del comprobante.',445,10,MUTED,14)
pill(540,212,'Aceptar',TEAL,white)
notes([('Origen','Una o varias facturas del mismo proveedor y moneda.'),('Evitar duplicados','Se bloquea otro comprobante de V2 para la misma factura.'),('Requisito','La factura debe tener códigos HN y conceptos que produzcan un importe positivo.')])
end()

# 8 — Ficha del borrador.
page(8,'08 · Revisar el borrador','Comprobar base, importe y autorización','El cálculo toma los valores de la factura registrada. Recalcular solo está disponible en borradores.')
x,y,w=screen(40,166,W-80,307,'Comprobante de retención HN · RET-0001',['Recalcular','Vista previa de registro','Registrar','Imprimir comprobante'])
field(x,y,'Proveedor','Proveedor de ejemplo',224)
field(x+247,y,'Factura registrada','FC-00040',224)
field(x+494,y,'Autorización CAI','RET-2026',w-494,True)
table(x,y-54,w,['Concepto','Línea factura','Base imponible','%','Importe','Cuenta'],[
    ['RET-A · Ejemplo neto','10000','10.000,00','12,50','1.250,00','FISCAL-A'],
    ['RET-B · Ejemplo ISV','10000','1.500,00','50,00','750,00','FISCAL-B']],
    [2.5,1.2,1.4,.7,1.2,1.3],8,26)
section_strip(x,y-151,w,'Estado: Borrador  |  Total retenido: 2.000,00  |  Número fiscal: aún no emitido')
notes([('Revisión','Verifique proveedor, RTN, factura, moneda, fecha y cuenta fiscal.'),('Recalcular','Actualiza el borrador con los conceptos propios vigentes.'),('CAI desde acciones','La ficha permite abrir Configurar CAI sin mantener una tabla de autorizaciones visible.')])
end()

# 9 — Contabilización e histórico de retenciones.
page(9,'09 · Registrar y consultar retenciones','La retención reduce el saldo del proveedor','Esquema contable ilustrativo. Las cuentas, dimensiones y efectos de moneda dependen de la configuración estándar.')
x,y,w=screen(40,166,444,307,'Vista previa de registro',['Revisar movimientos'])
ledger(x,y,w,[['Proveedor · aplicación a FC-00040','2.000,00',''],['Retención por pagar · FISCAL-A','','1.250,00'],['Retención por pagar · FISCAL-B','','750,00']])
section_strip(x,y-134,w,'Debe 2.000,00 = Haber 2.000,00')
para(x,y-173,'En este caso: saldo de factura 11.500,00 menos retención 2.000,00 = saldo 9.500,00.',w,10,INK,14)
x,y,w=screen(505,166,296,307,'Retenciones registradas HN')
field(x,y,'Número interno','RET-0001',w)
field(x,y-54,'Número fiscal','000-001-05-00000001',w,True)
field(x,y-108,'Estado','Registrado',w)
notes([('Vista previa','Simula los movimientos y revierte los cambios; no deja un número fiscal consumido.'),('Registro definitivo','Contabiliza y aplica a la factura. No deja diarios pendientes bajo estado registrado.'),('Histórico','Permite consultar el documento, imprimirlo y abrir los movimientos del proveedor.')])
end()


def certificate(n,title,docno,rows,total,source,reason=None):
    # Ilustración del comprobante; el diseño RDLC requiere renderizado en Business Central.
    box(40,163,474,312,white,LINE)
    text(58,450,'EMISOR DE EJEMPLO',13,NAVY,True)
    text(58,432,'RTN: dato ficticio  |  Dirección del emisor',8,MUTED)
    text(58,403,title,14,TEAL,True)
    text(58,384,'Número: '+docno,10,INK,True)
    text(58,368,'Fecha: 22/10/2026   |   Moneda: HNL',8)
    text(58,349,'Cliente/proveedor: registro de ejemplo',8)
    text(58,334,'Factura origen: '+source,8)
    yy=318
    if reason:
        text(58,yy,'Motivo: '+reason,8);yy-=16
    text(58,yy,'CAI: XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XX',7.4);yy-=19
    table(58,yy,438,['Concepto','Base','%','Importe'],rows,[2.4,1.3,.7,1.3],7.5,23)
    text(58,207,'TOTAL: '+total,12,TEAL,True)
    text(58,190,'Rango y fecha límite de emisión: conservados en el documento.',7.4,MUTED)
    text(58,178,'EJEMPLO ILUSTRATIVO · NO ES UN DOCUMENTO FISCAL VÁLIDO',6.7,ORANGE,True)
    text(540,444,'Información conservada',14,NAVY,True)
    yy=414
    for label,body in [('Datos del emisor','Nombre, RTN y dirección.'),('Identificación fiscal','Número, CAI, rango y fecha límite.'),('Trazabilidad','Documento origen y detalles del cálculo.'),('Reimpresión','Se consulta un documento registrado; no se asigna otro número.')]:
        text(540,yy,label,10,TEAL,True)
        yy=para(540,yy-18,body,245,10,MUTED,14)-21
    notes([('Diseño esquemático','Representación del contenido del reporte, no una captura de su renderizado.'),('Validación pendiente','La distribución exacta y la impresión real deben revisarse en sandbox.'),('Datos ficticios','Nombres, números, CAI e importes se muestran exclusivamente para explicación.')])

# 10 — Comprobante de retención.
page(10,'10 · Comprobante de retención','Imprimir el comprobante registrado','El reporte usa la información fiscal y de cálculo conservada por la nueva extensión.')
certificate(10,'COMPROBANTE DE RETENCIÓN','000-001-05-00000001',[
    ['RET-A · Ejemplo neto','10.000,00','12,50','1.250,00'],
    ['RET-B · Ejemplo ISV','1.500,00','50,00','750,00']],
    '2.000,00','000-001-01-00000040')
end()

# 11 — Lista de notas de débito con CAI disponible desde acciones.
page(11,'11 · Página principal de notas de débito','Una lista de documentos sin panel de CAI','Las autorizaciones se abren desde Acciones > Configurar CAI; no se muestran debajo de los documentos.')
x,y,w=screen(40,166,W-80,307,'Notas de débito HN',['Nueva nota de débito','Notas de débito registradas','Acciones'])
table(x,y,w,['Número','Cliente','Fecha','Factura origen','Total con ISV','Moneda'],[
    ['ND-0001','Cliente de ejemplo','22/10/2026','FV-00125','1.150,00','HNL']],
    [1.1,2.2,1.3,1.3,1.3,.8],8,25)
box(563,255,212,90,white,TEAL,4)
text(579,320,'Acciones',11,NAVY,True)
text(579,296,'Configurar CAI',10,TEAL,True)
text(579,274,'Configuración general',10,INK)
notes([('Página principal limpia','Solo muestra los documentos; no contiene campos ni paneles de CAI.'),('Configuración a demanda','La acción abre una ventana filtrada a notas de débito.'),('Histórico del módulo','Se muestran las notas registradas por esta extensión; no se mezclan datos ajenos.')])
end()

# 12 — Datos fiscales de la nota de débito mediante una acción específica.
page(12,'12 · Crear la nota de débito','Referenciar la factura y agregar el cargo','El CAI y su autorización se editan desde Acciones > Datos fiscales, fuera de la sección general.')
x,y,w=screen(40,166,W-80,307,'Nota de débito HN · ND-0001',['Seleccionar factura origen','Vista previa de registro','Registrar e imprimir','Acciones'])
field(x,y,'Cliente','C-DEMO · Cliente de ejemplo',224)
field(x+247,y,'Factura origen','FV-00125 · 20/10/2026',224)
field(x+494,y,'Fecha de emisión','22/10/2026',w-494)
field(x,y-50,'Número fiscal factura origen','000-001-01-00000125',224)
field(x+247,y-50,'Motivo nota de débito','Ajuste de precio del servicio',w-247)
table(x,y-100,w,['Tipo','N.º / descripción','Cantidad','Precio','ISV','Total'],[
    ['Cuenta contable','Cargo adicional de ejemplo','1','1.000,00','150,00','1.150,00']],
    [1.1,3,1,1.2,1.1,1.1],8,27)
notes([('Primer acceso','Si faltan la habilitación o la serie, se abre Configuración general antes de crear la nota.'),('Datos fiscales','Desde esta acción se completa el CAI del origen y se selecciona la autorización de la nota.'),('Registro estándar','Business Central calcula impuestos y movimientos según la configuración de las líneas.')])
end()

# 13 — Registro de la nota de débito.
page(13,'13 · Registrar y consultar notas de débito','Crear el saldo adicional del cliente','La referencia a la factura es documental: la nota genera su propio saldo por cobrar.')
x,y,w=screen(40,166,444,307,'Vista previa de registro',['Revisar movimientos'])
ledger(x,y,w,[['Cuenta por cobrar del cliente','1.150,00',''],['Cargo / ingreso configurado','','1.000,00'],['ISV según configuración','','150,00']])
section_strip(x,y-134,w,'Ejemplo: cargo 1.000,00 + ISV 150,00 = 1.150,00')
para(x,y-173,'Las cuentas y el tratamiento del impuesto provienen de la configuración estándar de Business Central.',w,10,INK,14)
x,y,w=screen(505,166,296,307,'Notas de débito registradas HN')
field(x,y,'Número interno / factura registrada','Documento registrado de ejemplo',w)
field(x,y-54,'Número fiscal propio','000-001-07-00000001',w,True)
field(x,y-108,'Factura origen / motivo','FV-00125 · Ajuste de precio',w)
notes([('Antes de registrar','La vista previa permite revisar el efecto contable sin emitir definitivamente.'),('Registrar e imprimir','Primero se completa el registro y después se solicita la impresión del comprobante.'),('Consulta posterior','El histórico permite abrir el documento, imprimirlo y buscar sus movimientos.')])
end()

# 14 — Comprobante de la nota de débito.
page(14,'14 · Comprobante de nota de débito','Mostrar el cargo y su factura de origen','El reporte incluye motivo, identificación fiscal del documento afectado, detalle, impuestos y total.')
certificate(14,'NOTA DE DÉBITO','000-001-07-00000001',[
    ['Cargo adicional de ejemplo','1.000,00','15,00','1.150,00']],
    '1.150,00','000-001-01-00000125','Ajuste de precio del servicio')
end()

# 15 — Controles y estado.
page(15,'15 · Controles y alcance','Qué controla la versión desarrollada','Las verificaciones están implementadas en código; su comportamiento completo todavía requiere pruebas en Business Central.')
controls=[
    ('CAI y correlativo','Vigencia, formato, tipo de documento, rango y último número. Control de duplicados dentro de los datos de V2.'),
    ('Cálculo de retención','Códigos seleccionados, estado activo, porcentaje, base mínima y precisión de moneda.'),
    ('Registro de retención','Comprobante en borrador, importe positivo y saldo pendiente suficiente de la factura.'),
    ('Origen de la nota de débito','Cliente y moneda coincidentes, motivo, fecha y datos fiscales de la factura origen.'),
]
for i,(title,body) in enumerate(controls):
    x=40+(i%2)*389;y=323-(i//2)*126
    box(x,y,372,110,white,None)
    pill(x+15,y+73,f'CONTROL {i+1:02d}')
    text(x+15,y+51,title,13,NAVY,True)
    para(x+15,y+32,body,342,9.5,MUTED,13)
notes([('Independencia comprobada','Compila usando solo símbolos de Microsoft y campos propios.'),('Pruebas preparadas','71 pruebas AL compiladas; pendientes de ejecución en sandbox.'),('Comprobantes','Datasets y XML verificados; renderizado e impresión real pendientes.')],y=62,h=74)
end()

# 16 — Recorrido completo y pendientes.
page(16,'16 · Prueba guiada y siguiente etapa','Cómo revisar el proceso de principio a fin','Usar una empresa de prueba y datos controlados antes de habilitar la operación real.')
box(40,168,465,307,white,None)
text(57,447,'Recorrido de aceptación',16,NAVY,True)
steps=[
    '1. Configurar series, conceptos y proveedor; abrir CAI desde Acciones.',
    '2. Registrar una compra con conceptos RET-A y RET-B.',
    '3. Generar la retención, revisar el borrador y previsualizar.',
    '4. Registrar, conciliar movimientos y reimprimir el comprobante.',
    '5. Crear una nota de débito sobre una factura de venta.',
    '6. Previsualizar, registrar, imprimir y verificar su histórico.',
    '7. Repetir con errores, vencimiento, facturación parcial y moneda.',
]
y=416
for s in steps:y=para(58,y,s,425,10,INK,14)-14
box(525,168,276,307,HexColor('#FFF4E5'),None)
text(542,447,'Pendiente de desarrollo',15,ORANGE,True)
y=418
for s in ['Resolver conflictos de IDs y validar la migración POS preparada.','Pruebas de anulación y reversión automática por devoluciones o abonos.','Notas de débito de proveedores y exportaciones de declaraciones.']:
    y=para(542,y,s,240,10,INK,14)-18
text(542,235,'Convivencia con el sistema anterior',10,ORANGE,True)
para(542,216,'V2 no desactiva sus suscriptores. Se debe dejar fuera de operación el motor anterior y conciliar los correlativos antes del cambio.',240,9.5,INK,13)
notes([('Lo que acredita este PDF','Explica el código y el flujo previsto con ilustraciones; no acredita pruebas operativas.'),('Después del sandbox','Las ilustraciones pueden sustituirse por capturas reales y resultados de las pruebas.'),('Referencia del proyecto','Código en src/ y procedimiento detallado en documentacion/VALIDACION_SANDBOX.md.')],y=62,h=74)
end()
# 17 — Facturas agrupadas y anulación.
page(17,'17 · Facturas múltiples y anulación','Conservar el comprobante y sus movimientos','Pantallas ilustrativas de la versión 1.2.4.0; los movimientos y la impresión requieren prueba real en sandbox.')
x,y,w=screen(40,166,465,307,'Comprobante de retención HN',['Agregar facturas','Anular','Crear sustituto'])
field(x,y,'Proveedor / moneda','PROV-001 · HNL',w)
table(x,y-55,w,['Factura proveedor','Base','Retención'],[
    ['000-001-01-00000125','10.000,00','1.250,00'],
    ['000-001-01-00000126','4.000,00','500,00']])
para(x,y-170,'Total retenido: 1.750,00. Cada línea conserva factura, fecha y CAI de origen. Se valida el saldo por factura.',w,10,INK,14)
x,y,w=screen(525,166,276,307,'Anular retención')
field(x,y,'Motivo','Error en comprobante',w)
field(x,y-54,'Fecha contable','Fecha permitida por BC',w)
para(x,y-114,'Desliquidar → compensar → conservar documento como ANULADA. Un error revierte toda la operación.',w,10,INK,14)
para(x,y-164,'Crear sustituto genera otro borrador vinculado. El nuevo correlativo se asigna al registrarlo.',w,10,INK,14)
notes([('Documentos emitidos','Se conservan CAI, correlativo, líneas, motivo, fecha y usuario de anulación.'),('SAR','Una retención declarada requiere referencia de tratamiento fiscal externo. No se cambian declaraciones.'),('Origen anterior','Comprobantes V2 antiguos sin vínculo al movimiento requieren conciliación antes de anular.')],y=62,h=74)
end()

# 18 — Preparación de migración y bloqueo de despliegue.
page(18,'18 · Preparación de migración POS','Copiar metadatos sin perder su origen','Estado: preparación local. La API existente y los datos de Business Central permanecen sin cambios.')
x,y,w=screen(40,166,465,307,'Verificación de migración HN',['Verificar o copiar metadatos'])
field(x,y,'Tabla','Cliente / documento / línea',w)
field(x,y-54,'Aplicar copia','Desactivado para verificar primero',w)
para(x,y-116,'68 correspondencias confirmadas: validar propietario, ID, nombre, tipo y longitud. Copiar solo destinos vacíos; conservar origen y registrar conflictos.',w,10,INK,14)
para(x,y-164,'Los metadatos nuevos se transfieren explícitamente al registrar facturas y abonos, sin alterar importes estándar.',w,10,INK,14)
box(525,166,276,307,HexColor('#FFF4E5'),None)
text(542,446,'DESPLIEGUE BLOQUEADO',14,ORANGE,True)
para(542,416,'Se detectaron 14 conflictos preexistentes entre V2 y API_BCPOS 1.0.0.41: objetos y campos con el mismo ID y distinto significado.',240,11,INK,16)
para(542,315,'Resolver el traslado de propiedad/datos antes de instalar ambas juntas. No renumerar directamente ni usar ForceSync para eliminar información.',240,10,INK,14)
notes([('Preparado','Mapa de campos, copia manual con diagnóstico y transferencia de metadatos al registrar.'),('Antes del corte','Adaptar receptor y cierre, resolver CAI/exoneraciones y conciliar históricos.'),('Pruebas requeridas','Reenvíos, múltiples sucursales, devoluciones, pagos múltiples, T3 y cierre completo.')],y=62,h=74)
end()
# 19 — Configuración de la emisión desde pedidos y facturas.
page(19,'19 · Configuración de facturación','Preparar ventas y validación de compras','Configuración propia por empresa. La habilitación y la autorización se revisan antes de registrar.')
x,y,w=screen(40,166,465,307,'Configuración de facturación HN',['Autorizaciones CAI de ventas','CAI de proveedores'])
field(x,y,'Habilitar facturación de ventas HN','Sí',w)
field(x,y-52,'Autorización de facturas / tipo 01','FACT-2026',w)
field(x,y-104,'Autorización de notas de crédito / tipo 06','NC-2026',w)
field(x,y-156,'Aplicación al registrar','Automática; sin reservar en borradores',w)
x,y,w=screen(525,166,276,307,'Controles antes de emitir')
para(x,y,'1. Información de empresa y RTN.\n2. Series estándar de BC.\n3. CAI y rango por tipo fiscal.\n4. Fecha de emisión válida.\n5. Preparar el documento sin fiscal.\n6. Vista previa y registro.',w,11,INK,19)
notes([('Número interno','Se mantiene el documento estándar de Business Central.'),('Número fiscal','Se consume al facturar, con un correlativo nuevo por factura registrada.'),('Compras','La misma configuración permite exigir la autorización del proveedor al contabilizar.')],y=62,h=74)
end()

# 20 — Autorizaciones por proveedor y rango.
page(20,'20 · Gestión de CAI de proveedores','Identificar al proveedor y conservar varios CAI','Lista ilustrativa del catálogo propio. No se amplía la vigencia de autorizaciones utilizadas.')
x,y,w=screen(40,166,W-80,307,'Gestión de CAI de proveedores HN',['Nuevo','Administrar'])
table(x,y-10,w,['Proveedor','Nombre','Código','CAI','Fecha límite'],[
 ['P-DEMO','Proveedor de ejemplo','AUT-01','XXXXXX-…-XX','31/12/2026'],
 ['P-DEMO','Proveedor de ejemplo','AUT-02','YYYYYY-…-YY','31/03/2027']],weights=[.12,.26,.13,.30,.19],rowh=32)
para(x,y-130,'Cada registro conserva tipo, establecimiento/punto, rango y fechas. La selección se hace por proveedor emisor, número y fecha del documento.',w,11,INK,17)
para(x,y-170,'Si varias autorizaciones coinciden, el usuario debe elegir. Si no hay una válida, el registro de la factura se detiene.',w,11,INK,17)
notes([('Nombre visible','La identificación del proveedor se muestra junto a su código.'),('Fecha comprobada','Se utiliza la fecha real de emisión de la factura o abono del proveedor.'),('Histórico','Se conservan CAI, rango y límite de emisión en el documento registrado.')],y=62,h=74)
end()

# 21 — Registro común de la facturación.
page(21,'21 · Factura desde pedido o factura directa','Un control de CAI para ambos recorridos','Los envíos sin facturación no consumen número de factura. Los borradores se identifican como documentos de trabajo.')
for x,title,steps in [(40,'PEDIDO DE VENTA',['Cliente, fechas, líneas y dimensiones','CAI automático al registrar','Enviar y facturar / facturar parcialmente']), (431,'FACTURA DIRECTA',['Cliente, fechas y líneas','CAI automático al registrar','Validar y registrar'])]:
 box(x,275,370,198,white,None)
 text(x+18,443,title,14,NAVY,True)
 yy=414
 for i,step in enumerate(steps):yy=para(x+18,yy,f'{i+1}. {step}',333,10,INK,15)-15
box(40,166,W-80,89,PALE,None)
text(58,228,'Factura registrada → número fiscal, comprobante y movimientos',14,TEAL,True)
para(58,204,'Cada facturación parcial genera una factura con su propio correlativo. Desde el documento registrado se imprime el RDLC fiscal y se concilian cliente, contabilidad e impuestos.',W-116,11,INK,16)
notes([('Previsualizar','Revisar antes de contabilizar; comprobar en sandbox que no se consuma el rango.'),('Nota de crédito','Tipo 06, factura de origen, CAI de origen y motivo del ajuste.'),('Migración POS','No activar otra emisión para ventas ya facturadas por el POS.')],y=62,h=74)
end()

# 22 — Todos los formatos y su finalidad.
page(22,'22 · Centro de informes','20 formatos RDLC para documentos y movimientos','Filtrar por documento interno BC, tercero y fechas. La impresión real de RDLC debe verificarse en Business Central.')
listas=[('COMPROBANTES',['Retención emitida o anulada','Nota de débito','Factura de venta','Nota de crédito de venta','Factura de compra interna','Abono de compra interno','Boleta de compra tipo 11']),('BORRADORES Y CATÁLOGOS',['Borrador de venta','Borrador de compra','Borrador de retención','Borrador de boleta','Autorizaciones CAI de ventas','Autorizaciones CAI de proveedores','Movimientos fiscales y CAI']),('MOVIMIENTOS',['Contabilidad','Proveedores y saldo pendiente','Clientes y saldo pendiente','Aplicaciones de proveedores','Aplicaciones de clientes','Impuesto sobre ventas'])]
for i,(titulo,lineas) in enumerate(listas):
 xx=40+i*259
 box(xx,166,243,307,white,None)
 text(xx+14,446,titulo,11,TEAL,True)
 yy=416
 for linea in lineas:yy=para(xx+14,yy,'• '+linea,213,10,INK,14)-13
notes([('Sin duplicar documentos','Reimprimir un comprobante registrado no emite otro correlativo.'),('Moneda','Los movimientos muestran su moneda; no se suman divisas distintas.'),('Manual completo','MANUAL_USUARIO.pdf contiene configuración, pasos, incidencias y aceptación.')],y=62,h=74)
end()
# 23 — Boleta de compra: configuración y captura sin reserva.
page(23,'23 · Boleta de compra HN','Preparar el comprobante del adquirente','Pantalla ilustrativa. Tipo fiscal 11 con autorización propia; no utiliza el CAI de una factura del proveedor.')
x,y,w=screen(40,166,370,307,'Configuración y proveedor',['Configurar CAI'])
field(x,y,'Habilitar boletas / autorización','Sí / BOL-2026 · Tipo 11',w)
field(x,y-54,'Proveedor','Persona natural hondureña verificada',w)
field(x,y-108,'Identidad, dirección y teléfono','Obligatorios en el comprobante',w)
para(x,y-164,'Configurar RTN, dirección, teléfono y correo del emisor. Moneda local HNL. Conciliar procedencia y límites fiscales con contabilidad.',w,10,INK,14)
x,y,w=screen(431,166,370,307,'Boleta de compra HN',['Validar','Borrador','Registrar'])
field(x,y,'Número interno / fiscal','BC-00001 / SIN EMITIR',w)
field(x,y-54,'Descripción / cantidad / costo','Servicio o bien · 1 · 1.000,00',w)
field(x,y-108,'ISV / crédito fiscal','0 % / no permitido',w)
para(x,y-164,'Desde pedido: Acciones → Emitir como boleta de compra. Identifica el documento sin reservar autorización ni correlativo.',w,10,INK,14)
notes([('Crear y validar','No modifica próximo ni último número emitido.'),('Vista previa','Sin número fiscal asignado. Una recepción sola no emite.'),('Registrar','Obtiene el próximo fiscal disponible dentro de la transacción contable.')],y=62,h=74)
end()

# 24 — Histórico y comprobante fiscal de boleta.
page(24,'24 · Registrar e imprimir la boleta','Conservar la emisión y sus movimientos','El correlativo se asigna al registrar. Un error revierte el consumo; cada facturación parcial genera una boleta distinta.')
x,y,w=screen(40,166,465,307,'Boletas de compra registradas HN',['Abrir','Imprimir boleta'])
field(x,y,'Documento BC / fiscal','FC-00001 / 000-001-11-00000001',w)
field(x,y-54,'Emisor / proveedor','Empresa adquirente / persona natural',w)
field(x,y-108,'CAI / rango / fecha límite','Datos conservados al registrar',w)
para(x,y-166,'Comprobante: detalle, total en lempiras y letras, contactos, exoneraciones cuando correspondan y espacios para firma y huella del proveedor.',w,10,INK,14)
x,y,w=screen(525,166,276,307,'Trazabilidad y reimpresión')
para(x,y,'Movimientos estándar de proveedor y contabilidad. Movimiento fiscal emitido con CAI propio. El pedido abierto no conserva una reserva fiscal.',w,11,INK,16)
para(x,y-113,'Reimprimir conserva el mismo número. Recoger firma y huella en el comprobante físico. No borrar ni reutilizar números emitidos.',w,11,INK,16)
notes([('Tratamiento fiscal','No genera crédito ISV. Límites del art. 22: conciliación contable externa.'),('Correcciones','Anulación fiscal de boletas pendiente de un desarrollo específico.'),('Validación operativa','Comprobar facturación parcial, concurrencia, reversión por error y RDLC en sandbox.')],y=62,h=74)
end()
# 25 — Migración verificable con evidencia por ejecución.
page(25,'25 · Migrar y validar metadatos HN','Conservar el origen y acreditar cada paso','Ilustración del recorrido preparado. Sin ejecutar en BC. Los datos se copian como referencias, sin activar su lógica.')
x,y,w=screen(40,166,370,307,'Preparar, copiar o validar migración')
field(x,y,'Operación / tabla','Verificar antes de copiar / 0 = todas',w)
field(x,y-54,'Copia revisada','Copiar y validar automáticamente',w)
field(x,y-108,'Comprobación independiente','Validar después de la migración',w)
para(x,y-164,'Usar sandbox compatible, permiso HN MIGRATION y ventana coordinada sin escrituras de API/usuarios/tareas.',w,10,INK,14)
x,y,w=screen(431,166,370,307,'Verificación de migración HN',['Exportar ejecución a CSV'])
field(x,y,'Identificador / copia de referencia','Ejecuciones trazables por empresa',w)
field(x,y-54,'Resultado final esperado','Correcto: 0 pendientes / 0 conflictos',w)
field(x,y-108,'Validación de copia','Igualdad de valores, claves y adjuntos',w)
para(x,y-164,'236 referencias en campos propios. Tabla 115: Sin correspondencias. Completar prueba funcional y conciliación contable.',w,10,INK,14)
notes([('Antes de copiar','Un conflicto bloquea la copia de todo el conjunto seleccionado.'),('Después de copiar','Comparación automática; un fallo revierte la ejecución completa.'),('Aceptación','Conservar CSV y completar EJECUCION_MIGRACION.pdf con datos reales de BC.')],y=62,h=74)
end()
c.save()
print(OUT)
