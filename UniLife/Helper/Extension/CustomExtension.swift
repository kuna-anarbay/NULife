//
//  CustomExtension.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 2/10/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//MARK: UIColor extension
extension UIColor {
    static let main = UIColor(named: "Main color")
    
    
    static func by(name: String) -> UIColor? {
        switch name {
        case "location":
            return UIColor.systemIndigo
        case "email":
            return UIColor.systemOrange
        case "phone":
            return UIColor.systemGreen
        case "link":
            return UIColor.link
        default:
            return nil
        }
    }
}


//MARK: UIImageView extension
extension UIImageView {
    func setImage(from url: URL?){
        self.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached, context: nil)
    }
}


//MARK: UIImage extension
extension UIImage {
    
    static func by(name: String) -> UIImage? {
        return UIImage(named: name)
    }
}


//MARK: UIAlertController extension
protocol AlertViewControllerDelegate {
    func selectedRow(row: Int)
    func selectedString(string: String)
}


class AlertViewController: UIAlertController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var list: [String] = [] {
        didSet {
            self.actionSheet()
        }
    }
    var currentIndex : Int? = 0
    
    var delegate : AlertViewControllerDelegate!
    
    func actionSheet(){
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-16, height: 280))
        picker.selectRow(currentIndex ?? 0, inComponent: 0, animated: true)
        picker.delegate = self
        
        self.view.addSubview(picker)
        self.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (_) in
            self.delegate.selectedRow(row: picker.selectedRow(inComponent: 0))
            self.delegate.selectedString(string: self.list[picker.selectedRow(inComponent: 0)])
        }))
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}


extension UIAlertController {
    
    static func getActionSheet(list: [String], selectedIndex: Int?) -> AlertViewController{
        let sheet = AlertViewController(title: "Select your section", message: nil, preferredStyle: .actionSheet)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: sheet.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 330)
        sheet.view.addConstraint(height)
        sheet.currentIndex = selectedIndex
        sheet.list = list
        
        return sheet
    }
}
