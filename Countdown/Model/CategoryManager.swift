//
//  CategoryManager.swift
//  Countdown
//
//  Created by Josh Cutlan on 11/1/19.
//  Copyright © 2019 Josh Cutlan. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard

class CategoryManager {    
    class func loadCategories() -> [String] {
       return defaults.object(forKey: "Categories") as? [String] ?? ["Life", "Work", "School", "Birthday", "Anniversary", "Holiday"]
    }
    
    class func saveCategories(categories: [String]) {
        defaults.set(categories, forKey: "Categories")
    }
}


