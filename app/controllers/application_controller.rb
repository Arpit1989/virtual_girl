class ApplicationController < ActionController::API
  def load_samantha
    begin
      response = Samantha.new params[:ques]
      if (response.say.empty?)
        response = { say: {answer: "Could Not find the answer, will learn more , shit happens!"}}
      end
      render json: response.to_json,:callback => params[:callback]
    rescue
      render json: { say: {answer:"error"} },:callback => params[:callback]
    end
  end
end