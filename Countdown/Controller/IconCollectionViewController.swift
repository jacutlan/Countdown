//
//  IconCollectionViewController.swift
//  Countdown
//
//  Created by Josh Cutlan on 22/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class IconCollectionViewController: UICollectionViewController {
    weak var delegate: IconCollectionViewControllerDelegate?
    
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
    var selectedIcon: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "IconCell", bundle: nil)
        self.collectionView!.register(nib, forCellWithReuseIdentifier: "IconCell")

        configureCollectionView()
        
        for index in 0 ..< iconNames.count {
            let newImage = UIImage(named: iconNames[index])
            iconImages.append(newImage!)
        }
    }
    
    // MARK: - UI
    
    func configureCollectionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemsPerRow: CGFloat = 4
            let padding: CGFloat = 8
            let totalPadding = padding * (itemsPerRow - 1)
            let individualPadding = totalPadding / itemsPerRow
            let width = collectionView.frame.width / itemsPerRow - individualPadding
            let height = width
            layout.itemSize = CGSize(width: width, height: height)
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
        }
        
        self.collectionView.backgroundView = UIImageView(image: UIImage(named: "3"))
        //self.tableView.backgroundView = UIImageView(image: UIImage(named: "3"))
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldIndex = iconNames.firstIndex(of: selectedIcon)
        let oldSelectedCell = collectionView.cellForItem(at: IndexPath(row: oldIndex!, section: 0)) as! IconCell
        
        selectedIcon = iconNames[indexPath.row]
        
        let newSelectedCell = collectionView.cellForItem(at: indexPath) as! IconCell
        
        UIView.animate(withDuration: 0.3) {
            oldSelectedCell.backgroundColor = UIColor.clear
            oldSelectedCell.iconImageView.setImageColor(color: .black)
            newSelectedCell.backgroundColor = UIColor.green
            newSelectedCell.iconImageView.setImageColor(color: .black)
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        
        cell.iconImageView.image = iconImages[indexPath.row]
        cell.layer.cornerRadius = 8
        
        if iconNames[indexPath.row] == selectedIcon {
            cell.backgroundColor = .green
            cell.iconImageView.setImageColor(color: .white)
        }

        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        delegate?.iconCollectionViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        delegate?.iconCollectionViewController(self, didFinishSelecting: selectedIcon)
    }
}
