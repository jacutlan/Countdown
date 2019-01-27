import Foundation
import UIKit

protocol AddEditEventViewControllerDelegate: class {
    func addEditEventViewControllerDidCancel(_ controller: AddEventViewController)
    func addEditEventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event)
    func addEditEventViewController(_ controller: AddEventViewController, didFinishUpdating event: Event)
}

protocol CategoryTableViewControllerDelegate: class {
    func categoryTableViewControllerDidCancel(_ controller: CategoryTableViewController)
    func categoryTableViewController(_ controller: CategoryTableViewController, didFinishSelecting category: String)
}

protocol IconCollectionViewControllerDelegate: class {
    func iconCollectionViewControllerDidCancel(_ controller: IconCollectionViewController)
    func iconCollectionViewController(_ controller: IconCollectionViewController, didFinishSelecting icon: String)
}

protocol EventDetailViewControllerDelegate: class {
    func eventDetailViewControllerDismissed(_ controller: EventDetailViewController)
    func eventDetailViewController(_ controller: EventDetailViewController, editing editingEvent: Event)
}

protocol ThemeViewControllerDelegate: class {
    func themeViewControllerDismissed(_ controller: ThemeViewController)
    func themeViewController(_ controller: ThemeViewController, didFinishSelecting theme: Theme)
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
