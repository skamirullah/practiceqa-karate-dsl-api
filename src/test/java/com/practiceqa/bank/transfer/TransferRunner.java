package com.practiceqa.bank.transfer;

import com.intuit.karate.junit5.Karate;

/** Runs only the transfer features. Handy from an IDE while working on them. */
class TransferRunner {

  @Karate.Test
  Karate transferChecks() {
    return Karate.run("transfer-check").relativeTo(getClass());
  }
}
