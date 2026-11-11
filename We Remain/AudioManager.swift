import AVFoundation
import Foundation

final class AudioManager {

    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?

    private var currentTrack: String?

    private(set) var musicEnabled = true

    private init() {
        configureAudioSession()
    }


    // MARK: - Audio Session

    private func configureAudioSession() {

        do {

            let session =
                AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )

            try session.setActive(true)

            print("✅ AUDIO SESSION READY")

        } catch {

            print(
                "❌ AUDIO SESSION ERROR:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Menu Music

    func playMenuMusic() {

        stopEffect()

        playMusic(
            named: "Music_Menu",
            volume: 0.42
        )
    }


    // MARK: - Gameplay Music

    func playRunMusic() {

        stopEffect()

        playMusic(
            named: "Music_Run",
            volume: 0.55
        )
    }


    // MARK: - Death Music

    func playDeathSound() {

        guard musicEnabled else {
            return
        }

        // Stop gameplay music immediately.
        musicPlayer?.stop()

        musicPlayer = nil
        currentTrack = nil

        // Stop any previous effect.
        effectPlayer?.stop()
        effectPlayer = nil

        guard
            let url =
                findAudioFile(
                    named: "Music_Death"
                )
        else {

            print(
                "❌ COULD NOT FIND DEATH AUDIO: Music_Death"
            )

            printAvailableAudioFiles()

            return
        }

        do {

            let player =
                try AVAudioPlayer(
                    contentsOf: url
                )

            // Death audio plays ONE TIME.
            player.numberOfLoops = 0

            player.volume = 0.68

            player.prepareToPlay()

            let success =
                player.play()

            effectPlayer = player

            if success {

                print(
                    "💀 DEATH AUDIO:",
                    url.lastPathComponent
                )

            } else {

                print(
                    "❌ DEATH AUDIO FAILED TO START"
                )
            }

        } catch {

            print(
                "❌ DEATH AUDIO ERROR:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Play Looping Music

    private func playMusic(
        named name: String,
        volume: Float
    ) {

        guard musicEnabled else {
            return
        }

        // Don't restart the same song unnecessarily.
        if
            currentTrack == name,
            musicPlayer?.isPlaying == true {

            return
        }

        guard
            let url =
                findAudioFile(
                    named: name
                )
        else {

            print(
                "❌ COULD NOT FIND AUDIO:",
                name
            )

            printAvailableAudioFiles()

            return
        }

        do {

            musicPlayer?.stop()

            let player =
                try AVAudioPlayer(
                    contentsOf: url
                )

            // Menu and gameplay music loop forever.
            player.numberOfLoops = -1

            player.volume = volume

            player.prepareToPlay()

            let success =
                player.play()

            musicPlayer = player
            currentTrack = name

            if success {

                print(
                    "🎵 NOW PLAYING:",
                    url.lastPathComponent
                )

                print(
                    "🔁 LOOPING FOREVER"
                )

            } else {

                print(
                    "❌ MUSIC PLAYER FAILED TO START"
                )
            }

        } catch {

            print(
                "❌ MUSIC PLAYBACK ERROR:",
                error.localizedDescription
            )
        }
    }


    // MARK: - Find Audio

    private func findAudioFile(
        named name: String
    ) -> URL? {

        let supportedExtensions = [
            "mp3",
            "MP3",
            "m4a",
            "M4A",
            "wav",
            "WAV",
            "aac",
            "AAC"
        ]

        // Normal bundle lookup.
        for fileExtension in supportedExtensions {

            if
                let url =
                    Bundle.main.url(
                        forResource: name,
                        withExtension: fileExtension
                    ) {

                print(
                    "✅ FOUND AUDIO:",
                    url.lastPathComponent
                )

                return url
            }
        }


        // Fallback search through the app bundle.

        guard
            let resourceURL =
                Bundle.main.resourceURL
        else {

            return nil
        }

        guard
            let enumerator =
                FileManager.default.enumerator(
                    at: resourceURL,
                    includingPropertiesForKeys: nil
                )
        else {

            return nil
        }

        for case let fileURL as URL in enumerator {

            let baseName =
                fileURL
                    .deletingPathExtension()
                    .lastPathComponent

            let fileExtension =
                fileURL
                    .pathExtension
                    .lowercased()

            if
                baseName == name,
                [
                    "mp3",
                    "m4a",
                    "wav",
                    "aac"
                ]
                .contains(
                    fileExtension
                ) {

                print(
                    "✅ FOUND AUDIO THROUGH BUNDLE SEARCH:",
                    fileURL.lastPathComponent
                )

                return fileURL
            }
        }

        return nil
    }


    // MARK: - Debug Audio Files

    private func printAvailableAudioFiles() {

        guard
            let resourceURL =
                Bundle.main.resourceURL
        else {
            return
        }

        guard
            let enumerator =
                FileManager.default.enumerator(
                    at: resourceURL,
                    includingPropertiesForKeys: nil
                )
        else {
            return
        }

        print(
            "------ AUDIO FILES INSIDE APP ------"
        )

        var foundAny = false

        for case let url as URL in enumerator {

            let ext =
                url.pathExtension
                    .lowercased()

            if
                [
                    "mp3",
                    "m4a",
                    "wav",
                    "aac"
                ]
                .contains(ext) {

                foundAny = true

                print(
                    "🎵",
                    url.lastPathComponent
                )
            }
        }

        if !foundAny {

            print(
                "❌ NO AUDIO FILES ARE INCLUDED IN THE APP BUNDLE."
            )

            print(
                "CHECK TARGET MEMBERSHIP / COPY BUNDLE RESOURCES."
            )
        }

        print(
            "------------------------------------"
        )
    }


    // MARK: - Effects

    private func stopEffect() {

        effectPlayer?.stop()
        effectPlayer = nil
    }


    // MARK: - Pause

    func pauseMusic() {

        musicPlayer?.pause()
        effectPlayer?.pause()
    }


    // MARK: - Resume

    func resumeMusic() {

        guard musicEnabled else {
            return
        }

        musicPlayer?.play()
    }


    // MARK: - Stop

    func stopMusic() {

        musicPlayer?.stop()
        musicPlayer = nil

        effectPlayer?.stop()
        effectPlayer = nil

        currentTrack = nil
    }


    // MARK: - Toggle

    func setMusicEnabled(
        _ enabled: Bool
    ) {

        musicEnabled = enabled

        if enabled {

            musicPlayer?.play()

        } else {

            musicPlayer?.pause()
            effectPlayer?.pause()
        }
    }
}
