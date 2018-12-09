//
//  AddEventViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

protocol EventDetailViewControllerDelegate: class {
    func eventDetailViewControllerDidCancel(_ controller: AddEventViewController)
    func eventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event)
    func eventDetailViewController(_ controller: AddEventViewController, didFinishEditing event: Event)
}

class AddEventViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var mainEventToggle: UISwitch!
    @IBOutlet var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    var datePickerVisible = false
    var eventDate = Date()
    
    weak var delegate: EventDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventNameTextField.becomeFirstResponder()
        mainEventToggle.isOn = false
        updateEventDateLabel()
    }
    
    // MARK: - Actions
    @IBAction func cancel() {
        eventNameTextField.resignFirstResponder()
        delegate?.eventDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        // TODO: editing code goes here
        
        //let event = Event(eventName: eventNameTextField.text!, eventDate: eventDate, eventCategory: Event.Category.Life, mainEvent: mainEventToggle.isOn)
        let event = Event()
        event.name = eventNameTextField.text!
        event.date = eventDate
        event.category = .Birthday
        eventNameTextField.resignFirstResponder()
        
        delegate?.eventDetailViewController(self, didFinishAdding: event)
    }
    
    func showDatePicker() {
        datePickerVisible = true
        print("Datepicker is now visible")
        let indexPathDatePicker = IndexPath(row: 3, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        eventDate = datePicker.date
        updateEventDateLabel()
    }
    
    func updateEventDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        eventDateLabel.text = formatter.string(from: eventDate)
    }
    
    // MARK: - TableView Overrides
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventNameTextField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 2 {
            showDatePicker()
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 2 {         // Row of the Event Date cell
            return indexPath
        } else {
            return nil
        }
    }
    
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
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
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
}
