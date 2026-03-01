import Foundation

/// Acciones rápidas para contenido de clipboard (formatear JSON, Base64, JWT, etc.)
enum ClipboardActionsService {

    // MARK: - Detection

    static func looksLikeJSON(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
               (trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
    }

    static func looksLikeJWT(_ string: String) -> Bool {
        let parts = string.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")
        return parts.count == 3 && parts.allSatisfy { part in
            part.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
        }
    }

    // MARK: - JSON

    static func formatJSON(_ string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let formatted = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys])
        else { return nil }
        return String(data: formatted, encoding: .utf8)
    }

    static func minifyJSON(_ string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let minified = try? JSONSerialization.data(withJSONObject: obj)
        else { return nil }
        return String(data: minified, encoding: .utf8)
    }

    // MARK: - Base64

    static func decodeBase64(_ string: String) -> String? {
        let cleaned = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        guard let data = Data(base64Encoded: cleaned),
              let decoded = String(data: data, encoding: .utf8)
        else { return nil }
        return decoded
    }

    static func encodeBase64(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }

    // MARK: - JWT

    /// Decodifica un JWT y devuelve header y payload en JSON formateado (solo para visualización; no verifica firma).
    static func decodeJWT(_ string: String) -> (header: String, payload: String)? {
        let parts = string.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")
        guard parts.count == 3 else { return nil }

        func decodePart(_ part: String.SubSequence) -> String? {
            let base64 = String(part)
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let padding = base64.count % 4
            let padded = padding == 0 ? base64 : base64 + String(repeating: "=", count: 4 - padding)
            guard let data = Data(base64Encoded: padded),
                  let json = try? JSONSerialization.jsonObject(with: data),
                  let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            else { return nil }
            return String(data: pretty, encoding: .utf8)
        }

        guard let header = decodePart(parts[0]),
              let payload = decodePart(parts[1])
        else { return nil }
        return (header, payload)
    }

    /// Devuelve una sola string con header y payload para copiar al portapapeles.
    static func decodeJWTToCopyableString(_ string: String) -> String? {
        guard let (header, payload) = decodeJWT(string) else { return nil }
        return "// Header\n\(header)\n\n// Payload\n\(payload)"
    }
}
