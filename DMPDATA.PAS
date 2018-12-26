
  Program PrintData(input, output);

{$I Milio.pas}
         (*$U #5:MILOBJ.CODE*)   MilObject
         (*$U #5:MILMON.CODE*)   MilMonster
         (*$U #5:MILUSER.CODE*)  MilUser
         (*$U #5:MILROOM.CODE*)  MilRooms
         (*$U #5:MILDB.CODE*)    MilDataBase;
    
    Var
      F      : Text;
      Indent : Integer;
      Inner  : Integer;
      Outer  : Integer;
      Ch     : Char;
      
    Procedure ReadType (VAR F : Text;
                        VAR T : Ch2);

      Var
        Ch        : Char;

      Begin
        Repeat
          Read (F , Ch)
        Until Ch <> ' ';
        T [1] := Ch;
        Read (F , T [2]);
        Read (F , Ch)
      End (*ReadType*);

    Function ReadBool (VAR F : Text) : Boolean;
      
      Var
        Ch        : Char;
      
      Begin
        Repeat
          Read (F , Ch)
        Until Ch <> ' ';
        ReadBool := (Cap (Ch) = 'T')
      End (*ReadBool*);
    
    Function ReadInt (VAR F : Text) : Integer;
    
      Var
        I         : Integer;
      
      Begin
        Read (F , I);
        ReadInt := I
      End (*ReadInt*);
      
    Procedure ReadString (VAR F : Text;
                          VAR S : String);
      
      Var
        I         : Integer;
        Ch        : Char;
        N         : String;
      
      Begin
        Repeat
          Read (F , Ch)
        Until Ch = '"';
        (*$R-*)
        N [0] := Chr (80);
        (*$R^*)
        I := 0;
        Repeat
          I := I + 1;
          Read (F , N [I])
        Until (N [I] = '"');
        (*$R-*)
        N [0] := Chr (I - 1);
        (*$R^*)
        S := N
      End (*ReadString*);
    
    Procedure ReadObjData (VAR F   : Text;
                           VAR Obj : ObjectType);
      
      Var
        ObjPtr    : ObjectPoint;
        I         : Integer;
        Ch        : Char;
        B         : Boolean;
        ObjName   : String;

      Procedure SetObjClass (VAR Obj      : ObjectType;
                                 ClassName: String);

        Begin
          With Obj Do
            Begin
 , ObClass := Misc;
 , If ClassName = 'PORTAL'
 , Then
                ObClass := Portal;
 , If ClassName = 'WEAP'
 , Then
                ObClass := Weap;
 , If ClassName = 'SHIELD'
 , Then
                ObClass := Shield;
 , If ClassName = 'ARMOR'
 , Then
                ObClass := Armor;
 , If ClassName = 'COINS'
 , Then
                ObClass := Coins;
 , If ClassName = 'SCROLL'
 , Then
                ObClass := Scroll;
 , If ClassName = 'CHEST'
 , Then
                ObClass := Chest;
 , If ClassName = 'DOOR'
 , Then
                ObClass := Door;
 , If ClassName = 'KEYS'
 , Then
                ObClass := Keys;
 , If ClassName = 'MAGDEVICE'
 , Then
                ObClass := MagDevice;
 , If ClassName = 'TELEPORT'
 , Then
                ObClass := Teleport;
 , If ClassName = 'CARD'
 , Then
                ObClass := Card;
 , If ClassName = 'TREASURE'
 , Then
                ObClass := Treasure;
 , If ClassName = 'MISC'
 , Then
                ObClass := Misc;
 , If ClassName = 'RESERVED'
 , Then
                ObClass := Res1;
 , If ClassName = 'DUMMY'
 , Then
                ObClass := ObjDummy
            End (*With*)
        End (*SetObjClass*);

      Begin
        With Obj Do
          Begin
            Read (F , I);
            Article := A;
            While (I > 0) Do
 , Begin
                Article := Succ (Article);
                I := I - 1
 , End (*While*);
            ReadString (F , Name);
            Carry := ReadBool (F);
            Weight := ReadInt (F);
            Price := ReadInt (F);
            Magic := ReadBool (F);
            Permanent := ReadBool (F);
            Invisible := ReadBool (F);
            DescCode := ReadInt (F);
            DescRec := ReadInt (F);
            ReadString (F , ObjName);
            SetObjClass (Obj , ObjName);
            Case ObClass of
 , Portal:
                ToWhere := ReadInt (F);
 , Weap:
                Begin
                  MinHP := ReadInt (F);
                  MaxHP := ReadInt (F);
                  Strikes := ReadInt (F);
                  WeaPlus := ReadInt (F);
                  Read (F , Ch);
                  Read (F , Ch);
                  Case Ch of
                    'S':
                      WeapType := Sharp;
                    'T':
                      WeapType := Thrust;
                    'B':
                      WeapType := Blunt;
                    'P':
                      WeapType := Long
                  End (*Case*)
                End (*Weap*);
 , Shield:
                Begin
                  ShPlus := ReadInt (F);
                  ShHits := ReadInt (F)
                End (*Shield*);
 , Armor:
                Begin
                  ArmPlus := ReadInt (F);
                  ArmHits := ReadInt (F)
                End (*Armor*);
 , Coins:
                Multiplier := ReadInt (F);
 , Scroll:
                Spell := ReadInt (F);
 , Chest:
                Begin
                  Closed := ReadBool (F);
                  Locked := ReadInt (F);
                  Trap := ReadInt (F);
                  NumInside := ReadInt (F);
                  ObjectTail := NIL
                End (*Chest*);
 , Door:
                Begin
                  DToWhere := ReadInt (F);
                  DClosed := ReadBool (F);
                  DTrap := ReadInt (F);
                  DLocked := ReadInt (F)
                End (*Door*);
 , Keys:
                UnLock := ReadInt (F);
 , MagDevice:
                Begin
                  MSpell := ReadInt (F);
                  NumCharges := ReadInt (F)
                End (*MagDevice*);
 , Teleport:
                Begin
                  TToWhere := ReadInt (F);
                  TActiveRm := ReadInt (F)
                End (*Teleport*);
 , Misc: ;
 , Card: ;
 , ObjDummy: ;
 , Res1: ;
            End (*Case*);
            ReadLn (F)
          End (*With*)
      End (*ReadObjData*);
      
    Procedure ReadMonData (VAR F   : Text;
                           VAR Mon : MonsterType);

      Var
        Obj       : ObjectPoint;
        I         : Integer;
        Ch        : Char;

      Begin
        With Mon Do
          Begin
            Repeat
 , Read (F , Ch)
            Until Ch <> ' ';
            Name [1] := Ch;
            For I := 2 to 10 Do
 , Read (F , Name [I]);
            Defend := ReadBool (F);
            Block := ReadBool (F);
            Follow := ReadBool (F);
            Guard := ReadBool (F);
            AtkLastAggr := ReadBool (F);
            SlowReact := ReadBool (F);
            FastReact := ReadBool (F);
            Invisible := ReadBool (F);
            Regenerate := ReadBool (F);
            Drain := ReadBool (F);
            Poison := ReadBool (F);
            AntiMagic := ReadBool (F);
            Undead := ReadBool (F);
            MoralReact := ReadBool (F);
            Flee := ReadBool (F);
            Assistance := ReadBool (F);
            MonSpells := ReadBool (F);
            MRes2 := ReadBool (F);
            MRes3 := ReadBool (F);
            Lvl := ReadInt (F);
            Hits := ReadInt (F);
            MaxHits := ReadInt (F);
            Experience := ReadInt (F);
            Top := ReadBool (F);
            Num := ReadInt (F);
            Permanent := ReadBool (F);
            Magic := ReadBool (F);
            WhichObj := ReadInt (F);
            MReact := ReadInt (F);
            MParley := ReadInt (F);
            ReadLn (F)
          End (*With*)
      End (*ReadMonData*);

    Procedure ReadRoomData (VAR F    : Text;
                            VAR Num  : Integer);

      Var
        I     : Integer;
        J     : Integer;
        Rm    : Integer;

      Begin
        Num := ReadInt (F);
        Rm := S (Num);
        With Room [Rm] Do
          Begin
            For I := 1 to 6 Do
 , Adjoin [I] := Max (0 , Min (NumRooms , ReadInt (F)));
            Out := ReadInt (F);
            DescCode := ReadInt (F);
            DescRec := ReadInt (F);
            LastDir := ReadInt (F);
            WhichEncounter := ReadInt (F);
            EncounterTime := ReadInt (F);
            NotifyDM := ReadBool (F);
            Safe := ReadBool (F);
            ReadLn (F)
          End (*With*)
      End (*ReadRoomData*);

    Procedure ReadDescData (VAR F : Text;
                            VAR D : DescRec);

      Var
        Ch        : Char;

      Begin
        With D Do
          Begin
            RecNum := ReadInt (F);
            LinNum := ReadInt (F);
            NPhr := ReadInt (F);
            Read (F , Ch);
            ReadLn (F , DLine)
          End (*With*)
      End (*ReadDescData*);
    
    Procedure UpdateDescData (VAR D : DescRec);
    
      Const
        Add       = 193;
        Update    = 202;
        
      Var
        Error     : Integer;
        KSAMRec   : Packed Record
                      Case Boolean of
                        False:
                          (Dummy : KSAMWord);
                        True:
                          (DRec  : DescRec)
                    End (*KSAMRec*);
                    
      Begin
        KSAMRec.DRec := D;
        With KSAMRec Do
          Begin
            DRec.Len := 7 + Length (DRec.DLine);
            If Odd (DRec.Len)
            Then
 , DRec.Len := DRec.Len + 1
          End (*With*);
        Error := KSAM (Add , EDesc , DscrptFCB , KSAMRec.Dummy);
        If Error <> 0
        Then
          Begin
            Error := KSAM (Update , EDesc , DscrptFCB , KSAMRec.Dummy);
            If Error <> 0
            Then
 , Begin
                WriteLn ('Error updating description!  Error = ' , Error: 0);
                Halt
 , End (*If*)
          End (*If*)
      End (*UpdateDescRec*);

    Procedure ReadPlyrData (VAR F : Text;
                            VAR P : UserType);

      Var
        Ch       : Char;
        I        : Integer;

      Begin
        With P Do
          Begin
            Read (F , Ch);
            Repeat
 , Read (F , Ch)
            Until Ch <> ' ';
            Name [1] := Ch;
            For I := 2 to 10 Do
 , Read (F , Name [I]);
            SSJ := ReadBool (F);
            Weight := ReadInt (F);
            Lvl := ReadInt (F);
            Read (F , I);
            Class := Fighter;
            While (I > 0) Do
 , Begin
                Class := Succ (Class);
                I := I - 1
 , End (*While*);
            Hits := ReadInt (F);
            MaxHits := ReadInt (F);
            Fatigue := ReadInt (F);
            MaxFatigue := ReadInt (F);
            Magic := ReadInt (F);
            MaxMagic := ReadInt (F);
            Experience := ReadInt (F);
            AGuild := ReadBool (F);
            SendDay := ReadInt (F);
            AC := ReadInt (F);
            RmCode := ReadInt (F);
            Str := ReadInt (F);
            Int := ReadInt (F);
            Dex := ReadInt (F);
            Pty := ReadInt (F);
            Con := ReadInt (F);
            Evil := ReadBool (F);
            SpellDay := ReadInt (F);
            LastAccess := ReadInt (F);
            PW := ReadInt (F);
            Money := ReadInt (F);
            Invisible := ReadBool (F);
            Nonexistant := ReadBool (F);
            SkillNew := ReadBool (F);
            Sex := Male;
            Read (F , I);
            If I = 1
            Then
 , Sex := Female;
            Dead := ReadBool (F);
            Poisoned := ReadBool (F);
            PlayTester := ReadBool (F);
            PlyrTemp := ReadBool (F);
            Echo := ReadBool (F);
            SSharp := ReadInt (F);
            SThrust := ReadInt (F);
            SBlunt := ReadInt (F);
            SLong := ReadInt (F);
            Converted := ReadInt (F);
            Hidden := ReadBool (F);
            Assoc := ReadBool (F);
            Master := ReadBool (F);
            TGuild := ReadBool (F);
            FileNum := ReadInt (F);
            Reserved := ReadInt (F);
            Auto := ReadBool (F);
            Brief := ReadBool (F);
            MesBlock := ReadBool (F);
            ReadLn (F)
          End (*With*)
      End (*ReadPlyrData*);
     , Procedure ReadOIndex (VAR F   : Text);
      
      Var
        Pos : Integer;
        I   : Integer;
      
      Begin
        Read (F , Pos);
        For I := 1 to 6 Do
          ObjIndex [Pos , I] := ReadInt (F);
        ReadLn (F)
      End (*ReadOIndex*);

    Procedure ReadMIndex (VAR F   : Text);

      Var
        Pos : Integer;
        I   : Integer;

      Begin
        Read (F , Pos);
        For I := 1 to 6 Do
          EncIndex [Pos , I] := ReadInt (F);
        ReadLn (F)
      End (*ReadMIndex*);

    Procedure InsObject (VAR Head : ObjectPoint;
                             Obj  : ObjectPoint);

      Var
        ObjPtr    : ObjectPoint;

      Begin
        If Head = NIL
        Then
          Begin
            Head := Obj;
            Head ^.Next := NIL
          End (*If*)
        Else
          Begin
            ObjPtr := Head;
            While ObjPtr ^.Next <> NIL Do
 , ObjPtr := ObjPtr ^.Next;
            ObjPtr ^.Next := Obj;
            Obj ^.Next := NIL
          End (*Else*)
      End (*InsObject*);

    Procedure InsMonster (VAR Head : MonsterPoint;
                              Mon  : MonsterPoint);

      Var
        MonPtr    : MonsterPoint;

      Begin
        If Head = NIL
        Then
          Begin
            Head := Mon;
            Head ^.Next := NIL
          End (*If*)
        Else
          Begin
            MonPtr := Head;
            While MonPtr ^.Next <> NIL Do
 , MonPtr := MonPtr ^.Next;
            MonPtr ^.Next := Mon;
            Mon ^.Next := NIL
          End (*Else*)
      End (*InsMonster*);
    
    Procedure ReadData;

      Var
        Kind      : Ch2;
        ReadPos   : Integer;
        LastRm    : Integer;
        LastObj   : ObjectPoint;
        LastMon   : MonsterPoint;
        LastPlyr  : UserPoint;
        Obj       : ObjectPoint;
        Mon       : MonsterPoint;
        Plyr      : UserPoint;
        Desc      : DescRec;
        FileName  : String;
        St        : String;

      Begin
        Write ('Enter name of data file: ');
        ReadLn (FileName);
        (*$I-*)
        Reset (F , FileName);
        (*$I^*)
        If IOResult <> 0
        Then
          WriteLn ('File not present.')
        Else
          Begin
            LastRm := 0;
            LastObj := NIL;
            LastMon := NIL;
            LastPlyr := NIL;
            While Not Eof (F) Do
 , Begin
                ReadType (F , Kind);
                WriteLn ('Kind = ' , Kind);
                If Kind = '**'
                Then
                  Begin
                    ReadLn (F , St);
                    WriteLn (St)
                  End (*If*)
                Else
                  If Kind = 'RO'
                  Then
                    ReadRoomData (F , LastRm)
                  Else
                    If Kind = 'DS'
                    Then
                      Begin
                        ReadDescData (F , Desc);
                        UpdateDescData (Desc)
                      End (*If*)
                    Else
                      If Kind = 'OB'
                      Then
                        Begin
                          New (Obj);
                          Obj ^ := ProtoObject;
                          ReadObjData (F , Obj ^);
                          LastObj := Obj;
                          InsObject (Room [S (LastRm)].RmObjectTail , Obj)
                        End (*If*)
                      Else
                        If Kind = 'MO' (*Monster*)
                        Then
                          Begin
                            New (Mon);
                            Mon ^ := ProtoMonster;
                            ReadMonData (F , Mon ^);
                            LastMon := Mon;
                            InsMonster (Room [S (LastRm)].RmMonsterTail , Mon)
                          End (*If*)
                        Else
                          If Kind = 'CO'
                          Then
                            Begin
                              New (Obj);
                              Obj ^ := ProtoObject;
                              ReadObjData (F , Obj ^);
                              InsObject (LastObj ^.ObjectTail , Obj)
                            End (*If*)
                          Else
                            If Kind = 'MT'
                            Then
                              Begin
                                New (Obj);
                                Obj ^ := ProtoObject;
                                ReadObjData (F , Obj ^);
                                InsObject (LastMon ^.ObjectTail , Obj)
                              End (*If*)
                            Else
                              If Kind = 'PO'
                              Then
                                Begin
                                  New (Obj);
                                  Obj ^ := ProtoObject;
                                  ReadObjData (F , Obj ^);
                                  InsObject (LastPlyr ^.ObjectTail , Obj)
                                End (*If*)
                              Else
                                If Kind = 'PL'
                                Then
                                  Begin
                                    If LastPlyr <> NIL
                                    Then
                                      Begin
                                        WriteLn ('Writing last player..');
                                        WritePlayer (LastPlyr , True);
                                        WriteLn ('Disposing of record..');
                                        WritePlayer (LastPlyr , False);
                                        LastPlyr := NIL
                                      End (*If*);
                                    New (Plyr);
                                    Plyr ^ := ProtoUser;
                                    ReadPlyrData (F , Plyr ^);
                                    LastPlyr := Plyr
                                  End (*If*)
                                Else
                                  If Kind = 'OL'
                                  Then
                                    Begin
                                      Read (F , ReadPos);
                                      ReadObjData (F , OList ^);
                                      Seek (OList , ReadPos - 1);
                                      Put (OList)
                                    End (*If*)
                                  Else
                                    If Kind = 'ML'
                                    Then
                                      Begin
                                        Read (F , ReadPos);
                                        ReadMonData (F , MList ^);
                                        Seek (MList , ReadPos - 1);
                                        Put (MList)
                                      End (*If*)
                                    Else
                                      If Kind = 'OI'
                                      Then
                                        ReadOIndex (F)
                                      Else
                                        If Kind = 'MI'
                                        Then
                                          ReadMIndex (F)
                                        Else
                                          Begin
                                            ReadLn (F , St);
                                            WriteLn (St)
                                          End (*Else*)
 , End (*While*)
          End (*Else*)
      End (*ReadData*);
    
    Procedure PrintBool (VAR F : Text;
                             B : Boolean);
                             
      Begin
        If B
        Then
          Write (F , ' T')
        Else
          Write (F , ' F')
      End (*PrintBool*);
      
    Procedure StartLine (VAR F   : Text;
                             Chs : String);
      
      Begin
        Write (F , '': Indent , Chs , ' ')
      End (*StartLine*);
      
    Procedure DoObjData (VAR F   : Text;
                         VAR Obj : ObjectType);
    
      Var
        ObjPtr    : ObjectPoint;
        
      Begin
        With Obj Do
          Begin
            Write (F , Ord (Article): 2);
            Write (F , ' "' , Name , '"' , '': 21 - Length (Name));
            PrintBool (F , Carry);
            Write (F , Weight: 5);
            Write (F , Price: 6);
            PrintBool (F , Magic);
            PrintBool (F , Permanent);
            PrintBool (F , Invisible);
            Write (F , DescCode: 3);
            Write (F , DescRec: 4);
            Case ObClass of
 , Portal:
                Begin
                  Write (F , ' "PORTAL"');
                  Write (F , ToWhere: 5)
                End (*Portal*);
 , Weap:
                Begin
                  Write (F , ' "WEAPON"');
                  Write (F , MinHP: 4 , MaxHP: 4 , Strikes: 4 , WeaPlus: 3);
                  Case WeapType of
                    Sharp:
                      Write (F , ' S');
                    Thrust:
                      Write (F , ' T');
                    Blunt:
                      Write (F , ' B');
                    Long:
                      Write (F , ' P')
                  End (*Case*)
                End (*Weap*);
 , Shield:
                Begin
                  Write (F , ' "SHIELD"');
                  Write (F , ShPlus: 3 , ShHits: 4)
                End (*Armor*);
 , Armor:
                Begin
                  Write (F , ' "ARMOR"');
                  Write (F , ArmPlus: 3 , ArmHits: 4)
                End (*Armor*);
 , Coins:
                Begin
                  Write (F , ' "COINS"');
                  Write (F , Multiplier: 3);
                End (*Coins*);
 , Scroll:
                Begin
                  Write (F , ' "SCROLL"');
                  Write (F , Spell: 4);
                End (*Coins*);
 , Chest:
                Begin
                  Write (F , ' "CHEST"');
                  PrintBool (F , Closed);
                  Write (F , Locked: 5);
                  Write (F , Trap: 3);
                  Write (F , NumInside: 3);
                End (*Chest*);
 , Door:
                Begin
                  Write (F , ' "DOOR"');
                  Write (F , DToWhere: 5);
                  PrintBool (F , DClosed);
                  Write (F , DTrap: 3);
                  Write (F , DLocked: 5)
                End (*Door*);
 , Keys:
                Begin
                  Write (F , ' "KEYS"');
                  Write (F , UnLock: 5)
                End (*Keys*);
 , MagDevice:
                Begin
                  Write (F , ' "MAGDEVICE"');
                  Write (F , MSpell: 4);
                  Write (F , NumCharges: 4)
                End (*MagDevice*);
 , Teleport:
                Begin
                  Write (F , ' "TELEPORT"');
                  Write (F , TToWhere: 5);
                  Write (F , TActiveRm: 5)
                End (*Teleport*);
 , Treasure:
                Write (F , ' "TREASURE"');
 , Misc:
                Write (F , ' "MISC"');
 , Card:
                Write (F , ' "CARD"');
 , ObjDummy:
                Write (F , ' "DUMMY"');
 , Res1:
                Write (F , ' "RESERVED"')
            End (*Case*);
            WriteLn (F);
            If (ObClass = Chest) And (ObjectTail <> NIL)
            Then
 , Begin
                ObjPtr := ObjectTail;
                Indent := Indent + 1;
                While ObjPtr <> NIL Do
                  Begin
                    StartLine (F , 'CO');
                    Write (F , ' ');
                    DoObjData (F , ObjPtr ^);
                    ObjPtr := ObjPtr ^.Next
                  End (*While*);
                Indent := Indent - 1
 , End (*If*)
          End (*With*)
      End (*DoObjData*);
      
    Procedure DoMonData (VAR F   : Text;
                         VAR Mon : MonsterType);
      
      Var
        Obj       : ObjectPoint;
        
      Begin
        With Mon Do
          Begin
            Write (F , Name);
            PrintBool (F , Defend);
            PrintBool (F , Block);
            PrintBool (F , Follow);
            PrintBool (F , Guard);
            PrintBool (F , AtkLastAggr);
            PrintBool (F , SlowReact);
            PrintBool (F , FastReact);
            PrintBool (F , Invisible);
            PrintBool (F , Regenerate);
            PrintBool (F , Drain);
            PrintBool (F , Poison);
            PrintBool (F , AntiMagic);
            PrintBool (F , Undead);
            PrintBool (F , MoralReact);
            PrintBool (F , Flee);
            PrintBool (F , Assistance);
            PrintBool (F , MonSpells);
            PrintBool (F , MRes2);
            PrintBool (F , MRes3);
            Write (F , Lvl: 3);
            Write (F , Hits: 5);
            Write (F , MaxHits: 5);
            Write (F , Experience: 6);
            PrintBool (F , Top);
            Write (F , Num: 2);
            PrintBool (F , Permanent);
            PrintBool (F , Magic);
            Write (F , WhichObj: 4);
            Write (F , MReact: 3);
            Write (F , MParley: 3);
            WriteLn (F);
            If ObjectTail <> NIL
            Then
 , Begin
                Obj := ObjectTail;
                Indent := Indent + 1;
                While Obj <> NIL Do
                  Begin
                    StartLine (F , 'MT');
                    DoObjData (F , Obj ^);
                    Obj := Obj ^.Next
                  End (*While*);
                Indent := Indent - 1
 , End (*If*)
          End (*With*)
      End (*DoMonData*);
    
    Procedure DoRoomData (VAR F    : Text;
                          VAR Rm   : RoomType;
                              Num  : Integer);
      
      Var
        I     : Integer;
        Obj   : ObjectPoint;
        Mon   : MonsterPoint;
      
      Begin
        With Rm Do
          Begin
            Write (F , Num: 5);
            For I := 1 to 6 Do
 , Begin
                Write (F , Adjoin [I]: 5);
                If (Adjoin [I] >= (Num Div 10) * 10) And
                   (Adjoin [I] <= (Num Div 10) * 10 + 9)
                Then
                  Inner := Inner + 1
                Else
                  If Adjoin [I] <> 0
                  Then
                    Outer := Outer + 1
 , End (*For*);
            Write (F , Out: 5);
            If (Out >= (Num Div 10) * 10) And (Out <= (Num Div 10) * 10 + 9)
            Then
 , Inner := Inner + 1
            Else
 , If Out <> 0
 , Then
                Outer := Outer + 1;
            Write (F , DescCode: 3);
            Write (F , DescRec: 4);
            Write (F , LastDir: 2);
            Write (F , WhichEncounter: 4);
            Write (F , EncounterTime: 4);
            PrintBool (F , NotifyDM);
            PrintBool (F , Safe);
            WriteLn (F);
            Indent := Indent + 1;
            If RmObjectTail <> NIL
            Then
 , Begin
                Obj := RmObjectTail;
                While Obj <> NIL Do
                  Begin
                    StartLine (F , 'OB');
                    DoObjData (F , Obj ^);
                    Obj := Obj ^.Next
                  End (*While*)
 , End (*If*);
            If RmMonsterTail <> NIL
            Then
 , Begin
                Mon := RmMonsterTail;
                While Mon <> NIL Do
                  Begin
                    StartLine (F , 'MO');
                    DoMonData (F , Mon ^);
                    Mon := Mon ^.Next
                  End (*While*)
 , End (*If*);
            Indent := Indent - 1
          End (*With*)
      End (*DoRoomData*);
    
    Procedure DoDescData (VAR F : Text;
                          VAR D : DescRec);
    
      Begin
        With D Do
          Begin
            Write (F , RecNum: 4);
            Write (F , LinNum: 4);
            Write (F , NPhr: 4);
            Write (F , ' ' , DLine);
            WriteLn (F)
          End (*With*)
      End (*DoDescData*);
    
    Procedure DoPlyrData (VAR F : Text;
                          VAR P : UserType);
                          
      Var
        Obj      : ObjectPoint;
        
      Begin
        With P Do
          Begin
            Write (F , Name);
            PrintBool (F , SSJ);
            Write (F , Weight: 5);
            Write (F , Lvl: 3);
            Write (F , Ord (Class): 3);
            Write (F , Hits: 5);
            Write (F , MaxHits: 5);
            Write (F , Fatigue: 5);
            Write (F , MaxFatigue: 5);
            Write (F , Magic: 5);
            Write (F , MaxMagic: 5);
            Write (F , Experience: 6);
            PrintBool (F , AGuild);
            Write (F , SendDay: 3);
            Write (F , AC: 3);
            Write (F , RmCode: 5);
            Write (F , Str: 3);
            Write (F , Int: 3);
            Write (F , Dex: 3);
            Write (F , Pty: 3);
            Write (F , Con: 3);
            PrintBool (F , Evil);
            Write (F , SpellDay: 3);
            Write (F , LastAccess: 3);
            Write (F , PW: 6);
            Write (F , Money: 6);
            PrintBool (F , Invisible);
            PrintBool (F , Nonexistant);
            PrintBool (F , SkillNew);
            Write (F , Ord (Sex): 2);
            PrintBool (F , Dead);
            PrintBool (F , Poisoned);
            PrintBool (F , Playtester);
            PrintBool (F , PlyrTemp);
            PrintBool (F , Echo);
            Write (F , SSharp: 2);
            Write (F , SThrust: 2);
            Write (F , SBlunt: 2);
            Write (F , SLong: 2);
            Write (F , Converted: 5);
            PrintBool (F , Hidden);
            PrintBool (F , Assoc);
            PrintBool (F , Master);
            PrintBool (F , TGuild);
            Write (F , FileNum: 4);
            Write (F , Reserved: 4);
            PrintBool (F , Auto);
            PrintBool (F , Brief);
            PrintBool (F , MesBlock);
            WriteLn (F);
            If ObjectTail <> NIL
            Then
 , Begin
                Obj := ObjectTail;
                Indent := Indent + 1;
                While Obj <> NIL Do
                  Begin
                    StartLine (F , 'PO');
                    DoObjData (F , Obj ^);
                    Obj := Obj ^.Next
                  End (*While*);
                Indent := Indent - 1
 , End (*If*)
          End (*With*)
      End (*DoPlyrData*);
   
    Procedure PrintRooms (VAR F : Text);
    
      Var
        I         : Integer;
        J         : Integer;
      
      Begin
        NumSegs := 0;
        Seek (ECaves , 0);
        While Not Eof (ECaves) Do
          Begin
            Get (ECaves);
            NumSegs := NumSegs + 1
          End (*While*);
        Write ('ROOMS ');
        For I := 0 to NumSegs - 1 Do
          Begin
            ReadSeg (0 , I);
            Write ('.');
            WriteLn (F , '*** Rooms ' , I * 10: 0 , ' to ' , I * 10 + 9: 0 , ':');
            Inner := 0;
            Outer := 0;
            For J := 0 to 9 Do
 , If I * 10 + J > 0
 , Then
                Begin
                  StartLine (F , 'RO');
                  DoRoomData (F , Room [J] , I * 10 + J)
                End (*If*);
            WriteLn (F , '*** Total of ' , Inner: 0 , ' inner-segment links , and '
                        Outer: 0 , ' outer-segment links.')
          End (*For*);
        WriteLn;
      End (*PrintRooms*);
       , Procedure PrintDscrpt (VAR F : Text);
    
      Var
        I           : Integer;
        Error       : Integer;
        Description : Packed Record
                        Case Boolean of
                          False:
                            (Dummy : KSAMWord);
                          True:
                            (D     : DescRec)
                      End (*Description*);
      
      Begin
        I := -1;
        With Description.D Do
          Begin
            RecNum := 0;
            LinNum := 0
          End (*With*);
        Write ('DESCS ');
        Error := KSAM (200 , EDesc , DscrptFCB , Description.Dummy);
        While (Error = 0) Do
          Begin
            If Description.D.RecNum <> I
            Then
 , Begin
                I := Description.D.RecNum;
                WriteLn (F , '*** Description record ' , I);
                If I <> 1
                Then
                  Begin
                    WriteLn;
                    Write ('': 6)
                  End (*If*)
 , End (*If*);
            StartLine (F , 'DS');
            DoDescData (F , Description.D);
            Write ('.');
            Error := KSAM (197 , EDesc , DscrptFCB , Description.Dummy)
          End (*While*);
        WriteLn
      End (*PrintDescriptions*);
    
    Procedure PrintLists (VAR F : Text);
    
      Var
        I         : Integer;
      
      Begin
        Seek (OList , 0);
        WriteLn (F , '*** OList data follows..');
        Write ('OLIST ');
        For I := 1 to RanObjLen - 1 Do
          Begin
            StartLine (F , 'OL');
            Write (F , I: 2 , ' ');
            Get (OList);
            DoObjData (F , OList ^);
            Write ('.')
          End (*For*);
        Seek (MList , 0);
        WriteLn;
        Write ('MLIST ');
        WriteLn (F , '*** MList data follows..');
        For I := 1 to RanMonLen - 1 Do
          Begin
            StartLine (F , 'ML');
            Write (F , I: 2 , ' ');
            Get (MList);
            DoMonData (F , MList ^);
            Write ('.')
          End (*For*);
        WriteLn
      End (*PrintLists*);
    
    Procedure PrintIndexData (VAR F : Text);
      
      Var
        I , J      : Integer;
      
      Begin
        WriteLn (F , '*** Random object index');
        Write ('OINDEX ');
        For I := 1 to ObjListLen Do
          Begin
            StartLine (F , 'OI');
            Write (F , I: 3);
            For J := 1 to 6 Do
 , Write (F , ObjIndex [I , J]: 4);
            WriteLn (F);
            Write ('.')
          End (*For*);
        WriteLn;
        WriteLn (F , '*** Random monster index');
        Write ('MINDEX ');
        For I := 1 to ObjListLen Do
          Begin
            StartLine (F , 'MI');
            Write (F , I: 3);
            For J := 1 to 6 Do
 , Write (F , EncIndex [I , J]: 4);
            WriteLn (F);
            Write ('.')
          End (*For*);
        WriteLn
      End (*PrintIndexData*);
    
    Procedure PrintPlyrData (VAR F : Text);
    
      Var
        Plyr      : UserPoint;
        Error     : Integer;
        Name      : Alfa;
      
      Begin
        Write ('PLYRS ');
        Name := '          ';
        Error := ReadNextPlayer (Plyr , Name);
        While Error = 0 Do
          Begin
            StartLine (F , 'PL');
            DoPlyrData (F , Plyr ^);
            Write ('.');
            Name := Plyr ^.Name;
            WritePlayer (Plyr , False);
            Error := ReadNextPlayer (Plyr , Name)
          End (*While*);
        WritePlayer (Plyr , False);
        WriteLn
      End (*PrintPlyrData*);
      
    Procedure WriteData;
    
      Var
        FileName  : String;
    
      Begin
        Write ('Enter filename: ');
        ReadLn (FileName);
        (*$I-*)
        Rewrite (F , ConCat (FileName , '[*]'));
        If IOResult = 0
        Then
          Begin
            Indent := 0;
            { WriteLn (F , '*** Player data follows..');
            PrintPlyrData (F); }
            WriteLn (F , '*** Room data follows..');
            PrintRooms (F);
            WriteLn (F , '*** Description data follows..');
            PrintDscrpt (F);
            WriteLn (F , '*** Random monster and object data follows..');
            PrintLists (F);
            PrintIndexData (F);
            Close (F , Lock)
          End (*If*)
        Else
          WriteLn ('Something''s wrong!  Can''t open output file.')
      End (*WriteData*);
      
    Begin
      For Indent := 0 to MaxUsers Do
        Begin
          SlotTBL [Indent] := -1;
          Active [Indent] := 0
        End (*For*);
      NumSegs := 0;
      Seek (ECaves , 0);
      While Not Eof (ECaves) Do
        Begin
          Get (ECaves);
          NumSegs := NumSegs + 1
        End (*While*);
      NumRooms := NumSegs * 10 - 1;
      WriteLn ('TRANS - Transfer Milieu database files to other systems.': 68);
      WriteLn;
      Write ('Do you want to read or write data (R/W)? ');
      Repeat
        Read (Keyboard , Ch);
        Ch := Cap (Ch)
      Until Ch in [Chr (27) , 'R' , 'Q' , 'W'];
      WriteLn (Ch);
      Case Ch of
        'R':
          ReadData;
        'W':
          WriteData
      End (*Case*)
    End.
