Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.delay_jobs = !Rails.env.test? #to execute all jobs realtime.
Delayed::Worker.logger = Rails.logger

Delayed::Worker.backend = :active_record

# reload code in worker
# in dev mode
# http://stackoverflow.com/questions/4903375/delayed-job-how-to-reload-the-payload-classes-during-every-call-in-development
module Delayed::Backend::Base
  def payload_object_with_reload
    if Rails.env.development? and @payload_object_with_reload.nil?
      ActiveSupport::Dependencies.clear
    end
    @payload_object_with_reload ||= payload_object_without_reload
  end
  alias_method_chain :payload_object, :reload
end