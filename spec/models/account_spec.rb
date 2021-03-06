require 'spec_helper'

describe Account do
  let(:account) { build(:account) }

  describe "#validation" do
    context "#create" do
      context "permalink" do
        it "generates random string for code" do
          Account.create.permalink.should_not nil
        end

        it "does not mass assign code" do
          expect do
            Account.create(:permalink => 'custom')
          end.to raise_error
        end

        it "does not overwrite manual set permalink" do
          build(:account).tap do |account|
            account.permalink = 'custom'
            account.save!
            account.permalink.should == 'custom'
          end
        end

        it "generates uniqe one" do
          build(:account).tap do |account|
            account.permalink = create(:account).permalink
            account.save!
          end
        end
      end
    end
  end

  describe "#test_recipient_emails_array" do
    {
      :by_comma     => "test@test.de,test2@test.de,test3@test.de",
      :by_spec_char => "test@test.de;test2@test.de|test3@test.de",
      :uniq         => "test@test.de,test2@test.de\r,test3@test.de,test3@test.de",
      :remove_empty => "test@test.de,,test2@test.de,test3@test.de,",
      :and_strip    => "test@test.de ;test2@test.de\n| test3@test.de   "
    }.each do |name, value|
      it "splits recipients #{name}" do
        account.test_recipient_emails = value
        account.test_recipient_emails_array.should =~ %w(test@test.de test2@test.de test3@test.de)
      end
    end

    it "includes extra test_emails" do
      account.test_recipient_emails_array("test3@test.de").should =~ %w(test@test.de test2@test.de test3@test.de)
    end

    it "uniques extra test_emails" do
      account.test_recipient_emails_array("test2@test.de").should =~ %w(test@test.de test2@test.de)
    end

  end

  describe "#process_bounces" do
    it "doesn't fail" do
      account.should_receive(:mail_config).and_return(nil)
      account.process_bounces.should be_nil
    end
  end

  describe "#mail_config" do
    it "fals back to global when empty" do
      account.mail_config.should == $mail_config
    end

    it "fals back to global when not parsable" do
      account.mail_config_raw = "["
      account.mail_config.should == $mail_config
    end

    it "fals back to global when not parsable" do
      account.mail_config_raw = "method: smtp"
      account.mail_config.should == {"method"=>"smtp"}
    end
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  from                  :string(255)
#  user_id               :integer(4)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime
#  color                 :string(255)     default("#FFF")
#  has_html              :boolean(1)      default(TRUE)
#  has_text              :boolean(1)      default(TRUE)
#  has_attachments       :boolean(1)
#  has_scheduling        :boolean(1)
#  mail_config_raw       :text
#  permalink             :string(255)
#

#  updated_at            :datetime
