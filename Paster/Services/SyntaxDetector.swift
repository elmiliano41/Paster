import Foundation

enum SyntaxDetector {

    struct LanguagePattern {
        let name: String
        let keywords: [String]
        let weight: Int
    }

    private static let languages: [LanguagePattern] = [
        LanguagePattern(
            name: "swift",
            keywords: ["import Foundation", "import SwiftUI", "import UIKit", "func ", "let ", "var ", "guard ", "struct ", "class ", "enum ", "protocol ", "@Observable", "@State", "@Binding", "-> ", "if let ", "self."],
            weight: 1
        ),
        LanguagePattern(
            name: "python",
            keywords: ["def ", "import ", "from ", "class ", "self,", "self)", "elif ", "print(", "__init__", "lambda ", "None", "True", "False", "    def "],
            weight: 1
        ),
        LanguagePattern(
            name: "javascript",
            keywords: ["const ", "function ", "=>", "console.log", "require(", "module.exports", "async ", "await ", "document.", "window.", ".then(", ".catch(", "undefined"],
            weight: 1
        ),
        LanguagePattern(
            name: "typescript",
            keywords: ["interface ", ": string", ": number", ": boolean", "type ", "export ", "import {", "readonly ", "<T>", "as ", "keyof "],
            weight: 1
        ),
        LanguagePattern(
            name: "html",
            keywords: ["<!DOCTYPE", "<html", "<head", "<body", "<div", "<span", "<script", "<style", "<link", "class=\"", "id=\""],
            weight: 1
        ),
        LanguagePattern(
            name: "css",
            keywords: ["display:", "margin:", "padding:", "color:", "background:", "font-size:", "border:", "@media", ".class", "#id", "flex", "grid"],
            weight: 1
        ),
        LanguagePattern(
            name: "rust",
            keywords: ["fn ", "let mut ", "impl ", "pub ", "use ", "mod ", "match ", "enum ", "struct ", "trait ", "-> ", "&self", "unwrap()", "Result<", "Option<"],
            weight: 1
        ),
        LanguagePattern(
            name: "go",
            keywords: ["package ", "func ", "import (", "fmt.", "err != nil", ":= ", "go func", "chan ", "defer ", "interface{}", "struct {"],
            weight: 1
        ),
        LanguagePattern(
            name: "java",
            keywords: ["public class", "private ", "protected ", "System.out", "void ", "static ", "@Override", "throws ", "new ", "import java", "extends ", "implements "],
            weight: 1
        ),
        LanguagePattern(
            name: "shell",
            keywords: ["#!/bin", "echo ", "export ", "if [", "then", "fi", "done", "#!/usr/bin/env", "grep ", "awk ", "sed ", "chmod "],
            weight: 1
        ),
    ]

    static func detectLanguage(for code: String) -> String? {
        var scores: [String: Int] = [:]

        for language in languages {
            var score = 0
            for keyword in language.keywords {
                if code.contains(keyword) {
                    score += language.weight
                }
            }
            if score > 0 {
                scores[language.name] = score
            }
        }

        guard let best = scores.max(by: { $0.value < $1.value }),
              best.value >= 2 else {
            return nil
        }

        return best.key
    }
}
