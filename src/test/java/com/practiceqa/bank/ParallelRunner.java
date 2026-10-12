package com.practiceqa.bank;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

/**
 * Runs every feature in parallel and fails the build if any scenario fails.
 * Used by `mvn test`; filter with -Dkarate.options="--tags @smoke".
 */
class ParallelRunner {

  @Test
  void runAllFeatures() {
    Results results = Runner.path("classpath:com/practiceqa/bank")
        .tags("~@ignore")
        .outputCucumberJson(true)
        .parallel(3);
    assertEquals(0, results.getFailCount(), results.getErrorMessages());
  }
}
