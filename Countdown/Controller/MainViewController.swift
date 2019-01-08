//
//  ViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import SwipeCellKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var daysUntilSinceLabel: UILabel!
    @IBOutlet weak var mainEventLabel: UILabel!
    @IBOutlet weak var mainEventDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UIView!
   
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    let formatter = DateFormatter()
    var eventsArray = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        print("**** HomeDirectory: " + NSHomeDirectory())
        
        let nib = UINib(nibName: "EventCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "EventCell")
        
        if eventsArray.isEmpty {
            infoView.alpha = 0
            tableView.alpha = 0
        }

//        DispatchQueue.main.async {
//            self.loadData()
//            self.configureView()
//            self.updateLabels()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                DispatchQueue.main.async {
                    self.loadData()
                    self.configureView()
                    self.updateLabels()
                }

    }
    
    // MARK: - UI
    func configureView() {
        self.configureTableView()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 8

        if eventsArray.isEmpty {
            updateTitle(newTitle: "Add an Event")
            
            UIView.animate(withDuration: 0.3) {
                self.infoView.alpha = 0
                self.tableView.alpha = 0
            }
        } else {
            updateTitle(newTitle: "My Events")
            UIView.animate(withDuration: 0.3) {
                self.infoView.alpha = 1
                self.tableView.alpha = 1
                self.infoView.layer.cornerRadius = 8
                self.infoView.layer.borderColor = UIColor.black.cgColor
                self.infoView.layer.borderWidth = 1
            }
        }
    }
    
    func configureTableView() {
        let containerHeight = tableView.superview?.frame.size.height
        let maxRowCount: Int
        let maxTableViewHeight: CGFloat
        
        switch containerHeight {
        case 248:   // iPhone SE
            tableView.rowHeight = 61
            maxRowCount = 4
        case 297.5: // iPhone 6, 7, 8
            tableView.rowHeight = 58.7
            maxRowCount = 5
        case 332:   // 6,7,8+
            tableView.rowHeight = 54.6
            maxRowCount = 6
        case 341:   // XS, X
            tableView.rowHeight = 56.1
            maxRowCount = 6
        case 383:   // XR, XS Max
            tableView.rowHeight = 62.8
            maxRowCount = 6
        default:    // Nokia 3210
            tableView.rowHeight = 60
            maxRowCount = 5
        }
        
        maxTableViewHeight = CGFloat(maxRowCount) * tableView.rowHeight

        if CGFloat(eventsArray.count) * tableView.rowHeight <= maxTableViewHeight {
            self.tableView.isScrollEnabled = false
            
            self.tableViewHeight.constant = CGFloat(self.eventsArray.count) * self.tableView.rowHeight
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.tableViewHeight.constant = maxTableViewHeight
            self.tableView.isScrollEnabled = true
        }
        
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 1
    }
    
    func updateLabels() {
        if !eventsArray.isEmpty {
            switch eventsArray[0].dayCount {
            case 1...:
                daysRemainingLabel.text = String(abs(eventsArray[0].dayCount))
                daysUntilSinceLabel.text = "Days Until"
            case 0:
                daysRemainingLabel.text = "0"
                daysUntilSinceLabel.text = "It's Today!"
            case ..<0:
                daysRemainingLabel.text = String(abs(eventsArray[0].dayCount))
                daysUntilSinceLabel.text = "Days Since"
            default:
                daysRemainingLabel.text = "?"
            }
            
            mainEventLabel.text = eventsArray[0].name
            mainEventDateLabel.text = formatter.string(from: eventsArray[0].date)
        }
    }
    
    func updateTitle(newTitle: String) {
        if self.navigationItem.title != newTitle {
            let pushTextAnimation = CATransition()
            pushTextAnimation.duration = 0.5
            pushTextAnimation.type = CATransitionType.push
            
            navigationController?.navigationBar.layer.add(pushTextAnimation, forKey: "pushText")
            navigationItem.title = newTitle
        }
    }
    
    // MARK: - Data Load/Sort

    func loadData() {
        if let events = EventManager.shared.getEvents() {
            eventsArray = events
            sortData()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Sort by date, soonest to furthest away
    func sortData() {
        eventsArray = eventsArray.sorted(by: {$0.date < $1.date} )
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEvent" {
            let controller = segue.destination as! AddEventViewController
            controller.delegate = self
        }
        
        if segue.identifier == "EditEvent" {
            let controller = segue.destination as! AddEventViewController
            
            if let editingEvent = sender as? Event {
                print("You're about to edit the event: \(editingEvent.name)")
                
                controller.delegate = self
                controller.eventToEdit = editingEvent
                controller.eventName = editingEvent.name
                controller.eventDate = editingEvent.date
                controller.selectedIcon = editingEvent.iconName
                controller.selectedCategory = editingEvent.category
                controller.title = "Edit Event"
            }
        }
        
        if segue.identifier == "ShowEventDetail" {
            let selectedEvent = eventsArray[(tableView.indexPathForSelectedRow!.row)]
            
            let controller = segue.destination as! EventDetailViewController
            controller.event = selectedEvent
            controller.delegate = self
        }
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        cell.delegate = self
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        if !eventsArray.isEmpty {
            let event = eventsArray[indexPath.row]
            cell.cellImageView.image = event.icon
            cell.titleLabel.text = event.name
            cell.dateLabel.text = formatter.string(from: event.date)
            cell.accessoryType = .none
            cell.dayCountLabel.text = String(abs(event.dayCount))
            cell.arrowImageView.image = event.dayCount < 0 ? UIImage(named: "UpArrow") : UIImage(named: "DownArrow")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowEventDetail", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            let eventToDelete = self.eventsArray[indexPath.row]
//
//            DispatchQueue.main.async {
//                self.tableView.beginUpdates()
//                EventManager.shared.deleteEvent(eventToDelete)
//                self.eventsArray.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .fade)
//
//                self.configureView()
//                self.updateLabels()
//                self.tableView.endUpdates()
//            }
//        }
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - AddEditEventViewController Delegate
extension MainViewController: AddEditEventViewControllerDelegate {
    func addEditEventViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {
        let newRowIndex = eventsArray.count
    
        eventsArray.append(event)
        EventManager.shared.addEvent(event)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
    
        tableView.insertRows(at: indexPaths, with: .automatic)
        configureView()
        updateLabels()
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventViewController(_ controller: AddEventViewController, didFinishUpdating event: Event) {
        loadData()
        configureView()
        updateLabels()
        controller.navigationController?.popViewController(animated: true)
    }
}

extension MainViewController: EventDetailViewControllerDelegate {
    func eventDetailViewControllerDismissed(_ controller: EventDetailViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func eventDetailViewController(_ controller: EventDetailViewController, editing editingEvent: Event) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "EditEvent", sender: editingEvent)
        }
    }
}

extension MainViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                //Delete an event by swiping from the right
                
                let eventToDelete = self.eventsArray[indexPath.row]
                
                EventManager.shared.deleteEvent(eventToDelete)
                self.eventsArray.remove(at: indexPath.row)
                self.configureView()
                self.updateLabels()
                action.fulfill(with: .delete)
            }
            
            deleteAction.image = UIImage(named: "Trash")
            
            return [deleteAction]
        } else {
            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                // Edit an event by swiping from the left
            }
            
            editAction.image = UIImage(named: "Edit")
            editAction.backgroundColor = UIColor.yellow
            
            return [editAction]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        
        if orientation == .right {
            options.expansionStyle = .destructive
        } else {
            options.expansionStyle = .selection
        }

        return options
    }
}
