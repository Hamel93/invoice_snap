module LlmTools
  class BaseTool < RubyLLM::Tool
    def initialize(user)
      super()
      @user = user
    end

    private

    attr_reader :user
  end
end
