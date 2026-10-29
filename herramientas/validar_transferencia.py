"""Detecta conflictos de tipo Y concepto en TransferFields de compras y ventas."""
import json,zipfile
from pathlib import Path
PARES=[('Sales Header','Sales Invoice Header'),('Sales Header','Sales Cr.Memo Header'),('Sales Header','Sales Shipment Header'),('Sales Line','Sales Invoice Line'),('Sales Line','Sales Cr.Memo Line'),('Sales Line','Sales Shipment Line'),('Purchase Header','Purch. Inv. Header'),('Purchase Header','Purch. Cr. Memo Hdr.'),('Purchase Header','Purch. Rcpt. Header'),('Purchase Line','Purch. Inv. Line'),('Purchase Line','Purch. Cr. Memo Line'),('Purchase Line','Purch. Rcpt. Line')]

def objetos(datos):
 yield from datos.get('TableExtensions',[])
 for n in datos.get('Namespaces',[]):yield from objetos(n)

def validar(simbolos):
 tablas={}
 for obj in objetos(simbolos):
  tabla=obj['TargetObject'].split('#')[-1]
  for campo in obj.get('Fields',[]):
   props={p['Name']:p.get('Value') for p in campo.get('Properties',[])}
   if props.get('ObsoleteState')=='Removed':continue
   tablas.setdefault(tabla,{})[campo['Id']]=campo
 errores=[]
 for a,b in PARES:
  origen=tablas.get(a,{});destino=tablas.get(b,{})
  for numero in origen.keys()&destino.keys():
   f=origen[numero];g=destino[numero]
   if f['Name']!=g['Name'] or f['TypeDefinition']!=g['TypeDefinition']:
    errores.append(f"{a} ↔ {b}: {numero}, {f['Name']} / {g['Name']}")
 assert not errores,'Campos incompatibles para TransferFields:\n'+'\n'.join(errores)
 return len(PARES)

if __name__=='__main__':
 r=Path(__file__).resolve().parents[1];m=json.loads((r/'app.json').read_text())
 with zipfile.ZipFile(r/'artefactos'/f'INVTECH_LocalizacionHN_V2_{m["version"]}.app') as z:s=json.loads(z.read('SymbolReference.json'))
 print(f'{validar(s)} pares de tablas validados: tipos y conceptos compatibles.')
