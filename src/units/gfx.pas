(*
  gfx.pas

  Graphics routines for Mode 13h (320x200x256 colors)
*)
unit Gfx;


{$G+}

interface

uses Dos;

const
  SCREEN = $A000;
  SCREEN_WIDTH = 320;
  SCREEN_HEIGHT = 200;





procedure SetVideoMode(mode : word);
procedure SetMCGA;
procedure SetTextMode;
procedure SetPixel(x, y: integer; color: byte);
procedure ClearScreen(color : byte);
procedure WaitRetrace;



implementation

uses
  crt;



procedure SetVideoMode(mode: word); Assembler;
asm
  mov   ax, mode
  int   10h
end;

procedure SetMCGA;
begin
  SetVideoMode($13);
end;

procedure SetText;
begin
  SetVideoMode($03);
end;

procedure SetTextMode; assembler;
asm
  mov   ax, $03
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


procedure ClearScreen(color : byte); assembler;
asm
  mov   ax, SCREEN
  mov   es, ax
  mov   di, 0
  mov   al, color
  mov   ah, al
  mov   cx, 32000
  rep   stosw
end;

procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

end.