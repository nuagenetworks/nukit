Feature: Test the launching of the application
This test is used to make sure that we can launch the application

Background:
  Given the application is launched

  Scenario: Check if the NUNumericTextField accepts only number
    When I click on the numeric-field with the property cucapp-identifier set to numericTextField
      Then the numeric-field with the property cucapp-identifier set to numericTextField should be focused
    When I hit the keys 12
      Then the numeric-field with the property cucapp-identifier set to numericTextField should have the value 12
    When I hit the key delete
    When I hit the key delete
    When I hit the keys azugyuaerg
      Then the numeric-field with the property cucapp-identifier set to numericTextField should not have a value
    When I hit the keys 1a2e4
      Then the numeric-field with the property cucapp-identifier set to numericTextField should have the value 124

  Scenario: Check if the decimal NUNumericTextField accepts only number
    When I click on the numeric-field with the property cucapp-identifier set to decimalNumericTextField
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should be focused
    When I hit the keys 12
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should have the value 12
    When I hit the key delete
    When I hit the key delete
    When I hit the keys azugyuaerg
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should not have a value
    When I hit the keys 1a2e4
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should have the value 124
    When I hit the key delete
    When I hit the key delete
    When I hit the key delete
    When I hit the keys 12.32
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should have the value 12.32
    When I hit the keys 56.789
      Then the numeric-field with the property cucapp-identifier set to decimalNumericTextField should have the value 12.3256789