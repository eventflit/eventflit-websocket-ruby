# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventflit-client/version'

Gem::Specification.new do |s|
  s.name             = 'eventflit-client'
  s.version          = EventflitClient::VERSION
  s.authors          = ["Eventflit", "Logan Koester"]
  s.email            = ['support@eventflit.com']
  s.homepage         = 'http://github.com/eventflit/eventflit-ruby-client'
  s.summary          = 'Client for consuming WebSockets from http://eventflit.com'
  s.description      = 'Client for consuming WebSockets from http://eventflit.com'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f|
    File.basename(f)
  }
  s.extra_rdoc_files = %w(LICENSE.txt README.rdoc)
  s.require_paths    = ['lib']
  s.licenses         = ['MIT']

  s.add_runtime_dependency 'websocket', '~> 1.0'
  s.add_runtime_dependency 'json'

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
end
