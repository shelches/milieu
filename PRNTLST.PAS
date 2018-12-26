
  Program PrintLists;

{$I MILIO.PAS}
         (*$U #5:MILOBJ.CODE*)   MilObject
         (*$U #5:MILMON.CODE*)   MilMonster
         (*$U #5:TIME/DATE.CODE*) SIO_Unit , TAD_Unit;
    
    Var
      I , J: Integer;
      Mon : MonsterPoint;
      Obj : ObjectPoint;
      S , T: String;
      H   : Packed Array [1 .. 8] of string [80];
      
    Procedure GoodDate (Var S: String);
    
      Var
        Day , Month , Year , Hours , Minutes , Seconds , DayOfWeek
             Julian: Integer;
        TimeValue: TAD_PTime;
        
      Begin
        UnitRead (129 , TimeValue

 , 1);
        TAD_UnPack (TimeValue , Day , Month , Year , Hours , Minutes , Seconds
                    DayOfWeek , Julian);
        TAD_TimO (Hours , Minutes , Seconds , [TAD_Long , TAD_Short] , S);
        S := ConCat (S , '   ');
        TAD_DatO (Day , Month , Year , [TAD_Long] , S)
      End (*ClockTime*);
    
    Begin
      T := '';
      GoodDate (T);
      I := 1;
      Term [1] := Chr (0);
      Term [2] := Chr (0);
      Reset (MList);
      Seek (MList , 0);
      New (Mon);
  H[1]:= '**      **  **        **   ******   **********';
  H[2]:= '****  ****  **        **  *      *      **    ';
  H[3]:= '**  **  **  **        **  *             **    ';
  H[4]:= '**      **  **        **   ******       **    ';
  H[5]:= '**      **  **        **         *      **    ';
  H[6]:= '**      **  ********  **   ******       **    ';
      WriteLn (
  '---------------------------------------------------------------------------');
      WriteLn ('!' , '!':74);
      For I := 1 to 6 do
        WriteLn ('!' , '': (74 - Length (H [I])) Div 2 , H [I]
                      '!': (74 - Length (H [I])) Div 2);
      WriteLn ('!' , '!':74);
      WriteLn ('!' , '': (74 - Length (T)) Div 2
 , '!': (74 - Length (T)) Div 2);
      WriteLn (
  '---------------------------------------------------------------------------');
      I := 1;
      While Not Eof (MList) Do
        Begin
          Get (MList);
          If Not Eof (MList)
          Then
            Begin
 , WriteLn;
 , WriteLn ('MList record #' , I: 3 , '  ****************************');
 , WriteLn;
 , Mon ^ := MList ^;
 , MonDisplay (Mon);
 , I := I + 1
            End (*If*)
        End (*While*);
      WriteLn ('Total of ' , I - 1: 0 , ' records.');
      WriteLn;
      WriteLn ('Random monster list:');
      For I := 1 to LEncounter Do
        Begin
          WriteLn ('Monster index list ' , I: 0 , ':');
          For J := 1 to 6 Do
            Begin
 , Loc := EncIndex [I , J];
 , Write ('   ' , Loc: 3 , ': ');
 , If Loc > 0
 , Then
                Begin
                  Seek (MList , EncIndex [I , J] - 1);
                  Get (MList);
                  Mon ^ := MList ^;
                  Write ('A');
                  If Cap (Mon ^.Name [1]) in ['A' , 'E' , 'I' , 'O' , 'U']
                  Then
                    Write ('n');
                  Write (' ' , PS (Mon ^.Name))
                End (*If*)
 , Else
                Write ('No encounter.');
 , WriteLn
            End (*For*);
          WriteLn
        End (*For*);
      Dispose (Mon);
      Write (Chr (12));
  H[1]:= '  ******    **        **   ******   **********';
  H[2]:= '**      **  **        **  *      *      **    ';
  H[3]:= '**      **  **        **  *             **    ';
  H[4]:= '**      **  **        **   ******       **    ';
  H[5]:= '**      **  **        **         *      **    ';
  H[6]:= '  ******    ********  **   ******       **    ';
      WriteLn (
  '---------------------------------------------------------------------------');
      WriteLn ('!' , '!':74);
      For I := 1 to 6 do
        WriteLn ('!' , '': (74 - Length (H [I])) Div 2 , H [I]
                      '!': (74 - Length (H [I])) Div 2);
      WriteLn ('!' , '!':74);
      WriteLn ('!' , '': (74 - Length (T)) Div 2
 , '!': (74 - Length (T)) Div 2);
      WriteLn (
  '---------------------------------------------------------------------------');
      I := 1;
      Reset (OList);
      Seek (OList , 0);
      New (Obj);
      While Not Eof (OList) Do
        Begin
          Get (OList);
          If Not Eof (OList)
          Then
            Begin
 , WriteLn;
 , WriteLn ('OList record #' , I: 3 , '  ****************************');
 , WriteLn;
 , Obj ^ := OList ^;
 , ObjDisplay (Obj);
 , I := I + 1
            End (*If*)
        End (*While*);
      WriteLn;
      WriteLn ('Total of ' , I - 1: 0 , ' records.');
      WriteLn;
      WriteLn ('Random treasure list:');
      For I := 1 to ObjListLen Do
        Begin
          WriteLn ('Treasure type ' , I: 0 , ':');
          For J := 1 to 6 Do
            Begin
 , Loc := ObjIndex [I , J];
 , Write ('   ' , Loc: 3 , ': ');
 , If Loc > 0
 , Then
                Begin
                  Seek (OList , ObjIndex [I , J] - 1);
                  Get (OList);
                  PrintObj (OList ^ , False , True)
                End (*If*)
 , Else
                Write ('Nothing.');
 , WriteLn
            End (*For*)
        End (*For*);
      Write (Chr (12))
    End.
