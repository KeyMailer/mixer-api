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

    # Debug/Test

    def raw_get(query)
      url = @base_url + query
      get(url)
    end

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

    # Recordings

    def recordings(options={})
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

      query_params[:order] = 'id:ASC'

      url = @base_url + '/recordings'
      get(url, query_params)
    end



    # # Teams
    #
    # def teams
    #   path = "/teams/"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    #
    # def team(team_id)
    #   path = "/teams/"
    #   url = @base_url + path + team_id;
    #
    #   get(url)
    # end
    #
    #

    # Channel
    #
    # def editors(channel)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/editors?oauth_token=#{@access_token}"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # # TODO: Add ability to set delay, which is only available for partered channels
    # def edit_channel(channel, status, game)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   data = {
    #     :channel =>{
    #       :game => game,
    #       :status => status
    #     }
    #   }
    #   put(url, data)
    # end
    #
    # def reset_key(channel)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/stream_key?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   delete(url)
    # end
    #
    # def follow_channel(username, channel)
    #   return false unless @access_token
    #
    #   path = "/users/#{username}/follows/channels/#{channel}?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   put(url)
    # end
    #
    # def unfollow_channel(username, channel)
    #   return false unless @access_token
    #
    #   path = "/users/#{username}/follows/channels/#{channel}?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   delete(url)
    # end
    #
    # def run_commercial(channel, length = 30)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/commercial?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   post(url, {
    #     :length => length
    #   })
    # end
    #
    # def channel_teams(channel)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/teams?oauth_token=#{@access_token}"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # # Streams
    #
    # def stream(stream_name)
    #   path = "/streams/#{stream_name}"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # def streams(options = {})
    #   query = build_query_string(options)
    #   path = "/streams"
    #   url =  @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def featured_streams(options = {})
    #   query = build_query_string(options)
    #   path = "/streams/featured"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def summarized_streams(options = {})
    #   query = build_query_string(options)
    #   path = "/streams/summary"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def followed_streams(options = {})
    #   return false unless @access_token
    #
    #   options[:oauth_token] = @access_token
    #   query = build_query_string(options)
    #   path = "/streams/followed"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    # alias :your_followed_streams :followed_streams
    #
    # #Games
    #
    # def top_games(options = {})
    #   query = build_query_string(options)
    #   path = "/games/top"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # #Search
    #
    # def search_channels(options = {})
    #   query = build_query_string(options)
    #   path = "/search/channels"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def search_streams(options = {})
    #   query = build_query_string(options)
    #   path = "/search/streams"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def search_games(options = {})
    #   query = build_query_string(options)
    #   path = "/search/games"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # # Videos
    #
    # def channel_videos(channel, options = {})
    #   query = build_query_string(options)
    #   path = "/channels/#{channel}/videos"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def video(video_id)
    #   path = "/videos/#{video_id}/"
    #   url = @base_url + path
    #
    #   get(url)
    # end
    #
    # def subscribed?(username, channel, options = {})
    #   options[:oauth_token] = @access_token
    #   query = build_query_string(options)
    #   path = "/users/#{username}/subscriptions/#{channel}"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def followed_videos(options ={})
    #   return false unless @access_token
    #
    #   options[:oauth_token] = @access_token
    #   query = build_query_string(options)
    #   path = "/videos/followed"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    # alias :your_followed_videos :followed_videos
    #
    # def top_videos(options = {})
    #   query = build_query_string(options)
    #   path = "/videos/top"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # # Blocks
    #
    # def blocks(username, options = {})
    #   options[:oauth_token] = @access_token
    #   query = build_query_string(options)
    #   path = "/users/#{username}/blocks"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def block_user(username, target)
    #   return false unless @access_token
    #
    #   path = "/users/#{username}/blocks/#{target}?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   put(url)
    # end
    #
    # def unblock_user(username, target)
    #   return false unless @access_token
    #
    #   path = "/users/#{username}/blocks/#{target}?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #   delete(url)
    # end
    #
    # # Chat
    #
    # def chat_links(channel)
    #   path = "/chat/"
    #   url = @base_url + path + channel;
    #
    #   get(url)
    # end
    #
    # def badges(channel)
    #   path = "/chat/#{channel}/badges"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # def emoticons()
    #   path = "/chat/emoticons"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # # Follows
    #
    # def following(channel, options = {})
    #   query = build_query_string(options)
    #   path = "/channels/#{channel}/follows"
    #   url = @base_url + path + query;
    #
    #   get(url)
    # end
    #
    # def followed(username, options = {})
    #   query = build_query_string(options)
    #   path = "/users/#{username}/follows/channels"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def follow_status(username, channel)
    #   path = "/users/#{username}/follows/channels/#{channel}/?oauth_token=#{@access_token}"
    #   url = @base_url + path;
    #
    #   get(url)
    # end
    #
    # # Ingests
    #
    # def ingests()
    #   path = "/ingests"
    #   url = @base_url + path
    #
    #   get(url)
    # end
    #
    # # Root
    #
    # def root()
    #   path = "/?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #
    #   get(url)
    # end
    #
    # # Subscriptions
    #
    # def subscribed(channel, options = {})
    #   return false unless @access_token
    #   options[:oauth_token] = @access_token
    #
    #   query = build_query_string(options)
    #   path = "/channels/#{channel}/subscriptions"
    #   url = @base_url + path + query
    #
    #   get(url)
    # end
    #
    # def subscribed_to_channel(username, channel)
    #   return false unless @access_token
    #
    #   path = "/channels/#{channel}/subscriptions/#{username}?oauth_token=#{@access_token}"
    #   url = @base_url + path
    #
    #   get(url)
    # end
  end
end
