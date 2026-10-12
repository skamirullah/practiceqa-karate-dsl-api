Feature: TrustBank rules API
  The limits the Transfer form enforces are published so clients can show them.

  Background:
    Given url baseUrl
    And path '/api/bank/rules'

  @smoke
  Scenario: The rules are published as JSON
    When method get
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response ==
      """
      {
        currency: 'INR',
        dailyLimit: '#number',
        rtgsMinimum: '#number',
        approvalThreshold: '#number',
        sessionSeconds: '#number',
        modes: '#[3] #string',
        accounts: '#[] #object'
      }
      """

  Scenario: Every account has a label, a masked number and an opening balance
    When method get
    Then status 200
    And match each response.accounts ==
      """
      {
        id: '#regex (savings|current)',
        label: '#string',
        number: '#regex XXXX XXXX \\d{4}',
        openingBalance: '#? _ > 0'
      }
      """

  Scenario: The limits make sense together
    When method get
    Then status 200
    And match response.modes contains only ['imps', 'neft', 'rtgs']
    And assert response.approvalThreshold < response.dailyLimit
    And assert response.rtgsMinimum > response.dailyLimit
