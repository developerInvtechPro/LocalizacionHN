"""Actualiza la estructura RDLC sin regenerar el contenido de los diseños."""
from pathlib import Path
import copy
import re
import xml.etree.ElementTree as E

ANTERIOR = 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition'
ACTUAL = 'http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition'


def leer_diseno(ruta):
    """Presenta a los generadores su estructura de trabajo 2008 en memoria."""
    arbol = E.parse(ruta)
    raiz = arbol.getroot()
    if raiz.tag == '{' + ACTUAL + '}Report':
        secciones = raiz.find('{' + ACTUAL + '}ReportSections')
        if secciones is None or len(secciones) != 1:
            raise ValueError('El generador necesita exactamente una sección de informe.')
        posicion = list(raiz).index(secciones)
        raiz.remove(secciones)
        for elemento in secciones[0]:
            raiz.insert(posicion, elemento)
            posicion += 1
        for elemento in raiz.iter():
            elemento.tag = elemento.tag.replace('{' + ACTUAL + '}', '{' + ANTERIOR + '}')
    return arbol


def guardar_diseno(arbol, ruta):
    """Guarda los diseños generados con ReportSections y esquema 2016."""
    arbol = copy.deepcopy(arbol)
    raiz = arbol.getroot()
    if raiz.tag == '{' + ANTERIOR + '}Report':
        secciones = E.Element('{' + ANTERIOR + '}ReportSections')
        seccion = E.SubElement(secciones, '{' + ANTERIOR + '}ReportSection')
        elementos = [raiz.find('{' + ANTERIOR + '}' + n) for n in ('Body', 'Width', 'Page')]
        if any(e is None for e in elementos):
            raise ValueError('Faltan Body, Width o Page en el diseño.')
        posicion = list(raiz).index(elementos[0])
        for elemento in elementos:
            raiz.remove(elemento)
            seccion.append(elemento)
        raiz.insert(posicion, secciones)
        for elemento in raiz.iter():
            elemento.tag = elemento.tag.replace('{' + ANTERIOR + '}', '{' + ACTUAL + '}')
    E.register_namespace('', ACTUAL)
    arbol.write(ruta, encoding='utf-8', xml_declaration=True)


def actualizar_archivo(ruta):
    """Preserva bytes, formato y contenido existente salvo el envoltorio nuevo."""
    datos = Path(ruta).read_bytes()
    texto = datos.decode('utf-8')
    raiz = E.fromstring(datos)
    if raiz.tag == '{' + ACTUAL + '}Report':
        return False
    if raiz.tag != '{' + ANTERIOR + '}Report':
        raise ValueError(f'Esquema inesperado: {ruta}')
    salto = '\r\n' if '\r\n' in texto else '\n'
    patron = r'(?ms)^  <Body>.*?^  </Page>'
    coincidencias = list(re.finditer(patron, texto))
    if len(coincidencias) != 1:
        raise ValueError(f'No se encontró el bloque Body/Width/Page: {ruta}')
    bloque = coincidencias[0].group()
    seccion = ('  <ReportSections>' + salto + '    <ReportSection>' + salto
               + salto.join('    ' + linea for linea in bloque.split(salto)) + salto
               + '    </ReportSection>' + salto + '  </ReportSections>')
    resultado = texto.replace(bloque, seccion, 1).replace(ANTERIOR, ACTUAL)
    E.fromstring(resultado.encode('utf-8'))
    Path(ruta).write_bytes(resultado.encode('utf-8'))
    return True


if __name__ == '__main__':
    carpeta = Path(__file__).resolve().parents[1] / 'src/Informes/Disenos'
    cantidad = sum(actualizar_archivo(ruta) for ruta in carpeta.glob('*.rdlc'))
    print(f'{cantidad} diseños actualizados al esquema RDLC 2016; sin regenerar su contenido.')
