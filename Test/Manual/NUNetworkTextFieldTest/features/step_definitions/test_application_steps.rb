Given /^the application is launched$/ do
  launched = app.gui.command "launched"

  if !launched
    raise "The application was not launched"
  end
end

When /^I click on the control (.*)$/ do |cucappIdentifier|
  app.gui.wait_for                    "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.simulate_left_click         "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']", []
  sleep(0.1)
end

When /^I hit the keys (.*)$/ do |value|
  app.gui.simulate_keyboard_events    value, []
end

When /^I hit select all$/ do
  app.gui.simulate_keyboard_event    "a", [$CPCommandKeyMask]
end

When /^I hit delete$/ do
  app.gui.simulate_keyboard_event    $CPDeleteCharacter, []
end

When /^I hit tab$/ do
  app.gui.simulate_keyboard_event    $CPTabCharacter, []
end

When /^I hit shift tab$/ do
  app.gui.simulate_keyboard_event    $CPTabCharacter, [$CPShiftKeyMask]
end

Then /^the control (.*) should have the value (.*)$/ do |cucappIdentifier, value|
  app.gui.wait_for                    "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.value_is_equal              "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']", value
end

Then /^the control (.*) should be first responder$/ do |cucappIdentifier|
  app.gui.wait_for                    "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.is_control_focused          "//NUNetworkTextField[cucappIdentifier='#{cucappIdentifier}']"
end