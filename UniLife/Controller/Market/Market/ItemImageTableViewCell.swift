//
//  ItemImageTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/17/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class ItemImageTableViewCell: UITableViewCell {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mainImage: UIImageView!
    var imagesCount: Int = 0
    var urls: [String] = [] {
        didSet {
            self.setup()
            pageControl.numberOfPages = urls.count
            pageControl.currentPage = 0
            self.imagesCount = urls.count
        }
    }
    var currentImage = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
    }
    
    
    func setup(){
        if urls.count > 0 {
            pageControl.isHidden = false
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            self.contentView.addGestureRecognizer(swipeRight)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
            self.contentView.addGestureRecognizer(swipeLeft)
        } else {
            pageControl.isHidden = true
        }
    }
    
    

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {


            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                if currentImage == imagesCount - 1 {
                    currentImage = 0
                }else{
                    currentImage += 1
                }
                pageControl.currentPage = currentImage
                self.mainImage.setImage(from: URL(string: urls[currentImage]))
                let transition = CATransition()
                transition.duration = 0.75
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                transition.type = .fade
                self.mainImage.layer.add(transition, forKey: nil)
                

            case UISwipeGestureRecognizer.Direction.right:
                if currentImage == 0 {
                    currentImage = imagesCount - 1
                }else{
                    currentImage -= 1
                }
                pageControl.currentPage = currentImage
                self.mainImage.setImage(from: URL(string: urls[currentImage]))
                let transition = CATransition()
                transition.duration = 0.75
                transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                transition.type = .fade
                self.mainImage.layer.add(transition, forKey: nil)
            default:
                break
            }
        }
    }

}
