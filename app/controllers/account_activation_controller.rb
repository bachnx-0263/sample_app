class AccountActivationController < ApplicationController
  before_action :load_user, only: :edit

  def edit
    if !@user.activated? && @user.authenticated?(:activation, params[:id])
      @user.activate
      log_in @user
      flash[:success] = t "flash.activated"
      redirect_to @user
    else
      flash[:danger] = t "flash.invalid_link"
      redirect_to root_url
    end
  end

  private

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "user.error"
    redirect_to login_path
  end
end
