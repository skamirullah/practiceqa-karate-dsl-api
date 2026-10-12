package com.practiceqa.bank.rules;

import com.intuit.karate.junit5.Karate;

/** Runs only the rules feature. Handy from an IDE while working on it. */
class RulesRunner {

  @Karate.Test
  Karate rules() {
    return Karate.run("rules").relativeTo(getClass());
  }
}
