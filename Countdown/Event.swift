import UIKit


class Event {
    var name = ""
    var date = Date()
    var category = Category.Life
    var mainEvent: Bool
    
    enum Category {
        case Travel, Life, Work, School
    }
    
    init(eventName: String, eventDate: Date, eventCategory: Category, mainEvent: Bool) {
        self.name = eventName
        self.date = eventDate
        self.category = eventCategory
        self.mainEvent = mainEvent
    }
}
