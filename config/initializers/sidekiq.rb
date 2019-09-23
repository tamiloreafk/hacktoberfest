# frozen_string_literal: true

# Sidekiq configuration
# See: https://github.com/mperham/sidekiq

# Redis config shared between client and server
if (redis_url = ENV.fetch('HACKTOBERFEST_REDIS_URL', nil))
  REDIS_CONFIG = {
    url: redis_url,
    password: ENV.fetch('HACKTOBERFEST_REDIS_PASSWORD', nil)
    # namespace: #Consider using a namespace to separate sidekiq fro app cache
  }
end

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG if defined?(REDIS_CONFIG)

  # Periodic job setup
  # See: https://github.com/mperham/sidekiq/wiki/Ent-Periodic-Jobs
  config.periodic do |mgr|
    # first arg is chron tab syntax for "every day at 1 am"
    mgr.register('0 1 * * *', TransitionAllUsersJob, retry: 2, queue: "transition_all")
  end
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIG if defined?(REDIS_CONFIG)
end