#!/bin/awk -f

{
	row = 0; col = 0
	for (i = 1; i <= length; i++) {
		switch(substr($0, i, 1)) {
			case "F": row = lshift(row, 1);     break
			case "B": row = lshift(row, 1) + 1; break
			case "L": col = lshift(col, 1);     break
			case "R": col = lshift(col, 1) + 1; break
		}
	}

	id = row * 8 + col
	ids[NR] = id
	if (id > max_id) max_id = id
}

END { 
	print ("Maximum seat ID:", max_id)
	PROCINFO["sorted_in"]="@val_type_asc"
	for (i in ids) {
		key = ids[i]
		if (key - prev_key == 2) print("Missing seat ID:", key-1)
		prev_key = key
	}
}
