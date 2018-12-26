
Program CreateOMList (Input, Output);

  %Include 'Milio'
  %Include 'Milobj'
  %Include 'Milmon'
  
  Var
    JLoop: Integer;
    Ch: Char;
  
  Procedure CreateMList;
  
    Begin
      Rewrite (MList);
      MList ^ := ProtoMonster;
      MList ^.Permanent := False;
      For JLoop := 1 to RanMonLen Do
        Begin
          Put (MList);
          Write ('.')
        End (*For*);
      WriteLn;
      WriteLn ('MList created.')
    End (*CreateMList*);
      
  Procedure CreateOList;

    Begin
      Rewrite (OList);
      OList ^ := ProtoObject;
      OList ^.Permanent := False;
      For JLoop := 1 to RanObjLen Do
        Begin
          Put (OList);
          Write ('.')
        End (*For*);
      WriteLn;
      WriteLn ('OList created.')
    End (*CreateOList*);
  
  Procedure Display;
  
    Var
      Mon: MonsterPoint;
      Obj: ObjectPoint;
      
    Begin
      WriteLn ('   M - Display MList');
      WriteLn ('   O - Display OList');
      WriteLn ('   Q - leave');
      Write ('  Option? ');
      Repeat
        Read (Ch);
        Ch := Cap (Ch)
      Until Ch in ['M', 'O', 'Q'];
      If Ch = 'M' Then
        Begin
          Reset (MList);
          Get (MList);
          New (Mon);
          Mon ^ := MList ^;
          MonDisplay (Mon);
          Dispose (Mon)
        End (*If*)
      Else
        If Ch = 'O' Then
          Begin
            Reset (OList);
            Get (OList);
            New (Obj);
            Obj ^ := OList ^;
            ObjDisplay (Obj);
            Dispose (Obj)
          End (*If*);
      Ch := 'D'
    End (*Display*);
        
  Begin

    %Include 'Milobj1'
    %Include 'Milmon1'

    Repeat
      WriteLn ('Create file options:');
      WriteLn (' D - Display lists');
      WriteLn (' M - Create MList');
      WriteLn (' O - Create OList');
      WriteLn (' Q - Quit');
      Write ('Enter option: ');
      Repeat
        Read (Ch);
        Ch := Cap (Ch)
      Until Ch in ['M', 'O', 'Q', 'D'];
      If Ch = 'M'
      Then
        CreateMList
      Else
        If Ch = 'O'
        Then
          CreateOList
        Else
          If Ch = 'D'
          Then
            Display
    Until Ch = 'Q';

    %Include 'Milobj2'
    %Include 'Milmon2'

  End (*CreateMList*).
