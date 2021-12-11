Feature: CLI
  In order to verify proper installation of TAC
  As a CLI
  I want to print the current version number

  Scenario: tac version
    When I run `tac version`
    Then the output should contain the current app version
