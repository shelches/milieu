
Program MakeEDesc (Input, Output);

  %Include 'Milio'
  %Include 'MilJmr'
  
  Var
    I, Line, SegCount: Integer;
    Option: Char;
    Desc: Text;
    ED: File of Packed Array [1 .. StrPerSeg] of String;
    Temp: String;
    
  Procedure GetLine (Var S : String);
  
    Var
      I : Integer;
      Ch: Char;
      Ch2: Char;
      XX: String;
    
    Begin
      Read (Desc, I);
      Ch2 := Chr (I + Ord ('0'));
      Read (Desc, Ch);
      While (Ch = ' ') And Not Eoln (Desc) Do
        Read (Desc, Ch);
      Read (Desc, XX);
      S := Ch2 + Ch + XX;
      ReadLn (Desc)
    End (*GetLine*);
  
  Begin
    Repeat
      Write ('Option (C/D/Q)? ');
      Repeat
        Read (Option);
        If Option in ['a' .. 'z']
        Then
          Option := Chr (Ord (Option) - 32)
      Until Option in ['C', 'D', 'Q'];
      Case Option of
        'C':
          Begin
            Open (Desc, File_Name := 'DESC.TXT', History := Old);
            Reset (Desc);
            Open (ED, File_Name := 'DSCRPT', History := New, 
                  Access_Method := Direct);
            Rewrite (ED);
            SegCount := 0;
            For Line := 1 to StrPerSeg Do
              ED ^[Line] := '';
            While Not Eof (Desc) Do
              Begin
                Read (Desc, Line);
                If Line <= StrPerSeg
                Then
                  Begin
                    Temp := ED ^[Line];
                    GetLine (Temp);
                    ED ^[Line] := Temp;
                    Write ('.')
                  End (*If*)
                Else
                  Begin
                    ReadLn (Desc);
                    Put (ED, Error := Continue);
                    For Line := 1 to StrPerSeg Do
                      ED ^[Line] := '';
                    WriteLn ('  Segment ', SegCount: 0, ' done.');
                    SegCount := SegCount + 1
                  End (*Else*)
              End (*While*);
            Find (ED, 1);
            ED ^[1] := '        ';
            SegCount := SegCount - 1;
            ED ^[1, 1] := Chr (SegCount DIV 256);
            ED ^[1, 2] := Chr (SegCount MOD 256);
            Locate (ED, 1);
            Put (ED);
            WriteLn (SegCount: 0, ' segments processed.');
            Close (Desc);
            Close (ED);
            WriteLn ('Compilation complete.')
          End (*'C'*);
        'D':
          Begin
            Open (ED, File_Name := 'DSCRPT', History := Old,
                  Access_Method := Direct);
            Reset (ED);
            Write ('Which seg to display? ');
            ReadLn (SegCount);
            If SegCount >= 0
            Then
              Begin
                Find (ED, SegCount, Error := Continue);
                For I := 1 to StrPerSeg Do
                  Begin
                    Write (I);
                    If Length (ED ^[I]) > 0
                    Then
                      Begin
                        Write (Ord (ED ^[I, 1]) - Ord ('0'): 3);
                        For Line := 2 to Length (ED ^ [I]) Do
                          Write (ED ^[I, Line])
                      End (*If*);
                    WriteLn
                  End (*For*)
              End (*If*);
            Close (ED)
          End (*'D'*);
      End (*Case*);
    Until Option = 'Q';
  End.
