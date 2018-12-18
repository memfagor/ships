unit baselogic;


interface

uses crt, base;

function generate_coordinates: coordinates;
function vessels_number(var obj : field) : byte;
function is_empty(var obj : field; p_x, p_y : shortint) : boolean;
procedure mark_sinked(var obj : field; p_x, p_y : shortint);
procedure reach_target(var shooter, target : player; p_x, p_y : byte);

implementation

function generate_coordinates: coordinates;

var
  coord : coordinates;

begin
  coord.pos_x := random(DEFAULT_BOARD_SIZE + 1);
  coord.pos_y := random(DEFAULT_BOARD_SIZE + 1);
  generate_coordinates := coord;
end;

function vessels_number(var obj : field) : byte;

var
  indx_x : byte;
  indx_y : byte;
  vessels : byte = 0;

begin
  for indx_y := 0 to DEFAULT_BOARD_SIZE do
    for indx_x := 0 to DEFAULT_BOARD_SIZE do
      if obj[indx_x,indx_y] = occupied then vessels := vessels + 1;
  vessels_number := vessels;
end;

function is_empty(var obj : field; p_x, p_y : shortint) : boolean;

var
  test : boolean = true;
  indx_x : shortint;
  indx_y : shortint;

begin
  for indx_y := p_y - 1 to p_y + 1 do
    for indx_x := p_x -1 to p_x + 1 do
      if (indx_x in [0..DEFAULT_BOARD_SIZE]) and (indx_y in [0..DEFAULT_BOARD_SIZE]) then 
        if not (obj[indx_x,indx_y] = empty) then test := false;
  is_empty := test;
end;


procedure mark_sinked(var obj : field; p_x, p_y : shortint);

var
  indx_x : shortint;
  indx_y : shortint;
  
begin
  for indx_y := p_y - 1 to p_y + 1 do
    for indx_x := p_x - 1 to p_x + 1 do
      if (indx_x in [0..DEFAULT_BOARD_SIZE]) and (indx_y in [0..DEFAULT_BOARD_SIZE]) then
        if obj[indx_x,indx_y] = empty then obj[indx_x,indx_y] := marked;
end;

procedure reach_target(var shooter, target : player; p_x, p_y : byte);

begin
  case target.bfield[p_x,p_y] of
    empty : begin
              target.bfield[p_x,p_y] := miss;
              shooter.miss := shooter.miss + 1;
            end;
    occupied : begin
                 target.bfield[p_x,p_y] := hit;
                 mark_sinked(target.bfield,p_x,p_y);
                 shooter.hit := shooter.hit + 1;
               end;
  end;
end;

end.
