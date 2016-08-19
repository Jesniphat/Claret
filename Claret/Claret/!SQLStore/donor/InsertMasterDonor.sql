insert into donor(id, Donor_Number, Gender, Name, Surname, Name_E, Surname_E, Title_ID, Address, Sub_District, District, Province, Zipcode, Country_ID
, Occupation_ID, Nationality_ID, Race_ID, Tel_Mobile1, Tel_Mobile2, Tel_Home, Tel_Office, Tel_Office_Ext, Email, Association_ID, Visit_Number
, Donate_Number_Ext, First_Visit_Date, Last_Visit_Date, HIIG_Code, Create_Date, Create_Staff, Birthday, Update_Date, Update_Staff) 
values(:id, :Donor_Number, :Gender, :Name, :Surname, :Name_E, :Surname_E, :Title_ID, :Address, :Sub_District, :District, :Province, :Zipcode, :Country_ID
, :Occupation_ID, :Nationality_ID, :Race_ID, :Tel_Mobile1, :Tel_Mobile2, :Tel_Home, :Tel_Office, :Tel_Office_Ext, :Email, :Association_ID, :Visit_Number
, :Donate_Number_Ext, sysdate, sysdate, :HIIG_Code, sysdate, :Create_Staff, :Birthday, sysdate, :update_staff)