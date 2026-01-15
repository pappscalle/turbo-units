unit Shapes;

{$G+}

interface

uses Gfx;

type

  TEdge = array[0..SCREEN_HEIGHT-1] of integer;

  Point2D = record
    x,y : integer;
  end;

procedure Line(x1, y1, x2, y2 : integer; color : byte);
procedure HLine(x1, x2, y : integer; color : byte);
procedure VLine(x, y1, y2 : integer; color : byte);
procedure swap(var v1, v2: integer);
procedure swapPoints(var p1, p2: Point2D);
procedure ScanEdge(p1, p2 : Point2D; var  edge: TEdge);
procedure DrawFlatPolygon(p1, p2, p3 : Point2D; color: byte);
procedure DrawTriangle(x1, y1, x2, y2, x3, y3 : integer; color: byte);

function isFacing(a, b, c : Point2D) :  boolean;

implementation

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
end.