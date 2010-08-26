class NewsletterMailer < ActionMailer::Base
  
  def issue(newsletter, recipient)
    default_url_options[:host] = newsletter.host
    
    template_html = newsletter.template_html.blank? ? "<%= content %>" : newsletter.template_html
    template_text = newsletter.template_text.blank? ? "<%= content %>" : newsletter.template_text
    
    subject = newsletter.subject
    subject = "TEST: #{subject}" if newsletter.test?
    
    mail :to => recipient.email, :subject => subject, :from => newsletter.from do |format|
      data = { :content => newsletter.content, :newsletter => newsletter, :recipient => recipient }
      format.html { render :inline => template_html, :locals => data } if newsletter.has_html?
      format.text { render :inline => template_text, :locals => data } if newsletter.has_text?
    end
    
    newsletter.attachments.each do |attachment|
       attachments[attachment.name] = File.read(attachment.path) if File.exists?(attachment.path)
    end
  end
end
