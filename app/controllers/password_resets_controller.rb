class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "flash.reset_password"
      redirect_to root_url
    else
      flash.now[:danger] = t "flash.email_invalid"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("reset_password.empty")
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t "reset_password.success"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def load_user
    @user = User.find_by email: params[:email]

    return if @user

    flash[:danger] = t "user.error"
    redirect_to login_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "reset_password.expired"
    redirect_to new_password_reset_url
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger]= t "reset_password.user_invalid"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
