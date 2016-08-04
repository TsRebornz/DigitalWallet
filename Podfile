source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'Alamofire', '~> 3.4'
    pod 'Gloss', '~> 0.7'
    pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :tag => '4.0.0'
end

target 'MyProject' do
    shared_pods
end

target 'MyProjectTesting' do
	shared_pods
end
