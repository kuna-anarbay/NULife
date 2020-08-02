//
//  CafeViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/18/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class CafeViewController: UIViewController {

    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    var isFirstSegment: Bool = true
    var activeMeals = [Meal]()
    var otherMeals = [Meal]()
    var reviews = [Review]()
    var cafe = Cafe()
    var mealDetailVC = MealDetail()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let windowScene = UIApplication.shared
                        .connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first
        if let windowScene = windowScene as? UIWindowScene {
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: windowScene.statusBarManager?.statusBarFrame.size.height ?? 20))
            
            statusbarView.backgroundColor = UIColor(named: "White color")
            view.addSubview(statusbarView)
        }
        
        hideKeyboard()
        fetchMeals()
        fetchCafe()
        setupTableView()
        dismissButton.addShadow(radius: 15)
        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReviews" {
            let nav = segue.destination as! UINavigationController
            let dest = nav.viewControllers[0] as! ReviewsViewController
            dest.cafeId = cafe.id
        } else if segue.identifier == "addReview" {
            let nav = segue.destination as! UINavigationController
            let dest = nav.viewControllers[0] as! NewReviewViewController
            dest.cafeId = cafe.id
        }
    }
    

}


extension CafeViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let sectionHeader = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(sectionHeader, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
        let nib = UINib(nibName: "TopHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TopHeader")
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.contentOffset.y < -100 {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissButton.alpha = (100 + tableView.contentOffset.y)/100
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFirstSegment {
            if section == 0 {
                return 2
            }
            return section == 1 ? activeMeals.count : otherMeals.count
        } else {
            if section == 0 {
                return 2
            }
            if reviews.count < 3 {
               return section == 2 ? 0 : 4 + reviews.count
            }
            return section == 2 ? 0 : 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MARK: FIRST segment
        if isFirstSegment {
            
            //MARK: First section
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let topAdCell = tableView.dequeueReusableCell(withIdentifier: "topAdCell", for: indexPath) as! TopAdTableViewCell
                    
                    var featuredMeal = activeMeals.first(where: {$0.id == cafe.featured})
                    if featuredMeal == nil {
                        featuredMeal = otherMeals.first(where: {$0.id == cafe.featured})
                    }
                    if featuredMeal?.urls.count ?? 1 > 1 {
                        topAdCell.mainImage.setImage(from: URL(string: featuredMeal?.urls["cafe"]! ?? ""))
                    }
                    
                    
                    return topAdCell
                } else {
                    let cafeCell = tableView.dequeueReusableCell(withIdentifier: "cafeCell", for: indexPath) as! CafeTableViewCell
                    
                    
                    cafeCell.titleLabel.text = cafe.title
                    cafeCell.hoursLabel.text = cafe.opensAt
                    cafeCell.hoursLabel?.textColor = cafe.opensColor
                    cafeCell.infoLabel.text = ""
                    cafeCell.logoImage.setImage(from: URL(string: cafe.urls["logo"] ?? ""))
                    cafeCell.ratingLabel.text = (NSString(format: "%.01f", cafe.rating) as String)
                    
                    return cafeCell
                }
            }
            //MARK: Second section
            else if indexPath.section == 1 {
                let mealCell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! CafeTableViewCell
                
                let meal = activeMeals[indexPath.row]
                mealCell.titleLabel.text = meal.title
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(meal.price)₸")
               
                if meal.price != meal.discountedPrice {
                     attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray3, range: NSMakeRange(0, attributeString.length))
                } else {
                    attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "Main color")!, range: NSMakeRange(0, attributeString.length))
                }
                
                let attrString = NSMutableAttributedString(string: "   \(meal.discountedPrice)₸")
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "Main color")!, range: NSMakeRange(0, attrString.length))
                
                if meal.price != meal.discountedPrice {
                    attributeString.append(attrString)
                }
                
                mealCell.hoursLabel.attributedText = attributeString
                if meal.urls.count > 0 {
                    mealCell.logoImage.setImage(from: URL(string: meal.urls["standard"] ?? ""))
                }
                
                if meal.discount == 0 {
                    mealCell.ratingLabel.text = ""
                    mealCell.ratingLabel.layer.borderColor = UIColor.clear.cgColor
                } else {
                    mealCell.ratingLabel.text = "-\(meal.discount)%"
                    mealCell.ratingLabel.layer.cornerRadius = 6
                    mealCell.ratingLabel.layer.borderColor = UIColor.red.cgColor
                    mealCell.ratingLabel.layer.borderWidth = 0.5
                }
                mealCell.logoImage.alpha = 1
                mealCell.infoLabel.numberOfLines = 2
                mealCell.infoLabel.text = meal.details
                
                
                return mealCell
            }
            //MARK: Third section
            else {
                let mealCell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! CafeTableViewCell
                
                let meal = otherMeals[indexPath.row]
                mealCell.hoursLabel.textColor = UIColor(named: "Muted text color")
                
                mealCell.titleLabel.alpha = 0.75
                mealCell.titleLabel.text = meal.title
                mealCell.hoursLabel.text = "\(meal.discountedPrice)₸"
                if meal.urls.count > 0 {
                    mealCell.logoImage.setImage(from: URL(string: meal.urls["standard"] ?? ""))
                }
                mealCell.logoImage.alpha = 0.75
                mealCell.ratingLabel.text = ""
                mealCell.infoLabel.numberOfLines = 2
                mealCell.infoLabel.text = meal.details
                
                
                return mealCell
            }
        }
        //MARK: Second segment
        else {
            
            //MARK: First section
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let topAdCell = tableView.dequeueReusableCell(withIdentifier: "topAdCell", for: indexPath) as! TopAdTableViewCell
                    
                    var featuredMeal = activeMeals.first(where: {$0.id == cafe.featured})
                    if featuredMeal == nil {
                        featuredMeal = otherMeals.first(where: {$0.id == cafe.featured})
                    }
                    if featuredMeal?.urls.count ?? 1 > 1 {
                        topAdCell.mainImage.setImage(from: URL(string: featuredMeal?.urls["cafe"]! ?? ""))
                    }
                    
                    return topAdCell
                } else {
                    let cafeCell = tableView.dequeueReusableCell(withIdentifier: "cafeCell", for: indexPath) as! CafeTableViewCell
                    
                    
                    cafeCell.titleLabel.text = cafe.title
                    cafeCell.hoursLabel.text = cafe.opensAt
                    cafeCell.hoursLabel?.textColor = cafe.opensColor
                    cafeCell.infoLabel.text = ""
                    cafeCell.logoImage.setImage(from: URL(string: cafe.urls["logo"] ?? ""))
                    cafeCell.ratingLabel.text = (NSString(format: "%.01f", cafe.rating) as String)
                    
                    return cafeCell
                }
            }
            //MARK: Second section
            else {
                if indexPath.row == 0 {
                    let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath)
                    detailsCell.detailTextLabel?.text = cafe.details
                    
                    return detailsCell
                } else if indexPath.row == 1 {
                    let hoursCell = tableView.dequeueReusableCell(withIdentifier: "hoursCell", for: indexPath) as! HourTableViewCell
                    
                    hoursCell.mainLabel.text = cafe.workingHours
                    
                    return hoursCell
                } else if indexPath.row == 2 {
                    let contactCell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
                    
                    contactCell.contacts = self.cafe.contacts
                    
                    return contactCell
                } else if indexPath.row == 3 {
                    let ratingCell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! RatingTableViewCell
                    
                    let userRating = cafe.reviews?.first(where: {$0.id == Auth.auth().currentUser!.uid})
                    ratingCell.userRating = userRating != nil ? userRating!.rating : 0
                    ratingCell.delegate = self
                    ratingCell.cafeId = cafe.id
                    ratingCell.allReviews = cafe.reviews ?? []
                                       
                    return ratingCell
                } else {
                    let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
                    
                    let review = reviews[indexPath.row-4]
                    
                    reviewCell.nameLabel.text = review.author.name
                    reviewCell.timeLabel.text = Helper.displayDate24HourFull(timestamp: review.timestamp)
                    reviewCell.bodyLabel.text = review.body
                    
                    reviewCell.firstStar.image = review.rating >= 1 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    reviewCell.secondStar.image = review.rating >= 2 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    reviewCell.thirdStar.image = review.rating >= 3 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    reviewCell.forthStar.image = review.rating >= 4 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    reviewCell.fifthStar.image = review.rating >= 5 ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    
                    if review.image?.count == 0 {
                        reviewCell.bodyLabel.trailingConstraint?.constant = 16
                        reviewCell.mainImage.image = nil
                    } else {
                        reviewCell.mainImage.setImage(from: URL(string: review.image ?? ""))
                        reviewCell.bodyLabel.trailingConstraint?.constant = 100
                    }
                    
                    return reviewCell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFirstSegment {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    return tableView.bounds.width/16*9
                } else {
                    return 80
                }
            } else if indexPath.section == 1 {
                return 96
            } else {
                return 96
            }
        } else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    return tableView.bounds.width/16*9
                } else {
                    return 80
                }
            } else {
                if indexPath.row == 0 {
                    return UITableView.automaticDimension
                } else if indexPath.row == 1 {
                    return 200
                } else if indexPath.row == 2 {
                    return CGFloat(54.5 + Double(self.cafe.contacts.count*44))
                } else if indexPath.row == 3 {
                    return 195
                } else {
                    return UITableView.automaticDimension
                }
            }
        }
    }
    
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else if section == 1 {
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "TopHeader") as! TopHeader
            header.setupCollectionView()
            header.setupSearchBar()
            header.delegate = self
            header.segmentedControl.selectedSegmentIndex = isFirstSegment ? 0 : 1
            header.backView.layer.cornerRadius = 0
            
            header.segmentedControl.setTitle("Menu", forSegmentAt: 0)
            header.segmentedControl.setTitle("Details", forSegmentAt: 1)
            header.optionsButton.isHidden = true
            header.stackView.isHidden = true
            header.collectionView.isHidden = true
            
            
            return header
        } else {
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
            
            if isFirstSegment {
                header.titleLabel.text = "Others"
                header.titleLabel.font = UIFont(name: "SFProDisplay-regular", size: 15)
                header.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showReviews)))
            } else {
                header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showReviews)))
                header.titleLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 17)
                header.titleLabel.text = "See All"
            }
            header.backgroundColor = .clear
            header.detailLabel.text = ""
            header.topView.isHidden = true
            header.bottomView.isHidden = true
        
            return header
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
           return 52
        } else if section == 2 {
            return 38
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFirstSegment {
            if (indexPath.section == 0 && indexPath.row == 0) || indexPath.section != 0 {
                var meal : Meal = Meal()
                if indexPath.section != 0 {
                    meal = indexPath.section == 1 ? activeMeals[indexPath.row] : otherMeals[indexPath.row]
                } else {
                    var featuredMeal = activeMeals.first(where: {$0.id == cafe.featured})
                    if featuredMeal == nil {
                        featuredMeal = otherMeals.first(where: {$0.id == cafe.featured})
                    }
                    if featuredMeal != nil {
                        meal = featuredMeal!
                    }
                }
                if meal.id.count > 0 {
                    self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
                    self.blurEffectView.isUserInteractionEnabled = true
                    self.blurEffectView.frame = self.view.bounds
                    self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    
                    mealDetailVC = UINib(nibName: "MealDetail", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MealDetail
                    mealDetailVC.frame = CGRect(x: 0, y: self.view.bounds.height/2-150, width:  self.view.bounds.width, height: 300)

                    
                    if meal.urls.count > 0 {
                        mealDetailVC.imageView.setImage(from: URL(string: meal.urls["standard"]!))
                    }
                    mealDetailVC.titleLabel.text = meal.title
                    mealDetailVC.detailLabel.text = meal.details
                    
                   let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(meal.price)₸")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray3, range: NSMakeRange(0, attributeString.length))
                    let attrString = NSMutableAttributedString(string: "   \(meal.discountedPrice)₸")
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "Main color")!, range: NSMakeRange(0, attrString.length))
                    attributeString.append(attrString)
                    if meal.price != meal.discountedPrice {
                        mealDetailVC.priceLabel.attributedText = attributeString
                    } else {
                        mealDetailVC.priceLabel.attributedText = attrString
                    }
                    
                    
                    
                    
                    if meal.discount == 0 {
                        mealDetailVC.discountlabel.text = ""
                        mealDetailVC.discountlabel.layer.borderColor = UIColor.clear.cgColor
                    } else {
                        mealDetailVC.discountlabel.text = "-\(meal.discount)%"
                        mealDetailVC.discountlabel.layer.borderColor = UIColor.red.cgColor
                        mealDetailVC.discountlabel.layer.borderWidth = 0.75
                        mealDetailVC.discountlabel.layer.cornerRadius = 6
                    }
                    
                    mealDetailVC.statusLabel.text = meal.lastAvailableText
                    mealDetailVC.statusLabel.textColor = meal.isAvailable ? UIColor(named: "Success color") : UIColor(named: "Muted text color")
                    mealDetailVC.layer.cornerRadius = 12
                        
                        
                    if meal.price != 0 {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        self.view.addSubview(self.blurEffectView)
                        self.view.bringSubviewToFront(self.blurEffectView)
                        self.view.addSubview(mealDetailVC)
                        
                        let transition = CATransition()
                        transition.duration = 0.4
                        transition.timingFunction = CAMediaTimingFunction(name: .default)
                        transition.type = .fade
                        self.view.layer.add(transition, forKey: nil)
                    }
                }
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @objc func showReviews(){
        self.performSegue(withIdentifier: "showReviews", sender: cafe.id)
    }
    
    
}


extension CafeViewController: TopHeaderProtocol, NewReviewProtocol {
    
    
    
    func sortCategory(_ category: String) {
        
    }
    
    
    
    func reloadData() {
        tableView.reloadData()
    }
    
    
    func addReview() {
        self.performSegue(withIdentifier: "addReview", sender: nil)
    }
    
    
    func segmentChanged(_ firstSegment: Bool) {
        isFirstSegment = !isFirstSegment
        fetchMeals()
        
        tableView.reloadData()
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        tableView.layer.add(transition, forKey: nil)

    }
    
    func optionsPressed(_ firstSegment: Bool) {
        
    }
    
    func filterPressed(_ firstSegment: Bool) {
        
    }
    
    func sortPressed(_ firstSegment: Bool) {
        
    }
    
    func categoriesPressed() {
        
    }
    
    func searchPressed(_ text: String) {
        
    }
    
    
}



extension CafeViewController {
    
    
    func fetchMeals(){
        Meal.getActive(cafeId: cafe.id) { (meals) in
            self.activeMeals = meals
            self.tableView.reloadData()
        }
        Meal.getOther(cafeId: cafe.id) { (meals) in
            self.otherMeals = meals
            self.tableView.reloadData()
        }
    }
    
    func fetchCafe(){
        Cafe.getOne(cafe.id) { (cafe) in
            if cafe.approved && cafe.notNull {
                self.cafe = cafe
                self.reviews = cafe.reviews ?? []
                self.tableView.reloadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: HIDE KEYBOARD WHEN TAPPED ELSEWHERE
extension CafeViewController {
    
    func hideKeyboard() {
        let uitap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        uitap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(uitap)
    }
    
    @objc override func dismissKeyboard() {
        if self.view.contains(mealDetailVC) {
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: .default)
            transition.type = .fade
            self.view.layer.add(transition, forKey: nil)
            self.mealDetailVC.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            tableView.reloadData()
        }
        view.endEditing(true)
    }
}

