insert into donation_visit (id, donor_id, queue_number, visit_from, donation_type_id, bag_id, donation_to_id, collection_plan_id, collection_point_id
, site_id, visit_number, status, create_staff, create_date, visit_date, for_collection_point_id, update_staff, update_date) 
values(:id, :donor_id, :queue_number, :visit_from, :donation_type_id, :bag_id, :donation_to_id, :collection_plan_id, :collection_point_id
, :site_id, :visit_number, :status, :create_staff, sysdate, :visit_date, :for_collection_point_id, :update_staff, sysdate)

