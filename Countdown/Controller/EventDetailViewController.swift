//
//  EventDetailViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 9/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import ChameleonFramework

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var daysRemainingLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var event: Event!
    let dateFormatter = DateFormatter()
    weak var delegate: EventDetailViewControllerDelegate?

    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "EEEE, d MMM yyyy"       // Tuesday, 1 Jan 2019
        //updateLabels()
        self.navigationItem.title = event.name
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        arrowImageView.setImageColor(color: UIColor.white)
        
        if let backgroundImagePath = event.backgroundImagePath {
            let url = URL(string: backgroundImagePath)

            do {
                let data = try Data(contentsOf: url!)
                let image = UIImage(data: data)
                self.backgroundImageView.contentMode = .scaleAspectFill
                self.backgroundImageView.image = image
            } catch {
                print("Error loading photo: \(error.localizedDescription)")
            }
        }
        
        createGradientLayer()
        updateLabels()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.3).cgColor, UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.4).cgColor]
        gradientLayer.locations = [0.1, 0.75, 1.0]
        
        self.view.layer.insertSublayer(gradientLayer, at: 1)
    }
    
    func updateLabels() {
       
       let strokeTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -3,
        ] as [ NSAttributedString.Key: Any ]
   
        
        eventTitleLabel.attributedText = NSAttributedString(string: "\(event.name)", attributes: strokeTextAttributes)
        
        daysRemainingLabel.attributedText = NSAttributedString(string: String(abs(event.dayCount)), attributes: strokeTextAttributes)
        eventDateLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: event.date), attributes: strokeTextAttributes)
    }

    // MARK: - Actions    
    @IBAction func done() {
        delegate?.eventDetailViewControllerDismissed(self)
    }
    
    @IBAction func edit() {
        delegate?.eventDetailViewController(self, editing: event)
    }
}
