# frozen_string_literal: true

module Salesforce
  # Salesforce::OauthCode is class for Salesforce OAuth code.
  class OAuthCode < Salesforce::OAuth
    attr_reader :authorize, :refresh_token
    attr_writer :code

    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] redirect_uri
    # @param [String] api_version
    def initialize(**kwargs)
      @client_id ||= kwargs[:client_id] || Salesforce.client_id
      @client_secret ||= kwargs[:client_secret] || Salesforce.client_secret
      @redirect_uri = kwargs[:redirect_uri] || Salesforce.redirect_uri
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, 'Client ID is required' if blank? @client_id
      raise Salesforce::Error, 'Client secret is required' if blank? @client_secret
      raise Salesforce::Error, 'Redirect URI is required' if blank? @redirect_uri
      raise Salesforce::Error, 'API version is required' if blank? @api_version

      endpoint_authorize
    rescue Salesforce::Error => e
      raise e
    end

    def call
      response = Salesforce::Request.new(url: endpoint)
      response.post
      json = response.json
      @access_token = json&.dig('access_token')
      @refresh_token = json&.dig('refresh_token')
      @instance_url = json&.dig('instance_url')
      nil
    rescue Salesforce::Error => e
      raise e
    end

    private

    def endpoint_authorize
      @authorize = "#{host}authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
    rescue Salesforce::Error => e
      raise e
    end

    def endpoint
      raise Salesforce::Error, 'Code is required' if blank? @code

      "#{host}token?grant_type=authorization_code&client_id=#{@client_id}&client_secret=#{@client_secret}&redirect_uri=#{@redirect_uri}&code=#{@code}&format=json"
    end
  end
end
