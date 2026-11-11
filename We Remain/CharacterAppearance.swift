import Foundation
import SpriteKit

// MARK: - Character Style

enum CharacterStyle:
    String,
    CaseIterable,
    Codable,
    Identifiable {

    case man
    case woman

    var id: String {
        rawValue
    }

    var displayName: String {

        switch self {

        case .man:
            return "MAN"

        case .woman:
            return "WOMAN"
        }
    }
}


// MARK: - Skin Tone

// Retained for compatibility with existing saved progress.
// Current character PNG assets use their baked-in skin tone.

enum SkinTone:
    String,
    CaseIterable,
    Codable,
    Identifiable {

    case light
    case fair
    case tan
    case medium
    case brown
    case deep

    var id: String {
        rawValue
    }

    var displayName: String {

        switch self {

        case .light:
            return "LIGHT"

        case .fair:
            return "FAIR"

        case .tan:
            return "TAN"

        case .medium:
            return "MEDIUM"

        case .brown:
            return "BROWN"

        case .deep:
            return "DEEP"
        }
    }

    var color: SKColor {

        switch self {

        case .light:
            return SKColor(
                red: 0.98,
                green: 0.82,
                blue: 0.70,
                alpha: 1
            )

        case .fair:
            return SKColor(
                red: 0.91,
                green: 0.70,
                blue: 0.55,
                alpha: 1
            )

        case .tan:
            return SKColor(
                red: 0.76,
                green: 0.53,
                blue: 0.38,
                alpha: 1
            )

        case .medium:
            return SKColor(
                red: 0.61,
                green: 0.40,
                blue: 0.27,
                alpha: 1
            )

        case .brown:
            return SKColor(
                red: 0.45,
                green: 0.29,
                blue: 0.20,
                alpha: 1
            )

        case .deep:
            return SKColor(
                red: 0.31,
                green: 0.19,
                blue: 0.14,
                alpha: 1
            )
        }
    }
}


// MARK: - Survivor Outfit

enum SurvivorOutfit:
    String,
    CaseIterable,
    Codable,
    Identifiable {

    case survivor
    case streetwear
    case tactical
    case medic
    case biker
    case hunter

    var id: String {
        rawValue
    }

    var displayName: String {

        switch self {

        case .survivor:
            return "SURVIVOR"

        case .streetwear:
            return "STREETWEAR"

        case .tactical:
            return "TACTICAL"

        case .medic:
            return "MEDIC"

        case .biker:
            return "BIKER"

        case .hunter:
            return "ZOMBIE HUNTER"
        }
    }

    var price: Int {

        switch self {

        case .survivor:
            return 0

        case .streetwear:
            return 250

        case .tactical:
            return 500

        case .medic:
            return 650

        case .biker:
            return 900

        case .hunter:
            return 1500
        }
    }

    // MARK: Woman Asset Names

    var womanTextureName: String {

        switch self {

        case .survivor:
            return "Woman_Survivor"

        case .streetwear:
            return "Woman_Streetwear"

        case .tactical:
            return "Woman_Tactical"

        case .medic:
            return "Woman_Medic"

        case .biker:
            return "Woman_Biker"

        case .hunter:
            return "Woman_ZombieHunter"
        }
    }

    // MARK: Man Asset Names

    var manTextureName: String {

        switch self {

        case .survivor:
            return "Man_Survivor"

        case .streetwear:
            return "Man_Streetwear"

        case .tactical:
            return "Man_Tactical"

        case .medic:
            return "Man_Medic"

        case .biker:
            return "Man_Biker"

        case .hunter:
            return "Man_ZombieHunter"
        }
    }

    // MARK: Correct Texture for Selected Character

    func textureName(
        for style: CharacterStyle
    ) -> String {

        switch style {

        case .man:
            return manTextureName

        case .woman:
            return womanTextureName
        }
    }
}


// MARK: - Character Appearance

struct CharacterAppearance {

    let style: CharacterStyle
    let skinTone: SkinTone
    let outfit: SurvivorOutfit

    var textureName: String {

        outfit.textureName(
            for: style
        )
    }
}


// MARK: - Character Upgrades

enum CharacterUpgrade:
    String,
    CaseIterable,
    Identifiable {

    case armor
    case magnet
    case scavenger

    var id: String {
        rawValue
    }

    var maxLevel: Int {
        3
    }

    func price(
        for level: Int
    ) -> Int {

        switch level {

        case 0:
            return 300

        case 1:
            return 650

        default:
            return 1100
        }
    }
}
