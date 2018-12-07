//
//  ViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EventDetailViewControllerDelegate {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var mainEventLabel: UILabel!
    @IBOutlet weak var mainEventDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dataModel = DataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateLabels()
    }

    func updateLabels() {
        daysRemainingLabel.isHidden = dataModel.events.isEmpty
        mainEventDateLabel.isHidden = dataModel.events.isEmpty
        mainEventLabel.isHidden = dataModel.events.isEmpty
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEvent" {
            let controller = segue.destination as! AddEventViewController
            controller.delegate = self
        }
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        if dataModel.events.isEmpty {
            print("cellForRow: Events[] is empty")
            cell.textLabel?.text = "No events found. Add one now!"
            cell.accessoryType = .disclosureIndicator
        } else {
            print("cellForRow: Events[] is NOT empty")
            let event = dataModel.events[indexPath.row]
            cell.textLabel?.text = event.name
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (dataModel.events.isEmpty) {
            performSegue(withIdentifier: "AddEvent", sender: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataModel.events.isEmpty {
            print("numberOfRows: Events[] is empty - returning 1 row")
            return 1
        } else {
            return dataModel.events.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - EventDetailViewControllerDelegate
    
    func eventDetailViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func eventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {
        let newRowIndex = dataModel.events.count
        
        if dataModel.events.isEmpty {
            let initialIndexPath = IndexPath(row: 0, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [initialIndexPath], with: .automatic)
            dataModel.events.append(event)
            tableView.insertRows(at: [initialIndexPath], with: .automatic)
            tableView.endUpdates()
        } else {
            dataModel.events.append(event)
            let indexPath = IndexPath(row: newRowIndex, section: 0)
            let indexPaths = [indexPath]
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func eventDetailViewController(_ controller: AddEventViewController, didFinishEditing event: Event) {

        /** TODO: editing
         if let index = dataModel.lists.index(of: checklist) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel!.text = checklist.name
            }
         }
            navigationController?.popViewController(animated: true) */
      }
}

