    Const
      Lencounter= 50;
      RanMonLen = 100;
      
    Type
      StatusType= (SInit, SLogin, SNormal);
      ChType    = (Fighter, Thief, MagicUser, DM, Cleric, Paladin,
                   Ranger, Barbarian);
      TimeType  = Integer;
      UserPoint = ^ UserType;
      MonsterPoint= ^ MonsterType;
      MonsterType = Packed Record
                      Name        : Alfa;
                      Next        : MonsterPoint;
                      Defend, Block, Follow, Guard, AtkLastAggr, SlowReact,
                          FastReact, Invisible, Regenerate, Drain, Poison,
                          AntiMagic, Undead, MoralReact, Flee, Assistance,
                          MonSpells, MRes2, MRes3: Boolean;
                      DefPlayer   : UserPoint;
                      Lvl         : 0 .. 31;
                      Hits        : 0 .. 1023;
                      MaxHits     : 0 .. 1023;
                      ObjectTail  : ObjectPoint;
                      Experience  : 0 .. MaxInt;
                      Top         : Boolean;
                      Num         : 0 .. 9;
                      Permanent   : Boolean;
                      Magic       : Boolean;
                      WhichObj    : 0 .. 255;
                      MReact      : 0 .. 31;
                      MParley     : 0 .. 31
                    End (* MonsterType *);
      UserType  = Packed Record
                    Name: Alfa;
                    Trm: WInt;
                    Status: StatusType;
                    SSJ: Boolean;
                    Weight: 0..4095;
                    ObjectTail: ObjectPoint;
                    Lvl: 0..25;
                    Class: ChType;
                    Hits: 0..2500;
                    MaxHits: 0..2500;
                    Fatigue: 0..2500;
                    MaxFatigue: 0..2500;
                    Magic: 0..2500;
                    MaxMagic: 0..2500;
                    Experience: Integer;
                    AGuild: Boolean;
                    SendDay: 0..31;
                    AC: -32..31;
                    RmCode: RmCodeType;
                    Str, Int, Dex, Pty, Con: -10..25;
                    Evil: Boolean;
                    SpellDay: 0..10;
                    LastAccess: 0..31;
                    PW: Integer;
                    Money: Integer;
                    Invisible: Boolean;
                    NonExistant: Boolean;
                    SkillNew: Boolean;
                    Sex: (Male, Female);
                    Dead: Boolean;
                    Poisoned: Boolean;
                    Playtester: Boolean;
                    PlyrTemp, Echo: Boolean;
                    SSharp, SThrust, SBlunt, SLong: 0..7;
                    Converted: 0..1023;
                    Hidden, Assoc, Master, TGuild: Boolean;
                    FileNum: 0..127;
                    Reserved: 0..511;
                    LastInput: TimeType;
                    Next: UserPoint;
                    USWeap, USArm, USShield: ObjectPoint;
                    DefPlayer: UserPoint;
                    DefMon: MonsterPoint;
                    Entry: EntryType;
                    Follow, NextUser: UserPoint;
                    LastAtk: TimeType;
                    LastHeal: TimeType;
                    HitAtTime: TimeType;
                    EncountStop: Boolean;
                    Drunk: TimeType;
                    Auto, Brief, MesBlock: Boolean;
                    Data: Integer;
                    LastCmd: Alfa;
                    WData: Alfa;
                    XPid: Integer
                  End (*UserType*);

    Var
      MList: File of MonsterType;
      EncIndex: Packed Array [1 .. LEncounter, 1 .. 6] of 0 .. 127;
      ProtoMonster: MonsterType;

    Procedure PM (Mon: MonsterPoint; C: Boolean; Var Str: Var256);

      Var
        Single  : Boolean;
        TName   : Alfa;
        Str1    : Var256;

      Begin
        Single := Mon ^.Top and (Mon ^.Num = 1);
        If Single
        Then
          If C
          Then
            Str := 'The '
          Else
            Str := 'the '
        Else
          Str := '';
        TName := Mon ^.Name;
        If C And Not Single Then
          TName [1] := Cap (TName [1]);
        Ps (TName, Str1);
        Str := Str + Str1;
        If Not Single
        Then
          Begin
            Writev (Str1, ' #', Mon ^.Num: 0);
            Str := Str + Str1
          End (*If*)
      End (*PM*);
    
    Procedure Destroy (Var Mon: MonsterPoint);
    
      Var
        Obj: ObjectPoint;
      
      Begin
        While Mon ^.ObjectTail <> NIL Do
          Begin
            Obj := Mon ^.ObjectTail;
            Mon ^.ObjectTail := Mon ^.ObjectTail ^.Next;
            ODestroy (Obj)
          End (*While*);
        Dispose (Mon);
        Mon := NIL
      End (*Destroy*);
    
    Procedure FixMonCount (MonsterTail: MonsterPoint; Name: Alfa);
    
      Var
        Pt: MonsterPoint;
        I, NumMon: Integer;
      
      Begin
        Pt := MonsterTail;
        NumMon := 0;
        While (Pt <> NIL) Do
          Begin
            If Pt ^.Name = Name
            Then
              NumMon := NumMon + 1;
            Pt := Pt ^.Next
          End (*While*);
        If NumMon > 0
        Then
          Begin
            Pt := MonsterTail;
            For I := NumMon DownTo 1 Do
              Begin
                While (Pt ^.Name <> Name) Do
                  Pt := Pt ^.Next;
                Pt ^.Num := Min (9, I);
                Pt ^.Top := (I = NumMon);
                Pt := Pt ^.Next
              End (*For*)
          End (*If*)
      End (*FixMonCount*);
      
    Procedure MonDisplay (Monster: MonsterPoint);
    
      Var
        Object : ObjectPoint;

      Begin
        With Monster ^ Do
          Begin
            PM (Monster, True, B2);
            B1 := '0' + B2;
            PNth (Lvl, B2);
            B1 := B1 + ' is a ' + B2;
            Writev (B2,
                    'level monster with ', Hits: 0, '/', MaxHits: 0, ' H.P.');
            B1 := B1 + B2;
            QOut (Term, B1);
            Pb (Defend, B1);
            Pb (Block, B2);
            B1 := '0' + 'Defend=' + B1 + ', Block=' + B2 + ', Follow=';
            Pb (Follow, B2);
            B1 := B1 + B2 + ',';
            QOut (Term, B1);
            Pb (Guard, B1);
            Pb (AtkLastAggr, B2);
            B1 := '0' + 'Guard=' + B1 + ', AtkLastAggr=' + B2 + '.';
            QOut (Term, B1);
            Writev (B1, '0', '': 8, Experience: 0, ' E.P., Permanent=');
            Pb (Permanent, B2);
            B1 := B1 + B2;
            QOut (Term, B1);
            If MoralReact Then
              QOut (Term, '0Monster will hit players with piety < 8.');
            If Invisible Then
              QOut (Term, '0Monster is invisible.');
            If Flee Then
              QOut (Term, '0Monster may flee.');
            If Assistance Then
              QOut (Term, '0Monster will call for help if attacked.');
            If Magic Then
              QOut (Term, '0Monster is affected only by magic weapons.');
            If Poison Then
              QOut (Term, '0Monster is poisonous.');
            If AntiMagic Then
              QOut (Term, '0Monster is immune to spells.');
            If Undead Then
              QOut (Term, '0Monster is undead.');
            If SlowReact Then
              QOut (Term, '0Monster will react slowly.');
            If FastReact Then
              QOut (Term, '0Monster will react quickly.');
            If Regenerate Then
              QOut (Term, '0Monster can regenerate hit points.');
            If Drain Then
              QOut (Term, '0Monster has energy-drain.');
            If MonSpells Then
              QOut (Term, '0Monster can cast spells.');
            If MParley > 0
            Then
              Begin
                Writev (B1, '0Monster will do type ', MParley: 0, ' parley.');
                QOut (Term, B1)
              End (*If*);
            Writev (B1, '0Treasure type: ', WhichObj: 0, '.');
            QOut (Term, B1);
            Object := ObjectTail;
            If Object <> NIL
            Then
              Begin
                QOut (Term, '0Objects carried:');
                Repeat
                  PrintObj (Object ^, False, True, B1);
                  B1 := '0  ' + B1;
                  QOut (Term, B1);
                  Object := Object ^.Next
                Until Object = NIL
              End (*If*)
          End (*With*)
      End (*MonDisplay*);
    
    Function FindMonster (Var Word: Alfa; Num: Integer; MonsterTail:
                          MonsterPoint): MonsterPoint;
    (* FindMonster returns the matching monster to *Word* in the list *)

      Var
        Monster: MonsterPoint;
        Count, Index: Integer;
        Found: Boolean;
        MonName: Alfa;
        NameList: NameTList;
      
      Begin
        CapAlfa (Word);
        Count := 0;
        Monster := MonsterTail;
        While (Monster <> NIL) And (Count < MaxNames) Do
          Begin
            Count := Count + 1;
            NameList[Count] := Monster^.Name;
            CapAlfa (NameList[Count]);
            Monster := Monster ^.Next
          End (*While*);
        If Count >= MaxNames
        Then
          QOut (Term, '0 Mil30 - Monster table overflow');
        Index := WordMatch (Word, Count, NameList);
        If Index <= 0
        Then
          Monster := NIL
        Else
          Begin
            Monster := MonsterTail;
            For Count := 1 to Index - 1 Do
              Monster := Monster ^.Next;
            If Num > 0
            Then
              Begin
                MonName := Monster^.Name;
                Found := False;
                While (Monster <> NIL) And Not Found Do
                  If (Monster ^.Name = MonName) And (Monster ^.Num = Num)
                  Then
                    Found := True
                  Else
                    Monster := Monster ^.Next
              End (*If*)
          End (*Else*);
        FindMonster := Monster
      End (*FindMonster*);
