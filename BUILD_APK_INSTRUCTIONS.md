# Instrucciones para Compilar el APK de ETH Trading Bot

## Requisitos Previos

1. **Flutter SDK** instalado (versión 3.13.8 o superior)
2. **Android Studio** o **Android SDK** instalado
3. **Java Development Kit (JDK)** versión 11 o superior

## Pasos para Compilar el APK

### Opción 1: Usando tu computadora local

1. **Clona o descarga el proyecto**:
   ```bash
   git clone <tu-repositorio>
   cd eth_trading_bot
   ```

2. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

3. **Compila el APK de release**:
   ```bash
   flutter build apk --release
   ```

4. **Encuentra tu APK**:
   - El archivo APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Opción 2: Usando GitHub Actions (Recomendado)

Crea un archivo `.github/workflows/build.yml` en tu repositorio con el siguiente contenido:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.8'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: eth-trading-bot-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Opción 3: Usando Codemagic (Servicio en línea gratuito)

1. Ve a [https://codemagic.io](https://codemagic.io)
2. Conecta tu repositorio de GitHub/GitLab/Bitbucket
3. Selecciona "Flutter App"
4. Configura el build para Android
5. Inicia el build
6. Descarga el APK cuando termine

## Configuración del APK

El APK está configurado con:
- **Nombre del paquete**: `com.eth_trading_bot.app`
- **Versión**: 1.0.0+1
- **SDK mínimo**: Android 6.0 (API 23)
- **Multidex**: Habilitado

## Instalación del APK

### En un dispositivo Android:

1. **Habilita fuentes desconocidas**:
   - Ve a Configuración > Seguridad
   - Activa "Fuentes desconocidas" o "Instalar aplicaciones desconocidas"

2. **Transfiere el APK**:
   - Envía el archivo `app-release.apk` a tu dispositivo
   - Puedes usar WhatsApp, Google Drive, email, o cable USB

3. **Instala**:
   - Abre el archivo APK en tu dispositivo
   - Toca "Instalar"
   - Una vez instalado, toca "Abrir"

## Solución de Problemas

### Error: "No Android SDK found"
- Instala Android Studio desde [https://developer.android.com/studio](https://developer.android.com/studio)
- O instala solo el SDK: `flutter doctor --android-licenses`

### Error: "Build failed"
- Ejecuta `flutter clean` y luego `flutter pub get`
- Verifica que tienes Java 11: `java -version`

### APK muy grande
- Puedes compilar APKs separados por arquitectura:
  ```bash
  flutter build apk --split-per-abi
  ```
  Esto creará APKs más pequeños para cada arquitectura (arm64, armeabi, x86_64)

## Versión Web Disponible

Mientras tanto, puedes acceder a la versión web de la aplicación en:
[https://etheriumpro-9744d.web.app](https://etheriumpro-9744d.web.app)

## Notas Importantes

- El APK está firmado con certificado de debug por defecto
- Para publicar en Google Play Store, necesitarás crear un certificado de release
- La aplicación requiere conexión a internet para funcionar correctamente
