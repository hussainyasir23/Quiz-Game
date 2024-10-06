//
//  FeedbackManager.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import UIKit

final class FeedbackManager {
    
    private(set) static var isHapticsEnabled: Bool = true
    
    static func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
    }
    
    static func triggerNotificationFeedback(of type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else {
            return
        }
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(type)
    }
    
    static func triggerImpactFeedback(of style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else {
            return
        }
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.impactOccurred()
    }
}
