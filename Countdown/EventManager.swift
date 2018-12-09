import UIKit
import RealmSwift

class EventManager: NSObject {
    static let shared = EventManager()
    
    private override init() {
        super.init()
    }
    
    func addEvent(_ newEvent: Event) {
        let realm = try! Realm()

        // TODO: something to do with MainEvent here
        
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
        return events.map({$0})
    }
    
    func updateEvent(_ event: Event, newName: String, newDate: Date) {
        let realm = try! Realm()
        
        do {
            try realm.write {
                event.name = newName
                event.date = newDate
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

