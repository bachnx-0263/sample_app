class SessionsController < ApplicationController
  attr_accessor :user

  before_action :load_user, only: :create

  def new; end

  def create
    if @user.authenticate params[:session][:password]
      # Log the user in and redirect to the user's show page.
      log_in user
      set_remember @user
      redirect_to @user
    else
      # Create an error message.
      flash.now[:danger] = t "login.error"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def load_user
    @user = User.find_by email: params.dig(:session, :email)&.downcase

    return if @user

    flash[:danger] = t "user.error"
    redirect_to login_path
  end

  def set_remember user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end
end
