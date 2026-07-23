//
//  Question.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/29/26.
//

import Foundation

struct Question: Sendable {
    let text: String
    let options: [String]
    let correctAnswer: String
}

struct QuestionSet: Sendable {
    let name: String
    let questions: [Question]
}

extension String {
    var htmlDecoded: String {
        var result = self
        let replacements: [String: String] = [
            // Basic HTML
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            
            // Quotes and dashes
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&lsquo;": "\u{2018}",
            "&rsquo;": "\u{2019}",
            "&laquo;": "«",
            "&raquo;": "»",
            "&mdash;": "—",
            "&ndash;": "–",
            "&hellip;": "...",
            "&sbquo;": "‚",
            "&bdquo;": "„",
            
            // Spaces and special
            "&nbsp;": " ",
            "&shy;": "",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™",
            "&deg;": "°",
            "&permil;": "‰",
            "&para;": "¶",
            "&sect;": "§",
            "&dagger;": "†",
            "&Dagger;": "‡",
            "&bull;": "•",
            "&prime;": "′",
            "&Prime;": "″",
            
            // Math
            "&sup2;": "²",
            "&sup3;": "³",
            "&sup1;": "¹",
            "&frac12;": "½",
            "&frac14;": "¼",
            "&frac34;": "¾",
            "&divide;": "÷",
            "&times;": "×",
            "&plusmn;": "±",
            "&ne;": "≠",
            "&le;": "≤",
            "&ge;": "≥",
            "&pi;": "π",
            "&infin;": "∞",
            "&sum;": "∑",
            "&prod;": "∏",
            "&radic;": "√",
            "&int;": "∫",
            "&asymp;": "≈",
            "&equiv;": "≡",
            "&sub;": "⊂",
            "&sup;": "⊃",
            "&empty;": "∅",
            "&minus;": "−",
            "&lowast;": "∗",
            "&and;": "∧",
            "&or;": "∨",
            "&there4;": "∴",
            "&sim;": "∼",
            "&cong;": "≅",
            
            // Currency
            "&euro;": "€",
            "&pound;": "£",
            "&yen;": "¥",
            "&cent;": "¢",
            "&curren;": "¤",
            
            // Accented letters - lowercase
            "&agrave;": "à",
            "&aacute;": "á",
            "&acirc;": "â",
            "&atilde;": "ã",
            "&auml;": "ä",
            "&aring;": "å",
            "&aelig;": "æ",
            "&ccedil;": "ç",
            "&egrave;": "è",
            "&eacute;": "é",
            "&ecirc;": "ê",
            "&euml;": "ë",
            "&igrave;": "ì",
            "&iacute;": "í",
            "&icirc;": "î",
            "&iuml;": "ï",
            "&eth;": "ð",
            "&ntilde;": "ñ",
            "&ograve;": "ò",
            "&oacute;": "ó",
            "&ocirc;": "ô",
            "&otilde;": "õ",
            "&ouml;": "ö",
            "&oslash;": "ø",
            "&ugrave;": "ù",
            "&uacute;": "ú",
            "&ucirc;": "û",
            "&uuml;": "ü",
            "&yacute;": "ý",
            "&thorn;": "þ",
            "&yuml;": "ÿ",
            
            // Accented letters - uppercase
            "&Agrave;": "À",
            "&Aacute;": "Á",
            "&Acirc;": "Â",
            "&Atilde;": "Ã",
            "&Auml;": "Ä",
            "&Aring;": "Å",
            "&AElig;": "Æ",
            "&Ccedil;": "Ç",
            "&Egrave;": "È",
            "&Eacute;": "É",
            "&Ecirc;": "Ê",
            "&Euml;": "Ë",
            "&Igrave;": "Ì",
            "&Iacute;": "Í",
            "&Icirc;": "Î",
            "&Iuml;": "Ï",
            "&ETH;": "Ð",
            "&Ntilde;": "Ñ",
            "&Ograve;": "Ò",
            "&Oacute;": "Ó",
            "&Ocirc;": "Ô",
            "&Otilde;": "Õ",
            "&Ouml;": "Ö",
            "&Oslash;": "Ø",
            "&Ugrave;": "Ù",
            "&Uacute;": "Ú",
            "&Ucirc;": "Û",
            "&Uuml;": "Ü",
            "&Yacute;": "Ý",
            "&THORN;": "Þ",
            
            // Greek letters
            "&alpha;": "α",
            "&beta;": "β",
            "&gamma;": "γ",
            "&delta;": "δ",
            "&epsilon;": "ε",
            "&zeta;": "ζ",
            "&eta;": "η",
            "&theta;": "θ",
            "&iota;": "ι",
            "&kappa;": "κ",
            "&lambda;": "λ",
            "&mu;": "μ",
            "&nu;": "ν",
            "&xi;": "ξ",
            "&omicron;": "ο",
            "&rho;": "ρ",
            "&sigma;": "σ",
            "&tau;": "τ",
            "&upsilon;": "υ",
            "&phi;": "φ",
            "&chi;": "χ",
            "&psi;": "ψ",
            "&omega;": "ω",
            "&Alpha;": "Α",
            "&Beta;": "Β",
            "&Gamma;": "Γ",
            "&Delta;": "Δ",
            "&Epsilon;": "Ε",
            "&Theta;": "Θ",
            "&Lambda;": "Λ",
            "&Pi;": "Π",
            "&Sigma;": "Σ",
            "&Phi;": "Φ",
            "&Psi;": "Ψ",
            "&Omega;": "Ω",
            
            // Arrows
            "&larr;": "←",
            "&rarr;": "→",
            "&uarr;": "↑",
            "&darr;": "↓",
            "&harr;": "↔",
            "&lArr;": "⇐",
            "&rArr;": "⇒",
            "&uArr;": "⇑",
            "&dArr;": "⇓",
            "&hArr;": "⇔",
            
            // Misc symbols
            "&spades;": "♠",
            "&clubs;": "♣",
            "&hearts;": "♥",
            "&diams;": "♦",
            "&star;": "★",
            "&phone;": "☎",
            "&check;": "✓",
            "&cross;": "✗",
            "&male;": "♂",
            "&female;": "♀",
            "&music;": "♫",
            "&sung;": "♪",
            "&sun;": "☀",
            "&cloud;": "☁",
            "&umbrella;": "☂",
            "&snowflake;": "❄",
        ]
        for (key, value) in replacements {
            result = result.replacingOccurrences(of: key, with: value)
        }
        // Remove any remaining HTML tags
        let tagPattern = "<[^>]+>"
        if let regex = try? NSRegularExpression(pattern: tagPattern) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "")
        }
        return result
    }
}
