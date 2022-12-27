

Pod::Spec.new do |s|


  s.name         = "MMStickerView"

  s.version      = "0.0.1"

  s.summary      = "iOS MMStickerView"

  s.description  = <<-DESC
  					能优化和严格的内存控制让其运行更加的流畅和稳健。
                   DESC

  s.homepage     = "https://github.com/Miles-Matheson"

  s.license      = "MIT"

  s.author       = { "John" => "liyida188@163.com" }

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/Miles-Matheson/MMStickerView.git", :tag => "0.0.1" }

  s.requires_arc = true

  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}

  s.requires_arc = true
  s.resources      = 'MMStickerView/Assets/*.xcassets' 
  s.source_files   = 'MMStickerView/Classes/**/*.{h,m,mm,a,pch,swift}'

end
