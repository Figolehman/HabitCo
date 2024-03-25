//
//  Color+Extension.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import Foundation
import SwiftUI


// MARK: - Color Palette
extension Color {
    enum AppColors: String {
        case danger
        case primary
        case primary2
        case primary3
        case secondary
        case neutral
        case neutral2
        case neutral3
        
        
        // Elevation Effect
        case shadow
    }
    
    static func getAppColor(_ appColor: AppColors) -> Color {
        return Color("\(appColor.rawValue)")
    }
}

// MARK: - Filter Colors
extension Color {
    enum FilterColors: String, CaseIterable {
        case aluminium
        case lavender
        case mushroom
        case glacier
        case wisteria
        case blush
        case turquoise
        case roseGold
        case peach
        case cornflower
        case blossom
        case goldenrod
    }
}
