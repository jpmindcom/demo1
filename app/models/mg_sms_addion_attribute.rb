class MgSmsAddionAttribute < ActiveRecord::Base
  belongs_to :mg_sms_configuration
  # validates_numericality_of :maximum_sms_Support
  # validates :maximum_sms_Support, :numericality => true
end
