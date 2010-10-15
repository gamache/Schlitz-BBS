require 'pp'

class ThreadsController < ApplicationController
  before_filter :populate_page
  before_filter :load_thread, :only => [:show]
  
  def index
    @threads = BBSThread.paginate :page => @page, :order => 'last_post_at DESC'
    respond_to do |format|
      format.json {render :json => @threads}
      format.xml  {render :xml => @threads}
      format.html
    end
    @thread = BBSThread.new
  end
  
  def show 
    page = params[:page]
    @posts = Post.paginate_by_thread_id @thread.id,
      :page => @page,
      :order => 'created_at'
      
    @subtitle = @thread.title
    respond_to do |format|
      format.json {render :json => {:thread => @thread, :posts => @posts} }
      format.xml  {render :xml =>  {:thread => @thread, :posts => @posts} }
      format.html
    end
  end
  
  def create
    logger.debug pp params[:author, :title]
    thread = BBSThread.new(params[:thread])
    post = Post.new(params[:post])
  end
  
  private
  
  def populate_page 
    @page = params[:page] || 1
  end
  
  def load_thread
    @thread = BBSThread.find(params[:id])
  end
end
