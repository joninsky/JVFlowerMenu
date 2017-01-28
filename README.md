#JVFlowerMenu is a quick and easy replacement to a hamburger menu and possibly a UITabBar

The `JVFlowerMenu` is not a controller but rather a drop in UI element that you could then use to control the content of any UI View. Here is a quick example of the final product:

![menuGIF](https://github.com/joninsky/JVFlowerMenu/blob/master/JVFlowerMenu.gif)

#Setup

Cocoapods

```shell
pod 'JVFlowerMenu'
```
#Limitations

1) Right now the classes are not @UIDesignable or @UIInspectable. This means that if you want to add them you have to add the constraints yourself in code or live and let live after you assign a frame. 

2) Will have unexpected behavior if it's super view is not the root view of your view controller.

3) Any transforms you apply to the menu will mess up the behavior.

#Example

initalize a `JVFlowerMenu` like this:

```swift
let menu = JVFlowerMenu(withImage: nil, andTitle: nil)
```
Initalizing with a `nil` image will default to a drawing of a hamburger menu. A `nil` title wil just produce nothing for the title.


Then you can add `Pedals` like this:

```swift
menu.addPedal(withImage: nil, withTitle: nil)
menu.addPedal(withImage: nil, withTitle: nil)
menu.addPedal(withImage: nil, withTitle: nil)
```

If you pass `nil` for a `Pedal` image it will default to a drawing of a circle. `nil` for the title will display nothing.

You can then become the delegate and get notified about events in these methods:

```swift
menu.delegate = self

//MARK: Delegate Functions

public func flowerMenuDidSelectPedalWithID(_ theMenu: JVFlowerMenu, pedal: Pedal) {
    print("\(pedal.ID) Selected")
}

public func flowerMenuDidExpand() {
    print("Flower Menu expanded")
}

public func flowerMenuDidRetract() {    
    print("Flower Menu Retracted")
}
```

There are some properties you can change to manipulate the behavior of the menu:

```swift
menu.startAngle = 90.0
menu.pedalDistance = 200
menu.pedalSpace = 20
menu.stagger = 0
```

Finally, here is some set up code for adding constraints progmatically:

```swift
override func viewDidLoad() {
    self.view.addSubview(menu)
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

```