unit base;


interface

uses crt;

const
    DEFAULT_TEXT_COLOR = 7;
    DEFAULT_BOARD_SIZE = 9;

type

coordinates = record
                x : shortint;
                y : shortint;
              end;

point = (empty,occupied,hit,miss,marked);

field = array[0..DEFAULT_BOARD_SIZE,0..DEFAULT_BOARD_SIZE] of point;

player = record
           bfield : field;
           hit : byte;
           miss : byte;
         end;

players = array [0..1] of player;

procedure move_cursor(var cursor : coordinates; key : char);
procedure colorized_write(txt : string; color : byte);
procedure print_point(obj : point);
procedure print_field(var obj : field; p_x, p_y : byte; hidden : point);
procedure print_battlefield(var obj : players; p_x, p_y : byte);

implementation

procedure move_cursor(var cursor : coordinates; key : char);

begin
  case key of
    #72 : if cursor.y > 0 then cursor.y := cursor.y - 1 else cursor.y := DEFAULT_BOARD_SIZE;
    #80 : if cursor.y < DEFAULT_BOARD_SIZE then cursor.y := cursor.y + 1 else cursor.y := 0;
    #75 : if cursor.x > 0 then cursor.x := cursor.x - 1 else cursor.x := DEFAULT_BOARD_SIZE;
    #77 : if cursor.y < DEFAULT_BOARD_SIZE then cursor.y := cursor.y + 1 else cursor.y := 0;
  end;
end;

procedure colorized_write(txt : string; color : byte);

begin
  textcolor(color);
  write(txt);
  textcolor(DEFAULT_TEXT_COLOR);
end;

procedure print_point(obj : point);

begin
  case obj of
    empty : colorized_write('.',DEFAULT_TEXT_COLOR);
    occupied : colorized_write('*',2);
    hit : colorized_write('*',4);
    miss : colorized_write('+',1);
    marked : colorized_write('+',14);
  end;
end;

procedure print_field(var obj : field; p_x, p_y : byte; hidden : point);

var
  indx_y : byte;
  indx_x : byte;

begin
  gotoxy(p_x+2,p_y);
  for indx_x := 0 to DEFAULT_BOARD_SIZE do write(indx_x+1:2);
  gotoxy(p_x+2,p_y+1);
  for indx_x := 0 to 19 do write('-');
  for indx_y := 0 to DEFAULT_BOARD_SIZE do
  begin
    gotoxy(p_x,p_y+2+indx_y);
    write(indx_y+1:2);
    write('|');
    for indx_x := 0 to DEFAULT_BOARD_SIZE do
    begin
      if obj[indx_x,indx_y] = hidden then print_point(empty) else print_point(obj[indx_x,indx_y]);
      write(' ');
    end;
  end;
end;

procedure print_battlefield(var obj : players; p_x, p_y : byte);

var
  indx : byte;
  effectivity : byte;

begin
  print_field(obj[0].bfield,p_x,p_y,empty);
  print_field(obj[1].bfield,p_x+25,p_y,occupied);
  for indx := 0 to 1 do
  begin
    if (obj[indx].hit = 0) and (obj[indx].miss = 0) then effectivity := 0 else effectivity := round((obj[indx].hit/(obj[indx].hit+obj[indx].miss))*100);
    gotoxy((p_x+2+indx*25),p_y+16);
    write('Hit :');
    write(obj[indx].hit:3);
    gotoxy((p_x+2+indx*25),p_y+17);
    write('Miss :');
    write(obj[indx].miss:3);
    gotoxy((p_x+2+indx*25),p_y+18);
    write('Efectivity :');
    write(effectivity:3);
    write('%');
  end;
end;

end.
