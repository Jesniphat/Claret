Namespace Booking
    Public Class Products
        Inherits Item
        Private TypeBooking As BookingType = BookingType.Normal
        Private IDBooking As Integer
        Private Package As New Bind


        Public ReadOnly Property IsRollUpPackage()
            Get
                Me.BindOnPackage()
                Return Package.RollUp And Package.ID <> -1
            End Get
        End Property

        Public ReadOnly Property GetPackageID()
            Get
                Return Package.ID
            End Get
        End Property

        Friend Structure Bind
            Public ID As Integer
            Public RollUp As Boolean
        End Structure

        Public Sub New(ByVal ItemType As ItemType, ByVal booking_id As Integer, ByVal id As Integer)
            CurrentItem = ItemType
            IDBooking = booking_id
            IDItem = id
        End Sub

        Public Sub UpdatePackageRollUpCost()
            If (IsRollUpPackage) Then
                Dim SyncConnected As Boolean = Sync.Connected
                If (Not SyncConnected) Then Sync = New DBQuery()
                Dim param As New SQLCollection("@package_id", DbType.Int32, Package.ID)

                ' All Package same package name.
                For Each drPackage As DataRow In Sync.QueryTable("SQL::Package_TotalCostPrice", param).Rows
                    param = New SQLCollection("@package_id", DbType.Int32, drPackage("id"))
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
                        MyBase.SyncApply(SyncConnected)
                    Catch ex As Exception
                        MyBase.SyncApply(SyncConnected)
                        Throw New Exception("PackageCostCalulator Method :: " & ex.Message)
                    End Try
                Next
            End If
        End Sub

        Public Function GetCostProduct() As Decimal
            Return ItemCostTotal(IDBooking)
        End Function

        Public Function EnabledSupplier() As Boolean
            Return Me.ChangeSupplierWithPayment()
        End Function

        Private Sub BindOnPackage()
            Package.ID = -1
            If (CurrentItem <> ItemType.Package) Then
                Dim SyncConnected As Boolean = Sync.Connected
                If (Not SyncConnected) Then Sync = New DBQuery()
                Package.ID = Sync.QueryField(String.Format("SELECT ISNULL(booking_package_id,-1) AS package_id FROM {0} WHERE id={1}", GetTableName(), IDItem))
                Package.RollUp = H2G.Bool(Sync.QueryField(String.Format("SELECT rollup_cost FROM booking_package WHERE id={0}", Package.ID)))
            Else
                Package.ID = IDItem
            End If
        End Sub

    End Class
End Namespace
