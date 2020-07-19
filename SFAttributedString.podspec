Pod::Spec.new do |s|
  s.name         = "SFAttributedString"
  s.version      = "1.0.0"
  s.summary      = "This is by far the most leveraged way to output `NSAttributedString`."
  s.homepage     = "https://github.com/Meterwhite/SFAttributedString"
  s.license      = "MIT"
  s.author       = { "Meterwhite" => "meterwhite@outlook.com" }
  s.source        = { :git => "https://github.com/Meterwhite/SFAttributedString.git", :tag => s.version.to_s }
  s.source_files  = "OBJC/SFAttributedString/*.{h,m}"
  s.requires_arc  = true
  s.framework     = "UIKit"
  
  s.ios.deployment_target     = "7.0"
  s.tvos.deployment_target    = "9.0"
end
