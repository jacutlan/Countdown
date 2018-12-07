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
    
    weak var delegate: EventDetailViewControllerDelegate?
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        eventNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate?.eventDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        // TODO: editing code goes here
        
        let event = Event(eventName: eventNameTextField.text!, eventDate: Date(), eventCategory: .Life)
        eventNameTextField.resignFirstResponder()
        delegate?.eventDetailViewController(self, didFinishAdding: event)
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
