//
//  ThemeViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 27/1/19.
//  Copyright © 2019 Josh Cutlan. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    
    weak var delegate: ThemeViewControllerDelegate!
    var currentTheme: Theme?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if currentTheme == nil {
            currentTheme = Theme(darkColour: UIColor.flatSkyBlueDark, lightColour: UIColor.flatSkyBlue)
        }
        
        self.view.backgroundColor = currentTheme!.lightColour
        scrollView.backgroundColor = UIColor.clear //currentTheme!.lightColour
    }
    
    @IBAction func cancel() {
        delegate.themeViewControllerDismissed(self)
    }
    
    @IBAction func done() {
        delegate.themeViewController(self, didFinishSelecting: currentTheme!)
    }
}
