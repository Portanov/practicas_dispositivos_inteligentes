# Climate App

Aplicación móvil desarrollada con Flutter para consultar el estado del tiempo y el clima.  
Actualmente, se trata de una aplicación básica que muestra un mensaje de prueba ("Hola Mundo").

## Cómo iniciar la aplicación

Para ejecutar la app, abre una terminal dentro del directorio del proyecto:

```bash
flutter run

## Debes estar dentro de la carpeta del proyecto en su caso deberas ejecutar

cd climate_app

## antes del primer comando
```

### Iniciar emulador de android

en caso de querer usar un emulador se debe usar

```bash
flutter emulators

## mostrara la lista de emuladores

flutter emulators --launch id_dispositivo

## para correr el emulador.
```

## Hot Reload (Carga de cambios)

Al realizar cualquier tipo de cambio para cargarlo en el proyecto hay dos formas

### Manual: 
para esto deberas ingresar **r** de manera manual a la consola mientras la app se esta ejecutando esto ayudara a recargar la pagina.

### Automatica (depende de tu ordenador): 
usando unicamente **ctrl + s** (guardar el documento) la app se actualizara correctamente.

## Resultado esperado

La app debe mostrar una pantalla con un boton flotante en la esquina inferior derecha y una barra fijada a la parte superior de la pantalla que diga "Mi primera APP" y en el centro de la pantalla debe verse un Hola Mundo acompañado de un contador debajo.


