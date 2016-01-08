//
//  DetailViewController.swift
//  
//
//  Created by Jay on 1/8/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class DetailView:UIViewController,MKMapViewDelegate{
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var businessTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var titleStr = ""
    var priceStr = ""
    var addressStr = ""
    var menuStr = ""
    var phoneStr = ""
    var categoryStr = ""
    var ratingStr = ""
    var businessTimeStr = ""
    var location = CLLocation()
    var storeAnnotation:MapPin?
    var storeAnnoView:MKPinAnnotationView = MKPinAnnotationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myMap.delegate = self
        self.myMap.mapType = MKMapType.Standard
        self.myMap.zoomEnabled = true
        self.myMap.scrollEnabled = true
        self.myMap.region = MKCoordinateRegionMakeWithDistance(self.location.coordinate,200,200)
        self.storeAnnotation = MapPin(coordinate: self.location.coordinate, title: self.titleStr)
        self.myMap.addAnnotation(self.storeAnnotation!)
        self.updateUIElements()
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        self.myMap.selectAnnotation(self.storeAnnotation!, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        self.storeAnnoView.annotation = self.storeAnnotation
        self.storeAnnoView.canShowCallout = true
        self.storeAnnoView.enabled = true
        self.storeAnnoView.animatesDrop = true
        let button = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
        button.addTarget(self, action:Selector("openInAppleMap:"), forControlEvents: UIControlEvents.AllTouchEvents)
        self.storeAnnoView.rightCalloutAccessoryView = button
        return self.storeAnnoView
    }
    
    func updateUIElements(){
        self.title = titleStr
        self.ratingLabel.text = self.ratingStr
        self.businessTimeLabel.text = self.businessTimeStr
        self.categoryLabel.text = self.categoryStr
        self.priceLabel.text = self.priceStr
        self.phoneButton.setTitle(self.phoneStr, forState: UIControlState.Normal)
        self.addressButton.setTitle(self.addressStr, forState: UIControlState.Normal)
        self.menuButton.setTitle(self.menuStr, forState: UIControlState.Normal)
        if self.menuStr == "No menu offered."{
            self.menuButton.enabled = false
        }
    }
    
   
    
    @IBAction func openInAppleMap(sender: UIButton) {
        var numberOfDoor = ""
        var street = ""
        var city = ""
        var state = ""
        var urlStr = " "
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.location) { (placemarks, error) -> Void in
            let placemark = placemarks!.last
            numberOfDoor = placemark!.subThoroughfare!
            city = placemark!.locality!
            state = placemark!.administrativeArea!
            street = placemark!.thoroughfare!
            
            for(var index = 0; index < numberOfDoor.characters.count-1; index++){
                let charIndex = numberOfDoor.startIndex.advancedBy(index)
                if numberOfDoor[charIndex] == "–" {
                    numberOfDoor.removeAtIndex(charIndex)
                    index--
                }
                
            }
            
            for(var index = 0; index < street.characters.count-2; index++){
                let charIndex = street.startIndex.advancedBy(index)
                let endIndex = street.startIndex.advancedBy(index + 1)
                if street[charIndex] == " " {
                    street.replaceRange((charIndex..<endIndex), with: "+")
                }
            }
            
            for(var index = 0; index < city.characters.count-2; index++){
                let charIndex = city.startIndex.advancedBy(index)
                let endIndex = charIndex.advancedBy(1)
                if city[charIndex] == " " {
                    city.replaceRange((charIndex..<endIndex), with: "+")
                }
            }
            urlStr = "http://maps.apple.com/?address=" + numberOfDoor + "+" + street + "+" + city + "+" + state
            let url = NSURL(string:urlStr)
            let map = UIApplication.sharedApplication()
            if map.canOpenURL(url!){
                map.openURL(url!)
            }else{
                let alert = UIAlertController(title: "Invalid Address", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func openPhoneAPP(sender: UIButton) {
        var phoneURL = self.phoneButton.currentTitle!
        for(var i = 0; i < phoneURL.characters.count; i++){
            let index = phoneURL.startIndex.advancedBy(i)
            if phoneURL[index] == "(" || phoneURL[index] == ")" || phoneURL[index] == "-" || phoneURL[index] == " "{
                phoneURL.removeAtIndex(index)
                i--
            }
        }
        phoneURL.insertContentsOf(["t","e","l",":","/","/"], at: phoneURL.startIndex)
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: phoneURL)!){
            UIApplication.sharedApplication().openURL(NSURL(string: phoneURL)!)
        }else{
            let alert = UIAlertController(title: "Invalid Number", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func openInSafari(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.menuStr)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}
