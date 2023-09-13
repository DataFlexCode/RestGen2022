Use Windows.pkg
Use DFClient.pkg
Use cJsonObject.pkg
Use seq_chnl.pkg

#REPLACE BIF_RETURNONLYFSDIRS       |CI$000001 // 0x00000001. Only return file system directories. If the user selects folders that are not part of the file system, the OK button is grayed. Note  The OK button remains enabled for "\\server" items, as well as "\\server\share" and directory items. However, if the user selects a "\\server" item, passing the PIDL returned by SHBrowseForFolder to SHGetPathFromIDList fails.
#REPLACE BIF_DONTGOBELOWDOMAIN      |CI$000002 // 0x00000002. Do not include network folders below the domain level in the dialog box's tree view control.
#REPLACE BIF_STATUSTEXT             |CI$000004 // 0x00000004. Include a status area in the dialog box. The callback function can set the status text by sending messages to the dialog box. This flag is not supported when BIF_NEWDIALOGSTYLE is specified.
#REPLACE BIF_RETURNFSANCESTORS      |CI$000008 // 0x00000008. Only return file system ancestors. An ancestor is a subfolder that is beneath the root folder in the namespace hierarchy. If the user selects an ancestor of the root folder that is not part of the file system, the OK button is grayed.
#REPLACE BIF_EDITBOX                |CI$000010 // 0x00000010. Version 4.71. Include an edit control in the browse dialog box that allows the user to type the name of an item.
#REPLACE BIF_VALIDATE               |CI$000020 // 0x00000020. Version 4.71. If the user types an invalid name into the edit box, the browse dialog box calls the application's BrowseCallbackProc with the BFFM_VALIDATEFAILED message. This flag is ignored if BIF_EDITBOX is not specified.
#REPLACE BIF_NEWDIALOGSTYLE         |CI$000040 // 0x00000040. Version 5.0. Use the new user interface. Setting this flag provides the user with a larger dialog box that can be resized. The dialog box has several new capabilities, including: drag-and-drop capability within the dialog box, reordering, shortcut menus, new folders, delete, and other shortcut menu commands. Note  If COM is initialized through CoInitializeEx with the COINIT_MULTITHREADED flag set, SHBrowseForFolder fails if BIF_NEWDIALOGSTYLE is passed.
#REPLACE BIF_BROWSEINCLUDEURLS      |CI$000080 // 0x00000080. Version 5.0. The browse dialog box can display URLs. The BIF_USENEWUI and BIF_BROWSEINCLUDEFILES flags must also be set. If any of these three flags are not set, the browser dialog box rejects URLs. Even when these flags are set, the browse dialog box displays URLs only if the folder that contains the selected item supports URLs. When the folder's IShellFolder::GetAttributesOf method is called to request the selected item's attributes, the folder must set the SFGAO_FOLDER attribute flag. Otherwise, the browse dialog box will not display the URL.
//#REPLACE BIF_USENEWUI //Version 5.0. Use the new user interface, including an edit box. This flag is equivalent to BIF_EDITBOX | BIF_NEWDIALOGSTYLE. Note  If COM is initialized through CoInitializeEx with the COINIT_MULTITHREADED flag set, SHBrowseForFolder fails if BIF_USENEWUI is passed.
#REPLACE BIF_UAHINT                 |CI$000100 // 0x00000100. Version 6.0. When combined with BIF_NEWDIALOGSTYLE, adds a usage hint to the dialog box, in place of the edit box. BIF_EDITBOX overrides this flag.
#REPLACE BIF_NONEWFOLDERBUTTON      |CI$000200 // 0x00000200. Version 6.0. Do not include the New Folder button in the browse dialog box.
#REPLACE BIF_NOTRANSLATETARGETS     |CI$000400 // 0x00000400. Version 6.0. When the selected item is a shortcut, return the PIDL of the shortcut itself rather than its target.
#REPLACE BIF_BROWSEFORCOMPUTER      |CI$001000 // 0x00001000. Only return computers. If the user selects anything other than a computer, the OK button is grayed.
#REPLACE BIF_BROWSEFORPRINTER       |CI$002000 // 0x00002000. Only allow the selection of printers. If the user selects anything other than a printer, the OK button is grayed. In Windows XP and later systems, the best practice is to use a Windows XP-style dialog, setting the root of the dialog to the Printers and Faxes folder (CSIDL_PRINTERS).
#REPLACE BIF_BROWSEINCLUDEFILES     |CI$004000 // 0x00004000. Version 4.71. The browse dialog box displays files as well as folders.
#REPLACE BIF_SHAREABLE              |CI$008000 // 0x00008000. Version 5.0. The browse dialog box can display sharable resources on remote systems. This is intended for applications that want to expose remote shares on a local system. The BIF_NEWDIALOGSTYLE flag must also be set.
#REPLACE BIF_BROWSEFILEJUNCTIONS    |CI$010000 // 0x00010000. Windows 7 and later. Allow folder junctions such as a library or a compressed file with a .zip file name extension to be browsed.

Struct BrowseInfo
    Integer hwndOwner
    Integer pidlRoot
    String  pszDisplayName
    String  lpszTitle
    Integer ulFlags
    Integer lpfn
    Integer lParam
    Integer iImage
End_Struct

External_Function SHBrowseForFolder "SHBrowseForFolder" Shell32.dll Pointer BrowseInfo Returns Integer
External_Function SHGetPathFromIDList "SHGetPathFromIDList" Shell32.dll Integer pidList Integer lpBuffer Returns Integer

Define C_US for (Ascii("_"))

Deferred_View Activate_oGenerator for ;
Object oGenerator is a dbView
    Set Border_Style to Border_Thick
    Set Size to 192 433
    Set Location to 0 0
    Set Label to "JSON Struct Generator"
    Set Minimize_Icon to False
    Set Maximize_Icon to False
    Set Sysmenu_Icon  to False
    Set View_Mode to ViewMode_Zoom
    
    Property Integer  piWarnings
    Property String   psPath
    Property String   psAppPath
    Property String   psOuter
    Property Integer  piIndent
    Property String[] pasOriginalNames
    Property String[] pasReplacedNames
    
    Function UCFirst String sVal Returns String
        Function_Return (Uppercase(Left(sVal, 1)) + Right(sVal, (Length(sVal) - 1)))
    End_Function
    
    Procedure ReplaceNames Handle hoJson
        String[]  asOriginal asReplaced asOrig asRepl
        Integer   i j iMembs iLast iPos iType
        UChar[]   ucaName
        String    sName sRepl
        Handle    hoMemb
        
        Get pasOriginalNames to asOriginal
        Get pasReplacedNames to asReplaced
        
        If (JsonType(hoJson) = jsonTypeObject) Begin
            Get MemberCount of hoJson to iMembs
            Decrement iMembs
            
            For j from 0 to iMembs
                Get MemberNameByIndex of hoJson j to sName
                Move sName                        to sRepl
                
                If (Length(sName) = 0) Begin
                    Move 0                                  to iPos
                End
                Else Begin
                    Move (SearchArray(sName, asOriginal))   to iPos            
                End
                
                // If name has length and we don't have it already, process:
                If (iPos = -1) Begin
                    Move (StringToUCharArray(sName))        to ucaName
                    Move (SizeOfArray(ucaName) - 1)         to iLast
                    
                    For i from 0 to iLast
                        
                        Case Begin
                            // A digit in 1st place
                            Case ((i = 0) and ((ucaName[i] >= 48) and (ucaName[i] <= 57)))
                                Move C_US to ucaName[i]
                                Case Break
                            // ASCII 36-47
                            Case ((ucaName[i] >= 36) and (ucaName[i] <= 47))
                                Move C_US to ucaName[i]
                                Case Break
                            // ASCII 58-64
                            Case ((ucaName[i] >= 58) and (ucaName[i] <= 63))
                                Move C_US to ucaName[i]
                                Case Break
                            // ASCII 91-94
                            Case ((ucaName[i] >= 91) and (ucaName[i] <= 94))
                                Move C_US to ucaName[i]
                                Case Break
                            // ASCII 96
                            Case (ucaName[i] = 96)
                                Move C_US to ucaName[i]
                                Case Break
                            // Greater than ASCII 123
                            Case (ucaName[i] >= 123)
                                Move C_US to ucaName[i]
                                Case Break
                        Case End
                        
                    Loop
                            
                    Move (UCharArrayToString(ucaName))    to sRepl
                End                            
                
                If (sName <> sRepl) Begin  // There have been replacements
                    Move (SizeOfArray(asOrig))  to iPos
                    Move sName                  to asOrig[iPos]
                    Move sRepl                  to asRepl[iPos]
                End
                
            Loop
            
            Move (AppendArray(asOriginal, asOrig)) to asOriginal
            Move (AppendArray(asReplaced, asRepl)) to asReplaced
            Set pasOriginalNames to asOriginal
            Set pasReplacedNames to asReplaced
        End
        
        // Now recurse down the tree
        Get MemberCount of hoJson to iMembs
        Decrement iMembs
        
        For i from 0 to iMembs
            Get MemberByIndex of hoJson i  to hoMemb
            Get JsonType of hoMemb         to iTYpe
            
            If ((iType = jsonTypeObject) or (iType = jsonTypeArray)) Begin
                Send ReplaceNames hoMemb
            End
            
        Loop
        
    End_Procedure

    Procedure WriteStruct Handle hoJson String sName String sParent
        String[] asOrig asRepl
        Integer  iChn i iLast iType iInd iArrType iMembs iIdx
        String   sMemb sPre
        Handle   hoMemb hoArrMemb
                
        Get MemberCount of hoJson to iLast
        Decrement iLast
        
        For i from 0 to iLast
            Get MemberNameByIndex  of hoJson i     to sMemb
            Get MemberJsonType     of hoJson sMemb to iType
            
            If (iType = jsonTypeObject) Begin
                Get Member of hoJson sMemb to hoMemb
                Send WriteStruct hoMemb sMemb sName
                Send Destroy of hoMemb
            End
            Else If (iType = jsonTypeArray) Begin
                Get Member of hoJson sMemb to hoMemb

                If (MemberCount(hoMemb)) Begin
                    Get MemberByIndex of hoMemb 0 to hoArrMemb
                    Get JsonType of hoArrMemb to iType
                    
                    If (iType = jsonTypeObject) Begin
                        Send WriteStruct hoArrMemb sMemb sName
                    End
    
                End
                
                Send Destroy of hoMemb                
            End
            
        Loop
        
        Get piIndent to iInd
        Get psOuter  to sPre
        
        Get Seq_New_Channel to iChn
        Direct_Output channel iChn (psPath(Self) + "\" + sPre + UCFirst(Self, sName) + ".pkg")

        Showln "Generating struct packanges for " sPre (UCFirst(Self, sName)) " in " (psPath(Self))

        Writeln channel iChn "// File: " sPre (UCFirst(Self, sName)) ".pkg generated by Unicorn InterGlobal's " (Module_Name(Self)) " program"
        Writeln channel iChn "// Generated date and time: " (String(CurrentDateTime()))
        Writeln channel iChn
        
        //Uses:
        Writeln channel iChn "Use cJsonObject.pkg"

        Get MemberCount of hoJson to iLast
        Decrement iLast
        
        For i from 0 to iLast
            Get MemberNameByIndex of hoJson i  to sMemb
            Get MemberJsonType of hoJson sMemb to iType
            
            If (iType = jsonTypeObject) Begin
                Writeln channel iChn ("Use" * psAppPath(Self) + "\" + sPre + UCFirst(Self, sMemb) + ".pkg")
            End
            Else If (iType = jsonTypeArray) Begin
                Get Member of hoJson sMemb to hoMemb
                
                If (MemberCount(hoMemb)) Begin
                    Get MemberByIndex of hoMemb 0 to hoArrMemb
                    Get JsonType of hoArrMemb to iType
                    
                    If (iType = jsonTypeObject) Begin
                        Writeln channel iChn ("Use" * psAppPath(Self) + "\" + sPre + UCFirst(Self, sMemb) + ".pkg")
                    End
                    
                    Send Destroy of hoArrMemb
                End
                    
                Send Destroy of hoMemb
            End
            
        Loop
        
        Writeln channel iChn
        
        Get pasOriginalNames to asOrig
        Get pasReplacedNames to asRepl
        
        // Struct
        Writeln channel iChn "Struct " sPre sName
        
        If (iLast < 0) Begin
            Showln "***** WARNING: UNPOPULATED JSON OBJECT FOUND: '" sName "'"
            Set piWarnings to (piWarnings(Self) + 1)
            Writeln channel iChn "// ToDo: Unpopulated JSON Object, resulting in an empty Struct, which is almost certainly incorrect"
        End
        
        For i from 0 to iLast
            Get MemberNameByIndex of hoJson i  to sMemb
            Get MemberJsonType of hoJson sMemb to iType
            
            Move (SearchArray(sMemb, asOrig)) to iIdx
            
            If (iIdx <> -1) Begin
                Write channel iChn (Repeat(" ", iInd))
                Writeln channel iChn ('{ Name="' + sMemb + '" }')
                Move asRepl[iIdx] to sMemb
            End
            
            Write channel iChn (Repeat(" ", iInd))
            
            Case Begin
                Case (iType = jsonTypeArray) 
                    Get Member of hoJson sMemb to hoMemb
                    
                    If (MemberCount(hoMemb)) Begin
                        Get MemberByIndex of hoMemb 0 to hoArrMemb
                        Get JsonType of hoArrMemb to iArrType
                        
                        Case Begin
                            Case (iArrType = jsonTypeBoolean)
                                Write channel iChn "Boolean[]"
                                Case Break
                            Case (iArrType = jsonTypeDouble)
                                Write channel iChn "Number[] "
                                Case Break
                            Case (iArrType = jsonTypeInteger)
                                Write channel iChn "Integer[]"
                                Case Break
                            Case (iArrType = jsonTypeNull)
                                Showln "***** WARNING: NULL ARRAY MEMBER FOUND *****"
                                Showln "     Substituting string array instead,"
                                Showln "     but this is probably incorrect"
                                Set piWarnings to (piWarnings(Self) + 1)
                                Writeln channel iChn "// ToDo: Substituted String for null member '" sMemb "' in sample JSON, which may not be correct"
                                Write channel iChn (Repeat(" ", iInd)) "String[] "
                                Case Break
                            Case (iArrType = jsonTypeObject)
                                Write channel iChn sPre (UCFirst(Self, sMemb)) "[]"
                                Case Break
                            Case (iArrType = jsonTypeString)
                                Write channel iChn "String[] "
                                Case Break
                            Case (iArrType = jsonTypeArray)
                                Showln "***** WARNING: MULTI-DIMENSIONAL ARRAY *****"
                                Showln "     Cannot process - defaulting '" sMemb "' to string[], which IS WRONG!"
                                Set piWarnings to (piWarnings(Self) + 1)
                                Writeln "// ToDo: Multi dimentional array '" sMemb "' in sample JSON - String[] used instead"
                                Write channel iChn "String[] "
                                Case Break
                        Case End

                        Send Destroy of hoArrMemb
                    End
                    Else Begin
                        Showln "***** WARNING: EMPTY ARRAY *****"
                        ShowLn '     Cannot determine member type for array "' sMemb '"'
                        Showln '     Defaulting type to string, which is probably wrong (it may be a complex type)'
                        Showln '     Suggest you populate the FIRST member of the "' sMemb '" array'
                        Showln '     with one filled-out item in the JSON window and regenerate'
                        Set piWarnings to (piWarnings(Self) + 1)
                        Writeln "// ToDo: Sample JSON had empty array '" sMemb "', so used array of String instead, which may not be correct"
                        Write channel iChn (Repeat(" ", iInd)) "String[] "
                    End
                    
                    Send Destroy of hoMemb
                    Case Break
                Case (iType = jsonTypeBoolean)
                    Write channel iChn "Boolean "
                    Case Break
                Case (iType = jsonTypeDouble)
                    Write channel iChn "Number  "
                    Case Break
                Case (iType = jsonTypeInteger)
                    Write channel iChn "Integer "
                    Case Break
                Case (iType = jsonTypeString)
                    Write channel iChn "String  "
                    Case Break
                Case (iType = jsonTypeNull)
                    Showln "***** WARNING: NULL JSON MEMBER FOUND *****"
                    Showln "     Substituting string instead,"
                    Showln "     but this is probably incorrect"
                    Set piWarnings to (piWarnings(Self) + 1)
                    Writeln channel iChn "// ToDo: Substituted String for null member '" sMemb "' in sample JSON, which may not be correct"
                    Write (Repeat(" ", iInd)) "String  "
                    Case Break
                Case (iType = jsonTypeObject)
                    Write channel iChn sPre  (UCFirst(Self, sMemb))
            Case End
            
            Writeln channel iChn " " sMemb
        Loop        
        
        Writeln channel iChn "End_Struct"
        
        Close_Output channel iChn
        Send Seq_Release_Channel iChn
    End_Procedure

    Procedure Generate
        String   sSource sPath sName sIPre sErr sPartPath sRPath
        String[] asDirs asEmpty asOrig asRepl
        Boolean  bOK bExist
        Integer  i iWarns iType iLast iInd iChn
        Handle   hoJson      
        
        Get Value of oJsonText to sSource
        
        If (sSource = "") Begin
            Send UserError "You need to paste sample JSON into the window before attempting to generate struct(s) from it" "No JSON"
            Procedure_Return
        End
        
        If (Value(oOuterName(Self)) = "") Begin
            Send UserError "You must specify a name for the outer struct" "No Name specified"
            Procedure_Return
        End
        
        If (Value(oOutput(Self)) = "") Begin
            Send UserError "You must specify a path to write the packages to" "No Path specified"
            Procedure_Return
        End
        
        Set pasOriginalNames to asEmpty
        Set pasReplacedNames to asEmpty
        
        Get Value of oOutput    to sPath
        Set psPath              to sPath
        Get Value of oRelPath   to sRPath
        Set psAppPath           to sRpath
        Get Value of oOuterName to sName
        Set psOuter             to sName
        Get Value of oIndent    to iInd
        Set piIndent            to iInd

        Set piWarnings          to 0

        Get Create (RefClass(cJsonObject)) to hoJson
        
        Get ParseString of hoJson sSource to bOK
        
        If not bOK Begin
            Get psParseError of hoJson to sErr
            Send UserError ("JSON" * sErr)
            Send Destroy of hoJson
            Procedure_Return
        End
        
        Get JsonType of hoJson to iType
        
        // I don't think this can happen is parsing worked, but...
        If ((iType <> jsonTypeObject) and (iType <> jsonTypeArray)) Begin
            Send UserError "Outer JSON is not an Object or Array" "No JSON Object"
            Send Destroy of hoJson
            Procedure_Return
        End
        
        // Check if the output directory exists; if not create it
        File_Exist sPath bExist

        If not bExist Begin
            Move (StrSplitToArray(sPath, "\"))  to asDirs
            Move (SizeOfArray(asDirs) - 1)      to iLast
            Move asDirs[0]                      to sPartPath
            
            For i from 1 to iLast
                File_Exist sPartPath bExist
                
                If not bExist Begin
                    Make_Directory sPartPath
                End
                
                Move (sPartPath + "\" + asDirs[i]) to sPartPath
            Loop
            
            File_Exist sPartPath bExist
            
            If not bExist Begin
                Make_Directory sPartPath
            End
            
        End
        
        Send ReplaceNames hoJson
        Send WriteStruct hoJson "" ""
        Send Destroy of hoJson
        
        Get piWarnings to iWarns
        Showln "Struct and code generation for " sName " complete"
        Showln "There " (If((iWarns = 1), "was ", "were ")) (String(iWarns)) " warning" (If((iWarns = 1), "", "s"))
        
        RunProgram Shell Background "explorer" sPath
    End_Procedure

    Object oJsonText is a cTextEdit
        Set Size to 123 428
        Set Location to 15 2
        Set peAnchors to anAll
        Set Label to "Paste sample JSON here:"
        Set psToolTip to "Paste the JSON text on which to base your struct(s) here"
        Set piMaxChars to 10000000
    End_Object

    Object oOuterName is a Form
        Set Size to 13 256
        Set Location to 142 102
        Set peAnchors to anBottomLeft
        Set Label_Col_Offset to 94
        Set Label to "Outer struct name:"
        Set Value to "st"
        Set psToolTip to "Name for the outer struct from your JSON"
    End_Object

    Object oOutput is a Form
        Set Size to 13 256
        Set Location to 159 102
        Set Label to "Path to write packages to:"
        Set Label_Col_Offset to 94
        Set peAnchors to anBottomLeftRight
        Set psToolTip to "Path to create your struct packages at"
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Activating
            String  sPath iSep
            Handle hoCL
            Integer iLen i
            
            Forward Send Activating
            
            Get phoCommandLine of oApplication to hoCL
            
            If (hoCL and CountOfArgs(hoCL)) Begin
                Get Argument of hoCL 1 to sPath
                If (sPath = "") Break
                
                Move (Length(sPath)) to iLen
                
                For i from 0 to (iLen - 1)
                    If (Mid(sPath, 1, (iLen - i)) = "\") Move (iLen - i) to iSep
                    If iSep Break
                Loop
                
                If iSep Begin
                    Set Value to  (Left(sPath, iSep) + "AppSrc\ApiStructs")
                End
                
            End
            
        End_Procedure
        
        Procedure Prompt
            Boolean bOK
            String  sPath sDir
            Handle  hWnd
            BrowseInfo tBI
            Integer iItem iOK i iLen

            Get Window_Handle           to tBI.hwndOwner
            Move "Select Output Folder" to tBI.lpszTitle
            Move 0                      to tBI.pidlRoot
            Move (BIF_NEWDIALOGSTYLE + BIF_UAHINT)   to tBI.ulFlags
            
            Move (SHBrowseForFolder(AddressOf(tBI))) to iItem
            
            If iItem Begin
                Move (ZeroString(512))                              to sPath
                Move (SHGetPathFromIDList(iItem, AddressOf(sPath))) to iOK
                Move (CString(sPath))                               to sPath
                Set Value                                           to sPath
                
                Move (Length(sPath))    to iLen
                Move ""                 to sDir
                
                For i from 0 to iLen
                    
                    If (Mid(sPath, 1, (iLen - i)) = "\") Begin
                        Move (Right(sPath, i)) to sDir
                    End
                
                    If (sDir <> "") Break
                Loop
                
            End
            
            Set Value of oRelPath to sDir
        End_Procedure
        
    End_Object

    Object oRelPath is a Form
        Set Size to 13 126
        Set Location to 176 102
        Set Label to "Struct path relative to AppSrc:"
        Set Label_Col_Offset to 100
        Set Value to "ApiStructs"
        Set peAnchors to anBottomLeftRight
        Set psToolTip to "Relative path from you AppSrc directory to your structs directory"
    End_Object

    Object oIndent is a SpinForm
        Set Size to 13 28
        Set Location to 158 402
        Set Label to "Indent:"
        Set Label_Col_Offset to 26
        Set Spin_Value to 4
        Set psToolTip to "Number of spaces to indent each source code level"
        Set peAnchors to anBottomRight
    End_Object

    Object GenerateBtn is a Button
        Set Size to 14 39
        Set Location to 176 392
        Set Label to "Generate"
        Set peAnchors to anBottomRight
        Set psToolTip to "Generate the struct packages"
    
        Procedure OnClick
            Send Generate
        End_Procedure
    
    End_Object
CD_End_Object
