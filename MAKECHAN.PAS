Program MakeChant (Input, Output);

  %Include 'Milio'
  
  Var
    I: Integer;
    Len: Integer;
    XHash: Integer;
    Chant: String;
  
  Begin
    Repeat
      Write ('Chant? ');
      ReadLn (Chant);
      XHash := 0;
      Len := 0;
      If Length (Chant) > 0
      Then
        Begin
          For I := 1 to Length (Chant) Do
            If Cap (Chant [I]) in ['A' .. 'Z']
            Then
              Begin
                Len := Len + 1;
                XHash := XHash + Ord (Cap (Chant [I])) - Ord ('A')
              End (*If*);
          WriteLn (Chant, ', length = ', Len: 0, ', hash = ', XHash: 0)
        End (*If*)
    Until Length (Chant) = 0
  End.
