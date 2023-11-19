# frozen_string_literal: true

require "spec_helper"

RSpec.describe Salesforce::V2::Request do
  subject(:request) { described_class.call(url: url, options: options) }

  let(:options) { {} }
  let(:query) do
    URI.encode_www_form(
      {
        grant_type: "password",
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: "#{PASSWORD}#{SECURITY_TOKEN}"
      }
    )
  end
  let(:url) { "https://login.salesforce.com/services/oauth2/token?#{query}" }

  describe "#call" do
    context "when failure" do
      context "when invalid url" do
        let(:url) { nil }

        it { expect(request.data[:exception].message).to eq "Salesforce url is not valid" }
      end

      context "when invalid token" do
        let(:options) { { method: :post } }

        it { expect(request.data[:exception].message).to eq "Salesforce token is not valid" }
      end

      context "when indefinied method" do
        let(:options) { { token: "token" } }

        it { expect(request.data[:exception].message).to eq "Salesforce method is not valid" }
      end
    end
  end
end
