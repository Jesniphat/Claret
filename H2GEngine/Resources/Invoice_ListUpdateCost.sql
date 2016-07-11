SELECT MIN(id2.id) AS id, id2.invoice_id, MAX(id2.linked_to) AS linked_to, 
id2.booking_billable_detail_id, SUM(id2.price) as price
FROM (
	SELECT invoice_id, booking_billable_detail_id FROM invoice_detail 
	WHERE booking_billable_detail_id in (
		SELECT bd.id FROM invoice_detail AS id
		INNER JOIN booking_billable_detail AS bd ON bd.id = id.booking_billable_detail_id
		WHERE id.linked_record='N' /*PRODUCT_ID*/
	)
) AS id1 
LEFT JOIN invoice_detail AS id2 
ON id1.booking_billable_detail_id= id2.booking_billable_detail_id AND id1.invoice_id= id2.invoice_id 
INNER JOIN invoice AS i ON i.id = id2.invoice_id AND i.status NOT IN('VOID')
GROUP BY id2.invoice_id, id2.booking_billable_detail_id