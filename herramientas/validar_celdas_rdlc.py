"""Reglas semánticas de celdas combinadas MS-RDL 2.30.1 y 2.31.2.

https://learn.microsoft.com/en-us/openspecs/sql_server_protocols/ms-rdl/a6564f5d-b478-42a7-9217-1a799e5ecd28
"""


def validar_fila(fila, ancho, contexto='RDLC'):
    celdas = fila.findall('./{*}TablixCells/{*}TablixCell')
    assert len(celdas) == ancho, f'{contexto}: se necesitan {ancho} celdas físicas, hay {len(celdas)}'
    cubiertas = 0
    for posicion, celda in enumerate(celdas):
        contenidos = celda.findall('./{*}CellContents')
        if cubiertas:
            assert not contenidos, f'{contexto}: columna {posicion+1} cubierta por ColSpan debe omitir CellContents'
            cubiertas -= 1
            continue
        assert len(contenidos) == 1, f'{contexto}: columna {posicion+1} sin combinar necesita CellContents'
        amplitud = int(contenidos[0].findtext('./{*}ColSpan', '1'))
        assert 1 <= amplitud <= ancho-posicion, f'{contexto}: ColSpan fuera de las columnas disponibles'
        cubiertas = amplitud-1
    assert cubiertas == 0, f'{contexto}: combinación incompleta'
