# Paster - Clipboard Manager para macOS

Un clipboard manager profesional y nativo para macOS, construido con SwiftUI.

## Requisitos

- **macOS 14.0** (Sonoma) o superior
- Swift 5.10+ (viene con las Command Line Tools de Xcode)

## Compilar y Ejecutar

```bash
cd /Users/emilianosanchez/Documents/Utilities/Paster

# Compilar
swift build

# Ejecutar
swift run
```

La app aparece como un icono de clipboard en la **barra de menú** (arriba a la derecha).

Presiona **Cmd+Shift+V** desde cualquier lugar para abrir la ventana flotante.

## Funcionalidades

- **Historial de clipboard**: Todo lo que copias se guarda automáticamente
- **Menu bar**: Acceso rápido desde la barra de menú
- **Ventana flotante**: Activar con `Cmd+Shift+V` desde cualquier lugar
- **Búsqueda instantánea**: Filtra tu historial en tiempo real
- **Detección de tipos**: Texto, código, imágenes, enlaces, archivos
- **Syntax highlighting**: Coloreado de código con detección automática de lenguaje
- **Preview de contenido**: Vista previa de imágenes, links con metadata, código con números de línea
- **Categorías**: Organiza tu historial con categorías personalizadas con iconos y colores
- **Elementos fijados**: Fija los items que no quieras perder
- **Persistencia en JSON**: Los datos se guardan en `~/Library/Application Support/Paster/`

## Estructura del proyecto

```
Paster/
├── Package.swift                 # Configuración SPM
├── README.md
└── Paster/
    ├── PasterApp.swift           # Entry point
    ├── AppDelegate.swift         # NSApplicationDelegate
    ├── Models/
    │   ├── ClipItem.swift        # Modelo principal (Codable)
    │   ├── Category.swift        # Categorías (Codable)
    │   └── ClipItemType.swift    # Enum de tipos
    ├── Services/
    │   ├── DataStore.swift           # Persistencia JSON + queries
    │   ├── ClipboardMonitor.swift    # Polling de NSPasteboard
    │   ├── PasteService.swift        # Copiar/pegar al clipboard
    │   ├── HotKeyManager.swift       # Atajos globales
    │   ├── FloatingPanelManager.swift # Gestión ventana flotante
    │   └── SyntaxDetector.swift      # Detección de lenguaje
    ├── Views/
    │   ├── MenuBar/
    │   │   └── MenuBarView.swift
    │   ├── FloatingPanel/
    │   │   ├── FloatingPanelView.swift
    │   │   ├── SearchBarView.swift
    │   │   ├── ClipItemRow.swift
    │   │   └── ClipItemDetail.swift
    │   ├── Previews/
    │   │   ├── TextPreview.swift
    │   │   ├── CodePreview.swift
    │   │   ├── ImagePreview.swift
    │   │   └── LinkPreview.swift
    │   ├── Settings/
    │   │   ├── SettingsView.swift
    │   │   ├── HotKeySettingsView.swift
    │   │   └── CategoryManagement.swift
    │   └── Components/
    │       ├── CategoryBadge.swift
    │       ├── PinButton.swift
    │       ├── TimeAgoLabel.swift
    │       └── ClipTypeIcon.swift
    ├── Utils/
    │   ├── Constants.swift
    │   └── Extensions.swift
    └── Resources/
        └── Assets.xcassets
```

## Permisos necesarios

La app puede necesitar permisos de **Accesibilidad** para:
- Registrar atajos de teclado globales (Cmd+Shift+V)
- Simular la acción de pegar (Cmd+V) en otras apps

Ve a **Preferencias del Sistema → Privacidad y Seguridad → Accesibilidad** y agrega el terminal o la app Paster.

## Dependencias

| Paquete | Versión | Uso |
|---------|---------|-----|
| [soffes/HotKey](https://github.com/soffes/HotKey) | 0.2.1+ | Atajos de teclado globales |

## Datos

Los datos se persisten como archivos JSON en:
```
~/Library/Application Support/Paster/
├── clip_items.json
└── categories.json
```
