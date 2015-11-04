Feature: Test the NUNetworkTextField control
Test the NUNetworkTextField control

Background:
    Given the application is launched

    Scenario: Fill a NUNetworkTextField IPV4 and check its value
      When I click on the control first-networkTextField
        Then the control first-networkTextField should be first responder
      When I hit the keys 192.168.0.4/32
        Then the control first-networkTextField should have the value 192.168.0.4/32

      When I click on the control second-networkTextField
        Then the control second-networkTextField should be first responder
      When I hit the keys 192.168.0.43
        Then the control second-networkTextField should have the value 192.168.0.43

    Scenario: Fill a NUNetworkTextField MAC and check its value
      When I click on the control third-networkTextField
        Then the control third-networkTextField should be first responder
      When I hit the keys aabbee111fc0
        Then the control third-networkTextField should have the value aa:bb:ee:11:1f:c0

    Scenario: Fill a NUNetworkTextField IPV6 and check its value
      When I click on the control first-networkTextField
      When I hit tab
      When I hit tab
      When I hit tab
        Then the control fourth-networkTextField should be first responder
      When I hit the keys 123456789012aeaa12ae4fc143aaFF1150
        Then the control fourth-networkTextField should have the value 1234:5678:9012:aeaa:12ae:4fc1:43aa:FF11/50

    Scenario: Fill a NUNetworkTextField IPV6 when clicking in the middle and check its value
      When I click on the control fourth-networkTextField
        Then the control fourth-networkTextField should be first responder
      When I hit the keys aaaa123e
        Then the control fourth-networkTextField should have the value :::::aaaa:123e:/

    Scenario: Fill a NUNetworkTextField IPV6 with wrong character and check its value
      When I click on the control first-networkTextField
      When I hit tab
      When I hit tab
      When I hit tab
        Then the control fourth-networkTextField should be first responder
      When I hit the keys zeaioeo:iazncza241412diz:jdaiozpa12312412/432FR:T.R124124
        Then the control fourth-networkTextField should have the value eae:aca2:4141:2d:daa1:2312:412:0/43

    Scenario: Fill a NUNetworkTextField MAC with wrong character and check its value
      When I click on the control third-networkTextField
      When I hit the keys zza10r1234abgf
      Then the control third-networkTextField should have the value a1:01:23:4a:bf:

    Scenario: Fill a NUNetworkTextField IPV4 with wrong character and check its value
      When I click on the control first-networkTextField
      When I hit the keys 1edz92.16dz8.0.k4/32
        Then the control first-networkTextField should have the value 192.168.0.4/32

      When I click on the control second-networkTextField
      When I hit the keys 5551680.3
        Then the control second-networkTextField should have the value 55.168.0.3

    Scenario: Fill a NUNetworkTextField and delete its content
      When I click on the control first-networkTextField
      When I hit the keys 192.168.0.4/32
      When I hit select all
      When I hit delete
        Then the control first-networkTextField should have the value ""

      When I click on the control second-networkTextField
      When I hit the keys 192.168.0.4
      When I double click on the control second-networkTextField
      When I hit delete
        Then the control second-networkTextField should have the value ""

      When I click on the control third-networkTextField
      When I hit the keys aabbee111fc0
      When I hit select all
      When I hit delete
        Then the control third-networkTextField should have the value ""

      When I hit tab
      When I hit the keys 123456789012aeaa12ae4fc143aaFF1150
      When I hit select all
      When I hit delete
        Then the control fourth-networkTextField should have the value ""

    Scenario: Fill a NUNetworkTextField IPV4 with tab
      When I click on the control first-networkTextField
      When I hit the keys 123
      When I hit tab
      When I hit the keys 21
      When I hit tab
      When I hit tab
        Then the control first-networkTextField should have the value 123.0.21.0/24

    Scenario: Fill a NUNetworkTextField IPV6 with tab
      When I click on the control first-networkTextField
      When I hit tab
      When I hit tab
      When I hit tab
      When I hit the keys 123
      When I hit tab
      When I hit the keys 21
      When I hit tab
      When I hit tab
      When I hit the keys aaab2
        Then the control fourth-networkTextField should have the value 123:21::aaab:2:::/

    Scenario: Fill a NUNetworkTextField MAC with tab
      When I click on the control third-networkTextField
      When I hit the keys 123
      When I hit tab
      When I hit the keys 21
      When I hit tab
      When I hit tab
        Then the control third-networkTextField should have the value 12:3:21:::

      When I hit select all
      When I hit delete
        Then the control third-networkTextField should have the value ""

      When I hit the keys 12
      When I hit tab
      When I hit the keys 21
      When I hit tab
      When I hit tab
        Then the control third-networkTextField should have the value 12::21:::

    Scenario: Test key view with tab and shift-tab
      When I click on the control first-networkTextField
        Then the control first-networkTextField should be first responder
      When I hit tab
        Then the control second-networkTextField should be first responder
      When I hit shift tab
        Then the control first-networkTextField should be first responder
      When I hit tab
      When I hit tab
        Then the control third-networkTextField should be first responder
      When I hit tab
        Then the control fourth-networkTextField should be first responder