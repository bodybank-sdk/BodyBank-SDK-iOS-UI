Pod::Spec.new do |s|
    s.name = 'BodyBankEnterpriseUI'
    s.summary = 'BodyBank Enterprise iOS UI SDK'
    s.version = '0.1.1'
    s.author = 'Bodygram Inc.'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage = 'git@github.com:bodybank-sdk/BodyBank-SDK-iOS-UI.git'
    s.platform = :ios, '10.0'
    s.swift_version = '5.0'
    s.source = {
        :git => "https://github.com/bodybank-sdk/BodyBank-SDK-iOS-UI.git",
        :tag => s.version.to_s
    }
    s.subspec 'Camera' do |camera|
        camera.ios.framework = 'AVFoundation', 'AssetsLibrary', 'MobileCoreServices', 'ImageIO', 'CoreMotion', 'CoreImage', 'Photos'
        camera.dependency 'BodyBankEnterprise'
        camera.dependency 'SimpleImageViewerNew'
        camera.dependency 'SwiftSpinner'
        camera.dependency 'Alertift'
        camera.source_files = 'BodyBankEnterpriseUI/Camera/**/*.swift',
  'BodyBankEnterpriseUI/Misc/*.swift'
        camera.resource_bundle = {
            'BodyBankEnterpriseUI-Camera' => [
            'BodyBankEnterpriseUI/Camera/*.storyboard',
            'BodyBankEnterpriseUI/Camera/*.xcassets'
            ]
        }
    end
    s.subspec 'History' do |history|
        history.dependency 'BodyBankEnterprise'
        history.dependency 'SimpleImageViewerNew'
        history.dependency 'NVActivityIndicatorView', '~> 4.6.1'
        history.dependency 'Kingfisher', '~> 4.10.1', '< 5.0'
        history.dependency 'Alertift'
        history.dependency 'AFDateHelper'
        history.dependency 'SCPageViewController'
        history.source_files = 'BodyBankEnterpriseUI/History/*.swift', 'BodyBankEnterpriseUI/Misc/*.swift'
        history.resource_bundle = {
            'BodyBankEnterpriseUI-History' => [
            'BodyBankEnterpriseUI/History/*.storyboard',
            'BodyBankEnterpriseUI/History/*.xcassets'
            ]
        }
    end
    s.subspec 'Tutorial' do |tutorial|
        tutorial.dependency 'BodyBankEnterprise'
        tutorial.source_files = 'BodyBankEnterpriseUI/Tutorial/*.swift', 'BodyBankEnterpriseUI/Misc/*.swift'
        tutorial.resource_bundle = {
            'BodyBankEnterpriseUI-Tutorial' => [
            'BodyBankEnterpriseUI/Tutorial/*.storyboard',
            'BodyBankEnterpriseUI/Tutorial/*.xcassets'
            ]
        }
    end
end
