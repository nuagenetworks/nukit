Given /^the application is launched$/ do
  launched = app.gui.command "launched"

  if !launched
    raise "The application was not launched"
  end
end

When /^I click on the control (.*)$/ do |cucappIdentifier|
  app.gui.wait_for                    "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.simulate_left_click         "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']", []
  sleep(0.1)
end

When /^I hit the keys (.*)$/ do |value|
  app.gui.simulate_keyboard_events    value, []
end

When /^I hit delete$/ do
  app.gui.simulate_keyboard_event    $CPDeleteCharacter, []
end

Then /^the control (.*) should have the value (.*)$/ do |cucappIdentifier, value|
  app.gui.wait_for                    "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.value_is_equal              "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']", value
end

Then /^the control (.*) should be first responder$/ do |cucappIdentifier|
  app.gui.wait_for                    "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.is_control_focused          "//NUNumericTextField[cucappIdentifier='#{cucappIdentifier}']"
end