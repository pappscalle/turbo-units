unit Graphics;

{$G+}

interface

uses Dos;

const
  SCREEN = $A000;
  SCREEN_WIDTH = 320;
  SCREEN_HEIGHT = 200;
  NUM_COLORS = 256;
  PALETTE_SIZE = 3 * NUM_COLORS;

type

  TEdge = array[0..SCREEN_HEIGHT-1] of integer;

  Point2D = record
    x,y : integer;
  end;

  RGB = record
    r, g, b: byte;
  end;

  Palette = array[0..NUM_COLORS - 1] of RGB;


procedure SetVideoMode(mode : word);
procedure SetMCGA;
procedure SetTextMode;
procedure SetColor(color: byte; r, g, b : byte);
procedure SetPalette(pal : Palette);
procedure SetPartialPalette(pal : Palette; start : byte; num : byte);
procedure SetPixel(x, y: integer; color: byte);
procedure ScreenOff;
procedure ScreenOn;
procedure ClearScreen(color : byte);
procedure WaitRetrace;
procedure Line(x1, y1, x2, y2 : integer; color : byte);
procedure HLine(x1, x2, y : integer; color : byte);
procedure VLine(x, y1, y2 : integer; color : byte);
procedure swap(var v1, v2: integer);
procedure swapPoints(var p1, p2: Point2D);
procedure ScanEdge(p1, p2 : Point2D; var  edge: TEdge);
procedure DrawFlatPolygon(p1, p2, p3 : Point2D; color: byte);
procedure DrawTriangle(x1, y1, x2, y2, x3, y3 : integer; color: byte);

function isFacing(a, b, c : Point2D) :  boolean;

function GetBIOSMillis: LongInt;
function GetCurrentTimeInMillis: LongInt;


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

procedure SetColor(color: byte; r, g, b : byte); assembler;
asm
  mov   dx, $3C8
  xor   ax, ax
  mov   al, [color]
  out   dx, al
  inc   dx
  mov   al, [r]
  out   dx, al
  mov   al, [g]
  out   dx, al
  mov   al, [b]
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

procedure ScreenOff; assembler;
asm
  cli
  mov	dx,$3C4
  mov	al,$01
  out	dx,al
  inc	dx
  in  al,dx
  or	al,$20
  out	dx,al
  sti
end;

procedure ScreenOn; assembler;
asm
  cli
  mov	dx,$3C4
  mov	al,$01
  out	dx,al
  inc	dx
  in	al,dx
  and	al,$DF
  out	dx,al
  sti
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

(*
  TODO:
  - assmebler
  - clipping

*)

procedure Line(x1, y1, x2, y2 : integer; color : byte);
var i, deltax, deltay, numpixels,
	d, dinc1, dinc2,
	x, xinc1, xinc2,
	y, yinc1, yinc2 : integer;
begin

  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  if deltax >= deltay then begin

	  numpixels := deltax + 1;
	  d := (2 * deltay) - deltax;
	  dinc1 := deltay shl 1;
	  dinc2 := (deltay - deltax) shl 1;
	  xinc1 := 1;
	  xinc2 := 1;
	  yinc1 := 0;
	  yinc2 := 1;

	end else begin

	  numpixels := deltay + 1;
	  d := (2 * deltax) - deltay;
	  dinc1 := deltax shl 1;
	  dinc2 := (deltax - deltay) shl 1;
	  xinc1 := 0;
	  xinc2 := 1;
	  yinc1 := 1;
	  yinc2 := 1;
	end;

  if x1 > x2 then begin
	  xinc1 := - xinc1;
	  xinc2 := - xinc2;
	end;

  if y1 > y2 then begin
	  yinc1 := - yinc1;
	  yinc2 := - yinc2;
	end;

  x := x1;
  y := y1;

  for i := 1 to numpixels do begin

	  SetPixel(x, y, color);
	  if d < 0 then	begin
		  d := d + dinc1;
		  x := x + xinc1;
		  y := y + yinc1;
		end else begin
		  d := d + dinc2;
		  x := x + xinc2;
		  y := y + yinc2;
		end;
	end;
end;

(*
TODO
- assembler
- clipping
*)

procedure HLine(x1, x2, y : integer; color : byte); assembler;
asm
  mov bx, [x1]
  mov cx, [x2]
  cmp bx, cx
  jl @draw
  xchg bx,cx
 @draw:
  mov ax, SCREEN
  mov es, ax
  mov ax, [y]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, bx
  mov al, [color]
  mov ah, al
  sub cx, bx
  shr cx, 1
  jnc @loop
  stosb
 @loop:
  rep stosw
end;

procedure VLine(x, y1, y2 : integer; color : byte); assembler;
asm
  mov bx, [y1]
  mov cx, [y2]
  cmp bx, cx
  jl  @draw
  xchg bx, cx
 @draw:
  mov ax, SCREEN
  mov es, ax
  mov ax, bx
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [x]
  sub cx, bx
  mov al, [color]
 @loop:
  stosb
  add di, SCREEN_WIDTH - 1
  dec cx
  jnz @loop
end;

procedure swap(var v1, v2: integer);
var
  tmp : integer;
begin
  tmp := v1;
  v1 := v2;
  v2 := tmp;
end;



procedure swapPoints(var p1, p2: Point2D);
var
  tmp : Point2D;
begin
  tmp := p1;
  p1 := p2;
  p2 := tmp;
end;


procedure ScanEdge(p1, p2 : Point2D; var  edge: TEdge);
var
  x, y : integer;
  dx, dy : integer;
  m: integer;
  start, stop : integer;
begin

  if p1.y > p2.y then begin
     swapPoints(p1, p2);
  end;

  dx :=  (p2.x - p1.x) shl 6;
  dy :=  (p2.y - p1.y);
  if (dy <> 0) then begin
    m := round(dx / dy);
  end else begin
    m := 0;
  end;

  x :=  p1.x shl 6;

  for y := p1.y to p2.y do begin
      edge[y] := x shr 6;
      x := x + m;
  end;

end;


function isFacing(a, b, c : Point2D) :  boolean;
begin
  isFacing := (c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y) >= 0;
end;

procedure DrawFlatPolygon(p1, p2, p3 : Point2D; color: byte);
var

  height : integer;

  y : integer;
  start, stop: integer;
  left, right : TEdge;

begin

    if (p1.y > p2.y) then begin
      swapPoints(p1, p2);
    end;

    if (p1.y > p3.y) then begin
      swapPoints(p1, p3);
    end;

    if (p2.y > p3.y) then begin
      swapPoints(p2, p3);
    end;

    height := p3.y - p1.y;
    if height = 0 then begin
      exit;
    end;

    if isFacing(p1, p2, p3) then begin
      ScanEdge(p1, p3, right);
      ScanEdge(p3, p2, left);
      ScanEdge(p2, p1, left);
    end else begin
      ScanEdge(p1, p2, right);
      ScanEdge(p2, p3, right);
      ScanEdge(p3, p1, left);
    end;

    for y := p1.y to p3.y do begin
        HLine(left[y], right[y], y, color);
    end;

end;

procedure DrawTriangle(x1, y1, x2, y2, x3, y3 : integer; color: byte);
var p1, p2, p3 : Point2D;
begin
  p1.x := x1;
  p1.y := y1;

  p2.x := x2;
  p2.y := y2;

  p3.x := x3;
  p3.y := y3;

  DrawFlatPolygon(p1, p2, p3, color);

end;

function GetBIOSMillis: LongInt;
var
  ticksLow, ticksHigh: Word;
  ticks: LongInt;
begin
  asm
    cli                     
    mov   ax, 40h             
    mov   es, ax
    mov   ax, es:[6Ch]        
    mov   ticksLow, ax        
    mov   ax, es:[6Eh]        
    mov   ticksHigh, ax       
    sti                     
  end;
  ticks := LongInt(ticksLow) + (LongInt(ticksHigh) shl 16);
  GetBIOSMillis := ticks * 55;
end;

function GetCurrentTimeInMillis: LongInt;
var
  Hour, Min, Sec, Sec100: Word;
begin
  GetTime(Hour, Min, Sec, Sec100);
  GetCurrentTimeInMillis := (Hour * 3600000) + (Min * 60000) + (Sec * 1000) + (Sec100 * 10);
end;

end.