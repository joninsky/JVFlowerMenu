//
//  JVFlowerMenu.swift
//  JVFlowerMenu
//
//  Created by Jon Vogel on 1/26/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit

///Delegate declaration for the `delegate` property of a `JVFlower` menu.
public protocol JVFlowerMenuDelegate {
    /// Delegate function that gets called when a `Pedal` of a `JVFlowerMenu` gets tapped.
    ///
    /// - Parameters:
    ///   - theMenu: The `JVFlowerMenu` that had one of its `Pedal`'s tapped.
    ///   - pedal: The `Pedal` that was tapped.
    func flowerMenuDidSelectPedalWithID(_ theMenu: JVFlowerMenu, pedal: Pedal)
    /// Delegate function that gets called when the `JVFlowerMenu` expands. Expansion happens when the user taps the `JVFlowerMenu` and it is not currently expanded.
    func flowerMenuDidExpand()
    /// Delegate function that gets called when the `JVFlowerMenu` collapses. The `JVFlowerMenu` collapses when the user taps it and it is currently expanded.
    func flowerMenuDidRetract()
}



/// The class that represents the `JVFlowerMenu`
open class JVFlowerMenu: Pedal {
    
    //MARK: Public Variables
    /// The `Pedal`'s that have been added to the menu
    open var pedals: [Pedal] = [Pedal]()
    /// The distance the `Pedal`'s will fly away from the `JVFlowerMenu`. The default is 100
    open var pedalDistance: CGFloat = 100
    /// The space between each `Pedal` once expanded. The Default is 50
    open var pedalSpace: CGFloat = 50
    /// Angle from the center of the `JVFlowerMenu` that the first `Pedal`'s center will be upon completion of expansion. Default it 0 (Directly above the `JVFlowerMenu`)
    open var startAngle: CGFloat = 0
    /// The amound of time the `JVFlowerMenu` will take to grow its `Pedal`'s when expanded. Default is 0.4 seconds
    open var growthDuration: TimeInterval = 0.4
    /// amount of time between `Pedal` growth during `JVFlowerMenu` expansion. Default is 0.6 seconds.
    open var stagger: TimeInterval = 0.06
    /// Boolean that lets you check the state of the `JVFlowerMenu`
    open var menuIsExpanded: Bool = false
    /// The delegate for the `JVFlowerMenu` where events will be broadcast.
    open var delegate: JVFlowerMenuDelegate?

    //MARK: Private Variables
    lazy var focusView = UIView()
    
    /// The designated initalizer for the `JVFlowerMenu`
    ///
    /// - Parameters:
    ///   - I: The image that will represent the `JVFlowerMenu` to the user. If nil is passed then a basic hamburger menu is drawn.
    ///   - title: The title of the `JVFlowerMenu` to communicate functionality to users. If nil is passed then nothing is displayed.
    public override init(withImage I: UIImage?, andTitle title: String?){
        
        super.init(withImage: I, andTitle: title)

        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCenterView(_:)))
        self.addGestureRecognizer(tapGesture)
        
        if I == nil {
            self.imageView.image = self.getMenuImage()
        }
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    

    
    /// The method that can be used to add a `Pedal` to the `JVFlowerMenu`. Make sure the `JVFlowerMenu` has a superview or the view will be absolutly and positivly destroyed by garbage collection and you will be wondering what the hell happened!!!
    ///
    /// - Parameters:
    ///   - image: The image for the new `Pedal`. Defaults to a basic `UIColor.blue` circle if nil is passed.
    ///   - title: The title for the new `Pedal`. Defaults to nothing if nil is passed
    public func addPedal(withImage image: UIImage?, withTitle title: String?){
        let newPedal = Pedal(withImage: image, andTitle: title)
        self.add(newPedal)
    }
    
    
    
    /// Alternate function to add a `Pedal` that you have already initalized
    ///
    /// - Parameter pedal: The `Pedal` you want added to the `JVFlowerMenu`
    public func add(_ pedal: Pedal) {
        pedal.translatesAutoresizingMaskIntoConstraints = false
        self.superview?.addSubview(pedal)
        self.constrainPedalToSelfCenter(pedal)
        self.pedals.append(pedal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPopOutView(_:)))
        pedal.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pannedViews(_:)))
        pedal.addGestureRecognizer(panGesture)
        pedal.alpha = 0

    }
    
    
    /// :nodoc:
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.bounds.contains(point) {
            return true
        }
        
        for view in self.pedals {
            if view.frame.contains(point) {
                return true
            }
        }
        
        return false
    }
    
    
    
    /// Make the `JVFlowerMenu` grow its pedals.
    public func grow(){
        
        for (index, view) in self.pedals.enumerated() {
            let indexAsDouble = Double(index)
            
            UIView.animate(withDuration: self.growthDuration, delay: self.stagger * indexAsDouble, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                view.alpha = 1
                view.transform = self.getTransformForPopupViewAtIndex(CGFloat(index))
            }, completion: { (didComplete) in
                
            })
        }
        self.menuIsExpanded = true
        self.focusView.translatesAutoresizingMaskIntoConstraints = false
        self.focusView.alpha = 0.5
        self.focusView.backgroundColor = UIColor.black
        self.superview?.insertSubview(self.focusView, belowSubview: self)
        self.constrainFocusView()
        self.delegate?.flowerMenuDidExpand()
        
    }
    
    
    
    /// Make the `JVFlowerMenu` shrivel its pedals.
    public func shrivel(){
        
        self.transform = CGAffineTransform.identity
        
        for (index, view) in self.pedals.enumerated() {
            let indexAsDouble = Double(index)
            
            UIView.animate(withDuration: self.growthDuration, delay: self.stagger * indexAsDouble, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                view.alpha = 0
                view.transform = CGAffineTransform.identity
            }, completion: { (didComplete) in
                
            })
        }
        self.menuIsExpanded = false
        self.focusView.removeFromSuperview()
        self.delegate?.flowerMenuDidRetract()
        
    }
    
    internal func didTapPopOutView(_ sender: UITapGestureRecognizer) {
        for view in self.pedals {
            if view == sender.view {
                self.delegate?.flowerMenuDidSelectPedalWithID(self, pedal: view)
            }
        }
    }
    
    internal func didTapCenterView(_ sender: UITapGestureRecognizer){
        if self.menuIsExpanded {
            self.shrivel()
        }else{
            self.grow()
        }
    }
    
    internal func pannedViews(_ sender: UIPanGestureRecognizer) {
        
        guard let theView = sender.view else {
            return
        }
        
        var indexOfView: Int?
        
        for (index, view) in self.pedals.enumerated() {
            if view == theView{
                indexOfView = index
                break
            }
        }
        
        let point = sender.location(in: self.superview)
        
        let centerX = self.frame.origin.x + self.frame.size.width / 2
        
        let centerY = self.frame.origin.y + self.frame.size.height / 2
        
        if sender.state == UIGestureRecognizerState.changed {
            
            let deltaX = point.x - centerX
            
            let deltaY = point.y - centerY
            
            let atan = Double(atan2(deltaX, -deltaY))
            
            let angle = atan * Double(180) / M_PI
            
            self.startAngle = CGFloat(angle) - self.pedalSpace * CGFloat(indexOfView!)
            
            theView.center = point
            
            theView.transform = CGAffineTransform.identity
            
            for (index, aView) in self.pedals.enumerated() {
                if aView != theView {
                    aView.transform = self.getTransformForPopupViewAtIndex(CGFloat(index))
                }
            }
            
        }else if sender.state == UIGestureRecognizerState.ended {
            theView.center = CGPoint(x: centerX, y: centerY)
            for (index, aView) in self.pedals.enumerated() {
                aView.transform = self.getTransformForPopupViewAtIndex(CGFloat(index))
            }
        }
        
    }
    
    internal func getTransformForPopupViewAtIndex(_ index: CGFloat) -> CGAffineTransform{
        
        let newAngle = Double(self.startAngle + (self.pedalSpace * index))
        
        let deltaY = Double(-self.pedalDistance) * cos(newAngle / 180 * M_PI)
        
        let deltaX = Double(self.pedalDistance) * sin(newAngle / 180 * M_PI)
        
        return CGAffineTransform(translationX: CGFloat(deltaX), y: CGFloat(deltaY))
    }
    
    internal func getTransformToSuperViewCenter() -> CGAffineTransform {
        
        let deltaX = Double(self.superview!.center.x - self.center.x)
        
        let deltaY = Double(self.superview!.center.y - self.center.y)
        
        return CGAffineTransform(translationX: CGFloat(deltaX), y: CGFloat(deltaY))
        
    }
    
    fileprivate func constrainPedalToSelfCenter(_ thePedal: Pedal) {
        
        var arrayOfConstraints = [NSLayoutConstraint]()
        
        
        let centerX = NSLayoutConstraint(item: thePedal, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        
        let centerY = NSLayoutConstraint(item: thePedal, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        
        arrayOfConstraints.append(centerX)
        arrayOfConstraints.append(centerY)
        
       // thePedal.centerConstraints = arrayOfConstraints
        
        self.superview?.addConstraints(arrayOfConstraints)
        
    }
    
    
    func constrainFocusView() {
        var constraints = [NSLayoutConstraint]()
        
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[focus]|", options: [], metrics: nil, views: ["focus": self.focusView])
        
        constraints.append(contentsOf: vertical)
        
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[focus]|", options: [], metrics: nil, views: ["focus": self.focusView])
        
        constraints.append(contentsOf: horizontal)
        
        self.superview?.addConstraints(constraints)
        
    }

}


extension JVFlowerMenu {
    func getMenuImage() -> UIImage {
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 3.14, y: 11.4))
        bezierPath.addLine(to: CGPoint(x: 40.86, y: 11.4))
        bezierPath.addCurve(to: CGPoint(x: 44, y: 7.7), controlPoint1: CGPoint(x: 42.59, y: 11.4), controlPoint2: CGPoint(x: 44, y: 9.74))
        bezierPath.addCurve(to: CGPoint(x: 40.86, y: 4), controlPoint1: CGPoint(x: 44, y: 5.66), controlPoint2: CGPoint(x: 42.59, y: 4))
        bezierPath.addLine(to: CGPoint(x: 3.14, y: 4))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 7.7), controlPoint1: CGPoint(x: 1.41, y: 4), controlPoint2: CGPoint(x: 0, y: 5.66))
        bezierPath.addCurve(to: CGPoint(x: 3.14, y: 11.4), controlPoint1: CGPoint(x: 0, y: 9.74), controlPoint2: CGPoint(x: 1.41, y: 11.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 40.86, y: 18.8))
        bezierPath.addLine(to: CGPoint(x: 3.14, y: 18.8))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 22.5), controlPoint1: CGPoint(x: 1.41, y: 18.8), controlPoint2: CGPoint(x: 0, y: 20.46))
        bezierPath.addCurve(to: CGPoint(x: 3.14, y: 26.2), controlPoint1: CGPoint(x: 0, y: 24.54), controlPoint2: CGPoint(x: 1.41, y: 26.2))
        bezierPath.addLine(to: CGPoint(x: 40.86, y: 26.2))
        bezierPath.addCurve(to: CGPoint(x: 44, y: 22.5), controlPoint1: CGPoint(x: 42.59, y: 26.2), controlPoint2: CGPoint(x: 44, y: 24.54))
        bezierPath.addCurve(to: CGPoint(x: 40.86, y: 18.8), controlPoint1: CGPoint(x: 44, y: 20.46), controlPoint2: CGPoint(x: 42.59, y: 18.8))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 40.86, y: 33.6))
        bezierPath.addLine(to: CGPoint(x: 3.14, y: 33.6))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 37.3), controlPoint1: CGPoint(x: 1.41, y: 33.6), controlPoint2: CGPoint(x: 0, y: 35.26))
        bezierPath.addCurve(to: CGPoint(x: 3.14, y: 41), controlPoint1: CGPoint(x: 0, y: 39.34), controlPoint2: CGPoint(x: 1.41, y: 41))
        bezierPath.addLine(to: CGPoint(x: 40.86, y: 41))
        bezierPath.addCurve(to: CGPoint(x: 44, y: 37.3), controlPoint1: CGPoint(x: 42.59, y: 41), controlPoint2: CGPoint(x: 44, y: 39.34))
        bezierPath.addCurve(to: CGPoint(x: 40.86, y: 33.6), controlPoint1: CGPoint(x: 44, y: 35.26), controlPoint2: CGPoint(x: 42.59, y: 33.6))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        let dash = CAShapeLayer()
        dash.frame = CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0)
        dash.path = bezierPath.cgPath

        let layer = dash
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("No Graphics Context")
            return UIImage()
        }
        
        layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}

