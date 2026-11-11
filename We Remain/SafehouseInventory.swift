import Foundation

// MARK: - Safehouse Items

enum SafehouseItem:
    String,
    CaseIterable,
    Identifiable {

    case shield
    case magnet
    case doubleScrap
    case medkit

    var id: String {
        rawValue
    }

    var displayName: String {

        switch self {

        case .shield:
            return "SHIELD"

        case .magnet:
            return "MAGNET"

        case .doubleScrap:
            return "DOUBLE SCRAP"

        case .medkit:
            return "MEDKIT"
        }
    }

    var description: String {

        switch self {

        case .shield:
            return "BLOCK ONE COLLISION"

        case .magnet:
            return "PULL NEARBY SCRAP TOWARD YOU"

        case .doubleScrap:
            return "DOUBLE SCRAP FOR A LIMITED TIME"

        case .medkit:
            return "RESTORE ONE HEALTH"
        }
    }

    var price: Int {

        switch self {

        case .shield:
            return 100

        case .magnet:
            return 125

        case .doubleScrap:
            return 150

        case .medkit:
            return 100
        }
    }

    var textureName: String {

        switch self {

        case .shield:
            return "PowerUp_Shield"

        case .magnet:
            return "PowerUp_Magnet"

        case .doubleScrap:
            return "PowerUp_DoubleScrap"

        case .medkit:
            return "Pickup_Medkit"
        }
    }

    var storageKey: String {

        "weRemain.safehouse.\(rawValue)"
    }
}


// MARK: - Inventory

final class SafehouseInventory:
    ObservableObject {

    static let shared =
        SafehouseInventory()

    @Published
    private(set)
    var shieldCount: Int

    @Published
    private(set)
    var magnetCount: Int

    @Published
    private(set)
    var doubleScrapCount: Int

    @Published
    private(set)
    var medkitCount: Int

    private let defaults =
        UserDefaults.standard

    private init() {

        shieldCount =
            defaults.integer(
                forKey:
                    SafehouseItem
                        .shield
                        .storageKey
            )

        magnetCount =
            defaults.integer(
                forKey:
                    SafehouseItem
                        .magnet
                        .storageKey
            )

        doubleScrapCount =
            defaults.integer(
                forKey:
                    SafehouseItem
                        .doubleScrap
                        .storageKey
            )

        medkitCount =
            defaults.integer(
                forKey:
                    SafehouseItem
                        .medkit
                        .storageKey
            )
    }


    // MARK: - Count

    func count(
        for item: SafehouseItem
    ) -> Int {

        switch item {

        case .shield:
            return shieldCount

        case .magnet:
            return magnetCount

        case .doubleScrap:
            return doubleScrapCount

        case .medkit:
            return medkitCount
        }
    }


    // MARK: - Add

    func add(
        _ item: SafehouseItem,
        amount: Int = 1
    ) {

        guard amount > 0 else {
            return
        }

        switch item {

        case .shield:

            shieldCount += amount

        case .magnet:

            magnetCount += amount

        case .doubleScrap:

            doubleScrapCount += amount

        case .medkit:

            medkitCount += amount
        }

        save()
    }


    // MARK: - Consume

    @discardableResult
    func consume(
        _ item: SafehouseItem
    ) -> Bool {

        guard
            count(for: item) > 0
        else {
            return false
        }

        switch item {

        case .shield:

            shieldCount -= 1

        case .magnet:

            magnetCount -= 1

        case .doubleScrap:

            doubleScrapCount -= 1

        case .medkit:

            medkitCount -= 1
        }

        save()

        return true
    }


    // MARK: - Save

    private func save() {

        defaults.set(
            shieldCount,
            forKey:
                SafehouseItem
                    .shield
                    .storageKey
        )

        defaults.set(
            magnetCount,
            forKey:
                SafehouseItem
                    .magnet
                    .storageKey
        )

        defaults.set(
            doubleScrapCount,
            forKey:
                SafehouseItem
                    .doubleScrap
                    .storageKey
        )

        defaults.set(
            medkitCount,
            forKey:
                SafehouseItem
                    .medkit
                    .storageKey
        )
    }
}


// MARK: - Scrap Spending

extension GameProgress {

    @discardableResult
    func buySafehouseItem(
        _ item: SafehouseItem
    ) -> Bool {

        guard
            totalScrap >= item.price
        else {
            return false
        }

        addScrap(
            -item.price
        )

        SafehouseInventory
            .shared
            .add(item)

        return true
    }
}
