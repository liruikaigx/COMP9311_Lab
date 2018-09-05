

-- Q1: how many page accesses on March 2

create or replace view Q1(nacc) as
select count(*) as nacc
from accesses
where accTime > '2005-03-02' and accTime < '2005-03-03'
;

-- Q2: how many times was the MessageBoard search facility used?

create or replace view Q2(nsearches) as
select count(page) as nsearches
from accesses
where page like '%messageboard%' and page like '%webcms%' and params like '%state=search%'
;

-- Q3: on which Tuba lab machines were there incomplete sessions?

create or replace view Q3(hostname) as
select distinct Hosts.hostname as hostname
from Hosts join Sessions on (Hosts.id = Sessions.host) 
where Sessions.complete = 'f' and Hosts.hostname like '%tuba%'

;

-- Q4: min,avg,max bytes transferred in page accesses

create or replace view Q4(min,avg,max) as
select min(nbytes)::int as min, avg(nbytes)::int as avg, max(nbytes)::int as max
from accesses
;

-- Q5: number of sessions from CSE hosts

create or replace view Q5(nhosts) as
select count(*) as nhosts
from Hosts h join Sessions s on (h.id = s.host)
where h.hostname like '%cse.unsw.edu.au'
;


-- Q6: number of sessions from non-CSE hosts

create or replace view Q6(nhosts) as
select count(*) as nhosts
from Hosts h join Sessions s on (h.id = s.host)
where h.hostname not like '%cse.unsw.edu.au'
;

-- Q7: session id and number of accesses for the longest session?

create or replace view Q7(session,length) as 
select session as session, seq as length
from accesses
where seq = (select max(seq) from accesses)
;

-- Q8: frequency of page accesses

create or replace view Q8(page,freq) as
select page as page, count(page) as freq
from accesses
group by page
order by count(page) desc
;


-- Q9: frequency of module accesses

create or replace view Q9(module,freq) as
select substring(page from '^([a-z]+)(/|$)') as module, count(page) as freq
from accesses
group by substring(page from '^([a-z]+)(/|$)')
order by count(substring(page from '^([a-z]+)(/|$)')) desc
;


-- Q10: "sessions" which have no page accesses

create or replace view Q10(session) as
select id as session
from sessions s
where not exists (select session from accesses where session = s.id)
;


-- Q11: hosts which are not the source of any sessions

create or replace view Q11(unused) as
select h.hostname
from   Hosts h left outer join Sessions s on (h.id=s.host)
group  by h.hostname
having count(s.id) = 0;


