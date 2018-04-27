Pod::Spec.new do |s|
  s.name     = 'MBAppKit'
  s.version  = '0.7.0'
  s.author   = 'BB9z'
  s.license  = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.homepage = 'https://github.com/RFUI/MBAppKit'
  s.summary  = '通用项目基础套件'
  s.source   = {
    :git => 'https://github.com/RFUI/MBAppKit.git',
    :tag => s.version.to_s
  }
  
  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.pod_target_xcconfig = {
  }

  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.dependency 'RFKit', '~> 2.0'
    ss.dependency 'RFKit/Category/NSDate'
    ss.dependency 'RFKit/Category/NSDateFormatter'
    ss.dependency 'RFKit/Category/NSURL'
    ss.dependency 'RFKit/Category/NSJSONSerialization'
    ss.dependency 'RFKit/Category/NSLayoutConstraint'
    ss.dependency 'RFAlpha/RFSwizzle'
    ss.dependency 'AFNetworking/NSURLConnection', '~> 2.6'
    ss.dependency 'RFMessageManager/RFNetworkActivityIndicatorMessage', '~> 0.3'
    ss.dependency 'RFAPI', '~> 1.1'
    ss.source_files = ['MBAppKit/**/*.{h,m}']
    ss.public_header_files = 'MBAppKit/**/*.h'
    ss.private_header_files = 'MBAppKit/shadow.h'
  end

  # Config
  s.subspec 'UserIDIsString' do |ss|
    ss.dependency 'MBAppKit/Core'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MBUserStringUID=1' }
    ss.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MBUserStringUID=1' }
  end

  # Components
  s.subspec 'ApplicationFont' do |ss|
    ss.dependency 'MBAppKit/Core'
    ss.source_files = 'Components/MBApplicationFont/*.{h,m}'
    ss.public_header_files = 'Components/MBApplicationFont/*.h'
  end

  s.subspec 'Button' do |ss|
    ss.dependency 'RFInitializing'
    ss.dependency 'RFKit/RFGeometry'

    ss.source_files = 'Components/Button/*.{h,m}'
    ss.public_header_files = 'Components/Button/*.h'
  end

  s.subspec 'Input' do |ss|
    ss.dependency 'RFInitializing'
    ss.dependency 'RFKit/RFGeometry'
    ss.dependency 'RFKit/Category/UIResponder'
    ss.dependency 'RFAlpha/RFDelegateChain/UITextFieldDelegate'

    ss.source_files = 'Components/Input/*.{h,m}'
    ss.public_header_files = 'Components/Input/*.h'
  end

  s.subspec 'Worker' do |ss|
    ss.dependency 'MBAppKit/Core'
    ss.source_files = 'Components/MBWorker/*.{h,m}'
    ss.public_header_files = 'Components/MBWorker/*.h'
  end
end
