//
//  RatingTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import SPAlert

protocol NewReviewProtocol {
    func addReview()
    func reloadData()
}

class RatingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rateButtonsView: UIView!
    @IBOutlet weak var ratingProgressView: UIView!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var allRatingLabel: UILabel!
    var userRating = 0 {
        didSet {
            for i in 1...5 {
                if i <= userRating {
                    (rateButtonsView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    (rateButtonsView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star"), for: .normal)
                }
            }
        }
    }
    var delegate: NewReviewProtocol!
    var cafeId = String()
    var newReview = Review()
    var allReviews : [Review] = [] {
        didSet {
            setDesign()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        for i in 1...5 {
            if i <= userRating {
                (rateButtonsView.viewWithTag(i) as! UIButton).setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
            let tempView = ratingProgressView.viewWithTag(i)!
            tempView.layer.cornerRadius = 8.25
        }
        
    }

    
    func setDesign(){
        let totalCount = allReviews.count
        var totalSum = 0
        var ratings = [0, 0, 0, 0, 0]
        for review in allReviews {
            totalSum += review.rating
            ratings[review.rating-1] += 1
        }
        
        
        if totalCount > 0 {
            self.ratingLabel.text = NSString(format: "%.01f", Float(totalSum)/Float(totalCount)) as String
        } else {
            self.ratingLabel.text = "0"
        }
        self.ratingCount.text = "(\(totalCount) reviews)"
        
        allRatingLabel.text = "\(ratings[4])\n\(ratings[3])\n\(ratings[2])\n\(ratings[1])\n\(ratings[0])"
        
        
        for i in 1...5 {
            let tempView = ratingProgressView.viewWithTag(i)!
            let progressView = tempView.viewWithTag(0) as! UIProgressView
            let rating = CGFloat(ratings[5-i])/CGFloat(totalCount)
            
            
            if totalCount != 0 {
                progressView.progress = Float(rating)
            }
        }
    }
    
    
    
    
    @IBAction func writeReviewPressed(_ sender: Any) {
        delegate.addReview()
    }
    
    
    
    @IBAction func ratePressed(_ sender: UIButton) {
        newReview.rating = sender.tag
        newReview.firebaseAdd(cafeId: cafeId, images: []) { (message) in
            if message == .success {
                SPAlert.present(title: "You rated as \(sender.tag)", preset: .done)
            } else {
                SPAlert.present(title: "Failed to rate", preset: .error)
            }
        }
        delegate.reloadData()
    }
    
}
