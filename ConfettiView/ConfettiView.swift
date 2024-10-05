//
//  ConfettiView.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation
import SwiftUI

struct ConfettiView: View {
    
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                ConfettiPiece()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onCompletion()
            }
        }
    }
}
