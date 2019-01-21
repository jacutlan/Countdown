//
//  AddEventViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class AddEventViewController: UITableViewController, UITextFieldDelegate, CategoryTableViewControllerDelegate, IconCollectionViewControllerDelegate {
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var eventIconImageView: UIImageView!
    @IBOutlet weak var eventBackgroundImageView: UIImageView!
    
    var datePickerVisible = false
    
    var eventToEdit: Event?
    
    var eventName: String?
    var eventDate: Date?
    var selectedIconPath: String?
    var selectedCategory: String?
    
    var selectedBackgroundImage: UIImage? {
        didSet {
            eventBackgroundImageView.image = selectedBackgroundImage
            eventBackgroundImageView.layer.borderWidth = 1
            eventBackgroundImageView.layer.cornerRadius = 8
            eventBackgroundImageView.layer.borderColor = UIColor.black.cgColor
            eventBackgroundImageView.contentMode = .scaleAspectFit
            eventBackgroundImageView.clipsToBounds = true
        }
    }
    var backgroundImagePath: String?

    let formatter = DateFormatter()
    let applicationDocumentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    let eventDateRow = IndexPath(row: 3, section: 1)
    let backgroundPickerRow = IndexPath(row: 2, section: 1)

    weak var delegate: AddEditEventViewControllerDelegate?
    
    // MARK: - Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "E, d MMM yyyy"
        
        self.navigationController?.hidesBarsOnSwipe = false
        listenForBackgroundNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.backgroundView?.backgroundColor = UIColor(red: 30.0, green: 144.0, blue: 255.0, alpha: 1.0)
        
        eventIconImageView.layer.borderWidth = 1
        eventIconImageView.layer.cornerRadius = 8
        eventIconImageView.contentMode = .scaleAspectFill
        
        if eventToEdit == nil {
            categoryLabel.text = selectedCategory ?? "Select Category"
            
            if let selectedIcon = self.selectedIconPath {
                eventIconImageView.layer.borderColor = UIColor.black.cgColor
                eventIconImageView.image = UIImage(named: selectedIcon)?.imageWithInsets(insetDimension: 8)
            } else {
                eventIconImageView.layer.borderColor = UIColor.red.cgColor
                eventIconImageView.image = UIImage()    // New events will have no icon to begin with!
            }
            
            if let eventDate = self.eventDate {
                eventDateLabel.text = formatter.string(from: eventDate)
            } else {
                eventDateLabel.text = "Select Date"
            }
            
            if eventNameTextField.text!.isEmpty {
                eventNameTextField.becomeFirstResponder()
            }
            
        } else {
            eventNameTextField.text = eventName
            eventDateLabel.text = formatter.string(from: eventDate!)
            categoryLabel.text = selectedCategory
            eventIconImageView.image = UIImage(named: selectedIconPath!)?.imageWithInsets(insetDimension: 8)
            
            if let backgroundImagePath = self.backgroundImagePath {
                let imageURL = URL(string: backgroundImagePath)
                do {
                    let photoData = try Data(contentsOf: imageURL!)
                    selectedBackgroundImage = UIImage(data: photoData)
                } catch {
                    print("Error loading photo: \(error)")
                }
                
                
                doneBarButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        hideDatePicker()
        
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryTableViewController
            controller.delegate = self
            controller.selectedCategory = selectedCategory
        }
        
        if segue.identifier == "SelectIcon" {
            let controller = segue.destination as! IconCollectionViewController
            controller.delegate = self
            controller.selectedIcon = selectedIconPath ?? nil
        }
    }
    
    // MARK: - Actions
    @IBAction func cancel() {        eventNameTextField.resignFirstResponder()
        delegate?.addEditEventViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        /* TODO: This really feels like it should be in the EventManager...but I couldn't figure out how to do it yet */
        if let realmEditEvent = eventToEdit {
            let realm = try! Realm()
            
            do {
                try realm.write {
                    realmEditEvent.name = eventNameTextField.text!
                    realmEditEvent.date = eventDate!
                    realmEditEvent.category = selectedCategory!
                    realmEditEvent.iconName = selectedIconPath!
                    
                    if let selectedImage = selectedBackgroundImage {
                        let fileName = "Photo-\(realmEditEvent.eventID).jpg"
                        let photoPath = applicationDocumentsDirectory.appendingPathComponent(fileName)
                        
                        if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                            do {
                                try data.write(to: photoPath)
                            } catch {
                                print("Error saving the background photo: \(error)")
                            }
                        }
                        
                        realmEditEvent.backgroundImagePath = photoPath.absoluteString
                    }
                }
            } catch {
                print("*** Error: " + error.localizedDescription)
            }

            eventNameTextField.resignFirstResponder()            
            delegate?.addEditEventViewController(self, didFinishUpdating: eventToEdit!)
        } else {
            if let date = eventDate, let icon = selectedIconPath, let category = selectedCategory {
                let newEvent = Event()
                
                newEvent.name = eventNameTextField.text!
                newEvent.date = date
                newEvent.category = category
                newEvent.iconName = icon
                
                // MARK: Save the background image
                if let selectedImage = selectedBackgroundImage {
                    let filename = "Photo-\(newEvent.eventID).jpg"
                    let photoPath = applicationDocumentsDirectory.appendingPathComponent(filename)
                    
                    print("**** PHOTO PATH: \(photoPath)")
                    
                    if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                        do {
                            try data.write(to: photoPath)
                        } catch {
                            print("Error saving the background photo: \(error)")
                        }
                    }
                    
                    newEvent.backgroundImagePath = photoPath.absoluteString
                }
                delegate?.addEditEventDetailViewController(self, didFinishAdding: newEvent)
            } else {
                // Missing information = present an alert
                let alertController = UIAlertController(title: "Missing Information", message: "Oops! Please make sure you've entered a category, date and icon.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "My Bad!", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - DatePicker
    
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDatePicker = IndexPath(row: 4, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        datePicker.date = eventToEdit?.date ?? Date()
        
        if let eventDate = self.eventDate {
            eventDateLabel.text = formatter.string(from: eventDate)
        } else {
            eventDate = Date().midnight()
            eventDateLabel.text = formatter.string(from: Date())
        }

    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 4, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        eventDate = datePicker.date.midnight()
        eventDateLabel.text = formatter.string(from: eventDate!)
    }

    // MARK: - TableView Overrides
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventNameTextField.resignFirstResponder()
        
        switch indexPath {
            case eventDateRow:
                if !datePickerVisible {
                    showDatePicker()
                } else {
                    hideDatePicker()
                }
            case backgroundPickerRow:
                pickPhoto()
            default:
                return
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 4 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 5
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 4 {          // The row of the Date Picker
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // Customise the tableview header colour
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }

    // Something I learned from iOS apprentice - necessary for the date picker toggling to work
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 4 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!

        if let stringRange = Range(range, in:oldText) {
            let newText = oldText.replacingCharacters(in: stringRange, with: string)
            doneBarButton.isEnabled = !newText.isEmpty
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    // MARK: - CategoryTableViewControllerDelegate
    
    func categoryTableViewControllerDidCancel(_ controller: CategoryTableViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func categoryTableViewController(_ controller: CategoryTableViewController, didFinishSelecting category: String) {
        // set the event category
        selectedCategory = category
        categoryLabel.text = category
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - IconCollectionViewControllerDelegate
    func iconCollectionViewControllerDidCancel(_ controller: IconCollectionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func iconCollectionViewController(_ controller: IconCollectionViewController, didFinishSelecting icon: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.navigationController?.popViewController(animated: true)
        }
        
        selectedIconPath = icon
        eventIconImageView.image = UIImage(named: icon)
    }
}

extension AddEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let photoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera()
        })
        alert.addAction(photoAction)
        
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(libraryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: {
            self.selectedBackgroundImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            UIView.transition(with: self.eventBackgroundImageView, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                self.eventBackgroundImageView.image = self.selectedBackgroundImage
            }, completion: nil)
        })
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Called if the photo picker action sheet is open when the user goes to their home screen...so that when they come back there isn't an action sheet staring them in the face
    func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                
               weakSelf.eventNameTextField.resignFirstResponder()
            }
        }
    }
}
