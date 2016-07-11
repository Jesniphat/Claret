--declare @booking_id bigint = 9705
SELECT SUM(ISNULL(pd.cost,0) * ISNULL(p.currency_rate,1)) AS cost FROM payment_detail AS pd
INNER JOIN payment AS p ON p.id = pd.payment_id
LEFT JOIN pay_by AS pb ON pb.id = p.pay_by_id 
WHERE pd.booking_id=@booking_id AND pb.description NOT IN('VOID')

