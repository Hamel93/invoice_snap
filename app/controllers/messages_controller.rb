class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are an expert financial and tax assistant.

    You help users analyze invoices and expenses.

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

    response = ruby_llm_chat
               .with_instructions(instructions)
               .ask(@message.content)

    Message.create!(
      role: "assistant",
      content: response.content,
      chat: @chat
    )

    redirect_to chat_path(@chat)
  end

  private

  def invoices_context
    current_user.invoices.map do |invoice|
      "
      Company: #{invoice.company_name}
      Amount: #{invoice.amount}
      Category: #{invoice.category}
      Due date: #{invoice.due_date}
      Status: #{invoice.status}
      "
    end.join("\n")
  end

  def instructions
    [
      SYSTEM_PROMPT,
      invoices_context
    ].join("\n\n")
  end
  endclass MessagesController < ApplicationController
end
