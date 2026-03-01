#!/usr/bin/env swift
import AppKit
import Foundation

let width: CGFloat = 540
let height: CGFloat = 380

let image = NSImage(size: NSSize(width: width, height: height))
image.lockFocus()

// Fondo: gradiente suave (gris claro a blanco)
let gradient = NSGradient(colors: [
    NSColor(white: 0.95, alpha: 1),
    NSColor(white: 0.98, alpha: 1)
])!
gradient.draw(from: NSPoint(x: 0, y: 0), to: NSPoint(x: 0, y: height), options: [])

// Texto de instrucción
let text = "Arrastra Paster a la carpeta Aplicaciones"
let font = NSFont.systemFont(ofSize: 22, weight: .medium)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor(white: 0.35, alpha: 1)
]
let string = NSAttributedString(string: text, attributes: attrs)
let textSize = string.size()
let textRect = NSRect(
    x: (width - textSize.width) / 2,
    y: height - 52,
    width: textSize.width,
    height: textSize.height
)
string.draw(in: textRect)

// Flecha: de izquierda (app) hacia derecha (Aplicaciones)
// Puntos aproximados: icono app ~120,150 ; Applications ~420,150
let arrow = NSBezierPath()
let startX: CGFloat = 180
let endX: CGFloat = 360
let centerY: CGFloat = height / 2 - 10
let arrowHeadSize: CGFloat = 14

// Línea horizontal
arrow.move(to: NSPoint(x: startX, y: centerY))
arrow.line(to: NSPoint(x: endX - arrowHeadSize, y: centerY))
arrow.lineWidth = 4
arrow.lineCapStyle = .round
NSColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 0.9).setStroke()
arrow.stroke()

// Punta de flecha (triángulo)
let head = NSBezierPath()
head.move(to: NSPoint(x: endX, y: centerY))
head.line(to: NSPoint(x: endX - arrowHeadSize, y: centerY - arrowHeadSize * 0.6))
head.line(to: NSPoint(x: endX - arrowHeadSize, y: centerY + arrowHeadSize * 0.6))
head.close()
NSColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 0.95).setFill()
head.fill()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Error generando PNG\n", stderr)
    exit(1)
}

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let outURL = scriptDir.appendingPathComponent("background.png")
try pngData.write(to: outURL)
print("Generado: \(outURL.path)")
