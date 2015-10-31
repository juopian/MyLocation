//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by 超平 谢 on 15/9/3.
//  Copyright (c) 2015年 超平 谢. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()


class LocationDetailsViewController: UITableViewController{
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var coordinate = CLLocationCoordinate2D(latitude:0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    
    var categoryName = "No Category"
    
    @IBAction func done(){
        println("Description '\(descriptionText)'")
        //dismissViewControllerAnimated(true, completion: nil)
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.text = "Tagged"
        
        
        let delayInSeconds = 0.6
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue(), {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    @IBAction func cancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue){
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text  = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark{
            addressLabel.text = stringFromPlacemark(placemark)
        }else {
            addressLabel.text = "No address Found"
        }
        dateLabel.text = formatDate(NSDate())
        
        let gestureReconginer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureReconginer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureReconginer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    func hideKeyboard(gestureRecongnizer: UIGestureRecognizer){
        let point = gestureRecongnizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0{
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return  "\(placemark.subThoroughfare) \(placemark.thoroughfare), " +
                "\(placemark.locality), " +
                "\(placemark.administrativeArea) \(placemark.postalCode), " +
                "\(placemark.country)"
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 100000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
}

extension LocationDetailsViewController: UITextViewDelegate{
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
    
}


