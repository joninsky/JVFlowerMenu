//
//  JVFlowerMenu.swift
//  JVFlowerMenu
//
//  Created by Jon Vogel on 1/17/17.
//  Copyright © 2017 Jon Vogel. All rights reserved.
//

import UIKit

public protocol FlowerMenuDelegate {
    func flowerMenuDidSelectPedalWithID(theMenu: JVFlowerMenu, identifier: String, pedal: UIView)
    func flowerMenuDidExpand()
    func flowerMenuDidRetract()
}

public enum Position {
    case UpperRight
    case UpperLeft
    case LowerRight
    case LowerLeft
    case Center
}

public class JVFlowerMenu: UIImageView {
    
    //MARK: Public Variables
    public var centerView: UIView!
    public var pedals: [UIView] = [UIView]()
    public var pedalSize: CGFloat!
    public var pedalDistance: CGFloat = 100
    public var pedalSpace: CGFloat = 50
    public var startAngle: CGFloat!
    public var growthDuration: TimeInterval = 0.4
    public var stagger: TimeInterval = 0.06
    public var menuIsExpanded: Bool = false
    public var delegate: FlowerMenuDelegate?
    public var showPedalLabels = false
    public var currentPosition: Position! {
        willSet(value) {
            self.previousPosition = self.currentPosition
        }
        didSet{
            
            self.constrainToPosition(thePosition: self.currentPosition, animate: true)
        }
    }
    //MARK: Private Variables
    var pedalIDs: [String: UIView] = [String: UIView]()
    var positionView: UIView!
    var previousPosition: Position?
    var arrayOfConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    lazy var focusView = UIView()
    //var theSuperView: UIView!
    
    //MARK: Init functions
    public init(withPosition: Position, andSuperView view: UIView, andImage: UIImage?){
        super.init(image: andImage)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        view.addSubview(self)
        self.constrainToPosition(thePosition: withPosition, animate: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCenterView(_:)))
        self.addGestureRecognizer(tapGesture)
        self.currentPosition = withPosition
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    //MARK: Public functions
    public func addPedal(theImage: UIImage, identifier: String){
        let newPedal = self.createAndConstrainPedal(image: theImage, name: identifier)
        self.addSubview(newPedal)
        self.constrainPedalToSelf(thePedal: newPedal)
        self.pedals.append(newPedal)
        self.pedalIDs[identifier] = newPedal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPopOutView(_:)))
        newPedal.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pannedViews(_:)))
        newPedal.addGestureRecognizer(panGesture)
        newPedal.alpha = 0
    }
    
    public func selectPedalWithID(identifier: String) {
        for key in self.pedalIDs.keys {
            if key == identifier {
                
                guard let view = self.pedalIDs[key] else{
                    return
                }
                
                self.delegate?.flowerMenuDidSelectPedalWithID(theMenu: self, identifier: key, pedal: view)
            }
        }
    }
    
    public func getPedalFromIdentifier(identifier: String) -> UIView {
        return UIView()
    }
    
    
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
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
    
    public func grow(){
        for (index, view) in self.pedals.enumerated() {
            let indexAsDouble = Double(index)
            
            
            UIView.animate(withDuration: self.growthDuration, delay: self.stagger * indexAsDouble, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.allowUserInteraction, animations: { 
                view.alpha = 1
                view.transform = self.getTransformForPopupViewAtIndex(index: CGFloat(index))
            }, completion: { (didComplete) in
                self.delegate?.flowerMenuDidExpand()
            })
        }
        self.menuIsExpanded = true
        
        
        for c in self.arrayOfConstraints {
            c.constant += 100
        }
        
        self.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        self.focusView.frame = self.superview!.frame
        self.focusView.alpha = 0.5
        self.focusView.backgroundColor = UIColor.black
        self.superview?.insertSubview(self.focusView, belowSubview: self)
        
    }
    
    public func shrivel(){
        for (index, view) in self.pedals.enumerated() {
            let indexAsDouble = Double(index)
            
            UIView.animate(withDuration: self.growthDuration, delay: self.stagger * indexAsDouble, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.allowUserInteraction, animations: { 
                view.alpha = 0
                view.transform = CGAffineTransform.identity
            }, completion: { (didComplete) in
                self.delegate?.flowerMenuDidRetract()
            })
        }
        self.menuIsExpanded = false
        
        for c in self.arrayOfConstraints {
            c.constant -= 100
        }
        
        self.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
        self.focusView.removeFromSuperview()
        
    }
    
    internal func didTapPopOutView(_ sender: UITapGestureRecognizer) {
        for key in self.pedalIDs.keys {
            guard let view = self.pedalIDs[key] else{
                break
            }
            if view == sender.view {
                self.delegate?.flowerMenuDidSelectPedalWithID(theMenu: self, identifier: key, pedal: view)
            }
        }
    }
    
    internal func didTapCenterView(_ sender: UITapGestureRecognizer){
        if self.menuIsExpanded {
            self.shrivel()
            //self.currentPosition = .UpperRight
        }else{
            self.grow()
            //self.currentPosition = .Center
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
        
        let point = sender.location(in: self)
        
        let centerX = self.bounds.origin.x + self.bounds.size.width / 2
        
        let centerY = self.bounds.origin.y + self.bounds.size.height / 2
        
        if sender.state == UIGestureRecognizerState.changed {
            
            let deltaX = point.x - centerX
            
            let deltaY = point.y - centerY
            
            let atan = Double(atan2(deltaX, -deltaY))
            
            let angle = atan * Double(180) / M_PI
            
            //self.pedalDistance = sqrt(pow(point.x - centerX, 2) + pow(point.y - centerY, 2))
            
            self.startAngle = CGFloat(angle) - self.pedalSpace * CGFloat(indexOfView!)
            
            theView.center = point
            
            theView.transform = CGAffineTransform.identity
            
            for (index, aView) in self.pedals.enumerated() {
                if aView != theView {
                    aView.transform = self.getTransformForPopupViewAtIndex(index: CGFloat(index))
                }
            }
            
        }else if sender.state == UIGestureRecognizerState.ended {
            theView.center = CGPoint(x: centerX, y: centerY)
            for (index, aView) in self.pedals.enumerated() {
                aView.transform = self.getTransformForPopupViewAtIndex(index: CGFloat(index))
            }
        }
        
    }
    
    internal func getTransformForPopupViewAtIndex(index: CGFloat) -> CGAffineTransform{
        
        let newAngle = Double(self.startAngle + (self.pedalSpace * index))
        
        let deltaY = Double(-self.pedalDistance) * cos(newAngle / 180 * M_PI)
        
        let deltaX = Double(self.pedalDistance) * sin(newAngle / 180 * M_PI)
        
        return CGAffineTransform(translationX: CGFloat(deltaX), y: CGFloat(deltaY))
    }
    
    private func createAndConstrainPedal(image: UIImage, name: String) -> UIView {
        
        let newPedal = UIView()
        let pedalImage = UIImageView(image: image)
        let pedalLabel = UILabel()
        
        newPedal.translatesAutoresizingMaskIntoConstraints = false
        pedalImage.translatesAutoresizingMaskIntoConstraints = false
        newPedal.isUserInteractionEnabled = true
        pedalLabel.isUserInteractionEnabled = true
        pedalImage.isUserInteractionEnabled = true
        pedalLabel.translatesAutoresizingMaskIntoConstraints = false
        pedalLabel.numberOfLines = 1
        if self.showPedalLabels == false {
            pedalLabel.text = name
            pedalLabel.isHidden = true
        }
        pedalLabel.text = name
        pedalLabel.adjustsFontSizeToFitWidth = true
        
        newPedal.addSubview(pedalImage)
        newPedal.addSubview(pedalLabel)
        
        let dictionaryOfViews = ["image": pedalImage, "label": pedalLabel]
        
        self.constrainPedal(thePedal: newPedal, pedalSubViews: dictionaryOfViews)
        
        return newPedal
        
    }
    
    //MARK: Constraint Adding
    func constrainToPosition(thePosition: Position, animate: Bool) {
        if self.arrayOfConstraints.count > 0 {
            self.superview?.removeConstraints(self.arrayOfConstraints)
            self.arrayOfConstraints.removeAll()
        }
        
        switch thePosition {
        case .Center:
            let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
            let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.superview, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
            self.arrayOfConstraints.append(verticalConstraint)
            self.arrayOfConstraints.append(horizontalConstraint)
            self.startAngle = 0
            print("Constrain To Center")
        case .LowerLeft:
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-28-[me]", options: [], metrics: nil, views: ["me": self])
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[me]-28-|", options: [], metrics: nil, views: ["me":self])
            self.arrayOfConstraints.append(contentsOf: horizontalConstraints)
            self.arrayOfConstraints.append(contentsOf: verticalConstraints)
            self.startAngle = 10
            print("Constrain To Lower Left")
        case .LowerRight:
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[me]-28-|", options: [], metrics: nil, views: ["me": self])
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[me]-28-|", options: [], metrics: nil, views: ["me":self])
            self.arrayOfConstraints.append(contentsOf: horizontalConstraints)
            self.arrayOfConstraints.append(contentsOf: verticalConstraints)
            self.startAngle = -80
            print("Constrain To Lower Right")
        case .UpperLeft:
            if self.superview is UINavigationBar {
                let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[me]", options: [], metrics: nil, views: ["me": self])
                let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[me]", options: [], metrics: nil, views: ["me":self])
                self.arrayOfConstraints.append(contentsOf: horizontalConstraints)
                self.arrayOfConstraints.append(contentsOf: verticalConstraints)
            }else{
                let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[me]", options: [], metrics: nil, views: ["me": self])
                let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[me]", options: [], metrics: nil, views: ["me":self])
                self.arrayOfConstraints.append(contentsOf: horizontalConstraints)
                self.arrayOfConstraints.append(contentsOf: verticalConstraints)
            }
            
            print("Constrain To Upper Left")
            self.startAngle = 100
        case .UpperRight:
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[me]-10-|", options: [], metrics: nil, views: ["me": self])
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[me]", options: [], metrics: nil, views: ["me":self])
            self.arrayOfConstraints.append(contentsOf: horizontalConstraints)
            self.arrayOfConstraints.append(contentsOf: verticalConstraints)
            self.startAngle = 170
            print("Constrain To Upper Right")
        }
        
        self.superview?.addConstraints(self.arrayOfConstraints)
        self.setNeedsLayout()
        
        if animate {
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
        }else{
            self.layoutIfNeeded()
        }
    }
    
    private func constrainPedal(thePedal: UIView, pedalSubViews: [String: AnyObject]){
        
        var arrayOfConstraint = [NSLayoutConstraint]()
        
        let imageLabelVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[image][label]|", options: [], metrics: nil, views: pedalSubViews)
        
        let imageHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[image]-(>=0)-|", options: [], metrics: nil, views: pedalSubViews)
        
        guard let theImage = pedalSubViews["image"] as? UIImageView, let label = pedalSubViews["label"] as? UILabel else {
            return
        }
        
        if self.showPedalLabels == false {
            let labeHeight = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0)
            arrayOfConstraint.append(labeHeight)
        }
        
        let moreImageHorizontal = NSLayoutConstraint(item: theImage, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: thePedal, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        
        let labelHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: pedalSubViews)
        
        arrayOfConstraint.append(contentsOf: imageLabelVertical)
        arrayOfConstraint.append(contentsOf: imageHorizontal)
        arrayOfConstraint.append(moreImageHorizontal)
        arrayOfConstraint.append(contentsOf: labelHorizontal)
        thePedal.addConstraints(arrayOfConstraint)
    }
    
    private func constrainPedalToSelf(thePedal: UIView) {
        
        var arrayOfConstraints = [NSLayoutConstraint]()
        
        
        let centerX = NSLayoutConstraint(item: thePedal, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        
        let centerY = NSLayoutConstraint(item: thePedal, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        
        arrayOfConstraints.append(centerX)
        arrayOfConstraints.append(centerY)
        
        self.addConstraints(arrayOfConstraints)
        
    }
    
}
