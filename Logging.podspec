Pod::Spec.new do |s|
  s.name             = "Logging"
  s.version          = "1.0"
  s.summary          = "A statically linked library for logging from OS X and iOS."
  s.description      = <<-DESC
                      A project that builds static libraries for logging.

                      Will build targets for OS X or iOS depending on the workspace scheme.
                       DESC
  s.homepage         = "http://github.com/smorrison/Logging"
  s.license          = 'MIT'
  s.author           = { "Sean Morrison" => "sean.morriss@gmail.com" }
  s.source           = { :git => "https://github.com/smorrison/Logging.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.public_header_files = 'Logging/*.h'
  s.source_files = 'Logging/*.{h,m}'

 end
