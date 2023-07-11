class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :load_user, only: [:edit, :show, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.all, items: Settings.pagination.per_page_10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_mail_active
      flash[:info] = t "signup.mail_verify"
      redirect_to login_url
    else
      flash.now[:danger] = t "signup.fail"
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      # Handle a successful update.
      flash[:success] = t "flash.saved"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "flash.delete"
      redirect_to users_url
    else
      flash[:danger] = t "flash.delete_fail"
    end
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email,
                  :password,
                  :password_confirmation)
  end

  def load_user
    @user = User.find_by id: params[:id]

    return if @user

    flash[:danger] = t "user.error"
    redirect_to login_path
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "flash.require_login"
    redirect_to root_path
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = t "flash.user_invalid"
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t "flash.not_admin"
    redirect_to(root_url)
  end
end
