unit Misc;

{$G+}      

interface

uses Dos;

procedure ScreenOff;
procedure ScreenOn;

function GetBIOSMillis: LongInt;
function GetCurrentTimeInMillis: LongInt;

implementation

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