class SessionController < ApplicationController
  def index
    unless flash[:notice] || flash[:alert]
      flash.now[:notice] = t('messages.login_please')
    end
  end

  def create
    login User.find_or_create_from_auth_hash(auth_params)
    redirect_to root_url, notice: t('messages.successed_to_login')
  rescue
    redirect_to login_url, alert: t('messages.failed_to_login')
  end

  def destroy
    reset_session
    redirect_to root_url, notice: t('messages.successed_to_logout')
  end

  private

  def auth_params
    request.env['omniauth.auth']
  end
end
