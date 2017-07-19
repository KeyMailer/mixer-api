# Mixer API

This gem simplifies the Mixer-API for ruby users.


## Install

With Rails:

```ruby
#add to your Gemfile
gem 'mixer_api', '~> 0.0.0'
```

Just irb or pry:

```ruby
$ gem install mixer_api

irb > require 'mixer_api'
irb > @mixer_api = MixerApi.new()
```

### Adapters


To allow the gem to use different HTTP libraries, you can define an Adapter:

```ruby
require 'open-uri' 

module MixerApi
  module Adapters
    class OpenURIAdapter < BaseAdapter
      def self.request(method, url, options={})
        if (method == :get)
          ret = {}

          open(url) do |io|
            ret[:body] = JSON.parse(io.read)
            ret[:response] = io.status.first.to_i
          end

          ret
        end
      end
    end # class OpenURIAdapter
  end # module Adapters
end # module MixerApi
```

and then pass it into the MixerApi class:

```ruby
@mixer_api = MixerApi.new adapter: MixerApi::Adapters::OpenURIAdapter

# or

@mixer_api = MixerApi.new
@mixer_api.adapter = MixerApi::Adapters::OpenURIAdapter
```

Adapters must be defined inside the MixerApi::Adapters module, otherwise they will be considered invalid.
Any invalid adapter passed to the library will revert to the default adapter.

The default adapter is `MixerApi::Adapters::HTTPartyAdapter` which uses the [HTTParty library](https://github.com/jnunemaker/httparty).

Feel free to contribute or add functionality!

### Credits

Derived from the [twitch-rb gem](https://github.com/dustinlakin/twitch-rb)
