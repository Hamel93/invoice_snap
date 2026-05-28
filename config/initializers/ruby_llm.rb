RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]

  if ENV["OPENAI_API_BASE"].present?
    config.openai_api_base = ENV["OPENAI_API_BASE"]
  end
end
