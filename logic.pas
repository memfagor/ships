unit logic;


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

function is_empty(var obj : field; coord: coordinates) : boolean;
function vessels_number(var obj : field) : byte;
procedure init_field(var obj : field);
procedure init_player(var obj : player);
procedure init_fields(var obj : players);
procedure print_point(obj : point);
procedure print_field(var obj : field; p_x, p_y : byte; hidden : point);
procedure print_battlefield(var obj : players; p_x, p_y : byte);
procedure fill_field(var obj : field; nmbr : byte);
procedure autofill_field(var obj : field; nmbr : byte);
procedure mark_sinked(var obj : field; coord: coordinates);
procedure autoshoot(var shooter, target : player);
procedure shoot(var shooter, target : player);


implementation

function is_empty(var obj : field; coord: coordinates) : boolean;

var
  test : boolean = true;
  indx_x : shortint;
  indx_y : shortint;

begin
  for indx_y := coord.y - 1 to coord.y + 1 do
    for indx_x := coord.x -1 to coord.x + 1 do
      if (indx_x in [0..DEFAULT_BOARD_SIZE]) and (indx_y in [0..DEFAULT_BOARD_SIZE]) then 
        if not (obj[indx_x,indx_y] = empty) then test := false;
  is_empty := test;
end;

function generate_coordinates: coordinates;

var
  coord : coordinates;

begin
  coord.x := random(DEFAULT_BOARD_SIZE + 1);
  coord.y := random(DEFAULT_BOARD_SIZE + 1);
  generate_coordinates := coord;
end;

function vessels_number(var obj : field) : byte;

var
  indx_x : shortint;
  indx_y : shortint;
  vessels : byte = 0;

begin
  for indx_y := 0 to DEFAULT_BOARD_SIZE do
    for indx_x := 0 to DEFAULT_BOARD_SIZE do
      if obj[indx_x,indx_y] = occupied then vessels := vessels + 1;
  vessels_number := vessels;
end;

procedure init_field(var obj : field);

var
  indx_x : shortint;
  indx_y : shortint;

begin
  for indx_y := 0 to DEFAULT_BOARD_SIZE do
    for indx_x := 0 to DEFAULT_BOARD_SIZE do obj[indx_x,indx_y] := empty;
end;

procedure init_player(var obj : player);

begin
  init_field(obj.bfield);
  obj.hit := 0;
  obj.miss := 0;
end;

procedure init_fields(var obj : players);

var
  indx : byte;

begin
  for indx := 0 to 1 do init_player(obj[indx]);
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
  indx_y : shortint;
  indx_x : shortint;

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

procedure move_cursor(var cursor : coordinates; key : char);
begin
      case key of
        #72 : if cursor.y > 0 then cursor.y := cursor.y - 1 else cursor.y := DEFAULT_BOARD_SIZE;
        #80 : if cursor.y < DEFAULT_BOARD_SIZE then cursor.y := cursor.y + 1 else cursor.y := 0;
        #75 : if cursor.x > 0 then cursor.x := cursor.x - 1 else cursor.x := DEFAULT_BOARD_SIZE;
        #77 : if cursor.x < DEFAULT_BOARD_SIZE then cursor.x := cursor.x + 1 else cursor.x := 0;
      end;
end;

procedure fill_field(var obj : field; nmbr : byte);

var
  indx : byte = 0;
  cursor : coordinates;
  keyprssd : char;
  is_set : boolean = false;

begin
  cursor.x := 0;
  cursor.y := 0;
  while indx < 20 do
  begin
    is_set := false;
    print_field(obj,1,1,empty);
    repeat
      gotoxy(3,14);
      write('Ship no: ');
      write(indx+1);
      gotoxy(3,15);
      write('Position X: ');
      write(cursor.x+1:2);
      gotoxy(18,15);
      write('Y: ');
      write(cursor.y+1:2);
      keyprssd := readkey;
      move_cursor(cursor,keyprssd);
      case keyprssd of
        #13 : if is_empty(obj,cursor) then is_set := true;
        #27 : begin
                is_set := true;
                indx := 21;
              end;
      end;
    until is_set;
    obj[cursor.x,cursor.y] := occupied;
    indx := indx + 1;
  end;
end;

procedure autofill_field(var obj : field; nmbr : byte);

var
  indx : byte;
  coord : coordinates;

begin
  for indx := 1 to nmbr do
  begin
    repeat
      coord := generate_coordinates;
    until is_empty(obj,coord);
    obj[coord.x,coord.y] := occupied;
  end;
end;

procedure mark_sinked(var obj : field; coord : coordinates);

var
  indx_x : shortint;
  indx_y : shortint;
  
begin
  for indx_y := coord.y - 1 to coord.y + 1 do
    for indx_x := coord.x - 1 to coord.x + 1 do
      if (indx_x in [0..DEFAULT_BOARD_SIZE]) and (indx_y in [0..DEFAULT_BOARD_SIZE]) then
        if obj[indx_x,indx_y] = empty then obj[indx_x,indx_y] := marked;
end;

procedure reach_target(var shooter, target : player; coord: coordinates);

begin
  case target.bfield[coord.x,coord.y] of
    empty : begin
              target.bfield[coord.x,coord.y] := miss;
              shooter.miss := shooter.miss + 1;
            end;
    occupied : begin
                 target.bfield[coord.x,coord.y] := hit;
                 mark_sinked(target.bfield,coord);
                 shooter.hit := shooter.hit + 1;
               end;
  end;
end;

procedure autoshoot(var shooter, target : player);

var
  coord : coordinates;
 
begin
  repeat
    coord := generate_coordinates;
  until target.bfield[coord.x,coord.y] in [empty, occupied];
  reach_target(shooter,target,coord);
end;

procedure shoot(var shooter, target : player);

var
  cursor : coordinates;
  keyprssd : char;
  is_shoot : boolean = false;
   
begin
   cursor.x := 0;
   cursor.y := 0;
   repeat
     gotoxy(3,14);
     write('Position X: ');
     write(cursor.x+1:2);
     gotoxy(18,14);
     write('Y: ');
     write(cursor.y+1:2);
     keyprssd := readkey;
     move_cursor(cursor,keyprssd);
     case keyprssd of
       #13 : if (target.bfield[cursor.x,cursor.y] = empty) or (target.bfield[cursor.x,cursor.y] = occupied) then 
             begin
               gotoxy(3,15);
               write('                                   ');
               is_shoot := true;
             end
             else
               case target.bfield[cursor.x,cursor.y] of
                 hit : begin
                         gotoxy(3,15);
                         write('Already shoot here and hit :)      ');
                       end;
                 miss : begin
                          gotoxy(3,15);
                          write('Already shoot here and miss :(     ');
                        end;
                 marked : begin
                            gotoxy(3,15);
                            write('Field marked as empty...           ');
                          end;
               end;
       #27 : is_shoot := true;
     end;
   until is_shoot;
   reach_target(shooter,target,cursor);
end;
   
end.
