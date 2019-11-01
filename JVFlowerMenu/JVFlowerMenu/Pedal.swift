//
//  Pedal.swift
//  JVFlowerMenu
//
//  Created by Jon Vogel on 1/26/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit



/// Class that represents an option in the `JVFlowerMenu`
open class Pedal: UIVisualEffectView {
    
    ///The image that helps let the user know what this menu item is all about. Defaults to a `UIColor.blue` circle if no image is passed in the initalizer. Can be re-set at any time.
    public var imageView: UIImageView!
    ///The `UIlabel` that provides a textual description to let the use know what the menu item does. This does not display anything if the `andTitle` part of the initalizer is nil.
    public var text: UILabel!
    ///In the absense of text on the `text` property this can be used to help identify which pedal was just selected by the user.
    public let ID = UUID().uuidString
    
   // var centerConstraints = [NSLayoutConstraint]()
    
    /// The default fill color for the circle image that is drawn for a `Pedal` that did not have an image passed to it. You can change this at any time and the circle will change colors.
    public var defaultCircleFillColor: UIColor = UIColor.blue {
        didSet{
            self.imageView.image = self.circle(diameter: 45, color: self.defaultCircleFillColor)
        }
    }
    
    /// Dedicated initalizer for the `Pedal` class
    ///
    /// - Parameters:
    ///   - image: The image you want the pedal to display. A `UIColor.blue` circle is displayed if nil is passed.
    ///   - title: The text to appear below the image. Displays nothing if nill is passed
    public init(withImage image: UIImage?, andTitle title: String?) {
        super.init(effect: UIBlurEffect(style: .light))
        self.setUp(withImage: image, andTitle: title)
    }
    
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setUp(withImage: nil, andTitle: nil)
    }
    
    private func setUp(withImage I: UIImage?, andTitle title: String?) {
        //Set some basic stuff on top of the Blure effect
        self.backgroundColor = UIColor(white: 0.8, alpha: 0.36)
        self.layer.cornerRadius = 9.0
        self.layer.masksToBounds = true
        
        //Set the interpolating motion effects
        let offSet = 30.0
        
        let motionX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffect.EffectType.tiltAlongHorizontalAxis)
        motionX.maximumRelativeValue = offSet
        motionX.minimumRelativeValue = -offSet
        
        let motionY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffect.EffectType.tiltAlongVerticalAxis)
        motionY.maximumRelativeValue = offSet
        motionY.minimumRelativeValue = -offSet
        
        let motionGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [motionX, motionY]
        
        self.addMotionEffect(motionGroup)
        
        //Set up Image View
        self.imageView = UIImageView()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit

        //Set up Label
        self.text = UILabel()
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.text = title
        self.text.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.text.numberOfLines = 0
        self.text.textAlignment = NSTextAlignment.center
        self.text.font = self.text.font.withSize(10)
        
        self.addSubview(self.imageView)
        self.addSubview(self.text)
        
        self.constrain()
        
        if I == nil {
            self.imageView.image = self.circle(diameter: 45, color: self.defaultCircleFillColor)
        }else{
            self.imageView.image = I
        }

    }
    
    func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            print("No Graphics Context")
            return UIImage()
        }
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    
    func constrain() {
        var constraints = [NSLayoutConstraint]()
        
        let imageHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[image]-3-|", options: [], metrics: nil, views: ["image": self.imageView as Any])
        
        constraints.append(contentsOf: imageHorizontal)
        
        let allVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[image]-3-[text]|", options: [], metrics: nil, views: ["image": self.imageView as Any, "text": self.text as Any])
        
        constraints.append(contentsOf: allVertical)
        
        let textHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-3-[text]-3-|", options: [], metrics: nil, views: ["text": self.text as Any])
        
        constraints.append(contentsOf: textHorizontal)
        
        self.addConstraints(constraints)
        
    }
    
}
