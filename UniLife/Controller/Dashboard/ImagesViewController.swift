//
//  ImagesViewController.swift
//  gostudy
//
//  Created by Kuanysh Anarbay on 10/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ImagesViewController: UIPageViewController {

    
    //MARK: VARIABLES AND CONSTANTS
    var storageRef : StorageReference!
    var refs = [String]()
    var labelBtn = UIButton()
    
    
    //MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .secondarySystemBackground
        let button = UIButton(frame: CGRect(x: self.view.bounds.width-96, y: self.view.bounds.height-44, width: 72, height: 30))
        button.setTitle("Close", for: .normal)
        button.backgroundColor = UIColor(named: "Main color")
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        
        labelBtn = UIButton(frame: CGRect(x: 16, y: self.view.bounds.height-44, width: 72, height: 30))
        labelBtn.setTitle("1 of \(refs.count)", for: .normal)
        labelBtn.backgroundColor = UIColor(named: "Main color")
        labelBtn.layer.cornerRadius = 8
        labelBtn.setTitleColor(.white, for: .normal)
        self.view.addSubview(labelBtn)
        //TODO: SETUP BACKGROUND
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        
        //TODO: SETUP APPEARANCE
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.backgroundColor = UIColor.secondarySystemBackground
        appearance.currentPageIndicatorTintColor = UIColor(hexString: "#3237AF")
        
        
        
        //TODO: SETUP DATASOURSE
        dataSource = self
        
        
        //TODO: SETUP VIEW CONTROLLERS
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                animated: true,
                completion: nil)
        }
        
    }
    
    
    
    @objc func close(sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    //MARK: VIEW WILL DISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK: SETUP VIEW BY ORDER
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var images : [UIViewController] = []
        for url in refs {
            var vc = ImageViewController()
            vc.url = url
            images.append(vc)
        }
        return images
    }()

}


// MARK:- UIPageViewControllerDataSource
extension ImagesViewController: UIPageViewControllerDataSource {
    
    //MARK: VIEW CONTROLLER BEFORE
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        labelBtn.setTitle("\(previousIndex+2) of \(refs.count)", for: .normal)
        
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    
    //MARK: VIEW CONTROLLER AFTER
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        labelBtn.setTitle("\(nextIndex) of \(refs.count)", for: .normal)
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
