SELECT nvl(count(visit_id),0) from ( select DV.id as visit_id
from donation_hospital dv
inner join donor dn on DN.id = DV.DONOR_ID
left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
left join external_card ec on ec.id = dexc.external_card_id
left join rh_group rg on rg.id = dn.rh_group_id
where dv.receipt_hospital_id = :receipt_hospital_id /*#REPORT_DATE*/ /*#STATUS*/
/*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
/*#BIRTHDAY*/ /*#BLOOD_GROUP*/  ) dn