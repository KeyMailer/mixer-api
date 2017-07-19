require 'httparty'

module MixerApi
  module Adapters
    class HTTPartyAdapter < BaseAdapter

      def self.request(method, url, options = {})
        res = HTTParty.send(method, url, options)
        {body: res, response: res.code, headers: res.headers}
      end

    end
  end
end
