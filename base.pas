unit base;


interface

uses crt;

const
    DEFAULT_TEXT_COLOR = 7;
    DEFAULT_BOARD_SIZE = 9;

type

coordinates = record
                pos_x : byte;
                pos_y : byte;
              end;

point = (empty,occupied,hit,miss,marked);

field = array[0..DEFAULT_BOARD_SIZE,0..DEFAULT_BOARD_SIZE] of point;

player = record
           bfield : field;
           hit : byte;
           miss : byte;
         end;

players = array [0..1] of player;

implementation

end.
