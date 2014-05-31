
Given(/^a GitHub user "(.*?)" who has set his address to "(.*?)"$/) do |arg1, arg2|
  create(:user, email: "#{arg1}@example.com", nickname: arg1, bitcoin_address: arg2)
end

Given(/^a GitHub user "([^"]*?)"$/) do |arg1|
  create(:user, email: "#{arg1}@example.com", nickname: arg1, bitcoin_address: nil)
end

Given(/^I type "(.*?)" in the recipient field$/) do |arg1|
  fill_in "add-recipients-input", with: arg1
end

Given(/^I select the recipient "(.*?)"$/) do |arg1|
  within "#recipient-suggestions" do
    click_on arg1
  end
end

Given(/^I fill the amount to "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  within "#recipients tr", text: /^#{Regexp.escape arg1}/ do
    fill_in "Amount", with: arg2
  end
end

Then(/^I should see these distribution lines:$/) do |table|
  table.hashes.each do |row|
    begin
      tr = find("#distribution-show-page tbody tr", text: row["recipient"])
    rescue
      puts "Rows: " + all("#distribution-show-page tbody tr").map(&:text).inspect
      raise
    end
    tr.find(".recipient").should have_content(row["recipient"])
    tr.find(".address").text.should eq(row["address"])
    tr.find(".amount").should have_content(row["amount"])
    tr.find(".percentage").should have_content(row["percentage"])
  end
end

Then(/^these amounts should have been sent from the account of the project:$/) do |table|
  BitcoinDaemon.instance.list_transactions(@project.address_label).map do |tx|
    if tx["category"] == "send"
      {
        "address" => tx["address"],
        "amount" => (-tx["amount"]).to_s,
      }
    end
  end.compact.should eq(table.hashes)
end

When(/^the tipper is started$/) do
  BitcoinTipper.work
end

Then(/^no coins should have been sent$/) do
  BitcoinDaemon.instance.list_transactions("*").should eq([])
end

When(/^I set my address to "(.*?)"$/) do |arg1|
  visit user_path(@current_user)
  fill_in "Peercoin address", with: arg1
  click_on "Update"
  page.should have_content "Your information was saved"
end

When(/^I click on the last distribution$/) do
  find("#distribution-list .distribution-link:first-child").click
end

Then(/^an email should have been sent to "(.*?)"$/) do |arg1|
  ActionMailer::Base.deliveries.map(&:to).should include([arg1])
end

When(/^I visit the link to register from the email$/) do
    pending # express the regexp above with the code you wish you had
end

Then(/^the user with email "(.*?)" should have "(.*?)" as password$/) do |arg1, arg2|
    pending # express the regexp above with the code you wish you had
end

Then(/^the user with email "(.*?)" should have "(.*?)" as peercoin address$/) do |arg1, arg2|
    pending # express the regexp above with the code you wish you had
end

