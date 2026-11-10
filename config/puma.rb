threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', 5))
threads threads_count, threads_count
port Integer(ENV.fetch('PORT', 3000))
environment ENV.fetch('RAILS_ENV', 'development')
