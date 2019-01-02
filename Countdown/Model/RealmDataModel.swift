//
//  DataModel.swift
//  Countdown
//
//  Created by Josh Cutlan on 4/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Event: Object {
    let formatter = DateFormatter()
    
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    @objc dynamic var category = "Life" // Default category
    @objc dynamic var iconName = "icons8-birthday" // Default icon
    @objc dynamic var eventID = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "eventID"
    }
   
    // Return the number of days until/since the event's date
    var dayCount: Int {
        get {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: date)
            let days = components.day
            let hours = components.hour
            let minutes = components.minute
            
            if days! >= 0 && hours! > 0 && minutes! > 0 {
                return days! + 1
            } else {
                return days!
            }
        }
    }
    
    var icon: UIImage {
        get {
            if let image = UIImage(named: iconName) {
                return image
            } else {
                return UIImage()
            }
        }
    }
}
