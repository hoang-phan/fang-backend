# frozen_string_literal: true

module Api
  module V1
    # Legacy alias — prefer POST /api/v1/editor/scripts/convert
    class ScriptsController < ApplicationController
      def convert
        # Preserve newlines — named-speaker scripts are line/paragraph oriented.
        text = params[:text].to_s.gsub("\r\n", "\n").strip

        if text.empty?
          return render json: { errors: [ "text is required" ] }, status: :unprocessable_entity
        end

        use_llm = ActiveModel::Type::Boolean.new.cast(params[:use_llm]) || false
        assets = ConversationEditor::AssetsScanner.new.call
        background_assets = assets.select { |asset| asset.include?("background") }
        conversations = ConversationEditor::ScriptToConversationService.new(
          background_assets:
        ).call(text, use_llm:)

        render plain: conversations.to_yaml, content_type: "text/yaml", status: :ok
      end
    end
  end
end
