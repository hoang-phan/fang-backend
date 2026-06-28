module Api
  module V1
    class ScriptsController < ApplicationController
      def convert
        text = params[:text].to_s.strip

        if text.blank?
          return render json: { errors: [ "text is required" ] }, status: :unprocessable_entity
        end

        blocks = ScriptToConversationService.new.call(text)
        conversation = { "chats" => blocks }

        render plain: [ conversation ].to_yaml, content_type: "text/yaml", status: :ok
      end
    end
  end
end
