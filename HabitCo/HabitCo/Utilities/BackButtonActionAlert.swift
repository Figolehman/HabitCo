//
//  BackAlert.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/05/24.
//

import Foundation

class BackButtonActionAlert {

    static let shared = BackButtonActionAlert()

    var backAction: () -> Void = {}

    private init() {

    }


}

