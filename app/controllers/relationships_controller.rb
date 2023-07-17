class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_following, only: :create
  before_action :load_followed, only: :destroy

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    current_user.unfollow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def load_following
    @user = User.find_by id: params[:followed_id];
    return if @user

    flash[:danger] = t "user.not_found"
    redirect_back
  end

  def load_followed
    relationship = Relationship.find_by({id: params[:id]})
    @user = relationship.followed if relationship;

    return if @user

    flash[:danger] = t "user.not_found"
    redirect_back
  end
end
