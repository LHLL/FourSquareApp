//
//  DownLoadModel.swift
//  FoodNearBySwift
//
//  Created by Jay on 1/8/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import Foundation
import CoreLocation


class Downlode {
    var dataStructArr = [dataStruct]()
    weak var delegate : errorHandler?
    weak var dataSource : dataHandler?
    func startFetchingDataFromFourSquare(urlString:String){
        self.dataStructArr.removeAll()
        if let targetURL = NSURL(string: urlString){
            let request = NSURLRequest(URL: targetURL)
            let session = NSURLSession.sharedSession()
            let downloadTask = session.downloadTaskWithRequest(request) { (dataLocationURL, URLResponse, dataError) -> Void in
                do{
                    let data = NSData(contentsOfURL: dataLocationURL!)
                    let firstDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    let responseDict = firstDict.objectForKey("response") as! [String : AnyObject]
                    let groupArray = responseDict["groups"] as! [AnyObject]
                    let groupDict = groupArray[0] as! [String: AnyObject]
                    let itemArray = groupDict["items"] as! [AnyObject]
                    for itemDict in itemArray {
                        var iconURL = " "
                        var status = " "
                        var phoneNum = " "
                        var address = " "
                        var menu = "No menu offered."
                        var price = "No price classification offered."
                        var storeBusinessTime = "No business time offered."
                        var category = "No category offered."
                        var currentRating = "Try to be the first rates this store!"
                        var location = CLLocation(latitude: 0, longitude: 0)
                        
                        let venueDict = itemDict["venue"] as! [String:AnyObject]
                        
                        let name = venueDict["name"] as! String
                        
                        if let contactDict = venueDict["contact"] as? [String: AnyObject]{
                            if ((contactDict["formattedPhone"] as? String) != nil){
                                phoneNum = contactDict["formattedPhone"] as! String
                            }
                        }
                        
                        if let locationDict = venueDict["location"] as? [String: AnyObject]{
                            if let street = locationDict["address"] as? String{
                                if let city = locationDict["city"] as? String{
                                    if let state = locationDict["state"] as? String{
                                        let space = ","
                                        address = street + space + city + space + state
                                    }
                                }
                            }
                            if let lat = locationDict["lat"] as? Double{
                                if let lng = locationDict["lng"] as? Double{
                                    location = CLLocation(latitude: lat, longitude: lng)
                                }
                            }
                            
                        }
                        
                        if let menuDict = venueDict["menu"] as? [String: String]{
                            menu = menuDict["mobileUrl"]!
                        }
                        
                        if let priceDict = venueDict["price"] as? [String: AnyObject]{
                            if let priceExist = priceDict["message"] as? String{
                                price = priceExist
                            }else{
                                price = "No price offered"
                            }
                        }
                        
                        if let categoriesArr = venueDict["categories"] as? [AnyObject]{
                            if let categoriesDict = categoriesArr[0] as? [String: AnyObject]{
                                if let iconDict = categoriesDict["icon"] as? [String: AnyObject]{
                                    if let prefix = iconDict["prefix"] as? String{
                                        if let suffix = iconDict["suffix"] as? String{
                                            let middle = "bg_88"
                                            iconURL = prefix+middle+suffix
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        if let hoursDict = venueDict["hours"] as? [String:AnyObject]{
                            if let isOpen = hoursDict["isOpen"] as? Bool{
                                if isOpen == true {
                                    status = "open Now"
                                }else {
                                    status = "closed Now"
                                }
                                
                            }else{
                                status = "Info not offered"
                            }
                            
                            if let storeStatus = hoursDict["status"] as? String{
                                storeBusinessTime = storeStatus
                            }
                        }
                        
                        if let categoryArr = venueDict["categories"] as? [AnyObject]{
                            let categoryDict = categoryArr[0]
                            if let str = categoryDict["name"] as? String{
                                category = str
                            }
                        }
                        
                        if let rate = venueDict["rating"] as? Double{
                            if let rateNum = venueDict["ratingSignals"] as? Int{
                                currentRating = "Average score is \(rate), based on \(rateNum) ratings."
                            }
                        }
                        
                        
                        let data = dataStruct(name: name, address: address, status: status, location: location, phoneNum: phoneNum, iconURL: iconURL,menu: menu,price: price,category: category, businessTime: storeBusinessTime,rating: currentRating)
                        self.dataStructArr.append(data)
                    }
                    self.dataSource?.didReceiveData(self.dataStructArr)
                    
                }catch{
                    self.delegate?.didReceiveError((dataError?.localizedDescription)!)
                }
                
            }
            downloadTask.resume()
        }else{
            self.delegate?.didReceiveError("No results found, try other key words.")
        }
        }
    }

protocol errorHandler:class {
    func didReceiveError(error:String)
}

protocol dataHandler: class {
    func didReceiveData(dataStructArr:[dataStruct])
}