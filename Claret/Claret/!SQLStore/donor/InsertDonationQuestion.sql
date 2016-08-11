insert into donation_questionnaire (id, create_date, create_staff, donation_visit_id, questionnaire_question_id
, questionnaire_question_code, questionnaire_question_desc, answer, parent_id, questionnaire_question_desc_th)
values(:id, sysdate, :create_staff, :donation_visit_id, :questionnaire_question_id
, :questionnaire_question_code, :questionnaire_question_desc, :answer, :parent_id, :questionnaire_question_desc_th)