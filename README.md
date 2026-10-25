# Localización Honduras V2

Extensión independiente de INVTECH para Business Central 28, versión **1.2.0.0**.

Incluye facturación automática al registrar pedidos o facturas directas, boletas de compra con CAI propio, notas de crédito y débito, retenciones con varias facturas y anulación, gestión de varios CAI por proveedor, preparación de migración POS y **20 formatos RDLC** para documentos y movimientos.

## Documentación

- [Manual de usuario actualizado en PDF](documentacion/MANUAL_USUARIO.pdf).
- [Manual paso a paso y configuración en Markdown](documentacion/MANUAL_USUARIO.md).
- [Guía visual de 22 páginas](documentacion/Guia_visual_LocalizacionHN_V2.pdf), con ilustraciones del código.
- [Procedimiento de migración y bloqueos de despliegue](documentacion/MIGRACION_POS.md).
- [Validación en sandbox](documentacion/VALIDACION_SANDBOX.md).
- [Arquitectura y reglas de conservación de datos](documentacion/DESARROLLO.md).
- [Historial de cambios](CAMBIOS.md).

La interfaz, los textos de informes, los comentarios y la documentación están en español. Se conservan los IDs y nombres técnicos de los campos publicados y el contrato JSON de integración para mantener datos y compatibilidad.

## Estructura

```text
src/
  CAI/                       Autorizaciones propias, proveedores y trazabilidad
  Comun/                     Enumeraciones compartidas
  Compras/                   Campos, páginas y validación de compras
  Configuracion/             Configuración general y de facturación
  Informes/Disenos/           Datasets y 20 diseños RDLC
  IntegracionPOS/             Metadatos propios y transferencia al registrar
  Migracion/                 Mapeo y copia controlada de campos
  Retenciones/               Cálculo, documentos, registro y anulación
  Seguridad/                 Permisos por función
  Ventas/Facturacion/         Facturas y notas de crédito
  Ventas/NotasDebito/          Notas de débito
herramientas/                Compilación, verificación y generación documental
pruebas/                    Pruebas AL para sandbox
migracion/                  Mapa de campos y esquema de referencia
documentacion/              Manuales y procedimientos
```

Las carpetas locales `artefactos/`, `.alpackages/` y `archivo/` quedan fuera de Git. No se publica la configuración real del tenant: copie `.vscode/launch.ejemplo.json` a `.vscode/launch.json` y complete sus propios valores.

## Compilar y verificar

Requisitos: extensión AL de VS Code compatible con BC28/runtime17, runtime .NET requerido por AL y símbolos Microsoft descargados en `.alpackages`. Las variables `AL_EXTENSION` y `AL_DOTNET` permiten indicar rutas diferentes a las detectadas localmente.

```sh
python3 herramientas/compilar.py
python3 herramientas/verificar_artefactos.py
```

La compilación utiliza una caché aislada con símbolos Microsoft. El proyecto de pruebas recibe además el paquete V2 compilado. No se publican extensiones ni se modifican datos de Business Central.

Resultados locales:

- `artefactos/INVTECH_LocalizacionHN_V2_1.2.0.0.app`
- `artefactos/INVTECH_LocalizacionHN_V2_Pruebas_1.2.0.0.app`

Las pruebas AL deben ejecutarse en una empresa desechable de sandbox. Su compilación no acredita el registro contable, el comportamiento concurrente ni la impresión real de RDLC.

## Generar documentación e informes

```sh
python3 herramientas/crear_campos_facturacion.py
python3 herramientas/crear_paginas_facturacion.py
python3 herramientas/crear_informes.py
python3 herramientas/traducir_textos.py
```

Para generar los PDF, instale las bibliotecas en su entorno Python y ejecute:

```sh
python3 -m pip install -r requisitos-documentacion.pip
python3 herramientas/crear_guia_visual.py
python3 herramientas/crear_manual.py
```

Los generadores PDF utilizan fuentes Arial de macOS; el manual de desarrollo explica cómo adaptar su ubicación. Los mapas de migración ya están incluidos. Regenerarlos desde símbolos de origen es una operación adicional de desarrollo, no un requisito para utilizar la extensión.

## Despliegue y convivencia

**No desplegar junto a API_BCPOS 1.0.0.41 sin resolver los 14 conflictos preexistentes de IDs.** Se conserva el esquema V2 existente para proteger los datos del sandbox. La compilación aislada no demuestra convivencia.

Las dependencias de compilación de terceros son `[]`. Eso no desactiva suscriptores de otras aplicaciones ni cambia las escrituras del receptor POS. Los nuevos recorridos se habilitan por empresa y documento, y la migración histórica se ejecuta bajo demanda con permisos separados.

No se ha ejecutado una migración ni modificado la API existente. Antes del corte deben resolverse esquema, receptor, revisión/cierre, catálogos y pruebas completas de ventas, devoluciones, reenvíos y turnos nocturnos.

La versión 1.2 elimina la aplicación manual por documento: el CAI vigente y el próximo fiscal se resuelven al registrar. Crear, validar, imprimir borradores y previsualizar no consumen correlativos. Consulte el capítulo 18 del manual para configurar boletas de compra.
