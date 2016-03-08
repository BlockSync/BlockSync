Pod::Spec.new do |s|

  s.name         = "BlockSync"
  s.version      = "1.0.0"
  s.summary      = "A useful set of async functions for objective-c"
  s.homepage     = "https://github.com/BlockSync/BlockSync"
  s.license  = "MIT"
  s.author       = { "Ryan Copley" => "rcopley@gannett.com" }
  s.requires_arc = true
  s.platform     = :ios
  s.platform     = :ios, '6.0'
  s.source       = { :git => "git@github.com:BlockSync/BlockSync.git", :branch => "master" }
  s.source_files = "BlockSync/*.{h,m}"
  s.public_header_files = "BlockSync/*.h"
 
end
