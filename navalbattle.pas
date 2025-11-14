unit navalbattle;


interface

uses crt, base, baselogic;

procedure init_field(var obj : field);
procedure init_player(var obj : player);
procedure init_fields(var obj : players);
procedure fill_field(var obj : field; nmbr : byte);
procedure autofill_field(var obj : field; nmbr : byte);
procedure autoshoot(var shooter, target : player);
procedure shoot(var shooter, target : player);


implementation

procedure init_field(var obj : field);

var
  indx_x : byte;
  indx_y : byte;

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
      case keyprssd of
        #72 : if cursor.y > 0 then cursor.y := cursor.y - 1 else cursor.y := DEFAULT_BOARD_SIZE;
        #80 : if cursor.y < DEFAULT_BOARD_SIZE then cursor.y := cursor.y + 1 else cursor.y := 0;
        #75 : if cursor.x > 0 then cursor.x := cursor.x - 1 else cursor.x := DEFAULT_BOARD_SIZE;
        #77 : if cursor.x < DEFAULT_BOARD_SIZE then cursor.x := cursor.x + 1 else cursor.x := 0;
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
     case keyprssd of
       #72 : if cursor.y > 0 then cursor.y := cursor.y - 1 else cursor.y := DEFAULT_BOARD_SIZE;
       #80 : if cursor.y < DEFAULT_BOARD_SIZE then cursor.y := cursor.y + 1 else cursor.y := 0;
       #75 : if cursor.x > 0 then cursor.x := cursor.x - 1 else cursor.x := DEFAULT_BOARD_SIZE;
       #77 : if cursor.x < DEFAULT_BOARD_SIZE then cursor.x := cursor.x + 1 else cursor.x := 0;
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
