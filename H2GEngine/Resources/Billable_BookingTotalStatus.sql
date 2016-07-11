--declare = @booking_id bigint = 9705
SELECT COUNT(p.list) total_send, p.status FROM (
SELECT id AS list, status FROM booking_package 
WHERE status IN ('SEND','OK') AND booking_id = @booking_id
UNION ALL SELECT id AS list, status FROM booking_ticket 
WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN ('SEND','OK', 'PACKAGE')  
UNION ALL SELECT id AS list, status FROM booking_hotel 
WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN ('SEND','OK', 'PACKAGE')  
UNION ALL SELECT id AS list, status FROM booking_transfer 
WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN ('SEND','OK', 'PACKAGE')  
UNION ALL SELECT id AS list, status FROM booking_others 
WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN ('SEND','OK', 'PACKAGE')  
UNION ALL SELECT id AS list, status FROM booking_group_tour 
WHERE status IN ('SEND','OK') AND booking_id = @booking_id
) AS p GROUP BY p.status, p.list 



