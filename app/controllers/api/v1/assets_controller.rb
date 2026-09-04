# frozen_string_literal: true

module Api
  module V1
    # Legacy alias — prefer GET/POST /api/v1/editor/assets*
    class AssetsController < ApplicationController
      def index
        render json: ConversationEditor::AssetsScanner.new.call
      end

      def upload_conversation_yml
        result = ConversationEditor::ConversationYmlUploader.new.call(
          file: params[:file],
          filename: params[:filename]
        )

        if result.ok
          render json: { path: result.path }, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
