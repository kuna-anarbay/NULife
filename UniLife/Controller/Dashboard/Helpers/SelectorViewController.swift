//
//  SelectorViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/8/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit


protocol SelectorViewControllerProtocol {
    func selectColor(at color: String)
    func selectColorAndIcon(at color: String, at icon: String)
}



class SelectorViewController: UIViewController {

    
    @IBOutlet weak var stackView: UIStackView!
    var currentState: selectorState = .all
    var delegate: SelectorViewControllerProtocol?
    var color: String = staticList.colors[0]
    var icon: String = staticList.icons[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupDesign()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectColorAndIcon))
        stackView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    func setupDesign(){
        switch currentState {
            case .all:
                title = "Select color & icon"
            default:
                title = "Select color"
        }

        (stackView.arrangedSubviews as! [UIStackView]).forEach { (subStackView) in
            subStackView.arrangedSubviews.forEach { (subView) in
                subView.layer.cornerRadius = subView.frame.width / 2
            }
        }
        
        setupStackView()
    }
    

    @IBAction func donePressed(_ sender: Any) {
        switch currentState {
            case .all:
                delegate?.selectColorAndIcon(at: color, at: icon)
            default:
                delegate?.selectColor(at: color)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



//MARK:- Setup STACK VIEW
extension SelectorViewController {
    
    
    func setupStackView(){
        switch currentState {
        case .all:
            for i in 1 ... 42 {
                let sub_view = (stackView.viewWithTag(i)!)
                sub_view.layer.cornerRadius = (sub_view.bounds.width + sub_view.bounds.height) / 4
                
                if i > 0 && i <= 12 {
                    sub_view.backgroundColor = UIColor(hexString: staticList.colors[i-1])
                    
                    if self.color == staticList.colors[i-1] {
                        sub_view.layer.borderWidth = 8
                        sub_view.layer.borderColor = UIColor.lightText.cgColor
                    } else {
                        sub_view.layer.borderColor = nil
                    }
                } else {
                    (sub_view.viewWithTag(0) as! UIImageView).preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
                    (sub_view.viewWithTag(0) as! UIImageView).image = UIImage(systemName: staticList.icons[i-13], withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
                    sub_view.viewWithTag(0)?.tintColor = .white
                    
                    
                    if self.icon == staticList.icons[i-13] {
                        sub_view.layer.borderWidth = 8
                        sub_view.layer.borderColor = UIColor.lightText.cgColor
                    } else {
                        sub_view.layer.borderColor = nil
                    }
                }
            }
            break
        default:
            for i in 1 ... 12 {
                let sub_view = (stackView.viewWithTag(i)!)
                sub_view.backgroundColor = UIColor(hexString: staticList.colors[i-1])
                sub_view.layer.cornerRadius = (sub_view.bounds.width + sub_view.bounds.height) / 4
                
                if self.color == staticList.colors[i-1] {
                    sub_view.layer.borderWidth = 5
                    sub_view.layer.borderColor = UIColor.lightText.cgColor
                } else {
                    sub_view.layer.borderWidth = 0
                }
            }
            break
        }
        
    }
    
    
    //MARK: Select color tap gesture
    @objc func selectColorAndIcon(sender: UITapGestureRecognizer) {
        let location = sender.location(in: stackView)
        let x_axis = location.x/( self.stackView.bounds.width/6)
        let y_axis = location.y/( self.stackView.bounds.height/7)
        let tag_index = Int(x_axis) + 6 * Int(y_axis)
        
        switch currentState {
            case .all:
                if tag_index < 12 {
                    self.color = staticList.colors[Int(tag_index)]
                } else {
                    self.icon = staticList.icons[Int(tag_index) - 12]
                }
            default:
                if tag_index < 12 {
                    self.color = staticList.colors[Int(tag_index)]
                }
        }
        setupStackView()
    }
}
