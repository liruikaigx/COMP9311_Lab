create or replace function
    insertRating() returns trigger
as $$
declare 
    b Beer;
begin 
    select * into b from Beers where id = new.beer;
    b.nRatings := b.nratings + 1;
    b.totRating := b.totRating + new.score;
    b.rating := b.totRating / b.nRatings;
    update Beer
    set
        nRatings = b.nRatings,
        totRating = b.totRating,
        rating = b.rating
    where id = new.beer;
    return new;
end;
$$ language plpgsql;

create or replace function
    updateRating() returns trigger 
as $$
declare
    nb Beer; ob Beer;
begin 
    select * in nb from Beer where id = new.beer;
    if (new.beer = old.beer) then
        if (new.rating = old.rating) then
            null;
        else
            nb.totRating := nb.totrating + new.score - old.score;
            nb.rating := nb.totalRating / nb.nRatings;
        end if;
    else
        select * into ob from Beer where id = old.beer;
        ob.totRating := ob.totRating - old.score;
        ob.nRatings := ob.nRatings - 1;
        ob.rating := ob.totRating / ob.nRatings;
        nb.totRating := nb.totRating + new.score;
        nb.nRatings := nb.nRatings + 1;
        nb.rating := nb.totRating / nb.nRatings;
        update Beer
        set
            nRatings = ob.nRatings,
            totRating = ob.totRating,
            rating = ob.rating 
        where id = old.beer;
        return old;
    end if;
    update Beer
    set 
        nRatings = nb.nRatings,
        totRating = nb.totRating,
        rating = nb.rating
    where id = new.beer;
    return new;
end;
$$ language plpgsql;

create or replace function 
    deleteRating() returns trigger 
as $$
declare 
    b Beer;
begin 
    select * into b from Beer where id = old.beer;
    b.nRatings := b.nRatings - 1;
    b.totrating := b.totrating - old.score;
    if (b.nratings = 0) then 
        b.rating := null
    else 
        b.rating := b.totrating / b.nRating;
    end if;
    update Beer
    set 
        nratings = b.nratings,
	    totrating = b.totrating,
	    rating = b.rating
    where id = old.beer;
    return old;
end;
$$ language plpgsql;

create trigger InsertRating
after insert on Ratings
for each row execute procedure insertRating();

create trigger UpdateRating
after update on Ratings
for each row execute procedure updateRating();

create trigger DeleteRating
before delete on Ratings
for each row execute procedure deleteRating();


