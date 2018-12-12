Pod::Spec.new do |s|
    s.name = 'BodyBankEnterpriseUI'
    s.summary = 'BodyBank Enterprise iOS UI SDK'
    s.version = '0.0.1'
    s.author = 'Original Inc.'
    s.license = { :type => 'MIT', :file => 'LICENSE' }

    s.homepage = 'https://originalstitch.com'
    s.platform = :ios, '9.0'
    s.source = {
        :http => "https://github.com/bodybank-sdk/BodyBank-iOS-SDK-UI.git",
        :tag => s.version.to_s
    }
    s.subspec 'Camera' do |camera|
        camera.frameworks 'AVFoundation', 'AssetsLibrary', 'MobileCoreServices', 'ImageIO', 'CoreMotion', 'CoreImage', 'Photos'
        camera.dependency 'BodyBankEnterprise'
        camera.dependency 'SimpleImageViewer', git: 'https://github.com/aFrogleap/SimpleImageViewer'
        camera.dependency 'SwiftSpinner'
        camera.dependency 'Alertift'
        camera.source_files = 'BodyBankEnterpriseUI/Camera/*.swift', 'BodyBankEnterpriseUI/Misc/*.swift'
        camera.resoruce_bundle = {
            'BodyBankEnterpriseUI-Camera' => [
            'BodyBankEnterpriseUI/Camera/*.{storyboard, xcassets}
            ]
        }
    end
    s.subspec 'History' do |history|
        history.dependency 'BodyBankEnterprise'
        history.dependency 'SimpleImageViewer', git: 'https://github.com/aFrogleap/SimpleImageViewer'
        history.dependency 'NVActivityIndicatorView'
        history.dependency 'Kingfisher'
        history.dependency 'AFDateHelper'
        history.dependency 'SCPageViewController'
        history.source_files = 'BodyBankEnterpriseUI/History/*.swift', 'BodyBankEnterpriseUI/Misc/*.swift'
        camera.resoruce_bundle = {
            'BodyBankEnterpriseUI-History' => [
            'BodyBankEnterpriseUI/History/*.{storyboard, xcassets}
            ]
        }
    end
    s.subspec 'Tutorial' do |tutorial|
        history.source_files = 'BodyBankEnterpriseUI/Tutorial/*.swift', 'BodyBankEnterpriseUI/Misc/*.swift'
        camera.resoruce_bundle = {
            'BodyBankEnterpriseUI-Tutorial' => [
            'BodyBankEnterpriseUI/Tutorial/*.{storyboard, xcassets}
            ]
        }
    end
end
