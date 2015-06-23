class ApplicationController < ActionController::API
  def load_samantha
    begin
      response = Samantha.new params[:ques]
      if (response.say.empty?)
        response = { say: {answer: "Could Not find the answer, will learn more , shit happens!"}}
      end
      render json: response.to_json
    rescue
      render json: { say: {answer:"error"} }
    end
  end
end