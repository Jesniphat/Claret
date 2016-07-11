--declare @id Bigint = 11346
SELECT 
(
 CASE WHEN s.id>0 THEN s.name 
 ELSE ISNULL(c.initial_name,'')+' '+(CASE WHEN ISNULL(c.billing_name, '')<>'' THEN c.billing_name ELSE c.name END) END
) AS billable_name,
(
 CASE WHEN s.id>0 THEN ISNULL(s.address,'') ELSE (CASE WHEN ISNULL(c.billing_address, '')<>'' THEN c.billing_address ELSE c.address END) END
) AS billable_address,
b.sub_agent_id, b.customer_id
FROM booking b
LEFT JOIN sub_agent s ON s.id=b.sub_agent_id LEFT JOIN customer c ON c.id=b.customer_id
WHERE b.id=@id

--SELECT TOP 1 [id] FROM [credit_term] WHERE status = 'ACTIVE' ORDER BY [description] ASC 
--SELECT TOP 1 [id] FROM [pay_by] WHERE [description] = 'WAIT'