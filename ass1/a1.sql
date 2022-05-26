-- COMP3311 Assignment 1

-- Q1: List all persons that are neither clients nor staff members. 
-- Order the result by pid in ascending order.

create or replace view Q1(pid, firstname, lastname) as 
select distinct p.pid, p.firstname, p.lastname
from person p
where p.pid not in (select pid from staff) 
and p.pid not in (select pid from client)
order by p.pid ASC;


-- Q2: List all persons (including staff and clients) who have never been insured 
-- (wholly or jointly) by an enforced policy from the company. Order the result 
-- by pid in ascending order.

create or replace view Q2(pid, firstname, lastname) as
select distinct p.pid, p.firstname, p.lastname
from person p 
where p.pid not in (
    select c.pid 
    from client c join insured_by i on c.cid = i.cid
    where i.pno in (
        select po.pno
        from policy po
        where po.status = 'E'
    )
)
order by p.pid ASC;



-- Q3: For each vehicle brand, list the vehicle insured by the most expensive policy (the premium, 
-- i.e., the sum of its approved coverages' rates). Include only the past and current enforced 
-- policies. Order the result by brand, and then by vehicle id, pno if there are ties, all in 
-- ascending order.
create or replace view Q3(brand, vid, pno, premium) as 
    with table1(brand, vid, pno, premium) as
    (
        select ii.brand, ii.id, p.pno, sum(rr.rate) 
        from insured_item ii
        join policy p on ii.id = p.id
        join coverage c on p.pno = c.pno
        join rating_record rr on rr.coid = c.coid
        where p.status = 'E' and rr.status = 'A' 
        and p.pno not in (select pno from policy where effectivedate > CURRENT_DATE)
        group by ii.brand, ii.id, p.pno
    ),

    table2(brand,maxpre) as
    (
        select brand, max(premium)
        from table1
        group by brand
    )

    select table2.brand, table1.vid, table1.pno, table2.maxpre
    from table1 join table2 on table1.premium = table2.maxpre
    order by table2.brand, vid, pno ASC;



-- Q4: List all the staff members who have not sell, rate or underwrite any policies that 
-- are/were eventually enforced. Note that policy.sid records the staff who sold the policy 
-- (i.e., the agent). Order the result by pid (i.e., Persion id) in ascending order.
create or replace view Q4(pid, firstname, lastname) as
    with written(writepid) as
    (
        select p.pid
        from person p 
        join staff s on s.pid = p.pid
        join underwritten_by ub on ub.sid = s.sid
        join underwriting_record ur on ur.urid = ub.urid
        join policy po on ur.pno = po.pno
        where po.status = 'E'
    ),

    rate(ratepid) as
    (
        select p.pid
        from person p 
        join staff s on s.pid = p.pid
        join rated_by rb on rb.sid = s.sid 
        join rating_record rr on rr.rid = rb.rid
        join coverage c on c.coid = rr.coid
        join policy po on po.pno = c.pno
        where po.status = 'E'
    ),

    sell(sellpid) as
    (
        select p.pid
        from person p 
        join staff s on s.pid = p.pid
        join policy po on po.sid = s.sid
        where po.status = 'E'
    )

    select p.pid, p.firstname, p.lastname
    from person p 
    join staff s on p.pid = s.pid
    where p.pid not in 
    (
       (select sellpid from sell)
       union (select ratepid from rate)
       union (select writepid from written)
    )
    order by p.pid ASC; 
    
    

-- Q5: For each suburb (by suburb name) in NSW, compute the number of enforced policies that 
-- have been sold to the policy holders living in the suburb (regardless of the policy effective 
-- and expiry dates). Order the result by Number of Policies (npolicies), then by suburb, 
-- in ascending order. Exclude suburbs with no sold policies. Furthermore, suburb names are 
-- output in all uppercase.
create or replace view Q5(suburb, npolicies) as
select upper(suburb) as sub, count(po.pno) as np
from person p
join client c on p.pid = c.pid
join insured_by ib on ib.cid = c.cid
join policy po on po.pno = ib.pno
where p.state = 'NSW' and po.status = 'E'
group by suburb
order by np, sub ASC;


-- Q6: Find all past and current enforced policies which are rated, underwritten, and 
-- sold by the same staff member, and not involved any others at all. Order the result by pno 
-- in ascending order.
create or replace view Q6(pno, ptype, pid, firstname, lastname) as
    with rate(pno, pid) as
    (
        select po.pno, p.pid
        from person p
        join staff s on p.pid = s.pid
        join rated_by rb on rb.sid = s.sid 
        join rating_record rr on rr.rid = rb.rid
        join coverage c on rr.coid = c.coid 
        join policy po on po.pno = c.pno
        where po.status = 'E' and po.effectivedate <= CURRENT_DATE
        and po.pno in (
            select po.pno 
            from person p
            join staff s on p.pid = s.pid
            join rated_by rb on rb.sid = s.sid 
            join rating_record rr on rr.rid = rb.rid
            join coverage c on rr.coid = c.coid 
            join policy po on po.pno = c.pno
            group by po.pno
            having count(distinct p.pid) = 1
        )
        
    ),

    written(pno, pid) as
    (
        select po.pno, p.pid
        from person p 
        join staff s on s.pid = p.pid
        join underwritten_by ub on ub.sid = s.sid
        join underwriting_record ur on ur.urid = ub.urid
        join policy po on ur.pno = po.pno
        where po.status = 'E' and po.effectivedate <= CURRENT_DATE 
        and po.pno in (
            select po.pno
            from person p 
            join staff s on s.pid = p.pid
            join underwritten_by ub on ub.sid = s.sid
            join underwriting_record ur on ur.urid = ub.urid
            join policy po on ur.pno = po.pno 
            group by po.pno
            having count(distinct p.pid) = 1
        )
    ),

    sell(pno, pid) as
    (
        select po.pno, p.pid
        from person p 
        join staff s on s.pid = p.pid
        join policy po on po.sid = s.sid
        where po.status = 'E' and po.effectivedate <= CURRENT_DATE  
        and po.pno in (
           select po.pno
            from person p 
            join staff s on s.pid = p.pid
            join policy po on po.sid = s.sid
            group by po.pno
            having count(distinct p.pid) = 1
        )
    ),

    sameperson(pno, ptype, pid, firstname, lastname) as
    (
        select po.pno, po.ptype, p.pid, p.firstname, p.lastname
        from person p 
        join staff s on p.pid = s.pid
        join policy po on s.sid = po.sid
        where p.pid in 
        (
            (select pid from sell) 
            intersect (select pid from written)
            intersect (select pid from rate)
        ) and po.pno in 
        (
            (select pno from sell) 
            intersect (select pno from written)
            intersect (select pno from rate)
        ) 
    )

    select sameperson.pno, sameperson.ptype, pid, firstname, lastname
    from sameperson
    join policy po on sameperson.pno = po.pno
     
    order by po.pno ASC;
 



-- Q7: The company would like to speed up the turnaround time of approving a policy and wants 
-- to find the enforced policy with the longest time between the first rater rating a coverage of 
-- the policy (regardless of the rating status), and the last underwriter approving the policy. 
-- Find such a policy (or policies if there is more than one policy with the same longest time) 
-- and output the details as specified below. Order the result by pno in ascending order.
create or replace view Q7(pno, ptype, effectivedate, expirydate, agreedvalue) as
    with timegap(timediff, pno) as
    (
        select max(ub.wdate) - min(rb.rdate), po.pno
        from rated_by rb 
        join rating_record rr on rr.rid = rb.rid
        join coverage c on rr.coid = c.coid
        join policy po on c.pno = po.pno
        join underwriting_record ur on po.pno = ur.pno
        join underwritten_by ub on ub.urid = ur.urid
        where po.status = 'E'
        group by po.pno
    )

    select po.pno, ptype, effectivedate, expirydate, agreedvalue
    from policy po
    join timegap t on t.pno = po.pno
    where t.timediff >= all(select timediff from timegap)
    group by po.pno
    order by po.pno ASC;



-- Q8: List the staff members (their firstname, a space and then the lastname as one column called 
-- name) who have successfully sold policies (i.e., enforced policies) that only cover one brand
-- of vehicle. Order the result by pid in ascending order.
create or replace view Q8(pid, name, brand) as
    with staffmb(pid, name) as 
    (
        select distinct p.pid, p.firstname||' '||p.lastname
        from person p
        join staff s on s.pid = p.pid
        join policy po on s.sid = po.sid
        join insured_item ii on ii.id = po.id
        where po.status = 'E' 
        group by p.pid
        having count(distinct ii.brand) = 1
    )

    select distinct staffmb.pid, staffmb.name, ii.brand
    from staffmb
    join staff s on s.pid = staffmb.pid
    join policy po on s.sid = po.sid
    join insured_item ii on ii.id = po.id
    order by staffmb.pid ASC;


-- Q9: List clients (their firstname, a space and then the lastname as one column called name) 
-- who hold policies that cover all brands of vehicles recorded in the database. Ignore the policy
-- status and include the past and current policies. Order the result by pid in ascending order.
create or replace view Q9(pid, name) as
    with cbrand(brand, pid) as
    (
        select distinct(ii.brand), p.pid
        from person p 
        join client c on p.pid = c.pid
        join insured_by ib on ib.cid = c.cid
        join policy po on po.pno = ib.pno
        join insured_item ii on po.id = ii.id
        order by p.pid
    )

    select p.pid, p.firstname||' '||p.lastname  
    from person p
    join client c on p.pid = c.pid
    join insured_by ib on ib.cid = c.cid
    join policy po on po.pno = ib.pno
    where po.effectivedate <= CURRENT_DATE
    and not exists(
        (select distinct(brand) from insured_item)
        except
        (select cbrand.brand
        from cbrand
        where cbrand.pid = p.pid)
    )
    group by p.pid
    order by p.pid ASC;


-- Q10: Create a function that returns the total number of (distinct) staff that have worked 
-- (i.e., sells, rates, underwrites) on the given policy (ignore its status).
-- Return 0 if no policy exists for the given policy number.
create or replace function staffcount(pnogiven integer) returns integer
as $$
declare
    total_num integer;
begin 
    if pnogiven not in (select po.pno from policy po) then
        return 0;
    else
        select count(distinct s.sid) into total_num
        from staff s
        where s.sid in 
        (
            (
                select distinct(po.sid)
                from policy po
                where po.pno = pnogiven
            )
            union (
                select distinct(rb.sid)
                from policy po
                join coverage c on po.pno = c.pno
                join rating_record rr on rr.coid = c.coid
                join rated_by rb on rb.rid = rr.rid
                where c.pno = pnogiven
            )
            union (
                select distinct(ub.sid)
                from policy po
                join underwriting_record ur on ur.pno = po.pno
                join underwritten_by ub on ub.urid = ur.urid
                where po.pno = pnogiven
            )
        );
    end if;
    return total_num;
end;
$$ language plpgsql;


-- Q11: Create a stored procedure that will start renewing an existing policy in the database.
create or replace procedure renew(pnogiven integer) 
as $$
declare 
    new_pno integer := 1 + (select max(pno) from policy);
    old_cover coverage;
    old_ptype char(1);
    old_status character varying(2);
    old_effectivedate date;
    old_expirydate date;
    old_agreedvalue real;
    old_comments character varying(80);
    old_sid integer;
    old_id integer;
 
begin
    -- find the policy that given
    select po.ptype, po.status, po.effectivedate, po.expirydate, po.agreedvalue,
    po.comments, po.sid, po.id
    into old_ptype, old_status, old_effectivedate, old_expirydate, old_agreedvalue, 
    old_comments, old_sid, old_id
    from policy po 
    where po.pno = pnogiven;
 
    if old_id is not null then 
        -- do nothing if there exists another currently effective (i.e., enforced and still 
        -- effective as of today) policy of the same policy type for the same vehicle, 
        -- for the given policy number.
        if exists (select *
            from policy po
            where po.status = 'E' 
            and po.expirydate > CURRENT_DATE 
            and po.effectivedate <= CURRENT_DATE
            and po.id = old_id 
            and po.ptype = old_ptype 
            and po.pno != pnogiven) then 
            return;
        else
            insert into policy values (
                new_pno, 
                old_ptype,
                'D', 
                CURRENT_DATE, 
                CURRENT_DATE + (old_expirydate - old_effectivedate), 
                old_agreedvalue, 
                old_comments, 
                old_sid,
                old_id
            );
            
            if (old_status = 'E' and old_expirydate > CURRENT_DATE and 
            old_effectivedate <= CURRENT_DATE) then
                update policy 
                set expirydate = CURRENT_DATE
                where pno = pnogiven;
            end if;
           
            -- the same set of coverages will be created in the Coverage table for the newly created policy
            for old_cover in (select * from coverage c where c.pno = pnogiven) loop
                insert into coverage values (
                    1 + (select max(coid) from coverage),
                    old_cover.cname,
                    old_cover.maxamount,
                    old_cover.comments,
                    new_pno
                );
            end loop;
        end if;
    end if;
end;
$$ language plpgsql;

-- Q12: A staff member can purchase an insurance policy from the company, but none of the insured 
-- parties of the policy can be the agent, a rater, or an underwriter of that policy. Create a 
-- trigger (or triggers) to enforce this constraint while allowing a staff member to purchase a 
-- policy.

-- create a fucntion to check staff member can purchase an insurance policy from the company, but none of the insured 
-- parties of the policy can be the agent, a rater, or an underwriter of that policy.
create function checkStaff() returns trigger 
as $$
declare 
    findpno integer;
    findstaff staff;
    findcid integer;

begin
    -- find each staff  
    for findstaff in (select * from staff) loop
        -- find the staff is also a client
        select c.cid into findcid
        from person p 
        join client c on p.pid = c.pid
        where p.pid = findstaff.pid;

        if (findcid is not null) then
            -- find all policy that the staff purchase
            for findpno in (
                select po.pno 
                from policy po
                join insured_by ib on ib.pno = po.pno
                join client c on c.cid = ib.cid
                where c.cid = findcid
            ) loop
                
                -- the policy is sell by this staff
                if findstaff.sid in 
                    (
                        select po.sid
                        from policy po
                        where po.pno = findpno
                    )
                then
                    raise exception 'Invalid code % is an agent cannot be client of policy %', findcid, findpno;
                end if;
                
                -- if the policy is rated by this staff
                if findstaff.sid in 
                    (
                        select rb.sid
                        from rated_by rb 
                        join rating_record rr on rb.rid = rr.rid
                        join coverage co on co.coid = rr.coid
                        where co.pno = findpno
                    ) then
                    raise exception 'Invalid code % is an agent cannot be rater of policy %', findcid, findpno; 
                end if;

                -- if the policy is written by this staff
                if findstaff.sid in 
                    (
                        select ub.sid
                        from underwritten_by ub 
                        join underwriting_record ur on ur.urid = ub.urid
                        where ur.pno = findpno
                    ) then 
                    raise exception 'Invalid code % is an agent cannot be writter of policy %', findcid, findpno; 
                end if;
            end loop;
        end if;
    end loop;
    return new;
end;
$$ language plpgsql;  


 -- update or insert policy
create trigger policy_trig after insert or update
on policy for each row execute procedure checkStaff();

-- update or insert client
create trigger client_trig after insert or update
on client for each row execute procedure checkStaff();

-- update or insert insured_by
create trigger insured_by_trig after insert or update
on insured_by for each row execute procedure checkStaff();

-- update or insert underwritten_by
create trigger underwritten_by_trig after insert or update
on underwritten_by for each row execute procedure checkStaff();

-- update or insert underwriting_record 
create trigger underwriting_record_trig after insert or update
on underwriting_record for each row execute procedure checkStaff();

-- update or insert rated_by  
create trigger rated_by_trig after insert or update
on rated_by for each row execute procedure checkStaff();

-- update or insert rating_record  
create trigger rating_record_trig after insert or update
on rating_record for each row execute procedure checkStaff();

-- update or insert coverage  
create trigger coverage_trig after insert or update
on coverage for each row execute procedure checkStaff();

-- update or insert staff  
create trigger staff_trig after insert or update
on staff for each row execute procedure checkStaff();