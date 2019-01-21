//
//  EventDetailViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 9/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var daysUntilSinceLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var event: Event!
    let dateFormatter = DateFormatter()
    weak var delegate: EventDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EEEE, d MMM yyyy"       // Tuesday, 1 Jan 2019
        updateLabels()
        self.navigationItem.title = event.name
        
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        if let backgroundImagePath = event.backgroundImagePath {
            let url = URL(string: backgroundImagePath)
            
            print(backgroundImagePath)
            
            
            do {
                let data = try Data(contentsOf: url!)
                let image = UIImage(data: data)
                self.backgroundImageView.contentMode = .scaleAspectFill
                self.backgroundImageView.image = image
            } catch {
                print("Error loading photo: \(error.localizedDescription)")
            }
        }
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

    // MARK: - Actions
    
    @IBAction func done() {
        delegate?.eventDetailViewControllerDismissed(self)
    }
    
    @IBAction func edit() {
        delegate?.eventDetailViewController(self, editing: event)
    }
}
