# EcoMerca2 - Distribución y Pruebas con Firebase

Este repositorio contiene el flujo de trabajo para la distribución de versiones de prueba de la aplicación **EcoMerca2** utilizando Firebase App Distribution.

## 🚀 Flujo de Trabajo
El proceso de distribución sigue estas etapas consecutivas:
1.  **Generar APK:** Compilación de la versión de producción optimizada.
2.  **App Distribution:** Carga del archivo `.apk` a la consola de Firebase.
3.  **Testers:** Notificación y gestión de los usuarios de prueba (QA).
4.  **Instalación:** Descarga y ejecución de la app en dispositivos físicos a través de la invitación.
5.  **Actualización:** Ciclo de mejora incremental y despliegue de nuevas versiones.

## 📦 Guía de Publicación
Para replicar este proceso en el equipo de desarrollo, siga estos pasos resumidos:

1.  **Preparación local:**
    *   Verificar permisos de `INTERNET` en `AndroidManifest.xml`.
    *   Generar el binario con el comando:
        ```bash
        flutter build apk --release
        ```
2.  **Carga en Firebase:**
    *   Acceder a [Firebase Console](https://console.firebase.google.com/).
    *   Navegar a **Release & Monitor > App Distribution**.
    *   Subir el archivo `app-release.apk` generado en `build/app/outputs/flutter-apk/`.
3.  **Distribución:**
    *   Asignar el release al grupo de testers `QA_Clase`.
    *   Incluir al tester obligatorio: **dduran@uceva.edu.co**.
    *   Redactar las *Release Notes* y enviar la invitación.

## 🔢 Notas sobre Versionado
En este proyecto, se utiliza un versionado semántico incremental:
*   **Formato en pubspec.yaml:** `version: 1.0.1+2`
    *   `1.0.1`: *versionName* (visible para el usuario).
    *   `2`: *versionCode* (entero incremental para que Android detecte la actualización).
*   **Release Notes:** Se documentan los cambios clave, la fecha del despliegue y los responsables de la versión.

## 🧪 Bitácora de QA
La bitácora detallada de incidencias y estados de las pruebas se encuentra consolidada en el **PDF de evidencias** adjunto en la entrega.

---
