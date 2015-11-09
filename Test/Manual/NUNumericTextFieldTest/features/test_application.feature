Feature: Test the NUNumericTextField control
This the NUNumericTextField control

Background:
  Given the application is launched

  Scenario: Check if the NUNumericTextField accepts only number
    When I click on the control numericTextField
      Then the control numericTextField should be first responder
    When I hit the keys 12
      Then the control numericTextField should have the value 12
    When I hit delete
    When I hit delete
    When I hit the keys azugyuaerg
      Then the control numericTextField should have the value ""
    When I hit the keys 1a2e4
      Then the control numericTextField should have the value 124

  Scenario: Check if the decimal NUNumericTextField accepts only number
    When I click on the control decimalNumericTextField
      Then the control decimalNumericTextField should be first responder
    When I hit the keys 12
      Then the control decimalNumericTextField should have the value 12
    When I hit delete
    When I hit delete
    When I hit the keys azugyuaerg
      Then the control decimalNumericTextField should have the value ""
    When I hit the keys 1a2e4
      Then the control decimalNumericTextField should have the value 124
    When I hit delete
    When I hit delete
    When I hit delete
    When I hit the keys 12.32
      Then the control decimalNumericTextField should have the value 12.32
    When I hit the keys 56.789
      Then the control decimalNumericTextField should have the value 12.3256789