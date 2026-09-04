Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ConversationEditor::Engine => "/api/v1/editor"
  mount ImageDownloader::Engine => "/api/v1"

  namespace :api do
    namespace :v1 do
      resources :moves,     param: :id
      resources :opponents, param: :id do
        resources :gifts, only: %i[index show create update destroy]
      end
      resources :items, param: :id

      # Legacy aliases for older fang-conversation-editor builds — prefer /api/v1/editor/*
      get  "opponent_options", to: "opponent_options#index"
      get  "assets", to: "assets#index"
      post "assets/upload_conversation_yml", to: "assets#upload_conversation_yml"
      post "scripts/convert", to: "scripts#convert"

      post "gacha", to: "gacha#pull"
    end
  end
end
