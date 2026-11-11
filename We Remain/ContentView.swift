import SwiftUI
import SpriteKit

enum AppScreen {
    case menu
    case game
    case customize
    case upgrades
    case missions
    case zombies
}


// MARK: - Root

struct ContentView: View {

    @EnvironmentObject
    private var progress: GameProgress

    @State
    private var screen: AppScreen = .menu

    var body: some View {

        ZStack {

            switch screen {

            case .menu:
                MainMenuView(
                    progress: progress,
                    screen: $screen
                )

            case .game:
                GameContainerView(
                    progress: progress,
                    screen: $screen
                )

            case .customize:
                CustomizeView(
                    progress: progress,
                    screen: $screen
                )

            case .upgrades:
                SafehouseView(
                    progress: progress,
                    screen: $screen
                )

            case .missions:
                MissionsView(
                    progress: progress,
                    screen: $screen
                )

            case .zombies:
                ZombieGuideView(
                    screen: $screen
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {

            AudioManager.shared
                .playMenuMusic()
        }
        .onChange(of: screen) { _, newScreen in

            switch newScreen {

            case .game:
                AudioManager.shared
                    .playRunMusic()

            case .menu,
                 .customize,
                 .upgrades,
                 .missions,
                 .zombies:

                AudioManager.shared
                    .playMenuMusic()
            }
        }
    }
}


// MARK: - Main Menu

struct MainMenuView: View {

    @ObservedObject
    var progress: GameProgress

    @Binding
    var screen: AppScreen

    var body: some View {

        ZStack {

            RuinedCityMenuBackground()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.12),
                    Color.black.opacity(0.45),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 14
                ) {

                    Spacer()
                        .frame(height: 50)

                    Text("WE REMAIN")
                        .font(
                            .system(
                                size: 38,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.66,
                                green: 1,
                                blue: 0.36
                            )
                        )

                    Text(
                        "THE CITY IS DEAD. KEEP MOVING."
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.75)
                    )

                    CharacterAssetPreview(
                        appearance: progress.appearance,
                        maximumHeight: 165
                    )
                    .frame(
                        width: 205,
                        height: 195
                    )
                    .background(
                        .black.opacity(0.28)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )

                    VStack(
                        spacing: 7
                    ) {

                        Text("HOW TO SURVIVE")
                            .foregroundColor(.green)

                        Text(
                            "AVOID INFECTED AND HAZARDS"
                        )

                        Text(
                            "JUMP BARRICADES • SLIDE UNDER GATES"
                        )

                        Text(
                            "COLLECT SCRAP AND POWER-UPS"
                        )
                        .foregroundColor(.yellow)

                        Text(
                            "SWIPE ← → TO MOVE"
                        )

                        Text(
                            "SWIPE ↑ TO JUMP • ↓ TO SLIDE"
                        )
                    }
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.86)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .frame(
                        maxWidth: .infinity
                    )
                    .background(
                        .black.opacity(0.70)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                    )

                    HStack(
                        spacing: 10
                    ) {

                        StatCard(
                            label: "SCRAP",
                            value: "\(progress.totalScrap)",
                            symbol: "⚙"
                        )

                        StatCard(
                            label: "BEST",
                            value: "\(progress.bestDistance)m",
                            symbol: "▲"
                        )
                    }

                    Button {

                        screen = .game

                    } label: {

                        Text("RUN")
                            .font(
                                .system(
                                    size: 21,
                                    weight: .black,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.black)
                            .frame(
                                maxWidth: .infinity
                            )
                            .padding(.vertical, 15)
                            .background(
                                Color.green
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 10
                                )
                            )
                    }

                    MenuButton(
                        title: "CUSTOMIZE"
                    ) {
                        screen = .customize
                    }

                    MenuButton(
                        title: "SAFEHOUSE"
                    ) {
                        screen = .upgrades
                    }

                    MenuButton(
                        title: "SURVIVAL MISSIONS"
                    ) {
                        screen = .missions
                    }

                    MenuButton(
                        title: "ZOMBIE GUIDE"
                    ) {
                        screen = .zombies
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding(
                    .horizontal,
                    22
                )
            }
        }
    }
}


// MARK: - Game

struct GameContainerView: View {

    @ObservedObject
    var progress: GameProgress

    @Binding
    var screen: AppScreen

    @State
    private var scene: GameScene

    init(
        progress: GameProgress,
        screen: Binding<AppScreen>
    ) {

        self.progress = progress
        _screen = screen

        let scene =
            GameScene(
                size: CGSize(
                    width: 390,
                    height: 844
                ),
                progress: progress
            )

        scene.scaleMode =
            .resizeFill

        _scene =
            State(
                initialValue: scene
            )
    }

    var body: some View {

        ZStack(
            alignment: .topLeading
        ) {

            SpriteView(
                scene: scene
            )
            .ignoresSafeArea()

            Button {

                scene.stopAndRecordRun()
                screen = .menu

            } label: {

                HStack(
                    spacing: 5
                ) {

                    Image(
                        systemName:
                            "chevron.left"
                    )

                    Text("MENU")
                }
                .font(
                    .system(
                        size: 11,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.white)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(
                    .black.opacity(0.75)
                )
                .clipShape(
                    Capsule()
                )
            }
            .padding(.leading, 16)
            .padding(.top, 58)
        }
    }
}


// MARK: - Customize

struct CustomizeView: View {

    @ObservedObject
    var progress: GameProgress

    @Binding
    var screen: AppScreen

    @State
    private var previewOutfit:
        SurvivorOutfit = .survivor

    @State
    private var purchaseMessage:
        String?

    var body: some View {

        NavigationBackground {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 18
                ) {

                    PageHeader(
                        title: "CUSTOMIZE",
                        screen: $screen
                    )

                    // MARK: Current Scrap

                    HStack {

                        Text(
                            "⚙ \(progress.totalScrap)"
                        )
                        .font(
                            .system(
                                size: 13,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.yellow)

                        Spacer()

                        Text(
                            "AVAILABLE SCRAP"
                        )
                        .font(
                            .system(
                                size: 8,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            .white.opacity(0.45)
                        )
                    }


                    // MARK: Gender

                    SectionTitle(
                        title: "CHOOSE SURVIVOR"
                    )

                    HStack(
                        spacing: 12
                    ) {

                        ForEach(
                            CharacterStyle.allCases
                        ) { style in

                            SelectionButton(
                                title:
                                    style.displayName,
                                selected:
                                    progress.selectedStyle
                                    == style
                            ) {

                                withAnimation(
                                    .easeInOut(
                                        duration: 0.20
                                    )
                                ) {

                                    progress.selectStyle(
                                        style
                                    )
                                }

                                purchaseMessage = nil
                            }
                        }
                    }


                    // MARK: Huge Character Preview

                    ZStack {

                        RoundedRectangle(
                            cornerRadius: 20
                        )
                        .fill(
                            Color.black.opacity(0.38)
                        )

                        RoundedRectangle(
                            cornerRadius: 20
                        )
                        .stroke(
                            Color.white.opacity(0.08),
                            lineWidth: 1
                        )

                        // Subtle glow behind character

                        RadialGradient(
                            colors: [
                                Color.green.opacity(0.13),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )

                        Image(
                            previewOutfit.textureName(
                                for:
                                    progress.selectedStyle
                            )
                        )
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(
                            maxHeight: 285
                        )
                        .padding(
                            .horizontal,
                            20
                        )
                        .padding(
                            .vertical,
                            10
                        )
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .frame(
                        height: 320
                    )


                    // MARK: Outfit Name / Status

                    VStack(
                        spacing: 5
                    ) {

                        Text(
                            previewOutfit
                                .displayName
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.white)


                        if
                            progress.selectedOutfit
                            == previewOutfit {

                            Text("CURRENT OUTFIT")
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(.green)

                        } else if
                            progress.isUnlocked(
                                previewOutfit
                            ) {

                            Text("OWNED")
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .black,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(
                                    .white.opacity(0.55)
                                )

                        } else {

                            Text(
                                "⚙ \(previewOutfit.price)"
                            )
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.yellow)
                        }
                    }


                    // MARK: Horizontal Outfit Scroller

                    SectionTitle(
                        title: "SWIPE TO PREVIEW"
                    )

                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {

                        HStack(
                            spacing: 12
                        ) {

                            ForEach(
                                SurvivorOutfit.allCases
                            ) { outfit in

                                OutfitPreviewCard(
                                    outfit: outfit,
                                    style:
                                        progress.selectedStyle,
                                    selected:
                                        previewOutfit
                                        == outfit,
                                    equipped:
                                        progress.selectedOutfit
                                        == outfit,
                                    unlocked:
                                        progress.isUnlocked(
                                            outfit
                                        )
                                ) {

                                    withAnimation(
                                        .easeInOut(
                                            duration: 0.18
                                        )
                                    ) {

                                        previewOutfit =
                                            outfit
                                    }

                                    purchaseMessage =
                                        nil
                                }
                            }
                        }
                        .padding(
                            .horizontal,
                            2
                        )
                        .padding(
                            .vertical,
                            4
                        )
                    }


                    // MARK: Buy / Equip

                    if let purchaseMessage {

                        Text(
                            purchaseMessage
                        )
                        .font(
                            .system(
                                size: 10,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            purchaseMessage
                            == "NOT ENOUGH SCRAP"
                            ? .red
                            : .green
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                    }


                    OutfitActionButton(
                        outfit: previewOutfit,
                        progress: progress
                    ) { result in

                        switch result {

                        case .equipped:

                            purchaseMessage =
                                "OUTFIT EQUIPPED"

                        case .purchased:

                            purchaseMessage =
                                "OUTFIT UNLOCKED"

                        case .notEnoughScrap:

                            purchaseMessage =
                                "NOT ENOUGH SCRAP"
                        }
                    }


                    Text(
                        "SWIPE THROUGH OUTFITS TO PREVIEW THEM BEFORE YOU BUY."
                    )
                    .font(
                        .system(
                            size: 8,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.35)
                    )
                    .multilineTextAlignment(
                        .center
                    )


                    Spacer()
                        .frame(
                            height: 40
                        )
                }
                .padding(
                    .horizontal,
                    20
                )
            }
        }
        .onAppear {

            previewOutfit =
                progress.selectedOutfit
        }
    }
}


// MARK: - Outfit Preview Card

struct OutfitPreviewCard: View {

    let outfit:
        SurvivorOutfit

    let style:
        CharacterStyle

    let selected:
        Bool

    let equipped:
        Bool

    let unlocked:
        Bool

    let action:
        () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            VStack(
                spacing: 6
            ) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .fill(
                        selected
                        ? Color.green.opacity(0.14)
                        : Color.black.opacity(0.58)
                    )

                    Image(
                        outfit.textureName(
                            for: style
                        )
                    )
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(
                        height: 105
                    )
                    .padding(
                        .horizontal,
                        7
                    )

                    if !unlocked {

                        VStack {

                            HStack {

                                Spacer()

                                Image(
                                    systemName:
                                        "lock.fill"
                                )
                                .font(
                                    .system(
                                        size: 11,
                                        weight: .black
                                    )
                                )
                                .foregroundColor(.yellow)
                                .padding(8)
                            }

                            Spacer()
                        }
                    }
                }
                .frame(
                    width: 105,
                    height: 125
                )
                .overlay {

                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .stroke(
                        selected
                        ? Color.green
                        : Color.white.opacity(0.08),
                        lineWidth:
                            selected
                            ? 2
                            : 1
                    )
                }


                Text(
                    outfit.displayName
                )
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    selected
                    ? .green
                    : .white
                )
                .lineLimit(1)


                if equipped {

                    Text("EQUIPPED")
                        .font(
                            .system(
                                size: 7,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.green)

                } else if unlocked {

                    Text("OWNED")
                        .font(
                            .system(
                                size: 7,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            .white.opacity(0.40)
                        )

                } else {

                    Text(
                        "⚙ \(outfit.price)"
                    )
                    .font(
                        .system(
                            size: 8,
                            weight: .black,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.yellow)
                }
            }
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Outfit Action Result

enum OutfitActionResult {

    case equipped
    case purchased
    case notEnoughScrap
}


// MARK: - Outfit Action Button

struct OutfitActionButton: View {

    let outfit:
        SurvivorOutfit

    @ObservedObject
    var progress:
        GameProgress

    let onResult:
        (OutfitActionResult) -> Void

    var body: some View {

        let unlocked =
            progress.isUnlocked(
                outfit
            )

        let equipped =
            progress.selectedOutfit
            == outfit


        Button {

            if equipped {

                return

            } else if unlocked {

                progress.equip(
                    outfit
                )

                onResult(
                    .equipped
                )

            } else if
                progress.totalScrap
                >= outfit.price {

                if
                    progress.purchase(
                        outfit
                    ) {

                    onResult(
                        .purchased
                    )
                }

            } else {

                onResult(
                    .notEnoughScrap
                )
            }

        } label: {

            HStack(
                spacing: 8
            ) {

                if equipped {

                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )
                }


                Text(
                    equipped
                    ? "EQUIPPED"
                    : unlocked
                    ? "EQUIP"
                    : "BUY  ⚙ \(outfit.price)"
                )
            }
            .font(
                .system(
                    size: 14,
                    weight: .black,
                    design: .monospaced
                )
            )
            .foregroundColor(
                equipped
                ? .green
                : .black
            )
            .frame(
                maxWidth: .infinity
            )
            .padding(
                .vertical,
                14
            )
            .background(
                equipped
                ? Color.black.opacity(0.70)
                : Color.green
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10
                )
            )
            .overlay {

                if equipped {

                    RoundedRectangle(
                        cornerRadius: 10
                    )
                    .stroke(
                        Color.green.opacity(0.45),
                        lineWidth: 1
                    )
                }
            }
        }
        .disabled(
            equipped
        )
    }
}


// MARK: - Generic Character Preview

struct CharacterAssetPreview: View {

    let appearance:
        CharacterAppearance

    let maximumHeight:
        CGFloat

    var body: some View {

        Image(
            appearance.textureName
        )
        .resizable()
        .interpolation(.none)
        .scaledToFit()
        .frame(
            maxHeight:
                maximumHeight
        )
    }
}


// MARK: - Safehouse

struct SafehouseView: View {

    @ObservedObject
    var progress: GameProgress

    @Binding
    var screen: AppScreen

    @StateObject
    private var inventory =
        SafehouseInventory.shared

    @State
    private var purchaseMessage:
        String?

    var body: some View {

        NavigationBackground {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 18
                ) {

                    PageHeader(
                        title: "SAFEHOUSE",
                        screen: $screen
                    )

                    VStack(
                        spacing: 3
                    ) {

                        Text(
                            "⚙ \(progress.totalScrap)"
                        )
                        .font(
                            .system(
                                size: 21,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(.yellow)

                        Text(
                            "AVAILABLE SCRAP"
                        )
                        .font(
                            .system(
                                size: 9,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            .white.opacity(0.55)
                        )
                    }

                    Text(
                        "BUY SUPPLIES HERE. USE THEM WHEN YOU NEED THEM DURING A RUN."
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.62)
                    )
                    .multilineTextAlignment(.center)

                    if let purchaseMessage {

                        Text(
                            purchaseMessage
                        )
                        .font(
                            .system(
                                size: 10,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            purchaseMessage
                            == "NOT ENOUGH SCRAP"
                            ? .red
                            : .green
                        )
                    }

                    SectionTitle(
                        title: "RUN SUPPLIES"
                    )

                    ForEach(
                        SafehouseItem.allCases
                    ) { item in

                        SafehouseStoreCard(
                            item: item,
                            owned:
                                inventory.count(
                                    for: item
                                )
                        ) {

                            if
                                progress.buySafehouseItem(
                                    item
                                ) {

                                purchaseMessage =
                                    "\(item.displayName) ADDED"

                            } else {

                                purchaseMessage =
                                    "NOT ENOUGH SCRAP"
                            }
                        }
                    }

                    SectionTitle(
                        title: "PERMANENT UPGRADES"
                    )

                    ForEach(
                        CharacterUpgrade.allCases
                    ) { upgrade in

                        UpgradeCard(
                            upgrade: upgrade,
                            progress: progress
                        )
                    }

                    Spacer()
                        .frame(
                            height: 40
                        )
                }
                .padding(
                    .horizontal,
                    20
                )
            }
        }
    }
}


// MARK: - Safehouse Store Card

struct SafehouseStoreCard: View {

    let item:
        SafehouseItem

    let owned:
        Int

    let purchase:
        () -> Void

    var body: some View {

        HStack(
            spacing: 14
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    .black.opacity(0.55)
                )

                Image(
                    item.textureName
                )
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(9)
            }
            .frame(
                width: 70,
                height: 70
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    item.displayName
                )
                .font(
                    .system(
                        size: 14,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.white)

                Text(
                    item.description
                )
                .font(
                    .system(
                        size: 8,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .white.opacity(0.55)
                )

                Text(
                    "OWNED: \(owned)"
                )
                .font(
                    .system(
                        size: 9,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.green)
            }

            Spacer()

            Button {

                purchase()

            } label: {

                VStack(
                    spacing: 2
                ) {

                    Text("BUY")

                    Text(
                        "⚙ \(item.price)"
                    )
                }
                .font(
                    .system(
                        size: 9,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    Color.green
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 8
                    )
                )
            }
        }
        .padding(14)
        .background(
            .black.opacity(0.74)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }
}


// MARK: - Upgrade Card

struct UpgradeCard: View {

    let upgrade:
        CharacterUpgrade

    @ObservedObject
    var progress:
        GameProgress

    private var level: Int {

        progress.upgradeLevel(
            upgrade
        )
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Text(title)
                    .font(
                        .system(
                            size: 16,
                            weight: .black,
                            design: .monospaced
                        )
                    )

                Spacer()

                Text(
                    "LV \(level)/\(upgrade.maxLevel)"
                )
                .foregroundColor(.green)
            }

            if
                level
                < upgrade.maxLevel {

                Button {

                    progress.purchaseUpgrade(
                        upgrade
                    )

                } label: {

                    Text(
                        "UPGRADE  ⚙ \(upgrade.price(for: level))"
                    )
                    .font(
                        .system(
                            size: 11,
                            weight: .black,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.black)
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(.vertical, 11)
                    .background(
                        Color.green
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                    )
                }

            } else {

                Text("MAX LEVEL")
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            .black.opacity(0.74)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    private var title:
        String {

        switch upgrade {

        case .armor:
            return "ARMOR"

        case .magnet:
            return "MAGNET"

        case .scavenger:
            return "SCAVENGER"
        }
    }
}


// MARK: - Missions

struct MissionsView: View {

    @ObservedObject
    var progress:
        GameProgress

    @Binding
    var screen:
        AppScreen

    var body: some View {

        NavigationBackground {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 18
                ) {

                    PageHeader(
                        title:
                            "SURVIVAL MISSIONS",
                        screen: $screen
                    )

                    Text(
                        "COMPLETE A MISSION TO UNLOCK A HARDER ONE"
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(
                        .white.opacity(0.55)
                    )
                    .multilineTextAlignment(.center)

                    ForEach(
                        SurvivalMission.allCases
                    ) { mission in

                        MissionCard(
                            mission: mission,
                            progress: progress
                        )
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding(
                    .horizontal,
                    20
                )
            }
        }
    }
}


struct MissionCard: View {

    let mission:
        SurvivalMission

    @ObservedObject
    var progress:
        GameProgress

    private var level:
        Int {

        progress.missionLevel(
            for: mission
        )
    }

    private var goal:
        Int {

        progress.missionGoal(
            for: mission
        )
    }

    private var reward:
        Int {

        progress.missionReward(
            for: mission
        )
    }

    private var current:
        Int {

        progress.missionProgress(
            for: mission
        )
    }

    private var complete:
        Bool {

        current >= goal
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 11
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(
                        mission.displayName
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .black,
                            design: .monospaced
                        )
                    )

                    Text(
                        "MISSION \(level + 1)"
                    )
                    .font(
                        .system(
                            size: 9,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.green)
                }

                Spacer()

                Text(
                    "⚙ \(reward)"
                )
                .foregroundColor(.yellow)
            }

            Text(
                missionDescription
            )
            .font(
                .system(
                    size: 10,
                    weight: .medium,
                    design: .monospaced
                )
            )
            .foregroundColor(
                .white.opacity(0.65)
            )

            ProgressView(
                value:
                    min(
                        Double(current)
                        / Double(goal),
                        1
                    )
            )
            .tint(.green)

            HStack {

                Text(
                    "\(min(current, goal))/\(goal)"
                )

                Spacer()

                if complete {

                    Button {

                        progress.claimMission(
                            mission
                        )

                    } label: {

                        Text("CLAIM")
                            .foregroundColor(.black)
                            .padding(
                                .horizontal,
                                16
                            )
                            .padding(
                                .vertical,
                                7
                            )
                            .background(
                                Color.green
                            )
                            .clipShape(
                                Capsule()
                            )
                    }
                }
            }
            .font(
                .system(
                    size: 10,
                    weight: .black,
                    design: .monospaced
                )
            )
        }
        .padding(16)
        .background(
            .black.opacity(0.73)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }

    private var missionDescription:
        String {

        switch mission {

        case .distance:
            return "RUN \(goal) METERS"

        case .scrap:
            return "COLLECT \(goal) SCRAP"

        case .runs:
            return "COMPLETE \(goal) RUNS"

        case .nearMisses:
            return "EARN \(goal) NEAR MISSES"
        }
    }
}


// MARK: - Zombie Guide

struct ZombieGuideView: View {

    @Binding
    var screen: AppScreen


    var body: some View {

        NavigationBackground {

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 18
                ) {

                    PageHeader(
                        title: "ZOMBIE GUIDE",
                        screen: $screen
                    )


                    // MARK: Guide Legend

                    VStack(
                        spacing: 6
                    ) {

                        Text(
                            "INFECTED FIELD GUIDE"
                        )
                        .font(
                            .system(
                                size: 12,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            .green
                        )


                        Text(
                            "THREAT RANK CONSIDERS SPEED, SIZE, AND HOW DIFFICULT THE INFECTED IS TO AVOID."
                        )
                        .font(
                            .system(
                                size: 8,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            .white.opacity(0.48)
                        )
                        .multilineTextAlignment(
                            .center
                        )
                    }
                    .padding(
                        12
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                    .background(
                        .black.opacity(0.55)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                    )


                    // ZombieType.allCases now includes:
                    // Walker
                    // Runner
                    // Crawler
                    // Infected Cat
                    // Infected Dog
                    // Brute

                    ForEach(
                        ZombieType.allCases
                    ) { zombie in

                        ZombieGuideCard(
                            zombie: zombie
                        )
                    }


                    BossGuideCard()


                    Spacer()
                        .frame(
                            height: 40
                        )
                }
                .padding(
                    .horizontal,
                    20
                )
            }
        }
    }
}


// MARK: - Zombie Guide Card

struct ZombieGuideCard: View {

    let zombie:
        ZombieType


    private var threatColor:
        Color {

        switch zombie.threatRank {

        case "LOW":
            return .green

        case "HIGH":
            return .orange

        case "SEVERE":
            return .red

        default:
            return .white
        }
    }


    var body: some View {

        HStack(
            spacing: 16
        ) {

            // MARK: Enemy Art

            ZStack {

                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    Color.black.opacity(0.45)
                )


                RadialGradient(
                    colors: [
                        threatColor.opacity(0.12),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 3,
                    endRadius: 65
                )


                Image(
                    zombie.textureName
                )
                .resizable()
                .interpolation(
                    .none
                )
                .scaledToFit()
                .padding(
                    7
                )
            }
            .frame(
                width: 105,
                height: 120
            )


            // MARK: Enemy Information

            VStack(
                alignment: .leading,
                spacing: 7
            ) {

                Text(
                    zombie
                        .displayName
                        .uppercased()
                )
                .font(
                    .system(
                        size: 14,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .green
                )


                // MARK: Rank

                HStack(
                    spacing: 6
                ) {

                    Text(
                        "THREAT: \(zombie.threatRank)"
                    )
                    .foregroundColor(
                        threatColor
                    )


                    Text("•")
                        .foregroundColor(
                            .white.opacity(0.30)
                        )


                    Text(
                        "SPEED: \(zombie.speedLabel)"
                    )
                    .foregroundColor(
                        zombie.speedLabel == "FAST"
                        ? .orange
                        : .white.opacity(0.62)
                    )
                }
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )


                Text(
                    zombie.description
                )
                .font(
                    .system(
                        size: 9,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .white.opacity(0.68)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )


                Text(
                    zombie
                        .unlockText
                        .uppercased()
                )
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .yellow
                )
            }


            Spacer(
                minLength: 0
            )
        }
        .padding(
            14
        )
        .background(
            .black.opacity(0.72)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: 12
            )
            .stroke(
                threatColor.opacity(0.16),
                lineWidth: 1
            )
        }
    }
}


// MARK: - Boss Guide Card

struct BossGuideCard: View {

    var body: some View {

        HStack(
            spacing: 16
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: 12
                )
                .fill(
                    Color.black.opacity(0.45)
                )


                RadialGradient(
                    colors: [
                        Color.red.opacity(0.18),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 4,
                    endRadius: 70
                )


                Image(
                    "Zombie_Boss"
                )
                .resizable()
                .interpolation(
                    .none
                )
                .scaledToFit()
                .padding(
                    3
                )
            }
            .frame(
                width: 105,
                height: 125
            )


            VStack(
                alignment: .leading,
                spacing: 7
            ) {

                Text(
                    "THE MUTANT"
                )
                .font(
                    .system(
                        size: 14,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .red
                )


                HStack(
                    spacing: 6
                ) {

                    Text(
                        "THREAT: EXTREME"
                    )
                    .foregroundColor(
                        .red
                    )


                    Text("•")
                        .foregroundColor(
                            .white.opacity(0.30)
                        )


                    Text(
                        "CHASE"
                    )
                    .foregroundColor(
                        .orange
                    )
                }
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )


                Text(
                    "A massive mutated infected that hunts the survivor during chase events. One mistake alerts it, and another hit during a danger chase can end the run."
                )
                .font(
                    .system(
                        size: 9,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .white.opacity(0.68)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )


                Text(
                    "SURVIVE THE CHASE"
                )
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .yellow
                )
            }


            Spacer(
                minLength: 0
            )
        }
        .padding(
            14
        )
        .background(
            .black.opacity(0.72)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: 12
            )
            .stroke(
                Color.red.opacity(0.20),
                lineWidth: 1
            )
        }
    }
}

// MARK: - Navigation Background

struct NavigationBackground<
    Content: View
>: View {

    let content:
        Content

    init(
        @ViewBuilder
        content:
            () -> Content
    ) {

        self.content =
            content()
    }

    var body: some View {

        ZStack {

            RuinedCityMenuBackground()
                .ignoresSafeArea()

            Color.black
                .opacity(0.70)
                .ignoresSafeArea()

            content
        }
    }
}


// MARK: - Menu Background

struct RuinedCityMenuBackground: View {

    private var scene:
        SKScene {

        let scene =
            RuinedCityMenuScene(
                size:
                    CGSize(
                        width: 390,
                        height: 844
                    )
            )

        scene.scaleMode =
            .resizeFill

        return scene
    }

    var body: some View {

        SpriteView(
            scene: scene
        )
        .allowsHitTesting(false)
    }
}


// MARK: - Ruined City Scene

final class RuinedCityMenuScene:
    SKScene {

    override init(
        size: CGSize
    ) {

        super.init(
            size: size
        )

        backgroundColor =
            SKColor(
                red: 0.04,
                green: 0.052,
                blue: 0.042,
                alpha: 1
            )

        createBackground()
    }

    required init?(
        coder: NSCoder
    ) {

        fatalError()
    }

    private func createBackground() {

        let centerX =
            size.width / 2


        // Road

        let street =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.14,
                        green: 0.15,
                        blue: 0.125,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width:
                            size.width * 0.62,
                        height:
                            size.height
                    )
            )

        street.position =
            CGPoint(
                x: centerX,
                y: size.height / 2
            )

        addChild(street)


        // Center lane

        let centerLane =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.10,
                        green: 0.115,
                        blue: 0.095,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: 82,
                        height: size.height
                    )
            )

        centerLane.position =
            CGPoint(
                x: centerX,
                y: size.height / 2
            )

        centerLane.zPosition =
            1

        addChild(centerLane)


        // Buildings

        let buildingWidth:
            CGFloat = 78

        for x in [
            buildingWidth / 2,
            size.width - buildingWidth / 2
        ] {

            let building =
                SKSpriteNode(
                    color:
                        SKColor(
                            red: 0.065,
                            green: 0.073,
                            blue: 0.061,
                            alpha: 1
                        ),
                    size:
                        CGSize(
                            width:
                                buildingWidth,
                            height:
                                size.height
                        )
                )

            building.position =
                CGPoint(
                    x: x,
                    y: size.height / 2
                )

            building.zPosition =
                3

            addChild(building)


            for row in 0..<10 {

                let window =
                    SKSpriteNode(
                        color:
                            SKColor(
                                red: 0.01,
                                green: 0.018,
                                blue: 0.012,
                                alpha: 1
                            ),
                        size:
                            CGSize(
                                width: 23,
                                height: 31
                            )
                    )

                window.position =
                    CGPoint(
                        x:
                            x
                            + CGFloat.random(
                                in: -14...14
                            ),
                        y:
                            CGFloat(row)
                            * 82
                            + 42
                    )

                window.zPosition =
                    5

                addChild(window)
            }
        }


        // Road dashes

        for index in 0..<12 {

            let dash =
                SKSpriteNode(
                    color:
                        SKColor(
                            red: 0.55,
                            green: 0.55,
                            blue: 0.44,
                            alpha: 0.26
                        ),
                    size:
                        CGSize(
                            width: 4,
                            height:
                                CGFloat.random(
                                    in: 18...34
                                )
                        )
                )

            dash.position =
                CGPoint(
                    x: centerX,
                    y:
                        CGFloat(index)
                        * 78
                        + 22
                )

            dash.zPosition =
                3

            addChild(dash)
        }


        // Road cracks

        for _ in 0..<34 {

            let crack =
                SKSpriteNode(
                    color:
                        .black
                        .withAlphaComponent(
                            0.34
                        ),
                    size:
                        CGSize(
                            width:
                                CGFloat.random(
                                    in: 7...25
                                ),
                            height: 3
                        )
                )

            crack.position =
                CGPoint(
                    x:
                        CGFloat.random(
                            in:
                                (centerX - 112)...(centerX + 112)
                        ),
                    y:
                        CGFloat.random(
                            in: 10...size.height
                        )
                )

            crack.zRotation =
                CGFloat.random(
                    in: -0.7...0.7
                )

            crack.zPosition =
                4

            addChild(crack)
        }


        // Plants

        for side in [
            CGFloat(77),
            size.width - 77
        ] {

            for index in 0..<15 {

                let plant =
                    SKNode()

                for _ in 0..<5 {

                    let leaf =
                        SKSpriteNode(
                            color:
                                [
                                    SKColor(
                                        red: 0.10,
                                        green: 0.22,
                                        blue: 0.06,
                                        alpha: 1
                                    ),
                                    SKColor(
                                        red: 0.14,
                                        green: 0.29,
                                        blue: 0.07,
                                        alpha: 1
                                    )
                                ]
                                .randomElement()
                                ?? .systemGreen,
                            size:
                                CGSize(
                                    width:
                                        CGFloat.random(
                                            in: 8...17
                                        ),
                                    height:
                                        CGFloat.random(
                                            in: 6...12
                                        )
                                )
                        )

                    leaf.position =
                        CGPoint(
                            x:
                                CGFloat.random(
                                    in: -11...11
                                ),
                            y:
                                CGFloat.random(
                                    in: -8...10
                                )
                        )

                    plant.addChild(
                        leaf
                    )
                }

                plant.position =
                    CGPoint(
                        x:
                            side
                            + CGFloat.random(
                                in: -11...11
                            ),
                        y:
                            CGFloat(index)
                            * 58
                            + CGFloat.random(
                                in: 5...28
                            )
                    )

                plant.zPosition =
                    7

                addChild(plant)
            }
        }


        // Fog

        for index in 0..<8 {

            let fog =
                SKShapeNode(
                    ellipseOf:
                        CGSize(
                            width:
                                CGFloat.random(
                                    in: 110...220
                                ),
                            height:
                                CGFloat.random(
                                    in: 25...65
                                )
                        )
                )

            fog.fillColor =
                SKColor(
                    red: 0.20,
                    green: 0.34,
                    blue: 0.10,
                    alpha: 0.07
                )

            fog.strokeColor =
                .clear

            fog.position =
                CGPoint(
                    x:
                        centerX
                        + CGFloat.random(
                            in: -35...35
                        ),
                    y:
                        CGFloat(index)
                        * 105
                        + 40
                )

            fog.zPosition =
                1

            addChild(fog)
        }
    }
}


// MARK: - Shared UI

struct PageHeader: View {

    let title:
        String

    @Binding
    var screen:
        AppScreen

    var body: some View {

        HStack {

            Button {

                screen = .menu

            } label: {

                Image(
                    systemName:
                        "chevron.left"
                )
                .foregroundColor(.white)
            }

            Spacer()

            Text(title)
                .font(
                    .system(
                        size: 20,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.green)

            Spacer()

            Image(
                systemName:
                    "chevron.left"
            )
            .opacity(0)
        }
        .padding(.top, 58)
    }
}


struct MenuButton: View {

    let title:
        String

    let action:
        () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            Text(title)
                .font(
                    .system(
                        size: 13,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.white)
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 15)
                .background(
                    .black.opacity(0.80)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 9
                    )
                )
        }
    }
}


struct StatCard: View {

    let label:
        String

    let value:
        String

    let symbol:
        String

    var body: some View {

        VStack(
            spacing: 4
        ) {

            Text(
                "\(symbol) \(value)"
            )
            .font(
                .system(
                    size: 15,
                    weight: .black,
                    design: .monospaced
                )
            )
            .foregroundColor(.yellow)

            Text(label)
                .font(
                    .system(
                        size: 8,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    .white.opacity(0.55)
                )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 11)
        .background(
            .black.opacity(0.7)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 9
            )
        )
    }
}


struct SelectionButton: View {

    let title:
        String

    let selected:
        Bool

    let action:
        () -> Void

    var body: some View {

        Button(
            action: action
        ) {

            Text(title)
                .font(
                    .system(
                        size: 11,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    selected
                    ? .black
                    : .white
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 11)
                .background(
                    selected
                    ? Color.green
                    : .black.opacity(0.68)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 8
                    )
                )
        }
    }
}


struct SectionTitle: View {

    let title:
        String

    var body: some View {

        HStack {

            Text(title)
                .font(
                    .system(
                        size: 12,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .foregroundColor(.green)

            Spacer()
        }
    }
}


#Preview {

    ContentView()
        .environmentObject(
            GameProgress.shared
        )
}
