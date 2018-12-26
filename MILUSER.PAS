
    Const
      RespondLimit = 120 (* Number of seconds a player has to respond *);
      AbsolutePlMax = 50;
      NumSpells = 17;
      MaxObjs   = 8;
      Empty     = '          ';
      
    Var
      User: UserPoint;
      UserTail: UserPoint (* Point to head of user list *);
      Pro: Packed Array [Male..Female] of Packed Array [1..3] of Char;
      Protouser : UserType;
      CName: Array [ChType] of Varying [10] of Char;
    
    Type
      UserFRec  = Packed Record
                    User : UserType;
                    NObj : WInt;
                    Objs : Packed Array [1 .. MaxObjs] of ObjectType
                  End (* UserFRec *);
                  
    Var
      EPerson   : File of UserFRec;
                  
    Procedure OpenPer;

      Var
        Error: Integer;

      Begin
        Open (EPerson, File_Name := 'EPERSON', History := Old,
              Access_Method := Keyed, Error := Continue);
        Error := Status (EPerson);
        If Error <> 0
        Then
          Abort ('0 Mil203 - Error opening person file.')
      End (*OpenPer*);

    Procedure ClosePer;
    
      Var
        Error: Integer;
        
      Begin
        Close (EPerson, Error := Continue);
        Error := Status (EPerson);
        If Error <> 0
        Then
          Abort ('0 Mil204 - Error closing person file.')
      End (*ClosePer*);

    Procedure DoEntry (User: UserPoint); Forward;

    Function SearchPlIndex (Name: Alfa): Integer;
    
      Var
        Error: Integer;
        TempName: Alfa;
      
      Begin
        SearchPlIndex := 0;
        TempName := Name;
        CapAlfa (TempName);
        Findk (EPerson, 0, TempName, eql, Error := Continue);
        Error := Status (EPerson);
        If (Error = 0) And (Not Ufb (EPerson))
        Then
          SearchPlIndex := 1
      End (*SearchPlIndex*);
        
    Procedure ReadPlayer (Var Player: UserPoint; Var Name: Alfa);
    
      Var
        EBuffer: UserFRec;
        Error: Integer;
        Pt: ObjectPoint;
        ILoop: Integer;
        TempName: Alfa;

      Begin
        New (Player);
        Player ^ := ProtoUser;
        TempName := Name;
        CapAlfa (TempName);
        Findk (EPerson, 0, TempName, eql, Error := Continue);
        Error := Status (EPerson);
        If (Error = 0) And (Not Ufb (EPerson))
        Then
          Begin
            EBuffer := EPerson ^;
            Player ^ := EBuffer.User;
            Player ^.Name := Name;
            With Player ^ Do
              Begin
                AC := 10;
                Next := NIL;
                USWeap := NIL;
                USShield := NIL;
                USArm := NIL;
                DefPlayer := NIL;
                DefMon := NIL;
                ObjectTail := NIL;
                LastInput := RealTime;
                LastAtk := RealTime - 50;
                LastHeal := RealTime - 50;
                HitAtTime := RealTime - 50;
                Drunk := RealTime;
                Entry := XName
              End (*With*);
            If EBuffer.NObj > 0
            Then
              For ILoop := 1 to Min (MaxObjs, EBuffer.NObj) Do
                Begin
                  New (Pt);
                  Pt ^ := EBuffer.Objs [ILoop];
                  Pt ^.Next := Player ^.ObjectTail;
                  Player ^.ObjectTail := Pt
                End (*If*)
          End (*If*)
        Else
          Player ^.Name := Empty
      End (*ReadPlayer*);
    
    Procedure WritePlayer (Var Player: UserPoint; Save: Boolean);
    
    (* If save is true, nothing is disposed.. *)
    
      Var
        Pt: ObjectPoint;
        I: Integer;
        Error: Integer;
        EBuffer: UserFRec;
        TempName: Alfa;
        
      Begin
        If Not Save
        Then
          With Player ^ Do
            Begin
              If ObjectTail <> NIL
              Then
                While ObjectTail <> NIL Do
                  Begin
                    Pt := ObjectTail;
                    ObjectTail := ObjectTail ^.Next;
                    ODestroy (Pt)
                  End (*While*);
              Dispose (Player)
            End (*With*)
        Else
          With EBuffer Do
            Begin
              User := Player ^;
              TempName := User.Name;
              CapAlfa (TempName);
              User.Name := TempName;
              Pt := Player ^.ObjectTail;
              I := 1;
              While (Pt <> NIL) And (I <= MaxObjs) Do
                Begin
                  Objs [I] := Pt ^;
                  Pt := Pt ^.Next;
                  I := I + 1
                End (*While*);
              NObj := I - 1;
              TempName := User.Name;
              CapAlfa (TempName);
              User.Name := TempName;
              Findk (EPerson, 0, TempName, eql, Error := Continue);
              Error := Status (EPerson);
              If (Error = 0) And (Not Ufb(EPerson))
              Then
                Begin
                  EPerson^ := EBuffer;
                  Update (EPerson, Error := Continue);
                  Error := Status (EPerson)
                End (*Then*)
              Else
                Begin
                  EPerson^ := EBuffer;
                  Put (EPerson, Error := Continue);
                  Error := Status (EPerson)
                End (*Else*);
              If Error = 0
              Then
                Begin
                  ClosePer;
                  OpenPer
                End (*If*);
              If Error > 0
              Then
                Abort ('0 Mil206 - Error updating person.')
            End (*With*)
      End (*WritePlayer*);
    
    Procedure DeleteUsr (Nm: Alfa);
    
      Var
        Error: Integer;
        TempName: Alfa;
      
      Begin
        TempName := Nm;
        CapAlfa (TempName);
        Findk (EPerson, 0, TempName, eql, Error := Continue);
        Error := Status (EPerson);
        If (Error = 0) And (Not Ufb (EPerson))
        Then
          Begin
            Delete (EPerson, Error := Continue);
            Error := Status (EPerson)
          End;
        If Error = 0
        Then
          Begin
            Reset (EPerson, Error := Continue);
            Error := Status (EPerson)
          End (*If*);
        If Error > 0
        Then
          Abort ('0 Mil208 - Error while deleting player.')
      End (*DeleteUsr*);
      
    Procedure Users (Word: Alfa);

      Procedure DisUser;
        Begin (*DisUser*)
          Writev (B1, '0', EPerson ^.User.Name);
          If User ^.SSJ
          Then
            Begin
              Writev (B2, EPerson ^.User.Lvl: 4,
                      EPerson ^.User.LastAccess: 4);
              If EPerson ^.User.SSJ
              Then
                B1 := B1 + ' * ' + B2
              Else
                B1 := B1 + '   ' + B2
            End (*If*);
          QOut (Term, B1)
        End (*DisUser*);

      Begin (*Users*)
        ResetK (EPerson, 0);
        While Not Eof (EPerson) Do
          Begin
            DisUser;
            Get (EPerson)
          End (*While*)
      End (*Users*);

    Function FindPlayer (Word: Alfa; PlayerTail: UserPoint): UserPoint;

      Var
        Player: UserPoint;
        Count, Index: Integer;
        NameList: NameTList;

      Begin
        CapAlfa (Word);
        Count := 0;
        Player := PlayerTail;
        While (Player <> NIL) And (Count < MaxNames) Do
          Begin
            Count := Count + 1;
            NameList[Count] := Player ^.Name;
            CapAlfa (NameList[Count]);
            Player := Player ^.Next
          End (*While*);
        If Count >= MaxNames Then
          QOut (Term, '0 Mil31 - Player table overflow!');
        Index := WordMatch (Word, Count, NameList);
        If Index <= 0
        Then
          Player := Nil
        Else
          Begin
            Player := PlayerTail;
            For Count := 1 to Index - 1 Do
              Player := Player ^.Next
          End (*Else*);
        FindPlayer := Player
      End (*FindPlayer*);

    Function FindUser (Word: Alfa; UserTail: UserPoint): UserPoint;

      Var
        Usr: UserPoint;
        Count, Index: Integer;
        NameList: NameTList;

      Begin
        CapAlfa (Word);
        Count := 0;
        Usr := UserTail;
        While (Usr <> NIL) And (Count < MaxNames) Do
          Begin
            Count := Count + 1;
            NameList [Count] := Usr ^.Name;
            CapAlfa (NameList[Count]);
            Usr := Usr ^.NextUser
          End (*While*);
        If Count >= MaxNames Then
          QOut (Term, '0 Mil31 - User table overflow!');
        Index := WordMatch (Word, Count, NameList);
        If Index <= 0
        Then
          Usr := NIL
        Else
          Begin
            Usr := UserTail;
            For Count := 1 to Index - 1 Do
              Usr := Usr ^.NextUser
          End (*Else*);
        FindUser := Usr
      End (*FindUser*);
    
    Function FindTerm (Term: WInt; UserTail: UserPoint): UserPoint;

      Var
        Usr: UserPoint;
        Found: Boolean;

      Begin
        Usr := UserTail;
        Found := False;
        While (Usr <> NIL) And Not Found Do
          If Usr ^.Trm = Term
          Then
            Found := True
          Else
            Usr := Usr ^.NextUser;
        If Not Found Then
          Abort ('0 Mil101 - Term not found!');
        FindTerm := Usr
      End (*FindTerm*);
    
    Function FindPid (Pid: Integer; UserTail: UserPoint): UserPoint;

      Var
        Usr: UserPoint;
        Found: Boolean;

      Begin
        Usr := UserTail;
        Found := False;
        While (Usr <> NIL) And Not Found Do
          If Usr ^.XPid = Pid
          Then
            Found := True
          Else
            Usr := Usr ^.NextUser;
        If Not Found
        Then
          FindPid := NIL
        Else
          FindPid := Usr
      End (*FindPid*);
    
    Function Hash (Var Word: Alfa; Len: Integer): Integer;
    
      Var
        Total, ILoop: Integer;
      
      Begin
        CapAlfa (Word);
        Total := 0;
        For ILoop := 1 to Len Do
          Total := Total + Ord (Word[ILoop]) * ILoop;
        Hash := Total;
      End (*Hash*);
    
    Function Expr (Lvl: Integer): Integer;
    
      Var
        Num: Integer;
      
      Begin
        If Lvl <= 1
        Then
          Num := 0
        Else
          If Lvl > 24
          Then
            Num := MaxInt
          Else
            Begin
              Num := 64;
              While Lvl > 0 Do
                Begin
                  Num := Num * 2;
                  Lvl := Lvl - 1
                End (*While *)
            End (*Else*);
        Expr := Num
      End (*Expr*);
      
    Procedure PrintExp (Plyr: UserPoint);
    
      Begin
        With Plyr ^ Do
          Begin
            Writev (B1, '0You need ', 
                    Max (0, Expr (Lvl + 1) - Expr (Lvl) - Experience): 0,
                    ' more exp points to train for the next level.');
            QOut (Term, B1);
            Writev (B1, '0You have ', Money: 0, ' shillings in cash.');
            QOut (Term, B1)
          End (*With*)
      End (*PrintExp*);
    
    Procedure Inventory;
    
      Var
        ILoop, Count: Integer;
        Object: ObjectPoint;
      
      Begin
        B1 := '0You are carrying ';
        Count := 0;
        Object := User ^.ObjectTail;
        While Object <> NIL Do
          Begin
            Count := Count + 1;
            Object := Object ^.Next
          End (*While*);
        If Count > 0
        Then
          Begin
            B1 := B1 + 'the following objects:';
            QOut (Term, B1);
            B1 := '0';
            Object := User ^.ObjectTail;
            ILoop := 0;
            While (ILoop < Count) And (Object <> NIL) Do
              Begin
                ILoop := ILoop + 1;
                PrintObj (Object ^, False, (ILoop = 1), B2);
                B1 := B1 + B2;
                Punctuate (ILoop, Count, B1);
                Object := Object ^.Next
              End (*While*);
            B1 := B1 + '.';
            QOut (Term, B1);
            QOut (Term, '0')
          End (*If*)
        Else
          Begin
            B1 := B1 + 'nothing at all.';
            QOut (Term, B1)
          End (*Else*)
      End (*Inventory*);
      
    Procedure PrintDmg (Player: UserPoint; Damage: Integer; Brf: Boolean;
                        Var Str: Var256);
    
      Var
        Str1: Var256;

      Begin
        With Player ^ Do
          If Brf
          Then
            Begin
              If Fatigue = 0
              Then
                Writev (Str1, Damage: 0, ' vit!')
              Else
                If Damage > Fatigue
                Then
                  Writev (Str1, Fatigue: 0, ' fat, and ', Damage - Fatigue: 0,
                          ' vit!')
                Else
                  Writev (Str1, Damage: 0, ' fat!')
            End (*If*)
          Else
            Begin
              If Fatigue = 0
              Then
                Writev (Str1, Damage: 0, ' vitality points!')
              Else
                If Damage > Fatigue
                Then
                  Writev (Str1, Fatigue: 0, ' fatigue points, and ',
                          Damage - Fatigue: 0, ' vitality pts!')
                Else
                  Writev (Str1, Damage: 0, ' fatigue points!')
            End (*Else*);
        Str := Str1
      End (*PrintDmg*);
            
    Function ReadyCheck (LastAtk: Integer): Boolean;
    
      Begin
        ReadyCheck := False;
        If RealTime + 1 < LastAtk
        Then
          Begin
            Writev (B1, '0Not ready! Wait ',
                    LastAtk - RealTime: 1, ' more seconds.');
            QOut (Term, B1)
          End (*If*)
        Else
          If User ^.Drunk - RealTime >= 60
          Then
            QOut (Term, '0You''re too smashed to do anything!')
          Else
            ReadyCheck := True
      End (*ReadyCheck*);
    
    Function NoTimeOut (Usr: UserPoint): Boolean;
    
      Begin
        If Usr = NIL Then
          Abort ('0 Mil220 - NIL user pointer!');
        If (RealTime - Usr ^.LastInput <= RespondLimit)
        Then
          NoTimeOut := True
        Else
          NoTimeOut := Usr ^.Auto
      End (*NoTimeOut*);
    
    Procedure WritePwMask;
    
      Var
        Bs: Alfa;
        II: Integer;
        
      Begin
        For II := 1 to 10 Do
          Bs [II] := Chr (8);
        B1 := '0' + 'QQQQQQQQQQ' + Bs + 'MMMMMMMMMM' + Bs + '##########' + Bs;
        QOut (Term, B1)
      End (*WritePwMask*);
      
    Procedure PromptUser (User: UserPoint);
    
      Begin
        If (Loc <= LenBuf)
        Then
          DoEntry (User)
        Else
          Begin
            User ^.EncountStop := False;
            Case User ^.Entry of
              XName:
                QOut (Term, '1Enter your name? ');
              XNewClass:
                QOut (Term, '1Class? ');
              XStats:
                QOut (Term, '1Stats? ');
              XSkill:
                QOut (Term, '1Skill? ');
              XSex:
                QOut (Term, '1Finally, is your character a male or female? ');
              XCmd:
                If User ^.Brief
                Then
                  QOut (Term, '1Do? ')
                Else
                  QOut (Term, '1Action? ');
              XPassWord:
                QOut (Term, '1Enter your password? ');
              XNewPw:
                QOut (Term, '1Enter access password? ');
              XChangePW:
                QOut (Term, '1Enter new password? ');
              XEdit:
                If User ^.Brief
                Then
                  QOut (Term, '1Ed? ')
                Else
                  QOut (Term, '1Edit command? ');
              XNotice:
                QOut (Term, '1Enter notice? ');
              XDead:
                Begin
         QOut (Term, '0Congratulations!  Your death has made the newspapers!');
         QOut (Term, '0In one line, try to explain what killed you and how.');
         QOut (Term, '0Use words like "he" and "she" instead of "I".');
         QOut (Term, '0Example: "His weapon broke and before he knew it, the');
         QOut (Term, '0vampire drained his life away.."');
                  QOut (Term, '1? ')
                End (*XDead*);
              XSpell:
                QOut (Term, '1Say chant? ');
              XNews:
                QOut (Term, '1Enter news? ');
              XSell, XRepair:
                QOut (Term, '1Yes/No? ');
              XWish:
                QOut (Term, '1Enter wish? ');
              XSure:
                QOut (Term, '1Are you sure? ');
              XParley:
                QOut (Term, '1Would you like to have it, Effendi? ');
              XDesc:
                QOut (Term, '1Enter description? ')
            End (*Case*)
          End (*Else*)
      End (*PromptUser*);
    
    Procedure Init;
    
      Var
        Pass : Alfa;
        
      Begin
        OpenPer;
        Pass := 'DUMMY     ';
        With ProtoUser Do
          Begin
            Name := Empty;
            SSJ := False;
            Weight := 0;
            ObjectTail := NIL;
            Lvl := 1;
            Class := Fighter;
            Hits := 10;
            MaxHits := 10;
            Magic := 10;
            MaxMagic := 10;
            Experience := 0;
            AGuild := False;
            AC := 10;
            RmCode := 1;
            Str := 11;
            Int := 11;
            Dex := 11;
            Pty := 11;
            Con := 11;
            Evil := False;
            SpellDay := 0;
            LastAccess := 1;
            Pw := Hash (Pass, 10);
            Money := 200;
            Invisible := False;
            Fatigue := 10;
            Nonexistant := False;
            SkillNew := False;
            Sex := Male;
            Dead := False;
            MaxFatigue := 10;
            Poisoned := False;
            Playtester := False;
            PlyrTemp := False;
            Echo := False;
            SSharp := 0;
            SThrust := 0;
            SBlunt := 0;
            SLong := 0;
            Converted := 457;
            Hidden := False;
            Assoc := False;
            Master := False;
            TGuild := False;
            FileNum := 0;
            Reserved := 0;
            LastInput := 0;
            Next := NIL;
            UsWeap := NIL;
            UsArm := NIL;
            UsShield := NIL;
            DefPlayer := NIL;
            DefMon := NIL;
            Entry := XInit;
            Follow := NIL;
            NextUser := NIL;
            LastAtk := 0;
            LastHeal := 0;
            HitAtTime := 0;
            EncountStop := False;
            Drunk := 0;
            Auto := False;
            Brief := False;
            MesBlock := False;
            LastCmd := Blanks;
            WData := Blanks;
            Data := 0
          End (*With*);
        Pro [Male] := 'him';
        Pro [Female] := 'her';
        CName[Fighter] := 'Fighter';
        CName[Thief] := 'Thief';
        CName[MagicUser] := 'Magic-User';
        CName[DM] := 'Caretaker';
        CName[Cleric] := 'Cleric';
        CName[Paladin] := 'Paladin';
        CName[Ranger] := 'Ranger';
        CName[Barbarian] := 'Barbarian'
      End (*Init*);
