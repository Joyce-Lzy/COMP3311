-- Schema for WebLog database
--
-- Written by: John Shepherd (March 2004)
-- Last modified by: John Shepherd (August 2006)

create table Hosts (
	id          integer,
	ipaddr      varchar(20) unique,
	hostname    varchar(100),
	primary key (id)
);

create table Sessions (
	id          int, 
	host        integer,
	complete    boolean,
	primary key (id),
	foreign key (host) references Hosts(id)
);

create table Accesses (
	session     int,
	seq         int,
	course      int,
	page        varchar(200),
	params      varchar(200),
	accTime     timestamp,
	nbytes      integer,
	primary key (session,seq),
	foreign key (session) references Sessions(id)
);
