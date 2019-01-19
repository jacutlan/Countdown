//
//  SettingsTableViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 16/1/19.
//  Copyright © 2019 Josh Cutlan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var darkColourBox: UIImageView!
    @IBOutlet weak var lightColourBox: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    // MARK: - UI Stuff
    func configureView() {
        tableView.rowHeight = 44
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        darkColourBox.layer.cornerRadius = 8
        darkColourBox.layer.borderColor = UIColor.black.cgColor
        darkColourBox.layer.borderWidth = 1
        
        
        lightColourBox.layer.cornerRadius = 8
        lightColourBox.layer.borderColor = UIColor.black.cgColor
        lightColourBox.layer.borderWidth = 1
    }

    // MARK: - Actions
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Customise the tableview header colour
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
}
