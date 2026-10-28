namespace INVTECH.Honduras;

enum 71101 "HN Modo Migracion"
{
    Extensible = false;
    value(0; Verificar) { Caption = 'Verificar antes de copiar'; }
    value(1; Copiar) { Caption = 'Copiar y validar automáticamente'; }
    value(2; Validar) { Caption = 'Validar después de la migración'; }
}
enum 71102 "HN Resultado Migracion"
{
    Extensible = false;
    value(0; Pendiente) { Caption = 'Pendiente'; }
    value(1; Correcto) { Caption = 'Correcto'; }
    value(2; Bloqueado) { Caption = 'Bloqueado'; }
    value(3; SinMapa) { Caption = 'Sin correspondencias'; }
}
enum 71103 "HN Comparacion Migracion"
{
    Extensible = false;
    value(0; OrigenVacio) { Caption = 'Origen vacío'; }
    value(1; Igual) { Caption = 'Coincidente'; }
    value(2; Pendiente) { Caption = 'Por copiar'; }
    value(3; Conflicto) { Caption = 'Diferencia'; }
}
