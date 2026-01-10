# 🚗 CarSiGo

CarSiGo es una plataforma de movilidad bajo demanda (tipo Uber/InDrive) que conecta a pasajeros con conductores. El proyecto está desarrollado en Flutter con un enfoque en la estabilidad, seguridad y escalabilidad para una aplicación de producción real.

## ✨ Qué hace

- **Para Pasajeros:** Solicitar viajes, ver la ubicación de los conductores y gestionar su historial.
- **Para Conductores:** Aceptar viajes, gestionar su perfil, ver sus ganancias y estado.

---

## 🏗️ Arquitectura y Tecnologías

Este proyecto utiliza una arquitectura híbrida moderna para aprovechar las fortalezas de diferentes plataformas serverless.

- **Frontend (App Móvil):**
  - Flutter & Dart

- **Proveedor de Identidad (Google Sign-In):**
  - Firebase Authentication

- **Backend Principal (Base de Datos, Storage, Lógica Crítica):**
  - Supabase
  - PostgreSQL

---

## ⚙️ Configuración del Entorno de Desarrollo

Sigue estos pasos para configurar el proyecto en una nueva máquina.

### 1. Prerrequisitos

- Instalar [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Instalar [Android Studio](https://developer.android.com/studio)
- Configurar un emulador de Android o un dispositivo físico.

### 2. Instalación de Dependencias del Proyecto

Una vez clonado el repositorio, abre una terminal en la raíz del proyecto y ejecuta:

```sh
flutter pub get
```

### 3. Configuración de Firebase CLI

Necesitamos las herramientas de línea de comandos de Firebase para conectar el proyecto.

**a) Activar la herramienta:**

```sh
dart pub global activate flutterfire_cli
```

**b) Añadir al PATH (si el comando `flutterfire` no se reconoce):**

En las variables de entorno de Windows, añade la siguiente ruta a la variable `Path`:
`%USERPROFILE%\AppData\Local\Pub\Cache\bin`

**c) Conectar con Firebase:**

Ejecuta el siguiente comando y sigue los pasos para enlazar tu proyecto de Firebase:

```sh
flutterfire configure
```

### 4. Configuración para Google Sign-In (Android)

**a) Generar el archivo `google-services.json`:**
   - En la [Consola de Firebase](https://console.firebase.google.com/), selecciona tu proyecto.
   - Registra una **app de Android**.
   - Asegúrate de que el **nombre del paquete** sea `com.example.carsigo`.
   - Descarga el archivo `google-services.json` y colócalo en la carpeta `android/app/` de tu proyecto.

**b) Obtener la Huella Digital SHA-1:**
   - En la terminal de Android Studio, navega a la carpeta `android`:
     ```sh
     cd android
     ```
   - Ejecuta el siguiente comando:
     ```sh
     .\gradlew signingReport
     ```
   - Copia el valor **SHA-1** que aparece para la variante `debug`.

**c) Registrar la Huella SHA-1 en Google Cloud:**
   - Ve a la [Consola de Google Cloud](https://console.cloud.google.com/) > `APIs y Servicios` > `Credenciales`.
   - Busca y edita tu **ID de cliente de OAuth de tipo Android**.
   - Pega la huella SHA-1 que copiaste en el campo correspondiente y guarda.

### 5. Aceptar Licencias de Android

Finalmente, asegúrate de que todas las licencias del SDK de Android estén aceptadas. Ejecuta en la terminal:

```sh
flutter doctor --android-licenses
```

Y acepta todas las licencias presionando `y`.

---

¡Listo! Ahora puedes ejecutar la aplicación en tu dispositivo.
