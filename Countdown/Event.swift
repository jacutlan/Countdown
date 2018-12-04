import UIKit


class Event {
    var name = ""
    var date = Date()
    var category = Category.Life
    
    enum Category {
        case Travel, Life, Work, School
    }
    
    init(eventName: String, eventDate: Date, eventCategory: Category) {
        self.name = eventName
        self.date = eventDate
        self.category = eventCategory
    }
}
