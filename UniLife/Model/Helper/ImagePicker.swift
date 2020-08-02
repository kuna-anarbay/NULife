//
//  ImagePicker.swift
//  UniLife
//
//  Created by Kuanysh Anarbay on 1/29/20.
//  Copyright © 2020 Kuanysh Anarbay. All rights reserved.
//

import Foundation
import YPImagePicker


class ImagePicker {
    static func getYPImagePicker()-> YPImagePicker {
       var config = YPImagePickerConfiguration()
       config.library.onlySquare = false
       config.onlySquareImagesFromCamera = false
       config.targetImageSize = .original
       config.library.maxNumberOfItems = 5
       config.usesFrontCamera = true
       config.showsPhotoFilters = false
       config.shouldSaveNewPicturesToAlbum = true
       config.albumName = "NULife"
       config.screens = [.library, .photo]
       config.startOnScreen = .library
       config.wordings.libraryTitle = "Gallery"
       config.hidesStatusBar = false
       
       let picker = YPImagePicker(configuration: config)
       picker.navigationBar.tintColor = UIColor(named: "Main color")
       picker.navigationController?.navigationBar.tintColor = UIColor(named: "Main color")
       
       return picker
   }
   
   
   static func getYPImagePicker(_ count: Int)-> YPImagePicker {
       var config = YPImagePickerConfiguration()
       config.library.onlySquare = false
       config.onlySquareImagesFromCamera = false
       config.targetImageSize = .original
       config.library.maxNumberOfItems = count
       config.usesFrontCamera = true
       config.showsPhotoFilters = false
       config.shouldSaveNewPicturesToAlbum = true
       config.albumName = "NULife"
       config.screens = [.library, .photo]
       config.startOnScreen = .library
       config.wordings.libraryTitle = "Gallery"
       config.hidesStatusBar = false
       
       let picker = YPImagePicker(configuration: config)
       picker.navigationBar.tintColor = UIColor(named: "Main color")
       picker.navigationController?.navigationBar.tintColor = UIColor(named: "Main color")
       
       return picker
   }
}
