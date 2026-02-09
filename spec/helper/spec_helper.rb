# frozen_string_literal: true

require_relative '../../lib/mastermind'

# For editing RSpec config for tests
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = %i[should
                      receive]
  end

  config.filter_run_when_matching :focus
end
