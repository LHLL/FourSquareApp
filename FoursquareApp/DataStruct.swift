//
//  DataStruct.swift
//  FoodNearBySwift
//
//  Created by Jay on 1/8/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import Foundation
import CoreLocation
struct dataStruct {
    var storeName:String
    var storeAddress:String
    var storeLocation:CLLocation
    var storeStatus:String
    var storePhone:String
    var categoryIconURL:String
    var storeMenu:String
    var storePrice:String
    var storeCatgory:String
    var storeTime:String
    var storeRating:String
    
    init(name:String,address:String,status:String,location:CLLocation,phoneNum:String,iconURL:String,menu:String,price:String,category:String,businessTime:String,rating:String){
        self.storeName = name
        self.storeAddress = address
        self.storeStatus = status
        self.storeLocation = location
        self.storePhone = phoneNum
        self.categoryIconURL = iconURL
        self.storeMenu = menu
        self.storePrice = price
        self.storeCatgory = category
        self.storeTime = businessTime
        self.storeRating = rating
    }
}
