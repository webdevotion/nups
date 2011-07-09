class NewslettersController < ApplicationNupsController
  before_filter :load_account

  respond_to :html

  def index
    @user        = User.find(params[:user_id]) if params[:user_id] && current_user.admin?
    @user      ||= (@account) ? @account.user : current_user
    @newsletters = @user.newsletters.with_account(@account).all( :order => 'updated_at DESC', :limit => 20 )
    @accounts    = current_user.admin? ? Account.all : @user.accounts

    if request.xhr?
      render @newsletters
    end
  end

  def show
    @newsletter = @account.newsletters.find(params[:id])
  end

  def new
    redner404 && return unless @account
    @newsletter = @account.newsletters.new
    @newsletter.subject ||= @account.subject

    respond_with @newsletter
  end

  def edit
    @newsletter = @account.newsletters.find(params[:id])
    render :new
  end

  def create
    @newsletter = @account.newsletters.new(params[:newsletter])

    respond_to do |format|
      if @newsletter.save
        format.html {
          redirect_to( account_newsletter_path(*@newsletter.route)) and return if params[:preview]
          redirect_to( account_newsletters_path(@account), :notice => 'Newsletter was successfully created.')
        }
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

    recipient = @newsletter.recipients.first || Recipient.new(:email => current_user.email)
    @newsletter_issue = NewsletterMailer.issue(@newsletter, recipient)
    
    part = @newsletter_issue.parts.last
    part = part.parts.last if part.multipart?
    render :text => part.body.decoded, :layout => false
  end

  def start
    @newsletter = @account.newsletters.find(params[:id])

    if params[:mode] == 'live'
      @newsletter.send_live!
    else
      @newsletter.send_test!
    end

    if request.xhr?
      render @newsletter
    else
      redirect_to account_newsletters_path(@account)
    end
  end

  def stop
    @newsletter = @account.newsletters.find(params[:id])
    @newsletter.stop!

    if request.xhr?
      render @newsletter
    else
      redirect_to account_newsletters_path(@account)
    end
  end

  ########################################################

  private
  def load_account
    return if params[:account_id].blank?
    klass = current_user.admin? ? Account : current_user.accounts
    @account = klass.find_by_id(params[:account_id])
    render_403 unless @account
  end

end
