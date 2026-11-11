import SpriteKit
import UIKit

final class GameScene: SKScene {

    private let progress: GameProgress
    private let safehouse = SafehouseInventory.shared

    private var player: SKNode!

    private let playerBaseY: CGFloat = 150
    private var currentLane = 1

    private var lanePositions: [CGFloat] {
        let center = size.width / 2
        let spacing: CGFloat = 104

        return [
            center - spacing,
            center,
            center + spacing
        ]
    }

    private var isJumping = false
    private var isSliding = false
    private var isInvulnerable = false

    private var gameOver = false
    private var hasRecordedRun = false

    private var health = 3

    private var maxHealth: Int {
        min(
            6,
            3 + progress.armorLevel
        )
    }

    private var preciseDistance: Double = 0
    private var distance = 0
    private var runScrap = 0

    private var worldSpeed: CGFloat = 285

    private var previousUpdateTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0

    private var threatTimer: TimeInterval = 0
    private var nextThreatDelay: TimeInterval = 0.85

    private var pickupTimer: TimeInterval = 0
    private var nextPickupDelay: TimeInterval = 1.8

    private var lastNearMissTime: TimeInterval = -100

    private let nearMissChance: Double = 0.28
    private let nearMissCooldown: TimeInterval = 5

    private var shieldTime: TimeInterval = 0
    private var magnetTime: TimeInterval = 0
    private var doubleScrapTime: TimeInterval = 0


    // MARK: - Weather

    // Rain now begins later and builds much more slowly.
    private let rainStartDistance = 600
    private let heavyRainDistance = 950

    private var rainStarted = false

    private var rainEmitter: SKEmitterNode?
    private var stormHaze: SKSpriteNode?

    private var wetGlassLayer = SKNode()
    private var nextWetStreakTime: TimeInterval = 0


    // MARK: - Boss

    private var boss: SKNode?

    private var bossActive = false
    private var bossIsIntroChase = false
    private var bossIsRetreating = false

    private var bossTimeRemaining: TimeInterval = 0

    private let introBossDuration: TimeInterval = 6
    private let dangerBossDuration: TimeInterval = 12

    private let bossChaseY: CGFloat = -28


    // MARK: - HUD

    private var distanceLabel: SKLabelNode!
    private var scrapLabel: SKLabelNode!
    private var healthLabel: SKLabelNode!

    private var touchStart: CGPoint?


    // MARK: - Threat Types

    private enum ThreatKind {
        case barricade
        case overhead
        case toxic
        case burningCar
        case wreckedCar

        case walker
        case runner
        case crawler
        case cat
        case dog
        case brute
    }


    private enum StreetSide {
        case left
        case right
    }


    // MARK: - Init

    init(
        size: CGSize,
        progress: GameProgress
    ) {

        self.progress = progress

        super.init(
            size: size
        )

        scaleMode = .resizeFill
    }


    required init?(
        coder: NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    // MARK: - Scene Setup

    override func didMove(
        to view: SKView
    ) {

        AudioManager.shared
            .playRunMusic()

        backgroundColor =
            SKColor(
                red: 0.045,
                green: 0.055,
                blue: 0.045,
                alpha: 1
            )

        setupRoad()
        setupPlayer()
        setupHUD()
        setupSafehouseHUD()
        setupWeatherSystem()

        run(
            .sequence([
                .wait(
                    forDuration: 0.45
                ),

                .run {
                    [weak self] in

                    self?
                        .startIntroBossChase()
                }
            ]),
            withKey: "openingBossSequence"
        )
    }


    // MARK: - Weather Setup

    private func setupWeatherSystem() {

        rainStarted = false

        rainEmitter?
            .removeFromParent()

        rainEmitter = nil

        stormHaze?
            .removeFromParent()

        stormHaze = nil

        wetGlassLayer
            .removeAllChildren()

        wetGlassLayer
            .removeFromParent()

        wetGlassLayer = SKNode()

        wetGlassLayer.name =
            "wetGlassLayer"

        wetGlassLayer.zPosition =
            165

        addChild(
            wetGlassLayer
        )
    }


    // MARK: - Begin Rain

    private func beginRain() {

        guard
            !rainStarted
        else {
            return
        }

        rainStarted = true

        showAnnouncement(
            title: "RAIN MOVING IN",
            subtitle: "WATCH THE ROAD",
            color: .systemTeal
        )

        let emitter =
            SKEmitterNode()

        emitter.name =
            "rainEmitter"

        emitter.position =
            CGPoint(
                x: size.width / 2,
                y: size.height + 40
            )

        emitter.particlePositionRange =
            CGVector(
                dx: size.width + 100,
                dy: 15
            )

        // Previously much heavier.
        // Starts with only 45 particles per second.
        emitter.particleBirthRate = 45

        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.20

        emitter.particleSpeed = 660
        emitter.particleSpeedRange = 90

        emitter.emissionAngle =
            -.pi / 2 - 0.10

        emitter.emissionAngleRange = 0.05

        // Much more transparent than before.
        emitter.particleAlpha = 0.22
        emitter.particleAlphaRange = 0.08

        emitter.particleScale = 0.80
        emitter.particleScaleRange = 0.20

        emitter.particleColor =
            UIColor(
                red: 0.73,
                green: 0.84,
                blue: 0.90,
                alpha: 1
            )

        emitter.particleTexture =
            makeRainTexture()

        emitter.zPosition = 155

        addChild(
            emitter
        )

        rainEmitter = emitter


        // Very light atmospheric overlay.
        let haze =
            SKSpriteNode(
                color:
                    UIColor(
                        red: 0.42,
                        green: 0.49,
                        blue: 0.51,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: size.width,
                        height: size.height
                    )
            )

        haze.name =
            "stormHaze"

        haze.position =
            CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

        haze.alpha = 0

        haze.blendMode = .alpha

        haze.zPosition = 150

        addChild(
            haze
        )

        stormHaze = haze
    }


    // MARK: - Rain Texture

    private func makeRainTexture() -> SKTexture {

        let imageSize =
            CGSize(
                width: 2,
                height: 18
            )

        UIGraphicsBeginImageContextWithOptions(
            imageSize,
            false,
            1
        )

        guard
            let context =
                UIGraphicsGetCurrentContext()
        else {

            return SKTexture()
        }

        context.setStrokeColor(
            UIColor.white.cgColor
        )

        context.setLineWidth(
            1
        )

        context.move(
            to:
                CGPoint(
                    x: 1.5,
                    y: 0
                )
        )

        context.addLine(
            to:
                CGPoint(
                    x: 0.5,
                    y: 18
                )
        )

        context.strokePath()

        let image =
            UIGraphicsGetImageFromCurrentImageContext()
            ?? UIImage()

        UIGraphicsEndImageContext()

        let texture =
            SKTexture(
                image: image
            )

        texture.filteringMode = .linear

        return texture
    }


    // MARK: - Update Weather

    private func updateWeather(
        _ delta: TimeInterval
    ) {

        guard
            distance >= rainStartDistance
        else {
            return
        }

        if !rainStarted {
            beginRain()
        }

        /*
         Rain builds gradually:

         600m = minimum rain
         950m = maximum rain intensity

         Maximum intensity is still intentionally mild.
         */

        let rainProgress =
            min(
                max(
                    CGFloat(
                        distance
                        - rainStartDistance
                    )
                    /
                    CGFloat(
                        heavyRainDistance
                        - rainStartDistance
                    ),
                    0
                ),
                1
            )


        // 45 particles → maximum of 85.
        rainEmitter?
            .particleBirthRate =
            45
            + 40
            * rainProgress


        /*
         Haze previously became strong enough to obscure
         gameplay.

         Now it ranges from about 1.5% to only 6%.
         */

        stormHaze?
            .alpha =
            0.015
            + 0.045
            * rainProgress


        // Do not put water on the "camera" until later.
        guard
            distance >= 750
        else {
            return
        }

        nextWetStreakTime -=
            delta

        if nextWetStreakTime <= 0 {

            createWetScreenStreak(
                intensity:
                    rainProgress
            )

            /*
             Wet streaks are now occasional.

             Even at full intensity, roughly one streak
             appears every second rather than several.
             */

            nextWetStreakTime =
                max(
                    0.75,
                    1.50
                    - TimeInterval(
                        rainProgress
                    )
                    * 0.55
                )
        }
    }


    // MARK: - Wet Screen

    private func createWetScreenStreak(
        intensity: CGFloat
    ) {

        let width =
            CGFloat.random(
                in: 2...4
            )

        let height =
            CGFloat.random(
                in: 35...85
            )

        let streak =
            SKShapeNode(
                rectOf:
                    CGSize(
                        width: width,
                        height: height
                    ),
                cornerRadius:
                    width / 2
            )

        // Much more subtle transparency.
        streak.fillColor =
            UIColor.white
            .withAlphaComponent(
                0.018
                + 0.035
                * intensity
            )

        streak.strokeColor =
            UIColor(
                red: 0.68,
                green: 0.80,
                blue: 0.86,
                alpha:
                    0.018
                    + 0.035
                    * intensity
            )

        streak.lineWidth = 1

        streak.position =
            CGPoint(
                x:
                    CGFloat.random(
                        in: 15...(size.width - 15)
                    ),
                y:
                    size.height
                    + 60
            )

        streak.zRotation =
            CGFloat.random(
                in: -0.07...0.07
            )

        wetGlassLayer.addChild(
            streak
        )

        let fall =
            SKAction.moveTo(
                y: -80,
                duration:
                    Double.random(
                        in: 2.4...3.6
                    )
            )

        let fade =
            SKAction.fadeOut(
                withDuration: 0.8
            )

        streak.run(
            .sequence([
                .group([
                    fall,

                    .sequence([
                        .wait(
                            forDuration: 1.4
                        ),

                        fade
                    ])
                ]),

                .removeFromParent()
            ])
        )
    }


    // MARK: - Road

    private func setupRoad() {

        let worldBackground =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.045,
                        green: 0.055,
                        blue: 0.045,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: size.width,
                        height: size.height
                    )
            )

        worldBackground.position =
            CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

        worldBackground.zPosition = -60

        addChild(
            worldBackground
        )


        let road =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.145,
                        green: 0.155,
                        blue: 0.13,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: size.width * 0.79,
                        height: size.height
                    )
            )

        road.position =
            CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

        road.zPosition = -40

        addChild(
            road
        )


        let grime =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.075,
                        green: 0.105,
                        blue: 0.07,
                        alpha: 0.52
                    ),
                size:
                    CGSize(
                        width: size.width * 0.50,
                        height: size.height
                    )
            )

        grime.position =
            CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

        grime.zPosition = -39

        addChild(
            grime
        )


        createSidewalk(
            x: 28,
            width: 54
        )

        createSidewalk(
            x: size.width - 28,
            width: 54
        )

        createBuildingWall(
            side: .left
        )

        createBuildingWall(
            side: .right
        )

        createShrubbery(
            side: .left
        )

        createShrubbery(
            side: .right
        )

        createRoadCracks()
        createRoadRubble()
        createToxicStains()
        createBrokenLaneMarkers()
    }


    private func createSidewalk(
        x: CGFloat,
        width: CGFloat
    ) {

        let sidewalk =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.19,
                        green: 0.195,
                        blue: 0.16,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: width,
                        height: size.height
                    )
            )

        sidewalk.position =
            CGPoint(
                x: x,
                y: size.height / 2
            )

        sidewalk.zPosition = -34

        addChild(
            sidewalk
        )


        let curbX =
            x < size.width / 2
            ? x + width / 2
            : x - width / 2


        let curb =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.30,
                        green: 0.30,
                        blue: 0.24,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: 5,
                        height: size.height
                    )
            )

        curb.position =
            CGPoint(
                x: curbX,
                y: size.height / 2
            )

        curb.zPosition = -30

        addChild(
            curb
        )
    }


    private func createBuildingWall(
        side: StreetSide
    ) {

        let wallWidth: CGFloat = 55

        let wallX =
            side == .left
            ? wallWidth / 2
            : size.width - wallWidth / 2


        let wall =
            SKSpriteNode(
                color:
                    SKColor(
                        red: 0.075,
                        green: 0.085,
                        blue: 0.068,
                        alpha: 1
                    ),
                size:
                    CGSize(
                        width: wallWidth,
                        height: size.height
                    )
            )

        wall.position =
            CGPoint(
                x: wallX,
                y: size.height / 2
            )

        wall.zPosition = -22

        addChild(
            wall
        )


        for row in 0..<9 {

            let window =
                SKSpriteNode(
                    color:
                        SKColor(
                            red: 0.018,
                            green: 0.025,
                            blue: 0.020,
                            alpha: 1
                        ),
                    size:
                        CGSize(
                            width: 19,
                            height: 28
                        )
                )

            window.position =
                CGPoint(
                    x:
                        wallX
                        + CGFloat.random(
                            in: -7...7
                        ),
                    y:
                        CGFloat(row)
                        * 94
                        + 55
                )

            window.zPosition = -19

            addChild(
                window
            )
        }
    }


    private func createShrubbery(
        side: StreetSide
    ) {

        let baseX =
            side == .left
            ? CGFloat(47)
            : size.width - 47


        for index in 0..<13 {

            let shrub =
                SKNode()


            let stem =
                SKSpriteNode(
                    color:
                        SKColor(
                            red: 0.08,
                            green: 0.14,
                            blue: 0.055,
                            alpha: 1
                        ),
                    size:
                        CGSize(
                            width: 5,
                            height:
                                CGFloat.random(
                                    in: 18...34
                                )
                        )
                )

            shrub.addChild(
                stem
            )


            for _ in 0..<5 {

                let leaf =
                    SKSpriteNode(
                        color:
                            SKColor(
                                red: 0.13,
                                green: 0.27,
                                blue: 0.07,
                                alpha: 1
                            ),
                        size:
                            CGSize(
                                width:
                                    CGFloat.random(
                                        in: 9...18
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
                                in: 1...22
                            )
                    )

                shrub.addChild(
                    leaf
                )
            }


            shrub.position =
                CGPoint(
                    x:
                        baseX
                        + CGFloat.random(
                            in: -14...14
                        ),
                    y:
                        CGFloat(index)
                        * 68
                        + CGFloat.random(
                            in: 5...35
                        )
                )

            shrub.zPosition = -15

            addChild(
                shrub
            )
        }
    }


    private func createRoadCracks() {

        let crackXs: [CGFloat] = [
            111,
            139,
            174,
            206,
            239,
            275
        ]


        for index in 0..<24 {

            let crack =
                SKSpriteNode(
                    color:
                        SKColor.black
                        .withAlphaComponent(
                            0.38
                        ),
                    size:
                        CGSize(
                            width:
                                CGFloat.random(
                                    in: 7...24
                                ),
                            height:
                                CGFloat.random(
                                    in: 2...4
                                )
                        )
                )

            crack.position =
                CGPoint(
                    x:
                        crackXs.randomElement()
                        ?? size.width / 2,
                    y:
                        CGFloat(index)
                        * 37
                        + CGFloat.random(
                            in: 5...28
                        )
                )

            crack.zRotation =
                CGFloat.random(
                    in: -0.6...0.6
                )

            crack.zPosition = -28

            addChild(
                crack
            )
        }
    }


    private func createRoadRubble() {

        for _ in 0..<32 {

            let rubble =
                SKSpriteNode(
                    color:
                        SKColor(
                            red: 0.20,
                            green: 0.20,
                            blue: 0.17,
                            alpha: 1
                        ),
                    size:
                        CGSize(
                            width:
                                CGFloat.random(
                                    in: 4...12
                                ),
                            height:
                                CGFloat.random(
                                    in: 3...8
                                )
                        )
                )


            let leftSide =
                Bool.random()


            rubble.position =
                CGPoint(
                    x:
                        leftSide
                        ? CGFloat.random(
                            in: 48...102
                        )
                        : CGFloat.random(
                            in: (size.width - 102)...(size.width - 48)
                        ),
                    y:
                        CGFloat.random(
                            in: 20...size.height
                        )
                )

            rubble.zPosition = -24

            addChild(
                rubble
            )
        }
    }


    private func createToxicStains() {

        for _ in 0..<12 {

            let stain =
                SKShapeNode(
                    ellipseOf:
                        CGSize(
                            width:
                                CGFloat.random(
                                    in: 18...45
                                ),
                            height:
                                CGFloat.random(
                                    in: 5...14
                                )
                        )
                )

            stain.fillColor =
                SKColor(
                    red: 0.12,
                    green: 0.24,
                    blue: 0.065,
                    alpha: 0.30
                )

            stain.strokeColor = .clear

            stain.position =
                CGPoint(
                    x:
                        CGFloat.random(
                            in: 87...(size.width - 87)
                        ),
                    y:
                        CGFloat.random(
                            in: 20...size.height
                        )
                )

            stain.zPosition = -27

            addChild(
                stain
            )
        }
    }


    private func createBrokenLaneMarkers() {

        for laneX in [
            size.width / 2 - 52,
            size.width / 2 + 52
        ] {

            for index in 0..<10 {

                let dash =
                    SKSpriteNode(
                        color:
                            SKColor(
                                red: 0.34,
                                green: 0.35,
                                blue: 0.30,
                                alpha: 0.30
                            ),
                        size:
                            CGSize(
                                width: 3,
                                height:
                                    CGFloat.random(
                                        in: 15...31
                                    )
                            )
                    )

                dash.position =
                    CGPoint(
                        x:
                            laneX
                            + CGFloat.random(
                                in: -3...3
                            ),
                        y:
                            CGFloat(index)
                            * 92
                            + 35
                    )

                dash.zPosition = -26

                addChild(
                    dash
                )
            }
        }
    }


    // MARK: - Player

    private func setupPlayer() {

        player =
            PixelArtFactory.makePlayer(
                appearance:
                    progress.appearance
            )

        player.position =
            CGPoint(
                x:
                    lanePositions[
                        currentLane
                    ],
                y:
                    playerBaseY
            )

        player.zPosition = 30

        addChild(
            player
        )


        if
            let sprite =
                player.childNode(
                    withName:
                        "playerSprite"
                ) {

            sprite.run(
                .repeatForever(
                    .sequence([
                        .moveBy(
                            x: 0,
                            y: 3,
                            duration: 0.10
                        ),

                        .moveBy(
                            x: 0,
                            y: -3,
                            duration: 0.10
                        )
                    ])
                ),
                withKey:
                    "runningBob"
            )
        }
    }


    // MARK: - HUD

    private func setupHUD() {

        let hudY =
            size.height - 110


        distanceLabel =
            makeHUDLabel(
                text: "0m",
                alignment: .left
            )

        distanceLabel.position =
            CGPoint(
                x: 22,
                y: hudY
            )

        addChild(
            distanceLabel
        )


        scrapLabel =
            makeHUDLabel(
                text: "⚙ 0",
                alignment: .center
            )

        scrapLabel.position =
            CGPoint(
                x: size.width / 2,
                y: hudY
            )

        scrapLabel.fontColor =
            .systemYellow

        addChild(
            scrapLabel
        )


        health = maxHealth

        healthLabel =
            makeHUDLabel(
                text:
                    heartText(),
                alignment:
                    .right
            )

        healthLabel.position =
            CGPoint(
                x:
                    size.width - 22,
                y:
                    hudY
            )

        healthLabel.fontColor =
            .systemRed

        addChild(
            healthLabel
        )
    }


    private func makeHUDLabel(
        text: String,
        alignment:
            SKLabelHorizontalAlignmentMode
    ) -> SKLabelNode {

        let label =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        label.text = text

        label.fontSize = 15
        label.fontColor = .white

        label.horizontalAlignmentMode =
            alignment

        label.verticalAlignmentMode =
            .center

        label.zPosition = 170

        return label
    }


    private func heartText() -> String {

        String(
            repeating:
                "♥",
            count:
                max(
                    health,
                    0
                )
        )
    }


    // MARK: - Safehouse HUD

    private func setupSafehouseHUD() {

        removeSafehouseHUD()

        let items =
            SafehouseItem.allCases

        let spacing: CGFloat = 78

        let totalWidth =
            spacing
            * CGFloat(
                items.count - 1
            )

        let startX =
            size.width / 2
            - totalWidth / 2


        for (
            index,
            item
        ) in items.enumerated() {

            let root =
                SKNode()

            root.name =
                safehouseButtonName(
                    item
                )


            let background =
                SKShapeNode(
                    rectOf:
                        CGSize(
                            width: 60,
                            height: 60
                        ),
                    cornerRadius:
                        10
                )

            background.fillColor =
                UIColor.black
                .withAlphaComponent(
                    0.72
                )

            background.strokeColor =
                UIColor.white
                .withAlphaComponent(
                    0.18
                )

            root.addChild(
                background
            )


            let texture =
                SKTexture(
                    imageNamed:
                        item.textureName
                )

            texture.filteringMode =
                .nearest


            let icon =
                SKSpriteNode(
                    texture:
                        texture
                )

            icon.size =
                CGSize(
                    width: 34,
                    height: 34
                )

            icon.position =
                CGPoint(
                    x: 0,
                    y: 5
                )

            icon.alpha =
                safehouse.count(
                    for: item
                ) > 0
                ? 1
                : 0.32

            root.addChild(
                icon
            )


            let countLabel =
                SKLabelNode(
                    fontNamed:
                        "Menlo-Bold"
                )

            countLabel.text =
                "×\(safehouse.count(for: item))"

            countLabel.fontSize = 9

            countLabel.fontColor =
                safehouse.count(
                    for: item
                ) > 0
                ? .white
                : .gray

            countLabel.position =
                CGPoint(
                    x: 19,
                    y: -23
                )

            countLabel.horizontalAlignmentMode =
                .right

            root.addChild(
                countLabel
            )


            root.position =
                CGPoint(
                    x:
                        startX
                        + CGFloat(index)
                        * spacing,
                    y:
                        63
                )

            root.zPosition = 175

            addChild(
                root
            )
        }
    }


    private func removeSafehouseHUD() {

        for item
        in SafehouseItem.allCases {

            childNode(
                withName:
                    safehouseButtonName(
                        item
                    )
            )?
            .removeFromParent()
        }
    }


    private func safehouseButtonName(
        _ item: SafehouseItem
    ) -> String {

        "safehouseButton_\(item.rawValue)"
    }


    private func refreshSafehouseHUD() {

        setupSafehouseHUD()
    }


    private func safehouseItem(
        at point: CGPoint
    ) -> SafehouseItem? {

        for item
        in SafehouseItem.allCases {

            guard
                let button =
                    childNode(
                        withName:
                            safehouseButtonName(
                                item
                            )
                    )
            else {

                continue
            }

            let frame =
                button
                    .calculateAccumulatedFrame()
                    .insetBy(
                        dx: -7,
                        dy: -7
                    )

            if frame.contains(
                point
            ) {

                return item
            }
        }

        return nil
    }


    private func activateSafehouseItem(
        _ item: SafehouseItem
    ) {

        guard
            safehouse.count(
                for: item
            ) > 0
        else {

            showEventMessage(
                "NONE LEFT",
                color: .gray
            )

            return
        }


        switch item {

        case .shield:

            guard
                shieldTime <= 0
            else {

                showEventMessage(
                    "SHIELD ACTIVE",
                    color:
                        .systemBlue
                )

                return
            }

            guard
                safehouse.consume(
                    .shield
                )
            else {

                return
            }

            shieldTime = 8

            showAnnouncement(
                title:
                    "SHIELD",
                subtitle:
                    "ONE HIT BLOCKED",
                color:
                    .systemBlue
            )


        case .magnet:

            guard
                magnetTime <= 0
            else {

                showEventMessage(
                    "MAGNET ACTIVE",
                    color:
                        .systemPurple
                )

                return
            }

            guard
                safehouse.consume(
                    .magnet
                )
            else {

                return
            }

            magnetTime =
                8
                + TimeInterval(
                    progress.magnetLevel
                )

            showAnnouncement(
                title:
                    "MAGNET",
                subtitle:
                    "SCRAP PULLED IN",
                color:
                    .systemPurple
            )


        case .doubleScrap:

            guard
                doubleScrapTime <= 0
            else {

                showEventMessage(
                    "2X ACTIVE",
                    color:
                        .systemGreen
                )

                return
            }

            guard
                safehouse.consume(
                    .doubleScrap
                )
            else {

                return
            }

            doubleScrapTime = 10

            showAnnouncement(
                title:
                    "DOUBLE SCRAP",
                subtitle:
                    "10 SECONDS",
                color:
                    .systemGreen
            )


        case .medkit:

            guard
                health < maxHealth
            else {

                showEventMessage(
                    "HEALTH FULL",
                    color:
                        .systemRed
                )

                return
            }

            guard
                safehouse.consume(
                    .medkit
                )
            else {

                return
            }

            health =
                min(
                    maxHealth,
                    health + 1
                )

            healthLabel.text =
                heartText()

            showAnnouncement(
                title:
                    "MEDKIT",
                subtitle:
                    "+1 HEALTH",
                color:
                    .systemRed
            )
        }


        refreshSafehouseHUD()

        haptic(
            .medium
        )
    }


    // MARK: - Update

    override func update(
        _ currentTime: TimeInterval
    ) {

        guard
            !gameOver
        else {
            return
        }


        if previousUpdateTime == 0 {

            previousUpdateTime =
                currentTime

            return
        }


        let delta =
            min(
                currentTime
                - previousUpdateTime,
                0.05
            )

        previousUpdateTime =
            currentTime

        elapsedTime +=
            delta

        preciseDistance +=
            delta
            * Double(
                worldSpeed
            )
            * 0.055

        distance =
            Int(
                preciseDistance
            )

        worldSpeed =
            min(
                520,
                285
                + CGFloat(distance)
                * 0.075
            )

        distanceLabel.text =
            "\(distance)m"

        scrapLabel.text =
            "⚙ \(runScrap)"


        updateWeather(
            delta
        )

        updatePowerUps(
            delta
        )

        updateBoss(
            delta
        )

        updateSpawning(
            delta
        )

        moveWorldObjects(
            delta
        )

        checkCollisions()

        updateMagnet(
            delta
        )
    }


    // MARK: - Spawning

    private func updateSpawning(
        _ delta: TimeInterval
    ) {

        threatTimer +=
            delta

        pickupTimer +=
            delta


        if
            threatTimer
            >= nextThreatDelay {

            threatTimer = 0

            spawnThreat()

            let minimum: Double
            let maximum: Double

            if distance < 300 {

                minimum = 0.68
                maximum = 0.95

            } else if distance < 800 {

                minimum = 0.60
                maximum = 0.86

            } else {

                minimum = 0.52
                maximum = 0.78
            }

            nextThreatDelay =
                Double.random(
                    in: minimum...maximum
                )
        }


        if
            pickupTimer
            >= nextPickupDelay {

            pickupTimer = 0

            spawnPickup()

            nextPickupDelay =
                Double.random(
                    in: 1.45...2.15
                )
        }
    }


    private func spawnThreat() {

        var pool: [ThreatKind] = [
            .barricade,
            .barricade,

            .overhead,
            .overhead,

            .walker,
            .walker
        ]


        if distance >= 100 {
            pool += [
                .toxic,
                .toxic
            ]
        }


        if distance >= 150 {
            pool += [
                .runner
            ]
        }


        if distance >= 300 {
            pool += [
                .burningCar,
                .burningCar
            ]
        }


        if distance >= 450 {
            pool += [
                .crawler
            ]
        }


        if distance >= 550 {
            pool += [
                .wreckedCar,
                .wreckedCar
            ]
        }


        if distance >= 650 {
            pool += [
                .cat
            ]
        }


        if distance >= 800 {
            pool += [
                .dog
            ]
        }


        if distance >= 1000 {
            pool += [
                .brute
            ]
        }


        guard
            let kind =
                pool.randomElement()
        else {
            return
        }


        let lane =
            Int.random(
                in: 0...2
            )

        let node: SKNode


        switch kind {

        case .barricade:

            node =
                PixelArtFactory
                    .makeBarricade()

            configureThreat(
                node,
                kind: "barricade",
                lane: lane,
                hitWidth: 86,
                hitHeight: 48,
                offsetY: 6,
                speedMultiplier: 1
            )


        case .overhead:

            node =
                PixelArtFactory
                    .makeOverheadObstacle()

            configureThreat(
                node,
                kind: "overhead",
                lane: lane,
                hitWidth: 90,
                hitHeight: 34,
                offsetY: 48,
                speedMultiplier: 1
            )


        case .toxic:

            node =
                PixelArtFactory
                    .makeHazard(
                        type: .toxic
                    )

            configureThreat(
                node,
                kind: "toxic",
                lane: lane,
                hitWidth: 91,
                hitHeight: 29,
                offsetY: 0,
                speedMultiplier: 1
            )


        case .burningCar:

            node =
                PixelArtFactory
                    .makeHazard(
                        type: .burningCar
                    )

            configureThreat(
                node,
                kind: "burningCar",
                lane: lane,
                hitWidth: 99,
                hitHeight: 64,
                offsetY: 17,
                speedMultiplier: 1
            )


        case .wreckedCar:

            node =
                PixelArtFactory
                    .makeHazard(
                        type: .wreckedCar
                    )

            configureThreat(
                node,
                kind: "wreckedCar",
                lane: lane,
                hitWidth: 100,
                hitHeight: 61,
                offsetY: 15,
                speedMultiplier: 1
            )


        case .walker:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .walker
                    )

            configureThreat(
                node,
                kind: "walker",
                lane: lane,
                hitWidth: 55,
                hitHeight: 89,
                offsetY: 18,
                speedMultiplier:
                    ZombieType.walker
                        .speedMultiplier
            )


        case .runner:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .runner
                    )

            configureThreat(
                node,
                kind: "runner",
                lane: lane,
                hitWidth: 55,
                hitHeight: 87,
                offsetY: 17,
                speedMultiplier:
                    ZombieType.runner
                        .speedMultiplier
            )


        case .crawler:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .crawler
                    )

            configureThreat(
                node,
                kind: "crawler",
                lane: lane,
                hitWidth: 88,
                hitHeight: 49,
                offsetY: 8,
                speedMultiplier:
                    ZombieType.crawler
                        .speedMultiplier
            )


        case .cat:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .cat
                    )

            configureThreat(
                node,
                kind: "cat",
                lane: lane,
                hitWidth: 74,
                hitHeight: 58,
                offsetY: 9,
                speedMultiplier:
                    ZombieType.cat
                        .speedMultiplier
            )


        case .dog:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .dog
                    )

            configureThreat(
                node,
                kind: "dog",
                lane: lane,
                hitWidth: 84,
                hitHeight: 71,
                offsetY: 11,
                speedMultiplier:
                    ZombieType.dog
                        .speedMultiplier
            )


        case .brute:

            node =
                PixelArtFactory
                    .makeZombie(
                        type: .brute
                    )

            configureThreat(
                node,
                kind: "brute",
                lane: lane,
                hitWidth: 80,
                hitHeight: 112,
                offsetY: 20,
                speedMultiplier:
                    ZombieType.brute
                        .speedMultiplier
            )
        }


        node.position =
            CGPoint(
                x:
                    lanePositions[
                        lane
                    ],
                y:
                    size.height
                    + 145
            )

        node.zPosition = 12

        addChild(
            node
        )
    }


    private func configureThreat(
        _ node: SKNode,
        kind: String,
        lane: Int,
        hitWidth: CGFloat,
        hitHeight: CGFloat,
        offsetY: CGFloat,
        speedMultiplier: Double
    ) {

        node.userData =
            NSMutableDictionary()

        node.userData?["moving"] =
            true

        node.userData?["threat"] =
            true

        node.userData?["kind"] =
            kind

        node.userData?["lane"] =
            lane

        node.userData?["hitWidth"] =
            hitWidth

        node.userData?["hitHeight"] =
            hitHeight

        node.userData?["hitOffsetY"] =
            offsetY

        node.userData?["speedMultiplier"] =
            speedMultiplier

        node.userData?["nearMissChecked"] =
            false
    }


    // MARK: - Pickups

    private func spawnPickup() {

        let lane =
            Int.random(
                in: 0...2
            )

        let node: SKNode

        let roll =
            Int.random(
                in: 0...99
            )


        if
            distance >= 200,
            roll < 8 {

            let type =
                PowerUpType
                    .allCases
                    .randomElement()
                ?? .shield

            node =
                PixelArtFactory
                    .makePowerUp(
                        type: type
                    )

        } else if roll < 20 {

            node =
                PixelArtFactory
                    .makeMedKit()

        } else {

            node =
                PixelArtFactory
                    .makeScrap()
        }


        if node.userData == nil {

            node.userData =
                NSMutableDictionary()
        }

        node.userData?["moving"] =
            true

        node.userData?["pickup"] =
            true

        node.userData?["lane"] =
            lane

        node.userData?["speedMultiplier"] =
            1.0

        node.position =
            CGPoint(
                x:
                    lanePositions[
                        lane
                    ],
                y:
                    size.height
                    + 80
            )

        node.zPosition = 14

        addChild(
            node
        )
    }


    // MARK: - Moving Objects

    private func moveWorldObjects(
        _ delta: TimeInterval
    ) {

        for node in children {

            guard
                node.userData?["moving"]
                as? Bool
                == true
            else {
                continue
            }

            let multiplier =
                node.userData?["speedMultiplier"]
                as? Double
                ?? 1

            node.position.y -=
                worldSpeed
                * CGFloat(multiplier)
                * CGFloat(delta)

            checkNearMiss(
                node
            )

            if node.position.y < -200 {

                node.removeFromParent()
            }
        }
    }


    // MARK: - Near Miss

    private func checkNearMiss(
        _ node: SKNode
    ) {

        guard
            node.userData?["threat"]
            as? Bool
            == true
        else {
            return
        }

        guard
            node.userData?["nearMissChecked"]
            as? Bool
            != true
        else {
            return
        }

        guard
            node.position.y
            < playerBaseY - 18
        else {
            return
        }

        node.userData?["nearMissChecked"] =
            true

        let lane =
            node.userData?["lane"]
            as? Int
            ?? -10

        guard
            abs(
                lane - currentLane
            )
            == 1
        else {
            return
        }

        guard
            elapsedTime
            - lastNearMissTime
            >= nearMissCooldown
        else {
            return
        }

        guard
            Double.random(
                in: 0...1
            )
            <= nearMissChance
        else {
            return
        }

        lastNearMissTime =
            elapsedTime

        runScrap += 2

        progress.addNearMiss()

        showEventMessage(
            "NEAR MISS  +2",
            color: .systemOrange
        )

        haptic(
            .light
        )
    }


    // MARK: - Collision

    private func checkCollisions() {

        guard
            !isInvulnerable,
            !gameOver
        else {
            return
        }


        for node in children {

            if
                node.userData?["pickup"]
                as? Bool
                == true {

                if pickupCollision(
                    with: node
                ) {

                    collect(
                        node
                    )
                }

                continue
            }


            guard
                node.userData?["threat"]
                as? Bool
                == true
            else {
                continue
            }


            if threatCollision(
                with: node
            ) {

                hitByThreat(
                    node
                )

                break
            }
        }
    }


    private func threatCollision(
        with node: SKNode
    ) -> Bool {

        let kind =
            node.userData?["kind"]
            as? String
            ?? ""

        let hitWidth =
            node.userData?["hitWidth"]
            as? CGFloat
            ?? 50

        let hitHeight =
            node.userData?["hitHeight"]
            as? CGFloat
            ?? 50

        let offsetY =
            node.userData?["hitOffsetY"]
            as? CGFloat
            ?? 0

        let playerHeight: CGFloat =
            isSliding
            ? 28
            : 62

        let playerWidth: CGFloat =
            34

        let playerCenter =
            CGPoint(
                x:
                    player.position.x,
                y:
                    player.position.y
                    + (
                        isSliding
                        ? 5
                        : 18
                    )
            )

        let threatCenter =
            CGPoint(
                x:
                    node.position.x,
                y:
                    node.position.y
                    + offsetY
            )

        let horizontal =
            abs(
                playerCenter.x
                - threatCenter.x
            )
            <
            (
                playerWidth
                + hitWidth
            )
            / 2

        let vertical =
            abs(
                playerCenter.y
                - threatCenter.y
            )
            <
            (
                playerHeight
                + hitHeight
            )
            / 2


        guard
            horizontal,
            vertical
        else {
            return false
        }


        if
            kind == "barricade"
            || kind == "toxic" {

            return !isJumping
        }


        if kind == "overhead" {

            return !isSliding
        }


        return true
    }


    private func pickupCollision(
        with node: SKNode
    ) -> Bool {

        let dx =
            abs(
                node.position.x
                - player.position.x
            )

        let dy =
            abs(
                node.position.y
                - player.position.y
            )

        return
            dx < 52
            &&
            dy < 68
    }


    // MARK: - Damage

    private func hitByThreat(
        _ node: SKNode
    ) {

        if shieldTime > 0 {

            shieldTime = 0

            node.removeFromParent()

            showEventMessage(
                "SHIELD BLOCKED",
                color: .systemBlue
            )

            if !bossActive {
                summonDangerBoss()
            }

            return
        }


        if
            bossActive,
            bossIsIntroChase {

            health -= 1

            healthLabel.text =
                heartText()

            node.removeFromParent()

            haptic(
                .heavy
            )

            if health <= 0 {

                triggerGameOver()

                return
            }

            bossIsIntroChase =
                false

            bossIsRetreating =
                false

            bossTimeRemaining =
                dangerBossDuration

            showAnnouncement(
                title:
                    "IT FOUND YOU",
                subtitle:
                    "DON'T GET HIT AGAIN",
                color:
                    .systemRed
            )

            beginTemporaryInvulnerability()

            return
        }


        if bossActive {

            node.removeFromParent()

            haptic(
                .heavy
            )

            triggerGameOver()

            return
        }


        health -= 1

        healthLabel.text =
            heartText()

        node.removeFromParent()

        haptic(
            .heavy
        )

        if health <= 0 {

            triggerGameOver()

            return
        }

        summonDangerBoss()

        beginTemporaryInvulnerability()
    }


    private func beginTemporaryInvulnerability() {

        isInvulnerable = true

        player.run(
            .sequence([
                .fadeAlpha(
                    to: 0.25,
                    duration: 0.08
                ),

                .fadeAlpha(
                    to: 1,
                    duration: 0.08
                ),

                .fadeAlpha(
                    to: 0.25,
                    duration: 0.08
                ),

                .fadeAlpha(
                    to: 1,
                    duration: 0.08
                )
            ])
        )


        run(
            .sequence([
                .wait(
                    forDuration: 0.9
                ),

                .run {
                    [weak self] in

                    self?
                        .isInvulnerable =
                        false
                }
            ])
        )
    }


    // MARK: - Boss

    private func startIntroBossChase() {

        guard
            !gameOver,
            !bossActive
        else {
            return
        }

        bossActive = true

        bossIsIntroChase = true
        bossIsRetreating = false

        bossTimeRemaining =
            introBossDuration

        spawnBoss()

        showAnnouncement(
            title:
                "THE BOSS IS CHASING YOU",
            subtitle:
                "DON'T GET HIT",
            color:
                .systemRed
        )

        haptic(
            .heavy
        )
    }


    private func summonDangerBoss() {

        guard
            !gameOver
        else {
            return
        }

        if bossIsRetreating {

            boss?
                .removeAllActions()

            boss?
                .removeFromParent()

            boss = nil

            bossIsRetreating =
                false
        }

        bossIsIntroChase =
            false

        bossTimeRemaining =
            dangerBossDuration


        if !bossActive {

            bossActive =
                true

            spawnBoss()
        }

        showAnnouncement(
            title:
                "IT FOUND YOU",
            subtitle:
                "DON'T GET HIT AGAIN",
            color:
                .systemRed
        )

        haptic(
            .heavy
        )
    }


    private func spawnBoss() {

        boss?
            .removeAllActions()

        boss?
            .removeFromParent()

        bossIsRetreating =
            false

        let newBoss =
            PixelArtFactory
                .makeBoss()

        newBoss.position =
            CGPoint(
                x:
                    player.position.x,
                y:
                    -205
            )

        newBoss.alpha = 1

        newBoss.setScale(
            1
        )

        newBoss.zPosition = 6

        addChild(
            newBoss
        )

        boss = newBoss
    }


    private func updateBoss(
        _ delta: TimeInterval
    ) {

        guard
            bossActive,
            let boss
        else {
            return
        }

        bossTimeRemaining -=
            delta

        boss.position.x +=
            (
                player.position.x
                - boss.position.x
            )
            * CGFloat(delta)
            * 2.4


        if
            boss.position.y
            < bossChaseY {

            boss.position.y +=
                CGFloat(delta)
                * 42

            if
                boss.position.y
                > bossChaseY {

                boss.position.y =
                    bossChaseY
            }
        }


        if bossTimeRemaining <= 0 {

            if bossIsIntroChase {

                endIntroBossChase()

            } else {

                endDangerBossChase()
            }
        }
    }


    private func endIntroBossChase() {

        guard
            let retreatingBoss =
                boss
        else {

            bossActive = false
            bossIsIntroChase = false
            bossIsRetreating = false
            bossTimeRemaining = 0

            return
        }

        bossActive = false
        bossIsIntroChase = false
        bossIsRetreating = true
        bossTimeRemaining = 0


        let fallBack =
            SKAction.moveTo(
                y: -270,
                duration: 1.35
            )

        fallBack.timingMode =
            .easeIn


        let drift =
            SKAction.moveTo(
                x: size.width / 2,
                duration: 1.35
            )


        let shrink =
            SKAction.scale(
                to: 0.78,
                duration: 1.35
            )


        let fade =
            SKAction.fadeAlpha(
                to: 0,
                duration: 1.35
            )


        retreatingBoss.run(
            .sequence([
                .group([
                    fallBack,
                    drift,
                    shrink,
                    fade
                ]),

                .run {
                    [weak self, weak retreatingBoss] in

                    retreatingBoss?
                        .removeFromParent()

                    if
                        self?.boss
                        === retreatingBoss {

                        self?.boss =
                            nil
                    }

                    self?
                        .bossIsRetreating =
                        false
                }
            ]),
            withKey:
                "bossRetreat"
        )
    }


    private func endDangerBossChase() {

        boss?
            .removeFromParent()

        boss = nil

        bossActive = false
        bossIsIntroChase = false
        bossIsRetreating = false

        bossTimeRemaining = 0

        runScrap += 100

        showAnnouncement(
            title:
                "ESCAPED",
            subtitle:
                "+100 SCRAP",
            color:
                .systemGreen
        )
    }


    // MARK: - Collect

    private func collect(
        _ node: SKNode
    ) {

        switch node.name {

        case "scrap":

            let amount =
                doubleScrapTime > 0
                ? 2
                : 1

            runScrap +=
                amount

            showEventMessage(
                "+\(amount) SCRAP",
                color:
                    .systemYellow
            )


        case "medkit":

            if health < maxHealth {

                health += 1

                healthLabel.text =
                    heartText()

                showEventMessage(
                    "+1 HEALTH",
                    color:
                        .systemRed
                )
            }


        case "powerUp":

            collectPowerUp(
                node
            )


        default:

            break
        }

        node.removeFromParent()

        haptic(
            .light
        )
    }


    private func collectPowerUp(
        _ node: SKNode
    ) {

        let type =
            node.userData?["type"]
            as? String
            ?? ""


        switch type {

        case "shield":

            shieldTime = 8

            showAnnouncement(
                title:
                    "SHIELD",
                subtitle:
                    "ONE HIT BLOCKED",
                color:
                    .systemBlue
            )


        case "magnet":

            magnetTime =
                6
                + TimeInterval(
                    progress.magnetLevel
                )

            showAnnouncement(
                title:
                    "MAGNET",
                subtitle:
                    "SCRAP PULLED IN",
                color:
                    .systemPurple
            )


        case "double":

            doubleScrapTime = 8

            showAnnouncement(
                title:
                    "DOUBLE SCRAP",
                subtitle:
                    "MAKE IT COUNT",
                color:
                    .systemGreen
            )


        default:

            break
        }
    }


    private func updatePowerUps(
        _ delta: TimeInterval
    ) {

        shieldTime =
            max(
                0,
                shieldTime - delta
            )

        magnetTime =
            max(
                0,
                magnetTime - delta
            )

        doubleScrapTime =
            max(
                0,
                doubleScrapTime - delta
            )
    }


    private func updateMagnet(
        _ delta: TimeInterval
    ) {

        guard
            magnetTime > 0
        else {
            return
        }

        for node in children {

            guard
                node.name == "scrap"
            else {
                continue
            }

            let verticalDistance =
                abs(
                    node.position.y
                    - player.position.y
                )

            guard
                verticalDistance < 230
            else {
                continue
            }

            let difference =
                player.position.x
                - node.position.x

            node.position.x +=
                difference
                * CGFloat(delta)
                * 6.5
        }
    }


    // MARK: - Touch Controls

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        if gameOver {

            restartGame()

            return
        }

        guard
            let touch =
                touches.first
        else {
            return
        }

        let point =
            touch.location(
                in: self
            )

        if
            let item =
                safehouseItem(
                    at: point
                ) {

            activateSafehouseItem(
                item
            )

            touchStart = nil

            return
        }

        touchStart =
            point
    }


    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard
            !gameOver,
            let start =
                touchStart,
            let touch =
                touches.first
        else {
            return
        }

        let end =
            touch.location(
                in: self
            )

        let dx =
            end.x - start.x

        let dy =
            end.y - start.y

        touchStart = nil


        if abs(dx) > abs(dy) {

            if dx > 35 {

                moveRight()

            } else if dx < -35 {

                moveLeft()
            }

        } else {

            if dy > 35 {

                jump()

            } else if dy < -35 {

                slide()
            }
        }
    }


    private func moveLeft() {

        guard
            currentLane > 0
        else {
            return
        }

        currentLane -= 1

        movePlayerToLane()
    }


    private func moveRight() {

        guard
            currentLane < 2
        else {
            return
        }

        currentLane += 1

        movePlayerToLane()
    }


    private func movePlayerToLane() {

        let move =
            SKAction.moveTo(
                x:
                    lanePositions[
                        currentLane
                    ],
                duration: 0.12
            )

        move.timingMode =
            .easeOut

        player.run(
            move
        )
    }


    private func jump() {

        guard
            !isJumping,
            !isSliding
        else {
            return
        }

        isJumping = true

        let up =
            SKAction.moveTo(
                y:
                    playerBaseY
                    + 100,
                duration: 0.23
            )

        up.timingMode =
            .easeOut


        let down =
            SKAction.moveTo(
                y:
                    playerBaseY,
                duration: 0.27
            )

        down.timingMode =
            .easeIn


        player.run(
            .sequence([
                up,
                down,

                .run {
                    [weak self] in

                    self?
                        .isJumping =
                        false
                }
            ])
        )
    }


    private func slide() {

        guard
            !isSliding,
            !isJumping
        else {
            return
        }

        isSliding = true

        guard
            let sprite =
                player.childNode(
                    withName:
                        "playerSprite"
                )
        else {

            isSliding = false

            return
        }


        sprite.run(
            .sequence([
                .scaleY(
                    to: 0.52,
                    duration: 0.08
                ),

                .wait(
                    forDuration: 0.45
                ),

                .scaleY(
                    to: 1,
                    duration: 0.10
                ),

                .run {
                    [weak self] in

                    self?
                        .isSliding =
                        false
                }
            ])
        )
    }


    // MARK: - Game Over

    private func triggerGameOver() {

        guard
            !gameOver
        else {
            return
        }

        gameOver = true

        AudioManager.shared
            .playDeathSound()

        stopAndRecordRun()

        removeNamedNodes([
            "eventMessage",
            "announcementTitle",
            "announcementSubtitle",
            "announcementPanel"
        ])


        let overlay =
            SKSpriteNode(
                color:
                    UIColor.black
                    .withAlphaComponent(
                        0.72
                    ),
                size:
                    CGSize(
                        width: size.width,
                        height: size.height
                    )
            )

        overlay.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    size.height / 2
            )

        overlay.zPosition = 200

        addChild(
            overlay
        )


        let texture =
            SKTexture(
                imageNamed:
                    "UI_YouDied"
            )

        texture.filteringMode =
            .nearest


        let deathImage =
            SKSpriteNode(
                texture:
                    texture
            )

        let original =
            texture.size()

        let targetWidth =
            min(
                size.width * 0.86,
                350
            )

        if original.width > 0 {

            let ratio =
                original.height
                / original.width

            deathImage.size =
                CGSize(
                    width:
                        targetWidth,
                    height:
                        targetWidth
                        * ratio
                )
        }


        deathImage.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    size.height
                    * 0.61
            )

        deathImage.zPosition = 210

        addChild(
            deathImage
        )


        let summary =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        summary.text =
            "\(distance)m   •   ⚙ \(runScrap)"

        summary.fontSize = 14
        summary.fontColor = .white

        summary.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    size.height
                    * 0.46
            )

        summary.zPosition = 210

        addChild(
            summary
        )


        let restart =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        restart.text =
            "TAP TO RUN AGAIN"

        restart.fontSize = 13

        restart.fontColor =
            .systemGreen

        restart.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    size.height
                    * 0.39
            )

        restart.zPosition = 210

        addChild(
            restart
        )

        haptic(
            .heavy
        )
    }


    // MARK: - Restart

    private func restartGame() {

        AudioManager.shared
            .playRunMusic()

        removeAllChildren()
        removeAllActions()

        gameOver = false
        hasRecordedRun = false

        preciseDistance = 0
        distance = 0
        runScrap = 0

        worldSpeed = 285

        previousUpdateTime = 0
        elapsedTime = 0

        threatTimer = 0
        nextThreatDelay = 0.85

        pickupTimer = 0
        nextPickupDelay = 1.8

        currentLane = 1

        isJumping = false
        isSliding = false
        isInvulnerable = false

        shieldTime = 0
        magnetTime = 0
        doubleScrapTime = 0

        boss = nil
        bossActive = false
        bossIsIntroChase = false
        bossIsRetreating = false
        bossTimeRemaining = 0

        lastNearMissTime = -100

        rainStarted = false
        rainEmitter = nil
        stormHaze = nil

        nextWetStreakTime = 0

        setupRoad()
        setupPlayer()
        setupHUD()
        setupSafehouseHUD()
        setupWeatherSystem()


        run(
            .sequence([
                .wait(
                    forDuration: 0.45
                ),

                .run {
                    [weak self] in

                    self?
                        .startIntroBossChase()
                }
            ]),
            withKey:
                "openingBossSequence"
        )
    }


    // MARK: - Save Run

    func stopAndRecordRun() {

        guard
            !hasRecordedRun
        else {
            return
        }

        hasRecordedRun = true

        progress.recordRun(
            distance:
                distance,
            scrapCollected:
                runScrap
        )

        progress.addScrap(
            runScrap
        )
    }


    // MARK: - Messages

    private func showEventMessage(
        _ text: String,
        color: SKColor
    ) {

        removeNamedNodes([
            "eventMessage"
        ])

        let label =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        label.name =
            "eventMessage"

        label.text =
            text

        label.fontSize = 13

        label.fontColor =
            color

        label.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    playerBaseY
                    + 110
            )

        label.zPosition = 190

        addChild(
            label
        )

        label.run(
            .sequence([
                .moveBy(
                    x: 0,
                    y: 12,
                    duration: 0.45
                ),

                .fadeOut(
                    withDuration: 0.25
                ),

                .removeFromParent()
            ])
        )
    }


    private func showAnnouncement(
        title: String,
        subtitle: String,
        color: SKColor
    ) {

        removeNamedNodes([
            "eventMessage",
            "announcementTitle",
            "announcementSubtitle",
            "announcementPanel"
        ])


        let panel =
            SKShapeNode(
                rectOf:
                    CGSize(
                        width:
                            size.width
                            * 0.76,
                        height:
                            74
                    ),
                cornerRadius: 8
            )

        panel.name =
            "announcementPanel"

        panel.fillColor =
            .black
            .withAlphaComponent(
                0.75
            )

        panel.strokeColor =
            color
            .withAlphaComponent(
                0.55
            )

        panel.lineWidth = 2

        panel.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    size.height
                    * 0.59
            )

        panel.zPosition = 185

        addChild(
            panel
        )


        let titleLabel =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        titleLabel.name =
            "announcementTitle"

        titleLabel.text =
            title

        titleLabel.fontSize = 18

        titleLabel.fontColor =
            color

        titleLabel.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    panel.position.y
                    + 8
            )

        titleLabel.zPosition = 190

        addChild(
            titleLabel
        )


        let subtitleLabel =
            SKLabelNode(
                fontNamed:
                    "Menlo-Bold"
            )

        subtitleLabel.name =
            "announcementSubtitle"

        subtitleLabel.text =
            subtitle

        subtitleLabel.fontSize = 10
        subtitleLabel.fontColor = .white

        subtitleLabel.position =
            CGPoint(
                x:
                    size.width / 2,
                y:
                    panel.position.y
                    - 19
            )

        subtitleLabel.zPosition = 190

        addChild(
            subtitleLabel
        )


        let fade =
            SKAction.sequence([
                .wait(
                    forDuration: 1.15
                ),

                .fadeOut(
                    withDuration: 0.25
                ),

                .removeFromParent()
            ])

        panel.run(
            fade
        )

        titleLabel.run(
            fade
        )

        subtitleLabel.run(
            fade
        )
    }


    private func removeNamedNodes(
        _ names: [String]
    ) {

        for name in names {

            childNode(
                withName:
                    name
            )?
            .removeFromParent()
        }
    }


    // MARK: - Haptics

    private func haptic(
        _ style:
            UIImpactFeedbackGenerator
            .FeedbackStyle
    ) {

        let generator =
            UIImpactFeedbackGenerator(
                style: style
            )

        generator.prepare()

        generator.impactOccurred()
    }
}
