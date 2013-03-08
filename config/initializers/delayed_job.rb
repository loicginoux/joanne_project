Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.delay_jobs = !Rails.env.test?
file_handle = File.open("log/#{Rails.env}_delayed_jobs.log", (File::WRONLY | File::APPEND | File::CREAT))
# Be paranoid about syncing, part #1
file_handle.sync = true
# Be paranoid about syncing, part #2
# Rails.logger.auto_flushing = true
# Hack the existing Rails.logger object to use our new file handle
# Rails.logger.instance_variable_set :@log, file_handle
# Calls to Rails.logger go to the same object as Delayed::Worker.logger
Delayed::Worker.logger = Rails.logger