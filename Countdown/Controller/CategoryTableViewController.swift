//
//  CategoryTableViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 9/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

    // TODO: If you delete a category, Realm might need to update all events of that category (if any) to have the category "None" or "No Category" etc

import UIKit

class CategoryTableViewController: UITableViewController {
    
    var alert: UIAlertController?
    var categories = [String]()
    var selectedCategory: String?
    var selectedIndexPath: IndexPath?
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    weak var delegate: CategoryTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = loadCategories()
        tableView.rowHeight = 44
        doneBarButton.isEnabled = selectedCategory != nil

        if let selectedCategory = self.selectedCategory, let categoryIndex = categories.firstIndex(of: selectedCategory) {
            selectedIndexPath = IndexPath(row: categoryIndex, section: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: UIImage(named: "gradient_blue"))
    }

    // MARK: - Table view data source
    
    func loadCategories() -> [String] {
        categories = defaults.object(forKey: "Categories") as? [String] ?? ["Life", "Work", "School", "Birthday", "Anniversary", "Holiday"]
        return categories
    }
    
    func saveCategories() {
        defaults.set(categories, forKey: "Categories")
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
        
        let addCategoryRow = IndexPath(row: categories.count, section: 0)
        
        // User has tapped the checked row again - so just keep it checked
        if indexPath == selectedIndexPath {
            return
        }
        
        
        if let selectedIndexPath = self.selectedIndexPath, let oldCell = tableView.cellForRow(at: selectedIndexPath) {
            if indexPath != addCategoryRow {
                oldCell.accessoryType = .none
            }
        }
        
        if let newCell = tableView.cellForRow(at: indexPath) {
            if indexPath != addCategoryRow {
                newCell.accessoryType = .checkmark
                selectedIndexPath = indexPath
                selectedCategory = categories[selectedIndexPath!.row]
                delegate?.categoryTableViewController(self, didFinishSelecting: selectedCategory!)
            }
        }
        
        if indexPath == addCategoryRow {
            if let selectedIndexPath = self.selectedIndexPath {
                tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
            }

            addCategory()
        }
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
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                self.selectedIndexPath = newIndexPath
                self.tableView(self.tableView, cellForRowAt: newIndexPath).accessoryType = .checkmark
                self.tableView.endUpdates()
                
                self.saveCategories()
                self.delegate?.categoryTableViewController(self, didFinishSelecting: categoryName)
            }
        }
        doneAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            cancelAction in
            if let selectedIndexPath = self.selectedIndexPath {
                let selectedCell = self.tableView(self.tableView, cellForRowAt: selectedIndexPath)
                selectedCell.accessoryType = .checkmark
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        alert!.addAction(cancelAction)
        alert!.addAction(doneAction)
        alert?.preferredAction = doneAction
        
        present(alert!, animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        delegate?.categoryTableViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        delegate?.categoryTableViewController(self, didFinishSelecting: selectedCategory!)
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
        if indexPath.row <= 5 || indexPath.row == categories.count {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath == selectedIndexPath {
                selectedIndexPath = IndexPath(row: selectedIndexPath!.row - 1, section: 0)
                tableView.cellForRow(at: selectedIndexPath!)!.accessoryType = .checkmark
                selectedCategory = categories[selectedIndexPath!.row]
            }
            categories.remove(at: indexPath.row)
            saveCategories()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
