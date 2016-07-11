/*declare IN  bigint = 3360 */

SELECT * FROM (
/* TICKET */

SELECT 'Ticket' AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.booking_package_id,-1) as package_id, bp.status,
ISNULL(bp.ad_cost+bp.ch_cost+bp.inf_cost+bp.ad_tax+bp.ch_tax+bp.inf_tax,0) AS cost,
ISNULL(bp.ad_price+bp.ch_price+bp.inf_price+bp.ad_tax+bp.ch_tax+bp.inf_tax,0) AS price 
FROM booking_ticket AS bp WHERE bp.booking_id = @booking_id
UNION ALL

/* HOTEL*/
SELECT 'Hotel' AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.booking_package_id,-1) as package_id, bp.status,
ISNULL(hroom.roomcost,0) + ISNULL(hreq.servicecost,0) AS cost,
ISNULL(hroom.roomprice,0) + ISNULL(hreq.serviceprice,0) AS price 
FROM booking_hotel AS bp
LEFT JOIN ( 
	SELECT booking_hotel_id, SUM(price * qty * DATEDIFF(DAY,checkin_date,checkout_date)) as roomprice,
	SUM(cost * qty * DATEDIFF(DAY,checkin_date,checkout_date)) as roomcost 
	FROM booking_hotel_room
	GROUP BY booking_hotel_id
) hroom ON hroom.booking_hotel_id = bp.id 
LEFT JOIN ( 
	SELECT booking_hotel_id, SUM(cost) as servicecost , SUM(price) as serviceprice 
	FROM booking_hotel_request
	GROUP BY booking_hotel_id
) hreq ON hreq.booking_hotel_id = bp.id 
WHERE bp.booking_id = @booking_id 
UNION ALL

/* OTHERS*/
SELECT 'Others' AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.booking_package_id,-1) as package_id, bp.status,
SUM(ISNULL(op.cost,0)*ISNULL(op.pay_amount,0)) AS cost, 
SUM(ISNULL(op.price,0)*ISNULL(op.pay_amount,0)) AS price 
FROM booking_others AS bp
LEFT JOIN booking_others_price AS op ON op.booking_others_id = bp.id 
WHERE booking_id = @booking_id
GROUP BY bp.supplier_id, bp.id, bp.booking_package_id, bp.status
UNION ALL

/* TRANSFER*/
SELECT 'Transfer' AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.booking_package_id,-1) as package_id, bp.status, (
	CASE WHEN bp.transfer_type = 'private' THEN 
		ISNULL(bp.private_cost,0) * ISNULL(pax_private,0)
	ELSE 
		ISNULL(bp.ad_cost,0) * ISNULL(bp.pax_adult,0) +
		ISNULL(bp.ch_cost,0) * ISNULL(bp.pax_child,0) +
		ISNULL(bp.inf_cost,0) * ISNULL(bp.pax_infant,0)
	END
) AS cost, (
	CASE WHEN bp.transfer_type = 'private' THEN 
		ISNULL(bp.private_price,0) * ISNULL(pax_private,0)
	ELSE 
		ISNULL(bp.ad_price,0) * ISNULL(bp.pax_adult,0) +
		ISNULL(bp.ch_price,0) * ISNULL(bp.pax_child,0) +
		ISNULL(bp.inf_price,0) * ISNULL(bp.pax_infant,0)
	END
) AS cost 
FROM booking_transfer AS bp 
WHERE booking_id = @booking_id
UNION ALL

/* PACKAGE*/
SELECT 'Package' AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.id,-1) as package_id, bp.status,
bp.cost+ISNULL(bp.discount_cost,0) AS cost, 
bp.price+ISNULL(bp.discount_price,0) AS price FROM booking_package AS bp
WHERE booking_id = @booking_id
UNION ALL

/* GROUP TOUR*/
SELECT 'Grouptour' AS product, bp.id as ref_id, bp.supplier_id, -1 as package_id, bp.status,
SUM(ISNULL(bop.cost,0)*ISNULL(bop.pay_amount,0)) AS cost ,
SUM(ISNULL(bop.price,0)*ISNULL(bop.pay_amount,0)) AS price 
FROM booking_group_tour AS bp
LEFT JOIN booking_group_tour_price bop ON bop.booking_group_tour_id = bp.id 
WHERE bp.booking_id = @booking_id GROUP BY bp.supplier_id, bp.id, bp.status
) AS b/*PRODUCT_REFID*/ WHERE b.status NOT IN('PACKAGE') /*SUPPLIER_ID*/