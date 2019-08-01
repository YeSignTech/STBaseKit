Pod::Spec.new do |s|
s.name		= 'STBaseKit'
s.version	= '0.0.1'
s.summary	= 'An Policy view on iOS'
s.homepage	= 'https://github.com/YeSignTech/STBaseKit'
s.license	= { :type => 'MIT' }
s.platform	= 'ios'
s.author	= {'YeSignTech' => 'YeSign@163.com'}
s.ios.deployment_target = '9.0'
s.source	= {:git => 'https://github.com/YeSignTech/STBaseKit.git', :tag => s.version}
s.source_files	= 'STBaseKit/*.swift'
s.requires_arc	= true
s.frameworks	= 'UIKit'
s.swift_version	= '4.1'
end
