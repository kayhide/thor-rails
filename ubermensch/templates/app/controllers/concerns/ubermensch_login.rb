module UbermenschLogin
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?, :current_user
  end

  def reset_session
    @current_user = nil
    super
  end

  def login user
    @current_user = user
    session[:user_id] = user.id
    session[:user_role] = user.role
  end

  def current_user_id
    session[:user_id].presence
  end

  def current_user
    @current_user ||= (current_user_id && User.find(current_user_id))
  end

  def authenticated? role = nil
    if role
      User.exists?(id: session[:user_id]) && session[:user_role] == role.to_s
    else
      User.exists?(id: session[:user_id])
    end
  end

  def authenticate_user!
    unless authenticated?
      redirect_to login_url
    end
  end

  def authenticate_admin!
    unless authenticated? :admin
      redirect_back_or :root, alert: t('messages.permission_denied')
    end
  end

  def redirect_back_or path, *args
    redirect_to(request.referer || path, *args)
  end
end
