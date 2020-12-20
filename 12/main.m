fid = fopen("input.txt");
c = textscan(fid, "%c%n");

pos = [ 0; 0 ]; dir = [ 1; 0 ];

for row = 1:(size(c{1}) - 1)
  instr = c{1}{row}; amt = c{2}(row);

  switch (instr)
    case 'F'  pos += amt * dir;
    case 'N'  pos += [ 0; amt ];
    case 'E'  pos += [ amt; 0 ];
    case 'S'  pos += [ 0; -amt ];
    case 'W'  pos += [ -amt; 0 ];
    case 'L'  dir =  ([ 0 -1; 1 0 ] ^ floor(amt / 90)) * dir;
    case 'R'  dir =  ([ 0 1; -1 0 ] ^ floor(amt / 90)) * dir;

    otherwise printf ("Unknown instruction: %s\n", instr)
  end
end

printf("Part 1: %d\n", sum(abs(pos)))

## The only difference for Part II is that the cardinal directions apply to the
## direction vector and not the position vector. Sadly, I can't work out a
## simple way to abstract over that, so Copy & Paste it is...

pos = [ 0; 0 ]; wayp = [ 10; 1 ];

for row = 1:(size(c{1}) - 1)
  instr = c{1}{row}; amt = c{2}(row);

  switch (instr)
    case 'F'  pos += amt * wayp;
    case 'N'  wayp += amt * [ 0; 1 ];
    case 'E'  wayp += amt * [ 1; 0 ];
    case 'S'  wayp += amt * [ 0; -1 ];
    case 'W'  wayp += amt * [ -1; 0 ];
    case 'L'  wayp =  ([ 0 -1; 1 0 ] ^ floor(amt / 90)) * wayp;
    case 'R'  wayp =  ([ 0 1; -1 0 ] ^ floor(amt / 90)) * wayp;

    otherwise printf ("Unknown instruction: %s\n", instr)
  end
end

printf("Part 2: %d\n", sum(abs(pos)))

