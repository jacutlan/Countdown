import UIKit
import RealmSwift

class EventManager: NSObject {
    static let shared = EventManager()
    
    private override init() {
        super.init()
    }
    
    func addEvent(_ newEvent: Event) {
        let realm = try! Realm()

        do {
            try realm.write {
                realm.add(newEvent)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCurrentEvents(forCategory category: String = "") -> [Event]? {
        let realm = try! Realm()
        
        if category != "" {
            let events = realm.objects(Event.self).filter("category = %@ and date >= %@", category, Date().midnight())
            return events.map {$0}
        } else {
            let events = realm.objects(Event.self).filter("date >= %@", Date().midnight())
            return events.map {$0}
        }
    }
    
    func getPastEvents() -> [Event]? {
        let realm = try! Realm()
        
        let pastEvents = realm.objects(Event.self).filter("date < %@", Date().midnight())
        return pastEvents.map {$0}
    }
    
    func updateEvent(_ event: Event) {
        let realm = try! Realm()

        do {
            try realm.write {
                realm.add(event, update: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteEvent(_ event: Event) {
        let realm = try! Realm()
        
        do {
            try realm.write {
                realm.delete(event)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Helper function to set all new dates to midnight of that day
extension Date {
    func midnight() -> Date {
        let cal = Calendar(identifier: .gregorian)
        let midnight = cal.startOfDay(for: self)
        
        return midnight
    }
}
