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
    
    let formatter = DateFormatter()
    var eventsArray = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("**** HomeDirectory: " + NSHomeDirectory())
        
        navigationController?.navigationBar.prefersLargeTitles = true
        loadData()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        //loadData()
        
        formatter.dateFormat = "E, d MMM yyyy"
    }
    
    func configureView() {
        if eventsArray.isEmpty {
            self.navigationItem.title = "Add an Event"
            updateLabels()
        } else {
            self.navigationItem.title = "My Events"
            loadData()
            updateLabels()
        }
    }

    func loadData() {
        if let events = EventManager.shared.getEvents() {
            eventsArray = events
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateLabels() {
        daysRemainingLabel.isHidden = eventsArray.isEmpty
        mainEventDateLabel.isHidden = eventsArray.isEmpty
        mainEventLabel.isHidden = eventsArray.isEmpty
        
        if !eventsArray.isEmpty {
            mainEventLabel.text = eventsArray[0].name
            mainEventDateLabel.text = formatter.string(from: eventsArray[0].date)
        }
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
        
        /*if eventsArray.isEmpty {
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "No events found. Add one now!"
            cell.accessoryType = .disclosureIndicator
        } else {*/
        if !eventsArray.isEmpty {
            let event = eventsArray[indexPath.row]
            cell.textLabel?.text = event.name
            cell.detailTextLabel?.text = formatter.string(from: event.date)
            cell.accessoryType = .disclosureIndicator
            //}
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (eventsArray.isEmpty) {
            performSegue(withIdentifier: "AddEvent", sender: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if eventsArray.isEmpty {
        //    return 1
        //} else {
            return eventsArray.count
        //}
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = eventsArray[indexPath.row]
            
            tableView.beginUpdates()
            EventManager.shared.deleteEvent(eventToDelete)
            eventsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            configureView()
            tableView.endUpdates()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - EventDetailViewControllerDelegate
    
    func eventDetailViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func eventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {
        let newRowIndex = eventsArray.count
    
        eventsArray.append(event)
        print("*** The New Event's Date is \(event.date)")
        EventManager.shared.addEvent(event)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        configureView()
        controller.navigationController?.popViewController(animated: true)
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

