program ships;

uses crt, logic;

var
  is_running : boolean = true;
  keyprssd : char;
  pl : players;
  whose_turn : byte;

begin
  randomize;
  clrscr; 
  
  repeat
    
    gotoxy(30,21);
    write('New game - press "n"');
    gotoxy(30,22);
    write('Quit game - press "Esc"');
    
    keyprssd := readkey;
    
    clrscr;
    
    case keyprssd of
      'n' : begin
      
              init_fields(pl);
              fill_field(pl[0].bfield,20);
              autofill_field(pl[1].bfield,20);
              whose_turn := random(1);              
              
              clrscr;
              
              repeat 
                print_battlefield(pl,1,1);
                
                if whose_turn = 0 then
                begin
                  shoot(pl[0],pl[1]);
                  whose_turn := 1;
                end
                else
                begin
                  autoshoot(pl[1],pl[0]);
                  whose_turn := 0;
                end;
              until (vessels_number(pl[0].bfield) = 0) or (vessels_number(pl[1].bfield) = 0);
              
              print_battlefield(pl,1,1);

              if (vessels_number(pl[1].bfield) = 0) then
              begin
                gotoxy(3,15);
                write('You WIN :)                         ');
              end
              else
              begin
                gotoxy(3,15);
                write('Computer WIN :(                    ');
              end;
              
            end;
            
      #27 : is_running := false;
    end;
    
  until not is_running;

  textcolor(8);
  clrscr;

end.
