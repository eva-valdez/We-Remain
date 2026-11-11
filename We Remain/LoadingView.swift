import SwiftUI

struct LoadingView: View {

    @Binding
    var finishedLoading: Bool

    @State
    private var progress: Double = 0

    @State
    private var loadingMessage =
        "ENTERING THE CITY..."

    @State
    private var fadeOut =
        false


    var body: some View {

        ZStack {

            // MARK: - Background

            RuinedCityMenuBackground()
                .ignoresSafeArea()


            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.50),
                    Color.black.opacity(0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()


            RadialGradient(
                colors: [
                    Color.green.opacity(0.10),
                    Color.clear
                ],
                center: .center,
                startRadius: 25,
                endRadius: 300
            )
            .ignoresSafeArea()


            // MARK: - Loading Content

            VStack(
                spacing: 18
            ) {

                Spacer()


                // MARK: - Full Resolution App Icon

                Image("Loading_AppIcon")
                    .resizable()

                    // This is regular artwork rather than
                    // an in-game pixel sprite, so high-quality
                    // interpolation is correct here.
                    .interpolation(.high)

                    .antialiased(true)

                    .scaledToFit()

                    .frame(
                        width: 280,
                        height: 280
                    )

                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 48,
                            style: .continuous
                        )
                    )

                    .overlay {

                        RoundedRectangle(
                            cornerRadius: 48,
                            style: .continuous
                        )
                        .stroke(
                            Color.white.opacity(0.14),
                            lineWidth: 1
                        )
                    }

                    .shadow(
                        color:
                            Color.black.opacity(0.70),
                        radius: 18,
                        x: 0,
                        y: 10
                    )


                // MARK: - Title

                VStack(
                    spacing: 5
                ) {

                    Text("WE REMAIN")
                        .font(
                            .system(
                                size: 37,
                                weight: .black,
                                design: .monospaced
                            )
                        )
                        .foregroundColor(
                            Color(
                                red: 0.66,
                                green: 1.0,
                                blue: 0.36
                            )
                        )


                    Text(
                        "THE CITY IS DEAD. KEEP MOVING."
                    )
                    .font(
                        .system(
                            size: 8,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .tracking(1.4)
                    .foregroundColor(
                        .white.opacity(0.62)
                    )
                }


                // MARK: - Progress Bar

                VStack(
                    spacing: 9
                ) {

                    GeometryReader { geometry in

                        ZStack(
                            alignment: .leading
                        ) {

                            RoundedRectangle(
                                cornerRadius: 4
                            )
                            .fill(
                                Color.black.opacity(0.82)
                            )


                            RoundedRectangle(
                                cornerRadius: 4
                            )
                            .fill(
                                Color.green
                            )
                            .frame(
                                width:
                                    geometry.size.width
                                    * progress
                            )
                        }
                    }
                    .frame(
                        height: 13
                    )

                    .overlay {

                        RoundedRectangle(
                            cornerRadius: 4
                        )
                        .stroke(
                            Color.white.opacity(0.30),
                            lineWidth: 1
                        )
                    }


                    HStack {

                        Text(
                            loadingMessage
                        )


                        Spacer()


                        Text(
                            "\(Int(progress * 100))%"
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
                        .white.opacity(0.72)
                    )
                }
                .frame(
                    maxWidth: 295
                )


                Spacer()


                Text(
                    "SURVIVE • SCAVENGE • RUN"
                )
                .font(
                    .system(
                        size: 8,
                        weight: .black,
                        design: .monospaced
                    )
                )
                .tracking(2)
                .foregroundColor(
                    .white.opacity(0.32)
                )
                .padding(
                    .bottom,
                    28
                )
            }
            .padding(
                .horizontal,
                24
            )
            .opacity(
                fadeOut
                ? 0
                : 1
            )
        }
        .onAppear {

            AudioManager.shared
                .playMenuMusic()

            runLoadingSequence()
        }
    }


    // MARK: - Loading Sequence

    private func runLoadingSequence() {

        progress =
            0


        loadingMessage =
            "ENTERING THE CITY..."


        withAnimation(
            .linear(
                duration: 0.35
            )
        ) {

            progress =
                0.20
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.35
        ) {

            loadingMessage =
                "SCANNING THE STREETS..."


            withAnimation(
                .linear(
                    duration: 0.40
                )
            ) {

                progress =
                    0.45
            }
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.80
        ) {

            loadingMessage =
                "TRACKING THE INFECTED..."


            withAnimation(
                .linear(
                    duration: 0.45
                )
            ) {

                progress =
                    0.72
            }
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.25
        ) {

            loadingMessage =
                "PREPARING YOUR RUN..."


            withAnimation(
                .linear(
                    duration: 0.40
                )
            ) {

                progress =
                    0.93
            }
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.65
        ) {

            loadingMessage =
                "RUN."


            withAnimation(
                .linear(
                    duration: 0.25
                )
            ) {

                progress =
                    1.0
            }
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.05
        ) {

            withAnimation(
                .easeOut(
                    duration: 0.25
                )
            ) {

                fadeOut =
                    true
            }
        }


        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2.35
        ) {

            finishedLoading =
                true
        }
    }
}
