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
    var categories = [String]()
    var selectedCategory: String!
    var selectedIndexPath: IndexPath?
    
    weak var delegate: CategoryTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = readCategoriesPropertyList()
        
        if let categoryIndex = categories.firstIndex(of: selectedCategory) {
            selectedIndexPath = IndexPath(row: categoryIndex, section: 0)
        } else {
            selectedIndexPath = IndexPath(row: 0, section: 0)
        }
    }

    // MARK: - Table view data source
    
    func readCategoriesPropertyList() -> [String] {
        if let path = Bundle.main.path(forResource: "Categories", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path), let categories = dict["Categories"] {
            print(categories)
            return categories as! [String]
        } else {
            return ["ERROR!"]
        }
    }
    
    func updateCategoriesPropertyList() {
        if let path = Bundle.main.path(forResource: "Categories", ofType: "plist"), let dict = NSMutableDictionary(contentsOfFile: path) {
            print("UpdateCategories: dict currently contains: \(dict)")
            dict["Categories"] = categories
            print("After the update, it now contains \(dict)")
            if dict.write(toFile: path, atomically: true) {
                print("Successfully wrote to the plist")
            } else {
                print("I DONE FUCKED UP")
            }
        }
    }

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
        
        // User tapped a different category to what was selected previously. Check this new category instead
        if let newCell = tableView.cellForRow(at: indexPath), newCell.accessoryType == .none, indexPath.row != categories.count {
            newCell.accessoryType = .checkmark
            delegate?.categoryTableViewController(self, didFinishSelecting: categories[indexPath.row])
        }
        
        // Remove the checkmark from the previously selected category
        if let oldCell = tableView.cellForRow(at: selectedIndexPath!), oldCell.accessoryType == .checkmark, indexPath.row != categories.count {
            oldCell.accessoryType = .none
        }
        
        // Update the selectedIndexPath value to reflect the new one
        if indexPath.row != categories.count {
            selectedIndexPath = indexPath
        } else {
            // User tapped the Add New Category row
            addCategory()
        }
        
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
            textfield.autocapitalizationType = .words
            textfield.addTarget(self, action: #selector(self.textDidChange(_:)), for: UIControl.Event.editingChanged)
        })
        
        let doneAction = UIAlertAction(title: "Done", style: .default) {
            doneAction in
            if let textField = self.alert?.textFields?[0], let categoryName = textField.text {
                let newIndexPath = IndexPath(row: self.categories.count, section: 0)
                self.categories.append(categoryName)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                self.updateCategoriesPropertyList()
                self.delegate?.categoryTableViewController(self, didFinishSelecting: categoryName)
            }
        }
        doneAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert!.addAction(cancelAction)
        alert!.addAction(doneAction)
        alert?.preferredAction = doneAction
        
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
        if indexPath.row == categories.count {  // Add new category row
            let addCategoryCell = tableView.dequeueReusableCell(withIdentifier: "addCategoryCell", for: indexPath)
            return addCategoryCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            if indexPath == selectedIndexPath { // Row of the selected category
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            cell.textLabel?.text = categories[indexPath.row] // Every other normal category row
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row <= 5 {
            return false
        } else {
            return true
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
}
