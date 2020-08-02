//
//  HelpViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/26/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase


class HelpViewController: UIPageViewController {

    
    
    var ref : StorageReference!
    var count: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                animated: true,
                completion: nil)
        }
    }
    

    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers = [UIViewController]()
        for i in 0..<self.count {
            viewControllers.append(self.newColoredViewController(i))
        }
        
        return viewControllers
    }()

    private func newColoredViewController(_ index: Int) -> UIViewController {
        let vc = UIViewController()
        let imageView = UIImageView(frame: vc.view.frame)
        imageView.sd_setImage(with: ref.child("\(index)"))
        vc.view.addSubview(imageView)
        return vc
    }

}


extension HelpViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}
