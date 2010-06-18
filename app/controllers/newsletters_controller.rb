class NewslettersController < ApplicationController
  before_filter :load_user, :load_account

  def index
    @accounts    = current_user.admin? ? Account.all : current_user.accounts
    @newsletters = @user.newsletters.with_account(@account).all( :order => 'id DESC', :limit => 20 )
  end  

  # GET /newsletters/1
  # GET /newsletters/1.xml
  def show
    @newsletter = @user.newsletters.with_account(@account).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @newsletter }
      format.js  { render @newsletter }
    end
  end

  # GET /newsletters/new
  # GET /newsletters/new.xml
  def new
    redner404 && return unless @account
    @newsletter = @account.newsletters.new
    @newsletter.subject ||= @account.subject

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @newsletter }
    end
  end

  # GET /newsletters/1/edit
  def edit
    @newsletter = @account.newsletters.find(params[:id])
    render :new
  end

  # POST /newsletters
  # POST /newsletters.xml
  def create
    @newsletter = @account.newsletters.new(params[:newsletter])
        
    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to( account_newsletters_path(@account) , :notice => 'Newsletter was successfully created.') }
        format.xml  { render :xml => @newsletter, :status => :created, :location => @newsletter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /newsletters/1
  # PUT /newsletters/1.xml
  def update
    @newsletter = @account.newsletters.find(params[:id])

    respond_to do |format|
      if @newsletter.update_attributes(params[:newsletter])
        format.html { 
          redirect_to( account_newsletter_path(*@newsletter.route)) and return if params[:preview]
          redirect_to( account_newsletters_path(@account), :notice => 'Newsletter was successfully updated.') 
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @newsletter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /newsletters/1
  # DELETE /newsletters/1.xml
  def destroy
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter.destroy

    respond_to do |format|
      format.html { redirect_to(newsletters_url) }
      format.xml  { head :ok }
    end
  end

  ########################################################
  def preview
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter_issue = NewsletterMailer.issue(@newsletter, @account.recipients.first)
    render :text => 'test', :layout => false
  end
  
  def start
    @newsletter = @account.newsletters.find(params[:id])
    #render_404 if !@newsletter.created? &&
    @newsletter.schedule!(params[:mode])
    @newsletter.async_deliver!( :test_email => current_user.email)
    redirect_to account_newsletters_path(@account)
  end
  
  def stop
    @newsletter = @account.newsletters.find(params[:id])
    #render_404 unless @newsletter.running?
    @newsletter.stop! if @newsletter.running?
    @newsletter.unschedule! if @newsletter.scheduled?
    redirect_to account_newsletters_path(@account)
  end
  
  ########################################################
    
  private
  def load_user
    @user = current_user
    @user = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
  end

  def load_account
    return if params[:account_id].blank?
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_403 unless @account
  end  

end
