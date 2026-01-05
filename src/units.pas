program Units;

{$G+}

uses crt;

const 
  SCREEN = $A000;
  SCREEN_WIDTH = 320;
  SCREEN_HEIGHT = 200;

procedure SetVideoMode(mode: word); assembler;
asm
  mov   ax, mode
  int   10h
end;


procedure SetPixel(x, y: integer; color: byte); assembler;
asm
  mov   ax, SCREEN
  mov   es, ax
  mov   di, y
  mov   dx, di
  shl   di, 2
  add   di, dx
  shl   di, 6
  add   di, x
  mov   al, color
  stosb
end;

begin

  SetVideoMode($13);
  repeat

    SetPixel(random(SCREEN_WIDTH), random(SCREEN_HEIGHT), random (256));

  until KeyPressed;

  SetVideoMode($03);

end.
