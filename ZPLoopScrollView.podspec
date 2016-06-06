
Pod::Spec.new do |s|
  s.name         = "ZPLoopScrollView"
  s.version      = "1.0.2"
  s.summary      = "Using three UIImageView pictures in an infinite loop, you can manually drag and drop and click on interactive"

  s.description  = <<-DESC
                   Using three UIImageView pictures in an infinite loop, you can manually drag and drop and click on interactive (使用三个UIImageView实现图片的无限循环,可手动拖拽以及点击交互)
                   DESC
  s.homepage     = "https://github.com/twenty-zp/ZPLoopScrollView"
  s.author       =  {'twenty-zp' => 'twenty-zp'}
  s.license      =  { :type => 'MIT', :file => 'ZPLoopScrollView/LICENSE.txt'}
  s.platform     =  :ios, '7.0'
  s.source       = { :git => "https://github.com/twenty-zp/ZPLoopScrollView.git", :tag => s.version}
  s.dependency   'AFNetworking', '>= 3.0.0'
  s.source_files  = 'ZPLoopScrollView/*.{h,m}'
  s.framework     = 'UIKit'
  s.requires_arc = true
 
end
