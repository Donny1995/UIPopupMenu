#
# Be sure to run `pod lib lint UIPopupMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIPopupMenu'
  s.version          = '1.0.0'
  s.summary          = 'Framework for creating UIMenu alike controllers just like Apple\'s'
  s.description      = <<-DESC
This took hours to replicate
                       DESC

  s.homepage         = 'https://github.com/Donny1995/UIPopupMenu'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Donny1995' => 'sanny199955@mail.ru' }
  s.source           = { :git => 'https://github.com/Donny1995/UIPopupMenu.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  
  s.source_files = 'UIPopupMenu/Classes/**/*'
  
  # s.resource_bundles = {
  #   'UIPopupMenu' => ['UIPopupMenu/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
