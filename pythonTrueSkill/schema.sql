CREATE TABLE names (
	id			integer PRIMARY KEY,
	name 		text UNIQUE,
	rounds		integer
);

CREATE TABLE data (
	round		integer,
	id			integer REFERENCES names(id),
	mu			real,
	sigma		real
);
