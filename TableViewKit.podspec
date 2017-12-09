Pod::Spec.new do |s|
  s.name         = "TableViewKit"
  s.version      = "0.1"
  s.summary      = ""
  s.description  = <<-DESC
    Your description here.
  DESC
  s.homepage     = "https://github.com/MrAlek/TableViewKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Alek Åström" => "alek@iosnomad.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/MrAlek/TableViewKit.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "UIKit"
end
