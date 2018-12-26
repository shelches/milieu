
    Const
      Blanks    = '          ';
      MaxNames  = 40;
      MaxBufLen = 256;
      StrPerSeg = 10;
      CmdListLen= 113;
    
    Type
      EntryType = (XInit, XName, XCmd, XEdit, XPassword, XNewPW, XChangePW,
                   XNewClass, XSex, XStats, XNotice, XDead, XNews, XSell,
                   XRepair, XWish, XSpell, XSure, XParley, XSkill, XDesc,
                   XRes1, XRes2, XRes3);
      Alfa      = Packed Array [1 .. 10] of Char;
      NameTList = Array [1 .. MaxNames] of Alfa;
      BufType   = Packed Array [1 .. MaxBufLen] of Char;
      LenBufType= 0 .. MaxBufLen;
      StringSeg = Packed Array [1 .. StrPerSeg] of String[80];
      SegText   = File of StringSeg;
      CmdListType= Packed Array [1 .. CmdListLen] of Alfa;
      CmdNumType= Packed Array [1 .. CmdListLen] of 0 .. 127;
      Ch2       = Packed Array [1 .. 2] of Char;
      WInt      = integer;
      TermIDType= Packed Array [1 .. 20] of WInt;
      NumType   = Packed Array [0 .. 20] of string[11];
      Str80     = string[80];

    Var
      EFile     : Text;
      Term      : WInt;
      Seed1     : Integer;
      Seed2     : Integer;
      LenBuf    : LenBufType;
      Loc       : LenBufType;
      CurrentRec: Integer;
      NumRecs   : Integer;
      Buffer    : BufType;
      CmdList   : CmdListType;
      CmdNum    : CmdNumType;
      EDesc     : SegText;
      ILoop     : Integer;
      TermList  : TermIDType;
      NTh       : NumType;
      NumString : NumType;
      Aborted   : Boolean;
      Pid       : Integer;
      NoPrompt  : Boolean;
      NumRun    : Integer;
      Today     : Integer;

    Function  Pos (Ch: Char; Str: Str80): Integer;

      Var
        ILoop: Integer;
        XPos: Integer;

      Begin
        XPos := 0;
        ILoop := 1;
        While (ILoop <= Length (Str)) And (XPos = 0) Do
          Begin
            If Str [ILoop] = Ch
            Then
              XPos := ILoop;
            ILoop := ILoop + 1
          End;
        Pos := XPos
      End;

    Procedure InitCmds;
    
      Var
        ILoop: Integer;
        
      Procedure AddCmd (Cmd: Alfa; Num: Integer);
      
        Begin
          CmdList [ILoop] := Cmd;
          CmdNum [ILoop] := Num;
          ILoop := ILoop + 1
        End (*AddCmd*);
      
      Begin
        ILoop := 1;
        AddCmd ('*ABORT    ', 21);
        AddCmd ('*AUTO     ', 87);
        AddCmd ('*CHANGENAM', 58);
        AddCmd ('*CLOSE    ', 18);
        AddCmd ('*DAYFILE  ', 80);
        AddCmd ('*DELETENEW', 53);
        AddCmd ('*EDIT     ', 16);
        AddCmd ('*INVISIBLE', 30);
        AddCmd ('*MONSPEED ', 54);
        AddCmd ('*NEWS     ', 52);
        AddCmd ('*NONEXISTA', 83);
        AddCmd ('*NOTICE   ', 47);
        AddCmd ('*OFF      ', 82);
        AddCmd ('*OPEN     ', 19);
        AddCmd ('*PANIC    ', 27);
        AddCmd ('*PURGEDEAT', 50);
        AddCmd ('*SAY      ', 36);
        AddCmd ('*SEND     ', 38);
        AddCmd ('*TEST     ', 51);
        AddCmd ('*UPDATE   ', 23);
        AddCmd ('*YELL     ', 37);
        AddCmd ('ACCEPT    ', 61);
        AddCmd ('APPEAL    ', 45);
        AddCmd ('ATTACK    ', 11);
        AddCmd ('BACKSTAB  ', 72);
        AddCmd ('BLOCK     ', 76);
        AddCmd ('BREAK     ', 70);
        AddCmd ('BRIEF     ', 25);
        AddCmd ('BUY       ', 46);
        AddCmd ('CAST      ', 44);
        AddCmd ('CATALOG   ', 48);
        AddCmd ('CHANGEPW  ', 59);
        AddCmd ('CIRCLE    ', 86);
        AddCmd ('CLIMB     ', 9);
        AddCmd ('CLOCK     ', 26);
        AddCmd ('CLOSE     ', 66);
        AddCmd ('CONDITION ', 88);
        AddCmd ('D         ', 6);
        AddCmd ('DOWN      ', 6);
        AddCmd ('DRAW      ', 10);
        AddCmd ('DRINK     ', 10);
        AddCmd ('DROP      ', 8);
        AddCmd ('E         ', 3);
        AddCmd ('EAST      ', 3);
        AddCmd ('ECHO      ', 34);
        AddCmd ('END       ', 17);
        AddCmd ('ENTER     ', 9);
        AddCmd ('EXAMINE   ', 24);
        AddCmd ('EXIT      ', 7);
        AddCmd ('EXPERIENCE', 79);
        AddCmd ('FEINT     ', 85);
        AddCmd ('FOLLOW    ', 55);
        AddCmd ('GET       ', 63);
        AddCmd ('GO        ', 9);
        AddCmd ('HELP      ', 28);
        AddCmd ('HIDE      ', 73);
        AddCmd ('HINT      ', 32);
        AddCmd ('HIT       ', 11);
        AddCmd ('HOLD      ', 10);
        AddCmd ('IDENTIFY  ', 31);
        AddCmd ('INFORMATIO', 22);
        AddCmd ('INVENTORY ', 41);
        AddCmd ('KILL      ', 11);
        AddCmd ('LEAVE     ', 7);
        AddCmd ('LOCK      ', 67);
        AddCmd ('LOOK      ', 24);
        AddCmd ('LOSE      ', 56);
        AddCmd ('N         ', 1);
        AddCmd ('NORTH     ', 1);
        AddCmd ('NUSERS    ', 20);
        AddCmd ('OFFER     ', 60);
        AddCmd ('OPEN      ', 65);
        AddCmd ('OUT       ', 7);
        AddCmd ('PACK      ', 29);
        AddCmd ('PANIC     ', 78);
        AddCmd ('PARLEY    ', 81);
        AddCmd ('PARRY     ', 42);
        AddCmd ('PAWN      ', 49);
        AddCmd ('PICKLOCK  ', 69);
        AddCmd ('PUT       ', 8);
        AddCmd ('QUIT      ', 17);
        AddCmd ('READ      ', 64);
        AddCmd ('REPAIR    ', 57);
        AddCmd ('RETURN    ', 29);
        AddCmd ('RUN       ', 78);
        AddCmd ('S         ', 2);
        AddCmd ('SAVE      ', 40);
        AddCmd ('SAY       ', 12);
        AddCmd ('SEARCH    ', 74);
        AddCmd ('SELL      ', 49);
        AddCmd ('SEND      ', 14);
        AddCmd ('SMASH     ', 70);
        AddCmd ('SOUTH     ', 2);
        AddCmd ('STATUS    ', 33);
        AddCmd ('STEAL     ', 84);
        AddCmd ('STRIKE    ', 11);
        AddCmd ('SUICIDE   ', 39);
        AddCmd ('TAKE      ', 63);
        AddCmd ('TALK      ', 81);
        AddCmd ('THRUST    ', 43);
        AddCmd ('TRACK     ', 71);
        AddCmd ('TRAIN     ', 75);
        AddCmd ('TURN      ', 62);
        AddCmd ('U         ', 5);
        AddCmd ('UNLOCK    ', 68);
        AddCmd ('UP        ', 5);
        AddCmd ('USE       ', 10);
        AddCmd ('USERS     ', 35);
        AddCmd ('W         ', 4);
        AddCmd ('WEAR      ', 10);
        AddCmd ('WEST      ', 4);
        AddCmd ('WIELD     ', 10);
        AddCmd ('YELL      ', 13);
        Nth [ 0] := 'zeroth';
        Nth [ 1] := 'first';
        Nth [ 2] := 'second';
        Nth [ 3] := 'third';
        Nth [ 4] := 'fourth';
        Nth [ 5] := 'fifth';
        Nth [ 6] := 'sixth';
        Nth [ 7] := 'seventh';
        Nth [ 8] := 'eighth';
        Nth [ 9] := 'ninth';
        Nth [10] := 'tenth';
        Nth [11] := 'eleventh';
        Nth [12] := 'twelfth';
        Nth [13] := 'thirteenth';
        Nth [14] := 'fourteenth';
        Nth [15] := 'fifteenth';
        Nth [16] := 'sixteenth';
        Nth [17] := 'seventeenth';
        Nth [18] := 'eighteenth';
        Nth [19] := 'ninteenth';
        Nth [20] := 'twentieth';
        NumString [ 0] := 'zero';
        NumString [ 1] := 'one';
        NumString [ 2] := 'two';
        NumString [ 3] := 'three';
        NumString [ 4] := 'four';
        NumString [ 5] := 'five';
        NumString [ 6] := 'six';
        NumString [ 7] := 'seven';
        NumString [ 8] := 'eight';
        NumString [ 9] := 'nine';
        NumString [10] := 'ten';
        NumString [11] := 'eleven';
        NumString [12] := 'twelve';
        NumString [13] := 'thirteen';
        NumString [14] := 'fourteen';
        NumString [15] := 'fifteen';
        NumString [16] := 'sixteen';
        NumString [17] := 'seventeen';
        NumString [18] := 'eighteen';
        NumString [19] := 'ninteen';
        NumString [20] := 'twenty';
      End (*InitCmds*);
        
    Procedure Abort (Error: Str80);
    
      Begin
        WriteLn (Error);
        Goto 990
      End (*Abort*);
      
    Function RealTime: Integer;
    
      Type
        Quad = Packed Array [0..1] of Integer;

      Var
        DayNum, DayTime: Integer;
        UserTime: Quad;

      Procedure Sys$GetTim (Var A: Quad); Extern;

      Procedure Lib$Day (Var A: Integer; Var B: Quad; Var C: Integer); Extern;

      Begin
        Sys$GetTim (UserTime);
        Lib$Day (DayNum, UserTime, DayTime);
        RealTime := (DayNum - 46000) * 86400 + (DayTime DIV 100)
      End (*RealTime*);

    Function Min (A, B: Integer): Integer;
    
      Begin
        If A < B Then Min := A Else Min := B
      End (*Min*);
    
    Function Max (A, B: Integer): Integer;
      
      Begin
        If A > B Then Max := A Else Max := B
      End (*Max*);
    
    Procedure SetRandom (A, B: Integer);

      Begin
        Seed1 := Abs (A);
        Seed2 := Abs (B)
      End (*SetRandom*);
      
    Function Rnd (X: Integer): Integer;
    
      Var
        Temp1, Temp2, HA: Integer;
      
      Begin
        Temp1 := Seed1 Div 2;
        Temp2 := Seed2 Div 2;
        If (Temp1 + Temp2) >= 16383 Then
          HA := Temp1 + Temp2 - 16383
        Else
          HA := Temp1 + Temp2;
        Seed1 := Seed2;
        Seed2 := HA * 2;
        Rnd := Trunc (Seed2 / 32768.0 * X) + 1
      End (*Rnd*);
    
    Function SubSet (Part, Full: Alfa): Boolean;
    
      Var
        I: Integer;
      
      Begin
        SubSet := True;
        I := 1;
        While (I >= 1) And (I <= 10) Do
          If Part[I] = Full[I]
          Then
            I := I + 1
          Else
            I := - I;
        If I < 0
        Then
          SubSet := (Part [- I] = ' ')
      End (*SubSet*);
      
    Procedure Ps (Word: Alfa; Var Str: Var256);
    
      Var
        ILoop: Integer;
      
      Begin
        ILoop := 10;
        While (Word [ILoop] = ' ') And (ILoop > 1) Do
          ILoop := ILoop - 1;
        Writev (Str, Word: ILoop)
      End (*Ps*);
    
    Procedure Pb (X: Boolean; Var Str: Var256);
    
      Begin
        If X Then
          Str := ' True'
        Else
          Str := 'False'
      End (*Pb*);
    
    Procedure Pn (N: Integer; Var Str: Var256);

      Begin
        If (N >= 0) And (N <= 20)
        Then
          Writev (Str, NumString [N], ' ')
        Else
          Writev (Str, N: 0, ' ')
      End (*PN*);
      
    Procedure PNth (N: Integer; Var Str: Var256);
    
      Begin
        If (N >= 0) And (N <= 20)
        Then
          Writev (Str, NTh [N], ' ')
        Else
          Begin
            Writev (Str, N: 0);
            Case N Mod 10 of
              0, 4, 5, 6, 7, 8, 9:
                Str := Str + 'th ';
              1:
                Str := Str + 'st ';
              2:
                Str := Str + 'nd ';
              3:
                Str := Str + 'rd '
            End (*Case*)
          End (*Else*)
      End (*PNth*);
      
    Function Cap (Ch: Char): Char;
    
      Begin
        If Ch in ['a' .. 'z']
        Then
          Cap := Chr(Ord(Ch) - 32)
        Else
          Cap := Ch
      End (*Cap*);
    
    Procedure CapAlfa (Var A: Alfa);
    
      Var
        ILoop: Integer;
      
      Begin
        For ILoop := 1 to 10 Do
          A [ILoop] := Cap (A [ILoop])
      End (*CapAlfa*);
      
    Procedure GetWord (Var Word: Alfa;
                       Var Num: Integer;
                       Var Buffer: BufType;
                       Var LenBuf: LenBufType;
                       Var Loc: Integer);
      
      Var
        ILoop, Digit: Integer;
        LbSign: Boolean;
        TWord: Alfa;
      
      Begin
        Word := Blanks;
        Num := 0;
        LbSign := False;
        If Buffer[Loc] = ','
        Then
          Loc := Loc + 1;
        While (Buffer[Loc] = ' ') And (Loc <= LenBuf) Do
          Loc := Loc + 1;
        If Loc <= LenBuf
        Then
          Begin
            ILoop := 1;
            Repeat
              If Buffer[Loc] = '#' Then
                LbSign := True;
              If (ILoop <= 10) And Not LbSign Then
                Word[ILoop] := Buffer[Loc];
              Loc := Loc + 1;
              ILoop := ILoop + 1
            Until (Buffer[Loc] in [' ', ',']) or (Loc > LenBuf);
            If Word[1] in ['0' .. '9', '-'] Then
              Word := Blanks;
            ILoop := Loc - 1;
            Digit := 1;
            While ILoop > 0 Do
              If Buffer[ILoop] in ['0' .. '9', '-']
              Then
                Begin
                  If Buffer[ILoop] = '-'
                  Then
                    Num := - Num
                  Else
                    Begin
                      Num := Num + (Ord(Buffer[ILoop]) - Ord('0')) * Digit;
                      Digit := Digit * 10
                    End (*Else*);
                  ILoop := ILoop - 1
                End (*If*)
              Else
                ILoop := 0;
            TWord := Word;
            CapAlfa (TWord);
            If (TWord = 'AT        ') or (TWord = 'FOR       ') or
               (TWord = 'FROM      ') or (TWord = 'IN        ') or
               (TWord = 'OF        ') or (TWord = 'ON        ') or
               (TWord = 'SPELL     ') or (TWord = 'TO        ') or
               (TWord = 'THE       ') or (TWord = 'WITH      ')
            Then
              GetWord (Word, Num, Buffer, LenBuf, Loc)
          End (*If*)
      End (*GetWord*);
    
    Procedure DoInput (Var Buffer: BufType; Var LenBuf: LenBufType);
    
      Var
        ILoop: Integer;
      
      Begin
        Loc := 1;
        LenBuf := Min (256, Length (C1) - 1);
        If LenBuf > 0 
        Then
          For ILoop := 1 to LenBuf Do
            Buffer [ILoop] := C1 [ILoop + 1]
      End (*DoInput*);

    Function BinaryMatch (Var Word: Alfa; Count: Integer;
                          Var NameList: CmdListType): Integer;
      
      Var
        Lower, Upper, Pos: Integer;
      
      Begin
        If Word = Blanks
        Then
          BinaryMatch := 0
        Else
          Begin
            Lower := 1;
            Upper := Count;
            Repeat
              Pos := (Lower + Upper) Div 2;
              If NameList [Pos] <= Word Then
                Lower := Pos + 1;
              If NameList [Pos] >= Word Then
                Upper := Pos - 1
            Until Lower > Upper;
            If NameList [Pos] = Word
            Then
              BinaryMatch := Pos
            Else
              If Pos = CmdListLen
              Then
                BinaryMatch := 0
              Else
                Begin
                  If Not SubSet (Word, NameList [Pos]) Then
                    Pos := Pos + 1;
                  BinaryMatch := Pos;
                  If Not SubSet (Word, NameList [Pos])
                  Then
                    BinaryMatch := 0
                  Else
                    If Pos < CmdListLen Then
                      If SubSet (Word, NameList [Pos + 1])
                      Then
                        Begin
                          Ps (Word, B1);
                          B1 := '0' + B1 + ' is not unique.';
                          QOut (Term, B1);
                          BinaryMatch := -1
                        End (*If*)
                End (*Else*)
          End (*Else*)
      End (*BinaryMatch*);
                
    Function WordMatch (Var Word: Alfa;
                            Count: Integer;
                        Var NameList: NameTList): Integer;
      
      Var
        ILoop, JLoop: Integer;
        Found: Boolean;
      
      Begin
        If (Count < 0) or (Count > MaxNames) Then
          QOut (Term, '0 Mil03 - Bad parse count!');
        If (Count = 0) or (Word = Blanks)
        Then
          WordMatch := 0
        Else
          Begin
            ILoop := 0;
            Repeat
              ILoop := ILoop + 1
            Until (NameList[ILoop] = Word) or (ILoop = Count);
            If NameList[ILoop] = Word
            Then
              WordMatch := ILoop
            Else
              Begin
                ILoop := 0;
                Repeat
                  ILoop := ILoop + 1;
                  Found := SubSet (Word, NameList[ILoop])
                Until Found or (ILoop = Count);
                If Not Found
                Then
                  WordMatch := 0
                Else
                  Begin
                    JLoop := ILoop;
                    Repeat
                      JLoop := JLoop + 1;
                      Found := SubSet (Word, NameList[JLoop]);
                      If Found Then
                        Found := (NameList[ILoop] <> NameList[JLoop])
                    Until Found or (JLoop >= Count);
                    If Found
                    Then
                      Begin
                        Ps (Word, B1);
                        B1 := '0' + B1 + ' is not unique.';
                        QOut (Term, B1);
                        WordMatch := -1
                      End (*If*)
                    Else
                      WordMatch := ILoop
                  End (*Else*)
              End (*Else*)
          End (*Else*)
      End (*WordMatch*);
    
    Procedure Punctuate (Num, Total: Integer; Var Str: Var256);
    
      Begin
        If Num <> Total Then
          If Total - Num >= 2
          Then
            Str := Str + ', '
          Else
            Str := Str + ' and ';
        If (Num Mod 3 = 0) And (Num < Total)
        Then
          Begin
            QOut (Term, Str);
            Str := '0'
          End (*If*)
      End (*Punctuate*);
    
    Procedure PrintDesc (Rec, Line, PhraseNum: Integer; Brief: Boolean;
                         Var Str1, Str2: Var256);

      Var
        Cont: Boolean;
        Str3: Var256;

      Procedure Pd (R, L, P: Integer; B: Boolean; Var C: Boolean;
                    Var V: Var256);

        Var
          NumPhrases, ILoop, LinePos: Integer;
          BrMark: Boolean;
          S: String;

        Begin
          BrMark := False;
          If Line > StrPerSeg Then
            Abort ('0 Mil72 - Bad description index');
          If Rec <> CurrentRec
          Then
            Begin
              Find (EDesc, Rec);
              CurrentRec := Rec
            End (*If*);
          S := Edesc ^[Line];
          If (Length (S) < 3) Or (Ufb (EDesc))
          Then
            S := '1//';
          LinePos := 1;
          NumPhrases := Min (9, Max (0, Ord (S[1]) - Ord ('0')));
          If PhraseNum = 0
          Then
            PhraseNum := Rnd (NumPhrases);
          For ILoop := 1 to PhraseNum Do
            Repeat
              LinePos := LinePos + 1
            Until S [LinePos] = '/';
          S [LinePos] := ' ';
          V := '';
          C := False;
          While (LinePos <= Length (S)) And (S [LinePos] <> '/') Do
            Begin
              LinePos := LinePos + 1;
              If S [LinePos] <> '/'
              Then
                If S [LinePos] = '#'
                Then
                  BrMark := Not BrMark
                Else
                  If Not (BrMark and Brief)
                  Then
                    If S [LinePos] = '+'
                    Then
                      Begin
                        C := True;
                        S [LinePos] := '/'
                      End (*If*)
                    Else
                      V := V + S [LinePos]
            End (*While*)
        End (*Pd*);

      Begin
        Pd (Rec, Line, PhraseNum, Brief, Cont, Str3);
        Str2 := Str1 + Str3;
        While Cont Do
          Begin
            QOut (Term, Str2);
            Line := Line + 1;
            Pd (Rec, Line, PhraseNum, Brief, Cont, Str3);
            Str2 := '0' + Str3
          End (*While*)
      End (*PrintDesc*);
