
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

    Procedure OpenDataBase;
    
      Var
        Error: Integer;
        
      Begin
        Open (DataBase, File_Name := 'EDATABAS', History := Old,
              Access_Method := Keyed, Error := Continue);
        Error := Status (DataBase);
        If Error <> 0
        Then
          Abort ('0 Mil201 - Error opening database file.')
      End (*OpenDataBase*);
    
    Procedure CloseDataBase;

      Var
        Error: Integer;
        
      Begin
        Close (DataBase, Error := Continue);
        Error := Status (DataBase);
        If Error <> 0
        Then
          Abort ('0 Mil201 - Error closing database file.')
      End (*CloseDataBase*);

    Procedure DeleteUObj (Var Rm: RmCodeType);

      Var
        Key: DataKey;
        Error: Integer;
      
      Begin
        Key.Room := Rm;
        For ILoop := 0 To 7 Do
          Begin
            Key.DataType := ILoop;
            Findk (DataBase, 0, Key, eql, Error := Continue);
            Error := Status (DataBase);
            If Error = 0
            Then
              If Not Ufb(DataBase)
              Then
                Begin
                  Delete (DataBase, Error := Continue);
                  Error := Status (DataBase)
                End (*If*);
            If Error <> 0
            Then
              Abort ('0 Mil900 - Error deleting object from database.')
          End (*For*)
      End (*DeleteUObj*);

    Procedure DeleteMon (Var Rm: RmCodeType);

      Var
        Key: DataKey;
        Error: Integer;
      
      Begin
        Key.Room := Rm;
        For ILoop := 8 To 15 Do
          Begin
            Key.DataType := ILoop;
            Findk (DataBase, 0, Key, eql, Error := Continue);
            Error := Status (DataBase);
            If Error = 0
            Then
              If Not Ufb(DataBase)
              Then
                Begin
                  Delete (DataBase, Error := Continue);
                  Error := Status (DataBase)
                End (*If*);
            If Error <> 0
            Then
              Abort ('0 Mil901 - Error deleting monster from database.')
          End (*For*)
      End (*DeleteMon*);

    Procedure AddRec (Var Rec: DataRec);
    
      Var
        Key: DataKey;
        Error: Integer;
      
      Begin
        Key.Room := Rec.Room;
        Key.DataType := Rec.DataType;
        Findk (DataBase, 0, Key, eql, Error := Continue);
        Error := Status (DataBase);
        If Error = 0
        Then
          Begin
            DataBase ^ := Rec;
            If Ufb (DataBase)
            Then
              Put (DataBase, Error := Continue)
            Else
              Update (DataBase, Error := Continue);
            Error := Status (DataBase)
          End (*If*);
        If Error = 0
        Then
          Begin
            CloseDataBase;
            OpenDataBase
          End (*If*);
        If Error > 0
        Then
          Abort ('0 Mil202 - Error updating file.')
      End (*AddRec*);

    Procedure WriteUObj (Rm: RmCodeType; Object: ObjectPoint; Cnt: Integer);

      Var
        Pt: ObjectPoint;
        N: WInt;
        ContCount: Integer;
        Rec: DataRec;

      Begin
        Pt := Object;
        N := 0;
        ContCount := 1;
        With Rec Do
          Begin
            Room := Rm;
            DataType := Cnt;
            Pt := Object;
            While (Pt <> NIL) And (N <= SavedItems) Do
              Begin
                Objs [N] := Pt ^;
                If (Pt ^.ObClass = Chest) And (ContCount <= 7)
                Then
                  Begin
                    WriteUObj (Rm, Pt ^.ObjectTail, ContCount);
                    ContCount := ContCount + 1
                  End (*If*);
                N := N + 1;
                Pt := Pt ^.Next
              End (*While*);
            Num := N
          End (*With*);
        AddRec (Rec)
      End (*WriteUObj*);

    Procedure ReadUObj (Rm: RmCodeType; Var Object: ObjectPoint; Cnt: Integer);

      Var
        N: WInt;
        ContCount, Error: Integer;
        Pt, Pt2, Pt3: ObjectPoint;
        Rec: DataRec;
        Key: DataKey;

      Begin
        With Rec Do
          Begin
            Key.Room := Rm;
            Key.DataType := Cnt;
            Findk (DataBase, 0, Key, eql, Error := Continue);
            Error := Status (DataBase);
            If (Error = 0) And (Not Ufb (DataBase))
            Then
              Begin
                Rec := DataBase ^;
                New (Pt);
                Object := Pt;
                Pt ^ := Objs [0];
                Pt ^.Next := NIL;
                ContCount := 1;
                If Pt ^.ObClass = Chest
                Then
                  Begin
                    Pt3 := Pt ^.ObjectTail;
                    ReadUObj (Rm, Pt3, ContCount);
                    Pt ^.ObjectTail := Pt3;
                    ContCount := ContCount + 1
                  End (*If*);
                N := 2;
                ContCount := 1;
                While (N <= Num) Do
                  Begin
                    New (Pt2);
                    Pt ^.Next := Pt2;
                    Pt := Pt2;
                    Pt ^ := Objs [N - 1];
                    Pt ^.Next := NIL;
                    If (Pt ^.ObClass = Chest) And (ContCount <= 7)
                    Then
                      Begin
                        Pt3 := Pt ^.ObjectTail;
                        ReadUObj (Rm, Pt3, ContCount);
                        Pt ^.ObjectTail := Pt3;
                        ContCount := ContCount + 1
                      End (*If*);
                      N := N + 1
                    End (*While*)
              End (*If*)
            Else
              If Error = 0
              Then
                Object := NIL
              Else
                Abort ('0 Mil398 - Error reading objects')
          End (*With*)
      End (*ReadUObj*);
    
    Procedure WriteMon (Rm: RmCodeType; Monster: MonsterPoint);

      Var
        Pt: MonsterPoint;
        N: WInt;
        ObjCount: Integer;
        Rec: DataRec;

      Begin
        Pt := Monster;
        N := 0;
        ObjCount := 8;
        With Rec Do
          Begin
            Room := Rm;
            DataType := 15;
            Pt := Monster;
            While (Pt <> NIL) And (N <= SavedItems) Do
              Begin
                Mons [N] := Pt ^;
                If (Pt ^.ObjectTail <> NIL) And (ObjCount <= 14)
                Then
                  Begin
                    WriteUObj (Room, Pt ^.ObjectTail, ObjCount);
                    ObjCount := ObjCount + 1
                  End (*If*);
                N := N + 1;
                Pt := Pt ^.Next
              End (*While*);
            Num := N
          End (*With*);
        AddRec (Rec)
      End (*WriteMon*);

    Procedure ReadMon (Rm: RmCodeType; Var Monster: MonsterPoint);
    
      Var
        Error, ObjCount: Integer;
        N: WInt;
        Pt, Pt2: MonsterPoint;
        Pt3: ObjectPoint;
        Rec: DataRec;
        Key: DataKey;

      Begin
        With Rec Do
          Begin
            Key.Room := Rm;
            Key.DataType := 15;
            Findk (DataBase, 0, Key, eql, Error := Continue);
            Error := Status (DataBase);
            If (Error = 0) And (Not Ufb (DataBase))
            Then
              Begin
                Rec := DataBase ^;
                ObjCount := 8;
                New (Pt);
                Monster := Pt;
                Pt ^ := Mons [0];
                Pt ^.Next := NIL;
                Pt ^.DefPlayer := NIL;
                If Pt ^.ObjectTail <> NIL
                Then
                  Begin
                    Pt3 := Pt ^.ObjectTail;
                    ReadUObj (Room, Pt3, ObjCount);
                    Pt ^.ObjectTail := Pt3;
                    ObjCount := ObjCount + 1
                  End (*If*);
                N := 2;
                While (N <= Num) Do
                  Begin
                    New (Pt2);
                    Pt ^.Next := Pt2;
                    Pt := Pt2;
                    Pt ^ := Mons [N - 1];
                    Pt ^.Next := NIL;
                    Pt ^.DefPlayer := NIL;
                    If Pt ^.ObjectTail <> NIL
                    Then
                      Begin
                        Pt3 := Pt ^.ObjectTail;
                        ReadUObj (Room, Pt3, ObjCount);
                        Pt ^.ObjectTail := Pt3;
                        ObjCount := ObjCount + 1
                      End (*If*);
                    N := N + 1
                  End (*While*)
              End (*If*)
            Else
              If Error = 0
              Then
                Monster := NIL
              Else
                Abort ('0 Mil198 - Error reading monsters')
          End (*With*)
      End (*ReadMon*);
