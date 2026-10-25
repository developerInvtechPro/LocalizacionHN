"""Mantiene en español los textos visibles y comentarios, conservando los identificadores publicados."""
from pathlib import Path
import re
R=Path(__file__).resolve().parents[1]
CAPTIONS={
'INV POS Transaction No.':'Documento fiscal de origen POS','INV POS Station':'Sucursal POS','INV POS Terminal':'Terminal POS','INV POS Shift':'Turno POS','INV POS Document Type':'Tipo de documento POS','INV POS Billing Type':'Tipo de facturación POS','INV POS Received Total':'Total recibido del POS','INV POS Received VAT':'ISV recibido del POS','INV POS Operator':'Operador POS','INV POS Purchase Order':'Orden de compra del cliente POS','INV POS Plate':'Placa POS','INV POS Mileage':'Kilometraje POS','INV POS Driver':'Conductor POS','INV POS Comment':'Comentario POS','INV POS CAI Code':'Código de autorización CAI POS','INV POS CAI':'CAI completo POS','INV POS CAI Expiration':'Fecha límite del CAI POS','INV POS CAI Start':'Rango inicial CAI POS','INV POS CAI End':'Rango final CAI POS','INV POS Exemption Code':'Código de exoneración POS','INV POS Exempted Amount':'Importe exonerado POS','INV POS Exempt Order':'Orden de compra exenta POS','INV POS Exemption Register':'Registro de exoneración POS','INV POS SAG Reference':'Referencia SAG POS','INV POS Additional CAI':'CAI adicional de origen POS','INV POS Pump':'Identificador de bomba POS','INV POS Pump Position':'Posición de bomba POS','INV POS Tank':'Tanque POS','INV POS Line Operator':'Operador de línea POS','INV POS Received VAT Rate':'Tasa de ISV recibida del POS','INV POS Line Received VAT':'ISV de línea recibido del POS','INV POS Line Received Total':'Total de línea recibido del POS','INV HN RTN':'RTN Honduras','INV HN Exempt Customer':'Cliente exonerado Honduras',
'No.':'Número','Document No.':'Número de documento','Line No.':'Número de línea','Entry No.':'Número de movimiento','Run ID':'Identificador de ejecución','Created At':'Fecha y hora de creación','User ID':'Usuario','Table ID':'Identificador de tabla','Record ID':'Identificador de registro','Field ID':'Identificador de campo','Detail':'Detalle','Apply Changes':'Aplicar cambios','Rows Checked':'Registros verificados','Fields To Copy':'Campos por copiar','Conflicts':'Conflictos','Source ID':'Identificador de origen','Source Name':'Nombre del campo de origen','Target ID':'Identificador de destino','Primary Key':'Clave principal'}
COMMENTS={
'Called only when opening the document, before editing or posting it.':'Se ejecuta al abrir el documento, antes de editarlo o registrarlo.',
'Persist the initial setup row before opening the configuration dialog.':'Conserva la configuración inicial antes de abrir la ventana de configuración.',
'Also protect documents created before the multi-invoice schema upgrade.':'Protege también los documentos anteriores a la actualización de facturas múltiples.',
'Use the standard unapplication engine; do not edit detailed balances.':'La desliquidación utiliza el motor estándar de Business Central para conservar la integridad de los saldos.',
'Only this service changes the state of an issued immutable certificate.':'Este servicio controla el cambio de estado de un comprobante emitido y conservado para auditoría.',
'Only enrich the existing V2 schema. Never issue CAI or post accounting here.':'Completa relaciones del esquema V2 existente sin emitir correlativos ni registrar contabilidad.',
'Deliberately limited to a separate migration role, never an automatic upgrade.':'Esta herramienta requiere permisos de migración separados y se ejecuta expresamente.',
'Only whitelisted V2 metadata; no Validate/posting/legacy triggers.':'Solo copia metadatos propios autorizados, sin disparar validaciones ni registros de otros módulos.',
'Only the audited migration map may name legacy fields.':'Solo el mapa auditado de migración puede referirse a nombres de campos anteriores.',
'Existing V2 data identities/types must survive upgrades. A build is not a coexistence check.':'Las identidades y tipos de datos V2 deben conservarse; compilar no acredita convivencia.',
'Only the test project sees V2\'s compiled symbols, in an isolated cache.':'El proyecto de pruebas recibe los símbolos V2 mediante una caché aislada.',
'Literal references are inventory evidence, not proof of complete runtime behavior.':'Las referencias encontradas son un inventario, no una validación completa de funcionamiento.',
'Exact source mapping per table. No TransferFields between legacy table schemas.':'El mapeo es explícito por tabla y no copia campos antiguos por coincidencia numérica.',
'Explicit copies on posting, including credit memos and their lines.':'La copia explícita al registrar incluye facturas, abonos y sus líneas.',
'Preserve actual types/lengths; do not add a second close ID or payment-detail owner.':'Conserva tipos y longitudes y respeta el propietario del cierre y del detalle de pagos.',
'1 — Cover':'1 — Portada','Vector path on cover.':'Trazado vectorial de la portada.',
'2 — Graphical overview and linked contents.':'2 — Resumen gráfico e índice enlazado.',
'3 — Setup and vendor.':'3 — Configuración y proveedor.','4 — Concepts.':'4 — Conceptos.',
'5 — CAI opened on demand from actions.':'5 — CAI disponible desde las acciones.',
'6 — Purchase.':'6 — Compra.','7 — Generate.':'7 — Generación.','Modal overlay.':'Ventana superpuesta.',
'8 — Draft card.':'8 — Ficha del borrador.','9 — Retention accounting and history.':'9 — Contabilización e histórico de retenciones.',
'Schematic, intentionally distinct from a literal RDLC rendering.':'Ilustración del comprobante; el diseño RDLC requiere renderizado en Business Central.',
'10 — Retention certificate.':'10 — Comprobante de retención.','11 — Debit list with CAI in actions, never embedded.':'11 — Lista de notas de débito con CAI disponible desde acciones.',
'12 — Debit card: fiscal information moved to its own action.':'12 — Datos fiscales de la nota de débito mediante una acción específica.',
'13 — Debit registration.':'13 — Registro de la nota de débito.','14 — Debit certificate.':'14 — Comprobante de la nota de débito.',
'15 — Controls / state.':'15 — Controles y estado.','16 — Complete walkthrough / pending.':'16 — Recorrido completo y pendientes.',
'17 — Grouped invoices and cancellation.':'17 — Facturas agrupadas y anulación.',
'18 — Migration preparation and concrete deployment blocker.':'18 — Preparación de migración y bloqueo de despliegue.'}
DOCSTRINGS={
'Compile V2 and sandbox tests using Microsoft symbols only; never publishes.':'Compila V2 y sus pruebas solo con símbolos Microsoft, sin publicar.',
'Check V2\'s independence, own field declarations and report datasets offline.':'Verifica la independencia de V2, sus campos propios y los datasets de informes.',
'Read local manifests, symbols and AL references. Never edits the source projects.':'Inspecciona manifiestos, símbolos y referencias AL sin modificar los proyectos de origen.',
'Generate the reviewable legacy-to-V2 map from local symbols; never connects to BC.':'Genera el mapa de campos desde símbolos locales, sin conectarse a Business Central.',
'Create an illustrated PDF from the implemented AL screens (not live screenshots).\nDependency: reportlab. Optional validation/rendering uses PyMuPDF outside this script.':'Genera una guía ilustrada a partir del código AL; no captura pantallas de Business Central.\nRequiere ReportLab. La revisión opcional del PDF utiliza PyMuPDF.'}
for base in ['src','herramientas']:
 for p in (R/base).rglob('*'):
  if not p.is_file() or p.suffix not in ['.al','.py']:continue
  if p.name=='traducir_textos.py':continue
  text=p.read_text()
  for a,b in COMMENTS.items():text=text.replace('// '+a,'// '+b).replace('# '+a,'# '+b)
  for a,b in DOCSTRINGS.items():text=text.replace(a,b)
  if p.suffix=='.al':
   for a,b in CAPTIONS.items():text=text.replace("Caption = '"+a+"'", "Caption = '"+b+"'")
   # Las propiedades Caption no modifican el almacenamiento ni el contrato externo.
   def campo(m):
    name=m.group(2) or m.group(3)
    if name not in CAPTIONS:return m.group(0)
    return m.group(0)+" Caption = '"+CAPTIONS[name]+"';"
   text=re.sub(r'(field\(\d+;\s*(?:"([^"]+)"|(\w+));[^\n{]+\)\s*\{)(?!\s*Caption)',campo,text)
   groups={'Details':'Detalle','Options':'Opciones','Fiscal':'Datos fiscales','General':'General','Correccion':'Corrección'}
   text=re.sub(r'(group\((\w+)\)\s*\{\n)(?!\s*Caption)',lambda m:m[1]+"                Caption = '"+groups.get(m[2],m[2])+"';\n",text)
  p.write_text(text)
print('Textos de interfaz y comentarios actualizados en español; identificadores de datos conservados.')
