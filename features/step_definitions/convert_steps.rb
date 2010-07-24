Given /^the following converts:$/ do |converts|
  Convert.create!(converts.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) convert$/ do |pos|
  visit converts_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following converts:$/ do |expected_converts_table|
  expected_converts_table.diff!(tableish('table tr', 'td,th'))
end
