//
//  ViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 1/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var mainEventLabel: UILabel!
    @IBOutlet weak var mainEventDateLabel: UILabel!
    
    var events = [Event]()
    var tableView: UITableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        events = []
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        tableView.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
        self.view.addSubview(tableView)
    }

    func updateLabels() {
        if events.isEmpty {
            daysRemainingLabel.isHidden = true
            mainEventDateLabel.isHidden = true
            mainEventLabel.isHidden = true
        }
    }
    
    
    @IBAction func cancelToMainViewController(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func saveEventDetail(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        if events.isEmpty {
            cell.textLabel?.text = "No events yet. Add one now!"
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (events.isEmpty) {
            performSegue(withIdentifier: "AddEvent", sender: indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (events.isEmpty) {
            return 1
        } else {
            return events.count
        }
    }
}

