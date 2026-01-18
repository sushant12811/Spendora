//
//  SpendoraApp.swift
//  Spendora
//
//  Created by Sushant Dhakal on 2025-10-17
//

import Foundation
import SwiftData
import SwiftUI

@main
struct SpendoraApp: App {
    @State private var showLunch: Bool = true
    @Environment(\.verticalSizeClass) var vSize

    var body: some Scene {
        WindowGroup {
            if showLunch {
                ZStack {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .containerRelativeFrame(
                            .horizontal,
                            count: 10,
                            span: 2,
                            spacing: 0
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showLunch = false
                        }
                    }
                }
            } else {

                ContentView()
                    .tint(.primary)

            }

        }
        .modelContainer(for: ExpenseModel.self)
    }
}
