//
//  FeedbackManager.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import UIKit

final class FeedbackManager {
    
    static func triggerNotificationFeedback(of type: UINotificationFeedbackGenerator.FeedbackType) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(type)
    }
    
    static func triggerImpactFeedback(of style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.impactOccurred()
    }
}
