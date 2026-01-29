unit GfxBuf;

{$G+}

interface

uses crt, gfx;

type 
  TBuffer = array[0..(SCREEN_WIDTH * SCREEN_HEIGHT)-1] of byte;

var 
  Buffer: ^TBuffer;

procedure InitBuffer;
procedure DoneBuffer;
procedure ClearBuffer(color: byte); 
procedure FlipBuffer; 
procedure FlipRect(x, y, w, h: integer);


implementation

procedure InitBuffer;
begin
  GetMem(Buffer, sizeof(TBuffer));
  SetScreenTarget(Buffer);
  ClearBuffer(0);
end;

procedure DoneBuffer;
begin
  UseHardwareScreen;
  if Buffer <> nil then
    FreeMem(Buffer, sizeof(TBuffer));
end;

procedure ClearBuffer(color: byte); assembler;
asm
  push  ds
  push  es
  cld
  les   di, ScreenTarget
  mov   al, color
  mov   ah, al
  mov   cx, (SCREEN_WIDTH * SCREEN_HEIGHT) / 2
  rep   stosw
  pop   es
  pop   ds
end;

procedure FlipBuffer; assembler;
asm
  push  ds
  push  es
  mov   ax, $A000
  mov   es, ax
  xor   di, di
  lds   si, Buffer
  mov   cx, (SCREEN_WIDTH * SCREEN_HEIGHT) / 2
  rep   movsw
  pop   es
  pop   ds
end;

procedure FlipRect(x, y, w, h: integer); assembler;
asm
  push  ds
  push  es

  mov   ax, SCREEN
  mov   es, ax

  lds   si, Buffer  
  mov   ax, [y]
  mov   dx, ax
  shl   ax, 8
  shl   dx, 6
  add   ax, dx
  add   ax, [x]

  add   si, ax
  mov   di, ax

  @loop:
  mov   cx, [w]
  rep   movsb

  add   si, 320
  sub   si, [w]
  add   di, 320
  sub   di, [w]
  dec   [h] 
  jnz   @loop

  pop   es
  pop   ds
end;

end.