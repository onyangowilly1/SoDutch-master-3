//
//  DetailViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 10.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var item: Item! {
        didSet {
            navigationItem.title = item.itemTitle
        }
    }
    
    var itemsStore: ItemsStore!
    let currentLocation = CLLocation!()
    
    // Press button and it takes you to the map
    @IBAction func goToMap(sender: UIButton) {
        let tabBarController = self.tabBarController
        let mapDetailViewController = tabBarController?.childViewControllers[0] as! MapViewController
        mapDetailViewController.comingFromDetailView = true
        
        tabBarController?.selectedIndex = 0
    }
    
    // Press button and it takes you to Apple Maps and shows the route
    @IBAction func goToAppleMap(sender: UIButton) {
        let tabBarController = self.tabBarController
        let mapDetailViewController = tabBarController?.childViewControllers[0] as! MapViewController
        
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(item.latitude, item.longitude), addressDictionary: nil)
        mapDetailViewController.destination = MKMapItem(placemark: destinationPlacemark)
        
        mapDetailViewController.routeToItem("appleMap")
    }
    
    // Sets the labels when opening
    func setLabels() {
        
        let itemImage = item.editedImage
        
        //titleLabel.text = item.itemTitle
        descriptionLabel.text = item.itemDescription
        adressLabel.text = item.addressString
        dateLabel.text = item.dateCreated
        imageView.image = itemImage
        
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = CGSizeMake(4, 5)
        imageView.layer.shadowRadius = 10
    }
    
    override func viewDidLoad() {
        setLabels()
    }
    
    
}
