//
//  EventDetailViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 9/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController, AddEditEventViewControllerDelegate {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var daysUntilSinceLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var event: Event!
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EEEE, d MMM yyyy"       // Tuesday, 1 Jan 2019
        updateLabels()
        self.navigationItem.title = event.name
        
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.blue.cgColor
    }
    
    func updateLabels() {
        daysRemainingLabel.text = String(abs(event.dayCount))
        eventTitleLabel.text = event.name
        eventDateLabel.text = dateFormatter.string(from: event.date)
        
        if event.dayCount > 1 {
            daysUntilSinceLabel.text = "Days Until"
        } else if event.dayCount == 1 {
            daysUntilSinceLabel.text = "Day Until"
        } else if event.dayCount == -1 {
            daysUntilSinceLabel.text = "Day Since"
        } else if event.dayCount < 0 {
            daysUntilSinceLabel.text = "Days Since"
        } else if event.dayCount == 0 {
            daysUntilSinceLabel.text = "Today's the Day!"
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEvent" {
            let controller = segue.destination as? AddEventViewController
            controller?.delegate = self
            controller?.eventToEdit = event
            controller?.navigationItem.title = "Edit Event"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - AddEditEventViewControllerDelegate
    
    func addEditEventViewControllerDidCancel(_ controller: AddEventViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func addEditEventViewController(_ controller: AddEventViewController, didFinishUpdating event: Event) {
        controller.navigationController?.popViewController(animated: true)
        print("Event title from the delegate is: \(event.name)")
        title = event.name
        self.event = event
        updateLabels()
    }
    
    func addEditEventDetailViewController(_ controller: AddEventViewController, didFinishAdding event: Event) {}
}
