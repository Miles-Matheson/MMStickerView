

Pod::Spec.new do |s|


  s.name         = "MMStickerView"

  s.version      = "0.0.1"

  s.summary      = "iOS MMStickerView"

  s.description  = <<-DESC
  					能优化和严格的内存控制让其运行更加的流畅和稳健。
                   DESC

  s.homepage     = "https://github.com/Miles-Matheson"

  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Miles" => "liyida188@163.com" }

  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/Miles-Matheson/MMStickerView.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}

  s.requires_arc = true
  s.resources      = 'MMStickerView/Assets/*.xcassets' 
  s.source_files   = 'MMStickerView/Classes/**/*.{h,m,mm,a,pch,swift}'
  s.swift_versions   = ['5.1', '5.2', '5.3']
  s.ios.deployment_target = '11.0'

end
