require 'base.rb'
class Response
  @response
  attr_accessor :response

  def initialize response
    if response.class == String
      @response = response
    else
      return "Response is not correct, I have a bug!"
    end
  end
end