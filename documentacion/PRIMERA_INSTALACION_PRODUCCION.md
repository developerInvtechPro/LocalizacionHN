# Primera instalación en producción — 1.3.0.1

Este paquete está preparado para la **primera instalación de V2 en producción**, confirmada por el usuario el 28 de octubre de 2026. El proyecto base 1.2.6.1 conserva los IDs del sandbox, donde existen pruebas y documentos.

## Motivo y alcance

El despliegue de 1.2.6.1 falló porque API_BCPOS 1.0.0.41 ya define la tabla 50100. El inventario identifica 14 colisiones de objetos/campos; cambiar solo esa tabla no resuelve el conjunto.

La variante de producción traslada las declaraciones propias 50100–50149 al rango 73000–73049. Conserva los objetos y campos 71100–71199. Conserva nombres, tipos, longitudes, valores de enumeraciones, claves y relaciones por nombre. El App ID se mantiene: `0afcac2a-37c1-4666-b0a6-72d4e5320046`.

Ejemplos: tabla de configuración 50100 → 73000, autorización CAI 50101 → 73001, cabecera de retención 50102 → 73002 y líneas 50103 → 73003. Los campos extendidos propios 501xx se trasladan también, evitando las colisiones con los campos POS. El mapa de copia de referencias actualiza sus destinos y su firma; no cambia IDs ni valores de origen de la localización anterior.

**No es una actualización directa del sandbox con V2 1.2.x instalada.** No usar ForceSync, Recreate ni eliminación de datos para aplicarla allí. Los datos de V2 del sandbox necesitan un traslado independiente y validado si se quiere llevar ese entorno al rango definitivo.

## Archivos de entrega

- `INVTECH_LocalizacionHN_V2_1.3.0.1.app`: primera instalación en producción.
- `LocalizacionHN_V2_Produccion_1.3.0.1_fuentes.zip`: fuentes de esa variante, con su propio app.json y mapa de destinos. Si se va a publicar desde VS Code, abrir estas fuentes como un proyecto separado y descargar sus símbolos Microsoft.
- `auditoria-produccion-1.3.0.1.json`: identidades trasladadas, hashes de los paquetes contrastados, colisiones antes/después y aplicaciones locales examinadas.
- El paquete de pruebas 1.3.0.1 es para un sandbox de validación, no se necesita para operar en producción.

## Publicación

1. En Administración de extensiones del entorno de destino, confirmar que V2 no está instalada y que no hay una instalación anterior pendiente. No desinstalar API_BCPOS ni la localización anterior.
2. Usar el paquete **1.3.0.1**. El paquete base 1.2.6.1 conserva los IDs antiguos y volverá a chocar con API_BCPOS. No compilar el proyecto base para publicarlo en producción.
3. Primero comprobar el paquete en una copia de sandbox que tenga las mismas aplicaciones instaladas que producción. El contraste de archivos locales no sustituye esta comprobación del entorno.
4. Completar la carga mediante el procedimiento de extensiones del entorno. El agente no ejecuta publicación, sincronización ni instalación desde esta preparación.
5. Revisar permisos, configuración propia y pruebas de retención/nota de débito. La instalación no ejecuta la copia de referencias de la localización antigua.
6. Verificar que API/POS y los formatos anteriores siguen operando. En V2 solo permanecen activos los comprobantes de retención (incluido su borrador) y nota de débito; los demás formatos siguen pospuestos. No se modifican selecciones de impresión anteriores.

Si aparece otra colisión con una aplicación no facilitada, conservar el error y ampliar el inventario antes de publicar. No resolverla quitando aplicaciones operativas.

## Verificación y reproducción

Ejecutar desde el proyecto base:

```text
python3 herramientas/compilar.py
python3 herramientas/compilar_produccion.py
```

El segundo comando copia fuentes a una carpeta temporal, transforma solo declaraciones y destinos del mapa, compila la aplicación y sus pruebas con símbolos Microsoft, compara sus tipos/campos con la base y audita colisiones contra API_BCPOS y los paquetes locales. Comprueba que el proyecto base no se modificó y entrega paquete, fuentes y auditoría en `artefactos`.

Las fuentes ZIP ya tienen los IDs de producción. Se compilan con `python3 herramientas/compilar.py` después de descargar los símbolos Microsoft. Incluyen únicamente las herramientas de compilación/validación, no los generadores del esquema antiguo. Los cambios posteriores se desarrollan en el proyecto base y se vuelve a generar una versión de producción mediante su perfil, incrementando su versión para cada entrega.

La revisión conserva todos los objetos por nombre; no retira tablas ni cambia los datos del sandbox. La comparación de tipos incluye los IDs de enumeraciones propios tras el traslado. Las pruebas AL se compilan, pero su ejecución y la aceptación funcional necesitan Business Central.

No se ha publicado ni instalado el paquete y no se ha ejecutado ninguna migración de datos. La auditoría local no certifica aplicaciones del servidor cuyos paquetes no se hayan facilitado.

Referencia: [Microsoft: rangos de IDs para extensiones por tenant](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al297).
