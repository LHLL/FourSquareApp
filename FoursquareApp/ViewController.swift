//
//  ViewController.swift
//  FoodNearBySwift
//
//  Created by Jay on 1/8/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,dataHandler,errorHandler{
    
    var dataArray = [dataStruct]()
    var fetchMethod = Downlode()
    let manager = CLLocationManager()
    var userLocation = CLLocation()
    var version = 20151230
    var indicator = UIActivityIndicatorView()
    var indicatorLabel:UILabel!
    
    @IBOutlet weak var myTetfield: UITextField!
    @IBOutlet weak var myTableview: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.manager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTableview.estimatedRowHeight = 68
        self.myTableview.rowHeight = UITableViewAutomaticDimension
        self.myTableview.dataSource = self
        self.myTableview.delegate = self
        self.fetchMethod.dataSource = self
        self.fetchMethod.delegate = self
        self.myTetfield.becomeFirstResponder()
        self.myTetfield.delegate = self
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
        self.getVersion()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.manager.stopUpdatingLocation()
        self.userLocation = locations.last!
        
    }

    @IBAction func startFetching(sender: UITextField) {
        if self.userLocation.coordinate.latitude != 0.0{
            self.drawIndicator()
            self.indicator.startAnimating()
            self.indicatorLabel.hidden = false
            self.dataArray.removeAll()
            
            let searchString = myTetfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let urlString = "https://api.foursquare.com/v2/venues/explore?&radius=8000&client_id=L0L20VIZSTHHR5RSC4UQCDHDF0LXT1WEJFN2Z5K3SOVRVJK1&client_secret=MZZGJNXI3TH33VMWNXEKO5IPTKDHKEYWJZG35TXU3IYNB2XO&v=\(self.version)&ll=\(self.userLocation.coordinate.latitude),\(self.userLocation.coordinate.longitude)&query=\(searchString)&limit=50"
            self.fetchMethod.startFetchingDataFromFourSquare(urlString)
        }else{
            let alert = UIAlertController(title: "Error", message:"Can not locate user location", preferredStyle: UIAlertControllerStyle.Alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true) { () -> Void in
                self.indicator.stopAnimating()
                self.indicatorLabel.hidden = true
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.myTetfield.text = ""
        self.dataArray.removeAll()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.myTableview.reloadData()
        }
    }
    
    func didReceiveData(dataStructArr: [dataStruct]) {
        self.dataArray = dataStructArr
        for (var index = 0; index<self.dataArray.count-1; index++){
            let location = self.dataArray[index]
            var distanceMin = self.userLocation.distanceFromLocation(location.storeLocation)
            for(var index1 = index+1; index1<self.dataArray.count; index1++){
                let location1 = self.dataArray[index1]
                let testDistance = self.userLocation.distanceFromLocation(location1.storeLocation)
                if testDistance <= distanceMin {
                    distanceMin = testDistance
                    swap(&self.dataArray[index], &self.dataArray[index1])
                }

            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.indicator.stopAnimating()
            self.indicatorLabel.hidden = true
            self.myTableview.reloadData()
        }
    }
    
    func didReceiveError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true) { () -> Void in
            self.indicator.stopAnimating()
            self.indicatorLabel.hidden = true
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contentCell") as! ContextCell
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.3
        cell.layer.cornerRadius = 20
        let dataForRow = self.dataArray[indexPath.row]
        cell.configureUIElements(dataForRow,userLocation: self.userLocation)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getVersion(){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day,.Month,.Year],fromDate:date)
        let year =  components.year
        let month = components.month
        let day = components.day
        self.version = year*10000+month*100+day
    }
    
    func drawIndicator(){
        let size = CGSize(width: 50,height: 50)
        let origin = CGPoint(x: self.view.center.x-30, y: self.view.center.y-50)
        let rect = CGRect(origin: origin, size: size)
        self.indicator = UIActivityIndicatorView(frame: rect)
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.indicator)
        self.indicatorLabel = UILabel(frame: CGRect(x: self.view.center.x - 100, y: self.view.center.y, width: 220, height: 20))
        self.view.addSubview(self.indicatorLabel)
        self.indicatorLabel.text = "searching " + self.myTetfield.text! + " near you."
        self.indicatorLabel.hidden = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("detail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail"{
            let detail = segue.destinationViewController as! DetailView
            let row = (sender as! NSIndexPath).row
            let rowDataStruct = self.dataArray[row]
            detail.titleStr = rowDataStruct.storeName
            detail.addressStr = rowDataStruct.storeAddress
            detail.phoneStr = rowDataStruct.storePhone
            detail.location = rowDataStruct.storeLocation
            detail.priceStr = rowDataStruct.storePrice
            detail.menuStr = rowDataStruct.storeMenu
            detail.businessTimeStr = rowDataStruct.storeTime
            detail.ratingStr = rowDataStruct.storeRating
            detail.categoryStr = rowDataStruct.storeCatgory
        }
    }
}

