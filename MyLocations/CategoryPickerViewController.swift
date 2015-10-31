//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by 超平 谢 on 15/9/4.
//  Copyright (c) 2015年 超平 谢. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName =  ""
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore"
    ]
    
    
    var selectedIndexPath = NSIndexPath()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell

        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.row != selectedIndexPath.row {
                if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                    newCell.accessoryType = .Checkmark
                }
                if let oldCell = tableView.cellForRowAtIndexPath( selectedIndexPath) {
                    oldCell.accessoryType = .None
                }
                selectedIndexPath = indexPath
            }
    }
}
