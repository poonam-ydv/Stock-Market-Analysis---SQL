-- SQL ASSIGNMENT to generate BUY , Sell or HOLD signal based on the data extracted from nse for bajaj auto , hero motocorp , eicher motors , tcs , infosys and tvs motors 
-- STEP 1 
-- created a new schema called assignment and imported the data from provided excel files to it.
use assignment;

-- STEP 2
-- creating temperory tables to alter the datatype of the date fields in the tables
create table bajajtemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from bajaj_auto; 
create table eichertemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from eicher_motors;
create table herotemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from hero_motocorp;
create table infosystemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from infosys;
create table tcstemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from tcs;
create table tvstemp select str_to_date(Date,'%d-%M-%Y') Date,`Close Price` from tvs_motors;

-- STEP 3
-- The next step is to calculate  20 DMA and 50 DMA for all the shares 

-- Bajaj Auto
create table bajaj1
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
FROM bajajtemp;

-- Eicher Motors
create table eicher1 
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
FROM eichertemp;

-- Hero Motocorp
create table hero1
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
from herotemp;

-- Infosys
create table infosys1
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
from infosystemp;

-- TCS
create table tcs1
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
from tcstemp;

-- TVS Motors
create table tvs1
as 
SELECT Date, `Close Price`,
avg(`close price`) over (order by Date rows between 19 preceding and current row) as `20 Day MA`,
avg(`close price`) over (order by Date rows between 49 preceding and current row) as `50 Day MA`
from tvstemp;

-- STEP 4 
-- Create a master table to combine all the tables created in STEP 3
create table master_table 
select b.Date as Date,b.`Close Price` as Bajaj, e.`Close Price` as Eicher, h.`Close Price` as Hero, i.`Close Price` as Infosys, 
t.`Close Price` as TCS, tv.`Close Price` as TVS
from bajaj1 b
join eicher1 e on b.Date = e.Date 
join hero1 h on b.Date = h.Date
join infosys1 i on b.Date = i.Date
join tcs1 t on b.Date = t.Date
join tvs1 tv on b.Date = tv.Date;

-- dispaly the data in master tables
select * from master_table;

-- STEP 5 
-- Creating BUY or SELL for each of the shares

create table bajaj2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from bajaj1;     
  
create table eicher2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from eicher1;

create table hero2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from hero1;

create table infosys2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from infosys1;

create table tcs2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from tcs1;

create table tvs2
select `Date` , `Close Price`,
case
		when `20 Day Ma` > `50 Day Ma` and lag(`20 Day Ma`) over() < lag(`50 Day Ma`) over() then 'BUY'
        when `20 Day Ma` < `50 Day Ma` and lag(`20 Day Ma`) over() > lag(`50 Day Ma`) over() then 'SELL'
        else 'HOLD'
end as `Signal`
from tvs1;               

-- STEP 6         
-- Create a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for all the stocks
delimiter $$
create function signalforTheDay ( given_date varchar(10) )
returns varchar(4)
deterministic
begin
declare signal_value varchar(4);
select `Signal` into signal_value from bajaj2 where date=STR_TO_DATE(given_date, "%Y-%m-%d");
return signal_value;
end$$ 
delimiter ;

select signalForTheDay('2015-05-28') as `Signal`; -- HOLD
select signalForTheDay('2015-06-01') as `Signal`; -- HOLD
select signalForTheDay('2015-08-24') as `Signal`; -- SELL
select signalForTheDay('2015-11-30') as `Signal`; -- HOLD
select signalForTheDay('2015-12-11') as `Signal`; -- SELL
