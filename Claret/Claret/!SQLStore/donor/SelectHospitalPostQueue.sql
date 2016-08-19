SELECT DN.rn as row_num, dn.visit_id, dn.donor_id, dn.QUEUE_NUMBER, dn.name, dn.SAMPLE_NUMBER, dn.COMMENT_TEXT, dn.regis_time
, dn.regis_staff, dn.INTERVIEW_time, dn.INTERVIEW_STAFF, dn.collection_time, dn.collection_staff, dn.lab_time, dn.lab_staff
FROM (
    SELECT ROWNUM AS rn, dn.* 
        FROM (
            SELECT dn.* 
                FROM (
						select DV.id as visit_id, DN.id as donor_id, DV.order_number as QUEUE_NUMBER, DN.name || ' '  || DN.SURNAME as name
						, DV.SAMPLE_NUMBER, '' as COMMENT_TEXT, to_char(nvl(DV.VISIT_DATE,dv.create_date),'HH24,MI') as regis_time
						, st.code as regis_staff, to_char(dv.INTERVIEW_DATE,'HH24,MI') as INTERVIEW_time, dv.INTERVIEW_STAFF
						, '' as collection_time, '' as collection_staff, '' as lab_time, '' as lab_staff
						from DONATION_HOSPITAL dv
						inner join donor dn on DN.id = DV.DONOR_ID
						left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
						left join external_card ec on ec.id = dexc.external_card_id
						left join rh_group rg on rg.id = dn.rh_group_id
						left join staff st on st.id = dv.create_staff
                        where dv.receipt_hospital_id = :receipt_hospital_id /*#STATUS*/
                        /*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
                        /*#BIRTHDAY*/ /*#BLOOD_GROUP*/ 
					) dn
            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
            ) dn
    ) dn
WHERE rn BETWEEN :start_row AND :end_row