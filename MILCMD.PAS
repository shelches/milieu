    Procedure TrapCheck (Var Obj: ObjectPoint; Trap: Integer);
    
      Var
        Dmg: Integer;
      
      Begin
        Dmg := 0;
        If Trap > 0
        Then
          If User^.Dex - Rnd (6) < Trap
          Then
            Begin
              If Trap <= 35
              Then
                Case Trap of
                  1,2,3:
                    B1 := 'Splinters on your hand';
                  4,5:
                    B1 := 'Spring dart';
                  6:
                    B1 := 'Small knife flies at you';
                  7:
                    Begin
                      User^.Poisoned := True;
                      B1 := 'Poison dart'
                    End (*7*);
                  8:
                    B1 := 'Spear shoots out of the ground at you';
                  9:
                    B1 := 'Dust sprays in your eyes';
                  10:
                    B1 := 'Grubs bite you';
                  11:
                    B1 := 'Steel wire cuts your hand';
                  12:
                    B1 := 'Needles stab your toes';
                  13:
                    Begin
                      User^.Poisoned := True;
                      B1 := 'Poison needles'
                    End (*13*);
                  14:
                    Begin
                      User^.Poisoned := True;
                      B1 := 'Cobra lunges at you'
                    End (*14*);
                  15:
                    Begin
                      User^.Poisoned := True;
                      B1 := 'Gas spores explode'
                    End (*15*);
                  16:
                    B1 := 'Rocks fall from the ceiling';
                  17:
                    B1 := 'Blam!  Explosion in your face';
                  18:
                    B1 := 'Acid splashes in your face';
                  19:
                    B1 := 'Flames shoot out at you';
                  20,21,22,23,24,25:
                    Begin
                      User^.Fatigue := 0;
                      B1 := 'Spear impales your stomach'
                    End (*20*);
                  26,27,28,29,30:
                    B1 := 'Boooooom';
                  31,32,33,34,35:
                    B1 := 'A rack of knives falls and crushes you'
                End (*Case*)
              Else
                Begin
                  User^.Fatigue := 0;
                  B1 := 'Tons of rocks tumble down upon you'
                End (*Else*);
              B1 := '0' + B1 + '!';
              QOut (Term, B1);
              Dmg := Max (0, Trap + User^.AC - 10);
              Dmg := Dmg Div 2 + Rnd (Dmg);
              PrintDmg (User, Dmg, User^.Brief, B1);
              B1 := '0It hits you for ' + B1;
              QOut (Term, B1);
              If User^.Hits + User^.Fatigue <= Dmg
              Then
                Begin
                  User^.Dead := True;
                  User^.Fatigue := 0;
                  User^.Hits := 0;
                  PS (User^.Name, B1);
                  B1 := '0### ' + B1 + ' was just killed by a deadly trap.';
                  For ILoop := 1 to MsgTerm (TermList, All) Do
                    QOut (TermList [ILoop], B1)
                End (*If*)
              Else
                Begin
                  If Dmg > User^.Fatigue Then
                    User^.Hits := User^.Hits - Dmg + User^.Fatigue;
                  User^.Fatigue := Max (0, User^.Fatigue - Dmg)
                End (*Else*)
            End (*If*)
      End (*TrapCheck*);
                  
    Procedure StopUsing (Usr: UserPoint; Object: ObjectPoint);
    
      Begin
        If Object <> NIL
        Then
          With Usr ^ Do
            If Object = USWeap
            Then
              USWeap := NIL
            Else
              If Object = USShield
              Then
                Begin
                  AC := Max (-50, Min (50, AC + Object ^.ShPlus));
                  USShield := NIL
                End (*If*)
              Else
                If Object = USArm
                Then
                  Begin
                    AC := Max (-50, Min (50, AC + Object ^.ArmPlus));
                    USArm := NIL
                  End (*If*)
      End (*StopUsing*);
              
    Procedure GetObj (Var Word: Alfa; Num: Integer; Rm: RmCodeType);
    
      Var
        Obj2, Box, ObTail, Object: ObjectPoint;
        Monster: MonsterPoint;
        Num2, ILoop: Integer;
        Where: (Ground,Container,NoWhere);
        Held: Boolean;
        Word2: Alfa;
      
      Begin
        Held := False;
        With Room [Rm] Do
          Begin
            ObTail := RmObjectTail;
            Box := NIL;
            Where := Ground;
            Object := FindObject (Word, Num, ObTail);
            GetWord (Word2, Num2, Buffer, LenBuf, Loc);
            If Word2 <> Blanks Then
              Begin
                Box := FindObject (Word2, Num, RmObjectTail);
                If Box = NIL Then
                  Begin
                    Box := FindObject (Word2, Num, User^.ObjectTail);
                    If Box <> NIL Then
                      Held := True
                  End (*If*);
                If Box <> NIL
                Then
                  If Box ^.ObClass = Chest Then
                    If Not Box ^.Closed Then
                      Begin
                        ObTail := Box ^.ObjectTail;
                        Where := Container
                      End (*If*)
                    Else
                      Begin
                        Where := NoWhere;
                        QOut (Term, '0You can''t.  It''s closed.')
                      End (*Else*)
                  Else
                    Begin
                      Where := NoWhere;
                      QOut (Term, '0That''s not a container.')
                    End (*Else*)
                Else
                  Begin
                    Where := NoWhere;
                    QOut (Term, '0That container isn''t here.')
                  End (*Else*);
                If Where = Container Then
                  Object := FindObject (Word, Num, ObTail)
              End (*If*);
            (* Pointer now equals object selected by user. *)
            If (Object <> NIL) And (Where <> NoWhere)
            Then
              If Not Object ^.Carry Then
                QOut (Term, '0You are not able to take that!')
              Else
                Begin
                  Monster := RmMonsterTail;
                  Num := 0;
                  While (Monster <> NIL) And (Num = 0) Do
                    If Monster ^.Guard and Not Held
                    Then
                      Num := 1
                    Else
                      Monster := Monster ^.Next;
                  If Num > 0
                  Then
                    Begin
                      PM (Monster, True, B1);
                      B1 := '0' + B1 + ' stops you from getting it.';
                      QOut (Term, B1)
                    End
                  Else
                    If (User^.Weight + Object^.Weight > User^.Str * 10) And
                       Not Held
                    Then
                      QOut (Term, '0It''s too much for you to carry!')
                    Else
                      Begin
                        If DeleteObject (Object, ObTail) Then
                          ObTail := ObTail ^.Next;
                        QOut (Term, '0Ok.');
                        Object ^.Invisible := False;
                        PS (User^.Name, B1);
                        PrintObj (Object ^, True, False, B2);
                        B1 := '0' + B1 + ' picked up ' + B2;
                        If Where = Container Then
                          Begin
                            PrintObj (Box ^, False, False, B2);
                            B1 := B1 + ' from inside ' + B2
                          End (*If*);
                        B1 := B1 + '.';
                        For ILoop := 1 to MsgTerm (TermList, Local) Do
                          QOut (TermList [ILoop], B1);
                        If Object ^.ObClass = Coins Then
                          Begin
                            User^.Money := User^.Money + Object ^.Price;
                            Writev (B1, '0You now have ', User^.Money: 0,
                                    ' shillings in cash.');
                            QOut (Term, B1);
                            Dispose (Object)
                          End (*If*)
                        Else
                          Begin
                            If Not Held Then
                              User^.Weight := Min (2500, User^.Weight +
                                                    Object ^.Weight);
                            If User^.ObjectTail = NIL Then
                              Begin
                                Object ^.Next := NIL;
                                User^.ObjectTail := Object
                              End (*If*)
                            Else
                              Begin
                                Obj2 := User^.ObjectTail;
                                While Obj2 ^.Next <> NIL Do
                                  Obj2 := Obj2 ^.Next;
                                Obj2 ^.Next := Object;
                                Object ^.Next := NIL
                              End (*Else*)
                          End (*Else*);
                        If Where = Container
                        Then
                          Begin
                            Box ^.Weight := Max (0, Box ^.Weight -
                                                 Object ^.Weight);
                            Box ^.NumInside := Max (0, Box ^.NumInside - 1);
                            Box ^.ObjectTail := ObTail
                          End (*If*)
                        Else
                          RmObjectTail := ObTail
                      End (*Else*)
              End (*Else*)
            Else
              If Where <> NoWhere Then
                QOut (Term, '0That object isn''t here.')
          End (*With*)
      End (*GetObj*);
    
    Procedure DropObj (Var Word: Alfa; Num: Integer; Rm: RmCodeType);
    
      Var
        Box, ObTail, Object: ObjectPoint;
        Num2, ILoop: Integer;
        Where: (Ground, Container, NoWhere);
        Held: Boolean;
        Word2: Alfa;
      
      Begin
        Held := False;
        Object := FindObject (Word, Num, User^.ObjectTail);
        If Object <> NIL
        Then
          Begin
            ObTail := Room[Rm].RmObjectTail;
            Box := Nil;
            Where := Ground;
            GetWord (Word2, Num2, Buffer, LenBuf, Loc);
            Box := FindObject (Word2, Num2, Room[Rm].RmObjectTail);
            If Box = NIL Then
              Begin
                Box := FindObject (Word2, Num, User^.ObjectTail);
                If Box <> NIL Then
                  Held := True
              End (*If*);
            If Box <> NIL
            Then
              If Box ^.ObClass = Chest
              Then
                If Not Box ^.Closed
                Then
                  Begin
                    ObTail := Box ^.ObjectTail;
                    If (Box ^.NumInside >= 6) or (Box ^.Weight > 200)
                    Then
                      Begin
                        PrintObj (Box ^, True, False, B1);
                        B1 := '0There is no more room inside ' + B1 +
                              ' for more objects!';
                        QOut (Term, B1);
                        Where := NoWhere
                      End (*If*)
                    Else
                      If Box = Object
                      Then
                        Begin
                          Where := NoWhere;
                          QOut (Term,
                                '0You can''t put an object inside itself!')
                        End (*If*)
                      Else
                        Where := Container
                  End (*If*)
                Else
                  Begin
                    Where := NoWhere;
                    QOut (Term, '0You can''t.  It''s closed!')
                  End (*Else*)
              Else
                Begin
                  Where := NoWhere;
                  QOut (Term, '0It won''t fit in that!')
                End (*Else*)
            Else
              If Word2 <> Blanks Then
                Begin
                  Where := NoWhere;
                  QOut (Term, '0That container isn''t here!')
                End (*If*);
            If Where <> NoWhere
            Then
              Begin
                If DeleteObject (Object, User^.ObjectTail) Then
                  User^.ObjectTail := User^.ObjectTail ^.Next;
                Object ^.Next := ObTail;
                ObTail := Object;
                If Not Held Then
                  User^.Weight := Max (0, User^.Weight - Object ^.Weight);
                StopUsing (User, Object);
                If Where = Container
                Then
                  Begin
                    QOut (Term, '0Ok.  You drop it.');
                    Box^.Weight := Min (1000, Box^.Weight + Object^.Weight);
                    Box ^.NumInside := Min (10, Box ^.NumInside + 1);
                    Box ^.ObjectTail := ObTail
                  End (*If*)
                Else
                  Begin
                    Room[Rm].RmObjectTail := ObTail;
                    QOut (Term, '0Ok.')
                  End (*Else*);
                PS (User^.Name, B1);
                PrintObj (Object ^, False, False, B2);
                B1 := '0' + B1 + ' dropped ' + B2;
                If Where = Container
                Then
                  Begin
                    PrintObj (Box ^, True, False, B2);
                    B1 := B1 + ' into ' + B2
                  End (*If*);
                B1 := B1 + '.';
                For ILoop := 1 to MsgTerm (TermList, Local) Do
                  QOut (TermList [ILoop], B1)
              End (*If*)
          End (*If*)
        Else
          QOut (Term, '0You aren''t carrying that!')
      End (*DropObj*);
    
    Function SpellLimit: Boolean;
    
      Begin
{
        If User^.SpellDay >= 7
        Then
          Begin
            SpellLimit := True;
            QOut (Term, '0Daily spell limit exceeded, sorry.')
          End
        Else
          Begin
            SpellLimit := False;
            User^.SpellDay := User^.SpellDay + 1
          End
}
        SpellLimit := False;
      End (*SpellLimit*);
      
    Function SpellCost (User: UserPoint;
                        Cost, MinLvl, MinInt: Integer): Boolean;
      
      Begin
        SpellCost := False;
        With User^ Do
          If Int < MinInt
          Then
            QOut (Term, '0You don''t have the intelligence to cast the spell.')
          Else
            Begin
              MinLvl := MinLvl + 2;
              Case Class of
                Fighter:
                  MinLvl := MinLvl + 2;
                Thief:
                  MinLvl := MinLvl + 1;
                MagicUser:
                  MinLvl := MinLvl - 2;
                Cleric:
                  MinLvl := MinLvl - 1;
                Barbarian:
                  MinLvl := MinLvl + 3
              End (*Case*);
              If MinLvl > Lvl
              Then
                QOut (Term, 
                      '0You aren''t high enough level to cast the spell!')
              Else
                If Magic - Cost < 0
                Then
                  QOut (Term, '0You''re too weak to cast that spell.')
                Else
                  Begin
                    Magic := Magic - Cost;
                    SpellCost := True
                  End (*Else*)
            End (*Else*)
      End (*SpellCost*);
    
    Function Lk (Var Word: Alfa; Num: Integer; CmdCode: Integer): Integer;
    
      Var
        Player: UserPoint;
        Monster: MonsterPoint;
        TObj, Object: ObjectPoint;
        Legal: Boolean;
        Lev: Integer;
        Where: (Ground, Person);
        Dummy: Alfa;
        Temp1: Alfa;
        Temp2: Integer;
      
      Begin
        Lk := 0;
        Legal := True;
        If CmdCode = 31 Then
          Begin
            Legal := SpellCost (User, 10, 5, 10);
            Legal := Legal and Not SpellLimit
          End (*If*);
        If Legal Then
          With Room [User^.RmCode] Do
            Begin
              Player := FindPlayer (Word, RmPlayerTail);
              If Player <> NIL
              Then
                With Player ^ Do
                  Begin
                    B1 := '0';
                    If UsArm = NIL
                    Then
                      B1 := B1 + 'You see ';
                    Ps (Name, B2);
                    B1 := B1 + B2;
                    Writev (B2, ' the ', CName [Class]);
                    B1 := B1 + B2;
                    If UsArm <> NIL
                    Then
                      Begin
                        PrintObj (UsArm ^, False, False, B2);
                        B1 := B1 + ' is wearing ' + B2
                      End (*If*);
                    B1 := B1 + '.';
                    QOut (Term, B1);
                    If (UsWeap <> NIL) Or (UsShield <> NIL)
                    Then
                      Begin
                        If Sex = Male
                        Then
                          B1 := '0He '
                        Else
                          B1 := '0She ';
                        B1 := B1 + 'is holding ';
                        If UsWeap <> NIL
                        Then
                          Begin
                            PrintObj (UsWeap ^, False, False, B2);
                            B1 := B1 + B2;
                            If UsShield <> NIL
                            Then
                              B1 := B1 + ' and '
                          End (*If*);
                        If UsShield <> NIL
                        Then
                          Begin
                            PrintObj (UsShield ^, False, False, B2);
                            B1 := B1 + B2
                          End;
                        B1 := B1 + '.';
                        QOut (Term, B1)
                      End (*If*);
                    If CmdCode = 31
                    Then
                      PlayerDisplay (Player)
                  End (*With*)
              Else
                Begin
                  Object := FindObject (Word, Num, User^.ObjectTail);
                  Where := Person;
                  If Object = NIL
                  Then
                    Begin
                      Where := Ground;
                      Object := FindObject (Word, Num, RmObjectTail)
                    End (*If*);
                  If Object <> NIL
                  Then
                    If (Object ^.ObClass = Scroll) And (Where = Ground)
                    Then
                      QOut (Term, '0Pick it up first, Eagle Eyes!')
                    Else
                      Begin
                        If CmdCode = 31
                        Then
                          ObjDisplay (Object)
                        Else
                          Begin
                            If (CmdCode = 64) And (Object ^.ObClass = Scroll)
                            Then
                              If ReadyCheck (User^.LastAtk)
                              Then
                                Begin
                                  Temp1 := User ^.WData;
                                  Temp2 := User ^.Data;
                                  GetWord (Temp1, Temp2, Buffer, LenBuf, Loc);
                                  User ^.WData := Temp1;
                                  User ^.Data := Temp2;
                                  Lk := Object ^.Spell
                                End (*If*)
                              Else
                                CmdCode := 31 (*Inhibit scroll destruction*)
                            Else
                              Begin
                                If Object ^.DescRec <> 0 Then
                                  Begin
                                    B2 := '0';
                                    With Object ^ Do
                                      PrintDesc (DescRec, DescCode, 0, False,
                                                 B2, B1);
                                    QOut (Term, B1)
                                  End (*If*)
                                Else
                                  Begin
                                    If Where = Ground
                                    Then
                                      B1 := '0It''s '
                                    Else
                                      B1 := '0You are holding ';
                                    PrintObj (Object ^, False, False, B2);
                                    B1 := B1 + B2 + '.';
                                    QOut (Term, B1)
                                  End (*Else*);
                                If Object ^.ObClass = Weap
                                Then
                                  Begin
                                    Case Object ^.WeapType of
                                      Sharp:
                                        B1 := 'sharp, bladed';
                                      Thrust:
                                        B1 := 'thrusting';
                                      Blunt:
                                        B1 := 'blunt';
                                      Long:
                                        B1 := 'pole'
                                    End (*Case*);
                                    B1 := '0This is a ' + B1 + ' weapon.';
                                    QOut (Term, B1)
                                  End (*If*);
                                If Object ^.ObClass = Chest Then
                                  If Not Object ^.Closed Then
                                    If Object ^.ObjectTail <> NIL Then
                                      Begin
                                        PrintObj (Object ^, True, False, B1);
                                        B1 := '0Inside ' + B1 +
                                              ' you see the following:';
                                        QOut (Term, B1);
                                        TObj := Object ^.ObjectTail;
                                        While TObj <> NIL Do
                                          Begin
                                           PrintObj (TObj ^, False, False, B1);
                                            B1 := '0   ' + B1;
                                            QOut (Term, B1);
                                            TObj := TObj ^.Next
                                          End (*While*)
                                      End (*If*)
                                    Else
                                      QOut (Term, '0It''s empty.')
                                  Else
                                    QOut (Term, '0It''s closed.')
                              End (*Else*);
                            If (Object ^.ObClass = Scroll) And (CmdCode <> 31)
                            Then
                              Begin
                                PrintObj (Object ^, True, True, B1);
                                B1 := '0' + B1 + ' disintegrates!';
                                QOut (Term, B1);
                                If DeleteObject (Object, User^.ObjectTail)
                                Then
                                  User^.ObjectTail := User^.ObjectTail^.Next;
                                User^.Weight := User^.Weight - Object^.Weight;
                                Dispose (Object)
                              End (*If*)
                          End (*Else*)
                      End (*If*)
                  Else (*Monster?*)
                    Begin
                      If Num = 0
                      Then
                        GetWord (Dummy, Num, Buffer, LenBuf, Loc);
                      Monster := FindMonster (Word, Num, RmMonsterTail);
                      If Monster = NIL
                      Then
                        QOut (Term, '0I don''t see that here.')
                      Else
                        If CmdCode = 31
                        Then
                          MonDisplay (Monster)
                        Else
                          Begin
                            Lev := (Monster ^.Lvl Div 5) * 5 + 1;
                            Ps (Monster ^.Name, B1);
                            PNth (Lev, B2);
                            B1 := '0It''s a ' + B1 + ', ' + B2 + 'to ';
                            PNth (Lev + 4, B2);
                            B1 := B1 + B2 + 'level.';
                            QOut (Term, B1);
                            If Monster ^.Magic Then
                              QOut (Term, '0It looks magical!');
                            If Monster ^.SlowReact or Monster ^.FastReact Then
                              QOut (Term, '0It looks hostile!')
                          End (*Else*)
                    End (*Else*)
                End (*Else*)
            End (*With*)
      End (*Lk*);
    
    Procedure Tr;
    
      Var
        TRoom: Integer;
      
      Begin
        TRoom := 0;
        Case User^.Class of
          Fighter:
            TRoom := 20;
          Paladin:
            TRoom := 21;
          Cleric:
            TRoom := 22;
          Thief:
            TRoom := 23;
          MagicUser:
            TRoom := 24;
          Ranger:
            TRoom := 25
        End (*Case*);
        TRoom := Max (20, TRoom);
        With User^ Do
          If W (RmCode) <> TRoom
          Then
            QOut (Term, '0This is not the proper place for training!')
          Else
            If Money * 2 < Expr (Lvl + 1) - Expr (Lvl)
            Then
              QOut (Term, '0You haven''t enough funds to spend on training!')
            Else
              If Experience + Expr (Lvl) < Expr (Lvl + 1)
              Then
                QOut (Term,
                      '0You are not experienced enough for further training.')
              Else
                If Lvl >= 20
                Then
                  QOut (Term, '0You have reached the peak of excellence.')
                Else
                  Begin
                    Money := Money - (Expr (Lvl + 1) - Expr (Lvl)) Div 2;
                    B1 := '0After many weeks of training';
                    If Not (Class in [Barbarian, Thief, Fighter]) Then
                      B1 := B1 + ' and meditation';
                    B1 := B1 + ' you find......';
                    QOut (Term, B1);
                    Experience := 0;
                    MaxHits := Min (2500, MaxHits + MaxHits Div Lvl);
                    MaxFatigue := Min (2500, MaxFatigue + MaxFatigue Div Lvl);
                    MaxMagic := Min (2500, MaxMagic + MaxMagic Div Lvl);
                    Lvl := Lvl + 1;
                    Case Rnd (5) of
                      1:
                        Str := Min (25, Str + 1);
                      2:
                        Dex := Min (25, Dex + 1);
                      3:
                        Int := Min (25, Int + 1);
                      4:
                        Pty := Min (25, Pty + 1);
                      5:
                        Con := Min (25, Con + 1)
                    End (*Case*);
                    SkillNew := False;
                    If Lvl <= 10 Then
                      Con := Min (25, Con + 1);
                    PlayerDisplay (User)
                  End (*Else*)
      End (*Tr*);
    
    Procedure OpenClo (CmdCode: Integer; Var Word: Alfa; Num: Integer);
    
      Var
        OthrDoor, Key, Obj: ObjectPoint;
        ObTrap: 0..50;
        ObClosed, Found: Boolean;
        ObLocked: 0..1000;
        Num2, ILoop: Integer;
        ObType: (Portl, Box, Neither);
      
      Begin
        ObType := Neither;
        Obj := FindObject (Word, Num, User^.ObjectTail);
        If Obj = NIL Then
          Obj := FindObject (Word, Num, Room[User^.RmCode].RmObjectTail);
        If Obj = NIL
        Then
          QOut (Term, '0That object isn''t here!')
        Else
          If Obj ^.ObClass = Chest
          Then
            Begin
              ObTrap := Obj ^.Trap;
              ObLocked := Obj ^.Locked;
              ObType := Box;
              ObClosed := Obj ^.Closed
            End (*If*)
          Else
            If Obj ^.ObClass = Door
            Then
              Begin
                ObTrap := Obj ^.DTrap;
                ObLocked := Obj ^.DLocked;
                ObType := Portl;
                ObClosed := Obj ^.DClosed
              End (*If*)
            Else
              QOut (Term, '0I don''t know how to do such a thing.');
        If ObType <> Neither
        Then
          Begin
            If CmdCode = 66  (*Close*)
            Then
              If ObClosed
              Then
                QOut (Term, '0It''s already closed!')
              Else
                Begin
                  ObClosed := True;
                  PS (User^.Name, B1);
                  PrintObj (Obj ^, True, False, B2);
                  B1 := '0' + B1 + ' just closed ' + B2 + '.';
                  For ILoop := 1 to MsgTerm (TermList, Local) Do
                    QOut (TermList [ILoop], B1);
                  QOut (Term, '0Ok.')
                End (*Else*)
            Else
              If (CmdCode = 67) or (CmdCode = 68) (*Lock/UnLock*)
              Then
                Begin
                  GetWord (Word, Num2, Buffer, LenBuf, Loc);
                  Key := FindObject (Word, Num2, User^.ObjectTail);
                  If Word = Blanks
                  Then
                    QOut (Term, '0With what?')
                  Else
                    If Key = NIL
                    Then
                      QOut (Term,'0You don''t have the right key.')
                    Else
                      If Key ^.ObClass <> Keys
                      Then
                        QOut (Term, '0That won''t unlock anything!')
                      Else
                        If ((Key ^.UnLock Mod 10 = 0) And (Key ^.UnLock <>
                             ObLocked - ObLocked Mod 10) Or (Key ^.UnLock Mod
                             10 <> 0) And (Key ^.UnLock <> ObLocked)) And
                             (Key ^.UnLock <> 1000)
                        Then
                          Begin
                            PrintObj (Key ^, True, False, B1);
                            B1 := '0' + B1 + ' doesn''t work!';
                            QOut (Term, B1)
                          End (*If*)
                        Else
                          Begin
                            If CmdCode = 67
                            Then
                              ObClosed := True
                            Else
                              ObClosed := False;
                            PS (User^.Name, B1);
                            B1 := '0' + B1 + ' just ';
                            If CmdCode = 67
                            Then
                              B1 := B1 + 'locked '
                            Else
                              B1 := B1 + 'unlocked ';
                            PrintObj (Obj ^, True, False, B2);
                            B1 := B1 + B2 + ' with ';
                            PrintObj (Key ^, False, False, B2);
                            B1 := B1 + B2 + '.';
                            For ILoop := 1 to MsgTerm (TermList, Local) Do
                              QOut (TermList [ILoop], B1);
                            QOut (Term, '0Ok.')
                          End (*Else*)
                End (*If*)
              Else
                If CmdCode = 65 (*Open*)
                Then
                  If Not ObClosed
                  Then
                    QOut (Term, '0It''s already open!')
                  Else
                    If ObLocked > 0
                    Then
                      QOut (Term, '0You can''t.  It''s locked!')
                    Else
                      Begin
                        ObClosed := False;
                        PS (User^.Name, B1);
                        PrintObj (Obj ^, True, False, B2);
                        B1 := '0' + B1 + ' just opened ' + B2 + '.';
                        For ILoop := 1 to MsgTerm (TermList, Local) Do
                          QOut (TermList [ILoop], B1);
                        QOut (Term, '0Ok.');
                        TrapCheck (Obj, ObTrap)
                      End (*Else*)
                Else
                  If CmdCode = 69 (*PickLock*)
                  Then
                    Begin
                      If User^.Class <> Thief
                      Then
                        ILoop := -10
                      Else
                        ILoop := 3;
                      If ReadyCheck (User^.LastAtk)
                      Then
                        If ((User^.Lvl + User^.Dex Div 2 + ILoop) Div 3 <
                             ObLocked Mod 10) Or (ObLocked Mod 10 = 0)
                        Then
                          Begin
                            User^.LastAtk := RealTime + 15;
                            QOut (Term, '0You fail to pick the lock!')
                          End (*If*)
                        Else
                          Begin
                            ObClosed := False;
                            PS (User^.Name, B1);
                            PrintObj (Obj ^, True, False, B2);
                            B1 := '0' + B1 + ' pickes the lock on ' + B2 +
                                  ' open!';
                            For ILoop := 1 to MsgTerm (TermList, Local) Do
                              QOut (TermList [ILoop], B1);
                            QOut (Term, '0You picked the lock open!');
                            TrapCheck (Obj, ObTrap)
                          End (*Else*)
                    End (*If*)
                  Else
                    If CmdCode = 70 (*Smash*)
                    Then
                      If ReadyCheck (User^.LastAtk)
                      Then
                        If Not ObClosed
                        Then
                          QOut (Term, '0It''s already open!')
                        Else
                          If (Rnd (3) <> 1) or (User^.Str * 10 < Obj^.Weight)
                          Then
                            Begin
                              User^.LastAtk := RealTime + 15;
                              PS (User^.Name, B1);
                              PrintObj (Obj ^, True, False, B2);
                              B1 := '0' + B1 + ' fails to smash ' + B2 +
                                    ' open.';
                              For ILoop := 1 to MsgTerm (TermList, Local) Do
                                QOut (TermList [ILoop], B1);
                              QOut (Term, '0Bang!  You fail to smash it open!')
                            End (*If*)
                          Else
                            Begin
                              PS (User^.Name, B1);
                              PrintObj (Obj ^, True, False, B2);
                              B1 := '0' + B1 + ' smashes ' + B2 + ' open.';
                              For ILoop := 1 to MsgTerm (TermList, Local) Do
                                QOut (TermList [ILoop], B1);
                              ObClosed := False;
                              QOut (Term, '0You smash it open!');
                              TrapCheck (Obj, ObTrap)
                            End (*Else*);
            If ObType = Box
            Then
              Begin
                Obj ^.Closed := ObClosed;
                Obj ^.Trap := ObTrap;
                Obj ^.Locked := ObLocked
              End (*If*)
            Else
              If ObType = Portl
              Then
                Begin
                  Obj ^.DClosed := ObClosed;
                  Obj ^.DTrap := ObTrap;
                  Obj ^.DLocked := ObLocked;
                  Found := False;
                  OthrDoor := Room[S (Obj ^.ToWhere)].RmObjectTail;
                  While (OthrDoor <> NIL) And Not Found Do
                    If Pad (OthrDoor ^.Name, ' ', 20) =
                       Pad (Obj ^.Name, ' ', 20)
                    Then
                      Found := True
                    Else
                      OthrDoor := OthrDoor ^.Next;
                  If Found And (OthrDoor <> NIL)
                  Then
                    Begin
                      OthrDoor ^.DClosed := ObClosed;
                      OthrDoor ^.DTrap := ObTrap;
                      OthrDoor ^.DLocked := ObLocked
                    End (*If*)
                End (*If*)
          End (*If*)
      End (*OpenClo*);
      
    Procedure HitShArmor (Plyr: UserPoint; Var Damage: Integer);
    
      Var
        Temp: ObjectPoint;
      
      Begin
        With Plyr ^ Do
          Begin
            If UsArm <> NIL
            Then
              Begin
                Damage := Max (0, Damage - UsArm ^.ArmPlus);
                UsArm ^.ArmHits := Max (0, UsArm ^.ArmHits - 1);
                If UsArm ^.ArmHits = 0 Then
                  Begin
                    QOut (Term, '0Your armor falls apart!');
                    If DeleteObject (UsArm, ObjectTail) Then
                      ObjectTail := ObjectTail ^.Next;
                    Weight := Weight - UsArm ^.Weight;
                    Temp := UsArm;
                    StopUsing (Plyr, UsArm);
                    Dispose (Temp)
                  End (*If*)
              End (*If*);
            If UsShield <> NIL
            Then
              Begin
                UsShield ^.ArmHits := Max (0, UsShield ^.ArmHits - 1);
                If UsShield ^.ArmHits = 0 Then
                  Begin
                    QOut (Term, '0Your shield falls apart!');
                    If DeleteObject (UsShield, ObjectTail) Then
                      ObjectTail := ObjectTail ^.Next;
                    Weight := Weight - UsShield ^.Weight;
                    Temp := UsShield;
                    StopUsing (Plyr, UsShield);
                    Dispose (Temp)
                  End (*If*)
              End (*If*)
          End (*With*)
      End (*HitShArmor*);

    Procedure Train;
    
      Begin
        Tr
      End (*Train*);
      
    Procedure Hide (Var Word: Alfa; Num: Integer);
    
      Var
        Obj: ObjectPoint;
        Chance: Integer;
      
      Begin
        If Word = Blanks
        Then
          Begin
            Chance := User^.Lvl * 20 + User^.Dex;
            If User^.AGuild Or (User^.Class = Thief) Then
              Chance := Chance * 2;
            If Room[User^.RmCode].RmMonsterTail <> NIL
            Then
              Chance := Chance Div 2;
            If Rnd (100) <= Min (66, Chance)
            Then
              User^.Hidden := True;
            QOut (Term, '0You hide in the shadows.')
          End (*If*)
        Else
          Begin
            Obj := FindObject (Word, Num, User^.ObjectTail);
            If Obj = NIL
            Then
              QOut (Term, '0You aren''t holding that.')
            Else
              Begin
                StopUsing (User, Obj);
                If DeleteObject (Obj, User^.ObjectTail)
                Then
                  User^.ObjectTail := User^.ObjectTail ^.Next;
                User^.Weight := User^.Weight - Obj ^.Weight;
                Obj ^.Next := Room[User^.RmCode].RmObjectTail;
                Room[User^.RmCode].RmObjectTail := Obj;
                Obj ^.Invisible := True;
                PrintObj (Obj ^, True, False, B1);
                B1 := '0You carefully hide ' + B1 + ' in the room.';
                QOut (Term, B1);
                If Rnd (4) = 1
                Then
                  Begin
                    PS (User ^.Name, B1);
                    PrintObj (Obj ^, False, False, B2);
                    B1 := '0You see ' + B1 + ' trying to hide ' + B2 +
                          ' in the room.';
                    For ILoop := 1 to MsgTerm (TermList, Local) Do
                      QOut (TermList [ILoop], B1);
                    Obj ^.Invisible := False
                  End (*If*)
              End (*Else*)
          End (*Else*)
      End (*Hide*);
    
    Procedure Search;
    
      Var
        Find : Boolean;
        HidPlyr: UserPoint;
        HidObj:  ObjectPoint;
        Factor, Rm: Integer;
      
      Begin
        Find := False;
        Rm := User^.RmCode;
        Factor := 50;
        If User^.Class in [Thief, Ranger] Then
          Factor := Factor + 25;
        If ReadyCheck (User^.LastAtk)
        Then
          Begin
            User^.LastAtk := RealTime + 10;
            HidPlyr := Room[Rm].RmPlayerTail;
            While HidPlyr <> NIL Do
              Begin
                If (HidPlyr ^.Hidden) And (HidPlyr <> User)
                   And (Rnd (100) <= Factor)
                Then
                  Begin
                    HidPlyr ^.Hidden := False;
                    Find := True;
                    Ps (HidPlyr ^.Name, B1);
                    B1 := '0You spot ' + B1 + ' hiding in the shadows.';
                    QOut (Term, B1)
                  End (*If*);
                HidPlyr := HidPlyr ^.Next
              End (*While*);
            HidObj := Room[Rm].RmObjectTail;
            While HidObj <> NIL Do
              Begin
                If (Rnd (100) <= Factor) And (HidObj ^.Invisible)
                Then
                  Begin
                    Find := True;
                    PrintObj (HidObj ^, False, False, B1);
                    B1 := '0While searching you discover ' + B1 + '!';
                    QOut (Term, B1)
                  End (*If*);
                HidObj := HidObj ^.Next
              End (*While*);
            If Not Find Then
              QOut (Term, '0You didn''t find anything.')
          End (*If*)
      End (*Search*);
    
    Procedure GoDirection (Var Word: Alfa; Num, CmdCode: Integer);
    
     (* GoDirection lets players move from room to room.  It moves
        players N, S, E, W, U, D and through portals and doors.
        Movement is prohibited if a monster blocks the exit.  If
        the player is not blocked, following monsters have a 66%
        chance of following the player into the next room. *)
     
      Var
        Factor, I: Integer;
        Rm, NewRm: RmCodeType;
        Dm, Temp, FollowPlyr, Leader: UserPoint;
        NextMon, Monster: MonsterPoint;
        Object: ObjectPoint;
        Following, Leave, Blocked, Followed: Boolean;
      
      Function FindBlock (Mon: MonsterPoint): MonsterPoint;
      
        Var
          Temp: MonsterPoint;
          Found: Boolean;
        
        Begin
          Found := False;
          Temp := Mon;
          While Not Found And (Temp <> NIL) Do
            If Temp ^.Block
            Then
              Found := True
            Else
              Temp := Temp ^.Next;
          If Found
          Then
            FindBlock := Temp
          Else
            FindBlock := NIL
        End (*FindBlock*);
        
      Function FindFollow (Mon: MonsterPoint): MonsterPoint;
 
        Var
          Temp: MonsterPoint;
          Found: Boolean;
 
        Begin
          Found := False;
          Temp := Mon;
          While Not Found And (Temp <> NIL) Do
            If (Temp ^.Follow) And (Temp ^.DefPlayer = User)
            Then
              Found := True
            Else
              Temp := Temp ^.Next;
          If Found
          Then
            FindFollow := Temp
          Else
            FindFollow := NIL
        End (*FindFollow*);
        
      Function FindDm (Usr: UserPoint): UserPoint;
      
        Var
          Temp: UserPoint;
          Found: Boolean;
        
        Begin
          Found := False;
          Temp := Usr;
          While Not Found And (Temp <> NIL) Do
            If Temp ^.SSJ
            Then
              Found := True
            Else
              Temp := Temp ^.NextUser;
          If Found
          Then
            FindDm := Temp
          Else
            FindDm := NIL
        End (*FindDm*);
        
      Function PFollow (Usr: UserPoint): UserPoint;
 
        Var
          Temp: UserPoint;
          Found: Boolean;
 
        Begin
          Found := False;
          Temp := Usr;
          While Not Found And (Temp <> NIL) Do
            If (Temp ^.Follow = User)
            Then
              Found := True
            Else
              Temp := Temp ^.NextUser;
          If Found
          Then
            PFollow := Temp
          Else
            PFollow := NIL
        End (*PFollow*);
 
      Begin
        Blocked := False;
        Followed := False;
        Leave := False;
        Rm := User^.RmCode;
        If Not User^.EncountStop
        Then
          Begin
            If CmdCode <= 6
            Then
              If Room[Rm].Adjoin[CmdCode] = 0
              Then
                QOut (Term, '0There is no way to go in that direction.')
              Else
                Begin
                  Leave := True;
                  NewRm := Room[Rm].Adjoin[CmdCode]
                End (*Else*)
            Else
              If CmdCode = 7
              Then
                If Room[Rm].Out > 0
                Then
                  Begin
                    Leave := True;
                    NewRm := Room[Rm].Out
                  End (*If*)
                Else
                  QOut (Term, '0There is no obvious exit from here.')
              Else (* CmdCode = 9.  Go thru door or passage. *)
                Begin
                  Object := FindObject (Word, Num, Room[Rm].RmObjectTail);
                  If Object = NIL
                  Then
                    QOut (Term, '0That object isn''t here!')
                  Else
                    If Not (Object ^.ObClass in [Portal, Door])
                    Then
                      QOut (Term, '0You can''t go in that direction.')
                    Else
                      If (Object ^.ObClass = Door) And Object ^.DClosed
                      Then
                        Begin
                          PrintObj (Object ^, True, False, B1);
                          B1 := '0Clunk!  You bang your nose against ' + B1 +
                                '.';
                          QOut (Term, B1)
                        End (*If*)
                      Else
                        Begin
                          Leave := True;
                          NewRm := Object ^.ToWhere
                        End (*Else*)
                End (*Else*);
            If Leave
            Then
              Begin
                Monster := Room[Rm].RmMonsterTail;
                Repeat
                  Monster := FindBlock (Monster);
                  If Monster <> NIL
                  Then
                    Begin
                      If (CmdCode > 7) or (Monster ^.DefPlayer = User)
                      Then
                        If (Rnd (100) < 50) or (CmdCode > 7) Then
                          Begin
                            PM (Monster, True, B1);
                            B1 := '0' + B1 + ' blocks your way!';
                            QOut (Term, B1);
                            Blocked := True
                          End (*If*);
                      Monster := Monster ^.Next
                    End (*If*)
                Until (Monster = NIL) or Blocked;
                If Not Blocked
                Then
                  Begin
                    Monster := Room[Rm].RmMonsterTail;
                    I := S (NewRm);
                    If Not Room [I].Safe
                    Then
                      Repeat
                        Monster := FindFollow (Monster);
                        If Monster <> NIL
                        Then
                          If Rnd (100) < 70
                          Then
                            Begin
                              NextMon := Monster ^.Next;
                              PM (Monster, True, B1);
                              B1 := '0' + B1 + ' follows you!';
                              QOut (Term, B1);
                              Followed := True;
                              DeleteMonster (Monster, Rm);
                              InsertMonster (Monster, I);
                              Monster ^.DefPlayer := User;
                              Monster := NextMon
                            End (*If*)
                          Else
                            Monster := Monster ^.Next
                      Until Monster = NIL
                  End (*If*);
                If Rnd (100) > 50
                Then
                  User^.Hidden := False;
                FollowPlyr := PFollow (Room[Rm].RmPlayerTail);
                If Not User^.Hidden And ((FolCount = 0) Or Followed
                   Or Blocked)
                Then
                  Begin
                    PS (User^.Name, B1);
                    B1 := '0' + B1;
                    If FollowPlyr <> NIL
                    Then
                      B1 := B1 + '''s group';
                    If User^.Drunk - RealTime > 30
                    Then
                      B1 := B1 + ' just staggered'
                    Else
                      B1 := B1 + ' just went';
                    If CmdCode = 9
                    Then
                      Begin
                        PrintObj (Object^, True, False, B2);
                        B1 := B1 + ' to ' + B2
                      End (*If*)
                    Else
                      Begin
                        Writev (B2, DirList[CmdCode]);
                        B1 := B1 + ' ' + B2
                      End (*Else*);
                    If Followed
                    Then
                      Writev (B2, ' and something followed ', Pro [User^.Sex],
                              '!')
                    Else
                      If Blocked
                      Then
                        Writev (B2, ' but then something stopped ',
                                Pro [User^.Sex], '!')
                      Else
                        B2 := '.';
                    B1 := B1 + B2;
                    For ILoop := 1 to MsgTerm (TermList, Local) Do
                      QOut (TermList [ILoop], B1)
                  End (*If*);
                If Not Blocked
                Then
                  Begin
(**)
                    Leader := User ^.Follow;
(**)
                    DeletePlayer (User, Rm);
                    PlacePlayer (User, NewRm);
                    If CmdCode <= 7
                    Then
                      Room[Rm].LastDir := CmdCode
                    Else
                      Room[Rm].LastDir := 8;
                    If Not User^.Hidden And (FolCount = 0)
                    Then
                      Begin
                        PS (User^.Name, B1);
                        B1 := '0' + B1;
                        If FollowPlyr <> NIL
                        Then
                          B1 := B1 + '''s group';
                        B1 := B1 + ' just arrived.';
                        For ILoop := 1 To MsgTerm (TermList, Local) Do
                          QOut (TermList [ILoop], B1)
                      End (*If*);
                    If Room[User ^.RmCode].NotifyDM
                    Then
                      Begin
                        Ps (User ^.Name, B1);
                        Writev (B2, NewRm: 0);
                        B1 := '0*** ' + B1 + ' entered room ' + B2 + '.';
                        Dm := FindDm (UserTail);
                        While Dm <> NIL Do
                          Begin
                            QOut (Dm ^.Trm, B1);
                            Dm := FindDm (Dm ^.NextUser)
                          End (*While*)
                      End (*If*);
                    Following := (FolCount > 0);
                    If (User^.RmCode <> Rm) And (FolCount < 8)
                    Then
                      Begin
                        While (FollowPlyr <> NIL) And (FolCount < 8) Do
                          Begin
                            FolCount := FolCount + 1;
                            If (FolCount >= 8) Then
                              QOut (Term,
                                    '0 Mil432 - Follow table overflow!');
                            Temp := User;
                            Term := FollowPlyr ^.Trm;
                            User := FollowPlyr;
                            GoDirection (Word, Num, CmdCode);
                            User := Temp;
                            Term := User ^.Trm;
                            FollowPlyr := PFollow (FollowPlyr ^.NextUser)
                          End (*While*)
                      End (*If*);
                    With User^ Do
                      If Not Following
                      Then
                        RoomDisplay (RmCode, Brief)
                      Else
                        Begin
                          Follow := Leader;
                          If NoTimeOut (User)
                          Then
                            Begin
                              B1 := '0You''re ';
                              PrintDesc (Room[RmCode].DescRec,
                                         Room[RmCode].DescCode, 0, Brief,
                                         B1, B2);
                              QOut (Term, B2);
                              QOut (Term, '0')
                            End (*If*)
                        End (*Else*);
                    Case NewRm of
                      3:
                        QOut (Term,
                              '0Bartender says, "Buy a drink, mac?"');
                      4:
                        QOut (Term,
                         '0Paperboy says, "Extra! Extra! Read all about it!"');
                      8:
                        QOut (Term,
                            '0Appraisor asks, "What would you like to sell?"');
                      10:
                        QOut (Term,
                              '0Merchant asks, "What would you like to buy?"');
                      18:
                        QOut (Term,
        '0"Hee hee.  So matey, your gear don''t look too good.  Need fixin?"');
                    End (*Case*)
                  End (*Move*)
              End (*Leave*)
          End (*If*)
      End (*GoDirection*);
    
    Procedure GetObject (Var Word: Alfa; Num: Integer; Rm: RmCodeType);
    
      Begin
        GetObj (Word, Num, Rm)
      End (*GetObject*);
      
    Procedure DropObject (Var Word: Alfa; Num: Integer; Rm: RmCodeType);
    
      Begin
        DropObj (Word, Num, Rm)
      End (*DropObject*);
    
    Procedure EnterSpell (Var Word: Alfa; Num: Integer);
    
      Var
        Dummy: Alfa;
        SpellTable: NameTList;
      
      Begin
        If ReadyCheck (User^.LastAtk)
        Then
          Begin
            For Num := 1 to Spellen Do
              SpellTable [Num] := SpellList [Num];
            CapAlfa (Word);
            If WordMatch (Word, Spellen, SpellTable) > 0
            Then
              GetWord (Word, Num, Buffer, LenBuf, Loc);
            If Num = 0
            Then
              GetWord (Dummy, Num, Buffer, LenBuf, Loc);
            User^.WData := Word;
            User^.Data := Num;
            User^.Entry := XSpell
          End (*If*);
        LenBuf := 0
      End (*EnterSpell*);
              
    Procedure ReturnObj (Var Word: Alfa; Num: Integer);
    
      Var
        Object: ObjectPoint;
      
      Begin
        Object := FindObject (Word, Num, User^.ObjectTail);
        If Object = Nil
        Then
          QOut (Term, '0Object not found.')
        Else
          Begin
            StopUsing (User, Object);
            QOut (Term, '0Ok.')
          End (*Else*)
      End (*ReturnObj*);
      
    Function Look (Var Word: Alfa; Num, CmdCode: Integer): Integer;
    
      Begin
        Look := Lk (Word, Num, CmdCode)
      End (*Look*);
      
    Procedure OpenClose (CmdCode: Integer; Var Word: Alfa; Num: Integer);
    
      Begin
        OpenClo (CmdCode, Word, Num)
      End (*OpenClose*);
      
    Procedure Track;
    
      Var
        Dir: Integer;
        Obj: ObjectPoint;
        Found: Boolean;
      
      Begin
        If ReadyCheck (User^.LastAtk)
        Then
          Begin
            Dir := Room[User^.RmCode].LastDir;
            If User^.Class <> Ranger Then
              If Rnd (2) > 1 Then
                Dir := 0;
            User^.LastAtk := RealTime + 7;
            Case Dir of
              0:
                QOut (Term, '0You didn''t find any tracks.');
              1,2,3,4,5,6:
                Begin
                  Writev (B1, '0You see some tracks leading ', DirList[Dir],
                          '.');
                  QOut (Term, B1)
                End;
              7:
                QOut (Term, '0You see some tracks leading out.');
              8:
                Begin
                  Obj := Room[User^.RmCode].RmObjectTail;
                  Found := False;
                  While (Obj <> NIL) And Not Found Do
                    If Obj ^.ObClass in [Portal, Door]
                    Then
                      Begin
                        Found := True;
                        PrintObj (Obj ^, True, False, B1);
                        B1 := '0You see some tracks leading to ' + B1 + '.';
                        QOut (Term, B1)
                      End (*If*)
                    Else
                      Obj := Obj ^.Next;
                  If Not Found
                  Then
                    QOut (Term, '0You didn''t find any tracks.')
                End (*8*)
            End (*Case*)
          End (*If*)
      End (*Track*);
    
    Var
      Num: Integer;
      
    Function UseObj (Var Word: Alfa; Num: Integer): Integer;
    
      (* Use a weapon, shield or other item *)
      
      Var
        Object: ObjectPoint;
        Plyr: UserPoint;
        ILoop: Integer;
      
      Begin
        UseObj := 0;
        Object := FindObject (Word, Num, User ^.ObjectTail);
        If Object = NIL
        Then
          QOut (Term, '0But you aren''t carrying that!')
        Else
          If Object ^.ObClass in [Weap, Armor, Shield, MagDevice,
                                  Teleport, Card]
          Then
            With User ^ Do
              Case Object ^.ObClass of
                Weap:
                  If (User ^.Class = Cleric) And (Object ^.WeapType in
                          [Sharp, Thrust])
                  Then
                    Begin
                      B1 := '0It is against your faith to use weapons ' +
                            'that draw blood!';
                      QOut (Term, B1)
                    End (*If*)
                  Else
                    Begin
                      StopUsing (User, UsWeap);
                      UsWeap := Object;
                      Ps (User ^.Name, B1);
                      PrintObj (Object ^, False, False, B2);
                      B1 := '0' + B1 + ' pulls out ' + B2 + '!';
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        QOut (TermList [ILoop], B1);
                      QOut (Term, '0You ready your weapon!')
                    End (*Weap*);
                Armor:
                  If (Class = MagicUser) And (Object ^.ArmPlus > 1)
                  Then
                    QOut (Term, '0Magic-users cannot wear such armor!')
                  Else
                    Begin
                      StopUsing (User, UsArm);
                      UsArm := Object;
                      AC := Max (-50, Min (50, AC - Object ^.ArmPlus));
                      QOut (Term, '0You put on your armor.')
                    End (*Else*);
                Shield:
                  If (Class = MagicUser) And (Object ^.ShPlus > 1)
                  Then
                    QOut (Term, '0Magic-users cannot use such shields!')
                  Else
                    Begin
                      StopUsing (User, UsShield);
                      UsShield := Object;
                      AC := Max (-50, Min (50, AC - Object ^.ShPlus));
                      QOut (Term, '0You ready your shield.')
                    End (*Else*);
                MagDevice:
                  If Object ^.NumCharges <= 0
                  Then
                    Begin
                    QOut (Term, '0Nothing happens..  It''s discharged/empty.');
                      Object ^.Permanent := False
                    End (*If*)
                  Else
                    If ReadyCheck (User ^.LastAtk)
                    Then
                      Begin
                        GetWord (Word, Num, Buffer, LenBuf, Loc);
                        WData := Word;
                        If Num = 0 Then
                          GetWord (Word, Num, Buffer, LenBuf, Loc);
                        Data := Num;
                        Object ^.NumCharges := Object ^.NumCharges - 1;
                        UseObj := - (Object ^.Spell)
                      End (*If*);
                Teleport:
                  If (Object ^.TActiveRm <> W (RmCode)) And
                     (Object ^.TActiveRm <> 0)
                  Then
                    QOut (Term,
                        '0You feel a slight tingle, but nothing else happens.')
                  Else
                    Begin
                      Ps (Name, B1);
                      B1 := '0' + B1 +
                            ' suddenly vanishes in a blinding flash!';
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        QOut (TermList [ILoop], B1);
                      DeletePlayer (User, RmCode);
                      PlacePlayer (User, Object ^.ToWhere);
                      QOut (Term,
                '0Everything swirls around in a blinding flash!  You find...');
                      RoomDisplay (RmCode, False);
                      Ps (Name, B1);
                      B1 := '0' + B1 +
                            ' suddenly appears in a blinding flash of light!';
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        QOut (TermList [ILoop], B1)
                    End (*Else*);
                Card:
                  Begin
                    GetWord (Word, Num, Buffer, LenBuf, Loc);
                    Plyr := FindUser (Word, UserTail);
                    If Plyr <> NIL
                    Then
                      Begin
                        DeletePlayer (User, RmCode);
                        PlacePlayer (User, W (Plyr ^.RmCode));
                        Ps (Plyr ^.Name, B1);
                        B1 := '0You teleport to player ' + B1;
                        QOut (Term, B1);
                        RoomDisplay (RmCode, False)
                      End (*If*)
                    Else
                      QOut (Term, '0Player not found.')
                  End (*Card*)
              End (*Case*)
          Else
            QOut (Term, '0Nothing happens.')
      End (*UseObj*);
              
    Procedure Logoff (Usr: UserPoint);

      Begin
        If Not (Usr ^.Status In [SLogin, SInit]) Or (Usr ^.Entry = XDead)
        Then
          Begin
            DeleteUser (Usr, UserTail);
            If Usr ^.Lvl >= 1
            Then
              WritePlayer (Usr, True)
            Else
              QOut (Term,
              '0Sorry, you must be at least 1st level to save your character.')
          End (*If*)
        Else
          Begin
            Usr ^.RmCode := 0;
            DeleteUser (Usr, UserTail)
          End (*Else*);
        WritePlayer (Usr, False);
        Usr := NIL;
        NUsers := NUsers - 1
      End (*Logoff*);

    Procedure Kill;

      Begin
        DeleteUser (User, UserTail);
        If SearchPlIndex (User ^.Name) > 0
        Then
          Begin
            DeleteUsr (User ^.Name);
            QOut (Term, '0Player file space released.')
          End (*If*);
        WritePlayer (User, False);
        NUsers := NUsers - 1
      End (*Kill*);

    Procedure SaveChar;
    
      Var
        DumUsr: UserPoint;
      
      Begin
        If User ^.Lvl < 1
        Then
          QOut (Term,
            '0Sorry, you must be at least 1st level to save your character.')
        Else
          Begin
            New (DumUsr);
            DumUsr ^ := User ^;
            DumUsr ^.UsWeap := NIL;
            DumUsr ^.RmCode := W (DumUsr ^.RmCode);
            StopUsing (DumUsr, DumUsr ^.UsArm);
            StopUsing (DumUsr, DumUsr ^.UsShield);
            WritePlayer (DumUsr, True);
            Dispose (DumUsr);
            QOut (Term, '0Character file updated.')
          End (*Else*)
      End (*SaveChar*);
      
    Procedure Off;

      Begin
        User := UserTail;
        While User <> NIL Do
          Begin
            Term := User ^.Trm;
            Logoff (User);
            QOut (Term, '3');
            User := UserTail
          End (*While*)
      End (*Off*);

    Procedure Death;
    
      Var
        ILoop: Integer;
        Rm: RmCodeType;
        Obj2, Obj, Body: ObjectPoint;
      
      Begin
        Rm := User ^.RmCode;
        Obj := User ^.ObjectTail;
        User ^.ObjectTail := NIL;
        New (Body);
        Body ^ := ProtoObject;
        With Body ^ Do
          Begin
            Weight := 150;
            Article := None;
            Name := '                 ';
            Name := 'body,';
            ILoop := 1;
            Repeat
              Name := Name + User ^.Name [ILoop];
              ILoop := ILoop + 1
            Until (ILoop = 10) or (User ^.Name [ILoop] = ' ');
            Name := Name + '''s *'
          End (*With*);
        User ^.Weight := 0;
        User ^.AC := 10;
        If User ^.Con * 5 >= Rnd (100)
        Then
          With User ^ Do
            Begin
              UsArm := NIL;
              UsShield := NIL;
              UsWeap := NIL;
              Entry := XCmd;
              Status := SNormal;
              If NoTimeOut (User)
              Then
                Begin
                  QOut (Term, '0');
                  QOut (Term,
             '0Everything goes dark...  You feel yourself floating away into');
                  QOut (Term,
               '0space.  After what seems like an eternity, you faintly hear');
                  QOut (Term,
                        '0voices!  As you come to your senses, you find....');
                  QOut (Term, '0')
                End (*If*);
              PlacePlayer (User, 17);
              Poisoned := False;
              Con := Max (3, Con - 1);
              If Lvl > 2 Then
                Begin
                  MaxHits := Max (3, MaxHits - MaxHits Div Lvl);
                  MaxMagic := Max (3, MaxMagic - MaxMagic Div Lvl);
                  MaxFatigue := Max (3, MaxFatigue - MaxFatigue Div Lvl);
                  Magic := MaxMagic;
                  Lvl := Lvl - 1;
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
                End (*If*);
              Hits := MaxHits;
              Fatigue := Min (10, MaxFatigue);
              Money := Max (3, Pty) * 10;
              Experience := 0;
              RoomDisplay (RmCode, Brief);
              QOut (Term, '0The acolyte gives you a small bag of money and');
              QOut (Term, '0bids you go on your way.');
              Dead := False;
              SaveChar;
              Loc := LenBuf + 1;
              PromptUser (User)
            End (*With*)
        Else
          Begin
            QOut (Term, '0Constitution failed.');
            User ^.Dead := False;
            Kill;
            User := NIL;
            QOut (Term, '0End Milieu.');
            QOut (Term, '2');
            QDea (Term)
          End (*Else*);
        Body ^.Next := Room[Rm].RmObjectTail;
        Room[Rm].RmObjectTail := Body;
        Obj2 := Obj;
        If Obj <> NIL Then
          Begin
            While Obj2 ^.Next <> NIL Do
              Obj2 := Obj2 ^.Next;
            Obj2 ^.Next := Body ^.Next;
            Body ^.Next := Obj
          End (*If*)
      End (*Death*);
    
    Function SpellCase (SpellCode, Level, Intel: Integer;
                        Player: UserPoint;
                        Monster: MonsterPoint;
                        Obj: ObjectPoint;
                        Target: Alfa): Integer;

      Var
        Damage: Integer;
      
      Begin
        Damage := 0;
        With User ^ Do
          Case SpellCode of
            1 (*Vigor, OnUsPlayer*):
              Begin
                Player ^.Fatigue := Min (Player ^.MaxFatigue,
                                         Player ^.Fatigue + Level * 6);
                Writev (B1, '0You now have ', Player ^.Fatigue: 0,
                         ' fatigue points.');
                QOut (Player ^.Trm, B1)
              End (*1*);
            2 (*Heal, OnUsPlayer*):
              Begin
                Player ^.Hits := Min (Player ^.MaxHits,
                                      Player ^.Hits + Level * 3);
                Writev (B1, '0You now have ', Player ^.Hits: 0,
                         ' vitality points.');
                QOut (Player ^.Trm, B1)
              End (*2*);
            3 (*Fireball, OnMonPlayer*):
              If 10 + Level > Rnd (20) Then
                Damage := Min (Intel * 2, 3 * (Level + 1));
            4 (*Lightning, OnMonPlayer*):
              If 8 + Level > Rnd (20) Then
                Damage := Min (20, 2 * (Level + 1)) + Rnd (2 * Intel);
            5 (*Hurt, OnMonPlayer*):
              Damage := Rnd (3);
            6 (*Curepoison, OnUsPlayer*):
              Begin
                Player ^.Poisoned := False;
                QOut (Player ^.Trm, '0The venom has disappeared!')
              End (*6*);
            7 (*Disintegrate, OnMonPlayer*):
              Damage := Rnd (5 * Intel) + Level * 2;
            8 (*Befuddle, OnMonPlayer*):
              If Player <> NIL
              Then
                Player ^.LastAtk := RealTime + 20 + Rnd (10)
              Else
                Begin
                  Monster ^.MReact := 4;
                  Monster ^.DefPlayer := NIL;
                  QOut (Term, '0It pauses for a moment...')
                End (*Else*);
            9 (*Teleport, OnUsPlayer*):
              Begin
                DeletePlayer (Player, Player ^.RmCode);
                PlacePlayer (Player, Rnd (570) + 30);
            QOut (Player ^.Trm, '0**Poof**  You find that you are elsewhere..')
              End (*9*);
            10 (*Wish, OnUsPlayer*):
              Begin
                WData := Target;
                Entry := XWish
              End (*10*);
            11 (*Passdoor, OnObject*):
              If Not (Obj ^.ObClass in [Door, Portal])
              Then
                QOut (Term, '0Can''t be done!')
              Else
                If Not Obj ^.Magic
                Then
                  Begin
                    DeletePlayer (User, User ^.RmCode);
                    PlacePlayer (User, Obj ^.ToWhere);
                    QOut (Term, '0You pass through the portal!')
                  End (*If*)
                Else
                  QOut (Term, '0A magic barrier stops you from passing!');
            12 (*Enchant, OnObject*):
              If Not Obj ^.Carry
              Then
                QOut (Term, '0Enchantment fails!')
              Else
                Begin
                  Obj ^.Magic := True;
                  QOut (Term, '0Ok.  It begins to glow!')
                End (*Else*);
            13 (*Bless, OnPlayer*):
              If (Lvl < Player ^.Lvl) And (Lvl < 10)
              Then
                QOut (Term,
                     '0You are not worthy of blessing this great person!')
              Else
                Begin
                  Player ^.Pty := Min (25, Player ^.Pty + 1);
                  QOut (Player ^.Trm, '0You feel purified and whole.')
                End (*Else*);
            14 (*Protection, OnUser*):
              Begin
                StopUsing (User, UsArm);
                StopUsing (User, UsShield);
                AC := Max (8, AC - 1);
                QOut (Term, '0You feel limber and strong..')
              End (*14*);
            15 (*Curse, OnPlayer*):
              Begin
                Player ^.Pty := Max (-10, Player ^.Pty - 1);
                QOut (Player ^.Trm, '0You''ve been cursed!')
              End (*15*);
            16 (*Poison, OnPlayer*):
              Begin
                Player ^.Poisoned := True;
                QOut (Player ^.Trm, '0You''ve been poisoned!')
              End (*16*);
            17 (*Intoxicate, OnUsPlayer*):
              Begin
                Player ^.Drunk := Max (Realtime, Player ^.Drunk) + 60;
                QOut (Player ^.Trm, '0(HIC)  You feel tipsy.')
              End (*17*)
          End (*Case*);
        SpellCase := Damage
      End (*SpellCase*);
    
    Function SpellMon (SpellNum, Lvl, Int: Integer;
                       Plr: UserPoint;
                       Mon: MonsterPoint;
                       Obj: ObjectPoint;
                       Target: Alfa): Integer;
      
      Begin
        SpellMon := SpellCase (SpellNum, Lvl, Int, Plr, Mon, Obj, Target)
      End (*SpellMon*);
    
    Function UseObject (Var Word: Alfa; Num: Integer): Integer;
    
      Begin
        UseObject := UseObj (Word, Num)
      End (*UseObject*);
    
    Procedure Dead;
    
      Begin
        Death
      End (*Dead*);
    
    Procedure ShareExperience (Mon: MonsterPoint; Rm: RmCodeType);
    
      Var
        NewExp, NumInvolved: Integer;
        Plyr: UserPoint;
      
      Begin
        NumInvolved := 1 (*Extra share for slayer*);
        Plyr := Room[Rm].RmPlayerTail;
        While Plyr <> NIL Do
          Begin
            If Plyr ^.DefMon = Mon Then
              NumInvolved := NumInvolved + 1;
            Plyr := Plyr ^.Next
          End (*While*);
        Plyr := Room[Rm].RmPlayerTail;
        NewExp := Mon ^.Experience Div NumInvolved;
        While Plyr <> NIL Do
          Begin
            If Plyr = User
            Then
              Plyr ^.Experience := Plyr ^.Experience + NewExp * 2
            Else
              If Plyr ^.DefMon = Mon
              Then
                Begin
                  Writev (B1,
                          '0You earned ', NewExp: 0, ' exp for the melee.');
                  QOut (Plyr ^.Trm, B1);
                  Plyr ^.Experience := Plyr ^.Experience + NewExp
                End (*If*);
            Plyr := Plyr ^.Next
          End (*While*)
      End (*ShareExperience*);
        
    Procedure ProtectNPC (Player: UserPoint; Monster: MonsterPoint);
    
      Var
        ILoop: Integer;
        Temp: ObjectPoint;
      
      Begin
        Ps (Monster ^.Name, B1);
        B1 := '0As you step forward to attack, the ' + B1 + ' yells,';
        QOut (Term, B1);
        QOut (Term,
             '0"Help!  Help!  Guards!  Guards!"...  In seconds, several');
        QOut (Term, '0burly guards grab you and take away your weapon!');
        If Player ^.UsWeap <> NIL
        Then
          Begin
            Temp := Player ^.UsWeap;
            Player ^.UsWeap := NIL;
            If DeleteObject (Temp, Player ^.ObjectTail) Then
              Player ^.ObjectTail := Player ^.ObjectTail ^.Next;
            Player ^.Weight := Max (0, Player ^.Weight - Temp ^.Weight);
            Dispose (Temp)
          End (*If*);
        If Player ^.Lvl <= 2
        Then
          Begin
            QOut (Term,
                 '0Since you are a young, inexperienced adventurer, they');
            QOut (Term,
             '0give you a stern warning and decide not to throw you in jail.');
            Ps (Player ^.Name, B1);
            Ps (Monster ^.Name, B2);
            B1 := '0' + B1 + ' assaults the ' + B2;
            Writev (B2, ', but the town guards stop ', Pro [Player ^.Sex],
                    '.');
            B1 := B1 + B2;
            For ILoop := 1 to MsgTerm (TermList, Local) Do
              QOut (TermList [ILoop], B1)
          End (*If*)
        Else
          Begin
            QOut (Term, '0Then they throw you in jail!');
            QOut (Term, '0');
            Ps (Player ^.Name, B1);
            Ps (Monster ^.Name, B2);
            B1 := '0### ' + B1 + ' was thrown in jail for assaulting the ' +
                  B2;
            For ILoop := 1 to MsgTerm (TermList, All) Do
              QOut (TermList [ILoop], B1);
            DeletePlayer (Player, Player ^.RmCode);
            PlacePlayer (Player, 5) (*Jail*);
            RoomDisplay (Player ^.RmCode, False)
          End (*Else*);
        Player ^.DefMon := NIL
      End (*ProtectNPC*);
    
    Procedure MakeTreasure (Monster: MonsterPoint; Rm: Integer);
    
      Var
        Nothing: Boolean;
        Obj, LastObj: ObjectPoint;
        ILoop, NumObjs, ObNum: Integer;
        Factor: Real;
      
      Begin
        Nothing := True;
        PM (Monster, False, B1);
        B1 := '0On ' + B1 + ' you find:';
        QOut (Term, B1);
        With Monster ^ Do
          Begin
            If ObjectTail <> NIL
            Then
              Begin
                Nothing := False;
                LastObj := ObjectTail;
                While LastObj ^.Next <> NIL Do
                  LastObj := LastObj ^.Next;
                LastObj ^.Next := Room[Rm].RmObjectTail;
                LastObj := LastObj ^.Next;
                Room[Rm].RmObjectTail := ObjectTail;
                ObjectTail := NIL
              End (*If*)
            Else
              LastObj := Room[Rm].RmObjectTail;
            If WhichObj > ObjListLen Then
              Begin
                QOut (Term, '0 Mil105 - Object list index out of bounds!');
                WhichObj := 0
              End (*If*);
            If WhichObj > 0
            Then
              Begin
                If Rnd (4) = 1
                Then
                  NumObjs := Rnd (4)
                Else
                  NumObjs := 1;
                For ILoop := 1 to NumObjs Do
                  Begin
                    ObNum := ObjIndex [WhichObj, Rnd (6)];
                    If ObNum > 0
                    Then
                      Begin
                        Nothing := False;
                        Find (OList, ObNum);
                        New (Obj);
                        Obj ^ := OList ^;
                        Factor := (Rnd (40) + 80) / 100;
                        Obj ^.Price := Round (Obj ^.Price * Factor);
                        Obj ^.Next := Room[Rm].RmObjectTail;
                        Room[Rm].RmObjectTail := Obj
                      End (*If*)
                  End (*For*)
              End (*If*);
            If Nothing Then
              QOut (Term, '0    Nothing.')
            Else
              Begin
                Obj := Room[Rm].RmObjectTail;
                Repeat
                  PrintObj (Obj ^, False, True, B1);
                  B1 := '0    ' + B1;
                  QOut (Term, B1);
                  Obj := Obj ^.Next
                Until Obj = LastObj
              End (*Else*)
          End (*With*)
      End (*MakeTreasure*);
    
    (* Combat routines.. *)
    
    Procedure TurnMon (Var Word: Alfa; Num: Integer);
    
      Var
        Dummy: Alfa;
        Mon: MonsterPoint;
        Factor: Integer;
        Turned: Boolean;
      
      Begin
        If Num = 0 Then
          GetWord (Dummy, Num, Buffer, LenBuf, Loc);
        Mon := FindMonster (Word, Num, Room[User ^.RmCode].RmMonsterTail);
        If Mon = NIL
        Then
          QOut (Term, '0Monster not found here.')
        Else
          If Not Mon ^.Undead
          Then
            Begin
              PM (Mon, True, B1);
              B1 := '0' + B1 + ' is not undead!';
              QOut (Term, B1)
            End (*If*)
          Else
            With User ^ Do
              If Not (Class in [Cleric, Paladin, Dm])
              Then
                QOut (Term, '0You can''t turn away the undead!')
              Else
                If ReadyCheck (LastAtk)
                Then
                  Begin
                    User ^.Hidden := False;
                    Turned := False;
                    Factor := Lvl - Mon ^.Lvl - 2;
                    LastAtk := RealTime + 25;
                    If Class = Paladin Then
                      Factor := Factor + 2;
                    Factor := Factor - Rnd (5);
                    User ^.DefMon := Mon;
                    Mon ^.DefPlayer := User;
                    Mon ^.MReact := 6;
                    If Rnd (3) = 1 Then
                      Factor := -1;
                    If Factor < 0
                    Then
                      Begin
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' ignores your command!';
                        QOut (Term, B1)
                      End (*If*)
                    Else
                      If Factor <= 3
                      Then
                        Begin
                          Turned := True;
                          Mon ^.Experience := Mon ^.Experience Div 2;
                          PM (Mon, True, B1);
                          B1 := '0' + B1 + ' flees at your command!';
                          QOut (Term, B1)
                        End (*If*)
                      Else
                        Begin
                          Turned := True;
                          PM (Mon, True, B1);
                          B1 := '0' + B1 + ' collapses and turns to dust!';
                          QOut (Term, B1);
                          MakeTreasure (Mon, RmCode)
                        End (*Else*);
                    Ps (Name, B1);
                    B1 := '0' + B1;
                    If Turned
                    Then
                      If Factor <= 3
                      Then
                        B1 := B1 + ' turns away '
                      Else
                        B1 := B1 + ' damns and destroys '
                    Else
                      B1 := B1 + ' fails to turn away ';
                    Pm (Mon, False, B2);
                    B1 := B1 + B2 + '!';
                    For ILoop := 1 to MsgTerm (TermList, Local) Do
                      QOut (TermList [ILoop], B1);
                    If Turned Then
                      Begin
                        ShareExperience (Mon, RmCode);
                        DeleteMonster (Mon, RmCode);
                        Destroy (Mon)
                      End (*If*)
                  End (*If*)
      End (*TurnMon*);
      
    Procedure HitPlayer (Damage: Integer);
    
      Var
        I: Integer;
        Player: UserPoint;
        Revenent: MonsterPoint;
        Merc, Cold: Boolean;
      
      Begin
        Player := User ^.DefPlayer;
        HitShArmor (Player, Damage);
        Ps (Player ^.Name, B1);
        PrintDmg (Player, Damage, User ^.Brief, B2);
        B1 := '0You hit ' + B1 + ' for ' + B2;
        QOut (Term, B1);
        If NoTimeOut (Player) Then
          Begin
            Ps (User ^.Name, B1);
            PrintDmg (Player, Damage, Player ^.Brief, B2);
            B1 := '0' + B1 + ' hits you for ' + B2;
            QOut (Player ^.Trm, B1)
          End (*If*);
        If Player ^.Hits + Player ^.Fatigue <= Damage
        Then
          If RealTime - Player ^.HitAtTime <= 30
          Then
            Begin
              Writev (B1, '0You killed ', Pro [Player ^.Sex], '!');
              QOut (Term, B1);
              Ps (Player ^.Name, B1);
              B1 := '0You''re dead, ' + B1 + '!';
              QOut (Player ^.Trm, B1);
              Merc := (User ^.Lvl - Player ^.Lvl > 3);
              Cold := (Player ^.DefPlayer = NIL);
              Ps (User ^.Name, B1);
              Ps (Player ^.Name, B2);
              B1 := '0### ' + B1 + ' just killed ' + B2;
              If Merc Then
                B1 := B1 + ' mercilessly';
              If Cold Then
                B1 := B1 + ' in cold blood';
              B1 := B1 + '!';
              For ILoop := 1 to MsgTerm (TermList, All) Do
                QOut (TermList [ILoop], B1);
              If Merc Then
                User ^.Pty := Max (-10, User ^.Pty - 1);
              If Cold Then
                User ^.Pty := Max (-10, User ^.Pty - 1);
              If (User ^.Class = Paladin) And (Merc or Cold) And
                 (Player ^.Class <> Thief)
              Then
                User ^.Class := Fighter;
              If User ^.AGuild Then
                User ^.Pty := Max (0, User ^.Pty - 1);
              If (Player ^.Con >= 18) Then
                Begin
                  New (Revenent);
                  Revenent ^ := ProtoMonster;
                  InsertMonster (Revenent, User ^.RmCode);
                  With Revenent ^ Do
                    Begin
                      Name := 'Revenent  ';
                      Hits := Player ^.MaxHits;
                      Lvl := Player ^.Lvl;
                      DefPlayer := User;
                      MaxHits := Hits
                    End (*With*);
                  QOut (Term, '0From the body you see a gaseous shape form...')
                End (*If*);
              Player ^.Dead := True;
              Player ^.Fatigue := 0;
              Player ^.Hits := 0;
              If (- (User ^.Pty * 10) > Rnd (100)) And (Merc or Cold)
              Then
                Begin
                  QOut (Term,
        '0Enough is enough!  The people rise up against you in an angry mob!');
                  QOut (Term, '0You have been lynched!');
                  Ps (User ^.Name, B1);
                  B1 := '0### ' + B1;
                  Writev (B2, ' the ', CName [User ^.Class],
                          ', was just lynched by an angry mob!');
                  B1 := B1 + B2;
                  For ILoop := 1 to MsgTerm (TermList, All) Do
                    QOut (TermList [ILoop], B1);
                  User ^.Dead := True;
                  User ^.Fatigue := 0;
                  User ^.Hits := 0
                End (*If*)
            End (*If*)
          Else
            Begin
              Player ^.Fatigue := 0;
              Player ^.Hits := 1;
            QOut (Player ^.Trm, '0You hear a voice cry out, "Run, fool, run!"');
            End (*Else*)
        Else
          With Player ^ Do
            Begin
              If Damage > Fatigue Then
                Hits := Max (0, Hits - Damage + Fatigue);
              Fatigue := Max (0, Fatigue - Damage)
            End (*With*)
      End (*HitPlayer*);
                
    Procedure HitMonster (Damage: Integer);
    (* HitMonster strikes monster for damage.  Enough damage will kill
       them.  Messages are sent to all involved in the kill, and treasure
       and experience are distributed. *)
    
      Var
        Monster: MonsterPoint;
        Rm: RmCodeType;
        I: Integer;
      
      Begin
        Rm := User ^.RmCode;
        Monster := User ^.DefMon;
        If Monster ^.Hits <= Damage
        Then
          Begin
            Ps (Monster ^.Name, B1);
            B1 := '0You killed the ' + B1 + '!';
            QOut (Term, B1);
            Ps (User ^.Name, B1);
            Pm (Monster, False, B2);
            B1 := '0' + B1 + ' just killed ' + B2 + '!';
            For ILoop := 1 to MsgTerm (TermList, Local) Do
              QOut (TermList [ILoop], B1);
            ShareExperience (Monster, Rm);
            MakeTreasure (Monster, Rm);
            DeleteMonster (Monster, Rm);
            Destroy (Monster);
            User ^.DefMon := NIL
          End (*If*)
        Else
          Begin
            If Monster ^.MParley in [1, 3, 4] Then
              If Not Monster ^.Permanent Then
                Monster ^.MParley := 2;
            Monster ^.Hits := Monster ^.Hits - Damage;
            If User ^.Brief
            Then
              Begin
                Writev (B1, '0You hit it for ', Damage: 1, ' hit points!');
                QOut (Term, B1)
              End (*If*)
            Else
              Begin
                Ps (Monster ^.Name, B1);
                B1 := '0You hit the ' + B1;
                Writev (B2, ' for ', Damage: 0, ' hit points!');
                B1 := B1 + B2;
                QOut (Term, B1)
              End (*Else*);
            If Monster ^.Flee or (User ^.Lvl >= 5 + Monster ^.Lvl)
            Then
              If Monster ^.Hits / Monster ^.MaxHits < 0.01 * Rnd (40)
              Then
                Begin
                  Pm (Monster, True, B1);
                  Ps (User ^.Name, B2);
                  B1 := '0' + B1 + ' flees from ' + B2 + '''s attack!';
                  For ILoop := 1 to MsgTerm (TermList, Local) Do
                    QOut (TermList [ILoop], B1);
                  Ps (Monster ^.Name, B1);
                  B1 := '0The ' + B1 + ' flees from your attack!';
                  QOut (Term, B1);
                  Monster ^.Experience := Monster ^.Experience Div 2;
                  If (User ^.Lvl < 5 + Monster ^.Lvl) Then
                    ShareExperience (Monster, Rm);
                  DeleteMonster (Monster, Rm);
                  Destroy (Monster);
                  User ^.DefMon := NIL
                End (*If*)
          End (*Else*)
      End (*HitMonster*);
      
    Procedure CastSpell (SpellCode: Integer);
    
      Var
        Obj: ObjectPoint;
        Player: UserPoint;
        Monster: MonsterPoint;
        GoodSpl: Boolean;
        MagType: (Chant, Scrl, Device);
        LEnchant, Damage, Sum, LvlNeeded, MPNeeded, ILoop: Integer;
        InNeeded: Integer;
        Target, Dummy: Alfa;
      
      Begin
        User ^.Hidden := False;
        MagType := Chant;
        GoodSpl := False;
        Player := NIL;
        Monster := NIL;
        Obj := NIL;
        If SpellCode = 0
        Then
          Begin
            ILoop := 1;
            Sum := 0;
            LEnchant := 0;
            User ^.Entry := XCmd;
            While ILoop <= LenBuf Do
              Begin
                If Buffer [ILoop] in ['A' .. 'Z', 'a' .. 'z'] Then
                  Begin
                    Sum := Sum + Ord (Cap (Buffer [ILoop])) - Ord ('A');
                    LEnchant := LEnchant + 1
                  End (*If*);
                ILoop := ILoop + 1
              End (*While*);
            LenBuf := 0;
            SpellCode := 0;
            While (SpellCode < Spellen) And Not GoodSpl Do
              Begin
                SpellCode := SpellCode + 1;
                GoodSpl := (SpellClass[SpellCode].SplHash = Sum) And
                           (LEnchant = SpellClass[SpellCode].SplLen)
              End (*While*)
          End (*If*)
        Else
          Begin
            GoodSpl := True;
            If SpellCode < 0
            Then
              Begin
                SpellCode := Abs (SpellCode);
                MagType := Device
              End (*If*)
            Else
              MagType := Scrl
          End (*Else*);
        If Not GoodSpl
        Then
          QOut (Term, '0You mispronounced the spell!')
        Else
          With SpellClass [SpellCode] Do
            Begin
              Target := User ^.WData;
              CapAlfa (Target);
              Num := User ^.Data;
              Case SplType of
                OnUser, OnPlayer, OnUsPlayer:
                  Begin
                    If Target = Blanks
                    Then
                      Player := User
                    Else
                      Player := FindPlayer (Target,
                                Room[User ^.RmCode].RmPlayerTail);
                    If (SplType = OnPlayer) And ((Target = Blanks) or
                       (Player = User)) or (Target <> Blanks) And
                       ((Player = NIL) Or (SplType = OnUser))
                    Then
                      Begin
                        GoodSpl := False;
                        If Target <> Blanks
                        Then
                          QOut (Term, '0That spell target is illegal!')
                        Else
                          QOut (Term, '0The spell target was not specified!')
                      End (*If*)
                  End (*OnUser*);
                OnMon, OnMonPlayer:
                  Begin
                    Player := FindPlayer (Target,
                                Room[User ^.RmCode].RmPlayerTail);
                    Monster := FindMonster (Target, Num,
                                Room[User ^.RmCode].RmMonsterTail);
                    If (Monster = NIL) And ((Player = NIL) or (SplType=OnMon))
                       Or (Player = User)
                    Then
                      Begin
                        GoodSpl := False;
                        If Target <> Blanks
                        Then
                          QOut (Term, '0That spell target is illegal!')
                        Else
                          QOut (Term, '0The spell target was not specified!')
                      End (*If*)
                  End (*OnMon*);
                OnObject:
                  Begin
                    Obj := FindObject (Target, Num, User ^.ObjectTail);
                    If Obj = NIL Then
                      Obj := FindObject (Target, Num,
                                Room[User ^.RmCode].RmObjectTail);
                    If Obj = NIL
                    Then
                      Begin
                        GoodSpl := False;
                        QOut (Term, '0Object not here!')
                      End (*If*)
                  End (*OnObject*)
              End (*Case*);
              If Room [User ^.RmCode].Safe
              Then
                If Not (SpellCode in [1, 2, 6, 13]) Then
                  Begin
                    GoodSpl := False;
                    QOut (Term,
                         '0Such magic does not work here.  Spell fails.')
                  End (*If*);
              If (Monster <> NIL) And (Player <> NIL) Then
                Player := NIL;
              If Monster <> NIL
              Then
                If Monster ^.AntiMagic
                Then
                  Begin
                    GoodSpl := False;
                    QOut (Term, '0Your spell has no effect on it!')
                  End (*If*);
              GoodSpl := GoodSpl And ReadyCheck (User ^.LastAtk);
              MPNeeded := SplMp;
              LvlNeeded := SplLvl;
              InNeeded := SplInt;
              If MagType = Scrl
              Then
                Begin
                  MPNeeded := 0;
                  InNeeded := InNeeded - 3;
                  LvlNeeded := SplLvl - 3 - Rnd (4)
                End (*If*)
              Else
                If MagType = Device
                Then
                  Begin
                    MPNeeded := 0;
                    LvlNeeded := -10;
                    InNeeded := 0
                  End (*If*);
              If MagType = Chant
              Then
                Begin
                  If (User ^.Class <> MagicUser) And
                     (SpellCode in [7, 10, 12, 14])
                  Then
                    Begin
                      GoodSpl := False;
                      QOut (Term, '0Only magic-users can cast that spell!')
                    End (*If*);
                  If (User ^.Class <> Cleric) And (SpellCode in [2, 13])
                  Then
                    Begin
                      GoodSpl := False;
                      QOut (Term, '0Only clerics can cast that spell!')
                    End (*If*);
                  If Not (User ^.Class in [Cleric, MagicUser])
                     And (SpellCode = 1)
                  Then
                    Begin
                      GoodSpl := False;
                      QOut (Term,
                        '0Only magic users and clerics may cast vigor spells!')
                    End (*If*)
                End (*If*);
              If GoodSpl And (MagType = Chant) Then
                If SpellCode in [7, 9, 10, 12, 13, 15, 16] Then
                  GoodSpl := Not SpellLimit;
              If GoodSpl
              Then
                If SpellCost (User, MPNeeded, LvlNeeded, InNeeded)
                Then
                  Begin
                    If MagType <> Device
                    Then
                      Begin
                        Dummy := SpellList [SpellCode];
                        For ILoop := 1 to 10 Do
                          If Dummy [ILoop] in ['A' .. 'Z']
                          Then
                            Dummy [ILoop] := Chr (Ord (Dummy [ILoop]) + 32);
                        Ps (Dummy, B1);
                        B1 := '0You cast a ' + B1 + ' spell!';
                        QOut (Term, B1)
                      End (*If*)
                    Else
                      QOut (Term, '0Ok.');
                    For ILoop := 1 to MsgTerm (TermList, Local) Do
                    Begin
                      Ps (User ^.Name, B1);
                      Ps (SpellList [SpellCode], B2);
                      B1 := '0' + B1 + ' casts a ' + B2 + ' spell on ';
                      If Monster <> NIL
                      Then
                        Begin
                          Pm (Monster, False, B2);
                          B1 := B1 + B2 + '!'
                        End (*If*)
                      Else
                        If Obj <> NIL
                        Then
                          Begin
                            PrintObj (Obj ^, True, False, B2);
                            B1 := B1 + B2 + '!'
                          End (*If*)
                        Else
                          If Player ^.Trm <> TermList [ILoop]
                          Then
                            Begin
                              Ps (Player ^.Name, B2);
                              B1 := B1 + B2 + '!'
                            End (*If*)
                          Else
                            B1 := B1 + 'you!';
                        QOut (TermList [ILoop], B1)
                      End (*For*);
                    Damage := SpellCase (SpellCode, User ^.Lvl, User ^.Int,
                                         Player, Monster, Obj, Target);
                    If SpellCode in [3, 4, 5, 7]
                    Then
                      Begin
                        User ^.LastAtk := RealTime + Max (5, SplMp Div 2 -
                                                          User ^.Lvl);
                        User ^.DefPlayer := NIL;
                        User ^.DefMon := NIL;
                        If Player <> NIL
                        Then
                          Begin
                            User ^.DefPlayer := Player;
                            Player ^.HitAtTime := RealTime
                          End (*If*)
                        Else
                          If Monster <> NIL
                          Then
                            User ^.DefMon := Monster
                          Else
                            Abort ('0 Mil106 - No spell target!');
                        If Damage = 0
                        Then
                          Begin
                            QOut (Term, '0It missed!');
                            If Player <> NIL Then
                              QOut (Player ^.Trm, '0It missed!')
                          End (*If*)
                        Else
                          If Player <> NIL
                          Then
                            HitPlayer (Damage)
                          Else
                            If Monster ^.Assistance
                            Then
                              ProtectNPC (User, Monster)
                            Else
                              Begin
                                If Monster ^.Defend And (Monster ^.DefPlayer =
                                       NIL) Or Monster ^.AtkLastAggr And
                                       (Monster ^.DefPlayer <> User)
                                Then
                                  Begin
                                    Monster ^.DefPlayer := User;
                                    If Monster ^.MReact >= 5 Then
                                      Monster ^.MReact := 0
                                  End (*If*);
                                HitMonster (Damage)
                              End (*Else*)
                      End (*If*)
                  End (*If*)
            End (*With*)
      End (*CastSpell*);
    
    Procedure HitAtMonster (Weapon: ObjectPoint; Plus: Integer);
    
      Var
        Damage: Integer;
        WithFist: Boolean;
      
      Begin
        WithFist := False;
        If Weapon = NIL Then
          Begin
            WithFist := True;
            New (Weapon);
            Weapon ^ := ProtoObject;
            With Weapon ^ Do
              Begin
                ObClass := Weap;
                MinHP := 1;
                MaxHP := 3;
                Strikes := 1;
                WeaPlus := -2;
                WeapType := Blunt
              End (*With*)
          End (*If*);
        With User ^ Do
          With Weapon ^ Do
            If DefMon ^.Magic And Not Magic
            Then
              QOut (Term, '0Your weapon strikes with no effect!!')
            Else
              Begin
                If Class = Paladin Then
                  If DefMon ^.SlowReact or DefMon ^.FastReact Then
                    Plus := Plus + 1;
                If Class = Fighter Then
                  Plus := Plus + 1;
                If Lvl = 1 Then
                  Plus := Plus + 2;
                If DefMon ^.Invisible Then
                  Plus := Plus - 4;
                If DefMon ^.Defend And (DefMon ^.DefPlayer = NIL) Or
                   DefMon ^.AtkLastAggr And (DefMon ^.DefPlayer <> User)
                Then
                  Begin
                    DefMon ^.DefPlayer := User;
                    If DefMon ^.MReact >= 5 Then
                      DefMon ^.MReact := 0
                  End (*If*);
                If Not DefMon ^.Permanent Then
                  If DefMon ^.MParley in [1, 3, 4] Then
                    DefMon ^.MParley := 2;
                If (Rnd (20) <> 20) And (Rnd (20) < 14 + DefMon ^.Lvl - Lvl -
                    WeaPlus - Str Div 6 - Plus)
                Then
                  If WithFist
                  Then
                    QOut (Term, '0Your fist misses!')
                  Else
                    QOut (Term, '0You missed!')
                Else
                  Begin
                    Strikes := Strikes - 1;
                    Damage := Max (0, MinHP + Rnd (MaxHP - MinHP + 1) +
                              WeaPlus + Plus);
                    If WithFist Then
                      QOut (Term, '0Punch!');
                    Case Rnd (100 - Lvl) of
                      1, 2, 3, 4:
                        Begin
                          QOut (Term, '0Double damage!');
                          Damage := Damage * 2
                        End (*1*);
                      85:
                        Begin
                          QOut (Term, '0You fumbled!');
                          Damage := 0;
                          UsWeap := NIL
                        End (*85*)
                    End (*Case*);
                    If Damage >= DefMon ^.Hits
                    Then
                      If ((DefMon ^.Lvl - Lvl)*5 > Rnd(25)) And Not SkillNew
                      Then
                        Begin
                          SkillNew := True;
                          Case Weapon ^.WeapType of
                            Sharp:
                              If Rnd (SSharp) = 1 Then
                                SSharp := Min (7, SSharp + 1);
                            Thrust:
                              If Rnd (SThrust) = 1 Then
                                SThrust := Min (7, SThrust + 1);
                            Blunt:
                              If Rnd (SBlunt) = 1 Then
                                SBlunt := Min (7, SBlunt + 1);
                            Long:
                              If Rnd (SLong) = 1 Then
                                SLong := Min (7, SLong + 1)
                          End (*Case*)
                        End (*If*);
                    HitMonster (Damage)
                  End (*Else*)
              End (*Else*);
        If WithFist Then
          Dispose (Weapon)
      End (*HitAtMonster*);
        
    Procedure HitAtPlayer (Weapon: ObjectPoint; Plus: Integer);
    (* HitAtPlayer lets one player attack another *)
    
      Var
        Damage: Integer;
        WithFist: Boolean;
      
      Begin
        WithFist := False;
        If Weapon = NIL Then
          Begin
            WithFist := True;
            New (Weapon);
            Weapon ^ := ProtoObject;
            With Weapon ^ Do
              Begin
                ObClass := Weap;
                MinHP := 1;
                MaxHP := 3;
                Strikes := 1;
                WeaPlus := -2;
                WeapType := Blunt
              End (*With*)
          End (*If*);
        With User ^ Do
          Begin
            With Weapon ^ Do
              If (Rnd(20) <> 20) And (Rnd (20) < 24 + DefPlayer ^.Lvl - Lvl -
                  WeaPlus - Str Div 6 - DefPlayer ^.AC + DefPlayer ^.Dex Div 6-
                  Plus) Or (DefPlayer ^.Hits = 0)
              Then
                Begin
                  If WithFist
                  Then
                    QOut (Term, '0Wooosh!  Your fist misses!')
                  Else
                    QOut (Term, '0You missed!');
                  If NoTimeOut (DefPlayer)
                  Then
                    Begin
                      Ps (User ^.Name, B1);
                      B1 := '0' + B1 + ' misses you!';
                      QOut (DefPlayer ^.Trm, B1)
                    End (*If*)
                End (*If*)
              Else
                Begin
                  Weapon ^.Strikes := Weapon ^.Strikes - 1;
                  Damage := Max (0, MinHP + Rnd (MaxHP - MinHP + 1) + WeaPlus +
                                 Plus);
                  If WithFist Then
                    QOut (Term, '0Pow!');
                  HitPlayer (Damage)
                End (*Else*);
            If DefPlayer <> NIL Then
              DefPlayer ^.HitAtTime := RealTime
          End (*With*);
        If WithFist Then
          Dispose (Weapon)
      End (*HitAtPlayer*);
      
    Procedure AttackSeg (CmdCode: Integer; Var Word: Alfa;
                                 Rm: RmCodeType);
      
      Type
        ToWhatType = (ToNone, ToMonster, ToPlayer);
      
      Var
        Weapon: ObjectPoint;
        ToWhat: ToWhatType;
        Plus: Integer;
      
      Function SelectWeap: ObjectPoint;
      
        Begin
          If User ^.UsWeap = NIL
          Then
            SelectWeap := NIL
          Else
            If User ^.UsWeap ^.Strikes = 0
            Then
              Begin
                User ^.UsWeap ^.Permanent := False;
                SelectWeap := NIL;
                QOut (Term, '0Your weapon is broken!')
              End (*If*)
            Else
              SelectWeap := User ^.UsWeap
        End (*SelectWeap*);
      
      Function AttackWhat (Var Word: Alfa): ToWhatType;
      
        Var
          OldDefPlayer: UserPoint;
          OldDefMon: MonsterPoint;
          I: Integer;
          Dummy: Alfa;
        
        Begin
          With User ^ Do
            Begin
              OldDefPlayer := DefPlayer;
              DefPlayer := FindPlayer (Word, Room[Rm].RmPlayerTail);
              If DefPlayer = User Then
                DefPlayer := NIL;
              If DefPlayer = NIL
              Then
                Begin 
                  OldDefMon := DefMon;
                  If Num = 0 Then
                    GetWord (Dummy, Num, Buffer, LenBuf, Loc);
                  DefMon := FindMonster (Word, Num, Room[Rm].RmMonsterTail);
                  If DefMon = NIL
                  Then
                    Begin
                      AttackWhat := ToNone;
                      If FindObject (Word, Num, Room[Rm].RmObjectTail) <> NIL
                      Then
                        QOut (Term, '0Use the command "Smash" instead.')
                      Else
                        Begin
                          Ps (Word, B1);
                          B1 := '0' + B1 + ' isn''t here.';
                          QOut (Term, B1)
                        End (*Else*)
                    End (*If*)
                  Else
                    Begin
                      AttackWhat := ToMonster;
                      If OldDefMon <> DefMon Then
                        Begin
                          Ps (Name, B1);
                          Pm (DefMon, False, B2);
                          B1 := '0' + B1 + ' attacks ' + B2 + '!';
                          For ILoop := 1 to MsgTerm (TermList, Local) Do
                            QOut (TermList [ILoop], B1)
                        End (*If*)
                    End (*Else*)
                End (*If*)
              Else
                Begin
                  AttackWhat := ToPlayer;
                  If OldDefPlayer <> DefPlayer
                  Then
                    Begin
                      If NoTimeOut (DefPlayer) Then
                        Begin
                          Ps (Name, B1);
                          B1 := '0' + B1 + ' is attacking you!';
                          QOut (DefPlayer ^.Trm, B1)
                        End (*If*);
                      Ps (Name, B1);
                      Ps (DefPlayer ^.Name, B2);
                      B1 := '0' + B1 + ' attacks ' + B2 + '!';
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        If TermList [ILoop] <> DefPlayer ^.Trm Then
                          QOut (TermList [ILoop], B1)
                    End (*If*)
                End (*Else*)
            End (*With*)
        End (*AttackWhat*);
      
      Begin (*Attack*)
        With User ^ Do
          Begin
            ToWhat := ToNone;
            Weapon := SelectWeap;
            If ReadyCheck (LastAtk) And ((Weapon <> NIL) or
                                         (User ^.UsWeap = NIL))
            Then
              Begin
                If Room[RmCode].Safe
                Then
                  QOut (Term, '0This is a safe haven.')
                Else
                  If Word = Blanks
                  Then
                    If (DefMon <> NIL) or (DefPlayer <> NIL)
                    Then
                      If DefMon <> NIL
                      Then
                        ToWhat := ToMonster
                      Else
                        ToWhat := ToPlayer
                    Else
                      QOut (Term, '0Specify target, please!')
                  Else
                    ToWhat := AttackWhat (Word);
                If ToWhat <> ToNone
                Then
                  If (CmdCode = 42) or (Fatigue > 0)
                  Then
                    Begin
                      Case CmdCode of
                        11 (*Attack*):
                          Begin
                            Plus := 0;
                            Fatigue := Max (0, Fatigue - Rnd (2) + 1)
                          End (*11*);
                        42 (*Parry*):
                          Begin
                            Plus := - (Lvl Div 2 + 1);
                            If ToWhat = ToMonster Then
                              DefMon ^.MReact := 5 (*Half Damage*)
                          End (*42*);
                        43 (*Thrust*):
                          Begin
                            Plus := Lvl;
                            Fatigue := Max (0, Fatigue - Lvl);
                            If ToWhat = ToMonster Then
                              If Rnd (4) = 4
                              Then
                                Begin
                                  DefMon ^.MReact := 6 (*Double Damage*);
                                  QOut (Term, '0You are vulnerable!')
                                End (*If*)
                          End (*43*);
                        85 (*Feint*):
                          Begin
                            QOut (Term, '0Ok.');
                            If Dex > Rnd (30)
                            Then
                              If ToWhat = ToMonster
                              Then
                                DefMon ^.MReact := 3
                              Else
                                Begin
                                  DefPlayer ^.LastAtk := RealTime + 10;
                                  Ps (Name, B1);
                                  B1 := '0' + B1 + ' feints at you!';
                                  QOut (DefPlayer ^.Trm, B1);
                                  Ps (DefPlayer ^.Name, B1);
                                  B1 := '0' + B1 + ' falls back!';
                                  QOut (Term, B1)
                                End (*Else*)
                            Else
                              QOut (Term, '0Didn''t work!');
                            ToWhat := ToNone
                          End (*85*);
                        86 (*Circle*):
                          Begin
                            QOut (Term, '0Ok.');
                            If Dex > Rnd (20)
                            Then
                              If ToWhat = ToMonster
                              Then
                                DefMon ^.MReact := 2
                              Else
                                Begin
                                  DefPlayer ^.LastAtk := RealTime + 8;
                                  Ps (Name, B1);
                                  B1 := '0' + B1 + ' circles you!';
                                  QOut (DefPlayer ^.Trm, B1);
                                  Writev (B1, '0You circle ',
                                          Pro [DefPlayer^.Sex], '!');
                                  QOut (Term, B1)
                                End (*Else*)
                            Else
                              QOut (Term, '0Didn''t work!');
                            ToWhat := ToNone
                          End (*85*);
                        72 (*BackStab*):
                          If Hidden
                          Then
                            Plus := 5
                          Else
                            Begin
                              Plus := -5;
                              QOut (Term, '0You are discovered!');
                              If ToWhat = ToMonster Then
                                DefMon ^.MReact := 6 (*Double damage*)
                            End (*Else*)
                      End (*Case*);
                      If Weapon <> NIL
                      Then
                        Case Weapon ^.WeapType of
                          Sharp:
                            Plus := Plus + SSharp;
                          Thrust:
                            Plus := Plus + SThrust;
                          Blunt:
                            Plus := Plus + SBlunt;
                          Long:
                            Plus := Plus + SLong
                        End (*Case*);
                      If ToWhat = ToPlayer
                      Then
                        LastAtk := RealTime + 8
                      Else
                        LastAtk := RealTime + 5;
                      Hidden := False;
                      If ToWhat = ToMonster
                      Then
                        If DefMon ^.Assistance
                        Then
                          ProtectNPC (User, User ^.DefMon)
                        Else
                          HitAtMonster (Weapon, Plus)
                      Else
                        If ToWhat = ToPlayer
                        Then
                          HitAtPlayer (Weapon, Plus)
                    End (*If*)
                  Else
                    QOut (Term, '0You''re too exhausted to strike!')
              End (*If*)
          End (*With*)
      End (*Attack*);
    
    Procedure Spell (SpellCode: Integer);
    
      Begin
        CastSpell (SpellCode)
      End (*Spell*);
    
    Procedure Attack (CmdCode: Integer; Var Word: Alfa; Rm: RmCodeType);

      Begin
        AttackSeg (CmdCode, Word, Rm)
      End (*Attack*);
    
    Procedure Turn (Var Word: Alfa; Num: Integer);
    
      Begin
        TurnMon (Word, Num)
      End (*Turn*);
    
    Const
      UpdatePeriod = 3600 (* One hour *);
      QuitWait = 20;
      HealWait = 30;
      
    Var
      TaskClosed: Char;
      LastUpdate: TimeType;
      TradeTime: TimeType;
      FCash, TCash: Integer;
      SFObj, STObj: Varying [20] of Char;
      NFPlyr, NTPlyr, NFObj, NTObj: Alfa;
      TName: Packed Array [1 .. 3] of Alfa;
      TClass: Packed Array [1 .. 3] of Varying [12] of Char;
      TLvl: Packed Array [1 .. 3] of 0 .. 32;
      TBuf: Packed Array [1 .. 3] of String;
      NewsBuf: Packed Array [1 .. 5] of String;
      Notice: String;
    
    Procedure Update_Seg;
    
      Var
        ILoop: Integer;

      Begin
        If (NUsers > 0) And (User <> NIL)
        Then
          For ILoop := 1 To MsgTerm (TermList, SysMsg) Do
            QOut (TermList [ILoop], '0Files updating.  Please wait.');
        For ILoop := 0 To MaxUsers Do
          If SlotTBL [ILoop] > -1
          Then
            WriteSeg (ILoop, SlotTBL [ILoop], False);
        Rewrite (EFile);
        WriteLn (EFile, Notice);
        For ILoop := 1 To 5 Do
          WriteLn (EFile, NewsBuf [ILoop]);
        For ILoop := 1 To 3 Do
          WriteLn (EFile, TLvl [ILoop]: 3, TName [ILoop], TClass [ILoop]);
        WriteLn (EFile, TaskClosed, NumRun + 1: 4, Today: 4, MSpeed: 4);
        For ILoop := 1 To LEncounter Do
          WriteLn (EFile, EncIndex [ILoop, 1]: 4, EncIndex [ILoop, 2]: 4,
                   EncIndex [ILoop, 3]: 4, EncIndex [ILoop, 4]: 4,
                   EncIndex [ILoop, 5]: 4, EncIndex [ILoop, 6]: 4);
        For ILoop := 1 To ObjListLen Do
          WriteLn (EFile, ObjIndex [ILoop, 1]: 4, ObjIndex [ILoop, 2]: 4,
                   ObjIndex [ILoop, 3]: 4, ObjIndex [ILoop, 4]: 4,
                   ObjIndex [ILoop, 5]: 4, ObjIndex [ILoop, 6]: 4);
        Reset (EFile)
      End (*Update_Seg*);
      
    Procedure Seg_MiscCmds (CmdCode: Integer; Word: Alfa; Num: Integer);

      Var
        FObj, TObj, Obj: ObjectPoint;
        TPlyr: UserPoint;
        Num2, Cost: Integer;
        Word3, Word4: Alfa;

      Begin
        With User ^ Do
          If CmdCode in [57 .. 60]
          Then
            Case CmdCode of
              57:
                If W (RmCode) = 10
                Then
                  QOut (Term, '0"I don''t have such skills.  Sorry!"')
                Else
                  If W (RmCode) <> 18
                  Then
                    QOut (Term, '0Find a smith first!')
                  Else
                    Begin
                      Obj := FindObject (Word, Num, ObjectTail);
                      If Obj = NIL
                      Then
                        QOut (Term, '0Object not found.')
                      Else
                        If Not (Obj ^.ObClass in [Weap, Armor, Shield])
                        Then
                          QOut (Term, '0"I don''t know how to repair that!"')
                        Else
                          Begin
                            Data := Trunc (Obj ^.Price * 0.60) + Rnd (5);
                            If Obj ^.Magic Then
                              Begin
                                Data := Data * 2;
                                QOut (Term,
                          '0"Very well, but it may lose its magical dweomer!"')
                              End (*If*);
                            If Obj ^.ObClass = Weap Then
                              If Obj ^.MaxHP + Obj ^.MinHP > 30 Then
                                QOut (Term,
                         '0"I''m not sure I can repair such a great weapon!"');
                            PrintObj (Obj ^, False, False, B1);
                            B1 := '0"Hmm.  Repairing ' + B1;
                            Writev (B2, ' will cost you ', Data: 0,
                                    ' shillings.  Do you accept?"');
                            B1 := B1 + B2;
                            QOut (Term, B1);
                            Entry := XRepair;
                            UsWeap := Obj
                          End (*Else*)
                    End (*Else*);
              58:
                Begin
                  Num := 1;
                  While Num <= 10 Do
                    If Not (Word [Num] in ['A' .. 'Z', ' '])
                    Then
                      Begin
                        For Num2 := Num + 1 To 10 Do
                          Word [Num2 - 1] := Word [Num2];
                        Word [10] := ' '
                      End (*If*)
                    Else
                      Num := Num + 1;
                  If Word = Blanks
                  Then
                    QOut (Term, '0Missing or bad characters in name.')
                  Else
                    If (SearchPlIndex (Word) > 0) or
                       (FindUser (Word, UserTail) <> NIL)
                    Then
                      QOut (Term, '0Name already in use elsewhere.')
                    Else
                      Begin
                        Ps (Name, B1);
                        Writev (B2, ' just changed ', Pro [Sex], ' name to ');
                        B1 := '0' + B1 + B2;
                        Ps (Word, B2);
                        B1 := B1 + B2 + '.';
                        For ILoop := 1 to MsgTerm (TermList, All) Do
                          QOut (TermList [ILoop], B1);
                        Name := Word;
                        QOut (Term, '0Name change complete.');
                        QOut (Term,
                     '0Be sure to "SAVE" your character to record the change.')
                      End (*Else*)
                End (*58*);
              59:
                Begin
                  GetWord (Word3, Num, Buffer, LenBuf, Loc);
                  If (Word3 = Blanks) or (Num <> 0)
                  Then
                    QOut (Term, '0Missing or bad characters in new password.')
                  Else
                    If Hash (Word, 10) <> PW
                    Then
                      QOut (Term, '0Wrong password, sorry.')
                    Else
                      Begin
                        PW := Hash (Word3, 10);
                        QOut (Term, '0PW change complete.');
                        QOut (Term,
                     '0Be sure to "SAVE" your character to record the change.')
                      End (*Else*)
                End (*59*);
              60:
                If TradeTime >= RealTime
                Then
                  Begin
                    Writev (B1, '0Trade already in progress.  Try again in ',
                            TradeTime - RealTime: 0, ' seconds.');
                    QOut (Term, B1)
                  End (*If*)
                Else
                  If Loc > LenBuf
                  Then
                    QOut (Term,
              '0Format is: OFFER <who> <your item/cash> FOR <their item/cash>')
                  Else
                    Begin
                      GetWord (Word3, Num, Buffer, LenBuf, Loc);
                      GetWord (Word4, Num2, Buffer, LenBuf, Loc);
                      TPlyr := FindPlayer (Word, Room[RmCode].RmPlayerTail);
                      If TPlyr = NIL
                      Then
                        QOut (Term, '0Player isn''t here!')
                      Else
                        Begin
                          FObj := FindObject (Word3, Num, ObjectTail);
                          If (FObj = NIL) And (Word3 <> Blanks)
                          Then
                            QOut (Term, '0You don''t have that!')
                          Else
                            Begin
                              TObj := FindObject (Word4, Num2,
                                        TPlyr ^.ObjectTail);
                              If (TObj <> NIL) And (Word4 <> Blanks)
                              Then
                                QOut (Term, '0Transaction cancelled.')
                              Else
                                Begin
                                  PS (TPlyr ^.Name, B1);
                                  B1 := '0Offer sent to ' + B1 + '.';
                                  QOut (Term, B1);
                                  FCash := Max (0, Num);
                                  TCash := Max (0, Num2);
                                  TradeTime := RealTime + 20;
                                  NFPlyr := Name;
                                  NTPlyr := TPlyr ^.Name;
                                  If FObj <> NIL Then
                                    SFObj := FObj ^.Name;
                                  NFObj := Word3;
                                  If TObj <> NIL Then
                                    STObj := TObj ^.Name;
                                  NTObj := Word4;
                                  Ps (Name, B1);
                                  B1 := '0' + B1 + ' offers you ';
                                  If FObj <> NIL
                                  Then
                                    PrintObj (FObj ^, False, False, B2)
                                  Else
                                    Writev (B2, FCash: 0, ' shillings');
                                  B1 := B1 + B2;
                                  If TObj <> NIL
                                  Then
                                    Begin
                                      PrintObj (TObj ^, True, False, B2);
                                      B1 := B1 + ' for ' + B2
                                    End (*If*)
                                  Else
                                    If TCash <> 0 Then
                                      Begin
                                        Writev (B2,
                                              ' for ', TCash: 0, ' shillings.');
                                        B1 := B1 + B2
                                      End (*If*);
                                  B1 := B1 + '.';
                                  QOut (TPlyr ^.Trm, B1);
                                  QOut (TPlyr ^.Trm,
                                        '0Enter "ACCEPT" to accept the offer.')
                                End (*Else*)
                            End (*Else*)
                        End (*Else*)
                    End (*Else*)
            End (*Case*)
          Else
            Abort ('0 Mil134 - Case expression out of range!')
      End (*Seg_MiscCmds*);

    Procedure Accept_Seg;

      Var
        FPlyr: UserPoint;
        FObj, TObj: ObjectPoint;
        OkTrade: Boolean;

      Begin
        OkTrade := True;
        If (TradeTime < RealTime) or (NTPlyr <> User ^.Name)
        Then
          QOut (Term, '0Nothing to accept.')
        Else
          With User ^ Do
            Begin
              FPlyr := FindPlayer (NFPlyr, Room[RmCode].RmPlayerTail);
              If FPlyr = NIL
              Then
                QOut (Term, '0Transaction cancelled.')
              Else
                Begin
                  FObj := FindObject (NFObj, FCash, FPlyr ^.ObjectTail);
                  TObj := FindObject (NTObj, TCash, ObjectTail);
                  If (FObj = NIL) And (NFObj <> Blanks) Or (TObj = NIL) And
                     (NTObj <> Blanks)
                  Then
                    QOut (Term, '0Transaction cancelled.')
                  Else
                    Begin
                      If FObj <> NIL Then
                        OkTrade := (FObj ^.Name = SFObj) And (FObj ^.Weight +
                                    Weight <= Str * 10);
                      If TObj <> NIL Then
                        OkTrade := OkTrade And (TObj ^.Name = STObj) And
                                   (TObj ^.Weight + FPlyr ^.Weight <=
                                    FPlyr ^.Str * 10);
                      OkTrade := OkTrade And (FCash <= FPlyr ^.Money) And
                                 (TCash <= Money);
                      If Not OkTrade
                      Then
                        QOut (Term, '0Transaction cancelled.')
                      Else
                        Begin
                          If FObj <> NIL
                          Then
                            Begin
                              StopUsing (FPlyr, FObj);
                              If DeleteObject (FObj, FPlyr ^.ObjectTail) Then
                                FPlyr ^.ObjectTail := FPlyr ^.ObjectTail^.Next;
                              FPlyr ^.Weight := Max (0, FPlyr ^.Weight -
                                 FObj ^.Weight);
                              FObj ^.Next := ObjectTail;
                              ObjectTail := FObj;
                              Weight := Min (5000, Weight + FObj ^.Weight)
                            End (*If*)
                          Else
                            Begin
                              FPlyr ^.Money := FPlyr ^.Money - FCash;
                              Money := Money + FCash
                            End (*Else*);
                          If TObj <> NIL
                          Then
                            Begin
                              StopUsing (User, TObj);
                              If DeleteObject (TObj, ObjectTail) Then
                                ObjectTail := ObjectTail ^.Next;
                              Weight := Max (0, Weight - TObj ^.Weight);
                              TObj ^.Next := FPlyr ^.ObjectTail;
                              FPlyr ^.ObjectTail := TObj;
                              FPlyr ^.Weight := Min (5000, FPlyr ^.Weight +
                                   TObj ^.Weight)
                            End (*If*)
                          Else
                            Begin
                              Money := Money - TCash;
                              FPlyr ^.Money := FPlyr ^.Money + TCash
                            End (*Else*);
                          TradeTime := RealTime - 50;
                          Writev (B1, '0Ok, you trade with ',
                                  Pro [FPlyr ^.Sex], '.');
                          QOut (Term, B1);
                          Ps (Name, B1);
                          B1 := '0' + B1 +
                                ' accepts your offer and trades with you.';
                          QOut (FPlyr ^.Trm, B1)
                        End (*Else*)
                    End (*Else*)
                End (*Else*)
            End (*With*)
      End (*Accept_Seg*);
    
    Procedure Seg_MinorCmds (User: UserPoint; CmdCode: Integer);
    
      Var
        ILoop: Integer;
        
      Begin
        With User ^ Do
          If CmdCode in [18 .. 21, 26 .. 28, 30, 34, 51, 83]
          Then
            Case CmdCode of
              18:
                Begin
                  TaskClosed := 'C';
                  QOut (Term, '0Milieu closed.')
                End (*18*);
              19:
                Begin
                  TaskClosed := 'O';
                  QOut (Term, '0Milieu opened.')
                End (*19*);
              51:
                Begin
                  TaskClosed := 'T';
                  QOut (Term, '0Milieu open for testing only.')
                End (*51*);
              20:
                Begin
                  Writev (B1, '0', AbsolutePlMax: 0, ' users (Capacity)');
                  QOut (Term, B1);
                  Writev (B1, '0', MaxUsers: 0, ' users (Max Online)');
                  QOut (Term, B1);
                  Writev (B1, '0', NUsers: 0, ' users (Active)');
                  QOut (Term, B1)
                End (*20*);
              21, 27:
                Begin
                  QOut (Term, '0Aborting of task not implemented yet.')
                End (*21*);
              26:
                Begin
                  Writev (B1, '0A random monster check occurs every ',
                          MSpeed: 0, ' seconds.');
                  QOut (Term, B1)
                End (*26*);
              28:
                Begin (*Help*)
                  QOut (Term, '0List of all commands:');
                  B1 := '0';
                  For ILoop := 1 to CmdListLen Do
                    Begin
                      If ILoop Mod 5 = 1 Then
                        Begin
                          QOut (Term, B1);
                          B1 := '0'
                        End;
                      Writev (B2, '   ', CmdList [ILoop]);
                      B1 := B1 + B2
                    End (*For*);
                  QOut (Term, '0')
                End (*28*);
              30:
                Begin
                  Invisible := Not Invisible;
                  Nonexistant := False;
                  If Invisible
                  Then
                    QOut (Term, '0You are now invisible.')
                  Else
                    QOut (Term, '0You are now visible.')
                End (*30*);
              34:
                Begin
                  Echo := Not Echo;
                  If Echo
                  Then
                    QOut (Term, '0Echo mode on.')
                  Else
                    QOut (Term, '0Echo mode off.')
                End (*34*);
              83:
                Begin
                  Nonexistant := Not Nonexistant;
                  Invisible := Nonexistant;
                  If Nonexistant
                  Then
                    QOut (Term, '0You no longer exist to the outside world.')
                  Else
                    QOut (Term, '0You now exist.')
                End (*83*)
            End (*Case*)
          Else
            Abort ('0 Mil133 - Case expression out of range.')
      End (*Seg_MinorCmds*);
    
    Procedure Seg_Parley (Word: Alfa; Num: Integer);
    
      Var
        Opt, ILoop, N1, N2: Integer;
        Obj: ObjectPoint;
        Mon: MonsterPoint;
      
      Begin
        Mon := FindMonster (Word, Num, Room [User ^.RmCode].RmMonsterTail);
        If Mon = NIL
        Then
          QOut (Term, '0That non-player character isn''t here.')
        Else
          With Mon ^ Do
            Begin
              Opt := MParley;
              If Opt = 9
              Then
                Opt := Rnd (8);
              PS (User ^.Name, B1);
              PM (Mon, False, B2);
              B1 := '0' + B1 + ' talks with ' + B2 + '.';
              For ILoop := 1 to MsgTerm (TermList, Local) Do
                QOut (TermList [ILoop], B1);
              If Opt in [1 .. 15]
              Then
                Case Opt of
                  1:
                    Begin
                      N1 := 0;
                      MParley := 3;
                      If WhichObj > 0 Then
                        N1 := ObjIndex [WhichObj, Rnd (6)];
                      If N1 = 0
                      Then
                        QOut (Term, '0I have nothing to sell you, good sir!')
                      Else
                        Begin
                          Find (OList, N1);
                          User ^.Data := Trunc (OList ^.Price * 0.5) +
                                         Rnd (OList ^.Price);
                          User ^.LastAtk := N1;
                          PM (Mon, True, B1);
                          PrintObj (OList ^, False, False, B2);
                          B1 := '0' + B1 + 'says, "I will sell you ' + B2;
                          Writev (B2, ' for a mere ', User ^.Data: 0,
                                  ' shillings."');
                          B1 := B1 + B2;
                          QOut (Term, B1);
                          User ^.Entry := XParley
                        End (*Else*)
                    End (*1*);
                  2, 3, 4:
                    Begin
                      If Opt = 2
                      Then
                        N1 := Rnd (5)
                      Else
                        If Opt = 3
                        Then
                          N1 := 5 + Rnd (5)
                        Else
                          N1 := Rnd (10);
                      PM (Mon, True, B1);
                      B1 := '0' + B1 + ' says, "';
                      PrintDesc (3, N1, 0, False, B1, B2);
                      B2 := B2 + '"';
                      QOut (Term, B2)
                    End (*2*);
                  5, 8:
                    If User ^.Lvl < 5 + Lvl
                    Then
                      Begin
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' stands its ground!';
                        QOut (Term, B1)
                      End (*If*)
                    Else
                      Begin
                        N1 := 0;
                        If Opt = 8
                        Then
                          Begin
                            MParley := 5;
                            If WhichObj > 0 Then
                              N1 := ObjIndex [WhichObj, Rnd (6)];
                            If N1 > 0
                            Then
                              Begin
                                Find (OList, N1);
                                New (Obj);
                                Obj ^ := OList ^;
                                Obj ^.Next := Room [User ^.RmCode].RmObjectTail;
                                Room [User ^.RmCode].RmObjectTail := Obj;
                                N1 := 1
                              End (*If*)
                          End (*If*);
                        N2 := Rnd (2);
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' ';
                        If N1 > 0
                        Then
                          Begin
                            PrintObj (Obj ^, False, False, B2);
                            B1 := B1 + 'throws down ' + B2 + ' and '
                          End (*If*);
                        If N2 = 1
                        Then
                          B1 := B1 + 'begs for mercy!'
                        Else
                          B1 := B1 + 'flees from your sight!';
                        QOut (Term, B1);
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' ';
                        If N1 > 0 Then
                          Begin
                            PrintObj (Obj ^, False, False, B2);
                            B1 := B1 + 'throws down ' + B2 + ' and '
                          End (*If*);
                        If N2 = 1
                        Then
                          B1 := B1 + 'begs for mercy!'
                        Else
                          Begin
                            PS (User ^.Name, B2);
                            B1 := B1 + 'flees from ' + B2 + '''s sight!'
                          End (*Else*);
                        For ILoop := 1 to MsgTerm (TermList, Local) Do
                          QOut (TermList [ILoop], B1);
                        If N2 = 2
                        Then
                          Begin
                            DeleteMonster (Mon, User ^.RmCode);
                            Destroy (Mon)
                          End (*If*)
                      End (*Else*);
                  6:
                    If Rnd (2) = 2
                    Then
                      Begin
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' says something in a strange tounge.';
                        QOut (Term, B1)
                      End (*If*)
                    Else
                      Begin
                        PM (Mon, True, B1);
                        B1 := '0' + B1 + ' makes no apparent response.';
                        QOut (Term, B1)
                      End (*Else*);
                  7:
                    Begin
                      DefPlayer := User;
                      PM (Mon, True, B1);
                      B1 := '0' + B1 + ' attacks you!';
                      QOut (Term, B1);
                      PM (Mon, True, B1);
                      PS (User ^.Name, B2);
                      B1 := '0' + B1 + ' attacks ' + B2;
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        QOut (TermList [ILoop], B1)
                    End (*7*);
                  10:
                    Begin
                      PM (Mon, True, B1);
                      B1 := '0** ZAP **  ' + B1 + ' teleports you elsewhere!';
                      QOut (Term, B1);
                      PM (Mon, True, B1);
                      Ps (User ^.Name, B2);
                      B1 := '0' + B1 + ' makes ' + B2 +
                            ' vanish in a cloud of smoke!';
                      For ILoop := 1 to MsgTerm (TermList, Local) Do
                        QOut (TermList [ILoop], B1);
                      DeletePlayer (User, User ^.RmCode);
                      PlacePlayer (User, 30 + Rnd (570))
                    End (*10*);
                  11, 12, 13, 14, 15:
                    Begin
                      PM (Mon, True, B1);
                      B1 := '0' + B1 + ' says, "';
                      PrintDesc (3, Opt - 10, 0, False, B1, B2);
                      B2 := B2 + '"';
                      QOut (Term, B2)
                    End (*11*)
                End (*Case*)
              Else
                Begin
                  PM (Mon, True, B1);
                  B1 := '0' + B1 + ' makes no apparent response.';
                  QOut (Term, B1)
                End (*Else*)
            End (*With*)
      End (*Seg_Parley*);
    
    Procedure DoYesNo;
    
      Var
        Yes: Boolean;
        Obj: ObjectPoint;
        Num: Integer;
        Word: Alfa;
      
      Begin
        GetWord (Word, Num, Buffer, LenBuf, Loc);
        Yes := (Word [1] in ['Y', 'y']);
        With User ^ Do
          Case Entry of
            XParley:
              If Yes Then
                If Data > Money
                Then
                  QOut (Term, '0You have not enough money, Effendi!')
                Else
                  Begin
                    Money := Money - Data;
                    New (Obj);
                    Find (OList, LastAtk);
                    Obj ^ := OList ^;
                    Obj ^.Next := Room[RmCode].RmObjectTail;
                    Room[RmCode].RmObjectTail := Obj;
                    QOut (Term,
          '0Here you are, my friend.  You are indeed a shrewd buyer, Effendi!')
                  End (*Else*)
              Else
                QOut (Term,
               '0Oh please reconsider, Effendi!  It is of such high quality!');
            XRepair:
              Begin
                Obj := UsWeap;
                UsWeap := NIL;
                If Yes And (Obj <> NIL)
                Then
                  If Data > Money
                  Then
                    QOut (Term, '0"You don''t have enough money!"')
                  Else
                    With Obj ^ Do
                      Begin
                        If Rnd (2) = 1 Then
                          Magic := False;
                        Case ObClass of
                          Weap:
                            If (MaxHP + MinHP > 30) And (Rnd (2) = 1)
                            Then
                              Begin
                                QOut (Term,
                     '0<<CRACK>>  "Oops!  Sorry!" the repairman says meekly.');
                                MinHP := 1;
                                MaxHP := MaxHP Div 2 + 1
                              End (*If*)
                            Else
                              Begin
                                If Not Magic Then
                                  WeaPlus := Min (0, WeaPlus);
                                Strikes := Min (100, Strikes * 2 + 50)
                              End (*Else*);
                          Shield:
                            ShHits := Min (50, ShHits * 2 + 25);
                          Armor:
                            ArmHits := Min (50, ArmHits * 2 + 25)
                        End (*Case*);
                        QOut (Term,
                             '0"Here it is sir, repaired as well it can be."');
                        Money := Money - Data
                      End (*With*)
              End (*XRepair*);
            XSell:
              Begin
                Obj := UsWeap;
                UsWeap := NIL;
                If Yes And (Obj <> NIL)
                Then
                  Begin
                    Money := Money + Data;
                    Weight := Max (0, Weight - Obj ^.Weight);
                    If DeleteObject (Obj, ObjectTail) Then
                      ObjectTail := ObjectTail ^.Next;
                    ODestroy (Obj);
                    QOut (Term, '0"Thank you!  Come again!"')
                  End (*If*)
              End (*XSell*)
          End (*Case*);
        User ^.Entry := XCmd;
        Loc := LenBuf + 1;
        PromptUser (User)
      End (*DoYesNo*);

    Procedure EnterNotice;
    
      Var
        ILoop: Integer;
      
      Begin
        Notice := '';
        For ILoop := Loc to Min (79, LenBuf) Do
          Notice := Notice + Buffer [ILoop];
        Loc := LenBuf + 1;
        User ^.Entry := XCmd;
        PromptUser (User)
      End (*EnterNotice*);
    
    Procedure EnterNews;
    
      Var
        ILoop, JLoop: Integer;
        Found: Boolean;
        Temp: String;
      
      Begin
        ILoop := 1;
        Found := False;
        While Not Found And (ILoop <= 5) Do
          Begin
            Found := (Length (NewsBuf [ILoop]) = 0);
            ILoop := ILoop + 1
          End (*While*);
        If Not Found
        Then
          QOut (Term, '0*DELETENEWS a line first.')
        Else
          Begin
            ILoop := ILoop - 1;
            NewsBuf [ILoop] := '';
            For JLoop := Loc to Min (79, LenBuf) Do
              NewsBuf [ILoop] := NewsBuf [ILoop] + Buffer [JLoop];
            Writev (B1, '0Entered as line ', ILoop: 0);
            QOut (Term, B1)
          End (*Else*);
        Loc := LenBuf + 1;
        User ^.Entry := XCmd;
        PromptUser (User)
      End (*EnterNews*);

    Procedure UpdateF;
    
      Begin
        Update_Seg
      End (*UpdateF*);
      
    Procedure YesNo;
    
      Begin
        DoYesNo
      End (*YesNo*);
    
    Procedure MiscCmds (CmdCode: Integer; Word: Alfa; Num: Integer);
    
      Begin
        Seg_MiscCmds (CmdCode, Word, Num)
      End (*MiscCmds*);

    Procedure Accept;

      Begin
        Accept_Seg
      End (*Accept*);
      
    Procedure MinorCmds (User: UserPoint; CmdCode: Integer);
    
      Begin
        Seg_MinorCmds (User, CmdCode)
      End (*MinorCmds*);
    
    Procedure Parley (Word: Alfa; Num: Integer);
    
      Begin
        Seg_Parley (Word, Num)
      End (*Parley*);
      
    Procedure EnterData;
    
      Begin
        If User ^.Entry = XNotice
        Then
          EnterNotice
        Else
          If User ^.Entry = XNews
          Then
            EnterNews
      End (*EnterData*);

    Procedure Appeal;
    
      Var
        Dm: UserPoint;
        Exit, ILoop: Integer;
      
      Function FindDm (UserTail: UserPoint): UserPoint;
      
        Var
          Found: Boolean;
        
        Begin
          Found := False;
          While (UserTail <> NIL) And Not Found Do
            If UserTail ^.SSJ
            Then
              Found := True
            Else
              UserTail := UserTail ^.NextUser;
          If Found
          Then
            FindDm := UserTail
          Else
            FindDM := NIL
        End (*FindDm*);
        
      Begin
        If Not SpellLimit
        Then
          Begin
            Dm := FindDm (UserTail);
            If Dm <> NIL
            Then
              QOut (Term, '0Ding dong!  You wake up the DM.')
            Else
              Begin
                Exit := 0;
                For ILoop := 1 to 6 Do
                  Exit := Exit + Room [User ^.RmCode].Adjoin [ILoop];
                Exit := Exit + Room [User ^.RmCode].Out;
                If (Exit = 0) And (Room [User ^.RmCode].RmObjectTail = NIL)
                Then
                  Begin
                    QOut (Term, '0Sigh, very well...');
                    DeletePlayer (User, User ^.RmCode);
                    PlacePlayer (User, 1);
                    QOut (Term, '0*** Poof *** You are elsewhere..')
                  End (*If*)
                Else
                  QOut (Term,
                     '0Sorry, the DM isn''t here right now.  Try again later.')
              End (*Else*);
            While DM <> NIL Do
              Begin
                If Not DM ^.NonExistant
                Then
                  Begin
                    Ps (User ^.Name, B1);
                    B1 := '0*** ' + B1 + ' summons your assistance.';
                    QOut (Dm ^.Trm, B1);
                    Writev (B1, '0*** Piety rating is ', User ^.Pty: 0);
                    QOut (Dm ^.Trm, B1);
                    Writev (B1, '0*** Recommended reaction: ');
                    Case User ^.Pty of
                      -10, -9, -8, -7, -6, -5, -4, -3:
                        B2 := 'Put them in a LOT of trouble.';
                      -2, -1, 0, 1, 2:
                        Writev (B2, 'Make the situation even worse for ',
                                Pro [User ^.Sex]);
                      3, 4, 5:
                        Writev (B2, 'Laugh in ', Pro [User ^.Sex], ' face.');
                      6, 7, 8:
                        B2 := 'Neutral.  Ask what''s wrong.';
                      9, 10, 11:
                        B2 := 'Tepid.  Help them, but not too much.';
                      12, 13, 14:
                        B2 := 'Positive.  Help player out of situation.';
                      15, 16, 17, 18:
                        B2 := 'Very positive.  Save player immediately.';
                      19, 20, 21, 22, 23, 24, 25:
                        Writev (B2, 'Save player and then send ',
                                Pro [User ^.Sex], ' on a quest.')
                    End (*Case*);
                    B1 := B1 + B2;
                    QOut (Dm ^.Trm, B1)
                  End (*If*);
                Dm := FindDm (DM ^.NextUser)
              End (*While*);
            User ^.Pty := Max (-10, User ^.Pty - 1)
          End (*If*)
      End (*Appeal*);

    Procedure Run;

      Var
        ILoop, Dir: Integer;
        GoodDir, DrWeap, DrShield: Boolean;

      Begin
        With User ^ Do
          Begin
            ILoop := 4;
            GoodDir := False;
            DrWeap := False;
            DrShield := False;
            Repeat
              Dir := Rnd (7);
              If Dir < 7
              Then
                GoodDir := (Room[RmCode].Adjoin[Dir] > 0)
              Else
                GoodDir := (Room[RmCode].Out > 0);
              ILoop := ILoop - 1
            Until GoodDir or (ILoop = 0);
            If Not GoodDir
            Then
              QOut (Term, '0You fail to escape!')
            Else
              Begin
                If UsWeap <> NIL
                Then
                  Begin
                    If DeleteObject (UsWeap, ObjectTail) Then
                      ObjectTail := ObjectTail ^.Next;
                    Weight := Weight - UsWeap ^.Weight;
                    UsWeap ^.Next := Room[RmCode].RmObjectTail;
                    Room[RmCode].RmObjectTail := UsWeap;
                    UsWeap := NIL;
                    DrWeap := True
                  End (*If*);
                If UsShield <> NIL
                Then
                  Begin
                    If DeleteObject (UsShield, ObjectTail) Then
                      ObjectTail := ObjectTail ^.Next;
                    Weight := Weight - UsShield ^.Weight;
                    UsShield ^.Next := Room[RmCode].RmObjectTail;
                    Room[RmCode].RmObjectTail := UsShield;
                    StopUsing (User, UsShield);
                    DrShield := True
                  End (*If*);
                Ps (Name, B1);
                B1 := '0' + B1 + ' ';
                If DrWeap Or DrShield
                Then
                  Begin
                    B1 := B1 + 'drops his ';
                    If DrWeap Then
                      B1 := B1 + 'weapon and ';
                    If DrShield Then
                      B1 := B1 + 'shield and '
                  End (*If*);
                B1 := B1 + 'runs away like a blithering idiot!';
                For ILoop := 1 to MsgTerm (TermList, Local) Do
                  QOut (TermList [ILoop], B1);
                QOut (Term, '0Aarggghhh!  You run like crazy!');
                DeletePlayer (User, RmCode);
                Room[RmCode].LastDir := Dir;
                If Dir < 7
                Then
                  PlacePlayer (User, Room[RmCode].Adjoin[Dir])
                Else
                  PlacePlayer (User, Room[RmCode].Out);
                RoomDisplay (RmCode, False)
              End (*Else*)
          End (*With*)
      End (*Run*);
    
    Procedure Pawn (Word: Alfa; Num: Integer);
    
      Var
        Amount: Integer;
        Object: ObjectPoint;
      
      Begin
        If W (User ^.RmCode) <> 8
        Then
          QOut (Term, '0Go to the pawn shop first.')
        Else
          Begin
            Object := FindObject (Word, Num, User ^.ObjectTail);
            If Object <> NIL
            Then
              Begin
                StopUsing (User, Object);
                Amount := Object ^.Price;
                With Object ^ Do
                  Case ObClass of
                    Weap:
                      If Strikes < 100 Then
                        Amount := Round (Amount * (Strikes / 100.0) + 1.00);
                    Shield:
                      If ShHits < 50 Then
                        Amount := Round (Amount * (ShHits / 50.0));
                    Armor:
                      If ArmHits < 50 Then
                        Amount := Round (Amount * (ArmHits / 50.0));
                    MagDevice:
                      If NumCharges = 0 Then
                        Amount := 5
                  End (*Case*);
                Writev (B1, '0"Well, I''ll give you ', Amount: 0,
                        ' shillings for ');
                PrintObj (Object ^, True, False, B2);
                B1 := B1 + B2 + '.  Is this';
                QOut (Term, B1);
                QOut (Term, '0to your satisfaction?"');
                User ^.Entry := XSell;
                User ^.Data := Amount;
                User ^.UsWeap := Object
              End (*If*)
            Else
              QOut (Term, '0You don''t own that item.')
          End (*Else*)
      End (*Pawn*);
    
    Procedure Buy (Word: Alfa; Num, Rm: Integer);

      Var
        ILoop, SecsDk: Integer;
        Object: ObjectPoint;

      Begin
        With User ^ Do
          Begin
            ILoop := W (Rm);
            If ILoop in [3, 4, 10]
            Then
              Case ILoop of
                3:
                  If Money >= 1
                  Then
                    Begin
                      Money := Money - 1;
                      If Drunk < RealTime Then
                        Drunk := RealTime;
                      Drunk := Drunk + 30;
                      SecsDk := Drunk - RealTime;
                      If SecsDk <= 60
                      Then
                        QOut (Term, '0That was good!')
                      Else
                        If SecsDk <= 120
                        Then
                          QOut (Term, '0That''s good! (HIC)')
                        Else
                          If SecsDk <= 60
                          Then
                            QOut (Term, '0Thash gud!')
                          Else
                            Begin
                              DeletePlayer (User, Rm);
                              Rm := Rnd (10);
                              PlacePlayer (User, Rm);
                              QOut (Term,
                     '0You seem to have staggered off somewhere...  You find');
                              RoomDisplay (RmCode, False)
                            End (*Else*)
                    End (*If*)
                  Else
                    QOut (Term,
                            '0Bartender says, "Your credit is no good here!"');
                4:
                  If Money < 1
                  Then
                    QOut (Term, '0"Sorry buddy, you got no money."')
                  Else
                    Begin
                      Money := Money - 1;
                      QOut (Term, '0');
                      QOut (Term,
                           '0((( The County Press.    Issue #69.  Day 37 )))');
                      QOut (Term, '0');
                      For ILoop := 1 to 5 Do
                        If Length (NewsBuf [ILoop]) > 0
                        Then
                          Begin
                            Writev (B1, '0', NewsBuf [ILoop]);
                            QOut (Term, B1)
                          End (*If*);
                      QOut (Term, '0');
                      For ILoop := 1 to 3 Do
                        If TLvl [ILoop] > 0
                        Then
                          Begin
                            Ps (TName [ILoop], B1);
                            PNth (TLvl [ILoop], B2);
                            B1 := '0' + B1 + ', the ' + B2;
                            Writev (B2, 'level ', TClass [ILoop], ', was ');
                            B1 := B1 + B2;
                            Case Rnd (5) of
                              1:
                                B1 := B1 + 'unexpectedly ';
                              2:
                                B1 := B1 + 'suddenly ';
                              3:
                                B1 := B1 + 'mysteriously ';
                              4:
                                B1 := B1 + 'horribly ';
                              5:
                                B1 := B1 + 'viciously '
                            End (*Case*);
                            Case Rnd (5) of
                              1:
                                B1 := B1 + 'murdered';
                              2:
                                B1 := B1 + 'killed';
                              3:
                                B1 := B1 + 'slain';
                              4:
                                B1 := B1 + 'butchered';
                              5:
                                B1 := B1 + '"terminated"'
                            End (*Case*);
                            B1 := B1 + ' yesterday.';
                            QOut (Term, B1);
                            If Length (TBuf [ILoop]) > 0
                            Then
                              Begin
                                Writev (B1, '0', TBuf [ILoop]);
                                QOut (Term, B1)
                              End (*If*);
                            QOut (Term, '0')
                          End (*If*)
                    End (*Else*);
                10:
                  Begin
                    If (Num < 1) or (Num > Min (20, RanObjLen))
                    Then
                      QOut (Term, '0Item number out of bounds.')
                    Else
                      Begin
                        Find (OList, Num);
                        If OList ^.Price > User ^.Money
                        Then
                          QOut (Term,
                                   '0You don''t have enough cash to buy that.')
                        Else
                          Begin
                            User ^.Money := User ^.Money - OList ^.Price;
                            New (Object);
                            Object ^ := OList ^;
                            Object ^.Next := Room[RmCode].RmObjectTail;
                            Room[RmCode].RmObjectTail := Object;
                            QOut (Term, '0"Here you are, sir.  Thank you!"');
                            QOut (Term,
                           '0"Oh, be sure and take it with you as you leave!"')
                          End (*Else*)
                      End (*Else*)
                  End (*10*)
              End (*Case*)
            Else
              QOut (Term, '0Nothing to purchase here.')
          End (*With*)
      End (*Buy*);

    Procedure Catalog;

      Var
        ILoop: Integer;

      Begin
        If W (User ^.RmCode) <> 10
        Then
          QOut (Term, '0I don''t understand')
        Else
          Begin
            QOut (Term, '0Inventory of armaments for sale');
            QOut (Term, '0  To purchase, enter: BUY <Item Number>');
            QOut (Term, '0');
            QOut (Term, '0 # Type       Cost Weight Name');
            For ILoop := 1 to Min (20, RanObjLen) Do
              With OList ^ Do
                Begin
                  Find (OList, ILoop);
                  Writev (B1, '0', ILoop: 2, ' ');
                  If ObClass in [Weap, Shield, Armor]
                  Then
                    Case ObClass of
                      Weap:
                        B1 := B1 + 'Weapon';
                      Shield:
                        B1 := B1 + 'Shield';
                      Armor:
                        B1 := B1 + 'Armor '
                    End (*Case*)
                  Else
                    B1 := B1 + 'Other ';
                  Writev (B2, Price: 9, Weight: 7, ' ');
                  B1 := B1 + B2;
                  PrintObj (OList ^, False, True, B2);
                  B1 := B1 + B2;
                  If ObClass = Weap
                  Then
                    Begin
                      Writev (B2, ', ', MinHP: 0, '-', MaxHP: 0, ' hits.');
                      B1 := B1 + B2
                    End (*If*)
                  Else
                    B1 := B1 + '.';
                  QOut (Term, B1)
                End (*With*)
          End (*Else*)
      End (*Catalog*);

    Procedure FollowPlyr (Var Word: Alfa);
    
      Var
        Leader: UserPoint;
      
      Begin
        Leader := FindPlayer (Word, Room [User ^.RmCode].RmPlayerTail);
        If Leader = NIL
        Then
          QOut (Term, '0Player not here.')
        Else
          If Leader ^.Name = User ^.Name
          Then
            QOut (Term, '0You can''t follow yourself!')
          Else
            Begin
              User ^.Follow := Leader;
              QOut (Term, '0Ok.');
              If Not (User ^.Hidden or User ^.Invisible) Then
                Begin
                  PS (User ^.Name, B1);
                  B1 := '0' + B1 + ' follows you!';
                  QOut (Leader ^.Trm, B1)
                End (*If*)
            End (*Else*)
      End (*FollowPlyr*);
    
    Procedure Lose (Var Word: Alfa);
    
      Var
        FollowPlyr: UserPoint;
      
      Begin
        FollowPlyr := FindPlayer (Word, Room [User ^.RmCode].RmPlayerTail);
        If FollowPlyr = NIL
        Then
          QOut (Term, '0Player not here.')
        Else
          If FollowPlyr ^.Follow <> User
          Then
            QOut (Term, '0Player not following you anyway.')
          Else
            If Not (FollowPlyr ^.Class = Ranger) And ((Rnd (3) = 1) or
                   (User ^.Weight < FollowPlyr ^.Weight))
            Then
              Begin
                FollowPlyr ^.Follow := NIL;
                Writev (B1, '0You lose ', Pro [FollowPlyr ^.Sex], '!');
                QOut (Term, B1);
                Ps (User ^.Name, B1);
                B1 := '0' + B1 + ' loses you!';
                QOut (FollowPlyr ^.Trm, B1)
              End (*If*)
            Else
              QOut (Term, '0Didn''t work!')
      End (*Lose*);
      
    Procedure WhyDie;
    
      Var
        ILoop, Indx: Integer;
      
      Begin
        User ^.Status := SLogin;
        DeletePlayer (User, User ^.RmCode);
        If (Min (Min (TLvl [1], TLvl [2]), TLvl [3]) < User ^.Lvl)
        Then
          Begin
            Indx := 3;
            For ILoop := 3 DownTo 1 Do
              If TLvl [ILoop] < TLvl [Indx] Then
                Indx := ILoop;
            User ^.Entry := XDead;
            TLvl [Indx] := User ^.Lvl;
            TName [Indx] := User ^.Name;
            TClass [Indx] := CName [User ^.Class];
            PromptUser (User)
          End (*If*)
        Else
          Dead
      End (*WhyDie*);
      
    Procedure EnterWhyDie;
    
      Var
        ILoop, JLoop: Integer;
        Found: Boolean;
      
      Begin
        ILoop := 0;
        Found := False;
        While Not Found And (ILoop < 3) Do
          Begin
            ILoop := ILoop + 1;
            Found := ((TName [ILoop] = User ^.Name) And
                      (TLvl [ILoop] = User ^.Lvl))
          End (*While*);
        If Not Found
        Then
          QOut (Term, '0On second thought, forget it!')
        Else
          Begin
            TBuf [ILoop] := '                    ';
            TBuf [ILoop] := TBuf [ILoop] + TBuf [ILoop] +
                            TBuf [ILoop] + TBuf [ILoop];
            TBuf [ILoop] := '';
            For JLoop := 1 to Min (78, LenBuf) Do
              TBuf [ILoop] := TBuf [ILoop] + Buffer [JLoop]
          End (*Else*);
        Dead
      End (*EnterWhyDie*);
    
    Procedure Quit (CmdCode: Integer);
    
      Var
        Num, ILoop: Integer;
        Delay: TimeType;
        Word: Alfa;
      
      Begin
        Delay := RealTime - User ^.HitAtTime;
        GetWord (Word, Num, Buffer, LenBuf, Loc);
        User ^.Entry := XCmd;
        If Word [1] in ['Y', 'y']
        Then
          If Delay = 0
          Then
            QOut (Term, '0Not while you''re being attacked!')
          Else
            If Delay < QuitWait
            Then
              Begin
                Writev (B1, '0Sorry, you must wait at least ',
                        QuitWait - Delay: 0, ' more seconds before quitting.');
                QOut (Term, B1)
              End (*If*)
            Else
              Begin
                Ps (User ^.Name, B1);
                B1 := '0### ' + B1;
                If CmdCode = 39
                Then
                  Writev (B2, ' just killed ', Pro [User ^.Sex], 'self.',
                          '  We shall all miss ', Pro [User ^.Sex],
                          ' dearly.')
                Else
                  B2 := ' has quit adventuring.';
                B1 := B1 + B2;
                For ILoop := 1 to MsgTerm (TermList, All) Do
                  QOut (TermList [ILoop], B1);
                If CmdCode = 39 (*Suicide*)
                Then
                  Kill
                Else
                  Begin
                    QOut (Term, '0Character file updated.');
                    Logoff (User)
                  End (*Else*);
                QOut (Term, '0End Milieu.');
                QOut (Term, '2');
                QDea (Term);
                User := NIL
              End (*Else*)
      End (*Quit*);
    
    Procedure GetStatus (Word: Alfa; User: UserPoint);

      Var
        Player: UserPoint;

      Procedure DispStatus (Plr: UserPoint);

        Begin
          With Plr ^ Do
            Begin
              B1 := '0' + Name + ' ';
              If MesBlock
              Then
                B1 := B1 + '*'
              Else
                B1 := B1 + ' ';
              B1 := B1 + ' ' + LastCmd + ' ';
              B2 := ' ';
              If Lvl >= 10
              Then
                Case Class of
                  Fighter:
                    If Sex = Male
                    Then
                      B2 := 'Lord'
                    Else
                      B2 := 'Lady';
                  Thief:
                    B2 := 'Master Thief';
                  MagicUser:
                    B2 := 'Wizard';
                  Cleric:
                    B2 := 'High Priest';
                  Barbarian:
                    B2 := 'Barbarian Chieftain';
                  Ranger:
                    If Sex = Male
                    Then
                      B2 := 'Ranger Lord'
                    Else
                      B2 := 'Ranger Lady';
                  Paladin:
                    If Sex = Male
                    Then
                      B2 := 'Lord of the Quest'
                    Else
                      B2 := 'Lady of the Quest';
                  Otherwise
                    B2 := Cname [Class]
                End (*Case*)
              Else
                B2 := Cname [Class];
              B1 := B1 + B2 + ' ';
              If User ^.SSJ
              Then
                Begin
                  Writev (B2, Lvl: 0, ' ');
                  B1 := B1 + B2
                End (*If*);
              If NonExistant
              Then
                B1 := B1 + '(NonExist) '
              Else
                If Invisible
                Then
                  B1 := B1 + '(Inv) ';
              If User ^.Master And (Sex = Female)
              Then
                B1 := B1 + '(F) ';
              If User ^.SSJ
              Then
                If Status = SNormal
                Then
                  Begin
                    Writev (B2, '(', W (RmCode): 0, ')');
                    B1 := B1 + B2
                  End (*If*);
              QOut (Term, B1)
            End (*With*)
        End (*DispStatus*);

      Begin (*GetStatus*)
        QOut (Term, '0');
        If Not User ^.Brief
        Then
          QOut (Term, '0Name       S LastCmd    Class');
        If Word <> Blanks
        Then
          Begin
            Player := FindUser (Word, UserTail);
            If Player = NIL
            Then
              QOut (Term, '0Player not active.')
            Else
              If Not Player ^.NonExistant
              Then
                DispStatus (Player)
              Else
                QOut (Term, '0Player not active.')
          End (*If*)
        Else
          Begin
            Player := UserTail;
            Repeat
              If (Not Player ^.Invisible And (Player ^.Status = SNormal))
                 Or User ^.SSJ
              Then
                DispStatus (Player);
              Player := Player ^.NextUser
            Until Player = NIL
          End (*Else*)
      End (*GetStatus*);

    Procedure Talk (CmdCode: Integer; Word: Alfa);
 
      Var
        Plyr: UserPoint;
        NumHearing: Integer;
        TalkHow: TalkHowType;
        MsgStart, MsgEnd: Integer;
        NoID: Boolean;
        LogTerm: WInt;
 
      Procedure TextLimits (Var MesStart, MesEnd: Integer);
 
        Var
          KLoop: Integer;
 
        Begin (*TextLimits*)
          KLoop := 1;
          While (KLoop <= LenBuf) And (Buffer [KLoop] <> '"') Do
            KLoop := KLoop + 1;
          If KLoop > LenBuf
          Then
            MesStart := 0
          Else
            Begin
              MesStart := KLoop + 1;
              MesEnd := LenBuf;
              If Buffer [LenBuf] = '"'
              Then
                MesEnd := LenBuf - 1
            End (*Else*)
        End (*TextLimits*);
 
      Procedure SendMsg (Tm: Wint; Verb: Var256; MSTart, MEnd: Integer;
                         NoID: Boolean);
 
        Var
          LineLen, JLoop: Integer;
 
        Begin
          B1 := '0';
          If Not NoID
          Then
            Begin
              Ps (User ^.Name, B2);
              B1 := B1 + B2 + Verb + ' "';
              LineLen := 65
            End (*If*)
          Else
            LineLen := 1000;
          For JLoop := MStart To Min (MEnd, MStart + LineLen) Do
            If NoID And (Buffer [JLoop] = '\')
            Then
              Begin
                QOut (Tm, B1);
                B1 := '0'
              End (*If*)
            Else
              B1 := B1 + Buffer [JLoop];
          If MStart + LineLen < MEnd
          Then
            Begin
              QOut (Tm, B1);
              B1 := '0     ';
              For JLoop := MStart + LineLen + 1 To Mend Do
                B1 := B1 + Buffer [JLoop]
            End (*If*);
          If Not NoID
          Then
            B1 := B1 + '"';
          QOut (Tm, B1)
        End (*SendMsg*);
 
      Begin (*Talk*)
        NoID := (CmdCode In [36, 37, 38]) Or (CmdCode = 82);
        If Word = Blanks
        Then
          QOut (Term, '0Missing text to send.')
        Else
          Begin
            User ^.Hidden := False;
            TextLimits (MsgStart, MsgEnd);
            If MsgStart <= 0
            Then
              QOut (Term, '0Missing quotation marks.  Send <who> "text"')
            Else
              If Word [1] <> '"'
              Then
                Case CmdCode Of
                  36, 12 (* Say *):
                    Begin
                      Plyr := FindPlayer (Word, Room [User ^.RmCode].
                                          RmPlayerTail);
                      If Plyr <> NIL
                      Then
                        If Plyr ^.NonExistant
                        Then
                          Plyr := NIL;
                      If Plyr <> NIL
                      Then
                        Begin
                          If NoTimeOut (Plyr)
                          Then
                            SendMsg (Plyr ^.Trm, ' whispers,', MsgStart,
                                     MsgEnd, NoID)
                          Else
                            QOut (Term,
                                  '0Player timed out - message not sent.');
                          If (Rnd (100) <= 10) And (CmdCode <> 36)
                          Then
                            For ILoop := 1 To MsgTerm (TermList, Local) Do
                              If TermList [ILoop] <> Plyr ^.Trm
                              Then
                                Begin
                                  Ps (User ^.Name, B1);
                                  Ps (Plyr ^.Name, B2);
                                  B1 := '0You overhear ' + B1 +
                                        ' whispering to ' + B2 + '!';
                                  QOut (TermList [ILoop], B1);
                                  SendMsg (TermList [ILoop],
                                           ' is whispering: ',
                                           MsgStart, MsgEnd, False)
                                End (*If*)
                        End (*If*)
                      Else
                        Begin
                          Ps (Word, B1);
                          B1 := '0' + B1 + ' is not here.';
                          QOut (Term, B1)
                        End (*Else*)
                    End (*36,12*);
                  37, 13 (* Yell *):
                    QOut (Term,
                          '0You can''t selectively yell to just one player!');
                  82, 38, 14 (* Send and *Logoff *):
                    If SpellCost (User, 1, -5, 5)
                    Then
                      Begin
                        Plyr := FindUser (Word, UserTail);
                        If Plyr <> NIL
                        Then
                          If Plyr ^.NonExistant
                          Then
                            Plyr := NIL;
                        If Plyr <> NIL
                        Then
                          Begin
                            If CmdCode = 82
                            Then
                              QOut (Plyr ^.Trm, '0');
                            If NoTimeOut (Plyr)
                            Then
                              SendMsg (Plyr ^.Trm, '# flashes:',
                                       MsgStart, MsgEnd, NoID)
                            Else
                              QOut (Term,
                                    '0Player timed out - Message not sent.');
                            If CmdCode = 82
                            Then
                              Begin
                                LogTerm := Plyr ^.Trm;
                                If Plyr = User
                                Then
                                  User := NIL;
                                Logoff (Plyr);
                                QOut (LogTerm, '2');
                                Plyr := NIL
                              End (*If*)
                          End (*If*)
                        Else
                          Begin
                            Ps (Word, B1);
                            B1 := '0' + B1 + ' cannot be found.';
                            QOut (Term, B1)
                          End (*Else*)
                      End (*If*)
                End (*Case*)
              Else
                Case CmdCode Of
                  36, 12 (* Say *):
                    Begin
                      NumHearing := MsgTerm (TermList, Local);
                      If NumHearing > 0
                      Then
                        Begin
                          If User ^.Echo
                          Then
                            Begin
                              NumHearing := NumHearing + 1;
                              TermList [NumHearing] := User ^.Trm
                            End (*If*);
                          For ILoop := 1 To NumHearing Do
                            SendMsg (TermList [ILoop], ' says,',
                                     MsgStart, MsgEnd, NoID)
                        End (*If*)
                      Else
                        QOut (Term, '0Nobody is here to hear you.')
                    End (*36,12*);
                  37, 13 (* Yell *):
                    Begin
                      NumHearing := MsgTerm (TermList, Yell);
                      If NumHearing > 0
                      Then
                        Begin
                          If User ^.Echo
                          Then
                            Begin
                              NumHearing := NumHearing + 1;
                              TermList [NumHearing] := User ^.Trm
                            End (*If*);
                          For ILoop := 1 To NumHearing Do
                            SendMsg (TermList [ILoop], ' yells,',
                                     MsgStart, MsgEnd, NoID);
                        End (*If*)
                      Else
                        QOut (Term, '0No one hears you.')
                    End (*37,13*);
                  38, 14 (* Send *):
                    If (User ^.SendDay >= Max (5, User ^.Lvl)) And Not NoID
                    Then
                      QOut (Term,
                  '0You have no telepathic powers left for broadcasting today!')
                    Else
                      If SpellCost (User, 2, -5, 7)
                      Then
                        Begin
                          If NoID
                          Then
                            TalkHow := Others
                          Else
                            Begin
                              TalkHow := NoBlock;
                              User ^.SendDay := User ^.SendDay + 0
                            End (*Else*);
                          For ILoop := 1 To MsgTerm (TermList, TalkHow) Do
                            SendMsg (TermList [ILoop], ': ', MsgStart,
                                     MsgEnd, NoID)
                        End (*If*)
                End (*Case*)
          End (*Else*);
        Loc := LenBuf + 1
      End (*Talk*);
  
    Procedure DoCmd (Var Buffer: BufType; Var Loc, LenBuf: LenBufType;
                       Var Room: RoomList; Var CmdList: CmdListType);
      
      Var
        Ch: Char;
        Cmd, Word: Alfa;
      
      Begin
        If User ^.Entry = XDead
        Then
          EnterWhyDie
        Else
          If (User ^.Hits > 0) And Not User ^.Dead
          Then
            Begin
              If RealTime > LastUpdate + UpDatePeriod
              Then
                If (NUsers > 0) And (User ^.Status <> SLogin)
                Then
                  Begin
                    UpdateF (*Update all the data files*);
                    LastUpdate := RealTime
                  End (*If*);
              With User ^ Do
                If Entry = XSpell
                Then
                  Spell (0)
                Else
                  If Entry = XSure
                  Then
                    Quit (Data)
                  Else
                    Begin
                      If RealTime >= LastHeal + HealWait
                      Then
                        If Poisoned
                        Then
                          Begin
                            LastHeal := RealTime;
                            QOut (Term,
                          '0You feel the poison coursing through your veins!');
                            Hits := Max (0, Hits - Rnd (2) * Lvl);
                            If (Hits = 0) or Dead
                            Then
                              Begin
                                Ps (Name, B1);
                                B1 := '0### ' + B1;
                                Writev (B2, ', the ', CName [Class],
                                        ' finally died from ', Pro [Sex],
                                        ' poisonous wounds.');
                                B1 := B1 + B2;
                                For ILoop := 1 to MsgTerm (TermList, All) Do
                                  QOut (TermList [ILoop], B1)
                              End (*If*)
                          End (*If*)
                        Else
                          Begin
                            LastHeal := RealTime;
                            If RealTime - HitAtTime >= 90
                            Then
                              Fatigue := MaxFatigue
                            Else
                              Fatigue := Min (MaxFatigue, Fatigue + Lvl);
                            Magic := Min (MaxMagic, Magic + Min (Lvl, 5));
                            Hits := Min (MaxHits, Hits + Lvl Div 2 + 1)
                          End (*Else*);
                      GetWord (Cmd, Num, Buffer, LenBuf, Loc);
                      CapAlfa (Cmd);
                      If Cmd <> Blanks
                      Then
                        CmdCode := BinaryMatch (Cmd, CmdListLen, CmdList)
                      Else
                        CmdCode := -1 (* Empty C/R *);
                      If (Cmd [1] = '*') And Not SSJ Then
                        CmdCode := -2 (* Illegal access *);
                      If CmdCode > 0
                      Then
                        Begin
                          User ^.LastCmd := CmdList [CmdCode];
                          CmdCode := CmdNum [CmdCode];
                          If Not (CmdCode in [1..7, 16..20, 22, 25..28,
                                  30, 34, 39, 40, 41, 45, 47, 48, 51,
                                  52, 61, 71, 74 .. 76, 78, 79, 83, 87])
                          Then
                            GetWord (Word, Num, Buffer, LenBuf, Loc)
                        End (*If*)
                      Else
                        User ^.LastCmd := Blanks;
                      If User ^.Assoc And (CmdCode in [18, 19, 51, 27, 54])
                      Then
                        CmdCode := -3;
                      Case CmdCode of
                        -3:
                         QOut (Term, '0Sorry, associate DMs may not do that.');
                        -2:
                          QOut (Term, '0Sorry..  That''s for DM use only!');
                        -1: (* Not unique.  BinaryMatch sent error message *);
                        0:
                          QOut (Term, '0I don''t understand.');
                        1, 2, 3, 4, 5, 6, 7, 9:
                          Begin
                            FolCount := 0;
                            GoDirection (Word, Num, CmdCode)
                          End (*1*);
                        8:
                          DropObject (Word, Num, RmCode);
                        10:
                          Begin
                            Num := UseObject (Word, Num);
                            If Num <> 0 Then
                              Spell (Num)
                          End (*10*);
                        11, 42, 43, 72, 85, 86:
                          Attack (CmdCode, Word, User ^.RmCode);
                        12, 13, 14, 36, 37, 38, 82:
                          If (CmdCode = 82) And Not User ^.Master
                          Then
                            QOut (Term, '0Only master DMs can logoff players.')
                          Else
                            Talk (CmdCode, Word);
                        16:
                          Entry := XEdit;
                        17, 39:
                          Begin
                            Data := CmdCode;
                            Entry := XSure
                          End (*17*);
                        18, 19, 20, 26, 27, 28, 30, 34, 51, 83:
                          MinorCmds (User, CmdCode);
                        21:
                          Begin
                            UpdateF;
                            Abort ('0 Mil000 - DM took task down.')
                          End (*21*);
                        22:
                          PlayerDisplay (User);
                        23:
                          Begin
                            UpdateF;
                            LastUpdate := RealTime;
                            QOut (Term, '0Files updated.')
                          End (*23*);
                        24, 31, 64:
                          If Word = Blanks
                          Then
                            RoomDisplay (RmCode, False)
                          Else
                            Begin
                              Num := Look (Word, Num, CmdCode);
                              If Num <> 0 Then
                                Spell (Num)
                            End (*Else*);
                        25:
                          Brief := Not Brief;
                        29:
                          ReturnObj (Word, Num);
                        32:
                          QOut (Term, '0When in doubt, panic!');
                        33:
                          GetStatus (Word, User);
                        35:
                          Users (Word);
                        40:
                          SaveChar;
                        41:
                          Inventory;
                        44:
                          EnterSpell (Word, Num);
                        45:
                          Appeal;
                        46:
                          Buy (Word, Num, RmCode);
                        47:
                          Begin
                            Entry := XNotice;
                            Loc := Loc + 1
                          End (*47*);
                        48:
                          Catalog;
                        49:
                          Pawn (Word, Num);
                        50:
                          If (Num < 1) or (Num > 3)
                          Then
                            QOut (Term, '0Must be 1 to 3.')
                          Else
                            Begin
                              TLvl [Num] := 0;
                              QOut (Term, '0Death entry purged.')
                            End (*Else*);
                        52:
                          Begin
                            Entry := XNews;
                            Loc := Loc + 1
                          End (*52*);
                        53:
                          If (Num < 1) or (Num > 5)
                          Then
                            QOut (Term, '0Must be 1 to 5.')
                          Else
                            Begin
                              NewsBuf [Num] := '';
                              QOut (Term, '0News line deleted.')
                            End (*Else*);
                        54:
                          Begin
                            MSpeed := Max (1, Min (10, Num));
                            Writev (B1, '0Monspeed set to ', MSpeed: 0, '.');
                            QOut (Term, B1)
                          End (*54*);
                        55:
                          FollowPlyr (Word);
                        56:
                          Lose (Word);
                        57, 58, 59, 60:
                          MiscCmds (CmdCode, Word, Num);
                        61:
                          Accept;
                        62:
                          Turn (Word, Num);
                        63:
                          GetObject (Word, Num, RmCode);
                        65, 66, 67, 68, 69, 70:
                          OpenClose (CmdCode, Word, Num);
                        71:
                          Track;
                        73:
                          Hide (Word, Num);
                        74:
                          Search;
                        75:
                          Train;
                        76:
                          Begin
                            MesBlock := Not MesBlock;
                            If MesBlock
                            Then
                              QOut (Term, '0Send messages blocked.')
                            Else
                              QOut (Term, '0Send messages received.')
                          End (*76*);
                        78:
                          Run;
                        79:
                          PrintExp (User);
                        80:
                          QOut (Term, '0Dayfile not implemented yet.');
                        81:
                          Parley (Word, Num);
                        84:
                          QOut (Term, '0Stealing not implemented yet.');
                        87:
                          (* Auto := True *)
                          QOut (Term, '0*AUTO not implemented yet.');
                        88:
                          Condition (User)
                      End (*Case*)
                    End (*Else*);
              If User <> NIL Then
                If (User ^.Hits = 0) or User ^.Dead
                Then
                  WhyDie
                Else
                  If Not User ^.Auto
                  Then
                    PromptUser (User)
            End (*If*)
          Else
            WhyDie
      End (*DoCmd*);
