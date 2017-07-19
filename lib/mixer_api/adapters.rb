require 'mixer_api/adapters/base_adapter'
require 'mixer_api/adapters/httparty_adapter'

module MixerApi
  module Adapters
    DEFAULT_ADAPTER = MixerApi::Adapters::HTTPartyAdapter

    def get_adapter(adapter, default_adapter = DEFAULT_ADAPTER)
      begin
        MixerApi::Adapters.const_defined?(adapter.to_s)
      rescue
        default_adapter
      else
        adapter
      end
    end
  end
end
