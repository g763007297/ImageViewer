Pod::Spec.new do |s|

  s.name         = "GQImageViewer"
  s.version = "0.0.3"
  s.summary      = "一款多图片浏览器，图片原尺寸显示，不会变形定，双击放大缩小，单击消失，支持多张图片，支持链式调用"

  s.homepage     = "https://github.com/g763007297/ImageViewer"
  # s.screenshots  = "https://github.com/g763007297/ImageViewer/blob/master/Screenshot/demo.gif"

  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "developer_高" => "763007297@qq.com" }

  s.platform     = :ios
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/g763007297/ImageViewer.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.source_files  = "GQImageViewer/*.{h,m}"

  #s.public_header_files = "GQImageViewer/*.h"

  s.dependency "SDWebImage"

end
