//
//  MapViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 07.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var telephone: UIView!
    @IBOutlet var linkView: UIView!
    @IBOutlet var annotationDetailView: UIView!
    @IBOutlet var imagePlaceholderView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var updateLocationButton: UIButton!
    
    @IBOutlet var detailView: UIView!
    @IBOutlet var detailImageView: UIView!
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var detailDescription: UILabel!
    @IBOutlet var detailAdress: UILabel!
    @IBOutlet var detailDate: UILabel!
    @IBOutlet var showDetailButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var meterKmLabel: UILabel!
    
    var location: CLLocation!
    var locationManager: CLLocationManager!
    var window: UIWindow!
    var annotations = [MKPointAnnotation]()
    var firstLoadOfMap = true
    var destination: MKMapItem?
    var itemTitleFromDetailView: String?
    var comingFromDetailView: Bool = false
    var routeOverlay: MKOverlay?
    var itemKeyString: String = ""
    var hideDetailView = false
    
    var itemsStore: ItemsStore!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapSegment: UISegmentedControl!
    
    // Press "Show Route" button will show a route overlay on the current map
    @IBAction func getRouteToItem(sender: UIButton) {
        
        routeToItem("inApp")
        
        annotationDetailView.hidden = true
        imagePlaceholderView.hidden = true
        detailView.hidden = true
        
        showDetailButton.setTitle("Show Details", forState: .Normal)
        showDetailButton.setTitleColor(UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1), forState: .Normal)
    }
    
    // If pressing "ARROW" then the location will be zoomed in to users location
    @IBAction func goToCurrentLocation(sender: UIButton) {
        self.mapView.showsUserLocation = true
        mapView.setRegion(MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
    
    // Segmented controll to display Standard, Hybrid or Satelite
    @IBAction func mapTypeSegment(sender: UISegmentedControl) {
        let segmentedControl = sender
        segmentedControl.addTarget(self, action: "mapTypeChanged:", forControlEvents: .ValueChanged)
    }
    
    // Press "Show in Apple Maps" button will open up Apple Maps with directions
    @IBAction func openInAppleMaps(sender: UIButton) {
        routeToItem("appleMap")
    }
    
    // Press "Show Details" will add a view over the map that shows the details
    @IBAction func showDetailView(sender: UIButton) {
        
        // When the "Show Details" button is pressed
        if showDetailButton.highlighted == true && hideDetailView == false {
            var i = 0
            
            while i < itemsStore.allItems.count {
                
                if itemKeyString == itemsStore.allItems[i].itemKey {
                    
                    let item = itemsStore.allItems[i]
                    annotationDetailView.hidden = true
                    imagePlaceholderView.hidden = true
                    detailView.hidden = false
                    
                    showDetailButton.setTitle("Hide Details", forState: .Normal)
                    showDetailButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                    
                    detailImage.image = item.editedImage
                    detailTitle.text = item.itemTitle
                    detailDescription.text = item.itemDescription
                    detailDate.text = item.dateCreated
                    detailAdress.text = item.addressString
                    
                    detailImage.layer.shadowColor = UIColor.blackColor().CGColor
                    detailImage.layer.shadowOpacity = 1
                    detailImage.layer.shadowOffset = CGSizeMake(4, 5)
                    detailImage.layer.shadowRadius = 10
                    
                    hideDetailView = true
                    
                    i = itemsStore.allItems.count
                }
                i++
            }
        // When the "Hide Details" button is presses
        } else if hideDetailView == true {
            detailView.hidden = true
            imagePlaceholderView.hidden = false
            annotationDetailView.hidden = false
            hideDetailView = false
            
            showDetailButton.setTitle("Show Details", forState: .Normal)
            showDetailButton.setTitleColor(UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1), forState: .Normal)
        }
    }
    
    // Function that calculates distance from user location to annotation
    func distanceToItem(itemCoordinate: CLLocation) -> Double {
        let currentLocation = mapView.userLocation.location
        let distance: CLLocationDistance = currentLocation!.distanceFromLocation(itemCoordinate)
        
        return distance
    }
    
    // Segmented control for map
    func mapTypeChanged(segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .Standard
        case 1:
            mapView.mapType = .Hybrid
        case 2:
            mapView.mapType = .Satellite
        default:
            break
        }
    }
    
    // Functions that will either show a route overlay on the map or open up AppleMaps for direction
    func routeToItem(mapOption: String) {
        
        if routeOverlay != nil {
            self.mapView.removeOverlay(routeOverlay!)
        }
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem.mapItemForCurrentLocation()
        directionRequest.destination = destination
        directionRequest.requestsAlternateRoutes = true
        directionRequest.transportType = .Walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler ({(response:
            MKDirectionsResponse?, error: NSError?) in
            
            if error == nil {
                
                if mapOption == "inApp" {
                    // Display the directions with a route overlay
                    for route in response!.routes {
                        
                        self.mapView.addOverlay(route.polyline,
                            level: MKOverlayLevel.AboveRoads)
                        
                        self.routeOverlay = route.polyline
                    }
                } else if mapOption == "appleMap" {
                    // Display the directions in Apple Maps
                    let launchOptions = [
                        MKLaunchOptionsDirectionsModeKey:
                        MKLaunchOptionsDirectionsModeWalking]
                    
                    MKMapItem.openMapsWithItems(
                        [response!.source, response!.destination],
                        launchOptions: launchOptions)
                }
            } else {
                let alertController = UIAlertController(title: "Not possible to find directions for this item", message: "Please select a different pin", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: .Destructive, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // Function that renders the route overlay
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }
    
    // Function to update the user location
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
            // Will only update the user location on the first time the map is opened
            if firstLoadOfMap == true {
                mapView.setRegion(MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
                firstLoadOfMap = false
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
        
        loadInitialData()
        
        annotationDetailView.hidden = true
        imagePlaceholderView.hidden = true
        detailView.hidden = true
        linkView.hidden = true
        hideDetailView = false
    
    
    
    
    
    }
    
    // Will reload all annotation when the view appears again
    override func viewWillAppear(animated: Bool) {
        loadInitialData()
        
        showDetailButton.setTitle("Show Details", forState: .Normal)
        showDetailButton.setTitleColor(UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1), forState: .Normal)
        
        var i = 0
        var selectedAnnotation: MKAnnotation?
        
        // If "Show in Map" is pressed in the DetailViewController, then the small annotation view is populated for the item
        if comingFromDetailView == true {
            
            while i < annotations.count {
                if annotations[i].title == itemTitleFromDetailView {
                    selectedAnnotation = annotations[i]
                    let region = selectedAnnotation?.coordinate
                    
                    mapView.selectAnnotation(selectedAnnotation!, animated: true)
                    mapView.setRegion(MKCoordinateRegion(center: region!, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
                    
                    annotationDetailView.hidden = false
                    imagePlaceholderView.hidden = false
                    linkView.hidden = false
                    comingFromDetailView = false
                    detailView.hidden = true
                    hideDetailView = false
                    break
                }
                
                i++
            }
        } else {
            annotationDetailView.hidden = true
            imagePlaceholderView.hidden = true
            linkView.hidden = true
            detailView.hidden = true
            hideDetailView = false
        }
    }
    
    func doubleNumberFormatter(number: Double) -> String {
        // Formates distance to only have two decimals
        let decimalFormatter = NSNumberFormatter()
        decimalFormatter.numberStyle = .DecimalStyle
        decimalFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundDown
        decimalFormatter.maximumFractionDigits = 2
        let formattedNumber = decimalFormatter.stringFromNumber(number)
        
        return formattedNumber!
    }
    
    
}

