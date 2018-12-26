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
    
    var newEvent = Event()
    var eventToEdit: Event?
    var eventDate = Date()
    var eventIcon = "icons8-birthday"

    let formatter = DateFormatter()

    
    weak var delegate: AddEditEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        formatter.dateFormat = "E, d MMM yyyy"
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "3"))

        if let eventToEdit = eventToEdit {
            eventDate = eventToEdit.date
            
            eventNameTextField.text = eventToEdit.name
            categoryLabel.text = eventToEdit.category
            eventDateLabel.text = formatter.string(from: eventToEdit.date)
            eventIconImageView.image = eventToEdit.icon
            doneBarButton.isEnabled = true
        }

        if eventToEdit == nil {
            categoryLabel.text = newEvent.category
            eventNameTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryTableViewController
            controller.delegate = self
            controller.selectedCategory = newEvent.category
        }
        
        if segue.identifier == "SelectIcon" {
            let controller = segue.destination as! IconCollectionViewController
            controller.delegate = self
            controller.selectedIcon = newEvent.iconName
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
                    realmEditEvent.date = eventDate
                    realmEditEvent.category = categoryLabel.text!
                    realmEditEvent.iconName = eventIcon
                }
            } catch {
                print("*** Error: " + error.localizedDescription)
            }

            eventNameTextField.resignFirstResponder()            
            delegate?.addEditEventViewController(self, didFinishUpdating: eventToEdit!)
        } else {
            newEvent.name = eventNameTextField.text!
            newEvent.date = eventDate
            newEvent.iconName = eventIcon
            eventNameTextField.resignFirstResponder()
        
            delegate?.addEditEventDetailViewController(self, didFinishAdding: newEvent)
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
        eventDateLabel.text = formatter.string(from: eventDate)
    }

    // MARK: - TableView Overrides
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventNameTextField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 2 {
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
    
    /*override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 1 && indexPath.row == 2) || (indexPath.section == 1 && indexPath.row == 0) { // Row of the Event Date + Category cells
            return indexPath
        } else {
            return nil
        }
    }*/
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 3 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK: - TextFieldDelegate
    // TODO: App cannot handle deletion of emojis with 3rd party keyboard. Apple keyboard works fine. WHAT THE HELL!
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
        newEvent.category = category
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - IconCollectionViewControllerDelegate
    
    func iconCollectionViewControllerDidCancel(_ controller: IconCollectionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func iconCollectionViewController(_ controller: IconCollectionViewController, didFinishSelecting icon: String) {
        eventIcon = icon
        
        eventIconImageView.image = UIImage(named: icon)
        
        if eventToEdit != nil {
            controller.navigationController?.popToRootViewController(animated: true)
        } else {
            controller.navigationController?.popViewController(animated: true)
        }
    }
}
