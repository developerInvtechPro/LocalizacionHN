"""Conserva referencias publicadas y crea destinos coherentes para TransferFields.
El plan es inmutable: los IDs publicados nunca se recalculan ni reutilizan.
"""
from pathlib import Path
import hashlib,json,re
R=Path(__file__).resolve().parents[1]
PLAN=R/'migracion/reparacion-transferencia.json'
MAP=R/'migracion/mapa-campos.json'
FILE=R/'src/Migracion/ReferenciasGeneradas.al'
FAMILIAS={36:'ventas-cabecera',112:'ventas-cabecera',37:'ventas-linea',113:'ventas-linea',38:'compras-cabecera',122:'compras-cabecera',39:'compras-linea',123:'compras-linea'}

def main():
 contrato=json.loads(MAP.read_text())
 if PLAN.exists(): plan=json.loads(PLAN.read_text())
 else:
  entradas=[f for f in contrato['fields'] if f['tableId'] in FAMILIAS and f.get('referenceOnly') and f.get('extendedReference') and f['type']!='Blob']
  claves=sorted({(FAMILIAS[f['tableId']],f['sourceId'],f['type']) for f in entradas})
  ids={k:74000+i for i,k in enumerate(claves)}
  plan={'tag':'INVTECH-REFERENCIAS-TRANSFERENCIA-20261029','fields':[dict(tableId=f['tableId'],table=f['table'],oldId=f['targetId'],oldName=f['targetName'],newId=ids[(FAMILIAS[f['tableId']],f['sourceId'],f['type'])],newName=f['targetName'].replace('HN Ref ','HN Copia '),type=f['type']) for f in entradas]}
  PLAN.write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n')
 texto=FILE.read_text()
 for p in plan['fields']:
  # Cada campo original se conserva con el mismo nombre, número y tipo.
  patron=rf'(        field\({p["oldId"]}; "{re.escape(p["oldName"])}"; [^\n]+\}})'
  matches=list(re.finditer(patron,texto))
  # Los nombres pueden coincidir en tablas distintas: restringir al bloque de su tabla.
  inicio=texto.index(f'"HN Ref Tabla {p["tableId"]}"')
  fin=texto.find('\ntableextension ',inicio)
  if fin<0: fin=texto.find('\ntable ',inicio)
  if fin<0: fin=len(texto)
  bloque=texto[inicio:fin]
  viejo=re.search(patron,bloque)
  assert viejo,p
  original=viejo[1]
  if 'ObsoleteState' not in original:
   retirado=original[:-1]+" ObsoleteState = Removed; ObsoleteReason = 'Referencia conservada; reemplazada por un campo compatible entre documentos e históricos.'; ObsoleteTag = '2026-10-29'; }"
   nuevo=original.replace(f'field({p["oldId"]}; "{p["oldName"]}"',f'field({p["newId"]}; "{p["newName"]}"')
   bloque=bloque.replace(original,retirado+'\n'+nuevo)
   texto=texto[:inicio]+bloque+texto[fin:]
  f=next(f for f in contrato['fields'] if f['tableId']==p['tableId'] and f['targetName'] in [p['oldName'],p['newName']])
  f['targetId']=p['newId'];f['targetName']=p['newName']
 FILE.write_text(texto)
 # Reemplazar solo argumentos de destino; el origen legado permanece idéntico.
 al=R/'src/Migracion/MapaCamposOrigen.al';s=al.read_text()
 for p in plan['fields']:
  s=s.replace(f", {p['oldId']}, '{p['oldName']}', {p['tableId']}, true)",f", {p['newId']}, '{p['newName']}', {p['tableId']}, true)")
 # Misma firma canónica empleada por el generador original.
 firma=hashlib.sha256(json.dumps(contrato['fields'],sort_keys=True,ensure_ascii=False).encode()).hexdigest()[:20].upper()
 anterior=contrato.get('mapVersion');contrato['mapVersion']=firma
 s=re.sub(r"exit\('[A-F0-9]{20}'\)",f"exit('{firma}')",s)
 MAP.write_text(json.dumps(contrato,ensure_ascii=False,indent=2)+'\n');al.write_text(s)
 print(f"{len(plan['fields'])} referencias conservadas y reemplazadas; firma {firma}.")

if __name__=='__main__': main()
