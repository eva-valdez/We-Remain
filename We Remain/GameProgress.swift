import Foundation
import SwiftUI

// MARK: - Survival Missions

enum SurvivalMission:
    String,
    CaseIterable,
    Identifiable {

    case distance
    case scrap
    case runs
    case nearMisses

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .distance:
            return "DISTANCE"
        case .scrap:
            return "SCAVENGER"
        case .runs:
            return "SURVIVOR"
        case .nearMisses:
            return "CLOSE CALLS"
        }
    }

    func goal(
        for level: Int
    ) -> Int {

        let safeLevel = max(
            level,
            0
        )

        switch self {

        case .distance:
            return 500 + (safeLevel * 250)

        case .scrap:
            return 75 + (safeLevel * 30)

        case .runs:
            return 3 + (safeLevel * 2)

        case .nearMisses:
            return 2 + safeLevel
        }
    }

    func reward(
        for level: Int
    ) -> Int {

        let safeLevel = max(
            level,
            0
        )

        switch self {

        case .distance:
            return 250 + (safeLevel * 75)

        case .scrap:
            return 225 + (safeLevel * 65)

        case .runs:
            return 275 + (safeLevel * 85)

        case .nearMisses:
            return 300 + (safeLevel * 90)
        }
    }
}


// MARK: - Game Progress

final class GameProgress:
    ObservableObject {

    static let shared =
        GameProgress()

    private let defaults =
        UserDefaults.standard


    // MARK: Currency / Records

    @Published
    var totalScrap: Int

    @Published
    var bestDistance: Int


    // MARK: Character

    @Published
    var selectedStyle:
        CharacterStyle

    @Published
    var selectedSkin:
        SkinTone

    @Published
    var selectedOutfit:
        SurvivorOutfit

    @Published
    var unlockedOutfits:
        Set<SurvivorOutfit>


    // MARK: Mission Progress

    @Published
    var missionDistance: Int

    @Published
    var missionScrap: Int

    @Published
    var missionRuns: Int

    @Published
    var missionNearMisses: Int


    // MARK: Mission Levels

    @Published
    var distanceMissionLevel: Int

    @Published
    var scrapMissionLevel: Int

    @Published
    var runsMissionLevel: Int

    @Published
    var nearMissMissionLevel: Int


    // Legacy compatibility

    @Published
    var claimedMissions:
        Set<String>


    // MARK: Upgrades

    @Published
    var armorLevel: Int

    @Published
    var magnetLevel: Int

    @Published
    var scavengerLevel: Int


    // MARK: Keys

    private enum Key {

        static let totalScrap =
            "deadRun.totalScrap"

        static let bestDistance =
            "deadRun.bestDistance"

        static let selectedStyle =
            "deadRun.selectedStyle"

        static let selectedSkin =
            "deadRun.selectedSkin"

        static let selectedOutfit =
            "deadRun.selectedOutfit"

        static let unlockedOutfits =
            "deadRun.unlockedOutfits"

        static let missionDistance =
            "deadRun.missionDistance"

        static let missionScrap =
            "deadRun.missionScrap"

        static let missionRuns =
            "deadRun.missionRuns"

        static let missionNearMisses =
            "deadRun.missionNearMisses"

        static let claimedMissions =
            "deadRun.claimedMissions"

        static let distanceMissionLevel =
            "weRemain.distanceMissionLevel"

        static let scrapMissionLevel =
            "weRemain.scrapMissionLevel"

        static let runsMissionLevel =
            "weRemain.runsMissionLevel"

        static let nearMissMissionLevel =
            "weRemain.nearMissMissionLevel"

        static let armorLevel =
            "deadRun.armorLevel"

        static let magnetLevel =
            "deadRun.magnetLevel"

        static let scavengerLevel =
            "deadRun.scavengerLevel"
    }


    // MARK: Appearance

    var appearance:
        CharacterAppearance {

        CharacterAppearance(
            style: selectedStyle,
            skinTone: selectedSkin,
            outfit: selectedOutfit
        )
    }


    // MARK: Init

    private init() {

        // -----------------------------------------
        // Load everything into LOCAL constants first
        // -----------------------------------------

        let loadedTotalScrap =
            defaults.integer(
                forKey:
                    Key.totalScrap
            )

        let loadedBestDistance =
            defaults.integer(
                forKey:
                    Key.bestDistance
            )


        let loadedStyle:
            CharacterStyle

        if
            let saved =
                defaults.string(
                    forKey:
                        Key.selectedStyle
                ),
            let value =
                CharacterStyle(
                    rawValue:
                        saved
                ) {

            loadedStyle =
                value

        } else {

            loadedStyle =
                .woman
        }


        let loadedSkin:
            SkinTone

        if
            let saved =
                defaults.string(
                    forKey:
                        Key.selectedSkin
                ),
            let value =
                SkinTone(
                    rawValue:
                        saved
                ) {

            loadedSkin =
                value

        } else {

            loadedSkin =
                .tan
        }


        let savedOutfitStrings =
            defaults.stringArray(
                forKey:
                    Key.unlockedOutfits
            )
            ?? []


        var loadedUnlockedOutfits =
            Set(
                savedOutfitStrings
                    .compactMap {
                        SurvivorOutfit(
                            rawValue:
                                $0
                        )
                    }
            )


        loadedUnlockedOutfits.insert(
            .survivor
        )


        let savedSelectedOutfit =
            defaults.string(
                forKey:
                    Key.selectedOutfit
            )


        var loadedSelectedOutfit =
            savedSelectedOutfit
                .flatMap {
                    SurvivorOutfit(
                        rawValue:
                            $0
                    )
                }
            ?? .survivor


        if
            !loadedUnlockedOutfits
                .contains(
                    loadedSelectedOutfit
                ) {

            loadedSelectedOutfit =
                .survivor
        }


        let loadedMissionDistance =
            defaults.integer(
                forKey:
                    Key.missionDistance
            )

        let loadedMissionScrap =
            defaults.integer(
                forKey:
                    Key.missionScrap
            )

        let loadedMissionRuns =
            defaults.integer(
                forKey:
                    Key.missionRuns
            )

        let loadedMissionNearMisses =
            defaults.integer(
                forKey:
                    Key.missionNearMisses
            )


        let loadedDistanceMissionLevel =
            defaults.integer(
                forKey:
                    Key.distanceMissionLevel
            )

        let loadedScrapMissionLevel =
            defaults.integer(
                forKey:
                    Key.scrapMissionLevel
            )

        let loadedRunsMissionLevel =
            defaults.integer(
                forKey:
                    Key.runsMissionLevel
            )

        let loadedNearMissMissionLevel =
            defaults.integer(
                forKey:
                    Key.nearMissMissionLevel
            )


        let loadedClaimedMissions =
            Set(
                defaults.stringArray(
                    forKey:
                        Key.claimedMissions
                )
                ?? []
            )


        let loadedArmorLevel =
            min(
                max(
                    defaults.integer(
                        forKey:
                            Key.armorLevel
                    ),
                    0
                ),
                3
            )

        let loadedMagnetLevel =
            min(
                max(
                    defaults.integer(
                        forKey:
                            Key.magnetLevel
                    ),
                    0
                ),
                3
            )

        let loadedScavengerLevel =
            min(
                max(
                    defaults.integer(
                        forKey:
                            Key.scavengerLevel
                    ),
                    0
                ),
                3
            )


        // -----------------------------------------
        // Now initialize EVERY stored property
        // -----------------------------------------

        self.totalScrap =
            loadedTotalScrap

        self.bestDistance =
            loadedBestDistance

        self.selectedStyle =
            loadedStyle

        self.selectedSkin =
            loadedSkin

        self.selectedOutfit =
            loadedSelectedOutfit

        self.unlockedOutfits =
            loadedUnlockedOutfits

        self.missionDistance =
            loadedMissionDistance

        self.missionScrap =
            loadedMissionScrap

        self.missionRuns =
            loadedMissionRuns

        self.missionNearMisses =
            loadedMissionNearMisses

        self.distanceMissionLevel =
            loadedDistanceMissionLevel

        self.scrapMissionLevel =
            loadedScrapMissionLevel

        self.runsMissionLevel =
            loadedRunsMissionLevel

        self.nearMissMissionLevel =
            loadedNearMissMissionLevel

        self.claimedMissions =
            loadedClaimedMissions

        self.armorLevel =
            loadedArmorLevel

        self.magnetLevel =
            loadedMagnetLevel

        self.scavengerLevel =
            loadedScavengerLevel


        // Safe to call now because self is fully initialized.

        save()
    }


    // MARK: Save

    private func save() {

        defaults.set(
            totalScrap,
            forKey:
                Key.totalScrap
        )

        defaults.set(
            bestDistance,
            forKey:
                Key.bestDistance
        )

        defaults.set(
            selectedStyle.rawValue,
            forKey:
                Key.selectedStyle
        )

        defaults.set(
            selectedSkin.rawValue,
            forKey:
                Key.selectedSkin
        )

        defaults.set(
            selectedOutfit.rawValue,
            forKey:
                Key.selectedOutfit
        )

        defaults.set(
            unlockedOutfits.map {
                $0.rawValue
            },
            forKey:
                Key.unlockedOutfits
        )

        defaults.set(
            missionDistance,
            forKey:
                Key.missionDistance
        )

        defaults.set(
            missionScrap,
            forKey:
                Key.missionScrap
        )

        defaults.set(
            missionRuns,
            forKey:
                Key.missionRuns
        )

        defaults.set(
            missionNearMisses,
            forKey:
                Key.missionNearMisses
        )

        defaults.set(
            claimedMissions.map {
                $0
            },
            forKey:
                Key.claimedMissions
        )

        defaults.set(
            distanceMissionLevel,
            forKey:
                Key.distanceMissionLevel
        )

        defaults.set(
            scrapMissionLevel,
            forKey:
                Key.scrapMissionLevel
        )

        defaults.set(
            runsMissionLevel,
            forKey:
                Key.runsMissionLevel
        )

        defaults.set(
            nearMissMissionLevel,
            forKey:
                Key.nearMissMissionLevel
        )

        defaults.set(
            armorLevel,
            forKey:
                Key.armorLevel
        )

        defaults.set(
            magnetLevel,
            forKey:
                Key.magnetLevel
        )

        defaults.set(
            scavengerLevel,
            forKey:
                Key.scavengerLevel
        )
    }


    // MARK: Scrap

    func addScrap(
        _ amount: Int
    ) {

        totalScrap +=
            max(
                amount,
                0
            )

        save()
    }


    // MARK: Character

    func selectStyle(
        _ style:
            CharacterStyle
    ) {

        selectedStyle =
            style

        save()
    }


    func selectSkin(
        _ skin:
            SkinTone
    ) {

        selectedSkin =
            skin

        save()
    }


    func isUnlocked(
        _ outfit:
            SurvivorOutfit
    ) -> Bool {

        unlockedOutfits
            .contains(
                outfit
            )
    }


    func equip(
        _ outfit:
            SurvivorOutfit
    ) {

        guard
            isUnlocked(
                outfit
            )
        else {
            return
        }

        selectedOutfit =
            outfit

        save()
    }


    @discardableResult
    func purchase(
        _ outfit:
            SurvivorOutfit
    ) -> Bool {

        if
            unlockedOutfits
                .contains(
                    outfit
                ) {

            selectedOutfit =
                outfit

            save()

            return true
        }


        guard
            totalScrap >=
                outfit.price
        else {
            return false
        }


        totalScrap -=
            outfit.price

        unlockedOutfits
            .insert(
                outfit
            )

        selectedOutfit =
            outfit

        save()

        return true
    }


    // MARK: Runs

    func recordRun(
        distance: Int,
        scrapCollected: Int
    ) {

        let safeDistance =
            max(
                distance,
                0
            )

        let safeScrap =
            max(
                scrapCollected,
                0
            )


        bestDistance =
            max(
                bestDistance,
                safeDistance
            )

        missionDistance +=
            safeDistance

        missionScrap +=
            safeScrap

        missionRuns += 1

        save()
    }


    func addNearMiss() {

        missionNearMisses += 1

        save()
    }


    // MARK: Dynamic Missions

    func missionLevel(
        for mission:
            SurvivalMission
    ) -> Int {

        switch mission {

        case .distance:
            return
                distanceMissionLevel

        case .scrap:
            return
                scrapMissionLevel

        case .runs:
            return
                runsMissionLevel

        case .nearMisses:
            return
                nearMissMissionLevel
        }
    }


    func missionGoal(
        for mission:
            SurvivalMission
    ) -> Int {

        mission.goal(
            for:
                missionLevel(
                    for:
                        mission
                )
        )
    }


    func missionReward(
        for mission:
            SurvivalMission
    ) -> Int {

        mission.reward(
            for:
                missionLevel(
                    for:
                        mission
                )
        )
    }


    func missionProgress(
        for mission:
            SurvivalMission
    ) -> Int {

        switch mission {

        case .distance:
            return
                missionDistance

        case .scrap:
            return
                missionScrap

        case .runs:
            return
                missionRuns

        case .nearMisses:
            return
                missionNearMisses
        }
    }


    func isComplete(
        for mission:
            SurvivalMission
    ) -> Bool {

        missionProgress(
            for:
                mission
        )
        >=
        missionGoal(
            for:
                mission
        )
    }


    func claimMission(
        _ mission:
            SurvivalMission
    ) {

        guard
            isComplete(
                for:
                    mission
            )
        else {
            return
        }


        let reward =
            missionReward(
                for:
                    mission
            )


        totalScrap +=
            reward


        switch mission {

        case .distance:

            missionDistance = 0
            distanceMissionLevel += 1

        case .scrap:

            missionScrap = 0
            scrapMissionLevel += 1

        case .runs:

            missionRuns = 0
            runsMissionLevel += 1

        case .nearMisses:

            missionNearMisses = 0
            nearMissMissionLevel += 1
        }


        save()
    }


    // MARK: Upgrades

    func upgradeLevel(
        _ upgrade:
            CharacterUpgrade
    ) -> Int {

        switch upgrade {

        case .armor:
            return armorLevel

        case .magnet:
            return magnetLevel

        case .scavenger:
            return scavengerLevel
        }
    }


    @discardableResult
    func purchaseUpgrade(
        _ upgrade:
            CharacterUpgrade
    ) -> Bool {

        let currentLevel =
            upgradeLevel(
                upgrade
            )


        guard
            currentLevel <
                upgrade.maxLevel
        else {
            return false
        }


        let price =
            upgrade.price(
                for:
                    currentLevel
            )


        guard
            totalScrap >=
                price
        else {
            return false
        }


        totalScrap -=
            price


        switch upgrade {

        case .armor:

            armorLevel =
                min(
                    armorLevel + 1,
                    upgrade.maxLevel
                )

        case .magnet:

            magnetLevel =
                min(
                    magnetLevel + 1,
                    upgrade.maxLevel
                )

        case .scavenger:

            scavengerLevel =
                min(
                    scavengerLevel + 1,
                    upgrade.maxLevel
                )
        }


        save()

        return true
    }
}
