Feature: Checking a transfer before it is made
  POST /api/bank/transfer-check validates a transfer with the same rules as the
  Transfer form. Nothing is stored and no money moves.

  Background:
    * def check = read('classpath:com/practiceqa/bank/common/transfer-check.feature')
    * def savings = karate.jsonPath(rules, "$.accounts[?(@.id=='savings')]")[0]

  @smoke
  Scenario: A small transfer is allowed without approval
    * def result = call check { transfer: { from: 'savings', amount: 2500, mode: 'imps' } }
    * match result.responseStatus == 200
    * match result.response == { ok: true, needsApproval: false, amount: 2500 }

  Scenario Outline: Approval is needed from the threshold upwards: <case>
    * def amount = rules.approvalThreshold + <offset>
    * def result = call check { transfer: { from: 'current', amount: '#(amount)', mode: 'neft' } }
    * match result.responseStatus == 200
    * match result.response.needsApproval == <needsApproval>

    Examples:
      | case                 | offset | needsApproval |
      | just below threshold | -1     | false         |
      | exactly at threshold | 0      | true          |
      | above the threshold  | 1      | true          |

  Scenario: The daily limit is the most that can be sent in one day
    * def atLimit = call check { transfer: { from: 'current', amount: '#(rules.dailyLimit)', mode: 'neft' } }
    * match atLimit.responseStatus == 200

    * def overLimit = call check { transfer: { from: 'current', amount: '#(rules.dailyLimit + 1)', mode: 'neft' } }
    * match overLimit.responseStatus == 422
    * match overLimit.response == { ok: false, errors: { amount: '#regex Daily transfer limit is .+' } }

  Scenario: Earlier transfers today count towards the daily limit
    * def result = call check { transfer: { from: 'current', amount: 20000, mode: 'neft', usedToday: 40000 } }
    * match result.responseStatus == 422
    * match result.response.errors.amount contains 'Daily transfer limit'

  Scenario: A transfer cannot be more than the account balance
    * def result = call check { transfer: { from: 'savings', amount: 500, mode: 'imps', balance: 100 } }
    * match result.responseStatus == 422
    * match result.response.errors == { amount: 'Amount exceeds available balance' }

  Scenario: The balance defaults to the account's opening balance
    * def result = call check { transfer: { from: 'savings', amount: '#(savings.openingBalance + 1)', mode: 'imps' } }
    * match result.responseStatus == 422
    * match result.response.errors.amount == 'Amount exceeds available balance'

  Scenario: RTGS is refused below its minimum amount
    * def result = call check { transfer: { from: 'current', amount: 1000, mode: 'rtgs' } }
    * match result.responseStatus == 422
    * match result.response.errors == { mode: '#regex RTGS needs at least .+' }

  Scenario: Every missing field is reported at once
    * def result = call check { transfer: {} }
    * match result.responseStatus == 422
    * match result.response ==
      """
      {
        ok: false,
        errors: { from: 'Choose an account', amount: 'Enter an amount', mode: 'Choose a transfer mode' }
      }
      """

  Scenario Outline: A malformed request is rejected with 400: <case>
    * def result = call check { transfer: <body> }
    * match result.responseStatus == 400
    * match result.response.error contains '<field>'

    Examples:
      | case              | body                                              | field  |
      | unknown account   | { from: 'gold', amount: 100, mode: 'imps' }       | from   |
      | unknown mode      | { from: 'savings', amount: 100, mode: 'pigeon' }  | mode   |
      | negative amount   | { from: 'savings', amount: -5, mode: 'imps' }     | amount |
      | amount as text    | { from: 'savings', amount: 'lots', mode: 'imps' } | amount |
