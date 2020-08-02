//
//  Extension.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/3/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SPAlert


extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}



// MARK: HIDE KEYBOARD WHEN TAPPED ELSEWHERE
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//MARK: SHOW ALERT
extension UIViewController {
    
    static public func getAlert() -> UIAlertController {
        let alertVC = UIAlertController(
            title: nil,
            message: "Please wait",
            preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        alertVC.view.addSubview(loadingIndicator)
        
        return alertVC
    }

    static public func getAlert(_ text: String) -> UIAlertController {
        let alertVC = UIAlertController(
            title: text,
            message: nil,
            preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        alertVC.view.addSubview(loadingIndicator)
        
        return alertVC
    }
    
    static public func getAlertWithCancelButton(_ text: String) -> UIAlertController {
        let alertVC = UIAlertController(
            title: text,
            message: nil,
            preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        return alertVC
    }
    
    
    static public func actionAlert(_ text: String, completion: @escaping() -> Void) -> UIAlertController {
        let alertVC = UIAlertController(
            title: text,
            message: nil,
            preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            completion()
        }))
        
        return alertVC
    }
    
    static public func getErrorAlert() -> UIAlertController {
        let alertVC = UIAlertController(
            title: nil,
            message: "Waiting for network ...",
            preferredStyle: .alert)
        alertVC.view.tintColor = .systemRed
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        alertVC.view.addSubview(loadingIndicator)
        
        return alertVC
    }
    
    static public func getEmptyAlert(_ title: String? = nil, _ text: String) -> UIAlertController {
        let alertVC = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert)
        alertVC.view.tintColor = UIColor(named: "TintColor")
        
        return alertVC
    }
    
}


extension UIViewController {
    
    
    enum courseDetailState {
        case add
        case edit
        case remove
        case deadline
        case event
    }
    
    enum selectorState {
        case color
        case all
    }
    
    
    enum courseSectionsState {
        case questions
        case deadlines
        case resources
    }
    
    
    enum newQuestionState {
        case normal
        case editing
        case resource
    }
    
    enum showListState {
        case locations
        case professors
        case topics
    }
    
    enum pickerState {
        case assessment
        case semester
        case reminder
    }
    
    
    enum filterState {
        case date
        case high
        case low
    }
    
    
    enum profileState {
        case categories
        case help
        case booking
    }
    
}

public class EdgeShadowLayer: CAGradientLayer {

    public enum Edge {
        case Top
        case Left
        case Bottom
        case Right
    }

    public init(forView view: UIView,
                edge: Edge = Edge.Top,
                shadowRadius radius: CGFloat = 20.0,
                toColor: UIColor = UIColor.white,
                fromColor: UIColor = UIColor.black) {
        super.init()
        self.colors = [fromColor.cgColor, toColor.cgColor]
        self.shadowRadius = radius

        let viewFrame = view.frame

        switch edge {
            case .Top:
                startPoint = CGPoint(x: 0.5, y: 0.0)
                endPoint = CGPoint(x: 0.5, y: 1.0)
                self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
            case .Bottom:
                startPoint = CGPoint(x: 0.5, y: 1.0)
                endPoint = CGPoint(x: 0.5, y: 0.0)
                self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
            case .Left:
                startPoint = CGPoint(x: 0.0, y: 0.5)
                endPoint = CGPoint(x: 1.0, y: 0.5)
                self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
            case .Right:
                startPoint = CGPoint(x: 1.0, y: 0.5)
                endPoint = CGPoint(x: 0.0, y: 0.5)
                self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//MARK: Preview docs and images
extension UIViewController: UIDocumentInteractionControllerDelegate {
    
    
    /// This function will set all the required properties, and then provide a preview for the document
    func share(url: URL, title: String, controller: UIDocumentInteractionController, contentType: String) {
        controller.url = url
        let contentTypes = ["pdf": "com.adobe.pdf", "doc": "com.microsoft.word.doc", "docx": "org.openxmlformats.wordprocessingml.document"]
        
        if contentType.count > 0 {
            controller.uti = contentTypes[contentType]
        } else {
            controller.uti = "com.adobe.pdf"
        }
        controller.name = title
        if !(self.navigationController?.topViewController?.isKind(of: UIDocumentInteractionController.self) ?? true) {
            controller.presentPreview(animated: true)
        } else if self.navigationController == nil {
            print("hrerere")
            controller.presentPreview(animated: true)
        }
    }
    
    // This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(name: String, ref: StorageReference, controller:  UIDocumentInteractionController, contentType: String) {
        let alert = UIViewController.getAlert("Loading file")
        ref.downloadURL { (url, error) in
            if error == nil {
                self.present(alert, animated: true, completion: nil)
                /// START YOUR ACTIVITY INDICATOR HERE
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else {
                        alert.dismiss(animated: true, completion: nil)
                        return
                    }
                    let tmpURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(response?.suggestedFilename ?? "fileName.pdf")
                    do {
                        try data.write(to: tmpURL)
                    } catch {
                        alert.dismiss(animated: true) {
                            SPAlert.present(message: "No syllabus found")
                        }
                    }
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            self.share(url: tmpURL, title: name, controller: controller, contentType: contentType)
                        }
                    }
                }.resume()
            } else {
                alert.dismiss(animated: true) {
                    SPAlert.present(message: "No syllabus found")
                }
            }
        }
    }
    
    
    // This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(name: String, url: URL, controller:  UIDocumentInteractionController, contentType: String) {
        let alert = UIViewController.getAlert("Loading file")
        self.present(alert, animated: true, completion: nil)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                alert.dismiss(animated: true, completion: nil)
                return
            }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.pdf")
            do {
                try data.write(to: tmpURL)
            } catch {
                alert.dismiss(animated: true) {
                    SPAlert.present(message: "No syllabus found")
                }
            }
            DispatchQueue.main.async {
                alert.dismiss(animated: true) {
                    self.share(url: tmpURL, title: name, controller: controller, contentType: contentType)
                }
            }
        }.resume()
    }
    
    
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        
        return navVC
    }
    
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController!) -> UIViewController! {
        return self
    }

    private func documentInteractionControllerViewForPreview(controller: UIDocumentInteractionController!) -> UIView! {
        return self.view
    }

    public func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.frame
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}



extension UIView {
    
    func addShadow(radius: CGFloat){
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.5
    }
    
    func addShadow(radius: CGFloat, Offset: CGFloat){
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: Offset, height: Offset)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.5
    }
    
    func addShadow(radius: CGFloat, Offset: CGFloat, opacity: CGFloat){
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: Offset, height: Offset)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = 0.5
    }
}
