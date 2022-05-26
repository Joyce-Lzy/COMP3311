-- COMP3311 21T1 Exam SQL Answer Template
--
-- * Don't change view/function names and view/function arguments;
-- * Only change the SQL code for view/function bodies as commented below;
-- * and do not remove the ending semicolon of course.
--
-- * You may create additional views, if you wish;
-- * but you are NOT allowed to create tables.
--


-- Q1. 
-- list the names of all actors in the database and the number of movies each of them acted 
-- (including 0, if any), ranked by the number of movies in descending order, and then by name 
-- in ascending order.
create or replace view Q1(name, total) as
select distinct(a.name), count(acti.movie_id) as total 
from actor a
left join acting acti on a.id = acti.actor_id
group by a.name
order by total desc, a.name asc
;


-- Q2. 
-- list the best director (based on the highest of the average IMDB score of their directed 
-- movies) of each year. If there are more than one best directors in a year (i.e., with the same 
-- highest average IMDB score), output all of them. Your output includes year and director name, 
-- ranked by year in ascending order and then name in ascending order. Ignore the movies with no 
-- year, no director, or with num_voted_users less than 100000, and do not output any year where 
-- no such director exists.
create or replace view Q2(year, name) as
-- replace the SQL code below:

with av(imdb, year, name) as (
    select avg(r.imdb_score), mo.year, d.name
    from director d
    join movie mo on mo.director_id = d.id
    join rating r on r.movie_id  = mo.id
    where (mo.year is not null 
        and mo.director_id is not null
        and r.num_voted_users >= 100000)
    group by d.name, mo.year
    order by mo.year, d.name
),

max_imdb(score, year) as (
    select max(imdb), year
    from av
    group by year
)

select av.year, av.name
from av
where av.imdb = (select score from max_imdb where av.year = max_imdb.year)
order by av.year asc, av.name asc
; 



-- Q3. 
-- to list any movie (title) where its director also acted in the movie itself (i.e., 
-- the director has exactly the same name as one of the actors). The query output is ranked 
-- by movie title in ascending order, and then by director name in ascending order.
create or replace view Q3 (title, name) as
-- replace the SQL code below:  
select mo.title, d.name
from movie mo
join director d on d.id = mo.director_id 
where d.name in (
    select atr.name
    from movie mo1
    join acting ac on ac.movie_id = mo1.id 
    join actor atr on atr.id = ac.actor_id
    where mo.id = mo1.id

)
order by mo.title asc, d.name asc;



-- Q4. 
-- write an SQL query to list of all actors that subsequently become directors (we define an 
-- actor and director as the same person if they have exactly the same name). i.e., Before 
-- they become directors, they have acted in at least one movie. Do not include those that 
-- started acting and directing in a same year. The query output is a list of actor names in 
-- ascending order.
create or replace view Q4 (name) as
-- replace the SQL code below:
select distinct(d.name)
from movie mo
join director d on d.id = mo.director_id
where mo.year > any(
    select mo1.year
    from movie mo1
    join acting ac on ac.movie_id = mo1.id 
    join actor atr on atr.id = ac.actor_id
    where atr.name = d.name
)
order by d.name asc;



-- Q5. 
-- find all pairs of actors (actor1's name and actor2's name) who always act in a same movie 
-- together and never act without each other in any other movies. Do not include any redundant 
-- results (e.g., if a pair A,B is in the result, then do not include B,A, assuming A is 
-- lexicographically less than B). Your query output is ranked by the number of movies that they 
-- have acted in descending order, and then by actor1 and then actor2 in ascending order.
create or replace view Q5(actor1, actor2) as
-- replace the SQL code below:
with actor1(name, moid) as (
    select aor.name, mo.id
    from movie mo
    join acting act on mo.id = act.movie_id
    join actor aor on aor.id = act.actor_id
)
    select distinct(a1.name), a2.name
    from actor1 a1, actor1 a2
    where a1.name <> a2.name and a1.moid = a2.moid
    order by a1.name;



-- Q6. 
-- Takes in the minimum (m) and maximum (n) numbers of years of acting experience and returns 
-- all actors that have acted (from their first movie till the last movie in the provided 
-- database) at least m years and up to n years inclusively. You may assume that 1 <= m <= n.


create or replace function
    experiencedActor(_m int, _n int) returns setof actor
as $$ 
declare
    actor1 actor;
    minyear integer;
    maxyear integer;
    exprience integer;
begin
    for actor1 in (
        select a.id, a.name, a.facebook_likes
        from actor a
    ) loop
        select min(mo.year) into minyear
        from movie mo
        join acting act on act.movie_id = mo.id
        join actor ac on ac.id = act.actor_id
        where ac.id = actor1.id;

        select max(mo.year) into maxyear
        from movie mo
        join acting act on act.movie_id = mo.id
        join actor ac on ac.id = act.actor_id
        where ac.id = actor1.id;

        exprience = maxyear - minyear + 1;
        if exprience >= _m and exprience <= _n then
            return next actor1;
        end if;
    end loop;
end;
$$ language plpgsql;








-- Q7.
-- Define your trigger (or triggers) below
-- A movie must have at most 5 genres and 5 keywords (i.e. there can be a movie with 5 genres 
-- and 5 keywords). Create a trigger (or triggers) to enforce this constraint for any future 
-- changes (insert, update and/or delete operations).
create or replace function checkgengre() returns trigger
as $$
begin
    if (select count(genre) from genre where new.movie_id = genre.movie_id) > 5 then
        raise exception "More than 5 gengre";
    end if;
    return new;
end;
$$ language plpgsql;


-- update or insert gengre
create trigger gengre_check after insert or update
on genre for each row execute procedure checkgengre();


create or replace function checkkeyword() returns trigger
as $$
begin
    if (select count(keyword) from keyword where new.movie_id = genre.movie_id) > 5 then
        raise exception "More than 5 keyword";
    end if;
    return new;
end;
$$ language plpgsql;


-- update or insert gengre
create trigger keyword_check after insert or update
on keyword for each row execute procedure checkkeyword();
