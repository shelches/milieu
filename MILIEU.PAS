Program Milieu (Input, Output);

  Label
    990;

  %Include 'Miljmr'
  %Include 'Milio'
  %Include 'Milobj'
  %Include 'Milmon'
  %Include 'Miluser'
  %Include 'Mildb'
  %Include 'Milroom'
  %Include 'Miledit'
  %Include 'Milcmd'
  %Include 'Millog'
  %Include 'Milmatt'

  [ASYNCHRONOUS] Function Handler (Var SA: Integer; Var MA: Integer): Integer;

    Const
      SS$_Resignal = 2328;

    Begin
      Writeln ('Error..');
      Off;
      UpdateF;
      Handler := SS$_Resignal
    End (*Handler*);

  Procedure TimeOut (User: UserPoint);

    Begin
      QOut (User ^.Trm, '4');
      LogOff (User)
    End (*TimeOut*);

  Procedure DoEntry;

    Begin
      If User ^.Entry in [XCmd, XDead, XSpell, XSure, XEdit, XNotice,
                          XNews, XParley, XRepair, XSell, XName, XPassWord,
                          XNewPW, XNewClass, XSex, XStats, XSkill, XDesc]
      Then
        Case User ^.Entry of
          XCmd, XDead, XSpell, XSure:
            DoCmd (Buffer, Loc, LenBuf, Room, CmdList);
          XEdit:
            Edit (Buffer, LenBuf);
          XNotice, XNews:
            EnterData;
          XParley, XRepair, XSell:
            YesNo;
          XName:
            GetNam (User);
          XPassWord:
            MatchPW (User);
          XNewPW:
            NewPW (User);
          XNewClass:
            ChooseClass (User);
          XSex:
            EnterSex (User);
          XStats:
            EnterStats (User);
          XSkill:
            EnterSkill (User);
          XDesc:
            EnterDesc
        End (*Case*)
      Else
        Begin
          Writev (B1, '0 Mil107 - Undefined entry type;  ord = ',
                  Ord (User ^.Entry));
          QOut (Term, B1);
          User ^.Entry := XCmd;
          PromptUser (User)
        End (*Else*)
    End (*DoEntry*);

  Procedure Init_Milieu;

    Var
      ILoop, LastDay: Integer;
      DateStr: Packed Array [1 .. 11] Of Char;

    Begin
      Open (EFile, File_Name := 'EFile', History := Unknown);
      Reset (EFile);
      ReadLn (EFile, Notice);
      For ILoop := 1 To 5 Do
        ReadLn (EFile, NewsBuf [ILoop]);
      For ILoop := 1 To 3 Do
        ReadLn (EFile, TLvl [ILoop], TName [ILoop], TClass [ILoop]);
      ReadLn (EFile, TaskClosed, NumRun, LastDay, MSpeed);
      For ILoop := 1 To LEncounter Do
        ReadLn (EFile, EncIndex [ILoop, 1], EncIndex [ILoop, 2],
                EncIndex [ILoop, 3], EncIndex [ILoop, 4],
                EncIndex [ILoop, 5], EncIndex [ILoop, 6]);
      For ILoop := 1 To ObjListLen Do
        ReadLn (EFile, ObjIndex [ILoop, 1], ObjIndex [ILoop, 2],
                ObjIndex [ILoop, 3], ObjIndex [ILoop, 4],
                ObjIndex [ILoop, 5], ObjIndex [ILoop, 6]);
      Reset (EFile);
      Date (DateStr);
      If DateStr [1] = ' '
      Then
        DateStr [1] := '0';
      Today := (Ord (DateStr [1]) - Ord ('0')) * 10;
      Today := Today + Ord (DateStr [2]) - Ord ('0');
      NumRooms := Clock MOD 32768;
      NumSegs := Clock MOD 32768;
      SetRandom (NumRooms, NumSegs);
      NumSegs := 200;
      NumRooms := NumSegs * 10 - 1;
      UserTail := NIL;
      NUsers := 0;
      LenBuf := 0;
      Loc := 1;
      LastUpdate := RealTime;
      LenBuf := 0;
      TradeTime := RealTime - 60;
      NTPlyr := Blanks;
      NFPlyr := Blanks;
      For ILoop := 0 to MaxUsers Do
        Begin
          Active [ILoop] := 0;
          SlotTBL [ILoop] := -1
        End
    End (*Init_Milieu*);

  Begin
    Establish (Handler);

(* Mildb1.Pas *)

      OpenDataBase;

(* Milio1.Pas *)

      Aborted := False;
      InitCmds;
      Open (EDesc, File_Name := 'DSCRPT', History := Unknown,
            Access_Method := Direct);
      Reset (EDesc);
      CurrentRec := 0;

(* Milmatt1.Pas *)

      InitEvents;

(* Milmon1.Pas *)

      Open (MList, File_Name := 'MList', History := Unknown,
            Access_Method := Direct);
      Reset (MList);
      With ProtoMonster Do
        Begin
          Name := 'something ';
          Next := NIL;
          DefPlayer := NIL;
          Lvl := 0;
          Hits := 10;
          MaxHits := 10;
          ObjectTail := NIL;
          Experience := 100;
          Top := True;
          Num := 1;
          Permanent := True;
          Magic := False;
          Defend := True;
          AtkLastAggr := True;
          WhichObj := 0;
          MReact := 0;
          MParley := 0
        End (*With*);

(* Milobj1.Pas *)

      Open (OList, File_Name := 'OList', History := Unknown,
            Access_Method := Direct);
      Reset (OList);
      InitSpells;
      With ProtoObject Do
        Begin
          Name := 'thing,*';
          Next := NIL;
          Article := A;
          Carry := True;
          Weight := 1;
          Price := 0;
          Magic := False;
          Permanent := False;
          Invisible := False;
          Reserved := 0;
          DescCode := 0;
          DescRec := 0;
          ObClass := Misc
        End (*With*);

(* Milroom1.Pas *)

      OpenCave;
      InitRoom;

(* Miluser1.Pas *)

      Init;

    Init_Milieu;
    QCre;
    Repeat
      QRea (C1, Pid);
      MonAttack;
      Case C1[1] Of
        '0':
          Begin
            B2 := '';
            For ILoop := 1 to (Length (C1) - 1) Do
              B2 := B2 + C1 [ILoop + 1];
            QAss (B2, Term);
            User := Login (NUsers, UserTail);
            User ^.LastInput := RealTime;
            Loc := LenBuf + 1;
            If User <> NIL
            Then
              PromptUser (User)
          End;
        '1':
          Begin
            User := FindPid (Pid, UserTail);
            If User <> NIL
            Then
              Begin
                User ^.LastInput := RealTime;
                Term := User ^.Trm;
                DoInput (Buffer, LenBuf);
                DoEntry (User)
              End (*If*)
          End
      End (*Case*);
      User := UserTail;
      While User <> NIL Do
        Begin
          If NoTimeOut (User)
          Then
            User := User ^.Next
          Else
            Begin
              TimeOut (User);
              User := UserTail
            End (*Else*)
        End (*While*)
    Until Aborted Or (NUsers = 0);

  990:
    UpdateF;
    Off;

(* Mildb2.Pas *)

      CloseDataBase;

(* Milio2.Pas *)

      CurrentRec := 0;
      Close (EDesc);

(* Milmon2.Pas *)

      Close (MList);

(* Milobj2.Pas *)

      Close (OList);

(* Milroom2.Pas *)

      CloseCave;

(* Miluser2.Pas *)

      ClosePer;

  End (*Milieu*).
