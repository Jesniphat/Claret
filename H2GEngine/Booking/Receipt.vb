Namespace Booking
    Public Class Receipt
        Inherits Item

        Public Sub New()
            CurrentItem = ItemType.Receipt
        End Sub

        Public Function NextReceiptNo(ByVal receipt_date As String, ByVal receipt_type As String) As String
            Dim _type As ItemStatus
            Select Case receipt_type
                Case "VAT" : _type = ItemStatus.VAT
                Case "TEMP" : _type = ItemStatus.TEMP
            End Select
            Return Me.NextNO(receipt_date, _type)
        End Function

        Public Shared Sub UpdateCost(ByVal new_cost As Decimal, ByVal column_name As String, ByVal product_id As String)
            REM: Update cost with Receipt issued more than one card ' Query Invoice with Group By and SUM(price) with Commission .
            Dim base As New DBQuery()
            Dim param As New ParameterCollection()
            param.Add("PRODUCT_ID", DbType.String, String.Format("AND {0}={1}", column_name, product_id))
            Try
                Dim Receipt_Commission As DataTable = base.QueryTable("SQL::Receipt_ListUpdateCost", param)

                Dim CostForCheckWithPrice As Decimal = new_cost
                Dim InvoicetoReceiptPrice As Decimal = 0
                Dim CurrentRow As Integer = 1
                For Each drLinked As DataRow In Receipt_Commission.Rows
                    If (drLinked("price") > 0) Then InvoicetoReceiptPrice = drLinked("price")

                    Dim ReceiptAmount As Decimal = drLinked("amount1")
                    Dim PriceCommission As Decimal = 0

                    If (CostForCheckWithPrice <= drLinked("amount1") And CostForCheckWithPrice > 0) Then
                        ReceiptAmount = CostForCheckWithPrice
                        PriceCommission = drLinked("amount1") - CostForCheckWithPrice
                    ElseIf (CostForCheckWithPrice <= 0) Then
                        ReceiptAmount = 0
                        PriceCommission = drLinked("amount1")
                    ElseIf (Receipt_Commission.Rows.Count() = CurrentRow And (CostForCheckWithPrice - ReceiptAmount) <= 0) Then
                        ' If ((CostForCheckWithPrice - ReceiptAmount) > 0) Then ' Receipt ‰¡Ë‡µÁ¡„∫
                        ReceiptAmount = (ReceiptAmount + CostForCheckWithPrice)
                        If (ReceiptAmount <= 0) Then ReceiptAmount = 0
                    ElseIf (Receipt_Commission.Rows.Count() = 1) Then
                        ReceiptAmount = new_cost
                        PriceCommission = 0
                    End If

                    If (Not String.IsNullOrEmpty(drLinked("linked_to").ToString())) Then
                        ' Update Cost Product
                        param.Clear()
                        param.Add("@id", DbType.String, drLinked("id").ToString())
                        param.Add("@cost", DbType.Decimal, ReceiptAmount.ToString())
                        param.Add("@price", DbType.Decimal, ReceiptAmount.ToString())
                        base.Execute(My.Resources.UPDATE_ReceiptDetail, param)

                        ' Update Cost Commision
                        param.Clear()
                        param.Add("@id", DbType.String, drLinked("linked_to").ToString())
                        param.Add("@cost", DbType.Decimal, "0")
                        param.Add("@price", DbType.Decimal, PriceCommission.ToString())
                        base.Execute(My.Resources.UPDATE_ReceiptDetail, param)

                        ' Finnish Row in Commission
                        If (Receipt_Commission.Rows.Count() = CurrentRow) Then
                            Dim query As String = String.Format("SELECT price FROM booking_billable_detail WHERE id={0}", drLinked("booking_billable_detail_id"))
                            Dim dtDetail As DataTable = base.QueryTable(query)

                            param.Item("@id").DefaultValue = drLinked("linked_to").ToString()
                            param.Item("@cost").DefaultValue = "0"
                            param.Item("@price").DefaultValue = dtDetail.Rows(0)("price") - new_cost
                            base.Execute(My.Resources.UPDATE_ReceiptDetail, param)
                        End If
                    Else
                        ' Update Cost Product
                        param.Clear()
                        param.Add("@id", DbType.String, drLinked("id").ToString())
                        param.Add("@cost", DbType.Decimal, ReceiptAmount.ToString())
                        param.Add("@price", DbType.Decimal, drLinked("amount1").ToString())
                        base.Execute(My.Resources.UPDATE_ReceiptDetail, param)
                    End If
                    CostForCheckWithPrice -= drLinked("amount1")
                    CurrentRow += 1
                Next
                base.Apply()
            Catch ex As Exception
                base.Rollback()
                Throw New Exception("Receipt.UpdateCost Method :: " & ex.Message)
            End Try
        End Sub
    End Class
End Namespace
