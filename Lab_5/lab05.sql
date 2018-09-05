-- COMP9311 18s2 Lab5 Exercise
-- Written by: YOUR NAME


-- AllRatings view 

create or replace view AllRatings(taster,beer,brewer,rating)
as
select t.given as taster, b.name as beer, br.name as brewer, r.score as rating
from Taster t join Ratings r on (t.id = r.taster)
			  join Beer b on (r.beer = b.id)
			  join Brewer br on (b.brewer = br.id)
order by t.given,r.score desc
;


-- John's favourite beer

create or replace view JohnsFavouriteBeer(brewer,beer)
as
select a.brewer as brewer, a.beer as beer
from AllRatings a
where taster = 'John' and rating = '5'
;


-- X's favourite beer

create type BeerInfo as (brewer text, beer text);

create or replace function FavouriteBeer(taster text) returns setof BeerInfo
as $$
	select brewer, beer
	from AllRatings
	where taster = $1 and rating = (select max(rating) from AllRatings where taster = $1)
$$ language sql
;


-- Beer style

create or replace function BeerStyle(brewer text, beer text) returns text
as $$
	select bs.name as beerstyle
	from BeerStyle bs join Beer b on (bs.id = b.style)
	                  join Brewer br on (b.brewer = br.id)
	where br.name = $1 and b.name = $2
$$ language sql
;

create or replace function BeerStyle1(brewer text, beer text) returns text
as $$
declare targetname text;
begin
	select bs.name into targetname
	from BeerStyle bs join Beer b on (bs.id = b.style)
	                  join Brewer br on (b.brewer = br.id)
	where br.name = $1 and b.name = $2;
	return targetname;
end;
$$ language plpgsql 
;


-- Taster address

create or replace function TasterAddress(taster text) returns text
as $$
	select loc.state||', '||loc.country
	from   Taster t, Location loc
	where  t.given = $1 and t.livesIn = loc.id
$$ language sql
;

create or replace function TasterAddress(taster text) returns text
as $$
declare 
country text;
state text;
begin
	select loc.state, loc.country into state, country
	from Taster t, Location loc
	where t.given = $1 and t.livesIn = loc.id;
	if (state is null) then 
	return country;
	elsif (country is null) then
	return state;
	ELSE
	return state||', '||country;
	end if;	
end;
$$ language plpgsql
;


-- BeerSummary function

create or replace function BeerSummary() returns text
as $$
declare
	... replace this by your definitions ...
begin
	... replace this by your code ...
end;
$$ language plpgsql;



-- Concat aggregate

create or replace function appendNext(_state text, _next text) returns text
as $$
begin 
	return _state||','||_next;
end;
$$ language plpgsql;

create or replace function finalText(_final text) returns text
as $$
begin
	return substr(_final, 2, length(_final));
end;
$$ language plpgsql;

create aggregate concat (text)
(
	stype     = text,
	initcond  = '',
	sfunc     = appendNext,
	finalfunc = finalText
);


-- BeerSummary view

create or replace view BeerSummary(beer,rating,tasters)
as
	select beer, to_char(avg(rating), '9.9'), concat(taster)
	from AllRatings
	group by beer


