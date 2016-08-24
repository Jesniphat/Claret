select dor.id as donor_id, dor.Donor_Number, dor.Gender, dor.Name, dor.Surname, dor.Name_E, dor.Surname_E, dor.Title_ID
, dor.Address, dor.Sub_District, dor.District, dor.Province, dor.Zipcode, dor.Country_ID, dor.Occupation_ID
, dor.Nationality_ID, dor.Race_ID, dor.Tel_Mobile1, dor.Tel_Mobile2, dor.Tel_Home, dor.Tel_Office, dor.Tel_Office_Ext
, dor.Email, dor.Association_ID, nvl(dor.Visit_Number,0) as visit_count, nvl(DOR.DONATE_NUMBER_EXT,0) as Donate_Number_Ext, dor.First_Visit_Date
, dor.HIIG_Code, dor.Create_Date, dor.Create_Staff, dor.Birthday, rg.description as RH_Group_ID, nvl(DOR.DONATE_NUMBER,0) as Donate_Number 
, nvl(dor.DONATE_NUMBER,0)+nvl(DOR.DONATE_NUMBER_EXT,0) as donate_count
, to_char(nvl(dor.Last_Visit_Date,cp.plan_date), 'DD MON YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as Last_Visit_Date_text
, to_date(to_char(nvl(DV.visit_date,nvl(dv.Create_Date,cp.plan_date)),'dd/mm/yyyy'),'dd/mm/yyyy') 
	- to_date(to_char(nvl(dor.Last_Visit_Date,cp.plan_date),'dd/mm/yyyy'),'dd/mm/yyyy') as diff_date 
, dv.id as visit_id, dv.collection_plan_id, dv.collection_point_id, dv.site_id, nvl(dv.status,'REGISTER') as status, nvl(dv.visit_from,'HOSPITAL') as visit_from
, dv.queue_number, dv.donation_type_id, dv.bag_id, dv.donation_to_id
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,cp.plan_date)), 'DD MON YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date_time_text
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,cp.plan_date)), 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date_text
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,cp.plan_date)), 'DD-MM-YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date
, dv.weight, dv.pressure_max, dv.pressure_min, dv.hb, dv.plt, dv.hb_test, dv.heart_rate, dv.heart_lung
, dv.interview_status, dv.sample_number, dv.for_collection_point_id
from donor dor 
left join donation_visit dv on DV.donor_id = dor.id  and dv.id = :visit_id 
left join rh_group rg on rg.id = dor.RH_Group_ID
cross join collection_plan cp
where DOR.id = :id
and cp.id = :plan_id