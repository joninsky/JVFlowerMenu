//
//  ViewController.swift
//  Example
//
//  Created by Jon Vogel on 1/26/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit
import JVFlowerMenu
import PKHUD
class ViewController: UIViewController {

    
    var menu: JVFlowerMenu!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menu = JVFlowerMenu(withImage: nil, andTitle: nil)
        
        self.menu.delegate = self
        
        self.menu.translatesAutoresizingMaskIntoConstraints = false
        
        self.menu.startAngle = 90.0
        self.menu.pedalDistance = 200
        self.menu.pedalSpace = 20
        self.menu.stagger = 0
        
        self.view.addSubview(menu)
        
        self.menu.addPedal(withImage: nil, withTitle: nil)
        self.menu.addPedal(withImage: nil, withTitle: nil)
        self.menu.addPedal(withImage: nil, withTitle: nil)
        self.menu.pedals[1].defaultCircleFillColor = UIColor.red
        self.menu.pedals[2].defaultCircleFillColor = UIColor.yellow
        self.constrain()
        
    }

    
    func constrain() {
        
        var constraints = [NSLayoutConstraint]()
        
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[pedal]", options: [], metrics: nil, views: ["pedal": self.menu])
        
        constraints.append(contentsOf: vertical)
        
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[pedal]", options: [], metrics: nil, views: ["pedal": self.menu])

        constraints.append(contentsOf: horizontal)
        
        self.view.addConstraints(constraints)
        
    }

}

extension ViewController: JVFlowerMenuDelegate {
    
    public func flowerMenuDidSelectPedalWithID(_ theMenu: JVFlowerMenu, pedal: Pedal) {
        
        
        print("\(pedal.ID) Selected")
        
        
        let view = UIView(frame: CGRect(x: pedal.frame.origin.x, y: pedal.frame.origin.y, width: pedal.frame.width, height: pedal.frame.height))
            
        view.backgroundColor = pedal.defaultCircleFillColor
        
        view.layer.cornerRadius = view.frame.height / 2
        
        
        let index = self.view.subviews.index(of: self.menu)! - 1
        
        self.view.insertSubview(view, at: index)
        
        UIView.animate(withDuration: 1.0, animations: { 
            
            view.transform = CGAffineTransform(scaleX: 50, y: 50)
            
        }) { (didComplete) in
            self.view.backgroundColor = pedal.defaultCircleFillColor
            view.removeFromSuperview()
        }
        
        
        
        
    }
    
    
    public func flowerMenuDidExpand() {
        
        print("Flower Menu expanded")
    }
    
    
    public func flowerMenuDidRetract() {
        
        print("Flower Menu Retracted")
        
    }
    
    
}

