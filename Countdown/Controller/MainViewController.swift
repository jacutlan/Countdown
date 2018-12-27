//
//  ViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import QuartzCore

class MainViewController: UIViewController {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var mainEventLabel: UILabel!
    @IBOutlet weak var mainEventDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let formatter = DateFormatter()
    var events = [Event]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Events.plist") // Where the .plist is saved
    
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()

    override func viewDidLoad() {
        print("*** Data File Path: \(dataFilePath)")
    
        super.viewDidLoad()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        
        // Initialise Jokc's custom Event Cell
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
        // Make the navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Configure the clear look of the table view
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        
        if events.isEmpty {
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
        daysRemainingLabel.isHidden = events.isEmpty
        mainEventDateLabel.isHidden = events.isEmpty
        mainEventLabel.isHidden = events.isEmpty
        
        if !events.isEmpty {
            switch events[0].dayCount {
            case 1...:
                daysRemainingLabel.text = String(abs(events[0].dayCount))
            case 0:
                daysRemainingLabel.text = "Today"
            case ..<0:
                daysRemainingLabel.text = "Gone"
            default:
                daysRemainingLabel.text = "?"
            }
            
            mainEventLabel.text = events[0].name
            mainEventDateLabel.text = formatter.string(from: events[0].date)
            
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
    
    // MARK: - Data Manipulation
    func saveData() {
        do {
            let data = try encoder.encode(events)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error saving data!")
        }
    }
    
    
    func loadData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            do {
                events = try decoder.decode([Event].self, from: data)
            } catch {
                print("Error decoding data! \(error)")
            }
        }
    }
    
    func sortData() {
        events = events.sorted {$0.date < $1.date}
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEvent" {
            let controller = segue.destination as! AddEventViewController
            controller.delegate = self
        }
        
        if segue.identifier == "ShowEventDetail" {
            //let selectedIndexPath = sender as? IndexPath()
            let selectedEvent = events[(tableView.indexPathForSelectedRow!.row)]
            
            let controller = segue.destination as! EventDetailViewController
            controller.event = selectedEvent
        }
    }
}

// MARK: - EventDetailViewControllerDelegate
extension MainViewController: AddEditEventViewControllerDelegate {
    func addEditEventViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {
    
        events.append(event)
        saveData()
        controller.navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
    
    func addEditEventViewController(_ controller: AddEventViewController, didFinishUpdating event: Event) {}
}

// MARK: - TableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        if !events.isEmpty {
            let event = events[indexPath.row]
            cell.cellImageView.image = event.icon
            cell.titleLabel.text = event.name
            cell.dateLabel.text = formatter.string(from: event.date)
            cell.accessoryType = .disclosureIndicator
            cell.dayCountLabel.text = String(abs(event.dayCount))
            
            cell.upArrowImageView.isHidden = event.dayCount >= 0
            cell.downArrowImageView.isHidden = event.dayCount <= 0
            
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
}

// MARK: - TableView Data Source
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
            configureView()
            tableView.endUpdates()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
