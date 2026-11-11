import SpriteKit
import UIKit


// MARK: - Zombie Types

enum ZombieType:
    String,
    CaseIterable,
    Identifiable {

    case walker
    case runner
    case crawler
    case cat
    case dog
    case brute


    var id: String {
        rawValue
    }


    var textureName: String {

        switch self {

        case .walker:
            return "Zombie_Walker"

        case .runner:
            return "Zombie_Runner"

        case .crawler:
            return "Zombie_Crawler"

        case .cat:
            return "Zombie_Cat"

        case .dog:
            return "Zombie_Dog"

        case .brute:
            return "Zombie_Brute"
        }
    }


    var displayName: String {

        switch self {

        case .walker:
            return "Walker"

        case .runner:
            return "Runner"

        case .crawler:
            return "Crawler"

        case .cat:
            return "Infected Cat"

        case .dog:
            return "Infected Dog"

        case .brute:
            return "Brute"
        }
    }


    var description: String {

        switch self {

        case .walker:

            return
                "The most common infected. Predictable, but dangerous if you stop paying attention."


        case .runner:

            return
                "A fast infected that rushes toward you much quicker than a normal Walker."


        case .crawler:

            return
                "A low-moving infected that charges quickly and can be harder to read at a glance."


        case .cat:

            return
                "A small infected animal that darts through the street at high speed. Its smaller silhouette makes it easy to notice too late."


        case .dog:

            return
                "A larger infected animal that aggressively charges down a lane at the same speed as a Runner."


        case .brute:

            return
                "A massive infected with a much larger body. It moves slower, but blocks much more of the lane."
        }
    }


    var unlockText: String {

        switch self {

        case .walker:
            return "Appears immediately"

        case .runner:
            return "Appears after 150m"

        case .crawler:
            return "Appears after 450m"

        case .cat:
            return "Appears after 650m"

        case .dog:
            return "Appears after 800m"

        case .brute:
            return "Appears after 1000m"
        }
    }


    var threatRank: String {

        switch self {

        case .walker:
            return "LOW"

        case .runner,
             .crawler,
             .cat,
             .dog:
            return "HIGH"

        case .brute:
            return "SEVERE"
        }
    }


    var speedLabel: String {

        switch self {

        case .walker:
            return "NORMAL"

        case .runner,
             .crawler,
             .cat,
             .dog:
            return "FAST"

        case .brute:
            return "HEAVY"
        }
    }


    var speedMultiplier: Double {

        switch self {

        case .walker:
            return 1.0

        case .runner,
             .crawler,
             .cat,
             .dog:
            return 1.35

        case .brute:
            return 0.92
        }
    }


    var targetHeight: CGFloat {

        switch self {

        case .walker:
            return 134

        case .runner:
            return 132

        case .crawler:
            return 118

        case .cat:
            return 106

        case .dog:
            return 126

        case .brute:
            return 170
        }
    }
}


// MARK: - Power Ups

enum PowerUpType:
    String,
    CaseIterable {

    case shield
    case magnet
    case doubleScrap


    var textureName: String {

        switch self {

        case .shield:
            return "PowerUp_Shield"

        case .magnet:
            return "PowerUp_Magnet"

        case .doubleScrap:
            return "PowerUp_DoubleScrap"
        }
    }


    var displayName: String {

        switch self {

        case .shield:
            return "SHIELD"

        case .magnet:
            return "MAGNET"

        case .doubleScrap:
            return "DOUBLE SCRAP"
        }
    }
}


// MARK: - Hazards

enum HazardType {

    case toxic
    case burningCar
    case wreckedCar
}


// MARK: - Pixel Art Factory

enum PixelArtFactory {


    // MARK: Player

    static func makePlayer(
        appearance: CharacterAppearance
    ) -> SKNode {

        let root =
            SKNode()


        root.name =
            "player"


        let texture =
            SKTexture(
                imageNamed:
                    appearance.textureName
            )


        texture.filteringMode =
            .nearest


        /*
         Instead of attaching the original character directly
         to the player, we place it inside an SKCropNode.

         This hides the very bottom strip of the source PNG
         where the gray rectangle underneath the character's
         feet is visible.

         This applies automatically to every outfit.
         */

        let sourceSprite =
            SKSpriteNode(
                texture: texture
            )


        sourceSprite.name =
            "playerArtwork"


        applyAspectFitHeight(
            to: sourceSprite,
            texture: texture,
            targetHeight: 128,
            fallbackWidth: 72
        )


        /*
         Move the artwork slightly downward behind the mask.
         The mask then clips the unwanted bottom edge.
         */

        sourceSprite.position =
            CGPoint(
                x: 0,
                y: -3
            )


        let visibleWidth =
            max(
                sourceSprite.size.width + 8,
                80
            )


        /*
         We intentionally make the visible window shorter
         than the full artwork.

         The bottom ~10 pixels are hidden.
         */

        let visibleHeight: CGFloat =
            118


        let mask =
            SKSpriteNode(
                color: .white,
                size:
                    CGSize(
                        width: visibleWidth,
                        height: visibleHeight
                    )
            )


        /*
         Shift the mask upward so the TOP of the survivor
         remains visible while the lowest part is cropped.
         */

        mask.position =
            CGPoint(
                x: 0,
                y: 5
            )


        let cropNode =
            SKCropNode()


        cropNode.name =
            "playerCrop"


        cropNode.maskNode =
            mask


        cropNode.addChild(
            sourceSprite
        )


        cropNode.position =
            CGPoint(
                x: 0,
                y: 14
            )


        root.addChild(
            cropNode
        )


        /*
         GameScene uses this child for running/slide animation.
         Keep a named wrapper so those animations work even
         though the actual artwork is now inside the crop node.
         */

        let animationRoot =
            SKNode()


        animationRoot.name =
            "playerSprite"


        cropNode.removeFromParent()


        animationRoot.addChild(
            cropNode
        )


        root.addChild(
            animationRoot
        )


        return root
    }


    // MARK: Zombies

    static func makeZombie(
        type: ZombieType
    ) -> SKNode {

        let root =
            SKNode()


        root.name =
            "zombie"


        root.userData =
            NSMutableDictionary()


        root.userData?[
            "zombieType"
        ] = type.rawValue


        let texture =
            SKTexture(
                imageNamed:
                    type.textureName
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        sprite.name =
            "zombieSprite"


        applyAspectFitHeight(
            to: sprite,
            texture: texture,
            targetHeight: type.targetHeight,
            fallbackWidth: 80
        )


        root.addChild(
            sprite
        )


        switch type {

        case .runner,
             .crawler,
             .cat,
             .dog:

            let down =
                SKAction.moveBy(
                    x: 0,
                    y: -3,
                    duration: 0.09
                )


            let up =
                SKAction.moveBy(
                    x: 0,
                    y: 3,
                    duration: 0.09
                )


            sprite.run(
                .repeatForever(
                    .sequence([
                        down,
                        up
                    ])
                ),
                withKey:
                    "rushMotion"
            )


        case .walker:

            sprite.run(
                .repeatForever(
                    .sequence([

                        .rotate(
                            toAngle: -0.025,
                            duration: 0.18
                        ),

                        .rotate(
                            toAngle: 0.025,
                            duration: 0.18
                        )
                    ])
                ),
                withKey:
                    "walkerMotion"
            )


        case .brute:

            sprite.run(
                .repeatForever(
                    .sequence([

                        .rotate(
                            toAngle: -0.018,
                            duration: 0.24
                        ),

                        .rotate(
                            toAngle: 0.018,
                            duration: 0.24
                        )
                    ])
                ),
                withKey:
                    "bruteMotion"
            )
        }


        return root
    }


    // MARK: Boss

    static func makeBoss() -> SKNode {

        let root =
            SKNode()


        root.name =
            "boss"


        let texture =
            SKTexture(
                imageNamed:
                    "Zombie_Boss"
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        sprite.name =
            "bossSprite"


        applyAspectFitHeight(
            to: sprite,
            texture: texture,
            targetHeight: 260,
            fallbackWidth: 225
        )


        sprite.position =
            CGPoint(
                x: 0,
                y: 18
            )


        root.addChild(
            sprite
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .scale(
                        to: 1.04,
                        duration: 0.17
                    ),

                    .scale(
                        to: 1.0,
                        duration: 0.17
                    )
                ])
            ),
            withKey:
                "bossPulse"
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .rotate(
                        toAngle: -0.012,
                        duration: 0.16
                    ),

                    .rotate(
                        toAngle: 0.012,
                        duration: 0.16
                    )
                ])
            ),
            withKey:
                "bossLurch"
        )


        return root
    }


    // MARK: Barricade

    static func makeBarricade() -> SKNode {

        let root =
            SKNode()


        root.name =
            "barricade"


        let texture =
            SKTexture(
                imageNamed:
                    "Obstacle_Barricade"
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: 124,
            fallbackHeight: 70
        )


        root.addChild(
            sprite
        )


        return root
    }


    // MARK: Overhead

    static func makeOverheadObstacle() -> SKNode {

        let root =
            SKNode()


        root.name =
            "overhead"


        let texture =
            SKTexture(
                imageNamed:
                    "Obstacle_Overhead"
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: 142,
            fallbackHeight: 100
        )


        root.addChild(
            sprite
        )


        return root
    }


    // MARK: Hazard

    static func makeHazard(
        type: HazardType
    ) -> SKNode {

        let root =
            SKNode()


        let textureName:
            String


        let width:
            CGFloat


        switch type {

        case .toxic:

            root.name =
                "toxic"


            textureName =
                "Hazard_Toxic"


            width =
                120


        case .burningCar:

            root.name =
                "burningCar"


            textureName =
                "Hazard_BurningCar"


            width =
                148


        case .wreckedCar:

            root.name =
                "wreckedCar"


            textureName =
                "Hazard_WreckedCar"


            width =
                146
        }


        let texture =
            SKTexture(
                imageNamed:
                    textureName
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: width,
            fallbackHeight: 80
        )


        root.addChild(
            sprite
        )


        return root
    }


    // MARK: Scrap

    static func makeScrap() -> SKNode {

        let root =
            SKNode()


        root.name =
            "scrap"


        let texture =
            SKTexture(
                imageNamed:
                    "Pickup_Scrap"
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        sprite.name =
            "scrapSprite"


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: 52,
            fallbackHeight: 48
        )


        sprite.position =
            CGPoint(
                x: 0,
                y: 8
            )


        root.addChild(
            sprite
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .moveBy(
                        x: 0,
                        y: 3,
                        duration: 0.32
                    ),

                    .moveBy(
                        x: 0,
                        y: -3,
                        duration: 0.32
                    )
                ])
            ),
            withKey:
                "scrapFloat"
        )


        return root
    }


    // MARK: Medkit

    static func makeMedKit() -> SKNode {

        let root =
            SKNode()


        root.name =
            "medkit"


        let texture =
            SKTexture(
                imageNamed:
                    "Pickup_Medkit"
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        sprite.name =
            "medkitSprite"


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: 54,
            fallbackHeight: 48
        )


        sprite.position =
            CGPoint(
                x: 0,
                y: 7
            )


        root.addChild(
            sprite
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .moveBy(
                        x: 0,
                        y: 2,
                        duration: 0.30
                    ),

                    .moveBy(
                        x: 0,
                        y: -2,
                        duration: 0.30
                    )
                ])
            ),
            withKey:
                "medkitFloat"
        )


        return root
    }


    // MARK: Power Up

    static func makePowerUp(
        type: PowerUpType
    ) -> SKNode {

        let root =
            SKNode()


        root.name =
            "powerUp"


        root.userData =
            NSMutableDictionary()


        switch type {

        case .shield:

            root.userData?[
                "type"
            ] = "shield"


        case .magnet:

            root.userData?[
                "type"
            ] = "magnet"


        case .doubleScrap:

            root.userData?[
                "type"
            ] = "double"
        }


        let texture =
            SKTexture(
                imageNamed:
                    type.textureName
            )


        texture.filteringMode =
            .nearest


        let sprite =
            SKSpriteNode(
                texture: texture
            )


        sprite.name =
            "powerUpSprite"


        applyAspectFitWidth(
            to: sprite,
            texture: texture,
            targetWidth: 54,
            fallbackHeight: 54
        )


        root.addChild(
            sprite
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .moveBy(
                        x: 0,
                        y: 2,
                        duration: 0.28
                    ),

                    .moveBy(
                        x: 0,
                        y: -2,
                        duration: 0.28
                    )
                ])
            ),
            withKey:
                "powerUpFloat"
        )


        sprite.run(
            .repeatForever(
                .sequence([

                    .scale(
                        to: 1.05,
                        duration: 0.30
                    ),

                    .scale(
                        to: 1.0,
                        duration: 0.30
                    )
                ])
            ),
            withKey:
                "powerUpPulse"
        )


        return root
    }


    // MARK: Aspect Helpers

    private static func applyAspectFitHeight(
        to sprite: SKSpriteNode,
        texture: SKTexture,
        targetHeight: CGFloat,
        fallbackWidth: CGFloat
    ) {

        let source =
            texture.size()


        guard
            source.width > 0,
            source.height > 0
        else {

            sprite.size =
                CGSize(
                    width: fallbackWidth,
                    height: targetHeight
                )

            return
        }


        let ratio =
            source.width
            / source.height


        sprite.size =
            CGSize(
                width:
                    targetHeight
                    * ratio,
                height:
                    targetHeight
            )
    }


    private static func applyAspectFitWidth(
        to sprite: SKSpriteNode,
        texture: SKTexture,
        targetWidth: CGFloat,
        fallbackHeight: CGFloat
    ) {

        let source =
            texture.size()


        guard
            source.width > 0,
            source.height > 0
        else {

            sprite.size =
                CGSize(
                    width: targetWidth,
                    height: fallbackHeight
                )

            return
        }


        let ratio =
            source.height
            / source.width


        sprite.size =
            CGSize(
                width:
                    targetWidth,
                height:
                    targetWidth
                    * ratio
            )
    }
}
