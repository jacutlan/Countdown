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
    
    func getEvents() -> [Event]? {
        let realm = try! Realm()

        let events = realm.objects(Event.self)
        return events.map {$0}
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
    
    func filterEvents(byCategory category: String) -> [Event] {
        let realm = try! Realm()
        
        let filteredEvents = realm.objects(Event.self).filter("category = %@", category)
        return filteredEvents.map {$0}
    }
}

