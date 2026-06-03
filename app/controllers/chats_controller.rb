class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @chats = current_user.chats.order(updated_at: :desc)

    @message = Message.new
  end

  def create
    @chat = current_user.chats.create(title: "New financial assistant")

    redirect_to chat_path(@chat)
  end

  def destroy
    @chat = current_user.chats.find(params[:id])

    @chat.destroy

    redirect_to chats_path, notice: "Conversation deleted."
  end
end
