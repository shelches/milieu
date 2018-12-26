
Type
  Var256 = Varying [256] of Char;

Var
  B1, B2, C1: Var256;

Procedure QAss (Mbx: Var256; Var Chn: Integer); Extern;
Procedure QCre; Extern;
Procedure QDea (Chn: Integer); Extern;
Procedure QRea (Var Str: Var256; Var Chn: Integer); Extern;
Procedure QOut (Chn: Integer; Str: Var256); Extern;
