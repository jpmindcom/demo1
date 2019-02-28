class MgSmsConfigeration < ActiveRecord::Base
	has_many :mg_sms_addion_attribute
	has_many :mg_sms_priorities
end
