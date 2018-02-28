Pod::Spec.new do |s|
  s.name     = 'MBAppKit'
  s.version  = '0.2.0'
  s.author   = 'BB9z'
  s.license  = { :type => 'private', :text => 'Copyright © 2018 BB9z. All rights reserved.' }
  s.homepage = 'https://github.com/RFUI/MBAppKit'
  s.source   = { :path => '.' }
  s.summary  = '通用项目基础套件'
  
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  
  # s.vendored_frameworks = 'Output/*.framework'
  # s.vendored_libraries = 'Output/**/*.a'
  s.source_files = [
    'include/*.h',
    'Pods/Headers/Public/**/*.h'
  ]
   s.resources = [
     'Resources/*'
   ]
end
