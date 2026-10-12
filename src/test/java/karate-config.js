function fn() {
  // Pick the environment with -Dkarate.env=local (default: prod).
  var env = karate.env || 'prod';
  var config = {
    env: env,
    baseUrl: 'https://www.practiceqaautomation.com',
  };
  if (env === 'local') {
    config.baseUrl = 'http://localhost:3000';
  }

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 10000);

  // The API allows 30 transfer checks a minute. A 429 is retried after a pause
  // instead of failing the run.
  karate.configure('retry', { count: 7, interval: 10000 });

  // Rules are published by the API itself and loaded once for the whole run,
  // so expected limits are never typed into a feature file.
  config.rules = karate.callSingle('classpath:com/practiceqa/bank/common/rules.feature', config).rules;
  return config;
}
