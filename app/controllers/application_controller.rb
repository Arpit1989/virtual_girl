class ApplicationController < ActionController::API
  def load_samantha
    begin
      response = Samantha.new params[:ques]
      render json: response.to_json
    rescue
      render json: { say: {answer:"error"} }
    end
  end
end