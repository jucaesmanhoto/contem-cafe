Rails.application.routes.draw do
  mount_avo
  devise_for :users
  root to: "pages#home"
  get "quero-cafe", to: "pages#try_form", as: :try_form
  get "pesquisa-satisfacao", to: "pages#satisfaction_survey", as: :satisfaction_survey
  get "pesquisa-satisfacao/obrigado", to: "pages#satisfaction_thanks", as: :satisfaction_thanks
  get "sobre-o-cafe", to: "pages#about_coffee", as: :about_coffee
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Farm and Coffee pages accessible via QR codes on product labels
  resources :farms, only: [:show] do
    resources :coffees, only: [:show, :create]
  end
end
