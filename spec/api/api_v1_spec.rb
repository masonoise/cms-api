require 'spec_helper'

describe Acme::API do
  include Rack::Test::Methods

  def app
    Acme::API
  end
    
  context "v1" do
    context "cms" do
      it "text" do
        get "/api/v1/cms/text/"
        last_response.body.should == { :ping => "pong" }.to_json
      end
    end
  end

end

