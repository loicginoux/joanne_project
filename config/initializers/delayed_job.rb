Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.delay_jobs = !Rails.env.test? #to execute all jobs realtime.
Delayed::Worker.logger = Rails.logger