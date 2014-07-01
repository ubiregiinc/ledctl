Gem::Specification.new do |s|
  s.name        = 'led_control_tool'
  s.version     = '0.1.0'
  s.date        = '2014-02-14'
  s.summary     = "Raspberry Pi LED(GPIO) Control Tool"
  s.description = "Simple LED blinking daemon."
  s.authors     = ["Soutaro Matsumoto"]
  s.email       = 'matsumoto@soutaro.com'
  s.homepage    = 'https://github.com/ubiregiinc/ledctl'
  s.license     = 'MIT'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  
  s.executables << "ledctl"
  s.add_runtime_dependency 'thor', '~> 0.18', '>= 0.18.1'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'
end
