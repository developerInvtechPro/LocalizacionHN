"""Regresión del fallo de impresión: celdas físicas y posiciones cubiertas."""
from pathlib import Path
import sys
import unittest
import xml.etree.ElementTree as E

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'herramientas'))
from validar_celdas_rdlc import validar_fila


def fila(celdas):
    return E.fromstring('<TablixRow><TablixCells>' + celdas + '</TablixCells></TablixRow>')


class CeldasCombinadas(unittest.TestCase):
    def test_combinaciones_y_celda_individual(self):
        validar_fila(fila('<TablixCell><CellContents><ColSpan>2</ColSpan></CellContents></TablixCell>'
                          '<TablixCell/><TablixCell><CellContents/></TablixCell>'
                          '<TablixCell><CellContents><ColSpan>2</ColSpan></CellContents></TablixCell>'
                          '<TablixCell/>'), 5)

    def test_rechaza_estructura_de_la_version_1250(self):
        with self.assertRaisesRegex(AssertionError, 'celdas físicas'):
            validar_fila(fila('<TablixCell><CellContents><ColSpan>3</ColSpan></CellContents></TablixCell>'
                              '<TablixCell><CellContents><ColSpan>4</ColSpan></CellContents></TablixCell>'), 7)

    def test_rechaza_contenido_en_posicion_cubierta(self):
        with self.assertRaisesRegex(AssertionError, 'cubierta por ColSpan'):
            validar_fila(fila('<TablixCell><CellContents><ColSpan>2</ColSpan></CellContents></TablixCell>'
                              '<TablixCell><CellContents/></TablixCell>'), 2)

    def test_rechaza_celda_vacia_sin_combinacion(self):
        with self.assertRaisesRegex(AssertionError, 'necesita CellContents'):
            validar_fila(fila('<TablixCell/>'), 1)

    def test_rechaza_combinacion_fuera_del_ancho(self):
        with self.assertRaisesRegex(AssertionError, 'fuera de las columnas'):
            validar_fila(fila('<TablixCell><CellContents><ColSpan>3</ColSpan></CellContents></TablixCell>'
                              '<TablixCell/>'), 2)

    def test_todos_los_formatos_generados(self):
        carpeta = Path(__file__).resolve().parents[1] / 'src/Informes/Disenos'
        for archivo in carpeta.glob('*.rdlc'):
            for tabla in E.parse(archivo).findall('.//{*}Tablix'):
                cuerpo = tabla.find('./{*}TablixBody')
                if cuerpo is None: continue
                ancho = len(cuerpo.findall('./{*}TablixColumns/{*}TablixColumn'))
                for numero, renglon in enumerate(cuerpo.findall('./{*}TablixRows/{*}TablixRow'), 1):
                    with self.subTest(archivo=archivo.name, fila=numero):
                        validar_fila(renglon, ancho, archivo.name)


if __name__ == '__main__': unittest.main()
