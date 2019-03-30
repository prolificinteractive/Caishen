#
# Be sure to run `pod lib lint Caishen.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Caishen"
  s.version          = "2.2.1"
  s.summary          = "A Payment Card UI & Validator for iOS"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                       Caishen provides a text field to enter credit card (or other card) information and validates most of this information on its own.
                       DESC

  s.homepage         = "https://github.com/prolificinteractive/caishen.git"
  s.license          = 'MIT'
  s.author           = { "Daniel Vancura" => "daniel@prolificinteractive.com" }
  s.source           = { :git => "https://github.com/prolificinteractive/caishen.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '4.2'

  s.source_files = 'Pod/Classes/**/*.swift'
  s.resources = ['Pod/Assets/*', 'Pod/Resources/*', 'Pod/**/*.{xib}']
end
