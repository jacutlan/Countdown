//
//  CategoryTableViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 9/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

    // TODO: If you delete a category, Realm might need to update all events of that category (if any) to have the category "None" or "No Category" etc

import UIKit

protocol CategoryTableViewControllerDelegate: class {
    func categoryTableViewControllerDidCancel(_ controller: CategoryTableViewController)
    func categoryTableViewController(_ controller: CategoryTableViewController, didFinishSelecting category: String)
}

class CategoryTableViewController: UITableViewController {
    
    var alert: UIAlertController?
    var categories = ["Life", "Birthdays", "Work", "School", "Deadline", "Travel"]
    var selectedCategory = "Work" //String!
    var delegate: CategoryTableViewControllerDelegate?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndexPath = IndexPath(row: categories.firstIndex(of: selectedCategory)!, section: 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count + 1
    }

    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // User has tapped the checked row again - so just keep it checked
        if indexPath == selectedIndexPath {
            return
        }
        
        if let newCell = tableView.cellForRow(at: indexPath), newCell.accessoryType == .none {
            print("New cell! Accessory type is NONE")
            newCell.accessoryType = .checkmark
        }
        
        if let oldCell = tableView.cellForRow(at: selectedIndexPath!), oldCell.accessoryType == .checkmark {
            print("Old cell! Accessory type was CHECKMARK!")
            oldCell.accessoryType = .none
        }
        
        selectedIndexPath = indexPath
        
        // Whatever else needs to happen with the Category goes here
    }
    
    // MARK: - Actions
    
    @IBAction func addCategory() {
        alert = UIAlertController(title: "New Category",
                                      message: "Enter a name for your new category:",
                                      preferredStyle: .alert)
        alert!.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Name of the Category"
            textfield.textColor = UIColor.blue
            textfield.clearButtonMode = UITextField.ViewMode.whileEditing
            textfield.borderStyle = UITextField.BorderStyle.roundedRect
            textfield.addTarget(self, action: #selector(self.textDidChange(_:)), for: UIControl.Event.editingChanged)
        })
        
        let doneAction = UIAlertAction(title: "Done", style: .default) {
            doneAction in
            self.delegate?.categoryTableViewController(self, didFinishSelecting: "Birthday")
        }
        doneAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert!.addAction(cancelAction)
        alert!.addAction(doneAction)
        
        present(alert!, animated: true, completion: nil)
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 0 {
            alert?.actions[1].isEnabled = textField.text!.count > 0
        } else {
            alert?.actions[1].isEnabled = false
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == categories.count {
            cell.textLabel?.text = "ADD BUTTON WILL GO HERE"
            cell.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            cell.textLabel?.text = categories[indexPath.row]
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
