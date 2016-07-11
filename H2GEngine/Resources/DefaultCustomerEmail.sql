SELECT * FROM (SELECT CASE WHEN i.sub_agent_id = -1 OR ISNULL(i.sub_agent_id,0)=0 THEN 
ISNULL(cus.email,'') ELSE ISNULL(sa.email,'') END AS email, 'i' doc FROM invoice i
LEFT JOIN customer cus ON i.customer_id = cus.id LEFT JOIN sub_agent sa ON i.sub_agent_id = sa.id 
WHERE i.invoice_no = @no UNION ALL
SELECT CASE WHEN i.sub_agent_id = -1 OR ISNULL(i.sub_agent_id,0)=0 THEN 
ISNULL(cus.email,'') ELSE ISNULL(sa.email,'') END AS email, 'r' doc FROM receipt i
LEFT JOIN customer cus ON i.customer_id = cus.id LEFT JOIN sub_agent sa ON i.sub_agent_id = sa.id 
WHERE i.receipt_no = @no) document WHERE doc = @doc