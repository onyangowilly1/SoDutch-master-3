//
//  PageViewController.swift
//  SoDutch
//
//  Created by Jarle Matland on 10.03.2016.
//  Copyright © 2016 Donkey Monkey. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    
    var itemsStore: ItemsStore!
    var item: Item!
    
    override func viewDidLoad() {
        
        // Sets the functionality of the swipe list
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        let startingViewController: PageDataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        let width = startingViewController.view.frame.width
        let height = startingViewController.view.frame.height

        self.pageViewController!.view.frame = CGRectMake(0, 0, width, height)
        self.pageViewController!.didMoveToParentViewController(self)
        
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
    }
    
    // Sets spine location of the interface
    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
        let currentViewController = self.pageViewController!.viewControllers![0]
        let viewControllers = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        
        self.pageViewController!.doubleSided = false
        return .Min
    }

    var modelController: ItemsStore {
        // Return the model controller object, creating it if necessary.
        if _modelController == nil {
            _modelController = ItemsStore()
        }
        return _modelController!
    }
    
    var _modelController: ItemsStore? = nil
    
}
