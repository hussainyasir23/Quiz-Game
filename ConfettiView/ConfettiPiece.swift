//
//  ConfettiPiece.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation
import SwiftUI

struct ConfettiPiece: View {
    
    @State private var isAnimating = false
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    private let randomX: CGFloat
    private let randomRotation: Double
    private let randomScale: CGFloat
    private let randomColor: Color
    
    init() {
        self.randomX = CGFloat.random(in: -1...1)
        self.randomRotation = Double.random(in: 0...360)
        self.randomScale = CGFloat.random(in: 0.5...1.5)
        self.randomColor = colors.randomElement()!
    }
    
    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: 10, height: 10)
            .offset(x: isAnimating ? randomX * UIScreen.main.bounds.width / 2 : 0,
                    y: isAnimating ? UIScreen.main.bounds.height + 100 : -100)
            .rotationEffect(.degrees(isAnimating ? randomRotation * 5 : 0))
            .scaleEffect(isAnimating ? randomScale : 1)
            .animation(.linear(duration: 3), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}
