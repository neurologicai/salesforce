# frozen_string_literal: true

module Salesforce
  # Salesforce::OAuth is class for Salesforce OAuth.
  class OAuth
    attr_reader :access_token, :instance_url, :issued_at

    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] username
    # @param [String] password
    # @param [String] security_token
    # @param [String] api_version
    def initialize(**kwargs)
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @username = kwargs[:username] || Salesforce.username
      @password = kwargs[:password] || Salesforce.password
      @security_token = kwargs[:security_token] || Salesforce.security_token
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, 'Client ID is required' if @client_id.blank?
      raise Salesforce::Error, 'Client secret is required' if @client_secret.blank?
      raise Salesforce::Error, 'Username is required' if @username.blank?
      raise Salesforce::Error, 'Password is required' if @password.blank?
      raise Salesforce::Error, 'Security token is required' if @security_token.blank?
      raise Salesforce::Error, 'API version is required' if @api_version.blank?
    rescue Salesforce::Error => e
      raise e
    end

    def call
      response = Salesforce::Request.new(url: endpoint)
      response.post
      json = response.json
      @access_token = json&.dig('access_token')
      @instance_url = json&.dig('instance_url')
      @issued_at = json&.dig('issued_at')
      nil
    rescue Salesforce::Error => e
      raise e
    end

    private

    def endpoint
      "#{host}token?grant_type=password&client_id=#{@client_id}&client_secret=#{@client_secret}&username=#{@username}&password=#{@password}#{@security_token}"
    rescue Salesforce::Error => e
      raise e
    end

    def host
      'https://login.salesforce.com/services/oauth2/'
    end
  end
end
