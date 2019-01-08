//
//  IconCollectionViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 22/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class IconCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    weak var delegate: IconCollectionViewControllerDelegate?
    
    let spacing: CGFloat = 16.0
    
    let iconNames: [String] = [
        "icons8-airplane_take_off",
        "icons8-babys_room.png",
        "icons8-birthday",
        "icons8-carpool",
        "icons8-clinic",
        "icons8-commercial_development_management_filled",
        "icons8-dancing",
        "icons8-dancing_party",
        "icons8-firework_explosion",
        "icons8-pencil_tip",
        "icons8-sunbathe",
        "icons8-water_transportation"
    ]
    
    var iconImages = [UIImage]()
    var selectedIcon: String?
    
    let selectedColour = UIColor.yellow
    let defaultColour = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "IconCell", bundle: nil)
        self.collectionView!.register(nib, forCellWithReuseIdentifier: "IconCell")

        collectionView.contentInset = UIEdgeInsets(top: (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        
        configureCollectionView()
        
        for index in 0 ..< iconNames.count {
            let newImage = UIImage(named: iconNames[index])
            iconImages.append(newImage!)
        }
    }
    
    // MARK: - UI
    
    func configureCollectionView() {
        self.collectionView.backgroundView = UIImageView(image: UIImage(named: "gradient_blue"))
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        
        self.collectionView?.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 4
        let spacingBetweenCells: CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ( (numberOfItemsPerRow - 1) * spacingBetweenCells)
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing) / numberOfItemsPerRow
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newSelectedCell = collectionView.cellForItem(at: indexPath) as! IconCell
        
        if let selectedIcon = self.selectedIcon {
            let oldIndex = iconNames.firstIndex(of: selectedIcon)
            let oldSelectedCell = collectionView.cellForItem(at: IndexPath(row: oldIndex!, section: 0)) as! IconCell
            
            UIView.animate(withDuration: 0.3) {

                oldSelectedCell.iconImageView.setImageColor(color: self.defaultColour)
                oldSelectedCell.layer.borderColor = self.defaultColour.cgColor
                
                newSelectedCell.iconImageView.setImageColor(color: self.selectedColour)
                newSelectedCell.layer.borderWidth = 3
                newSelectedCell.layer.borderColor = self.selectedColour.cgColor
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                newSelectedCell.iconImageView.setImageColor(color: self.selectedColour)
                newSelectedCell.layer.borderColor = self.selectedColour.cgColor
            }
        }
        
        selectedIcon = iconNames[indexPath.row]
        delegate?.iconCollectionViewController(self, didFinishSelecting: selectedIcon!)
    }
    
    

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        
        cell.iconImageView.image = iconImages[indexPath.row]
        cell.iconImageView.setImageColor(color: self.defaultColour)
        
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 3
        cell.layer.borderColor = defaultColour.cgColor

        if iconNames[indexPath.row] == selectedIcon {
            cell.iconImageView.setImageColor(color: selectedColour)
            cell.layer.borderColor = selectedColour.cgColor
        }

        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        delegate?.iconCollectionViewControllerDidCancel(self)
    }
}
