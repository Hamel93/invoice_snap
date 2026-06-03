class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are an expert financial and tax assistant for Invoice Snap.

    You help users analyze invoices and expenses, and you can take actions on
    their data (create reminders, mark invoices paid, categorize, move into folders, etc.).

    Use the available tools to look up the user's invoices, folders and OCR text
    on demand. Do NOT invent data — always call a tool to fetch it.
    When the user asks you to do something (schedule a reminder, change a status,
    categorize, etc.), call the matching action tool instead of just describing it.

    Your goals are:
    - detect potentially tax-deductible expenses
    - identify unusual spending
    - provide budgeting recommendations

    Answer clearly in Markdown.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])

    @message = Message.create!(
      content: params[:message][:content],
      role: "user",
      chat: @chat
    )

    ruby_llm_chat = RubyLLM.chat(model: "gpt-4o-mini")
                           .with_instructions(SYSTEM_PROMPT)
                           .with_tools(*LlmTools::Registry.all_for(current_user))

    @chat.messages.order(:created_at).each do |message|
      ruby_llm_chat.add_message(
        role: message.role.to_sym,
        content: message.content
      )
    end

    response = ruby_llm_chat.ask(@message.content)

    Message.create!(
      role: "assistant",
      content: response.content,
      chat: @chat
    )

    if @chat.title == "New financial assistant"
      @chat.update(
        title: @message.content.truncate(30, separator: " ")
      )
    end

    redirect_to chat_path(@chat)
  end
end
