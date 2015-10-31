//
//  FirstViewController.swift
//  MyLocations
//
//  Created by 超平 谢 on 15/7/9.
//  Copyright (c) 2015年 超平 谢. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer: NSTimer?
    
    @IBAction func getLocation(){
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
   
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation{
            stopLocationManager()
        }else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError\(error)")
        
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocation\(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        
        if newLocation.horizontalAccuracy < 0{
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
        
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                println("** we`re done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    self.performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                println("***Going to geocode")
                
                performingReverseGeocoding  = true
                geocoder.reverseGeocodeLocation(location, completionHandler: {
                    placemarks, error in println("*** Found placemarks:\(placemarks), error:\(error)")
                    self.lastLocationError = error
                    if error == nil && !placemarks.isEmpty {
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                println("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "location service disable", message: "please enable location services for this app in setting", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            }else if performingReverseGeocoding {
                addressLabel.text = "Searching for address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding address"
            } else {
                addressLabel.text = "No address found"
            }
            
        }else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            
            var statusMessage:String
            if let error = lastLocationError{
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disables"
                }else{
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
            } else if updatingLocation{
                statusMessage = "Searching..."
            } else{
                statusMessage = "Tap 'Get My Location' to Start"
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            if let timer = timer{
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate  = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self,
                selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        }else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String{
        return "\(placemark.subThoroughfare) " +
        "\(placemark.thoroughfare) \n" +
        "\(placemark.locality) " +
        "\(placemark.administrativeArea) " +
        "\(placemark.postalCode)"
    }

    func didTimeOut(){
        println("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
        }
    }
}

