#!/bin/bash
set -e

APP_NAME="Paster"
BUNDLE_ID="com.emilianosanchez.paster"
VERSION="1.2.0"
BUILD_DIR=".build/release"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Compilando $APP_NAME en release..."
swift build -c release

echo "📦 Creando $APP_DIR..."

# Limpiar build anterior
rm -rf "$APP_DIR"

# Crear estructura del .app bundle
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copiar el binario
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"

# Copiar recursos de localización
echo "🌍 Copiando archivos de localización..."
if [ -d "Paster/Resources/en.lproj" ]; then
    cp -r "Paster/Resources/en.lproj" "$RESOURCES_DIR/"
fi
if [ -d "Paster/Resources/es.lproj" ]; then
    cp -r "Paster/Resources/es.lproj" "$RESOURCES_DIR/"
fi

ICONSET_SRC="Paster/Resources/Assets.xcassets/AppIcon.appiconset"
ICONSET_TMP=$(mktemp -d)/AppIcon.iconset
mkdir -p "$ICONSET_TMP"
for size in 16 32 128 256 512; do
  [ -f "$ICONSET_SRC/icon_${size}.png" ] && cp "$ICONSET_SRC/icon_${size}.png" "$ICONSET_TMP/icon_${size}x${size}.png"
  [ -f "$ICONSET_SRC/icon_${size}@2x.png" ] && cp "$ICONSET_SRC/icon_${size}@2x.png" "$ICONSET_TMP/icon_${size}x${size}@2x.png"
done
iconutil -c icns -o "$RESOURCES_DIR/AppIcon.icns" "$ICONSET_TMP"
rm -rf "$(dirname "$ICONSET_TMP")"

# Crear Info.plist
cat > "$CONTENTS_DIR/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Emiliano Sanchez. All rights reserved.</string>
</dict>
</plist>
PLIST

echo "✅ $APP_DIR creado exitosamente!"
echo ""
echo "Para instalar:"
echo "  cp -r $APP_DIR /Applications/"
echo ""
echo "Para ejecutar:"
echo "  open $APP_DIR"
