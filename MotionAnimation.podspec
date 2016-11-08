Pod::Spec.new do |s|
  s.name             = "MotionAnimation"
  s.version          = "0.1.2"
  s.summary          = "Lightweight animation library for UIKit in Swift"

  s.description      = <<-DESC
                        An animation library written in swift. Checkout the Examples folder for more.
                        Consider MotionAnimation as a extremely simplified version of facebook's pop library.
                        There is no performance optimization or background work. This project is made for simplicity and ease of use. It is for people who want to learn how an animation library is made.
                       DESC

  s.homepage         = "https://github.com/lkzhao/MotionAnimation"
  s.screenshots     = "https://github.com/lkzhao/MotionAnimation/blob/master/imgs/demo.gif?raw=true"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/MotionAnimation.git", :tag => s.version.to_s }
  
  s.ios.deployment_target  = '8.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'MotionAnimation/*.swift'
end
