
Pod::Spec.new do |s|
s.name             = "JVFlowerMenu"
s.version          = "1.0.1"
s.summary          = "A simple, fun, menu UI element. Great replacement for hamburger menus and tab bar menus."
s.description      = <<-DESC
Lets you create a fun pop out radial (Flower pedals) menu. See docs and README for instructions on how to use.
                   DESC

s.homepage         = "https://github.com/joninsky/JVFlowerMenu.git"
s.license          = 'MIT'
s.author           = { "pebblebee" => "dev@pebblebee.com" }
s.source           = { :git => "https://github.com/joninsky/JVFlowerMenu.git", :tag => s.version.to_s}

s.platform     = :ios, '9.4'
s.requires_arc = true

s.source_files = "JVFlowerMenu/**/*"
#s.resource_bundle = { "JVFlowerImages" => ["JVFlowerMenu/JVFlowerMenu/*.xcassets"] }
s.resource_bundles = { 'ResourceTest' => ['JVFlowerMenu/JVFlowerMenu/**/*'] }
s.resources = "JVFlowerMenu/**/*.{png,json}"
#s.resource = "JVFlowerMenu/JVFlowerMenu/*.xcassets"
end

#/Users/jonvogel/Desktop/JVFlowerMenu/JVFlowerMenu/JVFlowerMenu/Media.xcassets