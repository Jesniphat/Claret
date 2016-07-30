select dor.id as donor_id, dor.Donor_Number, dor.Gender, dor.Name, dor.Surname, dor.Name_E, dor.Surname_E, dor.Title_ID
, dor.Address, dor.Sub_District, dor.District, dor.Province, dor.Zipcode, dor.Country_ID, dor.Occupation_ID
, dor.Nationality_ID, dor.Race_ID, dor.Tel_Mobile1, dor.Tel_Mobile2, dor.Tel_Home, dor.Tel_Office, dor.Tel_Office_Ext
, dor.Email, dor.Association_ID, nvl(dor.Visit_Number,0) as visit_count, nvl(DOR.DONATE_NUMBER_EXT,0) as Donate_Number_Ext, dor.First_Visit_Date
, dor.HIIG_Code, dor.Create_Date, dor.Create_Staff, dor.Birthday, rg.description as RH_Group_ID, nvl(DOR.DONATE_NUMBER,0) as Donate_Number 
, nvl(dor.Visit_Number,0)+nvl(DOR.DONATE_NUMBER_EXT,0) as donate_count
, to_char(nvl(dor.Last_Visit_Date,sysdate), 'DD MON YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as Last_Visit_Date_text
, to_date(to_char(nvl(DV.visit_date,nvl(dv.Create_Date,sysdate)),'dd/mm/yyyy'),'dd/mm/yyyy') 
	- to_date(to_char(nvl(dor.Last_Visit_Date,sysdate),'dd/mm/yyyy'),'dd/mm/yyyy') as diff_date 
, dv.id as visit_id, '' as collection_plan_id, dv.collection_point_id, dv.site_id, nvl(dv.status,'REGISTER') as status, 'HOSPITAL' as visit_from
, dv.order_number as queue_number, '' as donation_type_id, '' as bag_id, dv.donation_to_id
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,sysdate)), 'DD MON YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date_time_text
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,sysdate)), 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date_text
, to_char(nvl(DV.visit_date,nvl(dv.Create_Date,sysdate)), 'DD-MM-YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date
from donor dor 
left join donation_hospital dv on DV.donor_id = dor.id  and dv.id = :donation_hospital_id 
left join rh_group rg on rg.id = dor.RH_Group_ID
where DOR.id = :id