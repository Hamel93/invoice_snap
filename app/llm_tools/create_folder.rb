module LlmTools
  class CreateFolder < BaseTool
    description "Create a new folder for the current user."

    param :name, desc: "Name of the folder"

    def execute(name:)
      folder = user.folders.create(name: name)

      if folder.persisted?
        { success: true, folder_id: folder.id, name: folder.name }
      else
        { error: folder.errors.full_messages.to_sentence }
      end
    end
  end
end
