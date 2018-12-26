
Program PrintLists (Input, Output);

  Label
    990;

{$I Milio.pas}
  %Include 'Milobj'
  %Include 'Milmon'
  
  Var
    I, J: Integer;
    Mon : MonsterPoint;
    Obj : ObjectPoint;
    S, T: String;
    X1, X2: Packed Array [1 .. 11] of Char;
    
  Begin

    %Include 'Milio1'
    %Include 'Milobj1'
    %Include 'Milmon1'

    Time (X1);
    Date (X2);
    T := X1 + '  ' + X2 + ' |';
    I := 1;
    Term [1] := Chr (0);
    Term [2] := Chr (0);
    Reset (MList);
    New (Mon);
    WriteLn (
'---------------------------------------------------------------------------');
    S := '| Milieu Random Monster Lists';
    WriteLn (S, '': 75 - Length (S) - Length (T), T);
    WriteLn (
'---------------------------------------------------------------------------');
    While Not Eof (MList) Do
      Begin
        Find (MList, I);
        If Not Eof (MList)
        Then
          Begin
            WriteLn;
            WriteLn ('MList record #', I: 3, '  ****************************');
            WriteLn;
            Mon ^ := MList ^;
            MonDisplay (Mon);
            I := I + 1
          End (*If*)
      End (*While*);
    WriteLn ('Total of ', I - 1: 0, ' records.');
    Page;
    WriteLn ('Random monster list:');
    For I := 1 to LEncounter Do
      Begin
        WriteLn ('Monster index list ', I: 0, ':');
        For J := 1 to 6 Do
          Begin
            Loc := EncIndex [I, J];
            Write ('   ', Loc: 3, ': ');
            If Loc > 0
            Then
              Begin
                Find (MList, EncIndex [I, J]);
                Mon ^ := MList ^;
                Write ('A');
                If Cap (Mon ^.Name [1]) in ['A', 'E', 'I', 'O', 'U']
                Then
                  Write ('n');
                Write (' ', PS (Mon ^.Name))
              End (*If*)
            Else
              Write ('No encounter.');
            WriteLn
          End (*For*);
        WriteLn
      End (*For*);
    Dispose (Mon);
    Page;
    WriteLn (
'---------------------------------------------------------------------------');
    S := '| Milieu Random Object List ';
    WriteLn (S, '': 75 - Length (S) - Length (T), T);
    WriteLn (
'---------------------------------------------------------------------------');
    Reset (OList);
    I := 1;
    New (Obj);
    While Not Eof (OList) Do
      Begin
        Find (OList, I);
        If Not Eof (OList)
        Then
          Begin
            WriteLn;
            WriteLn ('OList record #', I: 3, '  ****************************');
            WriteLn;
            Obj ^ := OList ^;
            ObjDisplay (Obj);
            I := I + 1
          End (*If*)
      End (*While*);
    WriteLn;
    WriteLn ('Total of ', I - 1: 0, ' records.');
    Page;
    WriteLn ('Random treasure list:');
    For I := 1 to ObjListLen Do
      Begin
        WriteLn ('Treasure type ', I: 0, ':');
        For J := 1 to 6 Do
          Begin
            Loc := ObjIndex [I, J];
            Write ('   ', Loc: 3, ': ');
            If Loc > 0
            Then
              Begin
                Find (OList, ObjIndex [I, J]);
                PrintObj (OList ^, False, True)
              End (*If*)
            Else
              Write ('Nothing.');
            WriteLn
          End (*For*)
      End (*For*);

    %Include 'Milio2'
    %Include 'Milobj2'
    %Include 'Milmon2'

  990:

  End.
$ ώς¨
Program PrintLists (Input, Output);

  Label
    990;

  %Include 'Milio'
  %Include 'Milobj'
  %Include 'Milmon'
  
  Var
    I, J: Integer;
    Mon : MonsterPoint;
    Obj : ObjectPoint;
    S, T: String;
    X1, X2: Packed Array [1 .. 11] of Char;
    
  Begin

    %Include 'Milio1'
    %Include 'Milobj1'
    %Include 'Milmon1'

    Time (X1);
    Date (X2);
    T := X1 + '  ' + X2 + ' |';
    I := 1;
    Term [1] := Chr (0);
    Term [2] := Chr (0);
    Reset (MList);
    New (Mon);
    WriteLn (
'---------------------------------------------------------------------------');
    S := '| Milieu Random Monster Lists';
    WriteLn (S, '': 75 - Length (S) - Length (T), T);
    WriteLn (
'---------------------------------------------------------------------------');
    While Not Eof (MList) Do
      Begin
        Find (MList, I);
        If Not Eof (MList)
        Then
          Begin
            WriteLn;
            WriteLn ('MList record #', I: 3, '  ****************************');
            WriteLn;
            Mon ^ := MList ^;
            MonDisplay (Mon);
            I := I + 1
          End (*If*)
      End (*While*);
    WriteLn ('Total of ', I - 1: 0, ' records.');
    Page;
    WriteLn ('Random monster list:');
    For I := 1 to LEncounter Do
      Begin
        WriteLn ('Monster index list ', I: 0, ':');
        For J := 1 to 6 Do
          Begin
            Loc := EncIndex [I, J];
            Write ('   ', Loc: 3, ': ');
            If Loc > 0
            Then
              Begin
                Find (MList, EncIndex [I, J]);
                Mon ^ := MList ^;
                Write ('A');
                If Cap (Mon ^.Name [1]) in ['A', 'E', 'I', 'O', 'U']
                Then
                  Write ('n');
                Write (' ', PS (Mon ^.Name))
              End (*If*)
            Else
              Write ('No encounter.');
            WriteLn
          End (*For*);
        WriteLn
      End (*For*);
    Dispose (Mon);
    Page;
    WriteLn (
'---------------------------------------------------------------------------');
    S := '| Milieu Random Object List ';
    WriteLn (S, '': 75 - Length (S) - Length (T), T);
    WriteLn (
'---------------------------------------------------------------------------');
    Reset (OList);
    I := 1;
    New (Obj);
    While Not Eof (OList) Do
      Begin
        Find (OList, I);
        If Not Eof (OList)
        Then
          Begin
            WriteLn;
            WriteLn ('OList record #', I: 3, '  ****************************');
            WriteLn;
            Obj ^ := OList ^;
            ObjDisplay (Obj);
            I := I + 1
          End (*If*)
      End (*While*);
    WriteLn;
    WriteLn ('Total of ', I - 1: 0, ' records.');
    Page;
    WriteLn ('Random treasure list:');
    For I := 1 to ObjListLen Do
      Begin
        WriteLn ('Treasure type ', I: 0, ':');
        For J := 1 to 6 Do
          Begin
            Loc := ObjIndex [I, J];
            Write ('   ', Loc: 3, ': ');
            If Loc > 0
            Then
              Begin
                Find (OList, ObjIndex [I, J]);
                PrintObj (OList ^, False, True)
              End (*If*)
            Else
              Write ('Nothing.');
            WriteLn
          End (*For*)
      End (*For*);

    %Include 'Milio2'
    %Include 'Milobj2'
    %Include 'Milmon2'

  990:

  End.
