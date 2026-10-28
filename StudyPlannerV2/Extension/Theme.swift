//
//  Theme.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 14/10/2026.
//

import SwiftUI

enum Theme {
    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let onAccent = Color(.white)
    // Darker indigo for filled cards, so white text stays readable in dark mode.
    static let accentFill = Color(red: 88 / 255, green: 86 / 255, blue: 214 / 255)
    
    static let corner: CGFloat = 18
    static let padding: CGFloat = 16
}
