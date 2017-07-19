require 'mixer_api/adapters'
require 'mixer_api/client'
require 'mixer_api/request'
require 'mixer_api/version'

module MixerApi
  def self.new(options={})
    MixerApi::Client.new(options)
  end
end
