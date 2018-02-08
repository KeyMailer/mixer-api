$:.push File.expand_path("../lib", __FILE__)

require 'mixer_api/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'mixer_api'
  s.version     = MixerApi::VERSION::STRING
  s.date        = Date.today.to_s
  s.summary     = "Mixer API"
  s.description = "Simplify Mixer's API for Ruby"
  s.authors     = ["Dave Hartnoll"]
  s.email       = 'dave.hartnoll@keymailer.co'
  s.homepage    = "https://github.com/KeyMailer/mixer-api"
  s.license     = 'MIT'

  s.files       = Dir["lib/**/*"]
  s.require_paths = ["lib"]
  
  s.add_dependency 'httparty'
  # s.add_dependency('json')
end
