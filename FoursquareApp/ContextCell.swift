//
//  ContextCell.swift
//  FoodNearBySwift
//
//  Created by Jay on 1/8/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ContextCell: UITableViewCell{
    
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeDistance: UILabel!
    @IBOutlet weak var storeStatus: UILabel!
    @IBOutlet weak var categryIcon: UIImageView!
    
    
    func configureUIElements(dataForRow:dataStruct,userLocation:CLLocation){
        self.storeName.text = dataForRow.storeName
        self.storeStatus.text = dataForRow.storeStatus
        
        let imageData = NSData(contentsOfURL:NSURL(string: dataForRow.categoryIconURL)!)
        let categoryImage = UIImage(data: imageData!)
        self.categryIcon.image = categoryImage
        
        let distance = userLocation.distanceFromLocation(dataForRow.storeLocation)/1600
        let distanceStr = String(format: "%0.1f mi", distance)
        self.storeDistance.text = distanceStr
    }
    
}

