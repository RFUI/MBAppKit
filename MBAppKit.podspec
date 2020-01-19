Pod::Spec.new do |s|
  s.name     = 'MBAppKit'
  s.version  = '0.9.1'
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
  s.macos.deployment_target = '10.10'

  s.pod_target_xcconfig = {
  }

  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.dependency 'RFKit', '~> 2.0'
    ss.dependency 'RFKit/Category/NSDate'
    ss.dependency 'RFKit/Category/NSDateFormatter'
    ss.dependency 'RFKit/Category/NSURL'
    ss.dependency 'RFKit/Category/NSJSONSerialization'
    ss.dependency 'RFAlpha/RFSwizzle'
    ss.dependency 'RFAPI', '>= 1.2'

    ss.ios.dependency 'RFKit/Category/NSLayoutConstraint'
    ss.ios.source_files = ['MBAppKit/**/*.{h,m}']
    ss.ios.exclude_files = '**/macos/*'
    ss.ios.public_header_files = 'MBAppKit/**/*.h'

    ss.macos.source_files = [
      'MBAppKit/MBApplicationDelegate/macos/*.{h,m}',
      'MBAppKit/MBGeneral/*.{h,m}',
      'MBAppKit/MBUserDefaults/*.{h,m}',
      'MBAppKit/shadow.h',
    ]
    ss.macos.public_header_files = [
      'MBAppKit/MBApplicationDelegate/macos/*.h',
      'MBAppKit/MBGeneral/*.h',
      'MBAppKit/MBUserDefaults/*.h',
    ]
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
    ss.ios.deployment_target = '9.0'

    ss.dependency 'MBAppKit/Core'
    ss.source_files = 'Components/MBApplicationFont/*.{h,m}'
    ss.public_header_files = 'Components/MBApplicationFont/*.h'
  end

  s.subspec 'Button' do |ss|
    ss.ios.deployment_target = '9.0'

    ss.dependency 'RFInitializing'
    ss.dependency 'RFKit/RFGeometry'
    ss.source_files = 'Components/Button/*.{h,m}'
    ss.public_header_files = 'Components/Button/*.h'
  end

  s.subspec 'Environment' do |ss|
    ss.ios.deployment_target = '9.0'

    ss.dependency 'RFKit/Runtime'
    ss.dependency 'RFKit/Category/NSArray'
    ss.source_files = 'Components/Environment/*.{h,m}'
    ss.public_header_files = 'Components/Environment/*.h'
  end

  s.subspec 'Input' do |ss|
    ss.ios.deployment_target = '9.0'

    ss.dependency 'MBAppKit/Core'
    ss.dependency 'RFInitializing'
    ss.dependency 'RFKit/RFGeometry'
    ss.dependency 'RFKit/Category/UIResponder'
    ss.dependency 'RFDelegateChain/UITextFieldDelegate'
    ss.source_files = 'Components/Input/*.{h,m}'
    ss.public_header_files = 'Components/Input/*.h'
  end

  s.subspec 'Worker' do |ss|
    ss.ios.deployment_target = '9.0'
    
    ss.dependency 'MBAppKit/Core'
    ss.dependency 'RFInitializing'
    ss.source_files = 'Components/MBWorker/*.{h,m}'
    ss.public_header_files = 'Components/MBWorker/*.h'
  end
  
  s.subspec 'Navigation' do |ss|
    ss.ios.deployment_target = '9.0'

    ss.dependency 'MBAppKit/Core'
    ss.dependency 'RFAlpha/RFSynthesize'
    ss.dependency 'RFAlpha/RFNavigationController'
    ss.dependency 'RFKit/Category/NSArray'
    ss.dependency 'RFKit/Category/UIResponder'
    ss.source_files = 'Components/Navigation/*.{h,m}'
    ss.public_header_files = 'Components/Navigation/*.h'
  end
end
