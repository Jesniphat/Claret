insert into donation_examination (id, create_date, create_staff, donation_visit_id, donation_hospital_id, donation_from
, examination_group_id, examination_group_desc, examination_id, examination_desc, questionnaire_question_id)
values(:id, sysdate, :create_staff, :donation_visit_id, :donation_hospital_id, :donation_form
, :examination_group_id, :examination_group_desc, :examination_id, :examination_desc, :questionnaire_question_id)