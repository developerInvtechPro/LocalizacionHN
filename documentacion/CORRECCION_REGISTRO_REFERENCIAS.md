# Corrección del registro de compras y ventas

29 de octubre de 2026. Versiones: **1.2.6.2 para el sandbox 1.2.x** y **1.3.0.2 para producción 1.3.x**.

## Causa

Las referencias se numeraron de forma independiente en cada tabla. TransferFields copia por número de campo, no por nombre. El número 71125 era un Boolean en Cab. venta y un Text[60] en Histórico cab. factura venta. Había conflictos equivalentes en compras y otros campos del mismo tipo pero diferente significado. Estos últimos podían copiar valores a conceptos equivocados sin mostrar un error.

## Corrección y conservación

Los 96 campos de referencia afectados se conservan con su ID, nombre, tipo y contenido. Se marcan con ObsoleteState = Removed para excluirlos de las transferencias estándar; no se eliminan sus datos. Se añaden nuevos destinos con 75 IDs en 74000–74074, compartidos únicamente por conceptos equivalentes dentro de la misma familia de documentos. Las referencias Blob, de proveedores, de empresa y los catálogos no se cambian.

La codeunit de actualización copia los valores originales a los destinos nuevos en la misma fila de cada tabla. Compara cada valor después de copiar y guarda una etiqueta de actualización por empresa solamente si todo coincide. Si encuentra un destino distinto ya informado o una diferencia posterior, detiene la actualización. No contiene COMMIT, no registra documentos, no consume CAI y no cambia asientos, saldos ni campos de la extensión antigua.

El mapa de migración desde la localización antigua contiene los destinos nuevos y una firma actualizada. El visor de referencias los utiliza automáticamente. Si ya se había validado una migración con la firma anterior, debe hacerse una nueva ejecución con el mapa vigente; no se reutiliza aquella aprobación.

No puede reconstruirse automáticamente información que hubiera quedado semánticamente equivocada en registros anteriores. Se conserva su contenido tal como estaba; ante sospechas se compara con la extensión antigua mediante la rutina de migración.

## Instalación y comprobación

1. Confirmar la rama instalada: 1.2.x conserva IDs del sandbox; 1.3.x usa IDs de producción 730xx. Elegir el paquete correspondiente y actualizar normalmente. No desinstalar V2 ni usar ForceSync o Recreate.
2. Durante la actualización, Business Central ejecuta la copia y su comparación por empresa. Una primera instalación no tiene referencias anteriores de V2 que copiar y registra la etiqueta para que futuras actualizaciones no repitan esa copia.
3. En una empresa de pruebas, ejecutar las pruebas AL del paquete de pruebas correspondiente. Incluyen transferencias estándar en ambos sentidos para ventas, notas de crédito, compras y sus líneas. Compilarlas no equivale a ejecutarlas.
4. Abrir documentos con referencias, comprobar los valores desde «Referencias anteriores conservadas» y contrastarlos con una muestra anterior a la actualización.
5. Comprobar un pedido de venta, una factura de venta, una nota de crédito y una orden de compra, primero en vista previa de registro y después con documentos de prueba. Revisar sus históricos, importes, CAI y continuidad de los formatos anteriores.
6. Si persiste un error, copiar «Compartir detalles» para identificar la extensión y la llamada exactas. No corregirlo quitando aplicaciones ni borrando información.

## Verificación local

```text
python3 herramientas/compilar.py
python3 herramientas/verificar_artefactos.py
python3 -m unittest discover -s pruebas -p 'test_*.py'
python3 herramientas/compilar_produccion.py
```

La validación comprueba tipos y conceptos de 12 pares de tablas, además de los diseños RDLC y los 236 destinos de migración. La ejecución de actualización y registro requiere Business Central; no se ha realizado desde estas herramientas.

Referencias técnicas: [TransferFields, Microsoft](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-transferfields-table-boolean-boolean-method), [corrección de Microsoft para campos Removed](https://github.com/microsoft/AL/issues/4265), [DataTransfer durante actualizaciones](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-data-transfer).
