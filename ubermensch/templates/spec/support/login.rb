Module.new do
  def login_user
    if block_given?
      let(:current_user) { yield }
    else
      let(:current_user) { FactoryGirl.create(:user) }
    end

    before do
      controller.login current_user
    end
  end

  def login_admin
    login_user do
      FactoryGirl.create(:user, :admin)
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :controller
  end
end

Module.new do
  def login_user
    if block_given?
      let(:current_user) { yield }
    else
      let(:current_user) { FactoryGirl.create(:user) }
    end

    before do
      OmniAuth.config.test_mode = true
      auth_hash = OmniAuth::AuthHash.new(
        provider: :identity,
        uid: current_user.id,
        info: OmniAuth::AuthHash::InfoHash.new(current_user.raw)
      )
      get '/auth/identity/callback', nil, { 'omniauth.auth' => auth_hash }
    end
  end

  def login_admin
    login_user do
      FactoryGirl.create(:user, :admin)
    end
  end

  RSpec.configure do |config|
    config.extend self, type: :request
  end
end
