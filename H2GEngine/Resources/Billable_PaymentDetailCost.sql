--declare @billable_detail_id bigint = 10338
SELECT ISNULL(SUM(pd.cost*p.currency_rate),0) AS cost FROM payment_detail AS pd 
INNER JOIN payment AS p ON p.id = pd.payment_id LEFT JOIN pay_by AS pb ON pb.id = p.pay_by_id  
WHERE booking_billable_detail_id=@billable_detail_id AND pb.description NOT IN('VOID')