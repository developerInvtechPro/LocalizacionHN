"""Genera la guía PDF de ejecución de migración desde su protocolo Markdown."""
from pathlib import Path
import argparse
from xml.sax.saxutils import escape
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Table,TableStyle
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
R=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--entrada',type=Path,default=R/'documentacion/EJECUCION_MIGRACION.md')
parser.add_argument('--salida',type=Path,default=R/'documentacion/EJECUCION_MIGRACION.pdf')
opciones=parser.parse_args();salida=opciones.salida
estilos=getSampleStyleSheet();flujo=[];lineas=opciones.entrada.read_text().splitlines();i=0
while i<len(lineas):
    linea=lineas[i].strip();i+=1
    if not linea:continue
    if linea.startswith('|'):
        filas=[]
        while linea.startswith('|'):
            if not set(linea.replace('|','').replace('-','').replace(' ',''))==set():
                filas.append([Paragraph(escape(x.strip()),estilos['BodyText']) for x in linea.strip('|').split('|')])
            if i>=len(lineas):break
            linea=lineas[i].strip()
            if not linea.startswith('|'):break
            i+=1
        tabla=Table(filas,colWidths=[290,200] if len(filas[0])==2 else [490/len(filas[0])]*len(filas[0]),repeatRows=1)
        tabla.setStyle(TableStyle([('GRID',(0,0),(-1,-1),.4,colors.lightgrey),('VALIGN',(0,0),(-1,-1),'TOP'),('BACKGROUND',(0,0),(-1,0),colors.HexColor('#E6F3EF'))]))
        flujo.extend([tabla,Spacer(1,12)]);continue
    estilo='Title' if linea.startswith('# ') else ('Heading2' if linea.startswith('## ') else 'BodyText')
    flujo.extend([Paragraph(escape(linea.lstrip('# ')),estilos[estilo]),Spacer(1,7)])
SimpleDocTemplate(str(salida),pagesize=A4,rightMargin=45,leftMargin=45,topMargin=40,bottomMargin=40,title=lineas[0].lstrip('# '),author='INVTECH').build(flujo)
print(salida)
