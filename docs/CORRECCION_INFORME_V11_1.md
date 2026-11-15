# Corrección de informe — V11.1

## Síntoma confirmado por captura
El panel derecho tiene un tamaño mínimo que supera la altura del área central a 1280×720, empujando el `footer` más allá del borde inferior. La barra izquierda existente desplazaba solo las decisiones.

## Corrección
- `scripts/ui_kit.gd`: nuevo `scrollable_page()` sin modificar otras pantallas.
- `scripts/debrief.gd`: solo la bitácora usa esa página desplazable.
- Barra vertical turquesa siempre visible al **extremo derecho**; desplaza cabecera, paneles y botones.
- La lista de decisiones conserva su propio desplazamiento dentro del panel izquierdo.
- Contenido mínimo de 940 px, para crear margen desplazable a 1280×720 y que el pie resulte accesible.
- El botón Exportar conserva el mismo manejador de guardado.

## Verificación manual obligatoria dentro de Godot
1. Abrir una partida y navegar a Resultados → Informe científico.
2. Confirmar que aparecen dos barras: la del registro a la izquierda y otra al extremo derecho.
3. Arrastrar la barra **exterior** hasta abajo: ambos botones **← RESULTADOS** y **EXPORTAR .TXT** deben verse íntegros.
4. Hacer clic en **EXPORTAR .TXT** y confirmar el mensaje `Guardado en user://`.
5. Pulsar **← RESULTADOS** y comprobar navegación.
6. Abrir otra misión con diez eventos y repetir las comprobaciones a 1280×720 y, si es posible, 1366×768.

### Límite
El archivo está corregido estructuralmente, pero no se certifica una prueba de ejecución de Godot si no se dispone del motor.
