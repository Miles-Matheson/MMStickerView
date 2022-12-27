//
//  MMPhotoStickItem.swift
//  ImageCut
//
//  Created by Miles on 2022/12/2.
//

import UIKit

public class MMPhotoStickItem:NSObject{
    
    public init(image:UIImage,section:Int){
        self.image = image
        self.section = section
    }
    public var image:UIImage
    public var section:Int
}
