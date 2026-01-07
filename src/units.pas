program Units;

{$G+}

uses crt, graphics;

begin

  SetVideoMode($13);
  repeat

    SetPixel(random(SCREEN_WIDTH), random(SCREEN_HEIGHT), random (256));

  until KeyPressed;

  SetVideoMode($03);

end.
