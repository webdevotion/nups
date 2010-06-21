# == Schema Info
#
# Table name: accounts
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)
#  from                  :string(255)
#  host                  :string(255)
#  name                  :string(255)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  test "test recipients" do
    @account = accounts(:biff_account)
    @account.test_recipient_emails = "test@test.de,test2@test.de\n;test3@test.de,"
    
    assert_equal 3, @account.test_recipients.size
    assert_equal "test3@test.de", @account.test_recipients.last.email
    
    assert_equal 4, @account.test_recipients("test4@test.de").size
    assert_equal 5, @account.test_recipients(["test4@test.de", "test5@test.de"]).size
    
    assert_equal 3, @account.test_recipients("test3@test.de").size
  end
end