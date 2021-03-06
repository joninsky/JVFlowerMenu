
Pod::Spec.new do |s|
s.name             = "JVFlowerMenu"
s.version          = "1.0.10"
s.summary          = "A simple, fun, menu UI element. Great replacement for hamburger menus and tab bar menus."
s.description      = <<-DESC
Lets you create a fun pop out radial (Flower pedals) menu. See docs and README for instructions on how to use.
                   DESC

s.homepage         = "https://github.com/joninsky/JVFlowerMenu.git"
s.license          = 'MIT'
s.author           = { "Jon Vogel" => "joninsky@gmail.com" }
s.source           = { :git => "https://github.com/joninsky/JVFlowerMenu.git", :tag => s.version.to_s}

s.platform     = :ios, '12.4'
s.requires_arc = true
s.swift_version = '5'
s.exclude_files = "JVFlowerMenu/**/*.plist"
s.source_files = "JVFlowerMenu/**/*"

end
