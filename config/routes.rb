Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :moves,     param: :id
      resources :opponents, param: :id do
        resources :gifts, only: %i[index show create update destroy]
      end
      resources :items, param: :id
      get  "assets", to: "assets#index"
      post "assets/upload_conversation_yml", to: "assets#upload_conversation_yml"
    end
  end
end
