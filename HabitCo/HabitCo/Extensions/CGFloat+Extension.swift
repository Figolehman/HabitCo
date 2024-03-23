//
//  CGFloat+Extension.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import Foundation
import SwiftUI

extension CGFloat {
    
    static func getResponsiveWidth(_ width: CGFloat) -> CGFloat {
        return width * ScreenSize.width / ScreenSize.baseWidth
    }
    
    static func getResponsiveHeight(_ height: CGFloat) -> CGFloat {
        return height * ScreenSize.height / ScreenSize.baseHeight
    }
    
}
