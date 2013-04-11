class Admin::StoresController < ApplicationController
  before_filter :require_platform_admin

  def index
    @pending_stores = Store.order('name ASC').where(approval_status: 'pending')
    @approved_stores = Store.order('name ASC').where(approval_status: 'approved')
  end

  def update
    @store = Store.find(params[:id])
    if @store.update_attributes(params[:store])
      redirect_to admin_stores_path,
        :notice  => "Successfully updated store."
    else
      render :action => 'edit', :notice  => "Update failed."
    end
  end

  def choose_approval_status
    store = Store.find_by_id(params[:id])
    store.approval_status = params[:status]
    store.active = true if store.approved?
    store.save

    Resque.enqueue(StoreDecisionMailer, store.id)

    redirect_to admin_stores_path,
      :notice => "#{store.name} has been #{store.approval_status}"
  end

  def toggle_active
    @store = Store.find(params[:id])
    if @store.toggle_active
      redirect_to admin_stores_path,
        :notice  => "#{@store.name} successfully set to '#{@store.active_to_s}'."
    else
      head 400
    end
  end
end
