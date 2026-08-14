# Dos caras de Aiki

Composición Remotion editable para presentar Aiki ante inversionistas y administradores. Alterna la experiencia real del usuario con las acciones del administrador.

## Preview

```powershell
npm i
npx remotion studio --no-open
```

Abre la URL local y selecciona `AikiDosCaras`.

## Composición

- Resolución: 1080×1920 (vertical 9:16)
- Mockup: proporción aproximada 2.09:1 basada en teléfonos de 149.6 mm de alto y cerca de 71.5–71.7 mm de ancho.
- Frecuencia: 30 fps
- Duración: 60 segundos
- Diez escenas de 5–7 segundos, con cortes internos rápidos y overlays cinéticos.
- Interfaces demo de Aiki dentro de los teléfonos cuando aún no hay grabaciones reales.
- Todos los recorridos aparecen dentro de mockups 3D de celular tipo Rotato, incluidos los flujos administrativos.
- Identificador: `AikiDosCaras`

Los textos, el color de acento, las etiquetas y las rutas de grabación se pueden editar desde el panel de props de Remotion Studio.

## Grabaciones reales

Coloca los clips en `public/recordings`. La composición funciona sin ellos usando reemplazos visuales que indican qué captura falta. Consulta `public/recordings/README.md` para los nombres y el orden de captura.

## Verificación

```powershell
npm run lint
npx remotion compositions
npx remotion still AikiDosCaras --scale=0.25 --frame=30
```

El MP4 final debe renderizarse después de añadir las grabaciones reales y aprobar el audio.
