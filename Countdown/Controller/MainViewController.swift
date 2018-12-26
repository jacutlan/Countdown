//
//  ViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import QuartzCore

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddEditEventViewControllerDelegate {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var mainEventLabel: UILabel!
    @IBOutlet weak var mainEventDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let formatter = DateFormatter()
    var eventsArray = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        print("**** HomeDirectory: " + NSHomeDirectory())
        let nib = UINib(nibName: "EventCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "EventCell")
        loadData()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureView()
    }
    
    // MARK: - UI
    
    func configureView() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        
        if eventsArray.isEmpty {
            updateTitle(newTitle: "Add an Event")
            updateLabels()
        } else {
            updateTitle(newTitle: "My Events")
            loadData()
            sortData()
            updateLabels()
        }
    }
    
    func updateLabels() {
        daysRemainingLabel.isHidden = eventsArray.isEmpty
        mainEventDateLabel.isHidden = eventsArray.isEmpty
        mainEventLabel.isHidden = eventsArray.isEmpty
        
        if !eventsArray.isEmpty {
            switch eventsArray[0].dayCount {
            case 1...:
                daysRemainingLabel.text = String(abs(eventsArray[0].dayCount))
            case 0:
                daysRemainingLabel.text = "Today"
            case ..<0:
                daysRemainingLabel.text = "Gone"
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
        
        if segue.identifier == "ShowEventDetail" {
            //let selectedIndexPath = sender as? IndexPath()
            let selectedEvent = eventsArray[(tableView.indexPathForSelectedRow!.row)]
            
            let controller = segue.destination as! EventDetailViewController
            controller.event = selectedEvent
        }
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell

        if !eventsArray.isEmpty {
            let event = eventsArray[indexPath.row]
            cell.cellImageView.image = event.icon
            cell.titleLabel.text = event.name
            cell.dateLabel.text = formatter.string(from: event.date)
            cell.accessoryType = .disclosureIndicator
            cell.dayCountLabel.text = String(abs(event.dayCount))
            
            cell.upArrowImageView.isHidden = event.dayCount > 0
            cell.downArrowImageView.isHidden = event.dayCount < 0

        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowEventDetail", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let eventToDelete = eventsArray[indexPath.row]
            
            tableView.beginUpdates()
            EventManager.shared.deleteEvent(eventToDelete)
            eventsArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            //self.tableView.frame.size.height = CGFloat(60 * tableView.numberOfRows(inSection: 0))

            
            configureView()
            tableView.endUpdates()
            
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - EventDetailViewControllerDelegate
    
    func addEditEventViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {
        let newRowIndex = eventsArray.count
    
        eventsArray.append(event)
        print("*** New event icon is \(event.iconName)")
        EventManager.shared.addEvent(event)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.frame.size.height += 60
        }
        
        tableView.insertRows(at: indexPaths, with: .automatic)
        configureView()
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventViewController(_ controller: AddEventViewController, didFinishUpdating event: Event) {}
}
