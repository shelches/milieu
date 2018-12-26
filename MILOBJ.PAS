
    Const
      SpellDay  = 7;
      Spellen   = 17;
      RanObjLen = 78;
      ObjListLen= 50;
      
    Type
      ObjectPoint = ^ ObjectType;
      ObClassType = (Portal, Treasure, Weap, Armor, Shield, Coins, Scroll,
                     Chest, Door, Res1, MagDevice, Teleport, Keys, Card,
                     ObjDummy, Misc);
      SkillType   = (Sharp, Thrust, Blunt, Long);
      RmCodeType  = 0 .. 4095;
      ObjectType  = Packed Record
                      Name        : Varying [20] of Char;
                      Next        : ObjectPoint;
                      Article     : (A, An, Some, The, None);
                      Carry       : Boolean;
                      Weight      : 0 .. 1023;
                      Price       : 0 .. 16383;
                      Magic       : Boolean;
                      Permanent   : Boolean;
                      Invisible   : Boolean;
                      Reserved    : 0 .. 63;
                      DescCode    : 0 .. 63;
                      DescRec     : 0 .. 255;
                      Case ObClass: ObClassType of
                        Portal: (ToWhere: RmCodeType);
                        Weap: (MinHp, MaxHp: 0 .. 127;
                               Strikes: 0 .. 511;
                               WeaPlus: -5 .. 10;
                               WeapType: SkillType);
                        Shield: (ShPlus: -5 .. 10;
                                 ShHits: 0 .. 511);
                        Armor: (ArmPlus: -5 .. 10;
                                ArmHits: 0 .. 511);
                        Coins: (Multiplier: 0 .. 63);
                        Scroll: (Spell: 0 .. 511);
                        Chest: (Closed: Boolean;
                                Locked: 0 .. 1023;
                                Trap: 0 .. 63;
                                NumInside: 0 .. 15;
                                ObjectTail: ObjectPoint);
                        Door: (DToWhere: RmCodeType;
                               DClosed: Boolean;
                               DTrap: 0 .. 63;
                               DLocked: 0 .. 1023);
                        Keys: (UnLock: 0 .. 1023);
                        MagDevice: (MSpell: 0 .. 511;
                                    NumCharges: 0 .. 127);
                        Teleport: (TToWhere: RmCodeType;
                                   TActiveRm: 0 .. 2048)
                    End (* ObjectType *);
      SplClType = (OnUser, OnPlayer, OnMon, OnUsPlayer, OnMonPlayer, OnObject);
      SpellType = Packed Record
                    SplHash: Integer;
                    SplLen:  0..1023;
                    SplMp:   0..255;
                    SplLvl:  -4..25;
                    SplInt:  0..25;
                    SplType: SplClType;
                  End (*SpellType*);
    
    Var
      FolCount: Integer;
      OList : File of ObjectType;
      SpellList : Packed Array [0 .. Spellen] of Alfa;
      SpellClass: Packed Array [0 .. Spellen] of SpellType;
      ObjIndex : Packed Array [1 .. ObjListLen, 1 .. 6] of 0 .. 127;
      ProtoObject : ObjectType;
    
    Procedure InitSpells;

      Procedure AddSpell (N : Integer; Nm: Alfa; Hash, Len, MP, Lvl,
                           Int: Integer; Ty: SplClType);

        Begin
          SpellList [N] := Nm;
          With SpellClass [N] Do
            Begin
              SplHash := Hash;
              SplLen := Len;
              SplMP := MP;
              SplLvl := Lvl;
              SplInt := Int;
              SplType := Ty
            End (*With*)
        End (*AddSpell*);
      
      Begin
        AddSpell ( 0, 'NULL      ',   0,  0,  0, 0,  0, OnUser);
        AddSpell ( 1, 'VIGOR     ', 131, 14,  3, 0, 10, OnUsPlayer);
        AddSpell ( 2, 'HEAL      ', 190, 18,  6, 1, 10, OnUsPlayer);
        AddSpell ( 3, 'FIREBALL  ', 135, 15, 10, 2, 11, OnMonPlayer);
        AddSpell ( 4, 'LIGHTNING ', 340, 32, 15, 4, 13, OnMonPlayer);
        AddSpell ( 5, 'HURT      ',  40,  3,  1,-3,  8, OnMonPlayer);
        AddSpell ( 6, 'CUREPOISON', 317, 25,  6, 1,  9, OnUsPlayer);
        AddSpell ( 7, 'DISINTEGRA', 547, 50, 20, 5, 14, OnMonPlayer);
        AddSpell ( 8, 'BEFUDDLE  ', 341, 27,  5, 1, 11, OnMonPlayer);
        AddSpell ( 9, 'TELEPORT  ', 534, 46, 30, 6, 14, OnUsPlayer);
        AddSpell (10, 'WISH      ', 437, 43, 50,10, 17, OnUsPlayer);
        AddSpell (11, 'PASSDOOR  ', 199, 17, 20, 5, 13, OnObject);
        AddSpell (12, 'ENCHANT   ',  79, 12, 20, 5, 13, OnObject);
        AddSpell (13, 'BLESS     ', 296, 30, 16, 4, 11, OnPlayer);
        AddSpell (14, 'PROTECTION', 340, 30, 10, 2, 10, OnUser);
        AddSpell (15, 'CURSE     ', 258, 26, 10, 5, 10, OnPlayer);
        AddSpell (16, 'POISON    ', 278, 27, 10, 4, 10, OnPlayer);
        AddSpell (17, 'INTOXICATE', 268, 25,  8, 3,  9, OnUsPlayer);
        FolCount := 0
      End (*InitSpells*);
            
    Procedure ODestroy (Var Cont: ObjectPoint);
    
      Var
        Obj : ObjectPoint;
      
      Begin
        If Cont ^.ObClass = Chest
        Then
          While Cont ^.ObjectTail <> NIL Do
            Begin
              Obj := Cont ^.ObjectTail;
              Cont ^.ObjectTail := Cont ^.ObjectTail ^.Next;
              ODestroy (Obj)
            End (*While*);
        Dispose (Cont);
        Cont := NIL
      End (*ODestroy*);
    
    Function DeleteObject (Pt, ObjectTail: ObjectPoint): Boolean;
    
      Var
        Pt2 : ObjectPoint;
        Found : Boolean;
      
      Begin
        If Pt = NIL
        Then
          Abort (' Mil84 - Cannot delete NIL obj!');
        If Pt = ObjectTail
        Then
          DeleteObject := True
        Else
          Begin
            DeleteObject := False;
            Found := False;
            Pt2 := ObjectTail;
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
              Abort ('0 Mil05 - Deleted obj not found')
          End (*Else*)
      End (*DeleteObject*);
    
    Procedure PrintObj (Var Object: ObjectType; Singular, Capital: Boolean;
                        Var Str: Var256);
    
      Var
        ILoop, JLoop, KLoop : Integer;
        Ar : Varying [15] of Char;
        Flag : Boolean;
        Str1 : Var256;
      
      Begin
        With Object Do
          Begin
            Ar := '';
            If Singular and (Article <> None)
            Then
              Ar := 'the';
            If Not Singular
            Then
              If ObClass <> Door
              Then
                Case Article of
                  A:
                    Ar := 'a';
                  An:
                    Ar := 'an';
                  The:
                    Ar := 'the';
                  Some:
                    Ar := 'some';
                  None:
                    Ar := ''
                End (*Case*)
              Else
                Begin
                  Case Article of
                    A, An:
                      If DClosed
                      Then
                        Ar := 'a'
                      Else
                        Ar := 'an';
                    The:
                      Ar := 'the';
                    Some:
                      Ar := 'some';
                    None:
                      Ar := ''
                  End (*Case*);
                  If DClosed
                  Then
                    If DLocked > 0
                    Then
                      Ar := Ar + ' locked'
                    Else
                      Ar := Ar + ' closed'
                  Else
                    Ar := Ar + ' open'
                End (*Else*);
            Str := '';
            If Length (Ar) > 0
            Then
              Begin
                If Capital Then
                  Ar[1] := Cap (Ar[1]);
                Writev (Str, Ar, ' ')
              End (*If*);
            If ObClass = Coins
            Then
              Begin
                Writev (Str1, Price Div Multiplier: 0, ' ');
                Str := Str + Str1
              End (*If*);
            If Magic Then
              If Capital And (Article = None)
              Then
                Str := Str + 'Magic '
              Else
                Str := Str + 'magic ';
            ILoop := 0;
            Repeat
              ILoop := ILoop + 1;
              Flag := (Name[ILoop] = ',')
            Until Flag or (ILoop >= Length (Name));
            If Not Flag
            Then
              Begin
                Writev (Str1, Name);
                Str := Str + Str1
              End (*If*)
            Else
              Begin
                JLoop := ILoop + 1;
                While (JLoop <= Length (Name)) Do
                  Begin
                    If Name [JLoop] = '*'
                    Then
                      For KLoop := 1 to ILoop - 1 Do
                        Str := Str + Name[KLoop]
                    Else
                      Str := Str + Name[JLoop];
                    JLoop := JLoop + 1
                  End (*While*)
              End (*Else*);
            If Not Singular
            Then
              Begin
                If Invisible
                Then
                  Str := Str + ' (INV)';
                If (ObClass = Weap) And Magic Then
                  Begin
                    Writev (Str1, ' (+', Abs(WeaPlus): 0, ')');
                    Str := Str + Str1
                  End (*If*);
                If (ObClass = Shield) And Magic Then
                  Begin
                    Writev (Str1, ' (+', Abs(ShPlus): 0, ')');
                    Str := Str + Str1
                  End (*If*);
                If (ObClass = Armor) And Magic Then
                  Begin
                    Writev (Str1, ' (+', Abs(ArmPlus): 0, ')');
                    Str := Str + Str1
                  End (*If*);
                If ObClass = Treasure Then
                  Begin
                    Writev (Str1, ' (Value: ', Price: 0, ')');
                    Str := Str + Str1
                  End (*If*)
              End (*If*)
          End (*With*)
      End (*PrintObj*);
    
    Procedure ObjDisplay (Object: ObjectPoint);
    
      Var
        TObj : ObjectPoint;
        
      Begin
        PrintObj (Object ^, False, True, B1);
        B1 := '0' + B1 + ', ';
        With Object ^ Do
          Begin
            If Carry Then
              B1 := B1 + 'carryable, ';
            Writev (B2, Weight: 0, ' lbs, ', Price: 0, ' shillings.');
            B1 := B1 + B2;
            Qout (Term, B1);
            If (DescRec > 0) And (ObClass <> Scroll)
            Then
              Begin
                Writev (B1, '0DR=',DescRec: 0, ', DI=', DescCode: 0, '.');
                Qout (Term, B1);
                B1 := '0Descrp: ';
                PrintDesc (DescRec, DescCode, 0, False, B1, B2);
                Qout (Term, B2)
              End (*If*);
            Pb (Magic, B1);
            Pb (Permanent, B2);
            B1 := '0Magic=' + B1 + ', Permanent=' + B2 + ', Invisible=';
            Pb (Invisible, B2);
            B1 := B1 + B2 + '.';
            Qout (Term, B1);
            Case ObClass of
              Portal:
                Begin
                  Writev (B1, '0Portal to room ', ToWhere: 0, '.');
                  Qout (Term, B1)
                End;
              Treasure:
                Qout (Term, '0Treasure.');
              Weap:
                Begin
                  Writev (B1, '0Offensive weapon: ', MinHP: 0, '-', MaxHP: 0,
                          ' HP, ', Strikes: 0, ' strikes left.');
                  Qout (Term, B1);
                  Case WeapType of
                    Sharp:
                      B1 := '0Sharp';
                    Thrust:
                      B1 := '0Thrust';
                    Blunt:
                      B1 := '0Blunt';
                    Long:
                      B1 := '0Long'
                  End (*WeapType*);
                  B1 := B1 + ' class weapon.';
                  Qout (Term, B1);
                  Writev (B1, '0+ ', WeaPlus: 0, ' to hit.');
                  Qout (Term, B1)
                End (*Weap*);
              Shield:
                Begin
                  Writev (B1, '0Shield: + ', ShPlus: 0, ' protection, ',
                          ShHits: 0, ' hits left.');
                  Qout (Term, B1)
                End;
              Armor:
                Begin
                  Writev (B1, '0Armor: + ', ArmPlus: 0, ' protection, ',
                          ArmHits: 0, ' hits left.');
                  Qout (Term, B1)
                End;
              Coins:
                Begin
                  Writev (B1, '0Money, value multiplier:  X', Multiplier: 0);
                  Qout (Term, B1)
                End;
              Scroll:
                Begin
                  Ps (SpellList [Spell], B1);
                  B1 := '0Scroll, Spell = ' + B1;
                  Qout (Term, B1)
                End;
              Chest:
                Begin
                  Writev (B1, '0Container, Objects =', NumInside: 0, ' Trap=',
                          Trap: 0);
                  Qout (Term, B1);
                  Writev (B1, '0Lock type = ', Locked: 0);
                  Qout (Term, B1);
                  If ObjectTail <> NIL
                  Then
                    Begin
                      TObj := ObjectTail;
                      Qout (Term, '0Items inside:');
                      While TObj <> NIL Do
                        Begin
                          PrintObj (TObj ^, False, False, B1);
                          B1 := '0   ' + B1;
                          Qout (Term, B1);
                          TObj := TObj ^.Next
                        End (*While*)
                    End (*If*)
                End (*Chest*);
              Door:
                Begin
                  Writev (B1, '0Door, portal to room ', DToWhere: 0,
                          '.  Door trap=', DTrap: 0);
                  Qout (Term, B1);
                  Writev (B1, '0DLock type=', DLocked: 0);
                  Qout (Term, B1)
                End (*Door*);
              MagDevice:
                Begin
                  Ps (SpellList [Spell], B1);
                  B1 := '0Magical device, spell = ' + B1;
                  Qout (Term, B1);
                  Writev (B1, '0Number of charges = ', NumCharges: 0);
                  Qout (Term, B1)
                End (*MagDevice*);
              Teleport:
                Begin
                  Writev (B1, '0Teleport device, from room ', TActiveRm: 0,
                          ' to room ', ToWhere: 0, '.');
                  Qout (Term, B1)
                End;
              Keys:
                Begin
                  Writev (B1, '0Keys, unlock type=', Unlock: 0);
                  Qout (Term, B1)
                End;
              Card:
                Qout (Term, '0Cards, teleport to player.');
              Misc:
                Qout (Term, '0Miscellaneous object.')
            End (*Case*)
          End (*With*)
      End (*ObjDisplay*);
    
    Function FindObject (Var Word: Alfa; Num: Integer; ObjectTail:
                         ObjectPoint): ObjectPoint;
    (* FindObject returns the matching object to *Word* in the list *)
    
      Var
        Object: ObjectPoint;
        I, NumMatch, Count, Index: Integer;
        NameList: NameTList;
        Name: Alfa;
    
      Procedure Ld (Name: String; Var Entry: Alfa);
      
        Var
          ILoop: Integer;
        
        Begin
          Name := Name + '  ';
          ILoop := 1;
          Repeat
            Entry[ILoop] := Name[ILoop];
            ILoop := ILoop + 1
          Until (ILoop > 10) Or (ILoop > (Length (Name) - 1)) Or
                (Name[ILoop] = ',')
        End (*Ld*);
      
      Begin
        CapAlfa (Word);
        Count := 0;
        Object := ObjectTail;
        While (Object <> NIL) And (Count < MaxNames) Do
          Begin
            Count := Count + 1;
            NameList[Count] := Blanks;
            Ld (Object ^.Name, NameList[Count]);
            CapAlfa (NameList[Count]);
            Object := Object ^.Next
          End (*While*);
        If Count >= MaxNames
        Then
          Qout (Term, '0 Mil30 - Object table overflow');
        Index := WordMatch (Word, Count, NameList);
        If Index <= 0
        Then
          Object := NIL
        Else
          Begin
            Object := ObjectTail;
            For I := 1 to Index - 1 Do
              Object := Object ^.Next;
            If Num > 1
            Then
              Begin
                Name := NameList [Index];
                I := Index + 1;
                NumMatch := 1;
                While (NumMatch < Num) And (I <= Count) Do
                  Begin
                    Object := Object ^.Next;
                    If NameList[I] = Name Then
                      NumMatch := NumMatch + 1;
                    I := I + 1
                  End (*While*);
                If (I > Count) And (NumMatch < Num) Then
                  Object := NIL
              End (*If*)
          End (*Else*);
        FindObject := Object
      End (*FindObject*);
