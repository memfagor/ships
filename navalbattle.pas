unit navalbattle;


interface

uses crt;

type

coordinates = record
                pos_x : byte;
                pos_y : byte;
              end;

point = (empty,occupied,hit,miss,marked);

field = array[0..9,0..9] of point;

player = record
           bfield : field;
           hit : byte;
           miss : byte;
         end;

players = array [0..1] of player;

function is_empty(var obj : field; p_x, p_y : shortint) : boolean;
function vessels_number(var obj : field) : byte;
procedure init_field(var obj : field);
procedure init_player(var obj : player);
procedure init_fields(var obj : players);
procedure print_point(obj : point);
procedure print_field(var obj : field; p_x, p_y : byte; hidden : point);
procedure print_battlefield(var obj : players; p_x, p_y : byte);
procedure fill_field(var obj : field; nmbr : byte);
procedure autofill_field(var obj : field; nmbr : byte);
procedure mark_sink(var obj : field; p_x, p_y : shortint);
procedure autoshoot(var shooter, target : player);
procedure shoot(var shooter, target : player);


implementation

function is_empty(var obj : field; p_x, p_y : shortint) : boolean;

var
  test : boolean = true;
  indx_x : shortint;
  indx_y : shortint;

begin
  for indx_y := p_y - 1 to p_y + 1 do
    for indx_x := p_x -1 to p_x + 1 do
      if (indx_x in [0..9]) and (indx_y in [0..9]) then 
        if not (obj[indx_x,indx_y] = empty) then test := false;
  is_empty := test;
end;

function vessels_number(var obj : field) : byte;

var
  indx_x : byte;
  indx_y : byte;
  vessels : byte = 0;

begin
  for indx_y := 0 to 9 do
    for indx_x := 0 to 9 do
      if obj[indx_x,indx_y] = occupied then vessels := vessels + 1;
  vessels_number := vessels;
end;

procedure init_field(var obj : field);

var
  indx_x : byte;
  indx_y : byte;

begin
  for indx_y := 0 to 9 do
    for indx_x := 0 to 9 do obj[indx_x,indx_y] := empty;
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
    textcolor(8);
end;

procedure print_point(obj : point);
begin
  case obj of
    empty : begin
              textcolor(8);
              write('.');
            end;
    occupied : begin
                 textcolor(green);
                 write('*');
               end;
    hit : begin
            textcolor(red);
            write('*');
          end;
    miss : begin
             textcolor(blue);
             write('+');
           end;
    marked : begin
               textcolor(yellow);
               write('+');
             end;
  end;
  textcolor(8);
end;

procedure print_field(var obj : field; p_x, p_y : byte; hidden : point);

var
  indx_y : byte;
  indx_x : byte;

begin
  gotoxy(p_x+2,p_y);
  for indx_x := 0 to 9 do write(indx_x+1:2);
  gotoxy(p_x+2,p_y+1);
  for indx_x := 0 to 19 do write('-');
  for indx_y := 0 to 9 do
  begin
    gotoxy(p_x,p_y+2+indx_y);
    write(indx_y+1:2);
    write('|');
    for indx_x := 0 to 9 do
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

procedure fill_field(var obj : field; nmbr : byte);

var
  indx : byte = 0;
  cursor : coordinates;
  keyprssd : char;
  is_set : boolean = false;

begin
  cursor.pos_x := 0;
  cursor.pos_y := 0;
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
      write(cursor.pos_x+1:2);
      gotoxy(18,15);
      write('Y: ');
      write(cursor.pos_y+1:2);
      keyprssd := readkey;
      case keyprssd of
        #72 : if cursor.pos_y > 0 then cursor.pos_y := cursor.pos_y - 1 else cursor.pos_y := 9;
        #80 : if cursor.pos_y < 9 then cursor.pos_y := cursor.pos_y + 1 else cursor.pos_y := 0;
        #75 : if cursor.pos_x > 0 then cursor.pos_x := cursor.pos_x - 1 else cursor.pos_x := 9;
        #77 : if cursor.pos_x < 9 then cursor.pos_x := cursor.pos_x + 1 else cursor.pos_x := 0;
        #13 : if is_empty(obj,cursor.pos_x,cursor.pos_y) then is_set := true;
        #27 : begin
                is_set := true;
                indx := 21;
              end;
      end;
    until is_set;
    obj[cursor.pos_x,cursor.pos_y] := occupied;
    indx := indx + 1;
  end;
end;

procedure autofill_field(var obj : field; nmbr : byte);

var
  indx : byte;
  p_x : byte;
  p_y : byte;

begin
  for indx := 1 to nmbr do
  begin
    repeat
      p_x := random(10);
      p_y := random(10);
    until is_empty(obj,p_x,p_y);
    obj[p_x,p_y] := occupied;
  end;
end;

procedure mark_sink(var obj : field; p_x, p_y : shortint);

var
  indx_x : shortint;
  indx_y : shortint;
  
begin
  for indx_y := p_y - 1 to p_y + 1 do
    for indx_x := p_x - 1 to p_x + 1 do
      if (indx_x in [0..9]) and (indx_y in [0..9]) then
        if obj[indx_x,indx_y] = empty then obj[indx_x,indx_y] := marked;
end;

procedure autoshoot(var shooter, target : player);

var
  p_x : byte;
  p_y : byte;
 
begin
  repeat
    p_x := random(10);
    p_y := random(10);
  until ((target.bfield[p_x,p_y] = empty) or (target.bfield[p_x,p_y] = occupied));
  case target.bfield[p_x,p_y] of
    empty : begin
              target.bfield[p_x,p_y] := miss;
              shooter.miss := shooter.miss + 1;
            end;
    occupied : begin
                 target.bfield[p_x,p_y] := hit;
                 mark_sink(target.bfield,p_x,p_y);
                 shooter.hit := shooter.hit + 1;
               end;
  end;
end;

procedure shoot(var shooter, target : player);

var
  cursor : coordinates;
  keyprssd : char;
  is_shoot : boolean = false;
   
begin
   cursor.pos_x := 0;
   cursor.pos_y := 0;
   repeat
     gotoxy(3,14);
     write('Position X: ');
     write(cursor.pos_x+1:2);
     gotoxy(18,14);
     write('Y: ');
     write(cursor.pos_y+1:2);
     keyprssd := readkey;
     case keyprssd of
       #72 : if cursor.pos_y > 0 then cursor.pos_y := cursor.pos_y - 1 else cursor.pos_y := 9;
       #80 : if cursor.pos_y < 9 then cursor.pos_y := cursor.pos_y + 1 else cursor.pos_y := 0;
       #75 : if cursor.pos_x > 0 then cursor.pos_x := cursor.pos_x - 1 else cursor.pos_x := 9;
       #77 : if cursor.pos_x < 9 then cursor.pos_x := cursor.pos_x + 1 else cursor.pos_x := 0;
       #13 : if (target.bfield[cursor.pos_x,cursor.pos_y] = empty) or (target.bfield[cursor.pos_x,cursor.pos_y] = occupied) then 
             begin
               gotoxy(3,15);
               write('                                   ');
               is_shoot := true;
             end
             else
               case target.bfield[cursor.pos_x,cursor.pos_y] of
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
   case target.bfield[cursor.pos_x,cursor.pos_y] of
     empty : begin
              target.bfield[cursor.pos_x,cursor.pos_y] := miss;
              shooter.miss := shooter.miss + 1;
            end;
     occupied : begin
                 target.bfield[cursor.pos_x,cursor.pos_y] := hit;
                 mark_sink(target.bfield,cursor.pos_x,cursor.pos_y);
                 shooter.hit := shooter.hit + 1;
               end;
   end;
end;
   
end.
