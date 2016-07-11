SELECT (CASE s.name WHEN 'WALK IN' THEN ISNULL(c.tel,'') ELSE ISNULL(s.tel,'') END) AS tel FROM invoice i 
LEFT JOIN sub_agent s ON s.id=i.sub_agent_id LEFT JOIN customer c ON c.id=i.customer_id 
WHERE invoice_no=@no UNION ALL
SELECT (CASE s.name WHEN 'WALK IN' THEN ISNULL(c.tel,'') ELSE ISNULL(s.tel,'') END) AS tel FROM receipt i 
LEFT JOIN sub_agent s ON s.id=i.sub_agent_id LEFT JOIN customer c ON c.id=i.customer_id 
WHERE receipt_no=@no

