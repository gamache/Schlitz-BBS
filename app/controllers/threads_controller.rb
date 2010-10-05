class ThreadsController < ApplicationController
  before_filter :load_thread, :only => [:show]
  
  def index
    @threads = BBSThread.paginate :page => (params[:page] || 1),
      :order => 'last_post_at DESC'
    respond_to do |format|
      format.json {render :json => @threads}
      format.xml  {render :xml => @threads}
      format.html
    end
  end
  
  def show 
    @posts = Post.paginate_by_thread_id @thread.id,
      :page => (params[:page] || 1), 
      :order => 'created_at'
    respond_to do |format|
      format.json {render :json => {:thread => @thread, :posts => @posts} }
      format.xml  {render :xml =>  {:thread => @thread, :posts => @posts} }
      format.html
    end
  end
  
  private
  
  def load_thread
    @thread = BBSThread.find(params[:id])
  end
end
