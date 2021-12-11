require 'tac/version'

Then /^the output should contain the current app version$/ do
  expect(all_output).to include_output_string TAC::VERSION
end
