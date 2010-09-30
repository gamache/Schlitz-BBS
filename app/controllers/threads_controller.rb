class ThreadsController < ApplicationController
  
  def index
    @threads = Thread.paginate :page => params[:page] || 1,
      :order => 'last_post_at DESC'
    
  end
end
