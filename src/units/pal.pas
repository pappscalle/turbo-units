unit Pal;

{$G+}

interface

const 
  NUM_COLORS = 256;
  PALETTE_SIZE = 3 * NUM_COLORS;    

type 
  RGB = record
    r, g, b: byte;
  end;
    
  Palette = array[0..NUM_COLORS - 1] of RGB;  

procedure SetColor(color: byte; r, g, b : byte);
procedure SetPalette(pal : Palette);
procedure SetPartialPalette(pal : Palette; start : byte; num : byte);

implementation

procedure SetColor(color: byte; r, g, b : byte); assembler;
asm
  mov   dx, $3C8
  xor   ax, ax
  mov   al, color
  out   dx, al
  inc   dx
  mov   al, r
  out   dx, al
  mov   al, g
  out   dx, al
  mov   al, b
  out   dx, al
end;

procedure SetPalette(pal : Palette); assembler;
asm
  push  ds
  lds   si, pal
  mov   dx, 03C8h
  xor   ax, ax
  out   dx, al
  inc   dx
  mov   cx, PALETTE_SIZE
  rep   outsb
  pop   ds
end;

procedure SetPartialPalette(pal : Palette; start: byte; num: byte); assembler;
asm
  push  ds
  lds   si, pal
  mov   dx, 03C8h
  mov   ax, WORD(start)
  out   dx, al
  inc   dx
  mov   cx, WORD(num)
  mov   bx, cx
  add   bx, bx
  add   cx, bx       {CX = num * 3}
  rep   outsb
  pop   ds
end;

end.