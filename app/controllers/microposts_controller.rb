class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def index
    redirect_to root_path page: params[:page]
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    check_for_create
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "micropost.delete"
    else
      flash[:danger] = t "micropost.delete_fail"
    end

    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost

    flash[:error] = t "micropost.notfound"
    redirect_to root_url
  end

  def check_for_create
    if @micropost.save
      flash[:success] = t "flash.post_created"
      redirect_to root_url
    else
      @pagy, @feed_items = pagy(current_user.feed,
                                items: Settings.pagination.per_page_10)
      render "static_pages/home"
    end
  end
end
