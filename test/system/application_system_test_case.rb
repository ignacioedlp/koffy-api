require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use the default driver (rack_test) for system tests
  # If you need JavaScript support, uncomment the line below and install selenium-webdriver
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :rack_test
end

