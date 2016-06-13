//
//  ItemViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 08.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit
import MapKit

class ItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var fromMap: Bool = false
    
    var itemsStore = ItemsStore()
    
    // Sets the number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Sets the number of rows in section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsStore.allItems.count
    }
    
    // Populates the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        
        let itemTitle = itemsStore.allItems[indexPath.row].itemTitle
        let itemDescription = itemsStore.allItems[indexPath.row].itemDescription
        let itemImage = itemsStore.allItems[indexPath.row].editedImage
        
        // Configure Cell
        cell.itemTitle.text = itemTitle
        cell.itemDescription.text = itemDescription
        cell.itemImage.image = itemImage
        
        return cell
    }
    
    // Segue to DetailView which passes the item
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowItemDetail" {
            
            if let row = tableView.indexPathForSelectedRow?.row {
                
                let item = itemsStore.allItems[row]
                let detailViewController = segue.destinationViewController as! DetailViewController
                
                detailViewController.item = item
            }
        }
    }
    
    override func viewDidLoad() {
        // Reverses the itemStore.allItems so the newest comes first
        itemsStore.allItems = itemsStore.allItems.reverse()
        
        tableView.reloadData()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadInputViews()
        tableView.reloadData()
    }
    
    
}
