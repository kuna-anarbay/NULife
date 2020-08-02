//
//  LandingViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/24/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class LandingViewController: UIViewController {

    // MARK: - Properties (Private)
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var clubs = [Club(), Club(), Club(), Club(), Club(), Club()]
    var events = [ClubEvent(), ClubEvent(), ClubEvent(), ClubEvent(), ClubEvent()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        addCarousel()
        setupTableView()
        fetchClubs()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func showEvents(_ sender: Any) {
        self.performSegue(withIdentifier: "showClubs", sender: false)
    }
    
    
    
    // MARK: - Configuration
    
    private func addCarousel() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = CityCollectionViewFlowLayout(itemSize: CGSize(width: self.collectionView.bounds.width/2, height: self.collectionView.bounds.width*2*0.9/3), lineSpacing: collectionView.bounds.width/16)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showClubs" {
            let dest = segue.destination as! ClubsViewController
            dest.clubsState = sender as! Bool
        } else if segue.identifier == "showClub" {
            let dest = segue.destination as! ClubViewController
            dest.club = sender as! Club
        } else if segue.identifier == "showEvent" {
            let dest = segue.destination as! ClubEventViewController
            dest.event = sender as! ClubEvent
        }
    }
    

}


extension LandingViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        let sectionHeader = UINib(nibName: "SectionHeader", bundle: nil)
        tableView.register(sectionHeader, forHeaderFooterViewReuseIdentifier: "customSectionHeader")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 1 : clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
        } else {
            let clubCell = tableView.dequeueReusableCell(withIdentifier: "clubCell", for: indexPath) as! ClubTableViewCell
            let club = clubs[indexPath.row]
            
            clubCell.clubName.text = club.title
            clubCell.mainImage.setImage(from: URL(string: club.urls["logo"] ?? ""))
            
            return clubCell
        }
        

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section==0 ? self.collectionView.bounds.width*2/3+73 : 72
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            backView.topConstraint?.constant = tableView.contentOffset.y*(-1)
        }
    }
    
    
    //MARK: HEADER
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "customSectionHeader") as! SectionHeader
              
        header.titleLabel.text = "My Clubs"
        header.detailLabel.textColor = UIColor(named: "Text color")
        header.titleLabel.font = UIFont(name: "SfProDisplay-semibold", size: 20)
        header.backView.backgroundColor = .systemBackground
        header.backgroundColor = .systemBackground
        header.detailLabel.text = "All clubs"
        header.detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showClubs)))
        header.detailLabel.isUserInteractionEnabled = true
        header.detailLabel.textColor = UIColor(named: "Main color")
        header.detailLabel.font = UIFont(name: "SfProDisplay-medium", size: 17)
        header.topView.isHidden = true
        header.bottomView.isHidden = true
    
        return section==0 ? nil : header
    }
    
    
    @objc func showClubs(){
        self.performSegue(withIdentifier: "showClubs", sender: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section==0 ? 0 : 60
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showClub", sender: clubs[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}




extension LandingViewController {
    
    func fetchEvents(){
        ClubEvent.getAll(self.clubs.map({ (club) -> String in
            return club.id
        })) { (events) in
            self.events = events.sorted(by: { (event1, event2) -> Bool in
                return event2.start > event1.start
            })
            self.collectionView.reloadData()
        }
    }
    
    func fetchClubs(){
        Club.getUserClubs { (clubs) in
            self.clubs = clubs
            self.fetchEvents()
            self.tableView.reloadData()
        }
    }
}



extension LandingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let scalingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! ClubEventCollectionViewCell
        
        let event = events[indexPath.row]
        
        scalingCell.titleLabel.text = event.title
        scalingCell.locationLabel.text = event.location
        
        if event.end == 0 {
            scalingCell.startLabel.text = Helper.display24HourTime(timestamp: event.start)
        } else {
            scalingCell.startLabel.text = Helper.display24HourTime(timestamp: event.start) + "-" + Helper.display24HourTime(timestamp: event.end)
        }
        scalingCell.endLabel.text = Helper.displayDayMonth(timestamp: event.start)
        scalingCell.imageView.contentMode = .scaleAspectFill
        if event.urls.count > 0 {
            scalingCell.imageView.setImage(from: URL(string: event.urls[0]))
        }

        scalingCell.layer.cornerRadius = 8
        
        
        return scalingCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "showEvent", sender: events[indexPath.row])
    }
    
    
}


class CityCollectionViewFlowLayout: UICollectionViewFlowLayout {

    fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
    
    var scaleOffset: CGFloat = 200
    var scaleFactor: CGFloat = 0.9
    var alphaFactor: CGFloat = 0.3
    var lineSpacing: CGFloat = 8
    
    required init?(coder _: NSCoder) {
        fatalError()
    }
    
    init(itemSize: CGSize, lineSpacing: CGFloat) {
        super.init()
        self.itemSize = itemSize
        minimumLineSpacing = self.lineSpacing
        scrollDirection = .horizontal
    }
    
    func setItemSize(itemSize: CGSize) {
        self.itemSize = itemSize
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        guard let collectionView = self.collectionView else { return }
        
        if collectionView.bounds.size != lastCollectionViewSize {
            configureContentInset()
            lastCollectionViewSize = collectionView.bounds.size
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let layoutAttributes = self.layoutAttributesForElements(in: proposedRect) else {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionView.bounds.width / 2
        
        for attributes in layoutAttributes {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        guard let aCandidateAttributes = candidateAttributes else {
            return proposedContentOffset
        }
        
        var newOffsetX = aCandidateAttributes.center.x - collectionView.bounds.size.width / 2
        let offset = newOffsetX - collectionView.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = itemSize.width + minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView,
            let superAttributes = super.layoutAttributesForElements(in: rect) else {
                return super.layoutAttributesForElements(in: rect)
        }
        
        let contentOffset = collectionView.contentOffset
        let size = collectionView.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        guard case let newAttributesArray as [UICollectionViewLayoutAttributes] = NSArray(array: superAttributes, copyItems: true) else {
            return nil
        }
        
        newAttributesArray.forEach {
            let distanceFromCenter = visibleCenterX - $0.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scaleOffset)
            let scale = absDistanceFromCenter * (self.scaleFactor - 1) / self.scaleOffset + 1
            $0.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            
            let alpha = absDistanceFromCenter * (self.alphaFactor - 1) / self.scaleOffset + 1
            $0.alpha = alpha
        }
        
        return newAttributesArray
    }
    
    func configureContentInset() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.contentOffset = CGPoint(x: -inset, y: 0)
    }
    
    func resetContentInset() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}
