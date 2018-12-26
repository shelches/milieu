Program MakeCaves (Input, Output);

  %Include 'Milio'
  %Include 'Milobj'
  %Include 'Milmon'
  %Include 'Miluser'
  %Include 'Mildb'
  %Include 'Milroom'

  Var
    I, SegsToAdd: Integer;
    Opened: Boolean;
    NewCaves, OldCaves: BinFileType;
    
  Begin

    %Include 'Milroom1'

    Write ('Add how many segments to add? ');
    ReadLn (SegsToAdd);
    Open (NewCaves, File_Name := 'NEWCAVES');
    Rewrite (NewCaves);
    Open (OldCaves, File_Name := 'EDUNGEON', History := Old,
          Error := Continue);
    If Status (OldCaves) = 0
    Then
      Begin
        Reset (OldCaves);
        Opened := True;
        While Not Eof (OldCaves) Do
          Begin
            NewCaves ^ := OldCaves ^;
            Put (NewCaves);
            Get (OldCaves)
          End (*While*)
      End (*If*)
    Else
      Opened := False;
    For I := 0 to 9 Do
      NewCaves ^[I] := ProtoRoom;
    If SegsToAdd > 0
    Then
      For I := 1 to SegsToAdd Do
        Put (NewCaves);
    Close (NewCaves);
    If Opened
    Then
      Close (OldCaves)
  End.
