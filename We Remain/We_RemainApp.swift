import SwiftUI

@main
struct We_RemainApp: App {

    @StateObject
    private var progress =
        GameProgress.shared

    @State
    private var finishedLoading =
        false

    var body: some Scene {

        WindowGroup {

            ZStack {

                if finishedLoading {

                    ContentView()
                        .environmentObject(
                            progress
                        )
                        .transition(
                            .opacity
                        )

                } else {

                    LoadingView(
                        finishedLoading:
                            $finishedLoading
                    )
                    .transition(
                        .opacity
                    )
                }
            }
            .animation(
                .easeInOut(
                    duration: 0.30
                ),
                value:
                    finishedLoading
            )
            .preferredColorScheme(
                .dark
            )
        }
    }
}
