"""Genera el manual de usuario PDF desde Markdown y las ilustraciones del código AL."""
from pathlib import Path
import re, json, html
from tempfile import TemporaryDirectory
import fitz
from reportlab.platypus import BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, PageBreak, Table, TableStyle, Image, KeepTogether
from reportlab.platypus.tableofcontents import TableOfContents
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

R=Path(__file__).resolve().parents[1]
VERSION=json.loads((R/'app.json').read_text())['version']
F=Path('/System/Library/Fonts/Supplemental')
# En otros sistemas pueden proporcionarse fuentes Arial o sustituirse por una familia equivalente.
for nombre,archivo in [('Manual','Arial.ttf'),('ManualNegrita','Arial Bold.ttf')]:
 pdfmetrics.registerFont(TTFont(nombre,str(F/archivo)))
pdfmetrics.registerFontFamily('Manual',normal='Manual',bold='ManualNegrita',italic='Manual',boldItalic='ManualNegrita')
W,H=A4; AZUL=colors.HexColor('#12384B');VERDE=colors.HexColor('#008478');GRIS=colors.HexColor('#526674')
estilos=getSampleStyleSheet()
estilos.add(ParagraphStyle('TextoManual',fontName='Manual',fontSize=10,leading=14.8,spaceAfter=8,textColor=AZUL))
estilos.add(ParagraphStyle('Capitulo',fontName='ManualNegrita',fontSize=18,leading=22,textColor=AZUL,spaceAfter=17,keepWithNext=True))
estilos.add(ParagraphStyle('Paso',parent=estilos['TextoManual'],leftIndent=15,firstLineIndent=-15,spaceAfter=9))
estilos.add(ParagraphStyle('Celda',parent=estilos['TextoManual'],fontSize=8.5,leading=12,spaceAfter=0))
estilos.add(ParagraphStyle('IndiceManual',parent=estilos['TextoManual'],fontSize=10.5,leading=18))
estilos.add(ParagraphStyle('Portada',fontName='ManualNegrita',fontSize=31,leading=38,textColor=AZUL,alignment=TA_CENTER,spaceAfter=25))
estilos.add(ParagraphStyle('SubtituloManual',parent=estilos['TextoManual'],fontSize=14,leading=21,alignment=TA_CENTER,spaceAfter=20))

class Documento(BaseDocTemplate):
 def beforeDocument(self):self.contador=0
 def afterFlowable(self,elemento):
  if isinstance(elemento,Paragraph) and elemento.style.name=='Capitulo':
   self.contador+=1;clave='capitulo'+str(self.contador)
   self.canv.bookmarkPage(clave)
   self.notify('TOCEntry',(0,elemento.getPlainText(),self.page,clave))

def margen(c,doc):
 c.saveState();c.setFont('Manual',8);c.setFillColor(GRIS)
 c.drawString(42,H-29,'INVTECH · LOCALIZACIÓN HONDURAS V2')
 c.drawRightString(W-42,H-29,'Manual de usuario · '+VERSION)
 c.setStrokeColor(colors.HexColor('#D7E2E7'));c.line(42,39,W-42,39)
 c.drawString(42,25,'Configuración y operación · 24 de octubre de 2026')
 c.drawRightString(W-42,25,'Página '+str(doc.page));c.restoreState()

def contenido(s):
 s=html.escape(s)
 s=re.sub(r'\*\*(.*?)\*\*',r'<b>\1</b>',s)
 s=re.sub(r'`([^`]+)`',r'<font name="Manual">\1</font>',s)
 return s

salida=R/'documentacion/MANUAL_USUARIO.pdf'
doc=Documento(str(salida),pagesize=A4,title='Manual de usuario · Localización Honduras V2',author='INVTECH',leftMargin=43,rightMargin=43,topMargin=55,bottomMargin=52)
doc.addPageTemplates(PageTemplate(id='Manual',frames=Frame(43,52,W-86,H-107,leftPadding=0,rightPadding=0,topPadding=0,bottomPadding=0),onPage=margen))
flujo=[Spacer(1,100),Paragraph('Localización<br/>Honduras V2',estilos['Portada']),Paragraph('Manual de usuario<br/>Configuración y operación paso a paso',estilos['SubtituloManual']),Paragraph('Versión '+VERSION+' · 24 de octubre de 2026',estilos['SubtituloManual']),Spacer(1,30),Paragraph('Incluye facturación desde pedidos y facturas, CAI de proveedores, retenciones, notas de débito, notas de crédito e informes de movimientos.',estilos['TextoManual']),Paragraph('Las ilustraciones representan el código desarrollado. La ejecución y la impresión real en Business Central permanecen pendientes de validación.',estilos['TextoManual']),PageBreak(),Paragraph('Índice',estilos['Capitulo'])]
indice=TableOfContents();indice.levelStyles=[estilos['IndiceManual']];flujo+=[indice,PageBreak()]
lineas=(R/'documentacion/MANUAL_USUARIO.md').read_text().splitlines();i=0;primero=True
while i<len(lineas):
 linea=lineas[i].strip();i+=1
 if not linea or linea.startswith('# '):continue
 if linea.startswith('## '):
  if not primero:flujo.append(PageBreak())
  primero=False;flujo.append(Paragraph(contenido(linea[3:]),estilos['Capitulo']));continue
 if linea.startswith('|'):
  filas=[linea]
  while i<len(lineas) and lineas[i].strip().startswith('|'):filas.append(lineas[i].strip());i+=1
  datos=[]
  for fila in filas:
   celdas=[c.strip() for c in fila.strip('|').split('|')]
   if all(re.fullmatch(r'[-: ]+',c or '-') for c in celdas):continue
   datos.append([Paragraph(contenido(c),estilos['Celda']) for c in celdas])
  anchos=[150,W-236] if len(datos[0])==2 else None
  t=Table(datos,colWidths=anchos,repeatRows=1,hAlign='LEFT')
  t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#E0F0EB')),('GRID',(0,0),(-1,-1),0.35,colors.HexColor('#D7E2E7')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7)]))
  flujo.extend([t,Spacer(1,12)]);continue
 if re.match(r'^\d+\. ',linea):flujo.append(Paragraph(contenido(linea),estilos['Paso']))
 else:flujo.append(Paragraph(contenido(linea),estilos['TextoManual']))

with TemporaryDirectory(prefix='manual-hn-') as temporal:
 guia=fitz.open(R/'documentacion/Guia_visual_LocalizacionHN_V2.pdf')
 anexos=[(18,'Configuración de facturación'),(19,'Gestión de CAI de proveedores'),(20,'Pedido y factura directa'),(21,'Centro de informes')]
 for pagina,titulo in anexos:
  flujo.extend([PageBreak(),Paragraph('Ilustración: '+titulo,estilos['Capitulo'])])
  p=guia[pagina];destino=Path(temporal)/f'figura-{pagina}.png';p.get_pixmap(matrix=fitz.Matrix(1.6,1.6)).save(destino)
  ancho=W-86;alto=ancho*p.rect.height/p.rect.width
  flujo.extend([Image(str(destino),width=ancho,height=alto),Spacer(1,15),Paragraph('Pantalla ilustrativa basada en el código AL. No es una captura de Business Central ni un resultado de prueba.',estilos['TextoManual'])])
 doc.multiBuild(flujo)
print(salida)
