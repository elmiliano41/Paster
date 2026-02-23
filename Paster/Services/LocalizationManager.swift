import Foundation
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case spanish = "es"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: "System"
        case .english: "English"
        case .spanish: "Español"
        }
    }
}

@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()
    
    private(set) var currentLanguage: AppLanguage
    private var strings: [String: String] = [:]
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: AppConstants.Defaults.appLanguage) ?? "system"
        currentLanguage = AppLanguage(rawValue: savedLanguage) ?? .system
        loadStrings()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: AppConstants.Defaults.appLanguage)
        loadStrings()
    }
    
    private func loadStrings() {
        strings = [:]
        
        let languageCode: String
        if currentLanguage == .system {
            languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            languageCode = currentLanguage.rawValue
        }
        
        // Try to load from bundle
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "\(languageCode).lproj"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            strings = dict
        }
        // Fallback to Resources folder in app bundle
        else if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "Resources/\(languageCode).lproj"),
                let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            strings = dict
        }
        // Fallback to English if not found
        else if languageCode != "en",
                let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: "en.lproj"),
                let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            strings = dict
        }
    }
    
    func localizedString(_ key: String) -> String {
        if let value = strings[key] {
            return value
        }
        // Fallback to system localization
        return String(localized: String.LocalizationValue(key))
    }
}

func L(_ key: String) -> String {
    LocalizationManager.shared.localizedString(key)
}

extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
}
