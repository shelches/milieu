program dbman (input, output);

    Type
      EntryType = (XInit, XName, XCmd, XEdit, XPassword, XNewPW, XChangePW,
                   XNewClass, XSex, XStats, XNotice, XDead, XNews, XSell,
                   XRepair, XWish, XSpell, XSure, XParley, XSkill, XDesc,
                   XRes1, XRes2, XRes3);
      Alfa      = Packed Array [1 .. 10] of Char;
      WInt      = 0 .. 65535;
      StatusType= (SInit, SLogin, SNormal);
      ChType    = (Fighter, Thief, MagicUser, DM, Cleric, Paladin,
                   Ranger, Barbarian);
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

    Const
      SavedItems = 7;

    Type
      FourBits  = 0..15;
      ObjRec = Packed Array [0 .. SavedItems] of ObjectType;
      MonRec = Packed Array [0 .. SavedItems] of MonsterType;
      DataRec   = Packed Record
                    Num     : WInt;
                    Room    : RmCodeType;
                    Case DataType : FourBits of
                      0: (*Object*)
                       (Objs : ObjRec);
                      1, 2, 3, 4, 5, 6, 7: (*Container*)
                       (CObjs: ObjRec);
                      8, 9, 10, 11, 12, 13, 14:
                        (MObjs: ObjRec);
                      15: (*Monster*)
                       (Mons : MonRec)
                  End (*DataRec*);
      DataKey   = Packed Record
                    Room    : RmCodeType;
                    DataType: FourBits
                  End (*DataKey*);
    Var
      DataBase : File of DataRec;

  begin
    open (database, file_name := 'EDATABAS', history := old);
    reset (database);
    while not eof (database) do
      begin
        with database ^ do
          writeln (num, room, datatype);
        get (database)
      end (*while*);
    close (database)
  end.
