
    Procedure AnnounceLogin (User: UserPoint);
    
      Var
        I, ILoop: Integer;
      
      Begin
        User ^.Status := SNormal;
        With User ^ Do
          If LastAccess <> Today
          Then
            Begin
               LastAccess := Today;
               SpellDay := 0;
               SendDay := 0;
               If TGuild Or AGuild
               Then
                 Begin
                   Money := Max (0, Money - Lvl * 20);
                   If Money = 0
                   Then
                     Begin
                       QOut (Term,
                             '0You have not the funds to pay your dues!');
                       QOut (Term, '0You have been expelled from the guild.');
                       AGuild := False;
                       TGuild := False
                     End (*If*)
                   Else
                     Begin
                       Writev (B1, '0Daily ', Lvl * 20: 0, ' guild fee paid ',
                               'in full.  Thank you!');
                       QOut (Term, B1)
                     End (*Else*)
                 End (*If*)
            End (*If*);
        If Length (Notice) > 0
        Then
          Begin
            QOut (Term, '0Notice:');
            Writev (B1, '0', Notice);
            QOut (Term, B1);
            QOut (Term, '0')
          End (*If*);
        CmdCode := 0;
        Ps (User^.Name, B1);
        B1 := '0### Please welcome ' + B1;
        Writev (B2, ', the ', CName [User^.Class], '.');
        B1 := B1 + B2;
        For ILoop := 1 to MsgTerm (TermList, BrAll) Do
          QOut (TermList [ILoop], B1);
        If Not User ^.SSJ And (User ^.Invisible or User ^.Nonexistant)
        Then
          Begin
            User ^.Nonexistant := False;
            User ^.Invisible := False
          End (*If*);
        If User ^.Invisible
        Then
          If User ^.Nonexistant
          Then
            QOut (Term, '0You are currently nonexistant.')
          Else
            QOut (Term, '0You are currently invisible.');
        RoomDisplay (User ^.RmCode, User ^.Brief)
      End (*AnnounceLogin*);
      
    Function Login (Var NUsers: Integer;
                    Var PlayerTail: UserPoint): UserPoint;
      
      Var
        Found: Boolean;
        ValidLogin: (Good, Bad, Queued);
        NewUser: UserPoint;
        TNum, Num, I, ILoop: Integer;
        Ch, PrevCh: Char;
      
      Begin
        NUsers := NUsers + 1;
        New (NewUser);
        NewUser ^ := ProtoUser;
        ILoop := 1;
        Found := False;
        ValidLogin := Good;
        Writev (B1,
         '0Milieu Fantasy Role-Playing Game  Ver 2.4.1 (Run ', NumRun: 0, ')');
        QOut (Term, B1);
        If Length (Notice) <> 0
        Then
          Begin
            Writev (B1, '0Notice: ', Notice);
            QOut (Term, B1)
          End (*If*);
        With NewUser ^ Do
          Begin
            Entry := XName;
            Status := SLogin;
            Trm := Term;
            XPid := Pid;
            LastCmd := Blanks;
            NextUser := PlayerTail
          End (*With*);
        PlayerTail := NewUser;
        Login := NewUser
      End (*Login*);
    
    Procedure EnterSex (User: UserPoint);
    
      Var
        Ch: Char;
        Num: Integer;
        Word: Alfa;
      
      Begin
        With User ^ Do
          Begin
            GetWord (Word, Num, Buffer, LenBuf, Loc);
            Ch := Cap (Word [1]);
            Entry := XCmd;
            If Ch = 'M'
            Then
              Sex := Male
            Else
              If Ch = 'F'
              Then
                Sex := Female
              Else
                Begin
                  Entry := XSex;
                  Loc := LenBuf + 1;
                  QOut (Term, '0Try again.')
                End (*Else*);
            If Entry = XCmd Then
              Begin
                PlacePlayer (User, 1);
                Loc := LenBuf + 1;
                AnnounceLogin (User)
              End (*If*);
            PromptUser (User)
          End (*With*)
      End (*EnterSex*);
        
    Procedure NewPW (User: UserPoint);
    
      Var
        Dummy: Integer;
        PassWord: Alfa;
      
      Begin
        GetWord (PassWord, Dummy, Buffer, LenBuf, Loc);
        CapAlfa (PassWord);
        If PassWord <> Blanks Then
          Begin
            User ^.PW := Hash (PassWord, 10);
            User ^.Entry := XSex
          End (*If*);
        PromptUser (User)
      End (*NewPW*);
    
    Procedure EnterStats (User: UserPoint);
    
      Var
        ILoop, Sum, Num: Integer;
        Stat: Packed Array [1 .. 5] of Integer;
        BadNum: Boolean;
        Dummy: Alfa;
      
      Begin
        Sum := 0;
        ILoop := 1;
        BadNum := False;
        Repeat
          GetWord (Dummy, Num, Buffer, LenBuf, Loc);
          Stat [ILoop] := Num;
          Sum := Sum + Num;
          ILoop := ILoop + 1;
          BadNum := ((Num < 5) Or (Num > 18))
        Until BadNum or (ILoop > 5);
        If BadNum
        Then
          Begin
            QOut (Term, '0Error.  A number is more than 18 or less than 5.');
            User ^.Entry := XStats;
            Loc := LenBuf + 1
          End (*If*)
        Else
          If Sum / 5 > 11.0
          Then
            Begin
              Writev (B1, '0Error.  Your average is ', Sum / 5 : 2 : 1);
              QOut (Term, B1);
              User ^.Entry := XStats;
              Loc := LenBuf + 1
            End (*If*)
          Else
            With User ^ Do
              Begin
                Str := Stat [1];
                Int := Stat [2];
                Dex := Stat [3];
                Pty := Stat [4];
                Con := Stat [5];
                Entry := XSkill
              End (*With*);
        If (User ^.Entry = XSkill) And (Loc > LenBuf)
        Then
          Begin
            QOut (Term, '0Which weapon is your most skillful?');
            QOut (Term,
             '0Choose from: Sharp weapons, thrusting weapons, blunt weapons,');
            QOut (Term, '0or pole weapons.')
          End (*If*);
        PromptUser (User)
      End (*EnterStats*);
    
    Procedure EnterSkill (User: UserPoint);
    
      Var
        Num: Integer;
        Ch: Char;
        Word: Alfa;
      
      Begin
        User ^.Entry := XNewPW;
        GetWord (Word, Num, Buffer, LenBuf, Loc);
        Ch := Cap (Word [1]);
        With User ^ Do
          If Ch in ['S', 'T', 'B', 'P']
          Then
            Case Ch of
              'S':
                SSharp := 1;
              'T':
                SThrust := 1;
              'B':
                SBlunt := 1;
              'P':
                SLong := 1
            End (*Case*)
          Else
            Begin
              Entry := XSkill;
              Loc := LenBuf + 1;
              QOut (Term, '0No such skill.  Try again.')
            End (*Else*);
        PromptUser (User)
      End (*EnterSkill*);
    
    Procedure ChooseClass (User: UserPoint);
    
      Var
        Ch: Char;
        Num: Integer;
        Word: Alfa;
      
      Procedure SetStats (Cl: ChType; Vit, Fat, Mag, Mony: Integer);
      
        Begin
          With User ^ Do
            Begin
              Class := Cl;
              Hits := Vit;
              MaxHits := Vit;
              Fatigue := Fat;
              MaxFatigue := Fat;
              Magic := Mag;
              MaxMagic := Mag;
              Money := Mony
            End (*With*)
        End (*SetStats*);
      
      Begin (*ChooseClass*)
        User ^.Entry := XStats;
        GetWord (Word, Num, Buffer, LenBuf, Loc);
        Ch := Cap (Word [1]);
        With User ^ Do
          If Ch in ['F', 'T', 'M', 'C', 'R', 'P']
          Then
            Case Ch of
              'F':
                SetStats (Fighter, 8, 14, 2, 200);
              'T':
                SetStats (Thief, 7, 10, 3, 130);
              'M':
                SetStats (MagicUser, 6, 9, 6, 150);
              'C':
                SetStats (Cleric, 7, 11, 4, 80);
              'R':
                SetStats (Ranger, 7, 11, 3, 150);
              'P':
                SetStats (Paladin, 11, 8, 3, 140)
            End (*Case*)
          Else
            Begin
              Entry := XNewClass;
              Loc := LenBuf + 1;
              QOut (Term, '0No such class.  Try again.')
            End (*Else*);
        If (User ^.Entry = XStats) And (Loc > LenBuf)
        Then
          Begin
            QOut (Term,
           '0Choose your character''s attributes for strength, intelligence,');
            QOut (Term, '0   dexterity, piety and constitution.');
            QOut (Term,
            '0(Example: 15, 7, 9, 10, 9)  Each must be between 5 and 18, and');
            QOut (Term, '0the total average must be 11 or less.')
          End (*If*);
        PromptUser (User)
      End (*ChooseClass*);
    
    Procedure MatchPW (User: UserPoint);
    
      Var
        Dummy: Integer;
        PassWord: Alfa;
      
      Begin
        GetWord (PassWord, Dummy, Buffer, LenBuf, Loc);
        CapAlfa (PassWord);
        If Hash (PassWord, 10) <> User ^.PW
        Then
          Begin
            Logoff (User);
            QOut (Term, '0Wrong password, sorry.');
            QOut (Term, '2');
            QDea (Term)
          End (*If*)
        Else
          Begin
            PlacePlayer (User, User ^.RmCode);
            AnnounceLogin (User);
            User ^.Entry := XCmd;
            Loc := LenBuf + 1;
            PromptUser (User)
          End (*Else*)
      End (*MatchPW*);
    
    Procedure GetNam (User: UserPoint);
    
      Var
        TempNext, Other, DumUser: UserPoint;
        I1, I2, Dummy: Integer;
        Found: Boolean;
        Nam, Temp, CapName: Alfa;
      
      Begin
        GetWord (Nam, Dummy, Buffer, LenBuf, Loc);
        I1 := 1;
        CapName := Nam;
        CapAlfa (CapName);
        While I1 <= 10 Do
          If Not (Nam [I1] In ['A' .. 'Z', 'a' .. 'z', ' '])
          Then
            Begin
              For I2 := I1 + 1 To 10 Do
                Nam [I2 - 1] := Nam [I2];
              Nam [10] := ' '
            End (*If*)
          Else
            I1 := I1 + 1;
        If (Dummy <> 0) or (Nam = Blanks)
        Then
          Begin
            QOut (Term, '0Bad characters in name.');
            Loc := LenBuf + 1;
            PromptUser (User)
          End (*If*)
        Else
          Begin
            Other := UserTail;
            Found := False;
            While (Other <> NIL) And Not Found Do
              Begin
                Temp := Other ^.Name;
                CapAlfa (Temp);
                If Temp = CapName
                Then
                  Found := True
                Else
                  Other := Other ^.NextUser
              End (*While*);
            If Found
            Then
              Begin
                Logoff (User);
                QOut (Term, '0Name already in use!');
                QOut (Term, '2');
                QDea (Term)
              End (*If*)
            Else
              If CapName = 'STOP      '
              Then
                Begin
                  Logoff (User);
                  QOut (Term, '2');
                  QDea (Term)
                End (*If*)
              Else
                With User ^ Do
                  Begin
                    TempNext := NextUser;
                    ReadPlayer (DumUser, Nam);
                    User ^ := DumUser ^;
                    Dispose (DumUser);
                    Status := SLogin;
                    Trm := Term;
                    XPid := Pid;
                    NextUser := TempNext;
                    LastInput := RealTime;
                    If Not SSJ And ((TaskClosed = 'C') Or (TaskClosed = 'T')
                       And Not PlayTester)
                    Then
                      Begin
                        QOut (Term,
           '0As you approach the gates, a little gnome jumps out from behind');
                        QOut (Term,
              '0a rock.  He whines, "Go back!  The masters are not ready for');
                        QOut (Term,
                     '0you yet!".  The gnome then disappears into the brush.');
                        Logoff (User);
                        QOut (Term, '2');
                        QDea (Term)
                      End (*If*)
                    Else
                      If User ^.Name = Empty
                      Then
                        Begin
                          Name := Nam;
                          Entry := XNewClass;
                          If Loc > LenBuf
                          Then
                            Begin
                              QOut (Term,
                                   '0Please select your character''s class:');
                              QOut (Term,
                    '0Fighter, Thief, Cleric, Paladin, Ranger, or Magic-User.')
                            End (*If*);
                          PromptUser (User)
                        End (*If*)
                      Else
                        Begin
                          Entry := XPassword;
                          PromptUser (User)
                        End (*Else*)
                  End (*With*)
          End (*Else*)
      End (*GetNam*);
