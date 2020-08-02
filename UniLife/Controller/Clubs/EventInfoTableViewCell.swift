//
//  EventInfoTableViewCell.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/13/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import RealmSwift

protocol EventActionProtocol {
    func add()
    func remove()
    func share()
}

class EventInfoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clubImage: UIImageView!
    @IBOutlet weak var clubLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: EventActionProtocol!
    var eventId: String!
    var registration: [String: Any]? = [:] {
        didSet {
            if let registration = self.registration {
                let now = Int(Date().timeIntervalSince1970)
                if (registration["start"] as? Int ?? 0) < now && (registration["end"] as? Int ?? 0) > now {
                    registrationLabel.text = "Register via link"
                    registerButton.isHidden = false
                } else if (registration["start"] as? Int ?? 0) > now {
                    registrationLabel.text = "Register on" + Helper.displayDate24HourFull(timestamp: registration["start"] as? Int ?? 0)
                } else {
                    registrationLabel.text = "Registration closed"
                    registerButton.isHidden = true
                }
            } else {
                registrationLabel.text = "Registration not required"
                registerButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        shareButton.layer.cornerRadius = 20
        addButton.layer.cornerRadius = 20
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        if let registration = self.registration {
            let now = Int(Date().timeIntervalSince1970)
            if (registration["start"] as! Int) < now && (registration["end"] as! Int) > now {
                guard let link = URL(string: registration["link"] as? String ?? "") else { return }
                UIApplication.shared.open(link)
            }
        }
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        delegate.share()
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        if Constants.realm.object(ofType: Task.self, forPrimaryKey: eventId) != nil {
            delegate.remove()
        } else {
            delegate.add()
        }
    }
    

}
