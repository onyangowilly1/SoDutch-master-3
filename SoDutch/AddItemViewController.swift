//
//  AddItemViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 07.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit
import CoreLocation
import Photos

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var addresseLabel: UILabel!
    @IBOutlet var descriptionField: UITextField!
    
    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!
    
    var itemsStore: ItemsStore!
    var newItem: Item!
    
    var editedImageData: NSData!
    var addressString: String?
    var locationOfPhoto: CLLocation?
    var photoTaken = false
    
    // Actions that happen when user presses DONE button
    @IBAction func finishItem(sender: AnyObject) {
        
        // If image, title or description is NOT filled in, then an alert will show
        if (imageView.image == nil || imageView.image == UIImage(named: "CameraPlaceHolderImage") || titleField.text == "" || descriptionField.text == "") {
            let alertController = UIAlertController(title: "Missing information", message: "Photo, Title and Description is required to save", preferredStyle: .Alert)
            let completeAction = UIAlertAction(title: "OK", style: .Destructive, handler: nil)
            alertController.addAction(completeAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            newItem = itemsStore.addItem(titleField.text!, newDescription: descriptionField.text!, newLocation: locationOfPhoto!)
            
            // Set images directly to the item, NOT to ImageStore
            newItem.editedImage = UIImage(data: editedImageData)
            newItem.addressString = addresseLabel.text
            newItem.dateCreated = formatADate()
            
            itemsStore.saveChanges()
            
            // Sets titleField etc to default values after creating new item
            imageView.image = nil
            titleField.text = ""
            descriptionField.text = ""
            imageView.image = UIImage(named: "CameraPlaceHolderImage")
            addresseLabel.text = "Addresse will come automatically with picture"
            
            tabBarController?.selectedIndex = 2
        }
    }
    
    // Opens up the camera to take a picture
    @IBAction func takePicture(sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        
        // Asks the user to either Take a Photo or to choose one from the Photo Library
        let alertController = UIAlertController(title: "Add Photo", message: "Choose from Camera or from PhotoLibrary?", preferredStyle: .Alert)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {(action)-> Void in
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let libraryAction = UIAlertAction(title: "Get Photo From Library", style: .Default, handler: {(action)-> Void in
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Place image picker on the screen
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Take a photo and saves both the original and edited photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // if TAKE PHOTO then take photo, edit and save to PNG
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            // Get picked image from info dictionary
            let editedImageInit = info[UIImagePickerControllerEditedImage] as! UIImage
            
            // Convert image to PNG
            editedImageData = UIImagePNGRepresentation(editedImageInit)
            
            // Display the edited (small) image on screen
            imageView.image = editedImageInit
            
            locationOfPhoto = currentLocation
            
            // Get adresseLabel as current location
            getLocationAddress(currentLocation)
            
            // if PHOTO LIBRARY, then find metadata about photo and set location
        } else if picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary {
            
            var url: [NSURL] = []
            
            let editedImageInit = info[UIImagePickerControllerEditedImage] as! UIImage
            editedImageData = UIImagePNGRepresentation(editedImageInit)
            
            let imageURL: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            url.append(imageURL)
            let fetchedImage = PHAsset.fetchAssetsWithALAssetURLs(url, options: nil)
            let imageMetaData: PHAsset = fetchedImage.objectAtIndex(0) as! PHAsset
            
            // Display the edited (small) image on screen
            imageView.image = editedImageInit
            
            if imageMetaData.location != nil {
                
                let imageLocation: CLLocation = imageMetaData.location!
                locationOfPhoto = imageLocation
                getLocationAddress(imageLocation)
                
                // If a ocation is not associated with the picture, then show alert and choose currentLocation
            } else if imageMetaData.location == nil {
                
                locationOfPhoto = currentLocation
                getLocationAddress(currentLocation)
            }
        }
        photoTaken = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Convert the CLLocation coordinates to an addresse string
    func getLocationAddress(location: CLLocation) -> String {
        let geocoder = CLGeocoder()
        var placemark: CLPlacemark!
        var addresseString: String = ""
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)-> Void in
            
            if error == nil  {
                placemark = placemarks![0] as CLPlacemark
                
                if placemark.thoroughfare != nil {
                    addresseString = placemark.thoroughfare! + " "
                }
                if placemark.subThoroughfare != nil {
                    addresseString = addresseString + placemark.subThoroughfare!
                }
                if placemark.postalCode != nil {
                    addresseString = addresseString + ", " + placemark.postalCode! + " "
                }
                if placemark.locality != nil {
                    addresseString = addresseString + placemark.locality!
                }
                
                // Set adresseLabel as current location
                self.addresseLabel.text = addresseString
            }
        })
        return addresseString
    }
    
    override func viewDidLoad() {
        
        currentLocation = CLLocation!()
        locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location
        
        titleField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        descriptionField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = CGSizeMake(4, 5)
        imageView.layer.shadowRadius = 10
        
        addresseLabel.text = "Addresse will come automatically with picture"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
       
        // Sets titleField etc to default values if coming from another view
        if photoTaken == false {
            imageView.image = nil
            titleField.text = ""
            descriptionField.text = ""
            imageView.image = UIImage(named: "CameraPlaceHolderImage")
            addresseLabel.text = "Addresse will come automatically with picture"
            photoTaken = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        photoTaken = false
    }
    
    // Dismiss keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Function that dismiss the keyboard when pressing return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // Function that formates a date
    func formatADate() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = NSDate()
        let dateString = dateFormatter.stringFromDate(date)
        
        return dateString
    }
    
}
