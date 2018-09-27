<%@ Page Language="VB" EnableEventValidation="true"%>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Threading" %>

<!DOCTYPE html>

<script runat="server">
    Dim winHTTP As Object

    Private Sub DoWINHTTPLogin()
        'Set PADIrs = CurrentDb.OpenRecordset("SELECT CountryID, Address1, Address2, City, PostalCode, StateID, PADIStatus, gp.PADICourseName As CourseName, gp.PADICourseNum AS DropDownCourseNum, p.PADICourseNum As CertifyCourseNum, Birthdate, Email, FirstName, LastName, Gender, PADImid, Customer.StudentID, CourseType, Course.CourseTypeID from Course, CourseType, RAIDSelected, Customer, PADICourseType p, PADICourseType gp WHERE CourseType.PADICOurseTypeID = p.PADICourseTypeID AND p.PADICourseAssignID = gp.PADICourseTypeID AND Customer.StudentID = Course.StudentID AND RAIDSelected.CourseID = Course.CourseID and Course.CourseTypeID = CourseType.CourseTypeID")

        Session("statustext") = "Initializing..." + System.Environment.NewLine
        Dim UserName As String = "info@saireecottagediving.com"
        Dim Password As String = "scdpadicerts"

        'Create Login JSONString
        Dim LogInDict As New Dictionary(Of String, Object)
        With LogInDict
            .Item("UserName") = UserName
            .Item("Password") = Password
            .Item("ApplicationID") = 48
            .Item("redirectURI") = "home-pros.aspx"
        End With

        Dim jsonobj As String = Newtonsoft.Json.JsonConvert.SerializeObject(LogInDict)
        '  Dim cnvjson As String = Replace(jsonobj, "'", "/")
        Dim Model As New Dictionary(Of String, Object)
        Model.Item("Model") = jsonobj
        Dim modelObj As String = Newtonsoft.Json.JsonConvert.SerializeObject(Model)

        'LogIn to PADI
        WinHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")

        Session("statustext") = "Logging Into PADI..." + System.Environment.NewLine
        winHTTP.Open("Get", "https://www2.padi.com/mypadi", False)
        winHTTP.send

        winHTTP.Open("Post", "https://www2.padi.com/mypadi/default.aspx/Login", False)
        SetWINHTTPHeadersJSON()
        winHTTP.send(modelObj)
        winHTTP.Open("Get", "https://www2.padi.com/mypadi/home-pros.aspx", False)
        winHTTP.send
    End Sub

    Private Sub SetWINHTTPHeadersJSON()
        winHTTP.setRequestHeader("Content-type", " application/json; charset=utf-8")
        winHTTP.setRequestHeader("Accept", "application/json, text/javascript, */*; q=0.01")
        winHTTP.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko)")
        winHTTP.setRequestHeader("Accept-Language", "en-US")
        winHTTP.setRequestHeader("Connection", "Keep-Alive")
        winHTTP.setRequestHeader("Cache-Control", "no-cache")
        winHTTP.setRequestHeader("X-Requested-With", "XMLHttpRequest")
        winHTTP.setRequestHeader("Accept-Encoding", "gzip, deflate")
    End Sub

    Private Sub SetWINHTTPHeadersURLencoded()
        winHTTP.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
        winHTTP.setRequestHeader("Accept", "text/html, application/xhtml+xml, image/jxr, */*")
        winHTTP.setRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko)")
        winHTTP.setRequestHeader("Accept-Language", "en-US")
        winHTTP.setRequestHeader("Connection", "Keep-Alive")
        winHTTP.setRequestHeader("Cache-Control", "no-cache")
        winHTTP.setRequestHeader("Accept-Encoding", "gzip, deflate")
    End Sub

    Private Sub WinHTTPPicHome()

        'Go To PIC page
        Session("statustext") = "Going to PIC page..." + System.Environment.NewLine
        winHTTP.Open("Get", "https://www2.padi.com/mypadi/pros/app-old-pros/pic-online", False)
        winHTTP.send

        winHTTP.Open("Get", "https://apps.padi.com/Pros/PICOnline/Account/RedirectMain2", False)
        winHTTP.send
    End Sub



    Private Sub WINHTTPGetPicCount()
        '        Dim rdt As DataTable = GetDataTable("SELECT PADIManualName FROM PADIManual, DiveClass WHERE PADIManual.PADIManualID = DiveClass.PADIManualID AND DiveClassID = " + CStr(Me.cmbDiveClass.SelectedValue))

        '    Dim CurrentCourse As String = rdt(0)(0)


        Dim PicsNeeded As Integer = 3
        '        For i = 0 To rdt.Rows.Count - 1
        '        If PADIrs!StudentStatusID = 1 Then
        '        PicsNeeded = PicsNeeded + 1
        '        End If
        '        PADIrs.MoveNext
        '        Next i


        'Go To ALL Available Codes
        Session("statustext") = "Getting Available Codes..." + System.Environment.NewLine
        winHTTP.Open("Post", "https://apps.padi.com/Pros/PICOnline/CodeManagement/ShowAvailableView?Length=22", False)
        SetWINHTTPHeadersURLencoded
        winHTTP.send

        winHTTP.Open("Post", "https://apps.padi.com/Pros/PICOnline/CodeManagement/GetAvailableCodes", False)
        SetWINHTTPHeadersURLencoded()

        'Create String with PIC registration parameters
        Dim availStr As String = "courseFilterId=-1&productTypeFilterId=-1&statusFilterId=0&purchaseDateFilterId=-1&_search=false&nd=1509687532543&rows=500&page=1&sidx=&sord=asc"

        winHTTP.send(availStr)

        Session("statustext") = "Processing Pics..." + System.Environment.NewLine
        'Get Available PIC codes
        Dim tStr As String = winHTTP.responseText

        '        MsgBox(tStr)
        'Pic Counter
        Dim PicCounts As String = ""
        '        LowCounts = ""


        Dim CourseName As String = Me.cmbPADIManual.SelectedItem.Text
        Dim Sstr As String = "title=" & Chr(34) & CourseName
        Dim mypos As Integer = InStr(1, tStr, CourseName)
        Dim Counter As Integer = (Len(tStr) - Len(Replace(tStr, CourseName, ""))) / Len(CourseName)
        If Counter <> 0 Then
            PicCounts = PicCounts & Chr(13) & Chr(10) & CourseName & "=" & Counter
        End If

        MsgBox(PicCounts, , "Pic Counts")
        '   If CourseName = CurrentCourse Then
        '    CurrentCourseCount = Counter
        '    End If



        'If Came from Assign SUb, Check to see if enough PICS FOr COurse, send email if counts low
        '   If (PicsNeeded > CurrentCourseCount) Then
        '   SetMsg = "Not Enough " & CurrentCourse & " PICs Available!" & Chr(13) & Chr(10) & CurrentCourseCount & " " & CurrentCourse & " PICs Left!"
        '   mailmsg = PicCounts & Chr(13) & Chr(10) & "No Other PICs Available" & Chr(13) & Chr(10) & "Time to Order More PICs!"
        '  SendEmail (mailmsg)
        '        MsgBox SetMsg, vbOKOnly, "Not Enough PICs!"
        ' End
        '     End If

        '       MsgBox "Current Course Count for " + CourseName + ": " + CStr(CurrentCourseCount)

    End Sub

    Private Function GetDataTable(sqlstr As String) As DataTable
        Dim vcon As System.Data.OleDb.OleDbConnection = New System.Data.OleDb.OleDbConnection(ConfigurationManager.ConnectionStrings("ConnectionString").ConnectionString)
        Dim da As System.Data.OleDb.OleDbDataAdapter = New System.Data.OleDb.OleDbDataAdapter(sqlstr, vcon)
        Dim dt As DataTable = New DataTable()
        da.Fill(dt)
        Return dt
    End Function

    Private Function GetSingleSqlValue(sqlstr As String) As String

        Dim vcon As System.Data.OleDb.OleDbConnection = New System.Data.OleDb.OleDbConnection(ConfigurationManager.ConnectionStrings("ConnectionString").ConnectionString)
        Dim da As System.Data.OleDb.OleDbDataAdapter = New System.Data.OleDb.OleDbDataAdapter(sqlstr, vcon)
        Dim dt As DataTable = New DataTable()
        da.Fill(dt)
        GetSingleSqlValue = dt.Rows(0)(0)
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        '    cmbDiveClass.DataBind()
        '    AddStudentsDataSource.DataBind() 'checks database connection string and handles error if there is one
        '    GVAddStudents.DataBind()
    End Sub





    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If (Not Page.IsPostBack) Then
            cmbInstructor.DataBind()
            cmbDiveClass.DataBind()
            GVMainGrid.DataBind()
            AddStudentsDataSource.DataBind() 'checks database connection string and handles error if there is one
            GVAddStudents.DataBind()

        End If

        'checks user is authenticated to view the image and if so, does the binarywrite
    End Sub

    'Called when a button in the main grid is pressed.  Details or remove.
    Protected Sub GVMainGrid_OnRowCommand(sender As Object, e As GridViewCommandEventArgs)
        If (e.CommandName = "Details") Then                 'Details button pressed
            FVStudentEdit.ChangeMode(FormViewMode.ReadOnly) 'Start with read only mode
            EditStudentPUE.Show()                           'Show Student edit pop-up
            Dim ID As Integer = Convert.ToInt32(e.CommandArgument) 'SelectedStudentID keeps track of which student it is
            txtSelectedStudentID.Text = ID.ToString()
        ElseIf (e.CommandName = "Remove") Then          ' remove button pressed
            RemoveFromActiveStudentDataSource.DeleteParameters(0).DefaultValue = e.CommandArgument.ToString() 'Set parameter to activestudent ID
            RemoveFromActiveStudentDataSource.Delete()
            GVMainGrid.DataBind()           'reset grids appropriately
            GVAddStudents.DataBind()
        End If
    End Sub

    'Called from the add students popup.  Inserts a Student into ActiveStudent for this dive class
    Protected Sub AddStudents_OnRowCommand(sender As Object, e As GridViewCommandEventArgs)
        If (e.CommandName = "Add") Then
            InsertIntoActiveStudentDataSource.InsertParameters.Add("StudentID", e.CommandArgument.ToString())
            InsertIntoActiveStudentDataSource.InsertParameters.Add("DiveClassID", cmbDiveClass.SelectedValue.ToString())
            InsertIntoActiveStudentDataSource.InsertParameters.Add("PADIManualID", cmbPADIManual.SelectedValue.ToString())
            InsertIntoActiveStudentDataSource.Insert()
            MainGridDataSource.DataBind()  'refresh both the main grids and the add students pop up
            AddStudentsDataSource.DataBind()
            GVAddStudents.DataBind()
            SetMainGridVisible(True)  'Will pop up grid if there are now students.  
        End If

    End Sub

    'Called when user hits 'edit info' from student detail popup
    Protected Sub btnEditStudentInfo_Click(sender As Object, e As EventArgs)
        FVStudentEdit.ChangeMode(FormViewMode.Edit)
        EditStudentPUE.Show()
    End Sub


    'Updates State dropdown when country dropdown is called
    Protected Sub cmbCountry_DataBound(sender As Object, e As EventArgs)
        FVStudentEdit.FindControl("cmbState").DataBind()
    End Sub


    'Assign Student Button is clicked
    Protected Sub btnAssign_Click(sender As Object, e As EventArgs)
        Dim RowsChecked As Boolean = False

        'First Check that at least one row is checked.  Otherwise, do nothing.
        For Each row As GridViewRow In GVMainGrid.Rows
            If (row.RowType = DataControlRowType.DataRow) Then
                Dim chkRow As CheckBox = row.Cells(0).FindControl("chkRow")
                If (chkRow.Checked) Then
                    RowsChecked = True
                    Exit For
                End If
            End If
        Next

        ' Rows are checked
        If (RowsChecked) Then
            Session("inProcess") = True
            Session("statustext") = ""
            Session("processComplete") = False
            TxtStatus.Text = "Working..."
            PanelDynamicUpdate.Visible = True
            'Start the Timer which will refresh the grid periodically
            Timer1.Enabled = True

            'Start a new thread to assign students
            Dim workerThread As Thread = New Thread(AddressOf AssignStudents)
            workerThread.Start()
            '     Do While (Session("processComplete") = False)
            '     TxtStatus.Text = Session("statustext")
            '     GVMainGrid.DataBind()
            '     BigPanel.Update()
            '     Thread.Sleep(1000)
            '     Loop
        End If
    End Sub

    Protected Sub AssignStudents()
        'Go through each row
        For Each row As GridViewRow In GVMainGrid.Rows
            If (row.RowType = DataControlRowType.DataRow) Then
                Dim chkRow As CheckBox = row.Cells(0).FindControl("chkRow")
                If (chkRow.Checked) Then
                    Dim ActiveStatusIDField As HiddenField = row.Cells(1).FindControl("HiddenField1")

                    'Set Status to Assignining
                    UpdateStudentStatusDataSource.UpdateParameters("ActiveStudentID").DefaultValue = ActiveStatusIDField.Value
                    UpdateStudentStatusDataSource.UpdateParameters("StudentStatusID").DefaultValue = "2"
                    UpdateStudentStatusDataSource.Update()

                    'Update activity log
                    Session("statustext") = "Assigning: " + row.Cells(2).Text + " " + row.Cells(3).Text + System.Environment.NewLine

                    'Adri, replace this line with your code.
                    'PS, you're cute.
                    System.Threading.Thread.Sleep(3000)

                    'Set status to Assigned
                    UpdateStudentStatusDataSource.UpdateParameters("StudentStatusID").DefaultValue = "3"
                    Session("statustext") = "Assigned: " + row.Cells(2).Text + " " + row.Cells(3).Text + System.Environment.NewLine
                    UpdateStudentStatusDataSource.Update()
                End If

            End If
        Next
        'Tells the timer to stop
        ' TxtStatus.Text = Session("statustext")
        ' GVMainGrid.DataBind()
        Session("processComplete") = True
    End Sub



    'Called Before the Grid is drawn
    Protected Sub GVMainGrid_PreRender(sender As Object, e As EventArgs)
        'Only show the Cert Dropdown if there is at least one student that has been assigned a manual 
        Dim stdCount As String = GetSingleSqlValue("select Count (*) from ACtiveStudent Where StudentStatusId > 2 and  DiveClassID=" + cmbDiveClass.SelectedValue)
        If (stdCount = "0") Then     ' if no students have a manual yet
            GVMainGrid.Columns(5).Visible = False  ' hide the padi cert dropdown
        Else
            GVMainGrid.Columns(5).Visible = True
        End If
    End Sub

    'Started when user clicks assign students
    'refreshes grid and activity log every second
    Protected Sub Timer1_Tick(sender As Object, e As EventArgs)

        'If still talking with PADI
        If (Session("inProcess")) Then
            'Update the grid and the activity log
            TxtStatus.Text = Session("statustext")
            GVMainGrid.DataBind()
        End If
        If (Session("processComplete") = True) Then 'has Then final message been Set?

            Session("inProcess") = False  'stop the timer
            Timer1.Enabled = False
            PanelDynamicUpdate.Visible = False
        End If
    End Sub

    'User picks a new dive class
    Protected Sub cmbDiveClass_SelectedIndexChanged(sender As Object, e As EventArgs)

        'Update all the grids
        MainGridDataSource.DataBind()
        GVMainGrid.DataBind()
        GVAddStudents.DataBind()

        'Get the ManualID 
        Dim PadiManualID As String = GetSingleSqlValue("select PADIManualID from DiveClass WHERE DiveClassID=" + cmbDiveClass.SelectedValue)

        'Set the Manual Drop down and update the grids
        cmbPADIManual.SelectedValue = PadiManualID
        cmbPADIManual.DataBind()
        PADICertDataSource.DataBind()
        GVMainGrid.DataBind()
        SetMainGridVisible((GVMainGrid.Rows.Count <> 0))

    End Sub

    'Switches between the Main Grid being visible or a message saying to add students
    Protected Sub SetMainGridVisible(vis As Boolean)
        GVMainGrid.Visible = vis
        lblNoStudents.Visible = Not vis
    End Sub

    'Called from the Add new Class Dropdown.  Creates a new DiveClass 
    Protected Sub BtnSave_Click(sender As Object, e As EventArgs)
        If (Page.IsValid) Then
            'Inserts the DiveClassName and Manual selected in the Add New Class pop up.  And uses current InstructorID
            InsertDiveClassDataSource.InsertParameters.Add("DiveClassName", txtClassName.Text)
            InsertDiveClassDataSource.InsertParameters.Add("PADIManualID", cmbManual.SelectedValue.ToString())
            InsertDiveClassDataSource.InsertParameters.Add("InstructorID", cmbInstructor.SelectedValue.ToString())
            InsertDiveClassDataSource.Insert()

            'Update the grids
            cmbDiveClass.DataBind()
            SetMainGridVisible(False)
        Else
            NewClassPUE.Show()  ' this just makes sure the popup stays up
        End If
    End Sub


    'Change the default name of the course based on the date
    Protected Sub txtFinishDate_TextChanged(sender As Object, e As EventArgs)
        txtClassName.Text = cmbManual.SelectedItem.Text + " " + txtFinishDate.Text
    End Sub

    'Instructor Drop down changes.  just used for testing for now.
    Protected Sub cmbInstructor_SelectedIndexChanged(sender As Object, e As EventArgs)
        DiveClassDataSource.DataBind()
        cmbDiveClass.DataBind()
        cmbDiveClass_SelectedIndexChanged(sender, e)
        GVAddStudents.DataBind()
    End Sub

    Protected Sub GetPicCount()
        DoWINHTTPLogin()
        WinHTTPPicHome()
        WINHTTPGetPicCount()
        Session("statustext") += "Pic Count Complete" + System.Environment.NewLine
        Session("processComplete") = True
    End Sub

    Protected Sub btnPicCheck_Click(sender As Object, e As EventArgs)
        Session("inProcess") = True
        Session("statustext") = ""
        Session("processComplete") = False
        TxtStatus.Text = "Working..."
        PanelDynamicUpdate.Visible = True

        'Start the Timer which will refresh the grid periodically
        Timer1.Enabled = True

        'Start a new thread to assign students
        Dim workerThread As Thread = New Thread(AddressOf GetPicCount)
        workerThread.Start()
    End Sub

    Protected Sub btnAddStudents_Click(sender As Object, e As EventArgs)
        AddStudentsDataSource.DataBind() 'checks database connection string and handles error if there is one
        GVAddStudents.DataBind()

    End Sub
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <!-- Css -->
    <style type="text/css">
        .Header {
            font-size: larger
        }

        .button {
            background-color: #800000
        }

        .auto-style1 {
            text-align: justify;
            width: 811px
        }

        .modalBackground {
            background-color: Black;
            filter: alpha(opacity=90);
            opacity: 0.8;
        }

        .modalPopup {
            background-color: #FFFFFF;
            border-width: 3px;
            border-style: solid;
            border-color: black;
            padding-top: 10px;
            padding-left: 10px;
        }

        .dropdown {
            background-color: #e23838;
        }

        .modal 
        {
            position: fixed;
            z-index: 999;
            height: 100%;
            width: 100%;
            top: 0;
background-color: White;
filter: alpha(opacity=30);
opacity: .6;
}
.center
{
z-index: 100;
margin: 300px auto;
padding: 10px;
width: 300px;
background-color: White;
border-radius: 10px;
filter: alpha(opacity=100);
opacity: 1;
}
.center img
{
height: 200px;
width: 290px;
}   


        
    </style>
</head>
<body style="height: 379px; width: 782px; margin-bottom: 15px">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        



        <!---------------Top Menu Items-------------->
        <div>




            <asp:UpdatePanel runat="server" ID="TopPanel" UpdateMode="Conditional">
                <ContentTemplate>

                    <!---------------New Class Pop up---->
                    <asp:Panel  ID ="NewClassPopup" runat="server" CssClass="modalPopup" align="center" Style="display: none" Height="340" Width="300">
                        <asp:UpdatePanel ID="PopupUpdatePanel" runat="server">
                            <ContentTemplate>
                                Digital Manual:
                    <asp:DropDownList ID="cmbManual" runat="server" DataSourceID="PADIManualDataSource" DataTextField="PADIManualName" DataValueField="PADIManualID"></asp:DropDownList>
                                <br />
                                <br />
                                Expected Finish Date<br />
                                (You can change this later):<br />
                                <asp:TextBox ID="txtFinishDate" runat="server" AutoPostBack="True" OnTextChanged="txtFinishDate_TextChanged"></asp:TextBox><br />
                                <br />
                                ClassName (for your use only):<br />
                                <asp:RequiredFieldValidator ID="RFVtxtField" runat="server" ControlToValidate="txtClassName" Display="Static" ErrorMessage="Required Field." Style="color: #FF0000" /><br />
                                <asp:TextBox ID="txtClassName" runat="server" Width="200"></asp:TextBox>
                                <cc1:CalendarExtender
                                    ID="CalendarExtender1"
                                    TargetControlID="txtFinishDate"
                                    runat="server" TodaysDateFormat="dd-MMM-yyyy" Format="dd-MMM-yyyy" />
                                <br />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:Button CssClass="button" ID="BtnNewClassSave" runat="server" Text="OK" OnClick="BtnSave_Click" AutoPostBack="True" />

                        <asp:Button ID="btnNewClassCancel" runat="server" Text="Cancel" />
                    </asp:Panel>
                    <!---------New Class Pop up------>



                    <asp:Panel ID="AddStudentsPopup" runat="server" CssClass="modalPopup" align="center" Style="display: none">
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <asp:GridView ID="GVAddStudents" runat="server" AutoGenerateColumns="False" CellPadding="3" DataSourceID="AddStudentsDataSource" EnableViewState="False" OnRowCommand="AddStudents_OnRowCommand" ShowHeaderWhenEmpty="True" GridLines="Vertical" BackColor="White" BorderColor="#999999" BorderStyle="None" BorderWidth="1px">
                                    <AlternatingRowStyle BackColor="#DCDCDC" />
                                    <Columns>

                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:HiddenField ID="HiddenField1" runat="server" Value='<%# Eval("StudentId") %>' />
                                                <asp:TextBox ID="StdIDbox" runat="server" Value='<%# Eval("StudentId") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="StudentName" HeaderText="Student" SortExpression="StudentName" />
                                        <asp:TemplateField ShowHeader="False">
                                            <ItemTemplate>
                                                <asp:Button ID="btnAddStudent" runat="server" CausesValidation="false" CommandArgument='<%# Eval("StudentID") %>' CommandName="Add" Text="Add" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <asp:Button ID="btnAddStudentsCancel" runat="server" Text="Done" />
                        <asp:UpdateProgress ID="UpdateProgress2" runat="server">
                            <ProgressTemplate>
                                <div class="modal">
                                     <div class="center">
                                Processing...
                                <asp:Image ID="WorkingImage2" runat="server" ImageUrl="working.gif" />
                                         </div>
                                    </div>
                            </ProgressTemplate>
                        </asp:UpdateProgress>
                    </asp:Panel>







                    <div class="auto-style1">
                        <asp:DropDownList ID="cmbInstructor" runat="server" CssClass="dropdown" AutoPostBack="True" DataKeyNames="ActiveStudentID" DataSourceID="InstructorDataSource" DataTextField="InstructorName" DataValueField="InstructorID" Height="16px" OnSelectedIndexChanged="cmbInstructor_SelectedIndexChanged" Width="242px">
                        </asp:DropDownList>
                        <br />
                        <br />
                        <br />



                        <cc1:ModalPopupExtender ID="NewClassPUE" runat="server" PopupControlID="NewClassPopup" TargetControlID="btnNewClass"
                            CancelControlID="btnNewClassCancel" BackgroundCssClass="modalBackground">
                        </cc1:ModalPopupExtender>
                        <asp:Button ID="btnNewClass" runat="server" Text="CreateNewClass" />


                        

                    </div>
                    <cc1:ModalPopupExtender ID="AddStudentsPUE" runat="server" PopupControlID="AddStudentsPopup" TargetControlID="btnAddStudents"
                        BackgroundCssClass="modalBackground">
                    </cc1:ModalPopupExtender>

                    <asp:Button ID="btnAddStudents" runat="server" Text="Add Students" OnClick="btnAddStudents_Click" />

                    <%--  --%>
                </ContentTemplate>

            </asp:UpdatePanel>


            


            <asp:UpdatePanel runat="server" ID="BigPanel" UpdateMode="Always">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="Timer1" EventName="Tick" />
                </Triggers>
                <ContentTemplate>
                    <asp:Panel class="modal" visible ="false" runat="server" ID="PanelDynamicUpdate" BackColor="990000" BackImageUrl="~/working.gif">
                            Activity Log:
                                  
                                    <asp:TextBox  Text="Working..." ID="TxtStatus" runat="server" CssClass="center"></asp:TextBox>
                                         
                                </td>

                    </asp:Panel>
                    <asp:Panel ID="Panel1" runat="server" BackColor="#666699">
                        <br />



                        DiveClass:<asp:DropDownList ID="cmbDiveClass" runat="server" AutoPostBack="True" DataKeyNames="ActiveStudentID" DataSourceID="DiveClassDataSource" DataTextField="DiveClassName" DataValueField="DiveClassID" Height="16px" Width="242px" OnSelectedIndexChanged="cmbDiveClass_SelectedIndexChanged">
                        </asp:DropDownList>
                        <br />

                        Digital Manual:
                        <asp:DropDownList ID="cmbPADIManual" runat="server" DataSourceID="PADIManualDataSource" DataTextField="PADIManualName" DataValueField="PADIManualID" AutoPostBack="true"></asp:DropDownList>
                        <br />
                        <asp:Button ID="btnPicCheck" runat="server" OnClick="btnPicCheck_Click" Text="Pic Check" />
                        <br />
                        <br />

                                      <asp:Timer ID="Timer1" runat="server" Enabled="false" Interval="1000" OnTick="Timer1_Tick" />
                      <table>
                            <tr>
                               
                                <td style="vertical-align: top">
                                    <asp:Label runat="server" ID="lblNoStudents" Text="Click 'Add Students' to add students to this course"></asp:Label>
                                    <asp:GridView ID="GVMainGrid" runat="server" AutoGenerateColumns="False" CellPadding="3" DataSourceID="MainGridDataSource" EnableViewState="False" OnRowCommand="GVMainGrid_OnRowCommand" ShowHeaderWhenEmpty="True" GridLines="Vertical" OnPreRender="GVMainGrid_PreRender" BackColor="White" BorderColor="#999999" BorderStyle="None" BorderWidth="1px">
                                        <AlternatingRowStyle BackColor="#DCDCDC" />
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="chkRow" runat="server" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="HiddenField1" runat="server" Value='<%# Eval("ActiveStudentId") %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="StudentName" HeaderText="Student" SortExpression="StudentName" />
                                            <asp:TemplateField HeaderText="Photo">
                                                <ItemTemplate>
                                                    <asp:Image ID="GVImage" runat="server" Height="65" ImageUrl=' <%# Eval("CustImage") %>' Width="50" />
                                                    <br />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="ManualStatus" HeaderText="ManualStatus" SortExpression="Manual" />
                                            <asp:TemplateField HeaderText="Certification">
                                                <ItemTemplate>
                                                    <asp:Label ID="PADICert" runat="server" Text='<%# Eval("PADICertID") %>' Visible="false" />
                                                    <asp:DropDownList ID="cmbPADICert" runat="server" AutoPostBack="true" DataSourceID="PADICertDataSource" DataTextField="PADICertName" DataValueField="PADICertID">
                                                    </asp:DropDownList>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="False">
                                                <ItemTemplate>
                                                    <asp:Button ID="btnRemove" runat="server" CausesValidation="false" CommandArgument='<%# Eval("ActiveStudentID") %>' CommandName="Remove" Text="Remove" />
                                                    <asp:Button ID="btnDetails" runat="server" CausesValidation="false" CommandArgument='<%# Eval("StudentID") %>' CommandName="Details" Text="Details" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <FooterStyle BackColor="#CCCCCC" ForeColor="Black" />
                                        <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White" />
                                        <PagerStyle ForeColor="Black" HorizontalAlign="Center" BackColor="#999999" />
                                        <RowStyle BackColor="#EEEEEE" ForeColor="Black" />
                                        <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White" />
                                        <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                        <SortedAscendingHeaderStyle BackColor="#0000A9" />
                                        <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                        <SortedDescendingHeaderStyle BackColor="#000065" />
                                    </asp:GridView>
                                </td>

                            </tr>
                        </table>
                    </asp:Panel>
                    <asp:TextBox ID="txtSelectedStudentID" runat="server" Style="z-index: 1; left: 10px; top: 263px" Visible="false"></asp:TextBox>
                    <cc1:ModalPopupExtender ID="EditStudentPUE" runat="server" PopupControlID="EditStudentPopup" TargetControlID="btnStudentDetails"
                        CancelControlID="btnEditStudentCancel" BackgroundCssClass="modalBackground">
                    </cc1:ModalPopupExtender>
                    &nbsp<asp:Button ID="btnStudentDetails" runat="server" OnClick="btnEditStudentInfo_Click" />
                    <asp:Panel ID="EditStudentPopup" runat="server" CssClass="modalPopup" align="center" Style="display: none" Height="400" Width="400">
                        <asp:FormView DataSourceID="StudentDetailDataSource" ID="FVStudentEdit" runat="server" DataKeyNames="StudentID" BackColor="White" BorderColor="#336666" BorderStyle="Double" BorderWidth="3px" CellPadding="4" GridLines="Horizontal">
                            <EditItemTemplate>
                                <br />
                                Student:
                            <asp:Label CssClass="Header" ID="StudentNameLabel" runat="server" Text='<%# Eval("StudentName") %>' />
                                <br />
                                <asp:Image ID="Image1" runat="server" Height="65" Width="50" ImageUrl=' <%# Eval("CustImage") %>' /><br />
                                FirstName:
                            <asp:TextBox ID="FirstNameTextBox1" runat="server" Text='<%# Bind("FirstName") %>' />
                                <br />
                                LastName:
                            <asp:TextBox ID="LastNameTextBox1" runat="server" Text='<%# Bind("LastName") %>' />
                                <br />
                                BirthDate:
                            <asp:TextBox ID="BirthDateTextBox" runat="server" Text='<%# Bind("BirthDate") %>' />
                                <cc1:CalendarExtender
                                    ID="CalendarExtender2"
                                    TargetControlID="BirthDateTextBox" TodaysDateFormat="dd-MMM-yyyy" Format="dd-MMM-yyyy"
                                    runat="server" />
                                <br />
                                <br />
                                Gender:
                            <asp:DropDownList ID="DropDownList2" runat="server" SelectedValue='<%# Bind("Gender") %>'>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                                <br />
                                Email:
                            <asp:TextBox ID="EmailTextBox" runat="server" Text='<%# Bind("Email") %>' />
                                <br />
                                Address1:
                            <asp:TextBox ID="Address1TextBox" runat="server" Text='<%# Bind("Address1") %>' />
                                <br />
                                Address2:
                            <asp:TextBox ID="Address2TextBox" runat="server" Text='<%# Bind("Address2") %>' />
                                <br />
                                City:
                            <asp:TextBox ID="CityTextBox" runat="server" Text='<%# Bind("City") %>' Height="22px" />
                                <br />
                                StateID:
                            <asp:DropDownList ID="cmbState" runat="server" DataSourceID="StateDataSource" DataValueField="StateID" DataTextField="StateName">
                            </asp:DropDownList>
                                <asp:SqlDataSource ID="StateDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [StateID], [StateName] FROM [State] WHERE [CountryID] = ?">
                                    <SelectParameters>
                                        <asp:ControlParameter ControlID="cmbCountry" Name="CountryID" PropertyName="SelectedValue" Type="Int32" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <br />
                                Country:
                            <asp:DropDownList ID="cmbCountry" runat="server" DataSourceID="CountryDataSource" DataTextField="CountryName" DataValueField="CountryID" Height="20px" Width="134px" SelectedValue='<%# Bind("CountryID") %>' AutoPostBack="True" OnDataBound="cmbCountry_DataBound" />
                                <asp:SqlDataSource ID="CountryDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [CountryID], [CountryName] AS CountryName FROM [Country]"></asp:SqlDataSource>
                                <br />
                                PostalCode:
                            <asp:TextBox ID="PostalCodeTextBox" runat="server" Text='<%# Bind("PostalCode") %>' />
                                <br />
                                Notes:
                            <asp:TextBox ID="NotesTextBox" runat="server" Text='<%# Bind("Notes") %>' />
                                <br />


                                <br />
                                <asp:Button ID="UpdateButton" runat="server" CausesValidation="True" CommandName="Update" Text="Update" />
                                &nbsp<asp:Button ID="UpdateCancelButton" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                            </EditItemTemplate>

                            <InsertItemTemplate>
                                FirstName:
                            <asp:TextBox ID="FirstNameTextBox" runat="server" Text='<%# Bind("FirstName") %>' />
                                <br />
                                LastName:
                            <asp:TextBox ID="LastNameTextBox" runat="server" Text='<%# Bind("LastName") %>' />
                                <br />
                                BirthDate:
                            <asp:TextBox ID="BirthDateTextBox" runat="server" Text='<%# Bind("BirthDate") %>' />
                                <br />
                                Gender:
                            <asp:TextBox ID="GenderTextBox" runat="server" Text='<%# Bind("Gender") %>' />
                                <br />
                                CountryID:
                            <asp:TextBox ID="CountryIDTextBox" runat="server" Text='<%# Bind("CountryID") %>' />
                                <br />
                                Notes:
                            <asp:TextBox ID="NotesTextBox" runat="server" Text='<%# Bind("Notes") %>' />
                                <br />
                                StateID:
                            <asp:TextBox ID="StateIDTextBox" runat="server" Text='<%# Bind("StateID") %>' />
                                <br />
                                Email:
                            <asp:TextBox ID="EmailTextBox" runat="server" Text='<%# Bind("Email") %>' />
                                <br />
                                CustImage:
                            <asp:TextBox ID="CustImageTextBox" runat="server" Text='<%# Bind("CustImage") %>' />
                                <br />
                                PostalCode:
                            <asp:TextBox ID="PostalCodeTextBox" runat="server" Text='<%# Bind("PostalCode") %>' />
                                <br />
                                City:
                            <asp:TextBox ID="CityTextBox" runat="server" Text='<%# Bind("City") %>' />
                                <br />
                                Address2:
                            <asp:TextBox ID="Address2TextBox" runat="server" Text='<%# Bind("Address2") %>' />
                                <br />
                                Address1:
                            <asp:TextBox ID="Address1TextBox" runat="server" Text='<%# Bind("Address1") %>' />
                                <br />
                                <asp:LinkButton ID="InsertButton" runat="server" CausesValidation="True" CommandName="Insert" Text="Insert" />
                                &nbsp<asp:LinkButton ID="InsertCancelButton" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                            </InsertItemTemplate>
                            <ItemTemplate>
                                Student:
                            <asp:Label CssClass="Header" ID="StudentNameLabel" runat="server" Text='<%# Bind("StudentName") %>' />
                                <br />

                                <br />
                                BirthDate:
                            <asp:Label ID="BirthDateLabel" runat="server" Text='<%# Bind("BirthDate") %>' />
                                <br />
                                Gender:
                            <asp:Label ID="GenderLabel" runat="server" Text='<%# Bind("Gender") %>' />
                                <br />
                                Email:
                            <asp:Label ID="EmailLabel" runat="server" Text='<%# Bind("Email") %>' />
                                <br />
                                Address1:
                            <asp:Label ID="Address1Label" runat="server" Text='<%# Bind("Address1") %>' />
                                <br />
                                Address2:
                            <asp:Label ID="Address2Label" runat="server" Text='<%# Bind("Address2") %>' />
                                <br />
                                City:
                            <asp:Label ID="CityLabel" runat="server" Text='<%# Bind("City") %>' />
                                <br />
                                State:
                            <asp:Label ID="StateIDLabel" runat="server" Text='<%# Bind("StateID") %>' />
                                <br />
                                Country:
                            <asp:Label ID="CountryIDLabel" runat="server" Text='<%# Bind("CountryName") %>' />
                                <br />
                                Postal Code:
                            <asp:Label ID="PostalCodeLabel" runat="server" Text='<%# Bind("PostalCode") %>' />
                                <br />
                                Notes:
                            <asp:Label ID="NotesLabel" runat="server" Text='<%# Bind("Notes") %>' />
                                <br />
                                CustImage:
                                
                                    <asp:Image ID="EIImage" runat="server" Height="65" Width="50" ImageUrl=' <%# Bind("CustImage") %>' /><br />


                                <br />
                                <asp:Button ID="btnEditStudentInfo" runat="server" OnClick="btnEditStudentInfo_Click" Text="Edit Student Info" />
                                <br />
                            </ItemTemplate>
                            <PagerStyle BackColor="#336666" ForeColor="White" HorizontalAlign="Center" />
                            <RowStyle HorizontalAlign="Left" BackColor="White" ForeColor="#333333" />
                        </asp:FormView>

                        <asp:Button ID="btnEditStudentCancel" runat="server" Text="Done" />
                    </asp:Panel>








                    <!-- ***********************************DATA SOURCES********************************* -->

                    <asp:SqlDataSource ID="StudentDetailDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                        ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                        SelectCommand="SELECT Student.[StudentID], FirstName, LastName, [FirstName] + ' ' + [LastName] as StudentName, [BirthDate], [Gender], [Email], [Address1], [Address2], [City], [StateID], [Student.CountryID] as CountryID, [CountryName], [PostalCode], [Notes], '~/Customer Photos/' + [CustImage] as CustImage FROM [Student], [Country] WHERE Student.CountryID = Country.CountryID AND (Student.[StudentID] = ?)"
                        UpdateCommand="UPDATE Student SET FirstName=@FirstName, LastName=@LastName, BirthDate=@BirthDate, Gender=@Gender, Email=@Email, Address1=@Address1, Address2=@Address2, City=@City, CountryID=@CountryID, PostalCode=@PostalCode, Notes=@Notes  WHERE ([StudentID] = @StudentID)">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="txtSelectedStudentID" Name="StudentID" PropertyName="Text" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>

                    <asp:SqlDataSource ID="PADICertDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [PADICertID], [PADICertName] FROM [PADICert] WHERE PADIManualID = ? ORDER BY [Default], [PADICertName]">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="cmbPADIManual" Name="PADIManualID" PropertyName="Text" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>

                    &nbsp<asp:SqlDataSource ID="MainGridDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [ActiveStudentID],Student.[StudentID], [FirstName] + ' ' + [LastName] as StudentName, IIF ([StudentStatus.StudentStatusID] > 1, PADIManualName + ' Assigned', [StudentStatus]) as [ManualStatus], PADICERT.[PADICertID], [PADICertName], '~/Customer Photos/' + CustImage as CustImage FROM [Student], PADICert, StudentStatus, ActiveStudent, DiveClass, PADIManual WHERE PADIManual.PADIManualID = DiveClass.PADIManualID and PADICert.PADICertID = ActiveStudent.PADICertID and ActiveStudent.StudentID = Student.StudentID and ActiveStudent.StudentStatusID = StudentStatus.StudentStatusID AND DiveClass.DiveClassID = ActiveStudent.DiveClassID AND ([DiveClass.DiveClassID] = ?)">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="cmbDiveClass" Name="DiveClassID" PropertyName="SelectedValue" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>

                    &nbsp<asp:SqlDataSource ID="AddStudentsDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT Student.[StudentID], [FirstName] + ' ' + [LastName] as StudentName From Student WHere StudentID Not In (Select StudentID from ActiveStudent WHERE DiveClassID = ?)">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="cmbDiveClass" Name="DiveClassID" PropertyName="SelectedValue" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>



                    <asp:SqlDataSource ID="InstructorDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [InstructorID], [InstructorName] FROM [Instructor]"></asp:SqlDataSource>
                    <asp:SqlDataSource ID="PADIManualDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [PADIManualID], [PADIManualName] FROM [PADIManual] ORDER BY [Default], PADIManualName"></asp:SqlDataSource>
                    <asp:SqlDataSource ID="DiveClassDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [DiveClassID], [DiveClassName] FROM [DiveClass] WHERE InstructorID = ? ORDER BY DiveClassID DESC">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="cmbInstructor" Name="InstructorID" PropertyName="SelectedValue" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                    <asp:SqlDataSource ID="InsertDiveClassDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                        InsertCommand="Insert Into [DiveClass] (DiveClassName, PADIManualID, InstructorID) VALUES (?, ?, ?)"></asp:SqlDataSource>
                    <asp:SqlDataSource ID="InsertIntoActiveStudentDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                        InsertCommand="Insert Into [ActiveStudent] (StudentID, DiveClassID, StudentStatusID, PADICertID) SELECT ?, ?, 1, PADICertID from PADICert WHERE Default=True and PADIManualID = ?"></asp:SqlDataSource>
                    <asp:SqlDataSource ID="PADIManualByDiveClassDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT [PADIManualID] FROM DiveClass WHERE DiveClassID = ?">
                        <SelectParameters>
                            <asp:ControlParameter ControlID="cmbDIveClass" Name="DiveClassID" PropertyName="SelectedValue" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>

                    <asp:SqlDataSource ID="UpdateStudentStatusDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" UpdateCommand="Update ActiveStudent Set StudentStatusID = ? WHERE ActiveStudentID = ?">
                        <UpdateParameters>
                            <asp:FormParameter Name="StudentStatusID" Type="Int32" />
                            <asp:FormParameter Name="ActiveStudentID" Type="Int32" />
                        </UpdateParameters>
                    </asp:SqlDataSource>

                    <asp:SqlDataSource ID="RemoveFromActiveStudentDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" DeleteCommand="Delete from ActiveStudent WHERE ActiveStudentID = ?">
                        <DeleteParameters>
                            <asp:FormParameter Name="ActiveStudentID" Type="Int32" />
                        </DeleteParameters>
                    </asp:SqlDataSource>


                    <asp:Button runat="server" ID="btnAssign" OnClick="btnAssign_Click" Text="Assign Selected Students" />
                </ContentTemplate>
            </asp:UpdatePanel>


        </div>

    </form>
</body>
</html>
