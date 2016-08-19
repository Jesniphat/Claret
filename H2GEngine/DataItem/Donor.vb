Namespace DataItem

    Public Class DonorItem
        Public ID As String
        Public DonorNumber As String
        Public Gender As String
        Public Name As String
        Public Surname As String
        Public NameE As String
        Public SurnameE As String
        Public Birthday As String
        Public Age As String
        Public TitleID As String
        Public Address As String
        Public SubDistrict As String
        Public District As String
        Public Province As String
        Public Zipcode As String
        Public CountryID As String
        Public OccupationID As String
        Public NationalityID As String
        Public RaceID As String
        Public Mobile1 As String
        Public Mobile2 As String
        Public HomeTel As String
        Public OfficeTel As String
        Public OfficeTelExt As String
        Public Email As String
        Public AssociationID As String
        Public RHGroupID As String
        Public VisitNumber As String
        Public DonateNumber As String
        Public DonateNumberExt As String
        Public FirstVisitDate As String
        Public LastVisitDate As String
        Public HIIGCode As String
        Public VisitID As String
        Public notOnlyDonor As String

        Public Shared Function WithCollection(ByVal item As DataItem.DonorItem) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add(":id", DbType.Int64, .ID)
                param.Add(":Donor_Number", DbType.String, .DonorNumber)
                param.Add(":Gender", DbType.String, .Gender)
                param.Add(":Name", DbType.String, .Name)
                param.Add(":Surname", DbType.String, .Surname)
                param.Add(":Name_E", DbType.String, .NameE)
                param.Add(":Surname_E", DbType.String, .SurnameE)
                param.Add(":Birthday", DbType.DateTime, H2G.BE2AC(H2G.Convert(Of DateTime)(.Birthday)).ToString("dd-MM-yyyy"))
                param.Add(":Title_ID", DbType.Int64, .TitleID)
                param.Add(":Address", DbType.String, .Address)
                param.Add(":Sub_District", DbType.String, .SubDistrict)
                param.Add(":District", DbType.String, .District)
                param.Add(":Province", DbType.String, .Province)
                param.Add(":Zipcode", DbType.String, .Zipcode) '
                param.Add(":Country_ID", DbType.Int64, .CountryID)
                param.Add(":Occupation_ID", DbType.Int64, .OccupationID)
                param.Add(":Nationality_ID", DbType.Int64, .NationalityID) '
                param.Add(":Race_ID", DbType.Int64, .RaceID)
                param.Add(":Tel_Mobile1", DbType.String, .Mobile1)
                param.Add(":Tel_Mobile2", DbType.String, .Mobile2)
                param.Add(":Tel_Home", DbType.String, .HomeTel)
                param.Add(":Tel_Office", DbType.String, .OfficeTel)
                param.Add(":Tel_Office_Ext", DbType.String, .OfficeTelExt)
                param.Add(":Email", DbType.String, .Email)
                param.Add(":Association_ID", DbType.Int64, IIf(String.IsNullOrEmpty(.AssociationID), Nothing, .AssociationID))
                param.Add(":Visit_Number", DbType.Int64, .VisitNumber)
                param.Add(":Donate_Number_Ext", DbType.Int64, .DonateNumberExt)
                param.Add(":HIIG_Code", DbType.String, .HIIGCode)
                param.Add(":Create_Staff", DbType.Int64, H2G.Login.ID)
                param.Add(":update_staff", DbType.Int64, H2G.Login.ID)

            End With

            Return param
        End Function

        Public Shared Function WithItems(ByVal item As DataItem.DonorItem, ByVal dRow As DataRow) As DataItem.DonorItem
            With item
                .ID = dRow("id").ToString()
                .DonorNumber = dRow("Donor_Number").ToString()
                .Gender = dRow("Gender").ToString()
                .Name = dRow("Name").ToString()
                .Surname = dRow("Surname").ToString()
                .NameE = dRow("Name_E").ToString()
                .SurnameE = dRow("Surname_E").ToString()
                .Age = H2G.calAge(CDate(dRow("birthday"))) & "Ле"
                .Birthday = H2G.AC2BE(CDate(dRow("birthday"))).ToString("dd/MM/yyyy") 'dRow("Birthday").ToString()
                .TitleID = dRow("Title_ID").ToString()
                .Address = dRow("Address").ToString()
                .SubDistrict = dRow("Sub_District").ToString()
                .District = dRow("District").ToString()
                .Province = dRow("Province").ToString()
                .Zipcode = dRow("Zipcode").ToString()
                .CountryID = dRow("Country_ID").ToString()
                .OccupationID = dRow("Occupation_ID").ToString()
                .NationalityID = dRow("Nationality_ID").ToString()
                .RaceID = dRow("Race_ID").ToString()
                .Mobile1 = dRow("Tel_Mobile1").ToString()
                .Mobile2 = dRow("Tel_Mobile2").ToString()
                .HomeTel = dRow("Tel_Home").ToString()
                .OfficeTel = dRow("Tel_Office").ToString()
                .OfficeTelExt = dRow("Tel_Office_Ext").ToString()
                .Email = dRow("Email").ToString()
                .AssociationID = dRow("Association_ID").ToString()
                .RHGroupID = dRow("RH_Group_ID").ToString()
                .VisitNumber = dRow("Visit_Number").ToString()
                .DonateNumber = dRow("Donate_Number").ToString()
                .DonateNumberExt = dRow("Donate_Number_Ext").ToString()
                .FirstVisitDate = dRow("First_Visit_Date").ToString()
                .LastVisitDate = dRow("Last_Visit_Date").ToString()
                .HIIGCode = dRow("HIIG_Code").ToString()
            End With
            Return item
        End Function

    End Class

    Public Class DonationVisitItem
        Public ID As String
        Public DonorID As String
        Public QueueNumber As String
        Public VisitFrom As String
        Public Weight As String
        Public PressureMax As String
        Public PressureMin As String
        Public DonationTypeID As String
        Public BagID As String
        Public DonationToID As String
        Public RefuseDeferralID As String
        Public SampleNumber As String
        Public CollectionPlanID As String
        Public CollectionPointID As String
        Public ForCollectionPointID As String
        Public SiteID As String
        Public Comment As String
        Public VisitNumber As String
        Public HB As String
        Public PLT As String
        Public HBTest As String
        Public HeartLung As String
        Public HeartRate As String
        Public HospitalID As String
        Public DepartmentID As String
        Public ExtSampleNumber As String
        Public ExtComment As String
        Public Volume As String
        Public VolumeActual As String
        Public DonationTime As String
        Public Duration As String
        Public CollectionDate As String
        Public CollectionStaff As String
        Public RefuseReasonID1 As String
        Public RefuseReasonID2 As String
        Public RefuseReasonID3 As String
        Public PurgeDate As String
        Public PurgeStaff As String
        Public Status As String
        Public InterviewStatus As String
        Public VisitDate As String

        Public Shared Function WithCollection(ByVal item As DataItem.DonationVisitItem) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add(":id", DbType.Int64, .ID)
                param.Add(":donor_id", DbType.Int64, .DonorID)
                param.Add(":queue_number", DbType.Int64, .QueueNumber)
                param.Add(":visit_from", DbType.String, .VisitFrom)
                param.Add(":weight", DbType.Decimal, .Weight)
                param.Add(":pressure_max", DbType.Int64, .PressureMax)
                param.Add(":pressure_min", DbType.Int64, .PressureMin)
                param.Add(":donation_type_id", DbType.Int64, IIf(String.IsNullOrEmpty(.DonationTypeID), Nothing, .DonationTypeID))
                param.Add(":bag_id", DbType.Int64, IIf(String.IsNullOrEmpty(.BagID), Nothing, .BagID))
                param.Add(":donation_to_id", DbType.Int64, IIf(String.IsNullOrEmpty(.DonationToID), Nothing, .DonationToID))
                param.Add(":refuse_deferral_id", DbType.Int64, .RefuseDeferralID)
                param.Add(":sample_number", DbType.String, .SampleNumber)
                param.Add(":collection_plan_id", DbType.Int64, IIf(String.IsNullOrEmpty(.CollectionPlanID), Nothing, .CollectionPlanID))
                param.Add(":collection_point_id", DbType.Int64, IIf(String.IsNullOrEmpty(.CollectionPointID), Nothing, .CollectionPointID))
                param.Add(":for_collection_point_id", DbType.Int64, IIf(String.IsNullOrEmpty(.ForCollectionPointID), Nothing, .ForCollectionPointID))
                param.Add(":site_id", DbType.Int64, IIf(String.IsNullOrEmpty(.SiteID), Nothing, .SiteID))
                param.Add(":comment", DbType.String, .Comment)
                param.Add(":visit_number", DbType.Int64, .VisitNumber)
                param.Add(":hb", DbType.Int64, .HB)
                param.Add(":plt", DbType.Int64, .PLT)
                param.Add(":hb_test", DbType.String, .HBTest)
                param.Add(":heart_lung", DbType.String, .HeartLung)
                param.Add(":heart_rate", DbType.Int64, IIf(String.IsNullOrEmpty(.HeartRate), Nothing, .HeartRate))
                param.Add(":hospital_id", DbType.Int64, .HospitalID)
                param.Add(":department_id", DbType.Int64, .DepartmentID)
                param.Add(":ext_sample_number", DbType.String, .ExtSampleNumber)
                param.Add(":ext_comment", DbType.String, .ExtComment)
                param.Add(":volume", DbType.Int64, .Volume)
                param.Add(":volume_actual", DbType.Int64, .VolumeActual)
                param.Add(":donation_time", DbType.Date, .DonationTime)
                param.Add(":duration", DbType.Date, .Duration)
                param.Add(":collection_date", DbType.Date, .CollectionDate)
                param.Add(":collection_staff", DbType.Int64, .CollectionStaff)
                param.Add(":refuse_reason1_id", DbType.Int64, .RefuseReasonID1)
                param.Add(":refuse_reason2_id", DbType.Int64, .RefuseReasonID2)
                param.Add(":refuse_reason3_id", DbType.Int64, .RefuseReasonID3)
                param.Add(":purge_date", DbType.Date, .PurgeDate)
                param.Add(":purge_staff", DbType.Int64, .PurgeStaff)
                param.Add(":status", DbType.String, .Status)
                param.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":interview_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":update_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":interview_status", DbType.String, .InterviewStatus)
                param.Add(":visit_date", DbType.DateTime, H2G.BE2AC(H2G.Convert(Of DateTime)(.VisitDate)).ToString("dd-MM-yyyy HH:mm"))

            End With

            Return param
        End Function

    End Class

    Public Class DonationHospitalItem
        Public ID As String
        Public CreateStaff As String
        Public ReceiptHospitalID As String
        Public OrderNumber As String
        Public DonorID As String
        Public VisitDate As String
        Public DonationToID As String
        Public SiteID As String
        Public CollectionPointID As String
        Public HospitalID As String
        Public DepartmentID As String
        Public LabID As String
        Public Status As String
        Public Remark As String

        Public Shared Function WithCollection(ByVal item As DataItem.DonationHospitalItem) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add(":id", DbType.Int64, .ID)
                param.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":update_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":receipt_hospital_id", DbType.Int64, .ReceiptHospitalID)
                param.Add(":order_number", DbType.Int64, .OrderNumber)
                param.Add(":donor_id", DbType.Int64, .DonorID)
                param.Add(":visit_date", DbType.DateTime, H2G.BE2AC(H2G.Convert(Of DateTime)(.VisitDate)).ToString("dd-MM-yyyy HH:mm"))
                param.Add(":donation_to_id", DbType.Int64, .DonationToID)
                param.Add(":site_id", DbType.Int64, .SiteID)
                param.Add(":collection_point_id", DbType.Int64, .CollectionPointID)
                param.Add(":hospital_id", DbType.Int64, .HospitalID)
                param.Add(":department_id", DbType.Int64, .DepartmentID)
                param.Add(":lab_id", DbType.Int64, .LabID)
                param.Add(":status", DbType.String, .Status)
                param.Add(":remark", DbType.String, .Remark)

            End With
            Return param
        End Function

    End Class

    Public Class DonorExtCardItem
        Public ID As String
        Public DonorID As String
        Public ExternalCardID As String
        Public CardName As String
        Public CardNumber As String

        Public Shared Function WithCollection(ByVal item As DataItem.DonorExtCardItem) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add(":id", DbType.Int64, .ID)
                param.Add(":donor_id", DbType.Int64, .DonorID)
                param.Add(":external_card_id", DbType.Int64, .ExternalCardID)
                param.Add(":card_number", DbType.String, .CardNumber)
            End With
            Return param
        End Function

        Public Shared Function WithItems(ByVal item As DataItem.DonorExtCardItem, ByVal dRow As DataRow) As DataItem.DonorExtCardItem
            With item
                .ID = dRow("id").ToString()
                .DonorID = dRow("donor_id").ToString()
                .ExternalCardID = dRow("external_card_id").ToString()
                .CardNumber = dRow("card_number").ToString()
                .CardName = dRow("description").ToString()
            End With
            Return item
        End Function

    End Class

    Public Class DeferralItem
        Public Code As String
        Public EndDate As String
        Public Description As String
        Public DeferralType As String
        Public Status As String

        Public Shared Function WithItems(ByVal item As DataItem.DeferralItem, ByVal dRow As DataRow) As DataItem.DeferralItem
            With item
                .Code = dRow("deferral_code").ToString()
                .EndDate = dRow("end_date").ToString()
                .Description = dRow("description").ToString()
                .DeferralType = dRow("deferral_type").ToString()
                .Status = dRow("status").ToString()
            End With
            Return item
        End Function

    End Class

    Public Class DonationTypeItem
        Public Code As String
        Public LastDate As String

        Public Shared Function WithItems(ByVal item As DataItem.DonationTypeItem, ByVal dRow As DataRow) As DataItem.DonationTypeItem
            With item
                .Code = dRow("code").ToString()
                .LastDate = dRow("last_date").ToString()
            End With
            Return item
        End Function

    End Class

    Public Class DonorCommentItem
        Public ID As String
        Public DonorID As String
        Public CreateDate As String
        Public CreateStaff As String
        Public StartDate As String
        Public EndDate As String
        Public Description As String

        Public Shared Function WithCollection(ByVal item As DataItem.DonorCommentItem) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add(":id", DbType.Int64, .ID)
                param.Add(":donor_id", DbType.Int64, .DonorID)
                param.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                param.Add(":start_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(.StartDate)).ToString("dd-MM-yyyy HH:mm:ss"))
                param.Add(":end_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(.EndDate)).ToString("dd-MM-yyyy HH:mm:ss"))
                param.Add(":description", DbType.String, .Description)
            End With
            Return param
        End Function

        Public Shared Function WithItems(ByVal item As DataItem.DonorCommentItem, ByVal dRow As DataRow) As DataItem.DonorCommentItem
            With item
                .ID = dRow("id").ToString()
                .DonorID = dRow("donor_id").ToString()
                .CreateStaff = dRow("create_staff").ToString()
                .StartDate = dRow("start_date").ToString()
                .EndDate = dRow("end_date").ToString()
                .Description = dRow("description").ToString()
            End With
            Return item
        End Function

    End Class

    Public Class DTransaction
        Public DonorID As String
        Public DonorNumber As String
        Public Gender As String
        Public Name As String
        Public Surname As String
        Public NameE As String
        Public SurnameE As String
        Public Birthday As String
        Public Age As String
        Public TitleID As String
        Public Address As String
        Public SubDistrict As String
        Public District As String
        Public Province As String
        Public Zipcode As String
        Public CountryID As String
        Public OccupationID As String
        Public NationalityID As String
        Public RaceID As String
        Public Mobile1 As String
        Public Mobile2 As String
        Public HomeTel As String
        Public OfficeTel As String
        Public OfficeTelExt As String
        Public Email As String
        Public AssociationID As String
        Public RHGroup As String
        Public LastVisitDate As String
        Public LastVisitDateText As String
        Public VisitNumber As String
        Public DonateCount As String
        Public CurrentDonateNumber As String
        Public DonateNumber As String
        Public DonateNumberExt As String
        Public DiffDate As String
        '### Donation Visit
        Public VisitID As String
        Public CollectionPlanID As String
        Public CollectionPointID As String
        Public ForCollectionPointID As String
        Public SiteID As String
        Public Status As String
        Public VisitFrom As String
        Public QueueNumber As String
        Public DonationTypeID As String
        Public BagID As String
        Public DonationToID As String
        Public VisitDateTimeText As String
        Public VisitDateText As String
        Public VisitDate As String
        Public Weight As String
        Public PressureMax As String
        Public PressureMin As String
        Public HB As String
        Public PLT As String
        Public HBTest As String
        Public HeartLung As String
        Public HeartRate As String
        Public InterviewStatus As String
        Public SampleNumber As String

        Public LastWeight As String
        Public LastVisit As String

        Public DuplicateTransaction As String

        Public Shared Function WithItems(ByVal item As DataItem.DTransaction, ByVal dRow As DataRow) As DataItem.DTransaction
            With item
                .DonorID = dRow("donor_id").ToString()
                .DonorNumber = dRow("Donor_Number").ToString()
                .Gender = dRow("Gender").ToString()
                .Name = dRow("Name").ToString()
                .Surname = dRow("Surname").ToString()
                .NameE = dRow("Name_E").ToString()
                .SurnameE = dRow("Surname_E").ToString()
                .Age = H2G.calAge(CDate(dRow("birthday"))) & "Ле"
                .Birthday = H2G.AC2BE(CDate(dRow("birthday"))).ToString("dd/MM/yyyy") 'dRow("Birthday").ToString()
                .TitleID = dRow("Title_ID").ToString()
                .Address = dRow("Address").ToString()
                .SubDistrict = dRow("Sub_District").ToString()
                .District = dRow("District").ToString()
                .Province = dRow("Province").ToString()
                .Zipcode = dRow("Zipcode").ToString()
                .CountryID = dRow("Country_ID").ToString()
                .OccupationID = dRow("Occupation_ID").ToString()
                .NationalityID = dRow("Nationality_ID").ToString()
                .RaceID = dRow("Race_ID").ToString()
                .Mobile1 = dRow("Tel_Mobile1").ToString()
                .Mobile2 = dRow("Tel_Mobile2").ToString()
                .HomeTel = dRow("Tel_Home").ToString()
                .OfficeTel = dRow("Tel_Office").ToString()
                .OfficeTelExt = dRow("Tel_Office_Ext").ToString()
                .Email = dRow("Email").ToString()
                .AssociationID = dRow("Association_ID").ToString()
                .RHGroup = dRow("RH_Group_ID").ToString()
                .LastVisitDateText = dRow("Last_Visit_Date_Text").ToString().Replace(",", ":")

                .VisitNumber = dRow("visit_count").ToString()
                .donateCount = dRow("donate_count").ToString()
                .donateNumber = dRow("donate_number").ToString()
                .donateNumberExt = dRow("donate_number_ext").ToString()
                .DiffDate = dRow("diff_date").ToString()
                .CurrentDonateNumber = H2G.Convert(Of Integer)(dRow("donate_count").ToString) + 1

                '### Donation Visit
                .VisitID = dRow("visit_id").ToString()
                .CollectionPlanID = dRow("collection_plan_id").ToString()
                .CollectionPointID = dRow("collection_point_id").ToString()
                .ForCollectionPointID = dRow("for_collection_point_id").ToString()
                .SiteID = dRow("site_id").ToString()
                .Status = dRow("status").ToString()
                .VisitFrom = dRow("visit_from").ToString()
                .QueueNumber = dRow("queue_number").ToString()
                .SampleNumber = dRow("sample_number").ToString()
                .DonationTypeID = dRow("donation_type_id").ToString()
                .BagID = dRow("bag_id").ToString()
                .DonationToID = dRow("donation_to_id").ToString()
                .VisitDateTimeText = dRow("visit_date_time_text").ToString().Replace(",", ":")
                .VisitDateText = dRow("visit_date_text").ToString().Replace(",", ":")
                .VisitDate = dRow("visit_date").ToString().Replace(",", ":")
                .Weight = dRow("weight").ToString().Replace("0", "")
                .PressureMax = dRow("pressure_max").ToString()
                .PressureMin = dRow("pressure_min").ToString()
                .HB = dRow("hb").ToString()
                .PLT = dRow("plt").ToString()
                .HBTest = dRow("hb_test").ToString()
                .HeartLung = dRow("heart_lung").ToString()
                .HeartRate = dRow("heart_rate").ToString()
                .InterviewStatus = dRow("interview_status").ToString()

            End With
            Return item
        End Function

    End Class


End Namespace

