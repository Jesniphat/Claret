insert into donation_hospital (ID, CREATE_DATE, CREATE_STAFF, RECEIPT_HOSPITAL_ID, ORDER_NUMBER, DONOR_ID, VISIT_DATE, DONATION_TO_ID, SITE_ID
, COLLECTION_POINT_ID, HOSPITAL_ID, DEPARTMENT_ID, LAB_ID, STATUS, REMARK, update_DATE, update_STAFF) 
values(:id, sysdate, :create_staff, :receipt_hospital_id, :order_number, :donor_id, sysdate, :donation_to_id, :site_id
, :collection_point_id, :hospital_id, :department_id, :lab_id, :status, :remark, sysdate, :update_staff)