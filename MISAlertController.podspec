#
#  Be sure to run `pod spec lint MISAlertController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  Any lines starting with a # are optional, but encouraged
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = 'MISAlertController'
  s.version      = '1.0.1'
  s.summary      = 'Add support for UIAlertController API to iOS7+. Uses UIAlertController (iOS 8+) and UIAlertView / UIAlertSheet (iOS 7) behind the scenes.'
  s.description  = <<-DESC
                    If you want to use UIAlertController, but still need to support iOS 7 this project is for you.

                    MISAlertController is a wrapper around UIAlertController and UIAlertView / UIActionSheet. On iOS 7 MISAlertController uses UIAlertView or UIActionSheet and on iOS 8 it uses UIAlertController to show Alerts and Action Sheets.

                    MISAlertController uses ARC and supports iOS 7.0+
                   DESC
  s.homepage     = 'https://github.com/maicki/MISAlertController'
  s.license      = 'MIT'
  s.author       = { 'Michael Schneider' => 'mischneider1@gmail.com' }
  # s.social_media_url   = 'http://twitter.com/maicki'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source       = { :git => 'https://github.com/maicki/MISAlertController.git', :tag => s.version.to_s }
  s.source_files = 'MISAlertController'
  s.public_header_files = 'MISAlertController/**/*.h'
  s.frameworks   = 'UIKit'

end
