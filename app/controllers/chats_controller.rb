class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats
  end

  def show
    @chat = current_user.chats.find(params[:id])
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

  def rename
    @chat = current_user.chats.find(params[:id])

    if @chat.update(title: params[:chat][:title])
      redirect_to chat_path(@chat),
                  notice: "Conversation renamed."
    else
      redirect_to chat_path(@chat),
                  alert: "Unable to rename conversation."
    end
  end
end
