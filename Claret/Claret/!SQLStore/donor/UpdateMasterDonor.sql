update donor set
 Gender = :Gender
, Name = :Name
, Surname = :Surname
, Name_E = :Name_E
, Surname_E = :Surname_E
, Title_ID = :Title_ID
, Address = :Address
, Province = :Province
, Zipcode = :Zipcode
, Country_ID = :Country_ID
, Occupation_ID = :Occupation_ID
, Nationality_ID = :Nationality_ID
, Association_ID = :Association_ID
, Race_ID = :Race_ID
, Tel_Mobile1 = :Tel_Mobile1
, Tel_Mobile2 = :Tel_Mobile2
, Tel_Home = :Tel_Home
, Tel_Office = :Tel_Office
, Tel_Office_Ext = :Tel_Office_Ext
, Email = :Email
, Visit_Number = :Visit_Number
, Donate_Number_Ext = :Donate_Number_Ext
, Update_Date = sysdate
, Update_Staff = :update_staff
, Birthday = :Birthday
where id = :id