class Admin::UsersController < ApplicationController
  before_filter :require_admin

  def show
    @user = User.find(current_user.id)
    @store = current_store
  end

  def edit
    
  end
end
