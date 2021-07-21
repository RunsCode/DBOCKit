#
# Be sure to run `pod lib lint DBOCKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DBOCKit'
  s.version          = '0.1.1'
  s.summary          = 'A DB SQL Chain.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A DB SQL Chain
                       DESC

  s.homepage         = 'https://github.com/RunsCode'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RunsCode' => 'runs.wang.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/RunsCode/DBOCKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DBOCKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DBOCKit' => ['DBOCKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB'
  s.dependency 'MJExtension'
end
