
    Const
      LenEvent = 20;
    
    Var
      Event : Packed Array [1 .. LenEvent] of Varying [11] of Char;
      NextEvent : String;
    
    Procedure InitEvents;
    
      Begin
        Event [ 1] := '00:01:00.00';
        Event [ 2] := '00:05:00.00';
        Event [ 3] := '00:10:00.00';
        Event [ 4] := '04:30:00.00';
        Event [ 5] := '04:45:00.00';
        Event [ 6] := '04:55:00.00';
        Event [ 7] := '04:58:59.00';
        Event [ 8] := '04:59:00.00';
        Event [ 9] := '07:10:00.00';
        Event [10] := '12:00:00.00';
        Event [11] := '14:30:00.00';
        Event [12] := '14:45:00.00';
        Event [13] := '14:55:00.00';
        Event [14] := '14:59:59.00';
        Event [15] := '15:00:00.00';
        Event [16] := '15:04:00.00';
        Event [17] := '19:00:00.00';
        Event [18] := '20:59:00.00';
        Event [19] := '22:40:00.00';
        Event [20] := '23:55:00.00';
        NextEvent := 'INITIALIZE '
      End (*InitEvents*);
    
    Procedure MonStrike (Rm: RmCodeType);
    
      Var
        NonDMs, NumSp, AClass, NumPlyrs, MonNum, ILoop, NumMons,
        Damage, TempFat: Integer;
        Plyr, TUser: UserPoint;
        Monster: MonsterPoint;
        AtkFlag: Boolean;
        ESpeed, Speed: Integer;
      
      Begin
        TUser := User;
        Speed := MSpeed;
        ESpeed := 10;
        If NUsers = 1 Then
          Begin
            Speed := 1;
            ESpeed := 40
          End (*If*);
        With Room [Rm] Do
          Begin
            If RmMonsterTail <> NIL
            Then
              If Not RmMonsterTail ^.Permanent
              Then
                ESpeed := ESpeed Div 5;
            NonDMs := 0;
            NumPlyrs := 0;
            Plyr := RmPlayerTail;
            While Plyr <> NIL Do
              Begin
                If Not Plyr ^.Invisible
                Then
                  NonDMs := NonDMs + 1;
                NumPlyrs := NumPlyrs + 1;
                Plyr := Plyr ^.Next
              End (*While*);
            If (EncounterTime > 0) And (WhichEncounter > 0)
            Then
              If Rnd ((EncounterTime * 25) Div ESpeed) <= 3
              Then
                Begin
                  ILoop := 1;
                  While (EncIndex [WhichEncounter,
                         Min (6, ILoop + 1)] > 0) And (ILoop < 6) Do
                    ILoop := ILoop + 1;
                  If EncIndex [WhichEncounter, 1] > 0
                  Then
                    Begin
                      MonNum := EncIndex [WhichEncounter, Rnd (ILoop)];
                      NumMons := Rnd (Max (1, NonDMs - 1));
                      If Rnd (4) = 2
                      Then
                        NumMons := Rnd (Max (1, NonDMs - 1) * 2);
                      Find (MList, MonNum);
                      For ILoop := 1 to NumMons Do
                        Begin
                          New (Monster);
                          Monster ^ := MList ^;
                          Monster ^.Hits := Min (Monster ^.MaxHits,
                            Max (1, Round (Monster ^.Hits * 0.8 + Monster ^.
                            Hits * Rnd (40) / 100)));
                          Monster ^.Lvl := Min (25, Max (1, Monster ^.Lvl +
                                                2 - Rnd (3)));
                          InsertMonster (Monster, Rm)
                        End (*For*);
                      Plyr := RmPlayerTail;
                      For ILoop := 1 to NumPlyrs Do
                        Begin
                          If Not Plyr ^.Auto
                          Then
                            Plyr ^.EncountStop := True;
                          If NoTimeOut (Plyr)
                          Then
                            Begin
                              If NonDMs <= 1
                              Then
                                B1 := '0You encounter '
                              Else
                                B1 := '0Your party encounters ';
                              If NumMons = 1
                              Then
                                Begin
                                  If Cap (Monster ^.Name [1]) in
                                     ['A', 'E', 'I', 'O', 'U']
                                  Then
                                    B1 := B1 + 'an '
                                  Else
                                    B1 := B1 + 'a ';
                                  Ps (Monster ^.Name, B2);
                                  B1 := B1 + B2
                                End (*If*)
                              Else
                                Begin
                                  Pn (NumMons, B2);
                                  B1 := B1 + B2;
                                  Ps (Monster ^.Name, B2);
                                  B1 := B1 + B2 + 's'
                                End (*Else*);
                              B1 := B1 + '!';
                              QOut (Plyr ^.Trm, B1)
                            End (*If*);
                          Plyr := Plyr ^.Next
                        End (*For*)
                    End (*If*)
                End (*If*);
            Monster := RmMonsterTail;
            If Not Safe
            Then
              While Monster <> NIL Do
                With Monster ^ Do
                  Begin
                    AtkFlag := False;
                    If (DefPlayer = NIL) And (Top or (Num < 9))
                    Then
                      If SlowReact And (Rnd (Speed * 2) = 1) Or FastReact
                      Then
                        Begin
                          AtkFlag := True;
                          Plyr := RmPlayerTail;
                          For ILoop := 1 to Rnd (NumPlyrs) - 1 Do
                            Plyr := Plyr ^.Next;
                          If Not Plyr ^.Evil And Not Plyr ^.Invisible And
                             Not Plyr ^.Hidden
                          Then
                            DefPlayer := Plyr
                          Else
                            AtkFlag := False
                        End (*If*)
                      Else
                        If MoralReact And (Rnd (Speed) = 1)
                        Then
                          Begin
                            Plyr := RmPlayerTail;
                            DefPlayer := Plyr;
                            For ILoop := 1 to NumPlyrs Do
                              Begin
                                If (Plyr ^.Pty < DefPlayer ^.Pty) And
                                   (Rnd (3) <= 2)
                                Then
                                  DefPlayer := Plyr;
                                Plyr := Plyr ^.Next
                              End (*For*);
                            If (DefPlayer ^.Pty > 7) Or DefPlayer ^.Invisible
                            Then
                              DefPlayer := NIL
                            Else
                              AtkFlag := True
                          End (*If*);
                    User := DefPlayer;
                    If User <> NIL Then
                      Term := User ^.Trm;
                    Plyr := User;
                    If AtkFlag
                    Then
                      Begin
                        MReact := 0;
                        PM (Monster, True, B1);
                        Ps (Plyr ^.Name, B2);
                        B1 := '0' + B1 + ' attacks ' + B2 + '!';
                        For ILoop := 1 to MsgTerm (TermList, Local) Do
                          QOut (TermList [ILoop], B1);
                        PM (Monster, True, B1);
                        B1 := '0' + B1 + ' attacks you!';
                        QOut (Plyr ^.Trm, B1)
                      End (*If*);
                    If (DefPlayer <> NIL) And (Rnd (Speed) = 1) And Not
                       (MReact in [1, 2, 3])
                    Then
                      Begin
                        If Regenerate Then
                          Hits := Min (MaxHits, Hits + Lvl Div 2 + 1);
                        Plyr := DefPlayer;
                        Plyr ^.HitAtTime := RealTime;
                        AClass := - (Plyr ^.AC - 10);
                        If (Rnd (19) <> 19) And (Rnd (21) < 9 - Lvl +
                            Plyr ^.Lvl + AClass + Plyr ^.Dex Div 6) And
                            (MReact <> 6) Or (Plyr ^.Hits = 0) or
                            (MReact = 4)
                        Then
                          Begin
                            If Not Plyr ^.Brief And NoTimeOut (Plyr)
                            Then
                              Begin
                                PM (Monster, True, B1);
                                B1 := '0' + B1 + ' misses you!';
                                QOut (Plyr ^.Trm, B1)
                              End (*If*)
                          End (*If*)
                        Else
                          With Plyr ^ Do
                            Begin
                              Damage := Monster ^.Lvl * 4;
                              Damage := Max (1, Damage + 3 - Rnd (5));
                              If Monster ^.MonSpells
                              Then
                                If Rnd (3) = 2
                                Then
                                  Begin
                                    Case Rnd (4) of
                                      1:
                                        NumSp := 3;
                                      2:
                                        NumSp := 4;
                                      3:
                                        NumSp := 8;
                                      4:
                                        NumSp := 16
                                    End (*Case*);
                                    User := Plyr;
                                    Term := Plyr ^.Trm;
                                    Ps (Monster ^.Name, B1);
                                    Ps (SpellList [NumSp], B2);
                                    B1 := '0The ' + B1 + ' casts a ' + B2 +
                                          ' spell on ';
                                    Ps (Name, B2);
                                    B1 := B1 + B2 + '!';
                                    For ILoop := 1 to MsgTerm (TermList, Local)
                                      Do QOut (TermList [ILoop], B1);
                                    Ps (Monster ^.Name, B1);
                                    Ps (SpellList [NumSp], B2);
                                    B1 := '0The ' + B1 + ' casts a ' + B2 +
                                          ' spell on you!';
                                    QOut (Term, B1);
                                    Damage := SpellMon (NumSp, Monster ^.Lvl,
                                              15, Plyr, NIL, NIL, Name);
                                    If Damage = 0 Then
                                      Damage := Monster ^.Lvl * 3
                                  End (*If*);
                              If MReact = 5 Then
                                Damage := Damage Div 2 + 1;
                              If MReact = 6 Then
                                Damage := Damage * 2;
                              TempFat := 0;
                              If NoTimeOut (Plyr)
                              Then
                                Case Rnd (100) of
                                  1, 2, 3, 4:
                                    Begin
                                      QOut (Term, '0Double damage!');
                                      Damage := Damage * 2
                                    End (*1*);
                                  12, 13, 14:
                                    Begin
                                      QOut (Term, '0Vital wound!');
                                      TempFat := Fatigue;
                                      Fatigue := 0
                                    End (*12*);
                                  18, 19, 20, 21:
                                    Begin
                                      MReact := 3;
                                      Damage := 0;
                                      Ps (Monster ^.Name, B1);
                                      B1 := '0The ' + B1 + ' fumbles!';
                                      QOut (Term, B1);
                                      Monster ^.DefPlayer := NIL
                                    End (*18*)
                                End (*Case*);
                              HitShArmor (Plyr, Damage);
                              If NoTimeOut (Plyr) Then
                                Begin
                                  PM (Monster, True, B1);
                                  B1 := '0' + B1;
                                  If Brief Then
                                    B1 := B1 + ' hits for '
                                  Else
                                    B1 := B1 + ' hits you for ';
                                  PrintDmg (Plyr, Damage, Brief, B2);
                                  B1 := B1 + B2;
                                  QOut (Term, B1)
                                End (*If*);
                              If Drain And (Rnd (4) = 4)
                              Then
                                If Lvl <= 1
                                Then
                                  Begin
                                    Con := 0;
                                    Dead := True;
                                    Hits := 0;
                                    Fatigue := 0
                                  End (*If*)
                                Else
                                  Begin
                                    If NoTimeOut (Plyr) Then
                                      QOut (Term,
                                            '0You feel weak and drained..');
                                    MaxHits := MaxHits - MaxHits Div Lvl;
                                    MaxFatigue := MaxFatigue -
                                                  MaxFatigue Div Lvl;
                                    MaxMagic := MaxMagic - MaxMagic Div Lvl;
                                    Lvl := Lvl - 1;
                                    For ILoop := 1 to 2 Do
                                      Case Rnd (4) of
                                        1:
                                          Str := Max (3, Str - 1);
                                        2:
                                          Int := Max (3, Int - 1);
                                        3:
                                          Dex := Max (3, Dex - 1);
                                        4:
                                          Con := Max (3, Con - 1)
                                      End (*Case*)
                                  End (*Else*);
                              If Hits + Damage <= Damage
                              Then
                                Begin
                                  Dead := True;
                                  Hits := 0;
                                  Fatigue := 0;
                                  User := Plyr;
                                  Term := Trm;
                                  For ILoop := 1 To MsgTerm (TermList, All) Do
                                    Begin
                                      Ps (Name, B2);
                                      B1 := '0### ' + B2 + ', the ' +
                                            CName [Class] + ', was just ';
                                      Case Rnd (3) Of
                                        1: B1 := B1 + 'slain';
                                        2: B1 := B1 + 'killed';
                                        3: B1 := B1 + 'murdered'
                                      End (*Case*);
                                      Ps (Monster ^.Name, B2);
                                      B1 := B1 + ' by a ' + B2 + '.';
                                      QOut (TermList [ILoop], B1);
                                      If Lvl > 4
                                      Then
                                        Begin
                                          Writev (B1,
                              '0### We shall all grieve for ', Pro [Sex], '.');
                                          QOut (TermList [ILoop], B1)
                                        End (*If*)
                                    End (*For*)
                                End (*If*)
                              Else
                                Begin
                                  If Poison And (Damage > 0)
                                  Then
                                    If (Rnd (Monster ^.Lvl * 2) > Lvl) And
                                       (Rnd (3) = 3)
                                    Then
                                      Begin
                                        If NoTimeOut (Plyr) Then
                                        QOut (Term, '0You''ve been poisoned!');
                                        Poisoned := True
                                      End (*If*);
                                  If Damage > Fatigue Then
                                    Hits := Max (0, Hits - Damage + Fatigue);
                                  Fatigue := Max (0, Fatigue - Damage);
                                  If TempFat > 0
                                  Then
                                    Fatigue := TempFat
                                End (*Else*);
                              Monster ^.MReact := 0
                            End (*With*);
                        If MReact = 4
                        Then
                          MReact := 0
                      End (*If*)
                    Else
                      If MReact in [1, 2, 3] Then
                        MReact := MReact - 1;
                    Monster := Monster ^.Next
                  End (*While*)
          End (*With*);
        User := TUser
      End (*MonStrike*);
    
    Procedure TimeCheck (Var NextCheck: String);
    
      Var
        EventNum, ILoop: Integer;
        Found: Boolean;
        T: Packed Array [1 .. 11] of Char;
      
      Begin
        User := UserTail;
        Term := User ^.Trm (* Select dummy term so MsgTerm doesn't blow up*);
        If NextCheck = 'INITIALIZE '
        Then
          Begin
            Time (T);
            For ILoop := LenEvent DownTo 1 Do
              If T <= Event [ILoop]
              Then
                NextCheck := Event [ILoop];
            If NextCheck = 'INITIALIZE '
            Then
              NextCheck := Event [1]
          End (*If*)
        Else
          Begin
            ILoop := LenEvent;
            Found := False;
            While Not Found And (ILoop >= 1) Do
              Begin
                Found := (NextCheck >= Event [ILoop]);
                ILoop := ILoop - 1
              End (*While*);
            If Found
            Then
              EventNum := ILoop + 1
            Else
              Abort ('0 Mil943 - Timed event not found!');
            Case EventNum of
              1 (*12:01 PM*):
                NextCheck := Event [2];
              2 (*12:05 AM*): ;
              3 (*12:10 AM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0You hear an owl hooting in the distance.');
              4 (* 4:30 AM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0>>> Program will abort at 5:00 AM.');
              5 (* 4:45 AM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                    '0>>> Program aborting in 15 minutes.');
              6 (* 4:55 AM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0>>> Program aborting in 5 minutes.');
              7 (* 4:59 AM*):
                Begin
                  For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                    QOut (TermList [ILoop],
           '0Wait until program aborts.  A hangup will cost you a con point.');
                  LastUpdate := RealTime - UpdatePeriod - 10 (*Force update*)
                End (*7*);
              8 (* 4:59 AM*):
                Begin
                  For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                    QOut (TermList [ILoop],
                          '0*** Warning ***  Program aborting.');
                  Off;
                  Abort ('0 Mil001 - Program took itself down.')
                End (*8*);
              9 (* 7:10 AM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0Good morning and welcome to Milieu!');
              10(*12:00 PM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0You hear the town clock strike the noon hour.');
              11(* 2:30 PM*): ;
              12(* 2:45 PM*): ;
              13(* 2:55 PM*): ;
              14(* 2:59 PM*): ;
              15(* 2:59 PM*): ;
              16(* 3:04 PM*): ;
              17(* 7:00 PM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0The sun sets in the west.');
              18(* 8:59 PM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0The town watch sets out on its patrol.');
              19(*10:40 PM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0You hear crickets chirping in the grass.');
              20(*11:55 PM*):
                For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                  QOut (TermList [ILoop],
                        '0The town clock strikes the midnight hour.')
            End (*Case*);
            If (EventNum > 2) Then
              If EventNum = LenEvent
              Then
                NextCheck := Event [1]
              Else
                NextCheck := Event [EventNum + 1]
          End (*Else*)
      End (*TimeCheck*);
    
    Procedure MonAttack;
    
      Var
        Plyr: UserPoint;
        TempFat: Integer;
        T: Packed Array [1 .. 11] of Char;
      
      Begin (*MonAttack*)
        Time (T);
        If (T >= NextEvent) or (NextEvent = 'INITIALIZE ')
        Then
          If NUsers > 0
          Then
            TimeCheck (NextEvent);
        Plyr := UserTail;
        While Plyr <> NIL Do
          Begin
            If Plyr ^.Status <> SLogin
            Then
              If Room [Plyr ^.RmCode].RmPlayerTail = Plyr
              Then
                MonStrike (Plyr ^.RmCode);
            Plyr := Plyr ^.NextUser
          End (*While*)
      End (*MonAttack*);
