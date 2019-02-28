class MgSchool < ActiveRecord::Base

    # before_create :randomize_image_file_name

    validates :school_name,:school_code, :address_line1, :city, :state,:pin_code, 
    :country,:mobile_number,:email_id,:fax_number,:date_format,
    :currency_type,:affilicated_to,:grading_system, 
    presence: true

    validates_uniqueness_of :school_name, conditions: -> { where(is_deleted: false) }

    validates :pin_code,numericality: { only_integer: true }
    validates :email_id, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

    
    has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "logo.jpg"
    validates_attachment_content_type :logo,:content_type =>/\Aimage\/.*\Z/

    def schedule_command
        puts "It is for schedule job"
    end
       
    # has_many :mg_action_requireds
    # has_many :mg_album_photos
    # # has_many :mg_alumni_get_togethers
    # # has_many :mg_alumni_job_posting_details
    # has_many :mg_batch_groups
    # # has_many :mg_bed_assignments
    # # has_many :mg_bed_details
    # has_many :mg_book_purchases
    # has_many :mg_books_categories
    # has_many :mg_books_transactions
    # # has_many :mg_booster_doses
    # has_many :mg_caller_categories
    # has_many :mg_caller_category_foms
    # has_many :mg_caste_categories
    # has_many :mg_castes
    # has_many :mg_cbsc_disciplines
    # has_many :mg_cbsc_exam_components
    # has_many :mg_cbsc_exam_particulars
    # has_many :mg_cbsc_notebook_submissions
    # has_many :mg_cbsc_subject_enrichment_activity_components
    # has_many :mg_cbsc_subject_enrichments
    # # has_many :mg_check_up_schedules
    # # has_many :mg_checkup_particulars
    # # has_many :mg_checkup_types
    # has_many :mg_committee_members
    # # has_many :mg_complain_hostels
    # has_many :mg_custom_fields_data
    # has_many :mg_email_configurations
    # has_many :mg_emails
    # has_many :mg_employee_departments
    # has_many :mg_employee_weekdays
    # has_many :mg_entrance_exam_venues
    # # has_many :mg_fa_criteria
    # has_many :mg_faq_categories
    # has_many :mg_faq_sub_categories
    # has_many :mg_faqs
    # has_many :mg_guardian_transport_requisitions
    # has_many :mg_help_documents
    # # has_many :mg_hostel_programme_quota
    # has_many :mg_inventory_managements 
    # has_many :mg_invite_get_togethers
    # has_many :mg_item_informations
    # has_many :mg_lab_units
    # has_many :mg_laboratory_incharges
    # has_many :mg_languages
    # has_many :mg_library_stack_managements
    # has_many :mg_manage_subjects
    # has_many :mg_management_quota
    # has_many :mg_meeting_planner_foms
    # has_many :mg_phones
    # has_many :mg_placement_student_details
    # has_many :mg_poll_data
    # # has_many :mg_poll_question_alumnis
    # has_many :mg_previous_educations
    # has_many :mg_resource_categories
    # has_many :mg_sms_details
    # has_many :mg_sport_payslip_components
    # has_many :mg_sport_schedules
    # has_many :mg_sports_bed_assignments
    # has_many :mg_sports_bed_details
    # has_many :mg_sports_fine_students
    # has_many :mg_sports_fines
    # has_many :mg_student_batch_histories
    # has_many :mg_student_guardians
    # has_many :mg_student_scholarships
    # has_many :mg_syllabuses
    # has_many :mg_transport_time_managements
    # # has_many :mg_vaccinations
    # has_many :mg_wings
    # has_many :templates
    # # has_many :mg_specializations
    # has_many :mg_report_types
    # # has_many :mg_poll_option_alumni_particulars
    # # has_many :mg_meal_categories
    # has_many :mg_master_payment_types
    # has_many :mg_inventory_projection_items
    # has_many :mg_inventory_items
    # has_many :mg_alumni_item_sale_details
    # has_many :mg_inventory_sales_data
    # has_many :mg_inventory_item_managements
    # has_many :mg_inventory_sales_informations
    # has_many :mg_sports_item_managements
    # # has_many :mg_hostel_discipline_reports
    # # has_many :mg_hostel_floors
    # # has_many :mg_allocate_room_lists
    # # has_many :mg_allocate_rooms
    # # has_many :mg_hostel_health_managements
    # # has_many :mg_hostel_reallotment_requests
    # # has_many :mg_hostel_rooms
    # # has_many :mg_hostel_going_out_provisions
    # # has_many :mg_hostel_room_types
    # # has_many :mg_hostel_rules
    # has_many :mg_inventory_proposal_items
    # has_many :mg_inventory_room_managements
    # has_many :mg_inventory_vendor_items
    # has_many :mg_inventory_vendors
    # has_many :mg_multi_school_accesses
    # has_many :mg_page_hit_counts
    # has_many :mg_payment_types
    # has_many :mg_sport_student_data_results
    # has_many :mg_student_attandances
    # has_many :mg_resource_purchases
    # has_many :mg_inventory_item_categories
    # has_many :mg_inventory_fine_particulars
    # has_many :mg_images
    # # has_many :mg_hostel_attendances
    # # has_many :mg_hostel_discipline_report_lists
    # has_many :mg_cce_grades_sets
    # has_many :mg_guests
    # has_many :mg_exam_scores
    # has_many :mg_event_committees
    # has_many :mg_extra_curricular_associations
    # has_many :mg_exam_systems
    # has_many :mg_extra_curriculars
    # has_many :mg_finance_transaction_details
    # has_many :mg_library_settings
    # has_many :mg_particular_types
    # has_many :mg_hobbies
    # has_many :mg_hobby_associations
    # has_many :mg_homework_categories
    # has_many :mg_labs
    # has_many :mg_item_purchases
    # has_many :mg_lab_inventories
    # has_many :mg_laboratory_items
    # has_many :mg_laboratory_subjects
    # has_many :mg_employee_attendances
    # has_many :mg_employee_biometric_attendances
    # has_many :mg_employee_children
    # has_many :mg_employee_folders
    # has_many :mg_employee_grade_components
    # has_many :mg_employee_holiday_attendances
    # has_many :mg_employee_leave_applications
    # has_many :mg_employee_leave_types
    # has_many :mg_employee_payslip_details
    # has_many :mg_employee_payslip_components
    # has_many :mg_employee_payslips
    # has_many :mg_employee_subjects
    # has_many :mg_finance_officers
    # # has_many :mg_hostel_wardens
    # # has_many :mg_hostel_details
    # has_many :mg_inventory_item_consumptions
    # has_many :mg_inventory_item_damageds
    # has_many :mg_inventory_item_returns
    # has_many :mg_inventory_projections
    # has_many :mg_inventory_proposals
    # has_many :mg_inventory_store_managements
    # has_many :mg_inventory_store_managers
    # has_many :mg_library_employees
    # has_many :mg_meeting_details
    # has_many :mg_meeting_rooms
    # has_many :mg_sport_employee_data_results
    # has_many :mg_sports_results
    # has_many :mg_sport_teams
    # has_many :mg_sport_team_employees
    # has_many :mg_sports_item_consumptions
    # has_many :mg_sports_pay_deductiion_lists
    # has_many :mg_payslip_leave_details
    # has_many :mg_employee_leave_types
    # has_many :mg_employee_leave_applications
    # has_many :mg_grade_components
    # has_many :mg_employee_grades
    # has_many :mg_employee_positions
    # has_many :mg_cbsc_co_scholastic_exam_components
    # has_many :mg_cbsc_co_scholastic_exam_particulars
    # has_many :mg_designation_foms
    # has_many :mg_book_purchase_details
    # has_many :mg_entrance_exam_details
    # has_many :mg_resource_informations
    # has_many :mg_resource_inventories
    # has_many :mg_topics
    # has_many :mg_units
    # has_many :mg_batch_contents
    # has_many :mg_batch_documents
    # has_many :mg_batch_syllabuses
    # # has_many :mg_booster_dose_details
    # # has_many :mg_canteen_bill_details
    # # has_many :mg_canteen_wallet_amounts
    # has_many :mg_cbsc_co_scholastic_grades
    # has_many :mg_cbsc_exam_schedules
    # has_many :mg_cbsc_exam_type_associations
    # has_many :mg_cbsc_exam_types
    # has_many :mg_cbsc_final_co_scholastic_grades
    # has_many :mg_cbsc_other_marks_entries
    # has_many :mg_cbsc_scholastic_marks_entries
    # # has_many :mg_check_up_schedule_records
    # has_many :mg_disciplinary_action_students
    # has_many :mg_exam_application_form_data
    # has_many :mg_exam_subject_specialized_employees
    # has_many :mg_examination_details
    # has_many :mg_examination_time_tables
    # has_many :mg_fee_fine_particulars
    # has_many :mg_final_scholastic_scores
    # has_many :mg_grouped_batches
    # has_many :mg_grouped_exam_reports
    # has_many :mg_health_tests
    # has_many :mg_inventory_issued_item_consumptions
    # has_many :mg_invitations
    # has_many :mg_item_consumptions
    # has_many :mg_my_questions
    # has_many :mg_postal_records
    # has_many :mg_siblings
    # has_many :mg_student_admissions
    # # has_many :mg_student_hostel_application_forms
    # has_many :mg_student_item_consumptions
    # has_many :mg_syllabus_trackers
    # has_many :mg_time_table_change_entries
    # has_many :mg_time_table_entries
    # has_many :mg_user_albums
    # # has_many :mg_vaccination_details
    # has_many :mg_document_managements
    # has_many :mg_add_reports
    # has_many :inventory_stack_managements
    # has_many :mg_account_central_incharges
    # has_many :mg_account_transactions
    # has_many :mg_address_book_foms
    # # has_many :mg_allergies
    # # has_many :mg_alumnis
    # # has_many :mg_poll_option_alumnis
    # # has_many :mg_alumni_pollings
    # has_many :mg_app_faq_categories
    # has_many :mg_app_faq_qas
    # has_many :mg_app_faq_sub_categories
    # has_many :mg_assignments
    # has_many :mg_assignment_documentations
    # has_many :mg_assignment_submissions
    # has_many :mg_attendances
    # has_many :mg_bank_account_details
    # has_many :mg_books_inventories
    # has_many :mg_cce_grades
    # has_many :mg_cce_weightages
    # has_many :mg_cce_weightages_courses
    # has_many :mg_class_designations
    # has_many :mg_class_timings
    # has_many :mg_common_custom_fields
    # has_many :mg_employee_categories
    # has_many :mg_employee_leaves
    # has_many :mg_employee_subjects
    # has_many :mg_events
    # has_many :mg_event_types
    # has_many :mg_exams
    # has_many :mg_exam_groups
    # has_many :mg_fa_groups
    # has_many :mg_fa_groups_subjects
    # has_many :mg_fee_categories
    # has_many :mg_fee_category_batches
    # has_many :mg_fee_collections
    # has_many :mg_fee_collection_discounts
    # has_many :mg_fee_collection_particulars
    # has_many :mg_fee_discounts
    # has_many :mg_fee_fines
    # has_many :mg_fee_fine_dues
    # has_many :mg_fee_particulars
    # has_many :mg_finance_fees
    # has_many :mg_finance_transactions
    # has_many :mg_grading_levels
    # has_many :mg_grouped_exams
    # has_many :mg_mail_statuses
    # has_many :mg_notifications
    # has_many :mg_observations
    # has_many :mg_observation_groups
    # has_many :mg_ranking_levels
    # has_many :mg_student_attendances
    # has_many :mg_student_categories
    # has_many :mg_subjects
    # has_many :mg_time_tables
    # has_many :mg_weekdays
    # has_many :mg_batch_subjects
    # has_many :mg_cce_exam_categories
    # has_many :mg_addresses
    # has_many :mg_assessment_scores
    # has_many :mg_course_observation_groups
    # has_many :mg_curriculums
    # has_many :mg_descriptive_indicators
    # has_many :mg_accounts
    # has_many :mg_albums
    # # has_many :mg_alumni_photo_galleries
    # # has_many :mg_alumni_programme_attendeds
    # has_many :mg_get_togethers
    # has_many :mg_payment_gateways
    # has_many :mg_disciplinary_actions
    # has_many :mg_central_account_transactions
    # has_many :mg_fom_transport_bookings
    # has_many :mg_fom_query_records
    # has_many :mg_query_records
    # has_many :mg_guest_room_bookings
    # has_many :mg_holidays
    # has_many :mg_sports_pay_deductions
    # has_many :mg_transports
    # has_many :mg_vehicles

    # has_many :mg_courses,:dependent => :destroy
    # accepts_nested_attributes_for :mg_courses

    # has_many :mg_batches,:dependent => :destroy
    # accepts_nested_attributes_for :mg_batches

    # has_many :mg_employees,:dependent => :destroy
    # accepts_nested_attributes_for :mg_employees

    # has_many :mg_students,:dependent => :destroy
    # accepts_nested_attributes_for :mg_students

    # has_many :mg_guardians,:dependent => :destroy
    # accepts_nested_attributes_for :mg_guardians

    # has_many :mg_users#,:dependent => :destroy
    # # accepts_nested_attributes_for :mg_users
    # # for shashi added for canteen
   
    # # has_many :mg_canteen_meals
    # # has_many :mg_canteen_bill_payments
    # # has_many :mg_canteen_regular_menus
    # # has_many :mg_food_items
    # # has_many :mg_canteens
    # # has_many :mg_canteen_balance_amounts
    # # has_many :mg_canteen_amount_transactions
    # has_many :mg_employee_types
    # has_many :mg_resource_types
    # has_many :mg_roles
    # has_many :mg_roles_permissions
    # has_many :mg_salary_components
    # has_many :mg_scholastic_exam_components
    # has_many :mg_scholastic_exam_particulars
    # has_many :mg_sport_games
    # has_many :mg_sport_team_students
    # has_many :mg_sports
    # has_many :mg_sports_associations

    #def image_file=(input_data)
    # self.filename = input_data.original_filename
   #  self.content_type = input_data.content_type.chomp
   #  self.school_logo = input_data.read
  #end


  def randomize_image_file_name
      puts "School image editing is going to call "  

      # extension = File.extname(image_file_name).downcase
      # self.image.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(8)}#{extension}")
  end
end
