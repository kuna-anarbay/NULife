//
//  ColorAndIconViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 11/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit

protocol SelectIconAndColorProtocol {
    func select(event: Event)
}

class ColorAndIconViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var navTitle: UINavigationItem!
    var delegate : SelectIconAndColorProtocol!
    var color_tag = 1
    var icon_tag = 13
    var new_event : Event!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup_design()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectColorAndIcon))
        stackView.addGestureRecognizer(tapGesture)

    }
    
    
    
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.select(event: self.new_event)
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    //MARK: Set design of stack view
    func setup_design(){
        for i in 1 ... 42 {
            let sub_view = (stackView.viewWithTag(i)!)
            if i > 0 && i <= 12 {
                sub_view.backgroundColor = UIColor(hexString: staticList.colors[i-1])
                sub_view.viewWithTag(0)?.tintColor = .white
                if new_event.color == staticList.colors[i-1] {
                    (sub_view.viewWithTag(0) as! UIImageView).image = UIImage(systemName: "checkmark")
                } else {
                    (sub_view.viewWithTag(0) as! UIImageView).image = nil
                }
            } else {
                (sub_view.viewWithTag(0) as! UIImageView).image = UIImage(systemName: staticList.icons[i-13])
                if new_event.icon == staticList.icons[i-13] {
                    sub_view.backgroundColor = UIColor(named: "Main color")
                    sub_view.viewWithTag(0)?.tintColor = .white
                } else {
                    sub_view.backgroundColor = .secondarySystemBackground
                    sub_view.viewWithTag(0)?.tintColor = UIColor(named: "Muted text color")
                }
            }
            sub_view.layer.cornerRadius = sub_view.bounds.width / 2
        }
    }
    
    
    
    //MARK: Select color tap gesture
    @objc func selectColorAndIcon(sender: UITapGestureRecognizer) {
        let location = sender.location(in: stackView)
        let x_axis = location.x/( self.stackView.bounds.width/6)
        let y_axis = location.y/( self.stackView.bounds.height/7)
        let tag_index = Int(x_axis) + 6 * Int(y_axis)
        
        if tag_index < 12 {
            new_event.color = staticList.colors[Int(tag_index)]
        } else {
            new_event.icon = staticList.icons[Int(tag_index) - 12]
        }
        
        
        
        setup_design()
    }
}
