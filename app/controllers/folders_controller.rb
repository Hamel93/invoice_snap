class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: %i[show edit update destroy]

  def index
    @folders = current_user.folders.distinct
  end

  def show
    @invoices = @folder.invoices
  end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folder_params)

    if @folder.save

      FolderInvoice.create(
        user: current_user,
        folder: @folder
      )

      redirect_to folder_path(@folder), notice: "Folder created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @folder.update(folder_params)
      redirect_to folder_path(@folder), notice: "Folder updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @folder.destroy
    redirect_to folders_path, notice: "Folder deleted successfully."
  end

  private

  def set_folder
    @folder = current_user.folders.distinct.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:name)
  end
end
