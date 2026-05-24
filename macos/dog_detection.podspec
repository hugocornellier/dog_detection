Pod::Spec.new do |s|
  s.name                  = 'dog_detection'
  s.version               = '0.0.1'
  s.summary               = 'Dog detection via TensorFlow Lite (macOS)'
  s.description           = 'Flutter plugin for on-device dog face detection using TensorFlow Lite.'
  s.homepage              = 'https://github.com/your/repo'
  s.license               = { :type => 'MIT' }
  s.authors               = { 'You' => 'you@example.com' }
  s.source                = { :path => '.' }

  s.platform              = :osx, '11.0'

  # TFLite libraries are provided by flutter_litert dependency
end
