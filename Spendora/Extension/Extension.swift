//
//  Extension.swift
//  Spendora
//
//  Created by Sushant Dhakal on 2026-01-17.
//

import Foundation
import SwiftUI

struct PulseEffect: ViewModifier {
    @State private var scale: CGFloat = 1
   
    func body(content: Content) -> some View {
        content
            
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.03
                }
            }
            
    }
}

extension View {
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
}

