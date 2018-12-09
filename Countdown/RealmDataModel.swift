//
//  DataModel.swift
//  Countdown
//
//  Created by Josh Cutlan on 4/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import Foundation
import RealmSwift

class Event:Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    var category = Category.Life
    var mainEvent = false
    
    enum Category {
        case Travel, Life, Work, School, Anniversary, Birthday, Holiday, Deadline
    }
}
