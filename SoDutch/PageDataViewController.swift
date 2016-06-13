//
//  PageDataViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 10.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit
import MapKit

class PageDataViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var imageObject: UIImage?
    var titleObject: String?
    var descriptionObject: String?
    var itemKey: String?
    
    var itemsStore: ItemsStore!
    var item: Item!
    
    // Shows item in map
    @IBAction func showInMap(sender: UIButton) {
        let tabBarController = self.tabBarController
        let mapDetailViewController = tabBarController?.childViewControllers[0] as! MapViewController
        
        mapDetailViewController.itemTitleFromDetailView = titleLabel.text!
        
        mapDetailViewController.comingFromDetailView = true
        
        tabBarController?.selectedIndex = 0
    }
    
    // Opens up Apple Maps and give directions
    @IBAction func showInAppleMaps(sender: UIButton) {
        let tabBarController = self.tabBarController
        let mapDetailViewController = tabBarController?.childViewControllers[0] as! MapViewController
        
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(item.latitude, item.longitude), addressDictionary: nil)
        mapDetailViewController.destination = MKMapItem(placemark: destinationPlacemark)
        
        mapDetailViewController.routeToItem("appleMap")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = imageObject
        self.titleLabel.text = titleObject
        self.descriptionLabel.text = descriptionObject
        
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = CGSizeMake(4, 5)
        imageView.layer.shadowRadius = 10
        
    }
    
}
