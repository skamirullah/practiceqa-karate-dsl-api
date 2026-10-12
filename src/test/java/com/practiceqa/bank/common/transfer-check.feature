@ignore
Feature: Reusable call: check a transfer

  # Called with { transfer: { from, amount, mode, balance?, usedToday? } }.
  # Retries while the API answers 429 (rate limited), then hands the response back.
  Scenario:
    Given url baseUrl
    And path '/api/bank/transfer-check'
    And request transfer
    And retry until responseStatus != 429
    When method post
