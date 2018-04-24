Pod::Spec.new do |s|
  s.name     = 'MBAppKit'
  s.version  = '0.5.0'
  s.author   = 'BB9z'
  s.license  = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.homepage = 'https://github.com/RFUI/MBAppKit'
  s.summary  = '通用项目基础套件'
  s.source   = {
    :git => 'https://github.com/RFUI/MBAppKit.git'
  }
  
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  
  # s.vendored_frameworks = 'Output/*.framework'
  # s.vendored_libraries = 'Output/**/*.a'

  s.dependency 'RFKit', '~> 2.0'
  s.dependency 'RFKit/Category/NSDate'
  s.dependency 'RFKit/Category/NSDateFormatter'
  s.dependency 'RFKit/Category/NSURL'
  s.dependency 'RFKit/Category/NSJSONSerialization'
  s.dependency 'RFKit/Category/NSLayoutConstraint'
  s.dependency 'RFAlpha/RFSwizzle'
  s.dependency 'AFNetworking/NSURLConnection', '~> 2.6'
  s.dependency 'RFMessageManager/RFNetworkActivityIndicatorMessage', '~> 0.2'
  s.dependency 'RFAPI', '~> 1.0'

  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(SRCROOT)/../Frameworks/RFUI/Alpha/**" "$(SRCROOT)/../MBAppKit/MBAppKit"' }
  s.exclude_files = ['MBAppKit/shadow.h']

  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.source_files = [
      'MBAppKit/**/*.{h,m}'
    ]
  end

  s.subspec 'UserIDIsString' do |ss|
    ss.dependency 'MBAppKit/Core'
    ss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MBUserStringUID=1' }
    ss.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'MBUserStringUID=1' }
  end
end
