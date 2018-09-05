-- COMP9311 18s2 Lab 04 Exercises

-- Q1. What beers are made by Toohey's?

create or replace view Beer_and_brewer as
select b.name as beer, r.name as brewer
from   Beers b join Brewers r on (b.brewer=r.id)
;

create or replace view Q1(wine) as
select Beers.name as wine 
from Beers join Brewers on (Beers.brewer = Brewers.id)
where Brewers.id = 8
;

-- Q2. Show beers with headings "Beer", "Brewer".

create or replace view Q2(headings) as
select Beers.name, Brewers.name as beer
from Beers join Brewers on (Beers.brewer = Brewers.id)
;

-- Q3. Find the brewers whose beers John likes.

create or replace view Q3(Johnlike) as
select Brewers.name as Johnlike
from Brewers, Beers, Likes
where Brewers.id = Beers.brewer and Beers.id = Likes.beer and Likes.drinker = 42
;

-- Q4. How many different beers are there?

create or replace view Q4(difbeers) as
select count(*) as difbeers
from Beers
;

-- Q5. How many different brewers are there?

create or replace view Q5(difbrewers) as
select count(*) as difbrewers
from Brewers
;

-- Q6. Find pairs of beers by the same manufacturer
--     (but no pairs like (a,b) and (b,a), and no (a,a))

create or replace view Q6 as
select b1.name as beer1, b2.name as beer2
from Beers b1 join Beers b2 on (b1.brewer = b2.brewer)
where b1.name < b2.name
;

-- Q7. How many beers does each brewer make?

create or replace view Q7 as
select Brewers.name as brewer, count(*) as nbeers
from Brewers join Beers on (Brewers.id = Beers.brewer)
group by Brewers.name
;

-- Q8. Which brewer makes the most beers?

create or replace view Q8 as
select brewer
from Q7
where nbeers = (select max(nbeers) from Q7)
;

-- Q9. Beers that are the only one by their brewer.

create or replace view Q9 as
select distinct Beers.name as beer
from Beers join Brewers on (Beers.brewer = Brewers.id)
where Brewers.name in (select brewer from Q7 where nbeers=1)
;

-- Q10. Beers sold at bars where John drinks.

create or replace view Q10 as
select distinct(b.name) as beer
from   Frequents f
         join Drinkers d on (d.id=f.drinker)
         join Sells s on (s.bar=f.bar)
         join Beers b on (b.id=s.beer)
where  d.name = 'John'
;

-- Q11. Bars where either Gernot or John drink.

create or replace view bar_and_drinker as
select b.name as bar, d.name as drinker
from   Bars b
         join Frequents f on (b.id=f.bar)
         join Drinkers d on (d.id=f.drinker)
;

create or replace view Q11 as
(select bar from Bar_and_drinker where drinker = 'John')
union
(select bar from Bar_and_drinker where drinker = 'Gernot')
;

-- Q12. Bars where both Gernot and John drink.

create or replace view Q12 as
(select bar from Bar_and_drinker where drinker = 'John')
intersect 
(select bar from bar_and_drinker where drinker = 'Gernot')
;

-- Q13. Bars where John drinks but Gernot doesn't

create or replace view Q13 as
(select bar from Bar_and_drinker where drinker = 'John')
except 
(select bar from bar_and_drinker where drinker = 'Gernot')
;

-- Q14. What is the most expensive beer?

create or replace view Q14 as
select Beers.name as beer
from Beers join Sells on (Beers.id = Sells.beer)
where Sells.price = (select max(price) from Sells)
;

-- Q15. Find bars that serve New at the same price
--      as the Coogee Bay Hotel charges for VB.
create or replace view Beer_bar_prices as 
select Beers.name as beer, Bars.name as bar, Sells.price
from Beers join Sells on (Sells.beer=Beers.id) 
           join Bars on (Sells.bar=Bars.id)
;

create or replace view CBH_VB_price as
select price
from   Beer_bar_prices
where  bar = 'Coogee Bay Hotel'
         and beer = 'Victoria Bitter'
;

create or replace view Q15 as
select bar
from   Beer_bar_prices
where  beer = 'New'
         and price = (select price from CBH_VB_price)
;

-- Q16. Find the average price of common beers
--      ("common" = served in more than two hotels).

create or replace view Q16 as
select beer, avg(price)::numeric(5,2) as "AvgPrice"
from  Beer_bar_prices
group by beer
having count(bar)>2
;

-- Q17. Which bar sells 'New' cheapest?

create or replace view Q17 as
select bar 
from   Beer_bar_prices
where  beer = 'New' and price = (select min(price) from Beer_bar_prices where beer = 'New')
;

-- Q18. Which bar is most popular? (Most drinkers)
create or replace view Bar_drinkers as 
select b.name as bar, count(*) as ndrinkers
from Bars b left outer join Frequents f on (f.bar = b.id)
            left outer join Drinkers d on (f.drinker = d.id)
group by b.name
;

create or replace view Q18 as
select bar as bar
from   Bar_drinkers
where ndrinkers = (select max(ndrinkers) from Bar_drinkers)
;

-- Q19. Which bar is least popular? (May have no drinkers)

create or replace view Q19 as
select bar as bar
from   Bar_drinkers
where  ndrinkers = (select min(ndrinkers) from Bar_drinkers)
;

-- Q20. Which bar is most expensive? (Highest average price)

create or replace view Bar_average_price as
select b.id, b.name as bar, avg(s.price)::numeric(5,2) as avg_price
from   Bars b
         join Sells s on (b.id=s.bar)
group  by b.id, b.name
;

create or replace view Q20 as
select bar
from   Bar_average_price
where  avg_price = (select max(avg_price) from Bar_average_price)
;

-- Q21. Which beers are sold at all bars?

create or replace view Q21 as
select b.name as beer
from   Beers b
        join Sells s on (s.beer=b.id)
where  not exists (
        (select id as bar from Bars)
        except
        (select bar from Sells where beer=b.id)
       )
;

-- Q22. Price of cheapest beer at each bar?

--create or replace view Q22 as
--select bar, min(price) as min_price
--from   Beer_bar_prices
--group by beer
--having price = min(price)
create or replace view Bar_min_price as
select b.id, b.name as bar, min(s.price)::numeric(5,2) as min_price
from   Bars b
         join Sells s on (b.id=s.bar)
group  by b.id, b.name
;

create or replace view Q22 as
select bar, min_price
from   Bar_min_price
;

-- Q23. Name of cheapest beer at each bar?

create or replace view Q23 as
select bmp.bar, b.name as beer
from   Bar_min_price bmp
         join Sells s on (bmp.id=s.bar)
         join Beers b on (b.id=s.beer)
where  s.price = (select min_price
                  from   Bar_min_price
                  where  bar = bmp.bar)
;

-- Q24. How many drinkers are in each suburb?

create or replace view Q24 as
select addr, count(*)
from   Drinkers
group by addr  
;

-- Q25. How many bars in suburbs where drinkers live?
--      (Must include suburbs with no bars)

create or replace view Q25 as
select Drinkers.addr, count(Bars.id) as "#bar"
from   Drinkers 
         left outer join Bars on (Drinkers.addr=Bars.addr)
group by Drinkers.addr
;
