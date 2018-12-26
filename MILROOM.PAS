
    Const
      MaxUsers    = 8 (* Maximum number of users *);
      MaxPlusOne  = 9 (* MaxUsers + 1 *);
      RmLimit     = 89 (* MaxUsers * 10 + 9 *);
      MaxSegs     = 199;
    
    Type
      TalkHowType = (Local, Yell, Others, All, BrOthers, BrAll, NoBlock,
                     SysMsg);
      AdjoinType= Packed Array [1..6] of RmCodeType (*72 bits*);
      RoomType  = Packed Record
                    Adjoin: AdjoinType (*72*);
                    Out: RmCodeType (*12,84*);
                    DescCode: 0..63 (*6,90*);
                    DescRec: 0..255 (*8,98*);
                    LastDir: 0..8   (*4,102*);
                    WhichEncounter: 0..255 (*8,110*);
                    EncounterTime: 0..255 (*8,118*);
                    NotifyDM: Boolean (*1,119*);
                    Safe: Boolean (*1,120*);
                    RmPlayerTail: UserPoint (*16,136*);
                    RmMonsterTail: MonsterPoint (*16,152*);
                    RmObjectTail: ObjectPoint (*16,168*)
                  End (*RoomType*);
      RoomList  = Packed Array [0..RmLimit] of RoomType;
      RoomSeg   = Packed Array [0..9] of RoomType;
      BinFileType= File of RoomSeg;
    
    Var
      NUsers    : Integer;
      MSpeed    : Integer;
      NumRooms  : Integer;
      NumSegs   : Integer;
      CmdCode   : Integer;
      Room      : RoomList;
      SlotTBL   : Packed Array [0..MaxPlusOne] of Integer;
      Active    : Packed Array [0..MaxPlusOne] of Integer;
      ProtoRoom : RoomType;
      DirList   : Packed Array [1..7] of Varying [5] of Char;
      ECaves    : BinFileType;
  
    Procedure OpenCave;

      Var
        Error: Integer;

      Begin
        Open (ECaves, File_Name := 'EDUNGEON', History := Unknown,
              Access_Method := Direct, Error := Continue);
        Error := Status (ECaves);
        If Error <> 0
        Then
          Abort ('0 Mil910 - Error opening dungeon file.')
      End (*OpenCave*);

    Procedure CloseCave;

      Var
        Error: Integer;

      Begin
        Close (ECaves, Error := Continue);
        Error := Status (ECaves);
        If Error <> 0
        Then
          Abort ('0 Mil911 - Error closing dungeon file.')
      End (*CloseCave*);

    Function W (Rm: Integer): Integer;
    
      Var
        Where: Integer;
      
      Begin
        If (Rm < 0) Or (Rm > RmLimit)
        Then
          Where := 0
        Else
          Where := SlotTbl [Rm Div 10] * 10 + Rm - (Rm Div 10) * 10;
        If (Where < 0) or (Where > NumRooms) Then
          Where := 0;
        W := Where
      End (*W*);

    Procedure Condition (Plyr: UserPoint);

      Begin
        With Plyr^ Do
          Begin
            Writev (B1, '0You have ', Hits: 0, '/', MaxHits: 0,
                    ' vitality pts, ', Fatigue: 0, '/', MaxFatigue: 0,
                    ' fatigue pts, and ', Magic: 0, '/', MaxMagic: 0,
                    ' magic pts.');
            QOut (Term, B1)
          End (*With*)
      End (*Condition*);

    Procedure DisPlayer (Plyer: UserPoint);
    
      Var
        Count: Integer;
        Obj: ObjectPoint;
      
      Begin
        With Plyer^ Do
          Begin
            Ps (Name, B1);
            PNth (Lvl, B2);
            B1 := '0' + B1 + ', the ' + B2;
            Writev (B2, 'level ', CName [Class], ' ');
            B1 := B1 + B2;
            If Playtester Then
              B1 := B1 + '(Playtester) ';
            If SSJ And Not Assoc And Not Master Then
              B1 := B1 + '(DM) ';
            If SSJ and Assoc Then
              B1 := B1 + '(Assoc DM) ';
            If SSJ and Master Then
              B1 := B1 + '(Master DM) ';
            If User ^.SSJ Then
              Begin
                Writev (B2, 'in room ', RmCode: 0, '/', W (RmCode): 0);
                B1 := B1 + B2
              End (*If*);
            QOut (Term, B1);
            If Invisible Then
              If Nonexistant Then
                QOut (Term, '0You are nonexistant.')
              Else
                QOut (Term, '0You are currently invisible.');
            If TGuild Then
              QOut (Term, '0You are a member of the Thieves Guild.');
            If AGuild Then
              QOut (Term, '0You are a member of the Assassins Guild.');
            If Evil Then
              QOut (Term, '0You have fallen into the forces of evil.');
            Writev (B1, '0With ', Hits: 0, '/', MaxHits: 0, ' vitality pts, ',
                    Fatigue: 0, '/', MaxFatigue: 0, ' fatigue pts, and ',
                    Magic: 0, '/', MaxMagic: 0, ' magic pts.');
            QOut (Term, B1);
            If Poisoned Then
              QOut (Term, '0You are dying from poison!');
            Writev (B1, '0You have a defensive armor class of ', AC: 0, '.');
            QOut (Term, B1);
            Writev (B1, '0Str=', Str: 0, ', Int=', Int: 0, ', Dex=', Dex: 0,
                    ', Pty=', Pty: 0, ', Con=', Con: 0);
            QOut (Term, B1);
            Writev (B1, '0Weapon skills: Sharp-', SSharp*10: 1, '%,  Thrust-',
                    SThrust*10: 1, '%,  Blunt-', SBlunt*10: 1, '%,  Pole-',
                    SLong*10: 1, '%');
            QOut (Term, B1);
            PrintExp (Plyer);
            QOut (Term, '0');
            Writev (B1, '0You are carrying ', Weight: 0, ' lbs of items:');
            QOut (Term, B1);
            Obj := ObjectTail;
            Count := 0;
            While Obj <> NIL Do
              Begin
                Count := Count + 1;
                Writev (B1, '0    ', Count: 0, ') ');
                PrintObj (Obj ^, False, True, B2);
                B1 := B1 + B2;
                QOut (Term, B1);
                Obj := Obj ^.Next
              End (*While*);
            If Count > MaxObjs Then
              Begin
                Writev (B1, '0Only the first ', MaxObjs: 0,
                        ' items will be saved when you log out.');
                QOut (Term, B1)
              End (*If*);
            If User ^.SSJ Then
              Begin
                PNth (LastAccess, B1);
                B1 := '0Last logged in on the ' + B1 + 'of the month.';
                QOut (Term, B1)
              End (*If*)
          End (*With*)
      End (*PlayerDisplay*);
        
    Procedure ReadSeg (SlotNum, SegNum: Integer);

      Var
        RLoop, T, Rm, WRm : Integer;
        Pt3 : ObjectPoint;
        Pt4 : MonsterPoint;
        
      Begin
        SlotTbl [SlotNum] := SegNum;
        Find (ECaves, SegNum + 1);
        T := SlotNum * 10;
        For RLoop := 0 to 9 Do
          Begin
            Rm := RLoop + T;
            Room [Rm] := ECaves ^[RLoop];
            Room [Rm].RmPlayerTail := NIL;
            WRm := W (Rm);
            If Room[Rm].RmObjectTail <> NIL
            Then
              Begin
                Pt3 := Room[Rm].RmObjectTail;
                ReadUObj (WRm, Pt3, 0);
                Room[Rm].RmObjectTail := Pt3
              End;
            If Room[Rm].RmMonsterTail <> NIL
            Then
              Begin
                Pt4 := Room[Rm].RmMonsterTail;
                ReadMon (WRm, Pt4);
                Room[Rm].RmMonsterTail := Pt4
              End
          End (*For*)
      End (*ReadSeg*);

    Procedure WriteSeg (SlotNum, SegNum: Integer; Erase: Boolean);

      Var
        RLoop, T, Rm, WRm : Integer;
        Object, Obj2: ObjectPoint;
        Monster, Mon2: MonsterPoint;
      
      Begin
        Find (ECaves, SegNum + 1);
        T := SlotNum * 10;
        For RLoop := 0 to 9 Do
          Begin
            Rm := RLoop + T;
            ECaves ^[RLoop] := Room [Rm];
            WRm := W (Rm);
            With Room[Rm] Do
              Begin
                If RmObjectTail <> NIL
                Then
                  Begin
                    WriteUObj (WRm, RmObjectTail, 0);
                    If Erase Then
                      Begin
                        Object := RmObjectTail;
                        While Object <> NIL Do
                          Begin
                            Obj2 := Object ^.Next;
                            ODestroy (Object);
                            Object := Obj2
                          End (*While*)
                      End (*If*)
                  End (*If*)
                Else
                  DeleteUObj (WRm);
                If RmMonsterTail <> NIL
                Then
                  Begin
                    WriteMon (WRm, RmMonsterTail);
                    If Erase Then
                      Begin
                        Monster := RmMonsterTail;
                        While Monster <> NIL Do
                          Begin
                            Object := Monster ^.ObjectTail;
                            While Object <> NIL Do
                              Begin
                                Obj2 := Object ^.Next;
                                Dispose (Object);
                                Object := Obj2
                              End (*While*);
                            Mon2 := Monster ^.Next;
                            Dispose (Monster);
                            Monster := Mon2
                          End (*While*)
                      End (*If*)
                  End (*If*)
                Else
                  DeleteMon (WRm)
              End (*With*)
          End (*For*);
        Locate (ECaves, SegNum + 1);
        Put (ECaves);
        CloseCave;
        OpenCave
      End (*WriteSeg*);
    
    Function S (Rm: Integer): Integer;
    (* Return physical loc of room in room list *)
    
      Var
        ILoop, SegNum: Integer;
      
      Begin
        If (Rm < 1) Or (Rm >= NumSegs * 10) Then
          Abort (' Mil205 - Room # out of bounds!');
        SegNum := Rm Div 10;
        ILoop := 0;
        While (ILoop <= MaxUsers) And (SlotTbl[ILoop] <> SegNum) Do
          ILoop := ILoop + 1;
        If ILoop <= MaxUsers
        Then
          S := ILoop * 10 + Rm - SegNum * 10
        Else
          Begin
            ILoop := 0;
            While (ILoop <= MaxUsers) And (SlotTbl[ILoop] > -1) Do
              ILoop := ILoop + 1;
            If ILoop > MaxUsers Then
              Begin
                ILoop := 0;
                While (ILoop <= MaxUsers) And (Active [ILoop] > 0) Do
                  ILoop := ILoop + 1
              End (*If*);
            If ILoop > MaxUsers Then
              Abort ('0 Mil206 - Room buffer full!');
            If SlotTbl[ILoop] > -1 Then
              Begin
                WriteSeg (ILoop, SlotTbl [ILoop], True);
                SlotTBL [ILoop] := -1
              End (*If*);
            ReadSeg (ILoop, SegNum);
            S := ILoop * 10 + Rm - SegNum * 10
          End (*Else*)
      End (*S*);
    
    Procedure AddSeg;
    
      Var
        ILoop, JLoop: Integer;
      
      Begin
        If NumSegs > MaxSegs
        Then
          QOut (Term, '0 Sorry, max room limit reached.')
        Else
          Begin
            ILoop := 0;
            While (ILoop <= MaxUsers) And (Active [ILoop] > 0) Do
              ILoop := ILoop + 1;
            If ILoop > MaxUsers
            Then
              QOut (Term, '0 Mil209 - Room buffer full.')
            Else
              Begin
                If SlotTBL [ILoop] > - 1 Then
                  WriteSeg (ILoop, SlotTBL [ILoop], True);
                For JLoop := ILoop * 10 to ILoop * 10 + 9 Do
                  Room [JLoop] := ProtoRoom;
                SlotTBL [ILoop] := NumSegs;
                Writev (B1, '0New rooms ', NumSegs * 10: 1, ' to ',
                        NumSegs*10+9: 1, ' created.');
                QOut (Term, B1);
                NumSegs := NumSegs + 1;
                WriteSeg (ILoop, NumSegs - 1, False)
              End (*Else*)
          End (*Else*);
        NumRooms := NumSegs * 10 - 1
      End (*AddSeg*);
    
    Function SA (Rm: Integer): Integer;

      Var
        Seg, SegRm: Integer;

      Begin
        SegRm := S (Rm);
        Seg := SegRm Div 10;
        Active [Seg] := Active [Seg] + 1;
        SA := SegRm
      End (*SA*);

    Procedure Inactive (Rm: Integer);

      Var
        Seg: Integer;

      Begin
        Seg := Rm Div 10;
        If Active [Seg] = 0
        Then
          Abort (' Mil222 - Non active seg assumed active!');
        Active [Seg] := Active [Seg] - 1
      End (*Inactive*);
    
    Procedure StopPlyrAtk (Monster: MonsterPoint; Rm: RmCodeType);
    
      Var
        OtherPlayer: UserPoint;
      
      Begin
        With Room [Rm] Do
          Begin
            OtherPlayer := RmPlayerTail;
            While OtherPlayer <> NIL Do
              Begin
                If OtherPlayer ^.DefMon = Monster
                Then
                  OtherPlayer ^.DefMon := NIL;
                OtherPlayer := OtherPlayer ^.Next
              End (*While*)
          End (*With*)
      End (*StopPlyrAtk*);
    
    Procedure StopOtherAtk (Player: UserPoint; Rm: RmCodeType);
    
      Var
        OtherPlayer: UserPoint;
        OtherMonster: MonsterPoint;
      
      Begin
        Player ^.DefMon := NIL;
        Player ^.DefPlayer := NIL;
        With Room [Rm] Do
          Begin
            OtherPlayer := RmPlayerTail;
            While OtherPlayer <> NIL Do
              Begin
                If OtherPlayer ^.DefPlayer = Player
                Then
                  OtherPlayer ^.DefPlayer := NIL;
                OtherPlayer := OtherPlayer ^.Next
              End (*While*);
            OtherMonster := RmMonsterTail;
            While OtherMonster <> NIL Do
              Begin
                If OtherMonster ^.DefPlayer = Player
                Then
                  Begin
                    OtherMonster ^.DefPlayer := NIL;
                    If OtherMonster ^.MReact >= 5
                    Then
                      OtherMonster ^.MReact := 0
                  End (*If*);
                OtherMonster := OtherMonster ^.Next
              End (*While*)
          End (*While*)
      End (*StopOtherAtk*);
    
    Procedure DeleteMonster (Pt: MonsterPoint; Rm: RmCodeType);
    
      Var
        Pt2 : MonsterPoint;
        Found : Boolean;

      Begin
        If Pt = NIL
        Then
          Abort (' Mil86 - Cannot delete NIL monster!');
        With Room [Rm] Do
          Begin
            If Pt = RmMonsterTail
            Then
              RmMonsterTail := RmMonsterTail ^.Next
            Else
              Begin
                Found := False;
                Pt2 := RmMonsterTail;
                While Not Found And (Pt2 <> NIL) Do
                  If Pt2 ^.Next = Pt
                  Then
                    Found := True
                  Else
                    Pt2 := Pt2 ^.Next;
                If Found
                Then
                  Pt2 ^.Next := Pt ^.Next (* Delete *)
                Else
                  Abort (' Mil05 - Deleted mon not found')
              End (*Else*);
            FixMonCount (RmMonsterTail, Pt ^.Name);
            If RmPlayerTail <> NIL Then
              StopPlyrAtk (Pt, Rm)
          End (*With*)
      End (*DeleteMonster*);

    Procedure InsertMonster (Var Monster: MonsterPoint; Rm: RmCodeType);
      
      Begin
        With Room [Rm] Do
          Begin
            Monster ^.Next := RmMonsterTail;
            RmMonsterTail := Monster;
            FixMonCount (RmMonsterTail, Monster ^.Name)
          End (*With*)
      End (*InsertMonster*);
    
    Procedure CleanRm (Rm: RmCodeType);
    
      (* CleanRm removes old monster and objects that don't have the
         permanent bit set. *)
      
      Var
        NextMon, OldMon: MonsterPoint;
        NextObj, OldObj: ObjectPoint;
        
      Begin
        With Room [Rm] Do
          Begin
            OldObj := RmObjectTail;
            While OldObj <> NIL Do
              Begin
                NextObj := OldObj ^.Next;
                If Not (OldObj ^.Permanent) Then
                  Begin
                    If DeleteObject (OldObj, RmObjectTail) Then
                      RmObjectTail := RmObjectTail ^.Next;
                    ODestroy (OldObj)
                  End (*If*);
                OldObj := NextObj
              End (*While*);
            OldMon := RmMonsterTail;
            While OldMon <> NIL Do
              Begin
                NextMon := OldMon ^.Next;
                If OldMon ^.Permanent Then
                  OldMon ^.Hits := OldMon ^.MaxHits
                Else
                  Begin
                    DeleteMonster (OldMon, Rm);
                    Dispose (OldMon)
                  End (*Else*);
                OldMon := NextMon
              End (*While*)
          End (*With*)
      End (*CleanRm*);

    Procedure PlacePlayer (Var Plyr: UserPoint; Rm: RmCodeType);
    
      Var
        NewRm, Seg: Integer;
        
      Begin
        NewRm := SA (Rm);
        Plyr ^.Next := Room [NewRm].RmPlayerTail;
        Room [NewRm].RmPlayerTail := Plyr;
        Plyr ^.RmCode := NewRm
      End (*PlacePlayer*);
    
    Procedure DeletePlayer (Pt: UserPoint; Rm: RmCodeType);
    
      Var
        Pt2: UserPoint;
        Found: Boolean;
      
      Begin
        If Pt = NIL Then
          Abort ('0 Mil87 - Cannot delete NIL player!');
        With Room [Rm] Do
          Begin
            If Pt = RmPlayerTail
            Then
              Begin
                RmPlayerTail := RmPlayerTail ^.Next;
                If RmPlayerTail = NIL
                Then
                  CleanRm (Pt ^.RmCode)
                Else
                  If RmPlayerTail ^.Hits = 0
                  Then
                    CleanRm (Pt ^.RmCode)
              End (*If*)
            Else
              Begin
                Found := False;
                Pt2 := RmPlayerTail;
                While Not Found and (Pt2 <> NIL) Do
                  If Pt2 ^.Next = Pt
                  Then
                    Found := True
                  Else
                    Pt2 := Pt2 ^.Next;
                If Found
                Then
                  Pt2 ^.Next := Pt ^.Next
                Else
                  Abort ('0 Mil06 - Delete plyr not found!')
              End (*Else*);
            StopOtherAtk (Pt, Rm);
            Pt ^.Follow := NIL;
            InActive (Rm)
          End (*With*)
      End (*DeletePlayer*);
      
    Procedure DeleteUser (Pt: UserPoint; Var UserTail: UserPoint);

      Var
        Pt2: UserPoint;
        FollowPlyr: UserPoint;
        Found: Boolean;

      Function PFollow (Usr: UserPoint): UserPoint;

        Var
          Temp: UserPoint;
          Found: Boolean;

        Begin
          Found := False;
          Temp := Usr;
          While Not Found And (Temp <> NIL) Do
            If (Temp ^.Follow = Pt)
            Then
              Found := True
            Else
              Temp := Temp ^.Next;
          If Found
          Then
            PFollow := Temp
          Else
            PFollow := NIL
        End (*PFollow*);

      Begin (*DeleteUser*)
        If (Pt = NIL) Or (UserTail = NIL)
        Then
          Abort ('0 Mil88 - Cannot delete NIL user!');
        If Pt = UserTail
        Then
          UserTail := UserTail ^.NextUser
        Else
          Begin
            Found := False;
            Pt2 := UserTail;
            While Not Found and (Pt2 <> NIL) Do
              If Pt2 ^.NextUser = Pt
              Then
                Found := True
              Else
                Pt2 := Pt2 ^.NextUser;
            If Found
            Then
              Pt2 ^.NextUser := Pt ^.NextUser
            Else
              Abort ('0 Mil08 - Deleted record not found!')
          End (*Else*);
        If Pt ^.Status <> SLogin
        Then
          DeletePlayer (Pt, Pt ^.RmCode);
        Pt ^.RmCode := W (Pt ^.RmCode);
        FollowPlyr := PFollow (UserTail);
        While FollowPlyr <> NIL Do
          Begin
            FollowPlyr ^.Follow := NIL;
            FollowPlyr := PFollow (FollowPlyr ^.Next)
          End (*While*)
      End (*DeleteUser*);

    Procedure PlayerDisplay (Plyer: UserPoint);
    
      Begin
        DisPlayer (Plyer)
      End (*PlayerDisplay*);
      
    Procedure RoomDisplay (Rm: Integer; Brief: Boolean);
    
      Var
        ILoop, Count: Integer;
        Found: Boolean;
        Object: ObjectPoint;
        Monster: MonsterPoint;
        Player: UserPoint;
        Temp: Alfa;
        Tense: Packed Array [False .. True] of Packed Array [1..3] of Char;
      
      Begin
        B2 := '0You''re ';
        With Room [Rm] Do
          Begin
            PrintDesc (DescRec, DescCode, 0, Brief, B2, B1);
            If User ^.SSJ Then
              Begin
                Writev (B2, ' (', W (Rm): 0, ')');
                B1 := B1 + B2
              End (*If*);
            QOut (Term, B1);
            Count := 0;
            For ILoop := 1 to 6 Do
              If Adjoin [ILoop] <> 0
              Then
                Count := Count + 1;
            If Out > 0
            Then
              Count := Count + 1;
            If Count > 0
            Then
              Begin
                B1 := '0Obvious exits are ';
                For ILoop := 1 to 7 Do
                  Begin
                    If ILoop = 7
                    Then
                      Found := (Out <> 0)
                    Else
                      Found := (Adjoin [ILoop] <> 0);
                    If Found Then
                      Begin
                        Writev (B2, DirList[ILoop]);
                        B1 := B1 + B2;
                        If Count = 1
                        Then
                          Begin
                            B1 := B1 + '.';
                            QOut (Term, B1)
                          End (*If*)
                        Else
                          If Count > 2
                          Then
                            B1 := B1 + ', '
                          Else
                            B1 := B1 + ' and ';
                        Count := Count - 1
                      End (*If*)
                  End (*For*)
              End (*If*);
            Count := 0;
            Object := RmObjectTail;
            While Object <> NIL Do
              Begin
                If Not Object ^.Invisible or User ^.SSJ Then
                  Count := Count + 1;
                Object := Object ^.Next
              End (*While*);
            Monster := RmMonsterTail;
            While Monster <> NIL Do
              Begin
                If Monster ^.Top And (Not Monster ^.Invisible or User ^.SSJ)
                Then
                  Count := Count + 1;
                Monster := Monster ^.Next
              End (*While*);
            If Count > 0
            Then
              Begin
                B1 := '0You see ';
                Object := RmObjectTail;
                Monster := RmMonsterTail;
                ILoop := 0;
                While (ILoop < Count) And (Monster <> NIL) Do
                  Begin
                    If Monster ^.Top and (Not Monster ^.Invisible or
                                          User ^.SSJ)
                    Then
                      If Monster ^.Num = 1
                      Then
                        Begin
                          ILoop := ILoop + 1;
                          B1 := B1 + 'a';
                          If Cap (Monster ^.Name [1]) in ['A','E','I','O','U']
                          Then
                            B1 := B1 + 'n';
                          Ps (Monster ^.Name, B2);
                          B1 := B1 + ' ' + B2;
                          If Monster ^.Invisible and User ^.SSJ Then
                            B1 := B1 + ' (INV)';
                          Punctuate (ILoop, Count, B1)
                        End (*If*)
                      Else
                        Begin
                          ILoop := ILoop + 1;
                          Pn (Monster ^.Num, B2);
                          B1 := B1 + B2;
                          Ps (Monster ^.Name, B2);
                          B1 := B1 + B2 + 's';
                          If Monster ^.Invisible and User ^.SSJ Then
                            B1 := B1 + ' (INV)';
                          Punctuate (ILoop, Count, B1)
                        End (*Else*);
                    Monster := Monster ^.Next
                  End (*While*);
                While (ILoop < Count) And (Object <> NIL) Do
                  Begin
                    If Not Object ^.Invisible Or User ^.SSJ Then
                      Begin
                        ILoop := ILoop + 1;
                        PrintObj (Object ^, False, False, B2);
                        B1 := B1 + B2;
                        Punctuate (ILoop, Count, B1)
                      End (*If*);
                    Object := Object ^.Next
                  End (*While*);
                B1 := B1 + '.';
                QOut (Term, B1);
                QOut (Term, '0')
              End (*If*);
            Player := RmPlayerTail;
            Count := 0;
            While Player <> NIL Do
              Begin
                If (Player <> User) And Not Player^.Invisible And
                        (Not Player^.Hidden or User ^.SSJ)
                Then
                  Count := Count + 1;
                Player := Player ^.Next
              End (*While*);
            If Count > 0
            Then
              Begin
                Player := RmPlayerTail;
                ILoop := 0;
                B1 := '0';
                While Player <> NIL Do
                  Begin
                    If (Player <> User) And Not Player^.Invisible And
                        (Not Player^.Hidden or User^.SSJ)
                    Then
                      Begin
                        Ps (Player ^.Name, B2);
                        B1 := B1 + B2;
                        If Player ^.Hidden Then
                          B1 := B1 + ' (HID)';
                        ILoop := ILoop + 1;
                        Punctuate (ILoop, Count, B1)
                      End (*If*);
                    Player := Player ^.Next
                  End (*While*);
                If Count = 1
                Then
                  B1 := B1 + ' is also here.'
                Else
                  B1 := B1 + ' are also here.';
                QOut (Term, B1)
              End (*If*);
            Temp := User ^.Name;
            User ^.Name := 'you       ';
            Tense [False] := ' is';
            Tense [True] := '''re';
            Monster := RmMonsterTail;
            While Monster <> NIL Do
              Begin
                If Monster ^.DefPlayer <> NIL Then
                  Begin
                    PM (Monster, True, B1);
                    Ps (Monster ^.DefPlayer ^.Name, B2);
                    B1 := '0' + B1 + ' is attacking ' + B2 + '!';
                    QOut (Term, B1)
                  End (*If*);
                Monster := Monster ^.Next
              End (*While*);
            Player := RmPlayerTail;
            While Player <> NIL Do
              Begin
                If Player ^.DefMon <> NIL
                Then
                  If Player ^.DefMon ^.DefPlayer <> Player
                  Then
                    Begin
                      Ps (Player ^.Name, B1);
                      Writev (B2, Tense [Player = User]);
                      B1 := '0' + B1 + B2 + ' attacking ';
                      PM (Player^.DefMon, False, B2);
                      B1 := B1 + B2 + '!';
                      QOut (Term, B1)
                    End (*If*)
                  Else
                    If Player ^.DefPlayer <> NIL
                    Then
                      Begin
                        Ps (Player ^.Name, B1);
                        Writev (B2, Tense [Player = User]);
                        B1 := '0' + B1 + B2 + ' attacking ';
                        Ps (Player^.DefPlayer^.Name, B2);
                        B1 := B1 + B2 + '!';
                        QOut (Term, B1)
                      End (*If*);
                Player := Player ^.Next
              End (*While*);
            User ^.Name := Temp
          End (*With*)
      End (*RoomDisplay*);
    
    Function MsgTerm (Var TermList: TermIDType;
                          TalkHow:  TalkHowType): Integer;
      
      Var
        Factor, Count, ILoop: Integer;
        OtherPlayer: UserPoint;
      
      Function OkSend (Usr: UserPoint): Boolean;
      
        Begin
          OkSend := ((Usr <> User) And NoTimeOut (Usr) And
                     (Usr ^.Status <> SLogin))
        End (*OkSend*);

      Function NextOkSend (Usr: UserPoint): UserPoint;
      
        Var
          Found: Boolean;
        
        Begin
          Found := False;
          While (Usr <> NIL) And Not Found Do
            If OkSend (Usr)
            Then
              Found := True
            Else
              Usr := Usr ^.Next;
          If Found
          Then
            NextOkSend := Usr
          Else
            NextOkSend := NIL
        End (*NextOkSend*);
      
      Function MatchUser (Usr: UserPoint): UserPoint;
      
        Var
          Found: Boolean;
        
        Begin
          Found := False;
          While (Usr <> NIL) And Not Found Do
            If OkSend (Usr)
            Then
              Found := True
            Else
              Usr := Usr ^.NextUser;
          If Found
          Then
            MatchUser := Usr
          Else
            MatchUser := NIL
        End (*MatchUser*);
      
      Begin (*MsgTerm*)
        Count := 0;
        If Not User ^.Invisible or (CmdCode in [12, 13, 14, 16, 36, 37, 38]) or
           (TalkHow = SysMsg)
        Then
          If (TalkHow = Local) Or (TalkHow = Yell)
          Then
            With Room [User ^.RmCode] Do
              Begin
                OtherPlayer := NextOkSend (RmPlayerTail);
                While (OtherPlayer <> NIL) And (Count < MaxPlusOne) Do
                  Begin
                    Count := Count + 1;
                    TermList [Count] := OtherPlayer ^.Trm;
                    OtherPlayer := NextOkSend (OtherPlayer ^.Next)
                  End (*While*);
                If TalkHow = Yell
                Then
                  For ILoop := 1 to 6 Do
                    If Adjoin [ILoop] > 0
                    Then
                      Begin
                        OtherPlayer := NextOkSend
                          (Room [S (Adjoin [ILoop])].RmPlayerTail);
                        While (OtherPlayer <> NIL) And (Count < MaxPlusOne) Do
                          Begin
                            Count := Count + 1;
                            TermList [Count] := OtherPlayer ^.Trm;
                            OtherPlayer := NextOkSend (OtherPlayer ^.Next)
                          End (*While*)
                      End (*If*)
              End (*With*)
          Else
            If TalkHow in [All, Others, NoBlock, BrAll, Brothers, SysMsg]
            Then
              Begin
                OtherPlayer := MatchUser (UserTail);
                While (OtherPlayer <> NIL) And (Count < MaxPlusOne) Do
                  Begin
                    If Not ((TalkHow in [Brothers, BrAll]) And
                       OtherPlayer ^.Brief)
                    Then
                      If Not ((TalkHow = NoBlock) And (OtherPlayer ^.MesBlock))
                      Then
                        Begin
                          Count := Count + 1;
                          TermList [Count] := OtherPlayer ^.Trm
                        End (*If*);
                    OtherPlayer := MatchUser (OtherPlayer ^.NextUser)
                  End (*While*);
                If (TalkHow in [SysMsg, All, BrAll]) or User ^.Echo Then
                  Begin
                    Count := Count + 1;
                    TermList [Count] := Term
                  End (*If*)
              End (*If*)
            Else
              Abort ('0 Mil10 - Bad talk/term function!');
        If Count > MaxPlusOne
        Then
          WriteLn (Term, '0 Mil11 - Term msg table overflow!')
        Else
          MsgTerm := Count
      End (*MsgTerm*);
                                 
    Procedure InitRoom;
    
      Begin
        With ProtoRoom Do
          Begin
            For ILoop := 1 to 6 Do
              Adjoin [ILoop] := 0;
            Out := 0;
            DescCode := 1;
            DescRec := 4;
            LastDir := 0;
            WhichEncounter := 0;
            EncounterTime := 0;
            NotifyDM := False;
            Safe := False;
            RmPlayerTail := NIL;
            RmMonsterTail := NIL;
            RmObjectTail := NIL
          End (*With*);
        DirList [1] := 'north';
        DirList [2] := 'south';
        DirList [3] := 'east';
        DirList [4] := 'west';
        DirList [5] := 'up';
        DirList [6] := 'down';
        DirList [7] := 'out';
      End (*InitRoom*);
