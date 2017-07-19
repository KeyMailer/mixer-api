module MixerApi
  module Request

    def get(url, query_params={})
      url += build_query_string(query_params) unless query_params.empty?
      @adapter.get(url, :headers => {
        Authorization: 'Bearer ' + @access_token
      })
    end

    def post(url, data)
      @adapter.post(url, :body => data, :headers => {
        Authorization: 'Bearer ' + @access_token
      })
    end

    def put(url, data={})
      @adapter.put(url, :body => data, :headers => {
        # 'Accept' => 'application/json',
        # 'Content-Type' => 'application/json',
        # 'Api-Version' => '2.2',
        # 'Client-ID' => @client_id
      })
    end

    def delete(url)
      @adapter.delete(url, :headers => {
        Authorization: 'Bearer ' + @access_token
      })
    end

    private

    def build_query_string(options)
      query = "?"
      options.each do |key, value|
        query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
      end
      query[0...-1]
    end

  end
end
