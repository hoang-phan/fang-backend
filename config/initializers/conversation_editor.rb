# frozen_string_literal: true

ConversationEditor.configure do |c|
  c.profile_id = "fang"
  c.character_label = "Opponent"
  c.slot_kinds = %w[chat gift cinematic]
end

Rails.application.config.to_prepare do
  ConversationEditor.configuration.character_provider = Fang::Editor::CharacterProvider.new
end
