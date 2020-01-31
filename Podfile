project 'MBAppKit.xcodeproj'

target 'Test-iOS' do
    platform :ios, '9.0'

    pod 'MBAppKit', :path => '.', :subspecs => [
        'ApplicationFont',
        'Button',
        'Environment',
        'Input',
        'Worker',
        'Navigation',
    ]
    pod 'RFAPI', :git => 'https://github.com/RFUI/RFAPI.git'
end

target 'Test-macOS' do
    platform :macos, '10.10'

    pod 'MBAppKit', :path => '.', :subspecs => [
        'Core',
    ]
    pod 'RFAPI', :git => 'https://github.com/RFUI/RFAPI.git'
end
