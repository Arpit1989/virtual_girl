class Base
  class String
    def is_question?
      !(/\?/.match(self).nil?)
    end
  end
end