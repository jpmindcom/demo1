 #version1.1(for taking the phone number as a object 31/05/18 by mamatha) 
  #version1.2(for running the schedular at las day of month for updating the month wise table 31/05/18 by Bindhu) 

require 'rubygems'
require 'rufus/scheduler'
require "erb"
include ERB::Util

# ============================ scheduler starts ================================== #

  scheduler = Rufus::Scheduler.new

  # Below scheduler is to send inqueued sms requests
  scheduler.cron '/1 * * * *' do

    #scheduler.cron is for do something every day, every five minutes after midnight

    # Scheduler is running
    puts "RUNNING SCHEDULER Test"

    # to get sms_requests which are In Queue
    sms_requests = MgSmsRequest.where(:is_deleted => 0, :status=>"Pending")
    puts sms_requests
    sms_requests.update_all(:status => "In Queue")

    request_arr = []
    request_failed_arr = []
    response_status = false
    # sms_requests are looping to send messages starts
    sms_requests.each do |request|

      static_msg = false

      sms_config = MgSmsConfigeration.where(:is_deleted=>0, :mg_school_id=>request.mg_school_id)
      priority_objs = MgSmsPriority.where(:is_deleted=>0, :mg_school_id=>request.mg_school_id)

      # send to next request if school sms_configurations & sms_priorities are empty
      next if sms_config.empty? && priority_objs.empty?

      # to get school_name
      school_name = MgSchool.where(:id=>request.mg_school_id).pluck(:school_name)

      # keeping status in Processing before sending message
      request.update(:status => "Processing")

      # checking for child, user, date and class & section is present or not
      msg_is_dynamic = request.message.include?("$Child_name") || request.message.include?("$User_name") || request.message.include?("$Current_date") || request.message.include?("$Class_section")

      if !msg_is_dynamic
        static_msg = true
      end

      # for sending selected sms_type 
      if "selected".casecmp(request.sms_type) == 0
        sms_obj_arr = []
        phone_no_array = []
        update_sql = ''
        failed_count = 0
        # looping every request mg_sms_details starts
        request.mg_sms_details.each do |sms_obj|
          mobile_number = sms_obj.mobile_number
          text_msg = sms_obj.message
          school_id = sms_obj.mg_school_id

          len = get_msg_count(text_msg)

          current_date = Date.today
          response_msg = ''

          if mobile_number.present?
            message = text_msg.to_s

            # to convert message into encode format
            # message = ERB::Util.url_encode(message)
            # message = URI.encode(message)

            phone_no_array << mobile_number
            sms_obj_arr << sms_obj.id

            # if child, user, date and class & section is present
            # if static_msg
            #   if sms_obj == request.mg_sms_details.last

            #     # to get response and url
            #     response = get_sms_response(school_id, phone_no_array, message)

            #     if sms_obj_arr.present?

            #       if "failed".casecmp(response[0]) == 0

            #         update_sql = "update mg_sms_details set response = '#{response[0]}', status = 'Failed.. we will try after some time !!' where id in (#{sms_obj_arr.join(",")})"
            #         response_status = true
            #       else
            #         update_sql = "update mg_sms_details set response = '#{response[0]}', status = 'Sent' where id in (#{sms_obj_arr.join(",")})"
            #       end

            #       # to update mg_sms_details with response
            #       ActiveRecord::Base.connection.execute(update_sql)

            #     end
            #   end

            # else

              number = []
              number << mobile_number

              # to get response and url
              response = get_sms_response(school_id, number, message)

              if "failed".casecmp(response[0]) == 0

                # to update mg_sms_details with response
                sms_obj.update_attributes(:response => response[0],:status => "Failed..We will try after some time!!")

              else

                # to update mg_sms_details with response
                sms_obj.update_attributes(:response => response[0],:status => 'Sent')

              end
              failed_count += 1 if "failed".casecmp(response[0]) == 0
              # response_status = true if "failed".casecmp(response[0]) == 0
            # end
          end
        end
        # looping every request mg_sms_details ends

        # to update mg_sms_requests
        # if response_status
        #   request.update(:status => "Pending")
        # else
        #   request.update(:status => "Sent")
        # end
        if failed_count == request.mg_sms_details.count
          request.update(:status => "Failed")
        elsif failed_count > 0
          request.update(:status => "Partially Sent")
        else
          request.update(:status => "Sent")
        end

      # for sending bulk sms_type 
      elsif "bulk".casecmp(request.sms_type) == 0
        update_sql = ''
        sms_message = request.message
        user_type = request.receiver_type
        school_id = request.mg_school_id
        from_user_id = request.from_user_id
        school = MgSchool.find_by(:id=>school_id)
        
        # to parent or guardian data
        if "Parent".casecmp(user_type.to_s) == 0 || "guardian".casecmp(user_type.to_s) == 0

          students = MgStudent.where(:is_deleted=>0, :mg_school_id=>school_id, :mg_batch_id=>request.receiver_id, :is_archive => 0).pluck(:id)
          selected_users = MgGuardian.where(:is_deleted=>0,:mg_school_id=>school_id, :mg_student_id => students).pluck(:mg_user_id)
          batch = MgBatch.find_by(:mg_school_id=>school.id, :id => request.receiver_id)
          course  = MgCourse.find_by(:mg_school_id => school.id, :id=> batch.mg_course_id).course_name
          class_sec = "#{course}" "-" "#{batch.name}"
          sms_message = sms_message.gsub('$Class_section', class_sec)

        # to student data
        elsif "Student".casecmp(user_type.to_s) == 0

          selected_users = MgStudent.where(:is_deleted=>0, :mg_school_id=>school_id, :mg_batch_id=>request.receiver_id, :is_archive => 0).pluck(:mg_user_id)

        # to employee or teacher data
        elsif "Employee".casecmp(user_type.to_s) == 0 
          emp_catagory = MgEmployeeCategory.find_by(:is_deleted=>0, :category_name=>"Non Teaching Staff")
          selected_users = emp_catagory.mg_employees.where(:mg_employee_category_id=>emp_catagory.id, :mg_employee_department_id=>request.receiver_id).pluck(:mg_user_id)
          # selected_users = MgEmployee.where(:is_deleted=>0, :mg_school_id=>school_id, :mg_employee_department_id=>request.receiver_id).pluck(:mg_user_id)
        elsif "Teacher".casecmp(user_type.to_s) == 0
          emp_catagory = MgEmployeeCategory.find_by(:is_deleted=>0, :category_name=>"Teaching Staff")
          selected_users = emp_catagory.mg_employees.where(:mg_employee_category_id=>emp_catagory.id,:mg_employee_department_id=>request.receiver_id).pluck(:mg_user_id)
          # selected_users = MgEmployee.where(:is_deleted=>0, :mg_school_id=>school_id, :mg_employee_department_id=>request.receiver_id).pluck(:mg_user_id)
        end
        
        if selected_users.empty?
          request.update(:status=>"No Recipients")
          next
        end

        is_msg_dynamic = false
        has_child_name = false
        current_date = Time.now.strftime('%d/%m/%y')

        # to check for child, user name
        is_msg_dynamic = true if sms_message.include?('$Child_name') || sms_message.include?('$User_name')

        # to check for child name
        has_child_name = true if sms_message.include?('$Child_name') 
          
        sms_message = sms_message.gsub('$Current_date', current_date)
        sms_message = sms_message.gsub('$School_name', school.school_name)


        recepients_sms_details  = []
        phone_no_array = []
        response_for_all = ''
        failed_count = 0

        failed_sms_details = []
        response_status_arr = []
        if request.mg_sms_details.present?
          request.mg_sms_details.where.not(:status=>'Sent').each do |curr_obj|
            # binding.pry
            next if "InValid Number".casecmp(curr_obj.mobile_number) == 0
            number = [curr_obj.mobile_number]
            response = get_sms_response(school_id, number, curr_obj.message)
            if "failed".casecmp(response[0]) != 0 
              curr_obj.update(:status=>'Sent',:response=>response[0])
            else
              response_status_arr << false
            end 
          end
        else
          # to get SQL query based on user_type
          raw_sql = get_sql(user_type, is_msg_dynamic, school_id, selected_users)

          # to encode message
          # sms_message = ERB::Util.url_encode(sms_message)
          
          
          # to get data based on raw_sql
          recepients = ActiveRecord::Base.connection.execute(raw_sql)

          # looping for recepients data starts
          recepients.to_a.each do |curr_recepient|
            #   # sms_details_present = true 
            #   # next if sms_details_present
            # else
              message = ''
              response = ''

              # to get sms details obj
              sms_detail = get_sms_detail_obj(user_type, curr_recepient, from_user_id, school_id,sms_message, request, has_child_name)
              phone_no_array << sms_detail.mobile_number
              message << sms_detail.message

              if static_msg
                if curr_recepient == recepients.to_a.last
                  # to get response and url
                  response_for_all = get_sms_response(school_id, phone_no_array, message)
                end
              else
                phone_no = [sms_detail.mobile_number]
                # to get response and url
                response = get_sms_response(school_id, phone_no, message)
                if "failed".casecmp(response[0]) == 0 
                  response_status_arr << false
                end 
              end

              # if response is failed
              if response[0].present?
                sms_detail.status = "Failed..We will try after some time!!" if "failed".casecmp(response[0]) == 0
                failed_count += 1 if "failed".casecmp(response[0]) == 0
              end
              sms_detail.response = response[0] if response.present?
              recepients_sms_details << sms_detail
            # end
          end
        end

        # if the message is static 
        if response_for_all.present?
          recepients_sms_details.each do |curr_obj|
            curr_obj.response = response_for_all[0]
            if "failed".casecmp(response_for_all[0]) == 0
              curr_obj.status = "Failed..We will try after some time!!" 
            else
              curr_obj.status = "Sent"
            end
          end
        end

        # to import data into MgSmsDetail
        if recepients_sms_details.present?
          columns_without_id = MgSmsDetail.column_names.reject { |column| column == 'id' }
          save_sms_detail_saved = MgSmsDetail.import(columns_without_id, recepients_sms_details)
        end

        if response_for_all.present?
          response_for_all_status = true if "failed".casecmp(response_for_all[0]) == 0
        end
        status_value = ''
        if response_for_all_status 
          #request_failed_arr << request.id
          status_value = 'Failed'
        elsif response_status_arr.length == recepients.to_a.length
          status_value = 'Failed'
        elsif response_status_arr.length > 0
          status_value = 'Partially Sent'
        else
          status_value = 'Sent'
          #request_arr << request.id
        end

        update_sql = "update mg_sms_requests set status = '#{status_value}' where id = #{request.id}"
        ActiveRecord::Base.connection.execute(update_sql) 

      end

    end
    # sms_requests are looping to send messages ends

    # status_value = ''
    # request_ids = '' 
    # if request_arr.present?
    #   status_value = 'Sent'
    #   request_ids = request_arr 
    # elsif request_failed_arr.present?
    #   status_value = 'In Queue'
    #   request_ids = request_failed_arr 
    # end

    # # to update mg_sms_requests
    # if request_ids.present?
    #   update_sql = "update mg_sms_requests set status = '#{status_value}' where id in (#{request_ids.join(",")})"
    #   ActiveRecord::Base.connection.execute(update_sql) 
    # end
    
    puts "SCHEDULER COMPLETED"

  end

  def get_sms_response(school_id, phone_no_array, msg)

    # to read URI
    require 'open-uri'

    message = msg.to_s
    msg = message.gsub(" ", "%20")
    msg = msg.gsub("&", "%26")
    msg = msg.gsub("\r", "%2C")
    msg = msg.gsub("\n", "%0A")
    msg = msg.gsub("\'", "%27")
    msg = msg.gsub("\"", "%22")
    msg = msg.gsub(":", "%3A")
    msg = msg.gsub("/", "%2F")

    priority_count = 0  

    # to get school sms_configuration
    sms_config = MgSmsConfigeration.where(:is_deleted=>0, :mg_school_id=>school_id)
    key_value_pairs = ''
    url_exp = ''
    school_url = ''
    base_url = ''
    response = ''

    if sms_config.present?

      # to get attributes of school configuration
      saveattr = MgSmsAddionAttribute.where(:mg_sms_configuration_id=>sms_config[0].id, :is_deleted=>0, :mg_school_id=>school_id)
      key_value_pairs = saveattr[0].key + "=" + saveattr[0].value
      
      if saveattr.length > 0
        for i in 1..saveattr.length-1  
          key_value_pairs = "#{key_value_pairs}"+"&"+ saveattr[i].key + "=" + saveattr[i].value
        end
      end

      # msg = URI.encode(msg)
      # to combine school url, key_values_pairs, message and phone_number_array
      school_url = "#{sms_config[0].url}"+"?"+"#{key_value_pairs}"+"&"+"#{sms_config[0].msg_attribute}"+ "=" +"#{msg}"+"&"+"#{sms_config[0].mobile_number_attribute}"+ "=" +"#{phone_no_array.map(&:to_i).join(",")}"

      base_url = sms_config[0].url
      
    else

      # to get url_by_priority
      url_exp = get_url_by_priority(school_id, phone_no_array, msg, priority_count)

    end
    

    # to time for sleep
    require 'timeout'
    # if school_url present
    if school_url.present?

      begin

        # to sleep for 5secs
        status = Timeout::timeout(2) {

          # puts "###################################################################"
         #   # to print URl in log file
          begin
            Rails.logger.debug "school_url: #{school_url}" if Rails.logger.debug?
          rescue
            puts "school_url: #{school_url}"
          end 
           # puts "###################################################################"
            sleep 3
            # response = open(school_url).read
        }
      rescue
        response = 'failed'
      end

    else

      begin

        if url_exp[0].present?

          # to sleep for 5secs
          status = Timeout::timeout(2) {
          #   base_url = url_exp[1]

          #   puts "###################################################################"
          #   # to print URl in log file
          begin
            Rails.logger.debug "sms_url: #{url_exp[0]}" if Rails.logger.debug?
          rescue
            puts "sms_url: #{url_exp[0]}"
          end
          #   puts "###################################################################"

            sleep 3
          # response = open(url_exp[0]).read
          }

        end

      rescue

        priority_count += 1
        response = 'failed'
        # to get url_by_priority
        url_exp = get_url_by_priority(school_id, phone_no_array, msg, priority_count)

        # to retry if failed
        retry

      end

    end
    # returning response and base_url
    return response, base_url

  end

  def get_url_by_priority(school_id, phone_no_array, msg, priority_count)

    url_exp = ''

    # to encode message
    # msg = URI.encode(msg)
    # msg = ERB::Util.url_encode(msg)

    priority_objs = MgSmsPriority.where(:is_deleted=>0, :mg_school_id=>school_id).order(:priority)

    # to check priority_objs with priority_count
    if priority_count <= priority_objs.size - 1

      # to get priority sms_configuration
      sms_config = MgSmsConfigeration.where(:is_deleted=>0, :id=>priority_objs[priority_count].mg_sms_configeration_id)

      if sms_config.present?

        # to get attributes of priority configuration
        saveattr = MgSmsAddionAttribute.where(:mg_sms_configuration_id=>sms_config[0].id, :is_deleted=>0)
        key_value_pairs = saveattr[0].key + "=" + saveattr[0].value if saveattr.present?

        if  saveattr.length > 0
          for i in 1..saveattr.length-1  
            key_value_pairs = "#{key_value_pairs}"+"&"+ saveattr[i].key + "=" + saveattr[i].value
          end
        end

        sender_value = sms_config[0].sender_id_value if sms_config[0].sender_id_value.present?
        sender_value = priority_objs[priority_count].sender_id_value if priority_objs[priority_count].sender_id_value.present?

         # to combine priority url, key_values_pairs, message and phone_number_array
        url_exp = "#{sms_config[0].url}"+"?"+"#{key_value_pairs}"+"&"+"#{sms_config[0].msg_attribute}"+ "=" +"#{msg}"+"&"+"#{sms_config[0].mobile_number_attribute}"+ "=" +"#{phone_no_array.map(&:to_i).join(",")}"+"&"+"#{sms_config[0].sender_id}"+ "=" +"#{sender_value}"
        base_url = sms_config[0].url

      else
        # to combine defaulter url, key_values_pairs, message and phone_number_array
        url_exp = "http://10.0.20.177/blank/sms/user/urlsmstemp.php?username=kapbulk&pass=kapbulk@@12345&senderid=KAPMSG&message=#{msg}&dest_mobileno=#{phone_no_array.join(",")}&response=Y"
        base_url = "http://123.63.33.43/blank/sms"

      end
    end

    return url_exp, base_url

  end

  def get_sql(user_type, is_msg_dynamic, school_id, selected_users)

    raw_sql = ''

    if "Parent".casecmp(user_type.to_s) == 0

      if is_msg_dynamic

        # query for parent data
        raw_sql = "select g.id, g.first_name, g.middle_name, g.last_name, p.phone_number, s.first_name, s.middle_name, s.last_name from mg_guardians g, mg_phones p, mg_students s where g.mg_school_id=#{school_id} and g.mg_user_id = p.mg_user_id and p.phone_type = 'mobile' and g.mg_user_id in (#{selected_users.join(",")}) and s.id = g.mg_student_id and s.is_deleted = 0 and s.is_archive = 0"

      else  

        # query for parent data
        raw_sql = "select g.id, g.first_name, g.middle_name, g.last_name, p.phone_number from mg_guardians g, mg_phones p where g.mg_school_id=#{school_id} and g.mg_user_id = p.mg_user_id and p.phone_type = 'mobile' and g.mg_user_id in (#{selected_users.join(",")})"

      end

    elsif "Student".casecmp(user_type.to_s) == 0
      # query for student data

      raw_sql = "select s.id, s.first_name, s.middle_name, s.last_name, p.phone_number from mg_phones p, mg_students s where s.mg_school_id=#{school_id} and s.mg_user_id in (#{selected_users.join(",")}) and s.is_deleted = 0 and s.is_archive = 0 and s.mg_user_id = p.mg_user_id and p.phone_type = 'mobile'"

    elsif "Teacher".casecmp(user_type.to_s) == 0 || "Employee".casecmp(user_type.to_s) == 0

      # query for employee data
      raw_sql = "select e.id, e.first_name, e.middle_name, e.last_name, p.phone_number from mg_phones p, mg_employees e where e.mg_school_id=#{school_id} and e.mg_user_id in (#{selected_users.join(",")}) and e.is_deleted = 0 and e.is_archive = 0 and e.mg_user_id = p.mg_user_id and p.phone_type = 'mobile'"

    end

    # returning SQL query
    return raw_sql

  end

  def get_sms_detail_obj(user_type, curr_recepient, logged_in_user_id,logged_in_school_id, sms_message, save_sms_request_obj, has_child_name)

    current_date = Date.today
    full_name = ''
    curr_message = ''
    to_user_id = ''
    mobile_number = ''
    message = ''

    # to get parent details
    if "Parent".casecmp(user_type.to_s) == 0

      full_name = curr_recepient[1].to_s + " " + curr_recepient[2].to_s + " " + curr_recepient[3].to_s
      full_name = full_name.gsub("-"," ").gsub("  ","")
      curr_message = sms_message.gsub('$User_name', full_name)

      if has_child_name
        student_name = curr_recepient[5].to_s + " " + curr_recepient[6].to_s + " " +curr_recepient[7].to_s
        student_name = student_name.gsub("-"," ").gsub("  ","")
        curr_message = curr_message.gsub('$Child_name', student_name)
      end 

      to_user_id = curr_recepient[0]
      mobile_number = curr_recepient[4]
      message = curr_message

    # to get student details
    elsif "Student".casecmp(user_type.to_s) == 0

      full_name = curr_recepient[1].to_s + " " + curr_recepient[2].to_s + " " + curr_recepient[3].to_s
      full_name = full_name.gsub("-"," ").gsub("  ","")
      curr_message = sms_message.gsub('$User_name', full_name)

      if has_child_name
        curr_message = curr_message.gsub('$Child_name', full_name)
      end 

      to_user_id = curr_recepient[0]
      mobile_number = curr_recepient[4]
      message = curr_message

    # to get teacher details
    elsif "Teacher".casecmp(user_type.to_s) == 0 || "Employee".casecmp(user_type.to_s) == 0

      full_name = curr_recepient[1].to_s + " " + curr_recepient[2].to_s + " " + curr_recepient[3].to_s
      full_name = full_name.gsub("-"," ").gsub("  ","")
      curr_message = sms_message.gsub('$User_name', full_name)

      if has_child_name
        curr_message = curr_message.gsub('$Child_name', full_name)
      end 

      to_user_id = curr_recepient[0]
      mobile_number = curr_recepient[4]
      message = curr_message
    end

    # to validate mobile_number
    verified = validation_of_phone_number(mobile_number)
    if !verified[0]
      mobile_number = verified[1]
    end

    # to get message count
    msg_count = get_msg_count(message)

    # to new MgSmsDetail object
    sms_detail = MgSmsDetail.new
    sms_detail.mg_sms_request_id = save_sms_request_obj.id
    sms_detail.user_name = full_name
    sms_detail.to_user_id = to_user_id
    sms_detail.from_user_id = logged_in_user_id
    sms_detail.date = current_date
    sms_detail.response = ''
    sms_detail.status = "Sent"
    sms_detail.mobile_number = mobile_number
    sms_detail.from_module = "Notification"
    sms_detail.is_deleted = 0
    sms_detail.mg_school_id = logged_in_school_id
    sms_detail.created_by = logged_in_user_id
    sms_detail.updated_by = logged_in_user_id
    sms_detail.message = message
    sms_detail.msg_count = msg_count
    
    # returning sms_detail
    return sms_detail

  end


  # validate mobile_number method starts
  def validation_of_phone_number(number)

    if number.to_s.length == 10

      @output = "Verify"
      return true, @output

    else

      @output = "InValid Number"
      return false, @output

    end

  end
  # validate mobile_number method ends

  # message count method starts
  def get_msg_count(text_msg)

    len = text_msg.length
    if (1..160).include?(len)
      count_of_msg = 1
    elsif (161..306).include?(len)
      count_of_msg = 2
    elsif (307..459).include?(len)
      count_of_msg = 3
    elsif (460..612).include?(len)
      count_of_msg = 4
    elsif (613..765).include?(len)
      count_of_msg = 5
    elsif (766..918).include?(len)
      count_of_msg = 6
    elsif (919..1000).include?(len)
      count_of_msg = 7
    end

    # returning count_of_msg
    return count_of_msg

  end
  # message count method ends

# ============================ scheduler ends ================================== #

