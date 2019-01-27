//
//  Theme.swift
//  Countdown
//
//  Created by Josh Cutlan on 27/1/19.
//  Copyright © 2019 Josh Cutlan. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    var darkColour: UIColor!
    var lightColour: UIColor!
    
    init(darkColour: UIColor, lightColour: UIColor) {
        self.darkColour = darkColour
        self.lightColour = lightColour
    }
}
