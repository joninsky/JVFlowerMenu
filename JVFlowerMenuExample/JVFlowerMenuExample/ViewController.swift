//
//  ViewController.swift
//  JVFlowerMenuExample
//
//  Created by Jon Vogel on 1/17/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit
import JVFlowerMenu


class ViewController: UIViewController {

    
    var flowerMenu: JVFlowerMenu!
    
    
    var pedalNames = ["Skip", "Like", "Replay"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flowerMenu = JVFlowerMenu(withPosition: Position.Center, andSuperView: self.view, andImage: UIImage(named: "Menu"))

        for name in self.pedalNames {
            guard let image = UIImage(named: "Menu") else{
                return
            }
            
            self.flowerMenu.addPedal(theImage: image, identifier: name)
        }
        
        self.flowerMenu.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: FlowerMenuDelegate {
    
    func flowerMenuDidExpand() {
        
        print("Exanded")
        
        
    }
    
    
    func flowerMenuDidRetract() {
        print("Collapsed")
        
    }
    
    func flowerMenuDidSelectPedalWithID(theMenu: JVFlowerMenu, identifier: String, pedal: UIView) {
        
        
        print("Selected - \(identifier)")
        
    }
}

