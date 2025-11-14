unit baselogic;


interface

uses crt, base;

function generate_coordinates: coordinates;
function vessels_number(var obj : field) : byte;
function is_empty(var obj : field; coord : coordinates) : boolean;
function reach_target(var shooter, target : player; coord : coordinates) : boolean;
procedure mark_sinked(var obj : field; coord : coordinates);

implementation

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
  indx_x : byte;
  indx_y : byte;
  vessels : byte = 0;

begin
  for indx_y := 0 to DEFAULT_BOARD_SIZE do
    for indx_x := 0 to DEFAULT_BOARD_SIZE do
      if obj[indx_x,indx_y] = occupied then vessels := vessels + 1;
  vessels_number := vessels;
end;

function is_empty(var obj : field; coord : coordinates) : boolean;

var
  test : boolean = true;
  indx_x : shortint;
  indx_y : shortint;

begin
  for indx_y := coord.y - 1 to coord.y + 1 do
    for indx_x := coord.x - 1 to coord.x + 1 do
      if (indx_x in [0..DEFAULT_BOARD_SIZE]) and (indx_y in [0..DEFAULT_BOARD_SIZE]) then 
        if not (obj[indx_x,indx_y] = empty) then test := false;
  is_empty := test;
end;

function reach_target(var shooter, target : player; coord : coordinates) : boolean;

var
    rslt : boolean = true;
begin
  case target.bfield[coord.x,coord.y] of
    empty : begin
              target.bfield[coord.x,coord.y] := miss;
              shooter.miss := shooter.miss + 1;
            end;
    occupied : begin
                 target.bfield[coord.x,coord.y] := hit;
                 shooter.hit := shooter.hit + 1;
               end;
  else
    rslt := false;
  end;
  reach_target := rslt;
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

end.
