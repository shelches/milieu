
    Type
      ParmType  = (DFlag, DNum, DWord, DOther);
      Parameter = Packed Record
                    PName: Ch2;
                    PType: ParmType
                  End (*Parameter*);
      PType     = Packed Array [1..42] of Parameter;
    
    Var
      Parms     : PType;
                  
    Function GetEditParm (Var ParmL : PType; LPList: Integer;
                          Var Word: Alfa; Var Num : Integer;
                          Var Flag : Boolean; Var Buffer : BufType;
                          Var LenBuf: LenBufType;
                          Var Loc : Integer) : Integer; Forward;
                          
    Procedure Add (N : Integer; P : Ch2; T : ParmType); Forward;
    
    Procedure AssocErr; Forward;
    
    Procedure ModPlayer (Var Player: UserPoint; OnLine: Boolean);
    
      Var
        NP, ILoop, WhichParm, Number: Integer;
        Ch: Char;
        Word: Alfa;
        Flag: Boolean;
        Index: Integer;
      
      Procedure InitUsrParms;
      
        Begin
          Add (1, 'NA', DWord);
          Add (2, 'ZZ', DWord);
          Add (3, 'WE', DNum);
          Add (4, 'LV', DNum);
          Add (5, 'CL', DWord);
          Add (6, 'VI', DNum);
          Add (7, 'MV', DNum);
          Add (8, 'MA', DNum);
          Add (9, 'MM', DNum);
          Add (10, 'EX', DNum);
          Add (11, 'AC', DNum);
          Add (12, 'RO', DNum);
          Add (13, 'BR', DFlag);
          Add (14, 'ST', DNum);
          Add (15, 'IN', DNum);
          Add (16, 'DX', DNum);
          Add (17, 'PT', DNum);
          Add (18, 'EC', DFlag);
          Add (19, 'CO', DNum);
          Add (20, 'SE', DWord);
          Add (21, 'xx', DNum);
          Add (22, 'PW', DWord);
          Add (23, 'MO', DNum);
          Add (24, 'LA', DNum);
          Add (25, 'IV', DFlag);
          Add (26, 'FA', DNum);
          Add (27, 'MF', DNum);
          Add (28, 'PO', DFlag);
          Add (29, 'PL', DFlag);
          Add (30, 'HD', DFlag);
          Add (31, 'TG', DFlag);
          Add (32, 'MB', DFlag);
          Add (33, 'AG', DFlag);
          Add (34, 'EV', DFlag);
          Add (35, 'SL', DNum);
          Add (36, 'TL', DNum);
          Add (37, 'NO', DFlag);
          Add (38, 'SS', DNum);
          Add (39, 'TS', DNum);
          Add (40, 'BS', DNum);
          Add (41, 'PS', DNum)
        End (*InitUsrParms*);

      Begin
        InitUsrParms;
        NP := 0;
        WhichParm := GetEditParm (Parms, 41, Word, Number, Flag,
                                  Buffer, LenBuf, Loc);
        While WhichParm > 0 Do
          With Player ^ Do
            Begin
              NP := NP + 1;
              If User ^.Assoc And (WhichParm in [3,11,20,21,25,29,34,37])
              Then
                Begin
                  Writev (B1, '0',
                          Parms[WhichParm].PName, ' - Illegal access.');
                  QOut (Term, B1);
                  AssocErr;
                  Loc := LenBuf + 1
                End (*If*)
              Else
                Case WhichParm of
                  1:
                    Name := Word;
                  2:
                    If Not User ^.Master
                    Then
                      QOut (Term,
                           '0Only master DMs may activate DM priviledges.')
                    Else
                      Begin
                        Ch := Cap (Word [1]);
                        If Ch in ['D', 'A', 'M', 'N']
                        Then
                          Case Ch of
                            'D':
                              Begin
                                SSJ := True;
                                Assoc := False;
                                Master := False
                              End (*'D'*);
                            'A':
                              Begin
                                SSJ := True;
                                Assoc := True;
                                Master := False
                              End (*'A'*);
                            'M':
                              Begin
                                SSJ := True;
                                Assoc := False;
                                Master := True
                              End (*'M'*);
                            'N':
                              Begin
                                SSJ := False;
                                Assoc := False;
                                Master := False
                              End (*'N'*)
                          End (*Case*)
                        Else
                          QOut (Term,
                           '0Error.  ZZ must = None, Assistant, DM or Master.')
                      End (*Else*);
                  3:
                    Weight := Max (0, Min (5000, Number));
                  4:
                    Lvl := Max (0, Min (25, Number));
                  5:
                    Begin
                      Ch := Cap (Word [1]);
                      If Ch in ['B', 'F', 'T', 'C', 'M', 'R', 'P', 'D']
                      Then
                        Case Ch of
                          'B':
                            Class := Barbarian;
                          'F':
                            Class := Fighter;
                          'T':
                            Class := Thief;
                          'C':
                            Class := Cleric;
                          'M':
                            Class := MagicUser;
                          'R':
                            Class := Ranger;
                          'P':
                            Class := Paladin;
                          'D':
                            Class := DM
                        End (*Case*)
                      Else
                        QOut (Term, '0Illegal class type.')
                    End (*5*);
                  6:
                    Hits := Max (0, Min (2500, Number));
                  7:
                    MaxHits := Max (0, Min (2500, Number));
                  8:
                    Magic := Max (0, Min (2500, Number));
                  9:
                    MaxMagic := Max (0, Min (2500, Number));
                  10:
                    Begin
                      Number := Max (0, Min (MaxInt, Number));
                      Experience := Number
                    End (*10*);
                  11:
                    AC := Max (-32, Min (31, Number));
                  12:
                    If OnLine Then
                      Begin
                        DeletePlayer (Player, RmCode);
                        PlacePlayer (Player, Number)
                      End (*If*)
                    Else
                      RmCode := Number;
                  13:
                    Brief := Flag;
                  14:
                    Str := Max (-10, Min (25, Number));
                  15:
                    Int := Max (-10, Min (25, Number));
                  16:
                    Dex := Max (-10, Min (25, Number));
                  17:
                    Pty := Max (-10, Min (25, Number));
                  18:
                    Echo := Flag;
                  19:
                    Con := Max (-10, Min (25, Number));
                  20:
                    Begin
                      Word [1] := Cap (Word [1]);
                      If Word [1] = 'M'
                      Then
                        Sex := Male
                      Else
                        If Word [1] = 'F'
                        Then
                          Sex := Female
                        Else
                          QOut (Term, '0Sex must be male or female.')
                    End (*20*);
                  22:
                    If User ^.Master
                    Then
                      Begin
                        CapAlfa (Word);
                        PW := Hash (Word, 10)
                      End (*If*)
                    Else
                      QOut (Term, '0Only master DMs may alter passwords.');
                  23:
                    Begin
                      Number := Max (0, Min (MaxInt, Number));
                      Money := Number
                    End (*23*);
                  24:
                    LastAccess := Max (0, Min (31, Number));
                  25:
                    Invisible := Flag;
                  26:
                    Fatigue := Max (0, Min (2500, Number));
                  27:
                    MaxFatigue := Max (0, Min (2500, Number));
                  28:
                    Poisoned := Flag;
                  29:
                    Playtester := Flag;
                  30:
                    Hidden := Flag;
                  31:
                    TGuild := Flag;
                  32:
                    MesBlock := Flag;
                  33:
                    AGuild := Flag;
                  34:
                    Evil := Flag;
                  35:
                    SpellDay := Max (0, Min (5, Number));
                  36:
                    SendDay := Max (0, Min (31, Number));
                  37:
                    Nonexistant := Flag;
                  38:
                    SSharp := Min (7, Max (0, Number Div 10));
                  39:
                    SThrust := Min (7, Max (0, Number Div 10));
                  40:
                    SBlunt := Min (7, Max (0, Number Div 10));
                  41:
                    SLong := Min (7, Max (0, Number Div 10));
                End (*Case*);
              WhichParm := GetEditParm (Parms, 41, Word, Number, Flag,
                                        Buffer, LenBuf, Loc);
            End (*While*);
        If NP > 0
        Then
          QOut (Term, '0Player modified.')
      End (*ModPlayer*);
    
    Procedure EditPlayer (EditCmd: Integer; Which: Alfa);
    
      Var
        Player: UserPoint;
      
      Begin
        Player := NIL;
        If EditCmd = 4
        Then
          QOut (Term, '0You can''t create players.')
        Else
          Begin
            Player := FindUser (Which, UserTail);
            If Player = NIL
            Then
              QOut (Term, '0Player not found.')
            Else
              Case EditCmd of
                1:
                  ModPlayer (Player, True);
                2:
                  If User ^.Assoc
                  Then
                    AssocErr
                  Else
                    Begin
                      Ps (Player^.Name, B1);
                      B1 := '0### A lightning bolt hits ' + B1;
                      Writev (B2, ' and turns ', Pro [Player^.Sex],
                              ' into ashes!');
                      B1 := B1 + B2;
                      For ILoop := 1 to MsgTerm (TermList, SysMsg) Do
                        QOut (TermList [ILoop], B1);
                      Player ^.Dead := True;
                      Player ^.Hits := 0
                    End (*Else*);
                3:
                  PlayerDisplay (Player)
              End (*Case*)
          End (*Else*)
      End (*EditPlayer*);
    
    Procedure EditFile (EditCmd: Integer; Which: Alfa);
    
      Var
        Player: UserPoint;
        Exists: Boolean;
      
      Begin
        Exists := True;
        ReadPlayer (Player, Which);
        If Player ^.Name = Empty Then
          Begin
            QOut (Term, '0Entry not found.');
            Exists := False;
            Player ^.Name := Which
          End (*If*);
        Case EditCmd of
          1: (*Modify*)
            Begin
              ModPlayer (Player, False);
              WritePlayer (Player, True);
              WritePlayer (Player, False)
            End (*If*);
          2: (*Dispose*)
            If Exists
            Then
              Begin
                DeleteUsr (Player ^.Name);
                WritePlayer (Player, False);
                QOut (Term, '0Player erased.')
              End (*If*)
            Else
              WritePlayer (Player, False);
          3:
            Begin
              If Exists Then
                PlayerDisplay (Player);
              WritePlayer (Player, False)
            End (*3*);
          4:
            If Not Exists
            Then
              Begin
                Player ^.LastAccess := 1;
                QOut (Term, '0Entry created.');
                ModPlayer (Player, False);
                WritePlayer (Player, True);
                WritePlayer (Player, False)
              End (*If*)
            Else
              Begin
                QOut (Term, '0Player already exists in file.');
                WritePlayer (Player, False)
              End (*Else*)
        End (*Case*)
      End (*EditFile*);
    
    Procedure EditRoom (EditCmd: Integer; Rm: Integer);
    
      Var
        NP, N, ILoop, WhichParm, Number: Integer;
        Word: Alfa;
        Flag: Boolean;
      
      Procedure InitRoom;
      
        Begin
          Add (1, 'DI', DNum);
          Add (2, 'DR', DNum);
          Add (3, 'N ', DNum);
          Add (4, 'S ', DNum);
          Add (5, 'E ', DNum);
          Add (6, 'W ', DNum);
          Add (7, 'U ', DNum);
          Add (8, 'D ', DNum);
          Add (9, 'OU', DNum);
          Add (10, 'EN', DNum);
          Add (11, 'ET', DNum);
          Add (12, 'NO', DFlag);
          Add (13, 'SA', DFlag)
        End (*InitRoom*);
          
      Begin
        InitRoom;
        If (Rm <= 0) Or (Rm > NumRooms)
        Then
          QOut (Term, '0Room number out of bounds.')
        Else
          Case EditCmd of
            1:
              Begin
                Rm := S (Rm);
                NP := 0;
                WhichParm := GetEditParm (Parms, 13, Word, Number, Flag,
                                          Buffer, LenBuf, Loc);
                While WhichParm > 0 Do
                  With Room [Rm] Do
                    Begin
                      NP := NP + 1;
                      Case WhichParm of
                        1:
                          DescCode := Max (0, Min (StrPerSeg, Number));
                        2:
                          DescRec := Max (0, Min (256, Number));
                        3, 4, 5, 6, 7, 8:
                          Begin
                            Number := Max (0, Min (NumRooms, Number));
                            Adjoin [WhichParm - 2] := Number
                          End (*Else*);
                        9:
                          Out := Max (0, Min (NumRooms, Number));
                        10:
                          WhichEncounter := Max (0, Min (Lencounter, Number));
                        11:
                          EncounterTime := Max (0, Min (255, Number));
                        12:
                          NotifyDm := Flag;
                        13:
                          Safe := Flag
                      End (*Case*);
                      WhichParm := GetEditParm (Parms, 13, Word, Number, Flag,
                                                Buffer, LenBuf, Loc)
                    End (*While*);
                If NP > 0
                Then
                  QOut (Term, '0Room modified.')
              End (*1*);
            2:
              Begin
                Rm := S (Rm);
                Room [Rm] := ProtoRoom;
                QOut (Term, '0Room initialized.');
              End;
            3:
              Begin
                Rm := S (Rm);
                RoomDisplay (Rm, User ^.Brief);
                With Room [Rm] Do
                  Begin
                    B1 := '0';
                    For ILoop := 1 to 6 Do
                      Begin
                        Writev (B2, Cap (DirList [ILoop, 1]), '=',
                                Adjoin [ILoop]: 0, ', ');
                        B1 := B1 + B2
                      End (*For*);
                    If Out > 0
                    Then
                      Begin
                        Writev (B2, 'OUT=', Out: 0, ', ');
                        B1 := B1 + B2
                      End (*If*);
                    Writev (B2, 'DR=', DescRec: 0, ', DI=', DescCode: 0,
                            ', EN=', WhichEncounter: 0,
                            ', ET=', EncounterTime: 0, '.');
                    B1 := B1 + B2;
                    QOut (Term, B1);
                    If NotifyDm Then
                      QOut (Term, '0Dm notified upon entry.');
                    If Safe Then
                      QOut (Term, '0Room is haven against attack.')
                  End (*With*)
              End (*3*);
            4:
              If Not User ^.Master
              Then
                QOut (Term,
                     '0Sorry, only master DMs may create additional roomsegs.')
              Else
                AddSeg
          End (*Case*)
      End (*EditRoom*);
    
    Procedure EditMonster (EditCmd: Integer; Which: Alfa;
                           MNum, Whatcode: Integer);
      
      Var
        Monster: MonsterPoint;
        Object: ObjectPoint;
        NP, WhichParm, Number, Rm: Integer;
        Dummy, Word: Alfa;
        Flag: Boolean;
      
      Procedure InitMon;
      
        Begin
          Add (1, 'DE', DFlag);
          Add (2, 'BL', DFlag);
          Add (3, 'FO', DFlag);
          Add (4, 'GU', DFlag);
          Add (5, 'AT', DFlag);
          Add (6, 'SR', DFlag);
          Add (7, 'MO', DFlag);
          Add (8, 'FL', DFlag);
          Add (9, 'AS', DFlag);
          Add (10, 'LV', DNum);
          Add (11, 'HI', DNum);
          Add (12, 'MH', DNum);
          Add (13, 'EX', DNum);
          Add (14, 'PE', DFlag);
          Add (15, 'MA', DFlag);
          Add (16, 'TR', DNum);
          Add (17, 'NA', DWord);
          Add (18, 'FR', DFlag);
          Add (19, 'IN', DFlag);
          Add (20, 'RE', DFlag);
          Add (21, 'DR', DFlag);
          Add (22, 'PO', DFlag);
          Add (23, 'AM', DFlag);
          Add (24, 'UN', DFlag);
          Add (25, 'SP', DFlag);
          Add (26, 'PA', DNum);
        End (*InitMon*);
        
      Begin
        If WhatCode = 10
        Then
          GetWord (Dummy, Rm, Buffer, LenBuf, Loc)
        Else
          Begin
            Rm := MNum;
            Dummy := Which
          End (*Else*);
        If (Rm <= 0) or (Rm > NumRooms) Or (Dummy <> Blanks)
        Then
          QOut (Term, '0Illegal location number.')
        Else
          Begin
            If WhatCode = 10
            Then
              Begin
                Rm := S (Rm);
                Monster := FindMonster (Which, MNum, Room[Rm].RmMonsterTail);
                If EditCmd = 4
                Then
                  Begin
                    New (Monster);
                    Monster ^ := ProtoMonster;
                    Monster ^.Name := Which;
                    InsertMonster (Monster, Rm);
                    QOut (Term, '0Monster created.')
                  End (*If*)
              End (*If*)
            Else
              If (Rm >= 1) And (Rm <= RanMonLen)
              Then
                Begin
                  New (Monster);
                  Find (MList, Rm);
                  Monster ^ := MList ^
                End (*If*)
              Else
                Begin
                  QOut (Term, '0Bad MList number.');
                  WhichParm := 0;
                  Monster := NIL
                End (*Else*);
            If Monster <> NIL
            Then
              Case EditCmd of
                1,4 (*Modify, create*):
                  With Monster ^ Do
                    Begin
                      InitMon;
                      NP := 0;
                      WhichParm := GetEditParm (Parms, 26, Word, Number, Flag,
                                             Buffer, LenBuf, Loc);
                      While WhichParm > 0 Do
                        Begin
                          If (WhatCode = 13) And User ^.Assoc
                          Then
                            Begin
                              AssocErr;
                              Loc := LenBuf + 1
                            End (*If*)
                          Else
                            Begin
                              NP := NP + 1;
                              Case WhichParm of
                                1:
                                  Defend := Flag;
                                2:
                                  Block := Flag;
                                3:
                                  Follow := Flag;
                                4:
                                  Guard := Flag;
                                5:
                                  AtkLastAggr := Flag;
                                6:
                                  SlowReact := Flag;
                                7:
                                  MoralReact := Flag;
                                8:
                                  Flee := Flag;
                                9:
                                  Assistance := Flag;
                                10:
                                  Lvl := Max (0, Min (25, Number));
                                11:
                                  Hits := Max (0, Min (2500, Number));
                                12:
                                  MaxHits := Max (0, Min (2500, Number));
                                13:
                                  Experience := Max (0, Min (MaxInt, Number));
                                14:
                                  Permanent := Flag;
                                15:
                                  Magic := Flag;
                                16:
                                  WhichObj := Max (0, Min (Number, ObjListLen));
                                17:
                                  Name := Word;
                                18:
                                  FastReact := Flag;
                                19:
                                  Invisible := Flag;
                                20:
                                  Regenerate := Flag;
                                21:
                                  Drain := Flag;
                                22:
                                  Poison := Flag;
                                23:
                                  AntiMagic := Flag;
                                24:
                                  Undead := Flag;
                                25:
                                  MonSpells := Flag;
                                26:
                                  MParley := Max (0, Min (30, Number))
                              End (*Case*)
                            End (*Else*);
                          WhichParm := GetEditParm (Parms, 26, Word, Number,
                                        Flag, Buffer, LenBuf, Loc)
                        End (*While*);
                      If MaxHits < Hits
                      Then
                        MaxHits := Hits;
                      If NP > 0
                      Then
                        QOut (Term, '0Monster modified.')
                    End (*1*);
                2 (*Dispose*):
                  If WhatCode = 10
                  Then
                    Begin
                      DeleteMonster (Monster, Rm);
                      Destroy (Monster);
                      QOut (Term, '0Monster disposed.')
                    End (*If*)
                  Else
                    QOut (Term, '0MList cannot be disposed.');
                3 (*Display*):
                  MonDisplay (Monster)
              End (*Case*)
            Else
              QOut (Term, '0Monster not found.');
            If (WhatCode = 13) And (Monster <> NIL)
            Then
              Begin
                Locate (MList, Rm);
                MList ^ := Monster ^;
                Put (MList);
                Reset (MList);
                Dispose (Monster)
              End (*If*)
          End (*Else*)
      End (*EditMonster*);
    
    Procedure ModObject (Object: ObjectPoint);

      Var
        NP, WhichParm, Number, ILoop: Integer;
        Word: Alfa;
        Flag: Boolean;
        TName: Varying [20] of Char;

      Procedure InitObj;
      
        Begin
          Add (1, 'NA', DOther);
          Add (2, 'AR', DWord);
          Add (3, 'CA', DFlag);
          Add (4, 'WE', DNum);
          Add (5, 'VA', DNum);
          Add (6, 'MA', DFlag);
          Add (7, 'PE', DFlag);
          Add (8, 'TY', DWord);
          Add (9, 'TO', DNum);
          Add (10, 'MI', DNum);
          Add (11, 'MH', DNum);
          Add (12, 'SL', DNum);
          Add (13, 'WP', DNum);
          Add (14, 'SF', DNum);
          Add (15, 'SH', DNum);
          Add (16, 'AF', DNum);
          Add (17, 'AH', DNum);
          Add (18, 'DI', DNum);
          Add (19, 'DR', DNum);
          Add (20, 'IN', DFlag);
          Add (21, 'MU', DNum);
          Add (22, 'SP', DNum);
          Add (23, 'CC', DFlag);
          Add (24, 'CT', DNum);
          Add (25, 'CI', DNum);
          Add (26, 'XX', DNum);
          Add (27, 'CL', DNum);
          Add (28, 'DC', DFlag);
          Add (29, 'DT', DNum);
          Add (30, 'DL', DNum);
          Add (31, 'UL', DNum);
          Add (32, 'CH', DNum);
          Add (33, 'RO', DNum);
          Add (34, 'WT', DWord);
          NP := 0
        End (*InitObj*);
      
      Procedure SetClass (Obj: ObjectPoint; Class: ObClassType);
      
        Begin
          With Obj ^ Do
            Begin
              ObClass := Class;
              Case Class of
                Portal:
                  Begin
                    ToWhere := 1;
                    Carry := False
                  End (*Portal*);
                Weap:
                  Begin
                    MinHP := 1;
                    MaxHP := 1;
                    Strikes := 1;
                    WeaPlus := 0;
                    WeapType := Sharp
                  End (*Weap*);
                Shield:
                  Begin
                    ShPlus := 1;
                    ShHits := 5
                  End (*Shield*);
                Armor:
                  Begin
                    ArmPlus := 1;
                    ArmHits := 5
                  End (*Armor*);
                Coins:
                  Multiplier := 1;
                Scroll:
                  Spell := 1;
                Chest:
                  Begin
                    Closed := False;
                    Locked := 0;
                    Trap := 0;
                    NumInside := 0;
                    ObjectTail := NIL
                  End (*Chest*);
                Door:
                  Begin
                    Carry := False;
                    DToWhere := 1;
                    DClosed := False;
                    DTrap := 0;
                    DLocked := 0
                  End (*Door*);
                Keys:
                  UnLock := 0;
                MagDevice:
                  Begin
                    MSpell := 1;
                    NumCharges := 1
                  End (*MagDevice*);
                Teleport:
                  Begin
                    TToWhere := 1;
                    TActiveRm := 1
                  End (*TelePort*)
              End (*Case*)
            End (*With*)
        End (*SetClass*);

      Procedure BadClass;
      
        Begin
          Writev (B1, '0', Parms[WhichParm].PName: 3,
                  ' - Bad parameter for this obtype.  Mod not made.');
          QOut (Term, B1)
        End (*BadClass*);
    
      Begin (*ModObject*)
        InitObj;
        If (Object <> NIL)
        Then
          With Object ^ Do
            Begin
              NP := NP + 1;
              WhichParm := GetEditParm (Parms, 34, Word, Number,
                              Flag, Buffer, LenBuf, Loc);
              While WhichParm > 0 Do
                Begin
                  Case WhichParm of
                    1:
                      Begin
                        While (Buffer [Loc] <> '"') And (Loc <= LenBuf) Do
                          Loc := Loc + 1;
                        If Loc < LenBuf
                        Then
                          Begin
                            Loc := Loc + 1;
                            TName := '                    ';
                            TName := '';
                            ILoop := 1;
                            While (Buffer [Loc] <> '"') And (Loc <= LenBuf) Do
                              Begin
                                If ILoop <= 20
                                Then
                                  Begin
                                    TName := TName + Buffer [Loc];
                                    ILoop := ILoop + 1
                                  End (*If*);
                                Loc := Loc + 1
                              End (*While*);
                            Loc := Loc + 1;
                            If (Pos ('*', TName) = 0) or (Pos (',', TName) = 0)
                            Then
                              QOut (Term, '0Illegal name.')
                            Else
                              Name := TName
                          End (*If*)
                      End (*1*);
                    2:
                      Case Cap (Word [1]) of
                        'A':
                          If Word [2] in ['N', 'n']
                          Then
                            Article := An
                          Else
                            Article := A;
                        'N':
                          Article := None;
                        'S':
                          Article := Some;
                        'T':
                          Article := The
                      End (*Case*);
                    3:
                      Carry := Flag;
                    4:
                      Weight := Max (0, Min (1000, Number));
                    5:
                      Price := Max (0, Min (16000, Number));
                    6:
                      Magic := Flag;
                    7:
                      Permanent := Flag;
                    8:
                      Begin
                        CapAlfa (Word);
                        Case Word [1] of
                          'A':
                            SetClass (Object, Armor);
                          'C':
                            Case Word [2] of
                              'A':
                                SetClass (Object, Card);
                              'H':
                                SetClass (Object, Chest);
                              'O':
                                SetClass (Object, Coins)
                            End (*Case*);
                          'D':
                            SetClass (Object, Door);
                          'K':
                            SetClass (Object, Keys);
                          'M':
                            If Word[2] = 'I'
                            Then
                              SetClass (Object, Misc)
                            Else
                              SetClass (Object, MagDevice);
                          'P':
                            SetClass (Object, Portal);
                          'S':
                            If Word[2] = 'C'
                            Then
                              SetClass (Object, Scroll)
                            Else
                              SetClass (Object, Shield);
                          'T':
                            If Word[2] = 'E'
                            Then
                              SetClass (Object, Teleport)
                            Else
                              SetClass (Object, Treasure);
                          'W':
                            SetClass (Object, Weap)
                        End (*Case*)
                      End (*8*);
                    9:
                      If ObClass in [Portal, Door, Teleport]
                      Then
                        ToWhere := Max (0, Min (NumRooms, Number))
                      Else
                        BadClass;
                    10:
                      If ObClass = Weap Then
                        MinHp := Max (0, Min (127, Number))
                      Else
                        BadClass;
                    11:
                      If ObClass = Weap Then
                        MaxHp := Max (0, Min (127, Number))
                      Else
                        BadClass;
                    12:
                      If ObClass = Weap
                      Then
                        Strikes := Max (0, Min (511, Number))
                      Else
                        BadClass;
                    13:
                      If ObClass = Weap
                      Then
                        WeaPlus := Max (-5, Min (10, Number))
                      Else
                        BadClass;
                    14, 16:
                      If ObClass in [Shield, Armor]
                      Then
                        ShPlus := Max (-5, Min (10, Number))
                      Else
                        BadClass;
                    15, 17:
                      If ObClass in [Shield, Armor]
                      Then
                        ShHits := Max (0, Min (511, Number))
                      Else
                        BadClass;
                    18:
                      DescCode := Max (0, Min (StrPerSeg, Number));
                    19:
                      DescRec := Max (0, Min (256, Number));
                    20:
                      Invisible := Flag;
                    21:
                      If ObClass = Coins
                      Then
                        Multiplier := Max (0, Min (127, Number))
                      Else
                        BadClass;
                    22:
                      If ObClass = Scroll
                      Then
                        Spell := Max (0, Min (NumSpells, Number))
                      Else
                        If ObClass = MagDevice
                        Then
                          MSpell := Max (0, Min (NumSpells, Number));
                    23:
                      If ObClass = Chest
                      Then
                        Closed := Flag
                      Else
                        BadClass;
                    24:
                      If ObClass = Chest
                      Then
                        Trap := Max (0, Min (50, Number))
                      Else
                        BadClass;
                    25:
                      If ObClass = Chest
                      Then
                        NumInside := Max (0, Min (10, Number))
                      Else
                        BadClass;
                    26:
                      QOut (Term, '0Not implemented yet.');
                    27:
                      If ObClass = Chest
                      Then
                        Locked := Max (0, Min (1023, Number))
                      Else
                        BadClass;
                    28:
                      If ObClass = Door
                      Then
                        DClosed := Flag
                      Else
                        BadClass;
                    29:
                      If ObClass = Door
                      Then
                        DTrap := Max (0, Min (50, Number))
                      Else
                        BadClass;
                    30:
                      If ObClass = Door
                      Then
                        DLocked := Max (0, Min (1023, Number))
                      Else
                        BadClass;
                    31:
                      If ObClass = Keys
                      Then
                        UnLock := Max (0, Min (1023, Number))
                      Else
                        BadClass;
                    32:
                      If ObClass = MagDevice
                      Then
                        NumCharges := Max (0, Min (127, Number))
                      Else
                        BadClass;
                    33:
                      If ObClass = Teleport
                      Then
                        TActiveRm := Max (0, Min (2048, Number))
                      Else
                        BadClass;
                    34:
                      If ObClass = Weap
                      Then
                        If Cap (Word [1]) in ['B', 'P', 'S', 'T']
                        Then
                          Case Cap (Word [1]) of
                            'B':
                              WeapType := Blunt;
                            'P':
                              WeapType := Long;
                            'S':
                              WeapType := Sharp;
                            'T':
                              WeapType := Thrust
                          End (*Case*)
                        Else
                          QOut (Term, '0Illegal weapon type.')
                      Else
                        BadClass;
                  End (*Case*);
                  WhichParm := GetEditParm (Parms, 34, Word, Number,
                                  Flag, Buffer, LenBuf, Loc)
                End (*While*);
              If ObClass = Weap
              Then
                If MaxHp < MinHp
                Then
                  MaxHp := MinHp + 1;
              If NP > 0
              Then
                QOut (Term, '0Object modified.')
            End (*With*)
        Else
          QOut (Term, '0Object not found.')
      End (*ModObject*);
    
    Procedure EditObject (EditCmd: Integer; Var Which: Alfa; ONum : Integer);
    
      Var
        Object, Container, DoorP : ObjectPoint;
        Player : UserPoint;
        Monster : MonsterPoint;
        EditT : (InRoom, OnPlayer, InContainer, OnMonster, InFile, ENone);
        Word1, Word2 : Alfa;
        Temp, PWeight, Num2, Rm : Integer;
        Found: Boolean;
        PTemp: ObjectPoint;
      
      Function InsertObject (Var Tail: ObjectPoint): ObjectPoint;
      
        Var
          Obj: ObjectPoint;
        
        Begin
          New (Obj);
          Obj ^ := ProtoObject;
          Obj ^.Next := Tail;
          Tail := Obj;
          InsertObject := Obj;
          QOut (Term, '0Object created.')
        End (*InsertObject*);
      
      Begin
        EditT := ENone;
        Object := NIL;
        GetWord (Word1, Rm, Buffer, LenBuf, Loc);
        CapAlfa (Word1);
        If (Word1 = Blanks) And (Rm > 0)
        Then
          If (Rm > NumRooms)
          Then
            QOut (Term, '0Illegal location number.')
          Else
            Begin
              Rm := S (Rm);
              EditT := InRoom;
              If EditCmd = 4
              Then
                Begin
                  PTemp := Room[Rm].RmObjectTail;
                  Object := InsertObject (PTemp);
                  Room[Rm].RmObjectTail := PTemp
                End
              Else
                Object := FindObject (Which, ONum, Room[Rm].RmObjectTail)
            End (*Else*)
        Else
          If Word1 = 'FILE      '
          Then
            Begin
              EditT := InFile;
              GetWord (Word2, Num2, Buffer, LenBuf, Loc);
              ReadPlayer (Player, Word2);
              If Player ^.Name = Empty
              Then
                Begin
                  QOut (Term, '0Player entry not found.');
                  EditT := ENone
                End (*If*)
              Else
                If EditCmd = 4
                Then
                  Begin
                    PTemp := Player ^.ObjectTail;
                    Object := InsertObject (PTemp);
                    Player ^.ObjectTail := PTemp
                  End
                Else
                  Object := FindObject (Which, ONum, Player ^.ObjectTail)
            End (*If*)
          Else
            Begin
              Player := FindUser (Word1, UserTail);
              If Player <> NIL
              Then
                Begin
                  EditT := OnPlayer;
                  If EditCmd = 4
                  Then
                    Begin
                      PTemp := Player ^.ObjectTail;
                      Object := InsertObject (PTemp);
                      Player ^.ObjectTail := PTemp
                    End
                  Else
                    Object := FindObject (Which, ONum, Player ^.ObjectTail)
                End (*If*)
              Else
                Begin
                  GetWord (Word2, Rm, Buffer, LenBuf, Loc);
                  If (Rm < 1) or (Rm > NumRooms) or (Word2 <> Blanks)
                  Then
                    QOut (Term, '0Illegal room number.')
                  Else
                    Begin
                      EditT := OnMonster;
                      Rm := S (Rm);
                      Monster := FindMonster (Word1, ONum,
                                              Room[Rm].RmMonsterTail);
                      If Monster <> NIL
                      Then
                        If EditCmd = 4
                        Then
                          Begin
                            PTemp := Monster ^.ObjectTail;
                            Object := InsertObject (PTemp);
                            Monster ^.ObjectTail := PTemp
                          End (*If*)
                        Else
                          Object := FindObject (Which, ONum,
                                                Monster ^.ObjectTail)
                      Else
                        Begin
                          EditT := InContainer;
                          Container := FindObject (Word1, ONum,
                                                   Room[Rm].RmObjectTail);
                          If Container <> NIL
                          Then
                            If Container ^.ObClass = Chest
                            Then
                              If EditCmd = 4
                              Then
                                Begin
                                  PTemp := Container ^.ObjectTail;
                                  Object := InsertObject (PTemp);
                                  Container ^.ObjectTail := PTemp
                                End (*If*)
                              Else
                                Object := FindObject (Which, ONum,
                                                      Container ^.ObjectTail)
                        End (*Else*)
                    End (*Else*)
                End (*Else*)
            End (*Else*);
        If (Object <> NIL) And (EditT <> ENone)
        Then
          Begin
            If EditCmd = 4
            Then
              PWeight := 0
            Else
              PWeight := Object ^.Weight;
            Case EditCmd of
              1, 4:
                ModObject (Object);
              2:
                Begin
                  Case EditT of
                    InRoom:
                      If DeleteObject (Object, Room [Rm].RmObjectTail)
                      Then
                        Room[Rm].RmObjectTail := Room[Rm].RmObjectTail ^.Next;
                    OnMonster:
                      If DeleteObject (Object, Monster ^.ObjectTail)
                      Then
                        Monster ^.ObjectTail := Monster ^.ObjectTail ^.Next;
                    InContainer:
                      If DeleteObject (Object, Container ^.ObjectTail)
                      Then
                        Container ^.ObjectTail := Container^.ObjectTail^.Next;
                    OnPlayer, InFile:
                      Begin
                        If DeleteObject (Object, Player ^.ObjectTail)
                        Then
                          Player ^.ObjectTail := Player ^.ObjectTail ^.Next;
                        Player ^.Weight := Player ^.Weight - PWeight
                      End (*OnPlayer*)
                  End (*Case*);
                  Dispose (Object);
                  QOut (Term, '0Object deleted.')
                End (*2*);
              3:
                ObjDisplay (Object)
            End (*Case*);
            If (EditCmd in [1,4]) And (EditT in [OnPlayer, InFile])
            Then
              Begin
                Player ^.Weight := Player ^.Weight - PWeight + Object ^.Weight;
                If Player ^.Weight > Player ^.Str * 10 Then
                  QOut (Term,
                        '0Warning: Weight carried exceeds player''s capacity.')
              End (*If*);
            If EditT = InFile
            Then
              Begin
                If EditCmd in [1, 4] Then
                  WritePlayer (Player, True);
                WritePlayer (Player, False)
              End
            Else
              If (EditT = InRoom) And (Object ^.ObClass = Door)
              Then
                Case EditCmd of
                  1:
                    QOut (Term, '0Don''t forget to modify the companion door.');
                  2:
                    QOut (Term, '0Don''t forget to delete the companion door.');
                  4:
                    QOut (Term, '0Don''t forget to create a companion door.')
                End (*Case*)
          End (*If*)
        Else
          QOut (Term, '0Object not found.')
      End (*EditObject*);
    
    Procedure EditOList (EditCmd: Integer; OIndex: Integer);
    
      Var
        Obj : ObjectPoint;
      
      Begin
        If EditCmd = 2
        Then
          QOut (Term, '0OList cannot be disposed of.')
        Else
          If (OIndex < 1) or (OIndex > RanObjLen) Then
            QOut (Term, '0Illegal OList number.')
          Else
            Begin
              Find (OList, OIndex);
              New (Obj);
              Obj ^ := OList ^;
              Case EditCmd of
                1, 4:
                  Begin
                    ModObject (Obj);
                    Locate (OList, OIndex);
                    OList ^ := Obj ^;
                    Put (OList);
                    Reset (OList);
                    QOut (Term, '0OList updated.')
                  End (*1*);
                3:
                  ObjDisplay (Obj)
              End (*Case*);
              Dispose (Obj)
            End (*Else*)
      End (*EditOList*);
    
    Procedure EditDscrpt (EditCmd: Integer; Rec: Integer);
    
      Var
        Line: Integer;
        Dummy: Alfa;
        Done: Boolean;
        
      Begin
        If (Rec < 1)
        Then
          QOut (Term, '0Illegal EDesc record number.')
        Else
          Begin
            GetWord (Dummy, Line, Buffer, LenBuf, Loc);
            Find (EDesc, Rec);
            If Ufb (EDesc)
            Then
              CurrentRec := 0
            Else
              CurrentRec := Rec;
            Case EditCmd of
              1 (* Modify*):
                Begin
                  If Ufb (EDesc)
                  Then
                    QOut (Term, '0No such EDesc record.')
                  Else
                    If (Line < 1) Or (Line > 10)
                    Then
                      QOut (Term, '0Illegal EDesc line.')
                    Else
                      Begin
                        User ^.Entry := XDesc;
                        User ^.Data := Rec * 10 + (Line - 1)
                      End (*Else*)
                End (*1*);
              2 (* Delete *):
                QOut (Term, '0EDesc records cannot be deleted.');
              3 (* Display *):
                Begin
                  If Ufb (EDesc)
                  Then
                    QOut (Term, '0No such EDesc record.')
                  Else
                    Begin
                      Writev (B1, '0EDesc record ', Rec: 0, ':');
                      QOut (Term, B1);
                      If Line > 0
                      Then
                        If Line <= 10
                        Then
                          Begin
                            Writev (B1, '0', Line: 2, ':  ', EDesc ^[Line]);
                            QOut (Term, B1)
                          End (*If*)
                        Else
                          QOut (Term, '0Illegal line number.')
                      Else
                        For Line := 1 to 10 Do
                          Begin
                            Writev (B1, '0', Line: 2, ':  ', EDesc ^[Line]);
                            QOut (Term, B1)
                          End (*For*)
                    End (*Else*)
                End (*3*);
              4 (* Create *):
                Begin
                  If Ufb (EDesc)
                  Then
                    Begin
                      If Rec > 1
                      Then
                        Begin
                          Find (EDesc, Rec-1);
                          If Ufb (EDesc)
                          Then
                            Begin
                              CurrentRec := 0;
                              QOut (Term, '0Record beyond end of file.')
                            End (*If*)
                          Else
                            Begin
                              Find (EDesc, Rec);
                              If Ufb (EDesc)
                              Then
                                Begin
                                  For ILoop := 1 to 10 Do
                                    EDesc ^[ILoop] := '';
                                  Locate (EDesc, Rec);
                                  Put (EDesc);
                                  Reset (EDesc);
                                  CurrentRec := 0;
                                  QOut (Term, '0EDesc record created.')
                                End (*If*)
                              Else
                                Begin
                                  CurrentRec := 0;
                                  QOut (Term, '0EDesc record already exists.')
                                End (*Else*)
                            End (*Else*)
                        End (*If*)
                      Else
                        Begin
                          CurrentRec := 0;
                          QOut (Term, '0Illegal EDesc record.')
                        End (*Else*)
                    End (*If*)
                  Else
                    QOut (Term, '0EDesc record already exists.')
                End (*4*)
            End (*Case*)
          End (*Else*)
      End (*EditDscrpt*);
    
    Function GetEditParm;
    
      Var
        Parm: Ch2;
        WhichParm: Integer;
        Found: Boolean;
      
      Begin
        Parm := '  ';
        Word := Blanks;
        Num := 0;
        Flag := False;
        If Buffer [Loc] = ',' Then
          Loc := Loc + 1;
        While (Buffer [Loc] = ' ') And (Loc <= LenBuf) Do
          Loc := Loc + 1;
        If Loc > LenBuf
        Then
          GetEditParm := 0
        Else
          Begin
            Parm[1] := Cap (Buffer [Loc]);
            Loc := Loc + 1;
            If (Buffer [Loc] <> '=') And (Loc <= LenBuf) Then
              Begin
                Parm[2] := Cap (Buffer [Loc]);
                Loc := Loc + 1
              End (*If*);
            While Buffer [Loc] in ['A' .. 'Z', 'a' .. 'z'] Do
              Loc := Loc + 1;
            If (Buffer [Loc] <> '=') Or (Loc >= LenBuf) Then
              Begin
                GetEditParm := 0;
                Writev (B1, '0Bad parameter: ', Parm: 2);
                QOut (Term, B1)
              End (*If*)
            Else
              Begin
                Loc := Loc + 1;
                Found := False;
                WhichParm := 0;
                While Not Found And (WhichParm <= LPList) Do
                  Begin
                    WhichParm := WhichParm + 1;
                    Found := (Parm = ParmL[WhichParm].PName)
                  End (*While*);
                If Not Found Then
                  Begin
                    WhichParm := 0;
                    Writev (B1, '0Unknown parameter: ', Parm: 2);
                    QOut (Term, B1)
                  End (*If*)
                Else
                  Case ParmL[WhichParm].PType of
                    DFlag:
                      Begin
                        Buffer [Loc] := Cap (Buffer [Loc]);
                        If Buffer [Loc] = 'T'
                        Then
                          Flag := True
                        Else
                          If Buffer [Loc] = 'F'
                          Then
                            Flag := False
                          Else
                            Begin
                              WhichParm := 0;
                              Writev (B1, '0', Parm: 2,
                                      ' must be true or false.');
                              QOut (Term, B1)
                            End (*Else*);
                        While Not (Buffer [Loc] in [' ', ',']) And
                                  (Loc <= LenBuf) Do
                          Loc := Loc + 1
                      End (*DFlag*);
                    DNum:
                      Begin
                        GetWord (Word, Num, Buffer, LenBuf, Loc);
                        If Word <> Blanks Then
                          Begin
                            WhichParm := 0;
                            Writev (B1, '0', Parm: 2, ' must be a number.');
                            QOut (Term, B1)
                          End (*If*)
                      End (*DNum*);
                    DWord:
                      Begin
                        GetWord (Word, Num, Buffer, LenBuf, Loc);
                        If (Word = Blanks) And (Num <> 0) Then
                          Begin
                            WhichParm := 0;
                            Writev (B1, '0', Parm: 2,
                                    ' - only string allowed.');
                            QOut (Term, B1)
                          End (*If*)
                      End (*DWord*);
                    DOther:
                  End (*Case*);
                GetEditParm := WhichParm
              End (*Else*)
          End (*Else*)
      End (*GetEditParm*);
                      
    Procedure Add;
    
      Begin
        With Parms [N] Do
          Begin
            PName := P;
            PType := T
          End (*With*)
      End (*Add*);
      
    Procedure AssocErr;
    
      Begin
        QOut (Term, '0Sorry, associate DMs can''t do that.')
      End (*AssocErr*);
          
    Procedure EnterDesc;

      Var
        Rec, Line, Count, Slash: Integer;

      Begin
        Slash := -1;
        B1 := '';
        For ILoop := 1 To Min (80, LenBuf) Do
          Begin
            B1 := B1 + Buffer [ILoop];
            If Buffer [ILoop] = '/'
            Then
              Slash := Slash + 1
          End (*For*);
        Count := Ord (Buffer [1]) - Ord ('0');
        If ((Count <> Slash) Or (Buffer [2] <> '/')) And (LenBuf <> 0)
        Then
          QOut (Term, '0Bad description.')
        Else
          Begin
            Rec := User ^.Data DIV 10;
            Line := (User ^.Data MOD 10) + 1;
            If Rec <> CurrentRec
            Then
              Find (EDesc, Rec);
            EDesc^ [Line] := B1;
            Locate (EDesc, Rec);
            Put (EDesc);
            Reset (EDesc);
            CurrentRec := 0;
            QOut (Term, '0EDesc record updated.')
          End (*Else*);
        User ^.Entry := XEdit;
        Loc := LenBuf + 1;
        PromptUser (User)
      End (*EnterDesc*);

    Procedure EditETlist (EditCmd: Integer; EditCode: Integer; Index: Integer);

      Var
        Dummy: Alfa;
        Temp: Integer;

      Begin
        Case EditCode Of
          16 (*EList*):
            Case EditCmd Of
              1:
                If (Index > 0) And (Index <= LEncounter)
                Then
                  Begin
                    For ILoop := 1 To 6 Do
                      Begin
                        GetWord (Dummy, Temp, Buffer, LenBuf, Loc);
                        EncIndex [Index, ILoop] := Temp
                      End (*For*);
                    QOut (Term, '0EList modified.')
                  End (*If*)
                Else
                  QOut (Term, '0Illegal EList number.');
              2:
                QOut (Term, '0EList entries cannot be deleted.');
              3:
                If Index = 0
                Then
                  For ILoop := 1 To LEncounter Do
                    Begin
                      Writev (B1, '0', ILoop: 3, '.', EncIndex [ILoop, 1]: 4,
                              EncIndex [ILoop, 2]: 4, EncIndex [ILoop, 3]: 4,
                              EncIndex [ILoop, 4]: 4, EncIndex [ILoop, 5]: 4,
                              EncIndex [ILoop, 6]: 4);
                      QOut (Term, B1)
                    End (*For*)
                Else
                  If (Index > 0) And (Index <= LEncounter)
                  Then
                    Begin
                      Writev (B1, '0', Index: 3, '.', EncIndex [Index, 1]: 4,
                              EncIndex [Index, 2]: 4, EncIndex [Index, 3]: 4,
                              EncIndex [Index, 4]: 4, EncIndex [Index, 5]: 4,
                              EncIndex [Index, 6]: 4);
                      QOut (Term, B1)
                    End (*If*)
                  Else
                    QOut (Term, '0Illegal EList number.');
              4:
                QOut (Term, '0EList entries cannot be created.')
            End (*Case*);
          17 (*TList*):
            Case EditCmd Of
              1:
                If (Index > 0) And (Index <= ObjListLen)
                Then
                  Begin
                    For ILoop := 1 To 6 Do
                      Begin
                        GetWord (Dummy, Temp, Buffer, LenBuf, Loc);
                        ObjIndex [Index, ILoop] := Temp
                      End (*For*);
                    QOut (Term, '0TList modified.')
                  End (*If*)
                Else
                  QOut (Term, '0Illegal TList number.');
              2:
                QOut (Term, '0TList entries cannot be deleted.');
              3:
                If Index = 0
                Then
                  For ILoop := 1 To ObjListLen Do
                    Begin
                      Writev (B1, '0', ILoop: 3, '.', ObjIndex [ILoop, 1]: 4,
                              ObjIndex [ILoop, 2]: 4, ObjIndex [ILoop, 3]: 4,
                              ObjIndex [ILoop, 4]: 4, ObjIndex [ILoop, 5]: 4,
                              ObjIndex [ILoop, 6]: 4);
                      QOut (Term, B1)
                    End (*For*)
                Else
                  If (Index > 0) And (Index <= ObjListLen)
                  Then
                    Begin
                      Writev (B1, '0', Index: 3, '.', ObjIndex [Index, 1]: 4,
                              ObjIndex [Index, 2]: 4, ObjIndex [Index, 3]: 4,
                              ObjIndex [Index, 4]: 4, ObjIndex [Index, 5]: 4,
                              ObjIndex [Index, 6]: 4);
                      QOut (Term, B1)
                    End (*If*)
                  Else
                    QOut (Term, '0Illegal TList number.');
              4:
                QOut (Term, '0TList entries cannot be created.')
            End (*Case*)
        End (*Case*)
      End (*EditETlist*);

    Procedure Edit (Var Buffer: BufType; LenBuf: LenBufType);
    
      Var
        EditCmd, What, Which: Alfa;
        EditNum, Dummy, WhatCode, RmOrMonNum: Integer;
        EditList: NameTList;
      
      Procedure InitEditor;
      
        Begin
          EditList [1] := 'MODIFY    ';
          EditList [2] := 'DELETE    ';
          EditList [3] := 'DISPLAY   ';
          EditList [4] := 'CREATE    ';
          EditList [5] := 'STOP      ';
          EditList [6] := 'XQ        ';
          EditList [7] := 'END       ';
          EditList [8] := 'ROOM      ';
          EditList [9] := 'OBJECT    ';
          EditList [10] := 'MONSTER   ';
          EditList [11] := 'PLAYER    ';
          EditList [12] := 'FILE      ';
          EditList [13] := 'MLIST     ';
          EditList [14] := 'OLIST     ';
          EditList [15] := 'DESCRIPTIO';
          EditList [16] := 'ELIST     ';
          EditList [17] := 'TLIST     '
        End (*InitEditor*);
          
      Begin
        InitEditor;
        GetWord (EditCmd, Dummy, Buffer, LenBuf, Loc);
        CapAlfa (EditCmd);
        EditNum := WordMatch (EditCmd, 7, EditList);
        GetWord (What, Dummy, Buffer, LenBuf, Loc);
        CapAlfa (What);
        WhatCode := WordMatch (What, 17, EditList);
        If EditNum = 0
        Then
          Begin
            If EditCmd <> Blanks
            Then
              QOut (Term, '0Illegal edit command.')
          End (*If*)
        Else
          If (WhatCode <= 7) And Not (EditNum in [5,6,7])
          Then
            Begin
              Writev (B1, '0Bad operand - ', What);
              QOut (Term, B1)
            End (*If*)
          Else
            Begin
              GetWord (Which, RmOrMonNum, Buffer, LenBuf, Loc);
              Case EditNum of
                -1,0: ;
                1,2,3,4:
                  Case WhatCode of
                    8:
                      If (EditNum <> 3) And User ^.Assoc
                      Then
                        AssocErr
                      Else
                        Begin
                          EditRoom (EditNum, RmOrMonNum);
                          If EditNum = 3
                          Then
                            Begin
                              GetWord (EditCmd, Dummy, Buffer, LenBuf, Loc);
                              Dummy := Min (NumRooms, Dummy);
                              If Dummy > RmOrMonNum Then
                                While RmOrMonNum < Dummy Do
                                  Begin
                                    RmOrMonNum := RmOrMonNum + 1;
                                    QOut (Term, '0');
                                    EditRoom (EditNum, RmOrMonNum)
                                  End (*While*)
                            End (*If*)
                        End (*Else*);
                    9:
                      EditObject (EditNum, Which, RmOrMonNum);
                    14:
                      Begin
                        EditOList (EditNum, RmOrMonNum);
                        If (EditNum = 3) And (RmOrMonNum <> 0) Then
                          Begin
                            GetWord (EditCmd, Dummy, Buffer, LenBuf, Loc);
                            Dummy := Min (RanObjLen, Dummy);
                            If Dummy > RmOrMonNum Then
                              While RmOrMonNum < Dummy Do
                                Begin
                                  RmOrMonNum := RmOrMonNum + 1;
                                  QOut (Term, '0');
                                  Writev (B1, '0OList #', RmOrMonNum: 0, ', ');
                                  QOut (Term, B1);
                                  EditOList (EditNum, RmOrMonNum)
                                End (*While*)
                          End (*If*)
                      End (*14*);
                    10:
                      EditMonster (EditNum, Which, RmOrMonNum, WhatCode);
                    13:
                      Begin
                        EditMonster (EditNum, Which, RmOrMonNum, WhatCode);
                        If (EditNum = 3) And (RmOrMonNum <> 0) Then
                          Begin
                            GetWord (EditCmd, Dummy, Buffer, LenBuf, Loc);
                            Dummy := Min (RanMonLen, Dummy);
                            If Dummy > RmOrMonNum Then
                              While RmOrMonNum < Dummy Do
                                Begin
                                  RmOrMonNum := RmOrMonNum + 1;
                                  QOut (Term, '0');
                                  Writev (B1, '0MList #', RmOrMonNum: 0, ', ');
                                  QOut (Term, B1);
                                  EditMonster (EditNum, Which, RmOrMonNum,
                                               WhatCode)
                                End (*While*)
                          End (*If*)
                      End (*13*);
                    11:
                      EditPlayer (EditNum, Which);
                    15:
                      EditDscrpt (EditNum, RmOrMonNum);
                    12:
                      If (EditNum <> 3) And User ^.Assoc
                      Then
                        AssocErr
                      Else
                        EditFile (EditNum, Which);
                    16, 17:
                      If (EditNum <> 3) And User ^.Assoc
                      Then
                        AssocErr
                      Else
                        EditETlist (EditNum, WhatCode, RmOrMonNum)
                  End (*Case*);
                5,6,7:
                  Begin
                    User ^.Entry := XCmd;
                    If Not User ^.Brief Then
                      QOut (Term, '0Exiting the editor.')
                  End (*5*)
              End (*Case*)
            End (*Else*);
        Loc := LenBuf + 1;
        PromptUser (User)
      End (*Edit*);
