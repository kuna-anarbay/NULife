//
//  ReviewsViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class ReviewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var reviews = [Review]()
    var cafeId: String = "" {
        didSet {
            fetchReviews()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        setupTableView()
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReview" {
            let dest = segue.destination as! NewReviewViewController
            dest.cafeId = cafeId
        }
    }
    
    
    
    func fetchReviews(){
        Cafe.getOne(cafeId) { (cafe) in
            if cafe.approved {
                self.reviews = cafe.reviews ?? []
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}


extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {

    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[indexPath.row]
        
        if review.image == nil || review.image?.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
           
           cell.nameLabel.text = review.author.name
           cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: review.timestamp)
           cell.bodyLabel.text = review.body
            
           cell.firstStar.image = review.rating >= 1 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
           cell.secondStar.image = review.rating >= 2 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
           cell.thirdStar.image = review.rating >= 3 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
           cell.forthStar.image = review.rating >= 4 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
           cell.fifthStar.image = review.rating >= 5 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
           
           return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewImageCell", for: indexPath) as! ReviewTableViewCell
                    
            cell.nameLabel.text = review.author.name
            cell.timeLabel.text = Helper.displayDate24HourFull(timestamp: review.timestamp)
            cell.bodyLabel.text = review.body
            
            cell.mainImage.setImage(from: URL(string: review.image!))
            
            cell.firstStar.image = review.rating >= 1 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.secondStar.image = review.rating >= 2 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.thirdStar.image = review.rating >= 3 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.forthStar.image = review.rating >= 4 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            cell.fifthStar.image = review.rating >= 5 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            
            return cell
        }
       
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
