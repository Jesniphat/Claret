insert into donor_deferral (id, donor_id, deferral_id, create_date, create_staff, start_date
, note, questionnaire_question_id, donation_visit_id)
values(:id, :donor_id, :deferral_id, sysdate, :create_staff, :start_date
, :note, :questionnaire_question_id, :donation_visit_id)