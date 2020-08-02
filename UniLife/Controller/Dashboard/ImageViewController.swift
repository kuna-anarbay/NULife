//
//  ImageViewController.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 12/15/19.
//  Copyright © 2019 Kuanysh Anarbay. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: UIViewController {

    
    var imageView = UIImageView()
    var storageRef : StorageReference!
    var url: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .secondarySystemBackground
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        imageView.contentMode = .scaleAspectFit
        imageView.setImage(from: URL(string: url))
        imageView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        self.view.addSubview(imageView)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
