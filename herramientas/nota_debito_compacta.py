"""Adapta a nota de débito la plantilla de retención aprobada por el usuario."""
from pathlib import Path
from copy import deepcopy
import xml.etree.ElementTree as E

NS = 'http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition'
def q(n): return '{'+NS+'}'+n
def f(n): return 'First(Fields!'+n+'.Value, "Documento")'


def ajustar_celdas(fila, amplitudes):
    celdas = fila.find(q('TablixCells'))
    contenidos = [deepcopy(c.find(q('CellContents'))) for c in celdas if c.find(q('CellContents')) is not None]
    assert len(contenidos) == len(amplitudes)
    celdas.clear()
    for contenido, amplitud in zip(contenidos, amplitudes):
        anterior = contenido.find(q('ColSpan'))
        if anterior is not None: contenido.remove(anterior)
        if amplitud > 1: E.SubElement(contenido, q('ColSpan')).text = str(amplitud)
        E.SubElement(celdas, q('TablixCell')).append(contenido)
        for _ in range(amplitud-1): E.SubElement(celdas, q('TablixCell'))


def nombres_unicos(fila, prefijo):
    for i, nodo in enumerate(fila.iter()):
        if 'Name' in nodo.attrib: nodo.set('Name', prefijo+str(i))


def crear_nota_debito(ruta, campos):
    raiz_proyecto = Path(__file__).resolve().parents[1]
    arbol = E.parse(raiz_proyecto/'herramientas/plantillas/RetencionCompacta.rdlc')
    raiz = arbol.getroot(); tabla = raiz.find('.//'+q('Tablix'))
    cuerpo = tabla.find(q('TablixBody')); filas = cuerpo.find(q('TablixRows'))
    miembros = tabla.find('./'+q('TablixRowHierarchy')+'/'+q('TablixMembers')+'/'+q('TablixMember')+'/'+q('TablixMembers'))
    originales = list(filas); miembros_originales = list(miembros)
    columnas = cuerpo.find(q('TablixColumns')); columnas.clear()
    for ancho in [.55,2.1,.45,.65,.9,.8,.9,1.15]:
        E.SubElement(E.SubElement(columnas,q('TablixColumn')),q('Width')).text=str(ancho)+'in'
    columnas_jerarquia = tabla.find('./'+q('TablixColumnHierarchy')+'/'+q('TablixMembers')); columnas_jerarquia.clear()
    for _ in range(8): E.SubElement(columnas_jerarquia,q('TablixMember'))
    for indice,fila in enumerate(originales):
        if indice in [3,4]: continue
        ajustar_celdas(fila,[4,4] if indice in [1,8] else [4,3,1] if indice==6 else [8])
    originales[0].find('.//'+q('Value')).text='NOTA DE DÉBITO'
    originales[1].find(q('Height')).text='1.75in'
    derecha=originales[1].findall('.//'+q('Textbox'))[1]
    for valor in derecha.findall('.//'+q('Value')):
        valor.text=valor.text.replace('Proveedor: ','Cliente: ').replace('RTN / identidad: ','RTN cliente: ')
    parrafos=derecha.find(q('Paragraphs'))
    direccion=deepcopy(parrafos[2]);direccion.find('.//'+q('Value')).text='="Dirección: " & '+f('Party_Address');parrafos.insert(2,direccion)
    vencimiento=deepcopy(parrafos[-1]);vencimiento.find('.//'+q('Value')).text='="Fecha de vencimiento: " & '+f('Due_Date');parrafos.append(vencimiento)
    # Mantener los datos específicos de la nota, sin cambiar su relación con la factura.
    originales[2].find(q('Height')).text='.7in'
    originales[2].find('.//'+q('Value')).text=('="Factura fiscal de origen: " & '+f('Source_No')+' & " | Fecha: " & '+f('Source_Date')+
        ' & vbCrLf & "CAI de origen: " & '+f('Source_CAI')+' & vbCrLf & "Motivo: " & '+f('Reason'))
    for parrafo in originales[2].findall('.//'+q('Paragraph')):
        parrafo.find('./'+q('Style')+'/'+q('TextAlign')).text='Left'
    for negrita in originales[2].findall('.//'+q('FontWeight')):
        negrita.text='Normal'
    vis=miembros_originales[2].find(q('Visibility'))
    if vis is not None: miembros_originales[2].remove(vis)
    for indice,datos in [(3,['Código','Descripción','Ud.','Cantidad','Precio unit.','Descuento*','ISV','Importe']),
                         (4,['Line_Code','Line_Description','Line_Unit','Line_Quantity','Line_Unit_Price','Line_Discount','Line_Tax','Line_Amount'])]:
        fila=originales[indice];celdas=fila.find(q('TablixCells'));modelo=deepcopy(celdas[0]);celdas.clear()
        for j,valor in enumerate(datos):
            celda=deepcopy(modelo);nombres_unicos(celda,'NDDetalle'+str(indice)+'_'+str(j)+'_')
            celda.find('.//'+q('Value')).text=valor if indice==3 else '=Fields!'+valor+'.Value'
            for formato in celda.findall('.//'+q('Format')):
                for padre in celda.iter():
                    if formato in list(padre): padre.remove(formato);break
            if indice==4 and j>=3:
                E.SubElement(celda.find('.//'+q('TextRun')+'/'+q('Style')),q('Format')).text='N5' if j==3 else 'N4' if j==4 else 'N2'
            celdas.append(celda)
    totales=originales[6].findall('.//'+q('Value'));totales[1].text='TOTAL A PAGAR'
    originales[9].find('.//'+q('Value')).text='Original: cliente | Copia: obligado tributario emisor'
    nuevas_filas=[];nuevos_miembros=[]
    for indice,fila in enumerate(originales):
        if indice==6:
            for k,(etiqueta,campo) in enumerate([('Subtotal sin ISV','Subtotal_Amount'),('Total ISV','Tax_Amount')]):
                extra=deepcopy(fila);nombres_unicos(extra,'NDTotal'+str(k)+'_');valores=extra.findall('.//'+q('Value'))
                valores[1].text=etiqueta;valores[2].text='='+f(campo)
                nuevas_filas.append(extra);nuevos_miembros.append(deepcopy(miembros_originales[indice]))
        nuevas_filas.append(fila);nuevos_miembros.append(miembros_originales[indice])
        if indice==5:
            extra=deepcopy(fila);nombres_unicos(extra,'NDNotaPrecio_');extra.find(q('Height')).text='.30in'
            extra.find('.//'+q('Value')).text=('="* Descuentos de línea y factura. Precio unitario " & IIF('+f('Prices_Include_Tax')+',"con ISV incluido.","sin ISV.")')
            nuevas_filas.append(extra);nuevos_miembros.append(deepcopy(miembros_originales[indice]))
    filas.clear();miembros.clear()
    for fila in nuevas_filas: filas.append(fila)
    for miembro in nuevos_miembros: miembros.append(miembro)
    tabla.find(q('Height')).text=str(sum(float(fila.find(q('Height')).text[:-2]) for fila in filas))+'in'
    fields=raiz.find('.//'+q('Fields'));fields.clear()
    for campo in sorted(campos): E.SubElement(E.SubElement(fields,q('Field'),Name=campo),q('DataField')).text=campo
    E.register_namespace('',NS);E.indent(raiz,space='  ');arbol.write(ruta,encoding='utf-8',xml_declaration=True)
