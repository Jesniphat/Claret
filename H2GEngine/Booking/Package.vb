Namespace Booking
    Public Class Package
        Inherits Item
        Private IDBooking As Integer = -1
        Private IDPackage As Integer = -1
        Private IDProduct As Integer = -1

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDBooking = booking_id
            IDPackage = id
            CurrentItem = ItemType.Package
        End Sub

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer, ByVal table_name As ItemType)
            IDBooking = booking_id
            IDProduct = id
            CurrentItem = table_name
        End Sub

        Public Function EnabledSupplier() As Boolean
            IDItem = IDPackage
            Return Me.ChangeSupplierWithPayment()
        End Function

        REM :: ROLLUP COST PACKAGE
        Public Sub UpdatePackageRollUpCost()
            If (Me.CheckPackageCostRollup() And IDPackage <> -1) Then Me.RunCostInPackage()
        End Sub

        Public Function CheckInPackageAndRollUp() As Boolean
            Dim result As Boolean = False
            If (Me.CheckPackageCostRollup() And IDPackage <> -1) Then result = True
            Return result
        End Function

        Public Function GetCostBindPackageORCostProduct() As Decimal
            Return CostBindPackageORCostProduct(IDBooking, IDProduct)
        End Function

        Private Sub RunCostInPackage()
            If (Not Sync.Connected) Then Sync = New DBQuery()
            Dim param As New SQLCollection("@package_id", DbType.Int32, Me.PackageID().ToString)
            ' All Package same package name.
            For Each drRows As DataRow In Sync.QueryTable("SQL::Package_TotalCostPrice", param).Rows
                Me.PackageCostCalulator(drRows("id"))
            Next
        End Sub

        Public Function CheckPackageCostRollup() As Boolean
            If (Not Sync.Connected) Then Sync = New DBQuery()
            Dim rollup As String = Sync.QueryField(String.Format("SELECT rollup_cost FROM booking_package WHERE id={0}", Me.PackageID()))
            Return H2G.Bool(rollup)
        End Function

        Public Function PackageID() As Integer
            If (Not Sync.Connected) Then Sync = New DBQuery()
            If (IDProduct <> -1) Then
                Dim query As String = String.Format("SELECT ISNULL(booking_package_id,0) AS package_id FROM {0} WHERE id={1}", GetTableName(), IDProduct)
                IDPackage = Sync.QueryField(query)
            End If
            Return IDPackage
        End Function


        Private Sub PackageCostCalulator(ByVal getIDPackage As String)
            If (Not Sync.Connected) Then Sync = New DBQuery()
            Dim param As New ParameterCollection()
            param.Add("@package_id", DbType.Int32, getIDPackage)

            Dim NEWCost As Decimal = H2G.Convert(Of Decimal)(Sync.QueryField("SQL::Package_CostInBooking", param))
            Dim LastPackage As Integer = 0
            Dim LastCost As Decimal = 0
            Try
                For Each drRows As DataRow In Sync.QueryTable("SQL::Package_TotalCostPrice", param).Rows
                    LastPackage = Integer.Parse(drRows("id"))
                    LastCost = Decimal.Parse(drRows("price"))
                    If (NEWCost > Decimal.Parse(drRows("price"))) Then
                        NEWCost -= Decimal.Parse(drRows("price"))
                        Sync.Execute(String.Format("UPDATE booking_package SET cost={0} WHERE id={1}", drRows("price"), drRows("id")))
                    Else
                        Sync.Execute(String.Format("UPDATE booking_package SET cost={0} WHERE id={1}", NEWCost, drRows("id")))
                        NEWCost = 0
                    End If
                Next
                If (NEWCost > 0) Then Sync.Execute(String.Format("UPDATE booking_package SET cost={0} WHERE id={1}", (LastCost + NEWCost), LastPackage))
                MyBase.SyncApply(Sync.Connected)
            Catch ex As Exception
                MyBase.SyncApply(Sync.Connected)
                Throw New Exception("PackageCostCalulator Method :: " & ex.Message)
            End Try
        End Sub

    End Class
End Namespace
