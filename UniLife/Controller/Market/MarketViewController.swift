//
//  MarketViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/16/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase



class MarketViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var firstSegment = true
    var searchText = ""
    var gridItems = true
    let badgeLabel = UILabel(frame: CGRect(x: 36, y: -5, width: 18, height: 18))
    
    var selectedCategories : [String] = []
    var sortBy: String = "Date: newest to oldest"
    
    var liked = [String]()
    var featuredMeals = [Meal]()
    
    var allCafes : [Cafe] = [Cafe]()
    var cafes : [Cafe] = [Cafe]()
    let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    
    
    var allItems : [Item] = [Item]()
    var items : [Item] = [Item]()
    var dealItems : [Item] = [Item]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSegmentedControl()
        let defaults = UserDefaults.standard.array(forKey: "likedItems")
        liked = defaults == nil ? [] : defaults as! [String]
        setupTableView()
        fetchData()
        self.hideKeyboardWhenTappedAround()
        setupSearchBarController()
    }
    
    
    func addSegmentedControl(){
        let titles = ["Cafes", "Market"]
        let segmentControl = UISegmentedControl(items: titles)
        segmentControl.selectedSegmentIndex = 0
        for index in 0...titles.count-1 {
            segmentControl.setWidth(120, forSegmentAt: index)
        }
        addButton.isHidden = true
        badgeLabel.layer.borderColor = UIColor.clear.cgColor
        badgeLabel.layer.borderWidth = 2
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        badgeLabel.textAlignment = .center
        badgeLabel.layer.masksToBounds = true
        badgeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .red
        badgeLabel.text = "\(selectedCategories.count)"
        badgeLabel.isHidden = selectedCategories.count==0
        self.filterButton.addSubview(badgeLabel)
        filterButton.isHidden = true
        segmentControl.sizeToFit()
        segmentControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        navigationItem.titleView = segmentControl
    }
    
    
    @IBAction func addItemPressed(_ sender: Any) {
        if !firstSegment {
            performSegue(withIdentifier: "addItem", sender: nil)
        }
    }
    
    @IBAction func filterItems(_ sender: Any) {
        if !firstSegment {
            performSegue(withIdentifier: "showFilter", sender: nil)
        }
    }
    
    
    
    @objc func segmentedControlChanged(sender: UISegmentedControl){
        self.firstSegment = !firstSegment
        searchController.searchBar.placeholder = firstSegment ? "Search cafes" : "Search items"
        fetchData()
        tableView.reloadData()
        addButton.isHidden = firstSegment
        filterButton.isHidden = firstSegment
    }
    
    @objc func toTop(){
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if firstSegment, let duration: Float = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Float, let curve: Float = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Float {
            self.tableView.topConstraint?.constant = -(self.tableView.bounds.width/16*9 + 40)
            UIViewPropertyAnimator(duration: TimeInterval(duration), curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(curve))!) {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if firstSegment, let duration: Float = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Float, let curve: Float = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Float {
            self.tableView.topConstraint?.constant = 0
            UIViewPropertyAnimator(duration: TimeInterval(duration), curve: UIView.AnimationCurve(rawValue: UIView.AnimationCurve.RawValue(curve))!) {
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            let dest = segue.destination as! ItemViewController
            dest.item = sender as! Item
        } else if segue.identifier == "showCafe" {
            let dest = segue.destination as! CafeViewController
            dest.cafe = sender as! Cafe
        } else if segue.identifier == "showFilter" {
            let dest = segue.destination as! FilterViewController
            dest.delegate = self
            dest.selectedCategories = self.selectedCategories
            dest.sortBy = self.sortBy
        }
    }
}



extension MarketViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "TopHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TopHeader")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.firstSegment {
            if section != 2 {
                return section==0 ? 1 : cafes.count
            } else {
                return 0
            }
        } else {
            if section != 2 {
                if section == 0 {
                    return 1
                }
                return (searchText.count > 0 || selectedCategories.count > 0) ? 0 : 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MARK: CAFES
        if self.firstSegment {
            if indexPath.section == 0 {
                let adCell = tableView.dequeueReusableCell(withIdentifier: "topAdCell", for: indexPath) as! TopAdTableViewCell
                
                return adCell
            } else if indexPath.section == 1 {
                let cafeCell = tableView.dequeueReusableCell(withIdentifier: "cafeCell", for: indexPath) as! CafeTableViewCell
                
                let cafe = cafes[indexPath.row]
                
                cafeCell.titleLabel.text = cafe.title
                cafeCell.hoursLabel.text = cafe.opensAt
                cafeCell.hoursLabel?.textColor = cafe.opensColor
                cafeCell.logoImage.setImage(from: URL(string: cafe.urls["logo"] ?? ""))
                
                cafeCell.infoLabel.text = cafe.details
                cafeCell.ratingLabel.text = (NSString(format: "%.01f", cafe.rating) as String)
                
                
                return cafeCell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "cafeCell", for: indexPath) as! CafeTableViewCell
            }
        }
        //MARK: MARKET
        else {
            if indexPath.section == 0 {
                let adCell = tableView.dequeueReusableCell(withIdentifier: "topAdCell", for: indexPath) as! TopAdTableViewCell
                
                return adCell
            } else if indexPath.section == 1 {
                let dealItemsCell = tableView.dequeueReusableCell(withIdentifier: "dealCell", for: indexPath) as! DealTableViewCell
                
                dealItemsCell.delegate = self
                dealItemsCell.items = self.dealItems
                
                
                return dealItemsCell
            } else {
                let itemsCell = tableView.dequeueReusableCell(withIdentifier: "itemsCell", for: indexPath) as! ItemsTableViewCell
                
                
                itemsCell.gridItems = self.gridItems
                itemsCell.delegate = self
                itemsCell.items = self.items
                
                return itemsCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if firstSegment {
            if indexPath.section == 0 {
                return 0
            } else if indexPath.section == 1 {
                return 98
            } else {
                return 0
            }
        } else {
            if indexPath.section == 0 {
                return 0
            } else if indexPath.section == 1 {
                return (searchText.count > 0 || selectedCategories.count > 0 || dealItems.count == 0) ? 0 : 326
            } else {
                if !gridItems {
                    return CGFloat(self.items.count*132) + 72
                } else {
                    let height = (self.tableView.bounds.width-12)*2/3
                    if self.items.count % 2 == 0 {
                        return CGFloat(self.items.count)*height/2 + 72
                    } else {
                        return CGFloat(self.items.count/2+1)*height + 72
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if firstSegment && indexPath.section == 1 {
            performSegue(withIdentifier: "showCafe", sender: cafes[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}





//MARK:- Fetch and filter data
extension MarketViewController: filterItems {
    
    
    //MARK: FETCH DATA
    func fetchData(){
        if firstSegment {
            fetchFeaturedItem()
            fetchCafes()
        } else {
            fetchItems()
        }
    }
    
    
    
    //MARK: ITEMS
    func fetchItems(){
        Item.getDefaultItem { (items) in
            self.allItems.removeAll(where: {!$0.female})
            self.allItems.append(contentsOf: items)
            self.setDealItems()
            self.setRemainingItems()
            
            self.tableView.reloadData()
        }
        User.setupCurrentUser { (user) in
            if user.getIsFemale() {
                Item.getFemaleItems { (items) in
                    self.allItems.removeAll(where: {$0.female})
                    self.allItems.append(contentsOf: items)
                    self.setDealItems()
                    self.setRemainingItems()
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func setDealItems(){
        let sortedByDiscount = allItems.sorted { (first, second) -> Bool in
            return first.discountedPrice == 0 || second.discountedPrice == 0 || (first.requests.count <= second.requests.count && (first.discount <= second.discount))
        }
        
        self.dealItems = sortedByDiscount.filter({
            $0.price > $0.discountedPrice
            && $0.discountedPrice != -1
        })
    }
    
    
    func setRemainingItems(){
        self.items = self.allItems.filter { (item) -> Bool in
            var categories = selectedCategories
            if categories.contains("Free") {
                categories.removeAll(where: {$0 == "Free"})
                if categories.contains("Negotiable"){
                    categories.removeAll(where: {$0 == "Negotiable"})
                    if categories.contains("Sell"){
                        categories.removeAll(where: {$0 == "Sell"})
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == -1 || item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == -1 || item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == -1 || item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == -1 || item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    } else {
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == -1 || item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == -1 || item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == -1 || item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == -1 || item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    }
                } else {
                    if categories.contains("Sell"){
                        categories.removeAll(where: {$0 == "Sell"})
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    } else {
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == 0) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == 0) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    }
                }
            } else {
                if categories.contains("Negotiable"){
                    categories.removeAll(where: {$0 == "Negotiable"})
                    if categories.contains("Sell"){
                        categories.removeAll(where: {$0 == "Sell"})
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == -1) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && (item.discountedPrice == -1) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == -1) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && (item.discountedPrice == -1) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    } else {
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == -1) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && (item.discountedPrice == -1) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == -1) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    (item.discountedPrice == -1) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    }
                } else {
                    if categories.contains("Sell"){
                        categories.removeAll(where: {$0 == "Sell"})
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.sell && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    } else {
                        if categories.contains("Buy"){
                            categories.removeAll(where: {$0 == "Buy"})
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) && !item.sell && !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        } else {
                            if categories.contains("Ladies"){
                                categories.removeAll(where: {$0 == "Ladies"})
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    item.female && (categories.count == 0 || categories.contains(item.category))
                            } else {
                                return (searchText.count == 0 || item.title.lowercased().contains(searchText.lowercased())) &&
                                    !item.female && (categories.count == 0 || categories.contains(item.category))
                            }
                        }
                    }
                }
            }
        }
        self.items.sort { (item1, item2) -> Bool in
            switch sortBy {
            case "Date: oldest to newest":
                return item2.lastActive > item1.lastActive
            case "Price: high to low":
                return item1.discountedPrice > item2.discountedPrice
            case "Price: low to high":
                return item1.discountedPrice < item2.discountedPrice
            default:
                return item1.lastActive > item2.lastActive
            }
        }
    }
    
    
    func filter(categories: [String], sort: String) {
        self.selectedCategories = categories
        badgeLabel.text = "\(selectedCategories.count)"
        badgeLabel.isHidden = selectedCategories.count==0
        self.sortBy = sort
        self.fetchItems()
    }
    
    func setCategories(){
        if searchText.count > 0 {
            self.items = allItems.filter({$0.title.lowercased().contains(searchText.lowercased())})
        } else {
            self.items = allItems
        }
    }
    
    
    
    //MARK: CAFES
    func fetchCafes(){
        Cafe.getAll { (cafes) in
            self.allCafes = cafes
            self.filterCafes(text: "")
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: CAFES
    func fetchFeaturedItem(){
//        Constants.rootRef.child("featured").observe(.value) { (snapshot) in
//            var index = 0
//            for child in snapshot.children {
//                let featured = child as! DataSnapshot
//                Constants.mealsRef.child(featured.key).child(featured.value as! String).observe(.value) { (mealSnapshot) in
//                    self.featuredMeals.append(Meal(snapshot: mealSnapshot, cafeId: featured.key))
//                    index += 1
//                    if snapshot.childrenCount == index {
//                        self.tableView.reloadSections([0], with: .automatic)
//                    }
//                }
//            }
//        }
    }
    
    
    //MARK: CAFES
    func filterCafes(text: String){
        if text.count > 0 {
            cafes = allCafes.filter( {$0.title.lowercased().contains(text.lowercased())} )
        } else {
            cafes = allCafes
        }
    }
}


//MARK:- Items Protocols
extension MarketViewController: ItemsTableViewCellProtocol {
    
    func selectedItem(_ item: Item) {
        performSegue(withIdentifier: "showItem", sender: item)
    }
    
    func changeState(){
        self.gridItems = !gridItems
        tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
    }
    
}

//MARK:- Setup search controller
extension MarketViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    
    //MARK: Setup search bar
    func setupSearchBarController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cafes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    
    //MARK: Update search results
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    // MARK: Get searched courses
    func filterContentForSearchText(_ searchText: String) {
        if firstSegment {
            self.searchText = searchText
            filterCafes(text: searchText)
            tableView.reloadSections([1], with: .automatic)
        } else {
            self.searchText = searchText
            fetchItems()
        }
    }
    
    
    //MARK: Check search bar
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    //MARK: Is filtering
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
}
