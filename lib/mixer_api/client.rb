require 'time'
require 'mixer_api/request'
require 'mixer_api/adapters'

module MixerApi
  class Client
    include MixerApi::Request
    include MixerApi::Adapters

    def initialize(options = {})
      @client_id = options[:client_id] || ""
      @secret_key = options[:secret_key] || ""
      @redirect_uri = options[:redirect_uri] || ""
      @scope = options[:scope] || []
      @access_token = options[:access_token] || nil

      @adapter = get_adapter(options[:adapter] || nil)

      @base_url = "https://mixer.com/api/v1"
    end

    attr_reader :base_url, :redirect_url, :scope
    attr_accessor :adapter

    public

    def adapter=(adapter)
      get_adapter(adapter)
    end

    # def link
    #   scope = ""
    #   @scope.each { |s| scope += s + '+' }
    #   "#{@base_url}/oauth/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{scope}"
    # end

    # def auth(code)
    #   path = "/oauth/token"
    #   url = @base_url + path
    #   post(url, {
    #     :client_id => @client_id,
    #     :client_secret => @secret_key,
    #     :grant_type => "authorization_code",
    #     :redirect_uri => @redirect_uri,
    #     :code => code
    #   })
    # end

    # -------------------------------------------------------------------
    # Debug/Test

    def raw_get(query)
      url = @base_url + query
      get(url)
    end

    # -------------------------------------------------------------------
    # User

    def user(user_id = nil)
      return your_user unless user_id

      url = @base_url + '/users/' + user_id.to_s
      get(url)
    end

    def your_user
      url = @base_url + '/users/current'
      get(url)
    end

    # -------------------------------------------------------------------
    # Channel

    def channel(channel_id = nil)
      return your_channel unless channel_id

      url = @base_url + '/channels/' + channel_id.to_s
      get(url)
    end

    def your_channel
      channel_id = your_user[:body][:channel][:id]
      channel_id ? channel(channel_id) : nil
    end

    # -------------------------------------------------------------------
    # Recordings

    def recordings(options={})
      query_params = build_query_params(options)
      query_params[:order] = 'id:ASC'

      url = @base_url + '/recordings'
      get(url, query_params)
    end

    # -------------------------------------------------------------------
    # Types

    def types(options={})
      query_params = build_query_params(options)

      url = @base_url + '/types'
      get(url, query_params)
    end

    # -------------------------------------------------------------------
    # Analytics

    ANALYTICS_NAMES = %w(streamSessions streamHosts viewers viewersMetrics
                         subscriptions followers sparkSpent emojiUsageRanks
                         emojiUsage gameRanks gameRanksGlobal subRevenue cpm)

    def analytics(analytics_name, options={})
      ANALYTICS_NAMES.include?(analytics_name) or raise "Unknown analytics name: #{analytics_name}"
      channel_id = options.delete(:channel_id) or raise 'Channel ID is required'

      options[:from] ||= default_from
      query_params = build_query_params(options)
      url = @base_url + '/channels/' + channel_id.to_s + '/analytics/tsdb/' + analytics_name
      get(url, query_params)
    end


    # -------------------------------------------------------------------

    private

    def build_query_params(options)
      query_params = {}

      where_clauses = []
      where_clauses << "channelId:eq:#{options[:channel_id]}" if options[:channel_id]
      where_clauses << "id:gt:#{options[:since_id]}" if options[:since_id]
      where_clauses << "id:in:#{options[:ids].join(';')}" if options[:ids]
      where_clauses << "id:eq:#{options[:id]}" if options[:id]

      query_params[:where] = where_clauses.join(',') unless where_clauses.empty?
      query_params[:page] = options[:page] if options[:page]
      query_params[:limit] = options[:limit] if options[:limit]
      query_params[:limit] = 1 if options[:count_only]

      query_params[:from] = options[:from].utc.iso8601 if options[:from]
      query_params[:to] = options[:to].utc.iso8601 if options[:to]

      query_params
    end

    def default_from
      # 14 days ago
      (Date.today - 14).to_time
    end
  end
end
