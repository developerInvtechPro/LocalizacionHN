"""Regresión del bloqueo al registrar y de la mezcla silenciosa de referencias."""
import json,sys,unittest,zipfile
from pathlib import Path
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'herramientas'))
from validar_transferencia import validar

def simbolos():
 m=json.loads((R/'app.json').read_text())
 with zipfile.ZipFile(R/'artefactos'/f'INVTECH_LocalizacionHN_V2_{m["version"]}.app') as z:return json.loads(z.read('SymbolReference.json'))

def muestra(tipo='Text[60]',nombre='Fuente',retirado=False):
 def objeto(tabla,tipo,nombre,retirado=False):
  return {'TargetObject':'#'+tabla,'Fields':[{'Id':71125,'Name':nombre,'TypeDefinition':{'Name':tipo},'Properties':[{'Name':'ObsoleteState','Value':'Removed'}] if retirado else []}]}
 return {'TableExtensions':[objeto('Sales Header','Boolean','Indicador',retirado),objeto('Sales Invoice Header',tipo,nombre)]}

class Transferencia(unittest.TestCase):
 def test_tipos_diferentes_bloquean(self):
  with self.assertRaises(AssertionError):validar(muestra())
 def test_mismo_tipo_distinto_concepto_tambien_bloquea(self):
  with self.assertRaises(AssertionError):validar(muestra('Boolean'))
 def test_campo_retirado_no_participa(self):validar(muestra(retirado=True))
 def test_paquete_actual_coherente(self):validar(simbolos())
 def test_plan_preserva_tipos_y_ids_publicados(self):
  from validar_transferencia import objetos
  tablas={}
  for o in objetos(simbolos()):tablas.setdefault(o['TargetObject'].split('#')[-1],{}).update({f['Id']:f for f in o.get('Fields',[])})
  plan=json.loads((R/'migracion/reparacion-transferencia.json').read_text())
  for f in plan['fields']:
   old=tablas[f['table']][f['oldId']];new=tablas[f['table']][f['newId']]
   self.assertEqual(old['Name'],f['oldName']);self.assertEqual(new['Name'],f['newName'])
   self.assertEqual(old['TypeDefinition'],new['TypeDefinition'])
   self.assertIn({'Name':'ObsoleteState','Value':'Removed'},old['Properties'])

if __name__=='__main__':unittest.main()
