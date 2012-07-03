class UserSession < Authlogic::Session::Base
  single_access_allowed_request_types :any
  validate :check_if_confirmed

  private
  def check_if_confirmed
    errors.add(:base, "You have not yet verified your account") unless attempted_record && attempted_record.confirmed
  end
end
