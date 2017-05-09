Pod::Spec.new do |s|

  s.name         = "GQImageViewer"
  s.version      = "1.0.3"
  s.summary      = "一款多图文浏览器，支持图文混合浏览和单图片浏览，增加底部文字，仿今日头条效果，图片原尺寸显示，不会变形，双击放大缩小，单击消失，支持多张本地及网络图片混合查看，支持链式调用，支持WebP图片浏览。"

  s.homepage     = "https://github.com/g763007297/ImageViewer"
  # s.screenshots  = "https://github.com/g763007297/ImageViewer/blob/master/Screenshot/demo.gif"

  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "developer_高" => "763007297@qq.com" }
  
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/g763007297/ImageViewer.git" , :tag => s.version}

  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = "GQImageViewer/**/*.{h,m}"
  end

  s.subspec 'WebP' do |webp|
    webp.source_files = 'GQImageViewer/GQCategory/UIImage+GQImageViewrCategory.{h,m}'
    
    webp.xcconfig = { 
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GQ_WEBP=1'
    }
    
    webp.dependency 'GQImageViewer/Core'
    webp.ios.vendored_frameworks = 'GQImageViewer/GQThirdPart/WebP.framework'
  end

end
