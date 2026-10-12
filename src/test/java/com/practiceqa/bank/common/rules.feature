@ignore
Feature: Load the bank's published rules (called once from karate-config.js)

  Scenario:
    Given url baseUrl
    And path '/api/bank/rules'
    When method get
    Then status 200
    * def rules = response
