--
-- PostgreSQL 21T1 ass1 database
--

CREATE TABLE client (
    pid integer NOT NULL,
    cid integer
);

CREATE TABLE coverage (
    coid integer,
    cname character varying(30),
    maxamount real,
    comments character varying(80),
    pno integer NOT NULL
);

CREATE TABLE insured_by (
    cid integer,
    pno integer
);

CREATE TABLE insured_item (
    id integer,
    brand character varying(20) NOT NULL,
    model character varying(30) NOT NULL,
    year integer NOT NULL,
    reg character varying(10) NOT NULL,
    CONSTRAINT insured_item_year_check CHECK (((year > 1900) AND (year < 2099)))
);

CREATE TABLE person (
    pid integer,
    firstname character varying(20) NOT NULL,
    lastname character varying(20) NOT NULL,
    bdate date NOT NULL,
    street character varying(30),
    suburb character varying(20),
    state character varying(3),
    postcode character(4)
);

CREATE TABLE policy (
    pno integer,
    ptype char(1) NOT NULL,
    status character varying(2) NOT NULL,
    effectivedate date,
    expirydate date,
    agreedvalue real,
    comments character varying(80),
    sid integer NOT NULL,
    id integer NOT NULL
);

CREATE TABLE rated_by (
    sid integer,
    rid integer,
    rdate date NOT NULL,
    comments character varying(80)
);

CREATE TABLE rating_record (
    rid integer,
    rate real,
    status char(1) NOT NULL,
    coid integer
);

CREATE TABLE staff (
    pid integer NOT NULL,
    sid integer
);

CREATE TABLE underwriting_record (
    urid integer,
    status char(1) NOT NULL,
    pno integer NOT NULL
);

CREATE TABLE underwritten_by (
    sid integer,
    urid integer,
    wdate date NOT NULL,
    comments character varying(80)
);


--
-- Inserting sample data below.
--

INSERT INTO client VALUES (9, 0);
INSERT INTO client VALUES (10, 1);
INSERT INTO client VALUES (11, 2);
INSERT INTO client VALUES (8, 3);
INSERT INTO client VALUES (12, 4);

INSERT INTO coverage VALUES (0, 'legal services', 5850, 'other benefit: refund of emergency expenses', 0);
INSERT INTO coverage VALUES (1, 'property damages', 30000, NULL, 0);
INSERT INTO coverage VALUES (2, 'legal services', 7500, 'other benefit: refund of emergency expenses', 1);
--INSERT INTO coverage VALUES (3, 'property damages', 20000, NULL, 1);
INSERT INTO coverage VALUES (4, 'property damages', 50000, NULL, 2);
--INSERT INTO coverage VALUES (5, 'third party', 10000000, NULL, 2);
INSERT INTO coverage VALUES (6, 'property damages', 35000, NULL, 4);
INSERT INTO coverage VALUES (7, 'third party', 10000000, NULL, 4);
INSERT INTO coverage VALUES (8, 'third party', 20000000, NULL, 5);
INSERT INTO coverage VALUES (9, 'third party', 15000000, NULL, 6);
INSERT INTO coverage VALUES (10, 'third party', 30000000, NULL, 7);
INSERT INTO coverage VALUES (11, 'extra liability cover', 10000000, NULL, 7);
--INSERT INTO coverage VALUES (12, 'third party', 20000000, NULL, 11);

INSERT INTO insured_by VALUES (0, 0);
INSERT INTO insured_by VALUES (1, 0);
INSERT INTO insured_by VALUES (0, 1);
INSERT INTO insured_by VALUES (1, 1);
INSERT INTO insured_by VALUES (0, 2);
INSERT INTO insured_by VALUES (1, 2);
INSERT INTO insured_by VALUES (2, 3);
INSERT INTO insured_by VALUES (3, 4);
INSERT INTO insured_by VALUES (4, 4);
INSERT INTO insured_by VALUES (3, 5);
INSERT INTO insured_by VALUES (4, 5);
INSERT INTO insured_by VALUES (3, 6);
INSERT INTO insured_by VALUES (4, 6);
INSERT INTO insured_by VALUES (3, 7);
INSERT INTO insured_by VALUES (4, 7);
--INSERT INTO insured_by VALUES (4, 8);
--INSERT INTO insured_by VALUES (3, 9);
--INSERT INTO insured_by VALUES (3, 10);
--INSERT INTO insured_by VALUES (3, 11);

INSERT INTO insured_item VALUES (0, 'Nissan', 'Micra K11 LX', 2005, 'NTQ-254');
INSERT INTO insured_item VALUES (1, 'Nissan', 'Micra K11 LX', 2009, 'VCN-214');
--INSERT INTO insured_item VALUES (2, 'Nissan', 'Micra K11 LX', 2015, 'XMD-260');
INSERT INTO insured_item VALUES (3, 'Nissan', 'Micra K11 LX', 2017, 'LKH-886');
INSERT INTO insured_item VALUES (4, 'Toyota', 'Camry Altise', 2014, 'ATB-252');
--INSERT INTO insured_item VALUES (5, 'Toyota', 'Camry Altise', 2014, 'CDZ-848');
--INSERT INTO insured_item VALUES (6, 'Toyota', 'Ateva', 2012, 'UYT-962');
INSERT INTO insured_item VALUES (7, 'Honda', 'Civic', 2016, 'TCL-222');

INSERT INTO person VALUES (0, 'Jack', 'White', '1951-09-15', '215 Main St.', 'Rosslea', 'QLD', '4007');
INSERT INTO person VALUES (1, 'David', 'Lee', '1976-10-05', '21 George St.', 'Tissa', 'QLD', '4007');
INSERT INTO person VALUES (2, 'Mary', 'Jones', '1990-01-11', '87 Alex Av.', 'Parramatta', 'NSW', '2165');
INSERT INTO person VALUES (3, 'Vicky', 'Donald', '1982-10-11', '21 Pitt St.', 'Surry Hill', 'NSW', '2000');
INSERT INTO person VALUES (4, 'Vincent', 'Thomas', '1973-01-17', '458 Clevelend St.', 'Kingsford', 'NSW', '2052');
INSERT INTO person VALUES (5, 'Teresa', 'Story', '1985-12-23', '458 Knox St.', 'Epping', 'NSW', '2012');
INSERT INTO person VALUES (6, 'Alice', 'Wang', '1978-07-31', '92 Leon St.', 'Wooloomooloo', 'NSW', '2002');
INSERT INTO person VALUES (7, 'David', 'Bond', '1965-08-30', '1 Johnson St.', 'Green Square', 'NSW', '2083');
INSERT INTO person VALUES (8, 'Frederick', 'Brown', '1975-03-28', '4 Good St.', 'Wooloomooloo', 'NSW', '2091');
INSERT INTO person VALUES (9, 'Lucy', 'Smiths', '1968-04-02', '5 Hamony St.', 'Alexendria', 'NSW', '2008');
INSERT INTO person VALUES (10, 'Tom', 'Hanks', '1959-04-04', '50 George St.', 'North Sydney', 'NSW', '2060');
INSERT INTO person VALUES (11, 'Nicole', 'Kidman', '1962-08-16', '50 Military Rd.', 'North Sydney', 'NSW', '2060');
INSERT INTO person VALUES (12, 'Rose', 'Byrne', '1964-12-01', '285 George St.', 'North Sydney', 'NSW', '2060');
INSERT INTO person VALUES (13, 'Chris', 'Evan', '1975-05-22', '12 Captain Rd.', 'Parramatta', 'NSW', '2165');
INSERT INTO person VALUES (14, 'Tom', 'Holland', '1978-11-19', '59 Barker St.', 'Kingsford', 'NSW', '2052');
INSERT INTO person VALUES (15, 'Peter', 'Pan', '2005-01-20', '123 Anzac Pde.', 'Kingsford', 'NSW', '2052');

INSERT INTO policy VALUES (0, 'C', 'RR', '2020-11-01', '2021-08-13', 16500, 'The driver had an accident in the last 5 years, Use for business', 0, 0);
INSERT INTO policy VALUES (1, 'C', 'RU', '2020-11-16', '2021-09-11', 36500, 'The driver had an accident in the last 5 years, Use for business', 0, 0);
INSERT INTO policy VALUES (2, 'C', 'E', '2020-12-13', '2021-09-23', 46500, 'The driver had an accident in the last 5 years, Use for business', 0, 0);
INSERT INTO policy VALUES (3, 'C', 'D', '2021-04-17', '2022-08-09', 26500, 'The driver had an accident in the last 5 years, Use for business', 3, 1);
INSERT INTO policy VALUES (4, 'P', 'E', '2020-12-16', '2022-08-12', 56500, 'Young driver', 4, 3);
INSERT INTO policy VALUES (5, 'G', 'E', '2020-12-16', '2022-10-12', 16500, NULL, 4, 4);
INSERT INTO policy VALUES (6, 'G', 'E', '2018-12-16', '2020-12-16', 32500, NULL, 5, 7);
INSERT INTO policy VALUES (7, 'G', 'E', '2020-12-16', '2022-10-12', 20800, NULL, 5, 7);
--INSERT INTO policy VALUES (8, 'T', 'E', '2019-11-15', '2020-10-12', 27200, NULL, 3, 7);
--INSERT INTO policy VALUES (9, 'T', 'E', '2019-12-16', '2020-10-12', 31200, NULL, 4, 7);
--INSERT INTO policy VALUES (10, 'P', 'E', '2020-12-16', '2022-10-12', 33500, NULL, 5, 6);
--INSERT INTO policy VALUES (11, 'P', 'E', '2020-12-16', '2022-10-12', 16500, NULL, 6, 6);

INSERT INTO rated_by VALUES (0, 0, '2020-10-01', 'not 100% sure');
INSERT INTO rated_by VALUES (1, 0, '2020-10-02', 'approved');
INSERT INTO rated_by VALUES (1, 1, '2020-10-05', 'need more information');
INSERT INTO rated_by VALUES (2, 1, '2020-10-05', 'need more information');
INSERT INTO rated_by VALUES (0, 2, '2020-10-09', 'need more information');
INSERT INTO rated_by VALUES (1, 2, '2020-10-10', 'need more information');
INSERT INTO rated_by VALUES (0, 3, '2020-10-12', 'approved');
INSERT INTO rated_by VALUES (0, 4, '2020-11-20', 'coverage too high');
INSERT INTO rated_by VALUES (0, 5, '2020-11-22', 'approved');
INSERT INTO rated_by VALUES (4, 6, '2020-11-22', 'approved');
INSERT INTO rated_by VALUES (5, 6, '2020-11-23', 'approved');
INSERT INTO rated_by VALUES (4, 7, '2020-11-23', 'approved');
INSERT INTO rated_by VALUES (4, 8, '2020-11-23', 'approved');
INSERT INTO rated_by VALUES (4, 9, '2018-11-20', 'approved');
INSERT INTO rated_by VALUES (4, 10, '2020-11-23', 'approved');
INSERT INTO rated_by VALUES (5, 11, '2020-11-24', 'approved');
--INSERT INTO rated_by VALUES (0, 12, '2020-01-12', 'approved');

INSERT INTO rating_record VALUES (0, 100, 'A', 0);
INSERT INTO rating_record VALUES (1, 300, 'R', 1);
INSERT INTO rating_record VALUES (2, 200, 'R', 2);
INSERT INTO rating_record VALUES (3, 500, 'A', 2);
INSERT INTO rating_record VALUES (4, 300, 'R', 4);
INSERT INTO rating_record VALUES (5, 1500, 'A', 4);
INSERT INTO rating_record VALUES (6, 300, 'A', 6);
INSERT INTO rating_record VALUES (7, 600, 'A', 7);
INSERT INTO rating_record VALUES (8, 400, 'A', 8);
INSERT INTO rating_record VALUES (9, 100, 'A', 9);
INSERT INTO rating_record VALUES (10, 250, 'A', 10);
INSERT INTO rating_record VALUES (11, 230, 'A', 11);
--INSERT INTO rating_record VALUES (12, 120, 'A', 12);

INSERT INTO staff VALUES (0, 0);
INSERT INTO staff VALUES (1, 1);
INSERT INTO staff VALUES (2, 2);
INSERT INTO staff VALUES (3, 3);
INSERT INTO staff VALUES (4, 4);
INSERT INTO staff VALUES (5, 5);
INSERT INTO staff VALUES (6, 6);
INSERT INTO staff VALUES (7, 7);
INSERT INTO staff VALUES (8, 8);
INSERT INTO staff VALUES (9, 9);

INSERT INTO underwriting_record VALUES (0, 'R', 1);
INSERT INTO underwriting_record VALUES (1, 'R', 2);
INSERT INTO underwriting_record VALUES (2, 'A', 2);
INSERT INTO underwriting_record VALUES (3, 'A', 4);
INSERT INTO underwriting_record VALUES (4, 'R', 5);
INSERT INTO underwriting_record VALUES (5, 'A', 5);
INSERT INTO underwriting_record VALUES (6, 'A', 6);
INSERT INTO underwriting_record VALUES (7, 'A', 7);

INSERT INTO underwritten_by VALUES (0, 0, '2020-11-02', 'rate is inappropriate');
INSERT INTO underwritten_by VALUES (0, 1, '2020-11-29', 'missing driver qualification');
INSERT INTO underwritten_by VALUES (0, 2, '2020-12-03', 'rate is appropriate');
INSERT INTO underwritten_by VALUES (6, 3, '2020-12-05', 'rate is appropriate');
INSERT INTO underwritten_by VALUES (5, 4, '2020-12-06', 'missing key documents');
INSERT INTO underwritten_by VALUES (4, 5, '2020-12-09', 'rate is appropriate');
INSERT INTO underwritten_by VALUES (5, 6, '2018-12-09', 'rate is appropriate');
INSERT INTO underwritten_by VALUES (1, 7, '2020-12-10', 'rate is appropriate');
INSERT INTO underwritten_by VALUES (4, 7, '2020-12-11', 'rate is appropriate');


--
-- Add the table contraints to the tables.
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (cid);

ALTER TABLE ONLY coverage
    ADD CONSTRAINT coverage_pkey PRIMARY KEY (coid);

ALTER TABLE ONLY insured_by
    ADD CONSTRAINT insured_by_pkey PRIMARY KEY (cid, pno);

ALTER TABLE ONLY insured_item
    ADD CONSTRAINT insured_item_pkey PRIMARY KEY (id);

ALTER TABLE ONLY insured_item
    ADD CONSTRAINT insured_item_reg_key UNIQUE (reg);

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey PRIMARY KEY (pid);

ALTER TABLE ONLY policy
    ADD CONSTRAINT policy_pkey PRIMARY KEY (pno);

ALTER TABLE ONLY rated_by
    ADD CONSTRAINT rated_by_pkey PRIMARY KEY (sid, rid);

ALTER TABLE ONLY rating_record
    ADD CONSTRAINT rating_record_pkey PRIMARY KEY (rid);

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (sid);

ALTER TABLE ONLY underwriting_record
    ADD CONSTRAINT underwriting_record_pkey PRIMARY KEY (urid);

ALTER TABLE ONLY underwritten_by
    ADD CONSTRAINT underwritten_by_pkey PRIMARY KEY (urid, sid);

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pid_fkey FOREIGN KEY (pid) REFERENCES person(pid);

ALTER TABLE ONLY coverage
    ADD CONSTRAINT coverage_pno_fkey FOREIGN KEY (pno) REFERENCES policy(pno);

ALTER TABLE ONLY insured_by
    ADD CONSTRAINT insured_by_cid_fkey FOREIGN KEY (cid) REFERENCES client(cid);

ALTER TABLE ONLY insured_by
    ADD CONSTRAINT insured_by_pno_fkey FOREIGN KEY (pno) REFERENCES policy(pno);

ALTER TABLE ONLY policy
    ADD CONSTRAINT policy_id_fkey FOREIGN KEY (id) REFERENCES insured_item(id);

ALTER TABLE ONLY policy
    ADD CONSTRAINT policy_sid_fkey FOREIGN KEY (sid) REFERENCES staff(sid);

ALTER TABLE ONLY rated_by
    ADD CONSTRAINT rated_by_rid_fkey FOREIGN KEY (rid) REFERENCES rating_record(rid);

ALTER TABLE ONLY rated_by
    ADD CONSTRAINT rated_by_sid_fkey FOREIGN KEY (sid) REFERENCES staff(sid);

ALTER TABLE ONLY rating_record
    ADD CONSTRAINT rating_record_coid_fkey FOREIGN KEY (coid) REFERENCES coverage(coid);

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pid_fkey FOREIGN KEY (pid) REFERENCES person(pid);

ALTER TABLE ONLY underwriting_record
    ADD CONSTRAINT underwriting_record_pno_fkey FOREIGN KEY (pno) REFERENCES policy(pno);

ALTER TABLE ONLY underwritten_by
    ADD CONSTRAINT underwritten_by_sid_fkey FOREIGN KEY (sid) REFERENCES staff(sid);

ALTER TABLE ONLY underwritten_by
    ADD CONSTRAINT underwritten_by_urid_fkey FOREIGN KEY (urid) REFERENCES underwriting_record(urid);
