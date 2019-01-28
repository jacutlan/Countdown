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
    let themes = [
        Theme(darkColour: UIColor.flatRedDark, lightColour: UIColor.flatRed, themeName: "Flat Red"),
        Theme(darkColour: UIColor.flatOrangeDark, lightColour: UIColor.flatOrange, themeName: "Flat Orange"),
        Theme(darkColour: UIColor.flatYellowDark, lightColour: UIColor.flatYellow, themeName: "Flat Yellow"),
        Theme(darkColour: UIColor.flatGreenDark, lightColour: UIColor.flatGreen, themeName: "Flat Green"),
        Theme(darkColour: UIColor.flatSkyBlueDark, lightColour: UIColor.flatSkyBlue, themeName: "Flat Sky Blue"),
        Theme(darkColour: UIColor.flatBlueDark, lightColour: UIColor.flatBlue, themeName: "Flat Blue"),
        Theme(darkColour: UIColor.flatPurpleDark, lightColour: UIColor.flatPurple, themeName: "Flat Purple"),
        Theme(darkColour: UIColor.flatGrayDark, lightColour: UIColor.flatGray, themeName: "Flat Gray"),
        Theme(darkColour: UIColor.flatBrownDark, lightColour: UIColor.flatBrown, themeName: "Flat Brown"),
        Theme(darkColour: UIColor.flatBlackDark, lightColour: UIColor.flatBlack, themeName: "Flat Black")
    ]
    var slides: [ThemeSlide] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        if currentTheme == nil {
            currentTheme = Theme(darkColour: UIColor.flatSkyBlueDark, lightColour: UIColor.flatSkyBlue, themeName: "Sky Blue")
        }
        
        slides = createSlides()
        setupScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    // MARK: - UI Setup
    func createSlides() -> [ThemeSlide] {
        var slides = [ThemeSlide]()
        for theme in themes {
            let themeSlide: ThemeSlide = Bundle.main.loadNibNamed("ThemeSlide", owner: self, options: nil)?.first as! ThemeSlide
            
            themeSlide.navbarView.backgroundColor = theme.darkColour
            themeSlide.outerView.backgroundColor = theme.lightColour
            themeSlide.themeNameLabel.text = theme.themeName
            
            slides.append(themeSlide)
        }
        
        return slides
    }
    
    // Configure the position, content size and appearance for the scroll view and each slide inside it
    func setupScrollView(slides: [ThemeSlide]) {
        scrollView.frame = CGRect(x: 0, y: 0
            , width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            slides[i].outerView.layer.borderColor = UIColor.black.cgColor
            slides[i].outerView.layer.borderWidth = 1
            slides[i].outerView.layer.cornerRadius = 8
            slides[i].outerView.clipsToBounds = true
            scrollView.addSubview(slides[i])
        }
    }
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate.themeViewControllerDismissed(self)
    }
    
    @IBAction func done() {
        delegate.themeViewController(self, didFinishSelecting: currentTheme!)
    }
}

// MARK: - UIScrollView Delegate
extension ThemeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update the page controller as you switch slides
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        currentTheme = themes[Int(pageIndex)]
        
        // Prevent vertical scrolling
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
