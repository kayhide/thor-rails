Dir[Rails.root.join("lib/omniauth/**/*.rb")].each { |f| require f }

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ubermensch, ENV['UBERMENSCH_APP_KEY'], ENV['UBERMENSCH_APP_SECRET']
end
