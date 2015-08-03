class Interact
  @answer
  attr_accessor :answer
  @@greetings = ['hi','hey','hola','hello','helo','namaste']
  def initialize type,question
    if type.downcase == question.downcase
      if !(@@greetings.select{|i| i.downcase == question.strip.downcase }).empty?
        @answer = Response.new((@@greetings.select{|i| i.downcase == question.strip.downcase }).join(" "))
      elsif type.match(/Jasmine/i)
        if type.match(/Jasmine you are/i)
          adjective = question.downcase.gsub("jasmine you are","").strip
          if adjective.match(/ugly/i) || adjective.match(/horrible/i) || adjective.match(/bad/i)
            @answer = Response.new("No, You are #{adjective}")
          elsif adjective.match(/beautiful/i) || adjective.match(/gorgeous/i)
            @answer = Response.new("Thank you! I am flattered")
          elsif adjective.match(/sexy/i)
            @answer = Response.new("Oh really! I... wish I was real")
          end
        elsif type.match(/Jasmine fuck you/i)
          @answer = Response.new("Oh...! Yeah... Fuck you too!")
        end
      end
    else
      @answer = Response.new("No Answer found")
    end
  end

end