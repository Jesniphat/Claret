﻿'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated by a tool.
'     Runtime Version:4.0.30319.42000
'
'     Changes to this file may cause incorrect behavior and will be lost if
'     the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Option Strict On
Option Explicit On

Imports System

Namespace My.Resources
    
    'This class was auto-generated by the StronglyTypedResourceBuilder
    'class via a tool like ResGen or Visual Studio.
    'To add or remove a member, edit your .ResX file then rerun ResGen
    'with the /str option, or rebuild your VS project.
    '''<summary>
    '''  A strongly-typed resource class, for looking up localized strings, etc.
    '''</summary>
    <Global.System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0"),  _
     Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
     Global.System.Runtime.CompilerServices.CompilerGeneratedAttribute(),  _
     Global.Microsoft.VisualBasic.HideModuleNameAttribute()>  _
    Friend Module Resources
        
        Private resourceMan As Global.System.Resources.ResourceManager
        
        Private resourceCulture As Global.System.Globalization.CultureInfo
        
        '''<summary>
        '''  Returns the cached ResourceManager instance used by this class.
        '''</summary>
        <Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Friend ReadOnly Property ResourceManager() As Global.System.Resources.ResourceManager
            Get
                If Object.ReferenceEquals(resourceMan, Nothing) Then
                    Dim temp As Global.System.Resources.ResourceManager = New Global.System.Resources.ResourceManager("H2GEngine.Resources", GetType(Resources).Assembly)
                    resourceMan = temp
                End If
                Return resourceMan
            End Get
        End Property
        
        '''<summary>
        '''  Overrides the current thread's CurrentUICulture property for all
        '''  resource lookups using this strongly typed resource class.
        '''</summary>
        <Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)>  _
        Friend Property Culture() As Global.System.Globalization.CultureInfo
            Get
                Return resourceCulture
            End Get
            Set
                resourceCulture = value
            End Set
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to --declare = @booking_id bigint = 9705
        '''SELECT COUNT(p.list) total_send, p.status FROM (
        '''SELECT id AS list, status FROM booking_package 
        '''WHERE status IN (&apos;SEND&apos;,&apos;OK&apos;) AND booking_id = @booking_id
        '''UNION ALL SELECT id AS list, status FROM booking_ticket 
        '''WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN (&apos;SEND&apos;,&apos;OK&apos;, &apos;PACKAGE&apos;)  
        '''UNION ALL SELECT id AS list, status FROM booking_hotel 
        '''WHERE booking_id = @booking_id AND booking_package_id IS NULL AND status IN (&apos;SEND&apos;,&apos;OK&apos;, &apos;PACK [rest of string was truncated]&quot;;.
        '''</summary>
        Friend ReadOnly Property Billable_BookingTotalStatus() As String
            Get
                Return ResourceManager.GetString("Billable_BookingTotalStatus", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to --declare @billable_detail_id bigint = 10338
        '''SELECT ISNULL(SUM(pd.cost*p.currency_rate),0) AS cost FROM payment_detail AS pd 
        '''INNER JOIN payment AS p ON p.id = pd.payment_id LEFT JOIN pay_by AS pb ON pb.id = p.pay_by_id  
        '''WHERE booking_billable_detail_id=@billable_detail_id AND pb.description NOT IN(&apos;VOID&apos;).
        '''</summary>
        Friend ReadOnly Property Billable_PaymentDetailCost() As String
            Get
                Return ResourceManager.GetString("Billable_PaymentDetailCost", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to --declare @id Bigint = 11346
        '''SELECT 
        '''(
        ''' CASE WHEN s.id&gt;0 THEN s.name 
        ''' ELSE ISNULL(c.initial_name,&apos;&apos;)+&apos; &apos;+(CASE WHEN ISNULL(c.billing_name, &apos;&apos;)&lt;&gt;&apos;&apos; THEN c.billing_name ELSE c.name END) END
        ''') AS billable_name,
        '''(
        ''' CASE WHEN s.id&gt;0 THEN ISNULL(s.address,&apos;&apos;) ELSE (CASE WHEN ISNULL(c.billing_address, &apos;&apos;)&lt;&gt;&apos;&apos; THEN c.billing_address ELSE c.address END) END
        ''') AS billable_address,
        '''b.sub_agent_id, b.customer_id
        '''FROM booking b
        '''LEFT JOIN sub_agent s ON s.id=b.sub_agent_id LEFT JOIN customer c ON c.id=b.custo [rest of string was truncated]&quot;;.
        '''</summary>
        Friend ReadOnly Property Booking_BillableNameAddress() As String
            Get
                Return ResourceManager.GetString("Booking_BillableNameAddress", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to /*declare IN  bigint = 3360 */
        '''
        '''SELECT * FROM (
        '''/* TICKET */
        '''
        '''SELECT &apos;Ticket&apos; AS product, bp.id as ref_id, bp.supplier_id, ISNULL(bp.booking_package_id,-1) as package_id, bp.status,
        '''ISNULL(bp.ad_cost+bp.ch_cost+bp.inf_cost+bp.ad_tax+bp.ch_tax+bp.inf_tax,0) AS cost,
        '''ISNULL(bp.ad_price+bp.ch_price+bp.inf_price+bp.ad_tax+bp.ch_tax+bp.inf_tax,0) AS price 
        '''FROM booking_ticket AS bp WHERE bp.booking_id = @booking_id
        '''UNION ALL
        '''
        '''/* HOTEL*/
        '''SELECT &apos;Hotel&apos; AS product, bp.id as ref_id, bp.supplier_id, ISNU [rest of string was truncated]&quot;;.
        '''</summary>
        Friend ReadOnly Property Booking_TotalCostTotalPrice() As String
            Get
                Return ResourceManager.GetString("Booking_TotalCostTotalPrice", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to --declare @booking_id bigint = 9705
        '''SELECT SUM(ISNULL(pd.cost,0) * ISNULL(p.currency_rate,1)) AS cost FROM payment_detail AS pd
        '''INNER JOIN payment AS p ON p.id = pd.payment_id
        '''LEFT JOIN pay_by AS pb ON pb.id = p.pay_by_id 
        '''WHERE pd.booking_id=@booking_id AND pb.description NOT IN(&apos;VOID&apos;)
        '''
        '''.
        '''</summary>
        Friend ReadOnly Property Booking_TotalPayment() As String
            Get
                Return ResourceManager.GetString("Booking_TotalPayment", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to server=db2.ns.co.th;database={0};uid={1};pwd={2};.
        '''</summary>
        Friend ReadOnly Property ConnectionB2B() As String
            Get
                Return ResourceManager.GetString("ConnectionB2B", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Provider=Microsoft.ACE.OLEDB.12.0; Data Source=&apos;{0}&apos;; Extended Properties=&apos;Excel 12.0;HDR=Yes;IMEX=1&apos;.
        '''</summary>
        Friend ReadOnly Property ConnectionExcel() As String
            Get
                Return ResourceManager.GetString("ConnectionExcel", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to server=db3.ns.co.th;database={0};uid={1};pwd={2};.
        '''</summary>
        Friend ReadOnly Property ConnectionMBOS() As String
            Get
                Return ResourceManager.GetString("ConnectionMBOS", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST={0})(PORT={1})))(CONNECT_DATA=(SID = HIIGTEST))); User Id={2};Password={3};.
        '''</summary>
        Friend ReadOnly Property ConnectionNEW() As String
            Get
                Return ResourceManager.GetString("ConnectionNEW", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to provider=sqloledb; data source={0}; initial catalog={1}; user id={2}; password={3} connect timeout=30;.
        '''</summary>
        Friend ReadOnly Property ConnectionOLD() As String
            Get
                Return ResourceManager.GetString("ConnectionOLD", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT * FROM (SELECT CASE WHEN i.sub_agent_id = -1 OR ISNULL(i.sub_agent_id,0)=0 THEN 
        '''ISNULL(cus.email,&apos;&apos;) ELSE ISNULL(sa.email,&apos;&apos;) END AS email, &apos;i&apos; doc FROM invoice i
        '''LEFT JOIN customer cus ON i.customer_id = cus.id LEFT JOIN sub_agent sa ON i.sub_agent_id = sa.id 
        '''WHERE i.invoice_no = @no UNION ALL
        '''SELECT CASE WHEN i.sub_agent_id = -1 OR ISNULL(i.sub_agent_id,0)=0 THEN 
        '''ISNULL(cus.email,&apos;&apos;) ELSE ISNULL(sa.email,&apos;&apos;) END AS email, &apos;r&apos; doc FROM receipt i
        '''LEFT JOIN customer cus ON i.customer_id = cus [rest of string was truncated]&quot;;.
        '''</summary>
        Friend ReadOnly Property DefaultCustomerEmail() As String
            Get
                Return ResourceManager.GetString("DefaultCustomerEmail", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT (CASE s.name WHEN &apos;WALK IN&apos; THEN ISNULL(c.tel,&apos;&apos;) ELSE ISNULL(s.tel,&apos;&apos;) END) AS tel FROM invoice i 
        '''LEFT JOIN sub_agent s ON s.id=i.sub_agent_id LEFT JOIN customer c ON c.id=i.customer_id 
        '''WHERE invoice_no=@no UNION ALL
        '''SELECT (CASE s.name WHEN &apos;WALK IN&apos; THEN ISNULL(c.tel,&apos;&apos;) ELSE ISNULL(s.tel,&apos;&apos;) END) AS tel FROM receipt i 
        '''LEFT JOIN sub_agent s ON s.id=i.sub_agent_id LEFT JOIN customer c ON c.id=i.customer_id 
        '''WHERE receipt_no=@no
        '''
        '''.
        '''</summary>
        Friend ReadOnly Property DefaultCustomerSMS() As String
            Get
                Return ResourceManager.GetString("DefaultCustomerSMS", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to INSERT INTO /*[GLOBAL]*/err_message (system_date, company_code, err_msg, err_page) VALUES(GETDATE(), @company_code, @err_msg, @err_page).
        '''</summary>
        Friend ReadOnly Property INSERT_err_message() As String
            Get
                Return ResourceManager.GetString("INSERT_err_message", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to INSERT INTO /*[GLOBAL]*/login_history ([system_date],[comp_code],[user_code],[ip],[mac],[browser],[os],[status],[user_agent]) VALUES(GETDATE(),@com_code,@user_code,@ip,@mac,@browser,@os,@status,@user_agent).
        '''</summary>
        Friend ReadOnly Property INSERT_login_history() As String
            Get
                Return ResourceManager.GetString("INSERT_login_history", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT MIN(id2.id) AS id, id2.invoice_id, MAX(id2.linked_to) AS linked_to, 
        '''id2.booking_billable_detail_id, SUM(id2.price) as price
        '''FROM (
        '''	SELECT invoice_id, booking_billable_detail_id FROM invoice_detail 
        '''	WHERE booking_billable_detail_id in (
        '''		SELECT bd.id FROM invoice_detail AS id
        '''		INNER JOIN booking_billable_detail AS bd ON bd.id = id.booking_billable_detail_id
        '''		WHERE id.linked_record=&apos;N&apos; /*PRODUCT_ID*/
        '''	)
        ''') AS id1 
        '''LEFT JOIN invoice_detail AS id2 
        '''ON id1.booking_billable_detail_id= id2.b [rest of string was truncated]&quot;;.
        '''</summary>
        Friend ReadOnly Property Invoice_ListUpdateCost() As String
            Get
                Return ResourceManager.GetString("Invoice_ListUpdateCost", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 {0} FROM start_number WHERE [year]=&apos;{1}&apos; AND ([month]=&apos;&apos; OR [month]=&apos;{2}&apos;) ORDER BY [month] DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_BeginNo() As String
            Get
                Return ResourceManager.GetString("ITEM_BeginNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 invoice_no FROM invoice WHERE invoice_no LIKE &apos;{0}%&apos; and invoice_type =&apos;{1}&apos; ORDER BY invoice_no DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_GetLastInvoiceNo() As String
            Get
                Return ResourceManager.GetString("ITEM_GetLastInvoiceNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 payment_no FROM payment WHERE payment_no LIKE &apos;{0}%&apos; ORDER BY payment_no DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_GetLastPaymentNo() As String
            Get
                Return ResourceManager.GetString("ITEM_GetLastPaymentNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 receipt_no FROM receipt WHERE receipt_no LIKE &apos;{0}%&apos; and receipt_type =&apos;{1}&apos; ORDER BY receipt_no DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_GetLastReceiptNo() As String
            Get
                Return ResourceManager.GetString("ITEM_GetLastReceiptNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 tax_no FROM tax_airline WHERE tax_no LIKE &apos;{0}%&apos; ORDER BY tax_no DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_GetLastTaxAirlineNo() As String
            Get
                Return ResourceManager.GetString("ITEM_GetLastTaxAirlineNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 tax_no FROM tax WHERE tax_no LIKE &apos;{0}%&apos; ORDER BY tax_no DESC.
        '''</summary>
        Friend ReadOnly Property ITEM_GetLastTaxNo() As String
            Get
                Return ResourceManager.GetString("ITEM_GetLastTaxNo", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT SUM(receipt_amount) FROM view_amount_inv2rec WHERE receipt_status NOT IN(&apos;VOID&apos;,&apos;WAIT&apos;)  AND booking_id = @booking_id.
        '''</summary>
        Friend ReadOnly Property Receipt_TotalPrice() As String
            Get
                Return ResourceManager.GetString("Receipt_TotalPrice", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT bd.id FROM booking_billable_detail bd 
        '''INNER JOIN booking_billable bb ON bb.id = bd.booking_billable_id
        '''WHERE bd.{0}.
        '''</summary>
        Friend ReadOnly Property SELECT_BillableDetail() As String
            Get
                Return ResourceManager.GetString("SELECT_BillableDetail", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT (cost*currency_rate) AS cost FROM booking_billable_detail {0} AND status NOT IN(&apos;CANCEL&apos;).
        '''</summary>
        Friend ReadOnly Property SELECT_BillableTotalCost() As String
            Get
                Return ResourceManager.GetString("SELECT_BillableTotalCost", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT TOP 1 sms_user_id, sms_user, sms_password, sms_default_number FROM /*[GLOBAL]*/initial.
        '''</summary>
        Friend ReadOnly Property SELECT_InitialSMS() As String
            Get
                Return ResourceManager.GetString("SELECT_InitialSMS", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT &apos;#&apos; + CONVERT(VARCHAR,ISNULL(permission_id,&apos;&apos;)) FROM staff_permission WHERE staff_id=@staff_id  FOR XML PATH(&apos;&apos;).
        '''</summary>
        Friend ReadOnly Property SELECT_permission() As String
            Get
                Return ResourceManager.GetString("SELECT_permission", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT id FROM /*[GLOBAL]*/permission WHERE index_name=&apos;{0}&apos;.
        '''</summary>
        Friend ReadOnly Property SELECT_permission_id() As String
            Get
                Return ResourceManager.GetString("SELECT_permission_id", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to SELECT code, database_name FROM travox_global.travoxmos.site_customer WHERE [status]=&apos;ACTIVE&apos; OR status_hotel=&apos;ACTIVE&apos;.
        '''</summary>
        Friend ReadOnly Property SELECT_SiteCustomer() As String
            Get
                Return ResourceManager.GetString("SELECT_SiteCustomer", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to WITH LimitRow AS ( SELECT ROW_NUMBER() OVER(ORDER BY tb./*_NAME_*/ /*_ORDER_*/) AS row, * FROM (/*_SQL_QUERY_*/) tb ) 
        '''SELECT * FROM LimitRow WHERE row BETWEEN @start AND @finish ORDER BY row ASC.
        '''</summary>
        Friend ReadOnly Property SELECT_UI_AutoComplate() As String
            Get
                Return ResourceManager.GetString("SELECT_UI_AutoComplate", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to INSERT INTO sys_session.login (created_date, expired_date, username, session_id, ipv4_address)
        '''VALUES(@created @expired, @user_code, @sessionid, @ip).
        '''</summary>
        Friend ReadOnly Property SysSession_Login() As String
            Get
                Return ResourceManager.GetString("SysSession_Login", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to UPDATE invoice_detail SET cost=@cost,price=@price,display_price=@price WHERE id=@id.
        '''</summary>
        Friend ReadOnly Property UPDATE_InvoiceDetail() As String
            Get
                Return ResourceManager.GetString("UPDATE_InvoiceDetail", resourceCulture)
            End Get
        End Property
        
        '''<summary>
        '''  Looks up a localized string similar to UPDATE receipt_detail SET cost=@cost,price=@price,receipt_amt=@price,receipt_amt1=@price WHERE id=@id.
        '''</summary>
        Friend ReadOnly Property UPDATE_ReceiptDetail() As String
            Get
                Return ResourceManager.GetString("UPDATE_ReceiptDetail", resourceCulture)
            End Get
        End Property
    End Module
End Namespace
