//
//  ConfettiView.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation
import SwiftUI

struct ConfettiView: View {
    
    @State private var opacity: Double = 1.0
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                ConfettiPiece()
            }
        }
        .opacity(opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 0.5
                }
                onCompletion()
            }
        }
    }
}
