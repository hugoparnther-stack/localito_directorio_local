@echo off
echo ============================================
echo   Directorio Local - Compilar APK
echo ============================================
echo.
cd /d "%~dp0"

echo [1/2] Instalando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Verifica que Flutter este instalado y en el PATH.
    pause & exit /b 1
)

echo.
echo [2/2] Compilando APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: La compilacion fallo. Revisa los mensajes de error arriba.
    pause & exit /b 1
)

echo.
echo ============================================
echo  APK generado en:
echo  build\app\outputs\flutter-apk\app-release.apk
echo ============================================
pause
