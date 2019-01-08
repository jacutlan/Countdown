//
//  AddEventViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import RealmSwift

class AddEventViewController: UITableViewController, UITextFieldDelegate, CategoryTableViewControllerDelegate, IconCollectionViewControllerDelegate {
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var eventIconImageView: UIImageView!
    
    var datePickerVisible = false
    
    var eventToEdit: Event?
    
    var eventName: String?
    var eventDate: Date?
    var selectedIcon: String?
    var selectedCategory: String?

    let formatter = DateFormatter()
    let eventDateRow = IndexPath(row: 2, section: 1)

    weak var delegate: AddEditEventViewControllerDelegate?
    
    // MARK: - Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "gradient_blue"))
        formatter.dateFormat = "E, d MMM yyyy"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eventIconImageView.layer.borderWidth = 1
        eventIconImageView.layer.borderColor = UIColor.black.cgColor
        eventIconImageView.layer.cornerRadius = 8
        eventIconImageView.contentMode = .scaleAspectFill
        
        if eventToEdit == nil {
            categoryLabel.text = selectedCategory ?? "Select Category"
            
            if let selectedIcon = self.selectedIcon {
                eventIconImageView.image = UIImage(named: selectedIcon)?.imageWithInsets(insetDimension: 8)
            } else {
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
            eventIconImageView.image = UIImage(named: selectedIcon!)?.imageWithInsets(insetDimension: 8)
            
            doneBarButton.isEnabled = true
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
            controller.selectedIcon = selectedIcon ?? nil
        }
    }
    
    // MARK: - Actions
    @IBAction func cancel() {
        eventNameTextField.resignFirstResponder()
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
                    realmEditEvent.iconName = selectedIcon!
                }
            } catch {
                print("*** Error: " + error.localizedDescription)
            }

            eventNameTextField.resignFirstResponder()            
            delegate?.addEditEventViewController(self, didFinishUpdating: eventToEdit!)
        } else {
            if let date = eventDate, let icon = selectedIcon, let category = selectedCategory {
                let newEvent = Event()
                
                newEvent.name = eventNameTextField.text!
                newEvent.date = date
                newEvent.category = category
                newEvent.iconName = icon
                delegate?.addEditEventDetailViewController(self, didFinishAdding: newEvent)
            } else {
                print("SOMETHING IS MISSING!")
                return
            }
        }
    }
    
    // MARK: - DatePicker
    
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDatePicker = IndexPath(row: 3, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        datePicker.date = eventToEdit?.date ?? Date()
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 3, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        eventDate = datePicker.date
        eventDateLabel.text = formatter.string(from: eventDate!)
    }

    // MARK: - TableView Overrides
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventNameTextField.resignFirstResponder()
        
        if indexPath == eventDateRow {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 3 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 4
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 3 {          // The row of the Date Picker
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
        if indexPath.section == 1 && indexPath.row == 3 {
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
        
        selectedIcon = icon
        eventIconImageView.image = UIImage(named: icon)
    }
}
