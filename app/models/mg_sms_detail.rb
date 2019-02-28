class MgSmsDetail < ActiveRecord::Base
	belongs_to :mg_school
	belongs_to :mg_sms_request
end
