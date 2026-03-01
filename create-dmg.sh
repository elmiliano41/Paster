#!/bin/bash
set -e

APP_NAME="Paster"
DMG_NAME="${APP_NAME}-Installer"
VOLUME_NAME="${APP_NAME}"
STAGING_DIR="dmg_stage"
DMG_RESOURCES="DMGResources"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📦 Creando DMG de instalación..."

if [ ! -d "$APP_NAME.app" ]; then
    echo "❌ No se encuentra $APP_NAME.app. Ejecuta primero: ./build-app.sh"
    exit 1
fi

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_NAME.app" "$STAGING_DIR/"

DMG_PATH="${DMG_NAME}.dmg"
rm -f "$DMG_PATH"

if command -v create-dmg &>/dev/null; then
    # UI con fondo, flecha e instrucción (requiere: brew install create-dmg)
    echo "🎨 Generando imagen de fondo..."
    if [ ! -f "$DMG_RESOURCES/background.png" ]; then
        swift "$SCRIPT_DIR/$DMG_RESOURCES/generate-background.swift"
    fi
    VOL_ICON="$APP_NAME.app/Contents/Resources/AppIcon.icns"
    VOLICON_ARG=""
    if [ -f "$VOL_ICON" ]; then
        VOLICON_ARG="--volicon $VOL_ICON"
    fi
    echo "🖼️  Creando DMG con fondo e iconos..."
    create-dmg \
        --volname "$VOLUME_NAME" \
        $VOLICON_ARG \
        --window-size 540 380 \
        --window-pos 200 120 \
        --icon-size 96 \
        --icon "$APP_NAME.app" 100 150 \
        --app-drop-link 400 150 \
        --background "$DMG_RESOURCES/background.png" \
        --hide-extension "$APP_NAME.app" \
        "$DMG_PATH" \
        "$STAGING_DIR"
else
    # Fallback: DMG simple sin fondo
    echo "⚠️  create-dmg no instalado. Para DMG con flecha e instrucción: brew install create-dmg"
    echo "   Creando DMG básico..."
    ln -sf /Applications "$STAGING_DIR/Applications"
    hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"
fi

rm -rf "$STAGING_DIR"

echo "✅ DMG creado: $DMG_PATH"
echo "   Ábrelo y arrastra Paster a la carpeta Aplicaciones."
