class Samantha
   @say
   attr_accessor :say
  def self.ask question
      question = question
      analysis = Analyse.new question
      return question,analysis
    end

    def self.talk ques
      question,analysis = Samantha.ask ques
      if analysis.known?
        @say = analysis.analysis
        if analysis.type

        end
      else
        @say = (Interact.new analysis.type,question).answer.response
      end
      return @say
    end

    def initialize ques
      @say = Samantha.talk ques
    end

    def extract_proper_noun(question)
      question.match(/[A-Z]{1}[a-z]{2,30}/)
    end
end
