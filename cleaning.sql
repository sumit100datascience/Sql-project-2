select * from laptopbackup;
#1Lets first create a backup of the data in case while cleaning we lost  the data
create table latopback like laptopback;
select * from laptopback;
#Lets insert the values in the laptopback
insert into laptopback
(select * from laptopbackup);
#lets check if it has entered
select * from laptopback;
#Lets check how much memory is occupied in the memory before the cleanup;
select data_length/1024 from information_schema.Tables
where table_schema='campusx' and table_name='laptopbackup';
#we have around 240kb of data.
#We will now drop columns that are not necessary
select * from laptopbackup;
#Right now Unnamed column is not necessary so we drop it
ALTER TABLE laptopbackup
DROP COLUMN  `Unnamed: 0`;
SELECT * from laptopbackup;
#DROPPING NULL VALUES FROM all the rows that have all rows filled with null values;
SELECT index_no FROM laptopbackup
WHERE Company is null 
and TypeName is null 
and Inches is null
and ScreenResolution is null
and Cpu is null
and Ram is null
and Memory is null
and Gpu is null
and OpSys is null
and Weight is null
and price is null;
#There is no null values but there are values which are blank and contains either inches or or price as zero
#So we are going to delete such rows;
delete from laptopbackup where index_no in (select index_no from laptopbackup
where Price=0 or Inches=0);
select * from laptopbackup;
select count(*) from laptopbackup;
#As we can see the rows have reduced to 1272 .Hence the unuseful data has been eliminated.
#Now lets see if there any duplicates if there are any we will delete it.
select * from laptopbackup;
delete from laptopbackup where index_no not in (select  min(index_no)
from laptopbackup
group by  Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price
having count(*)>1);
select * from laptopbackup:
#As we can see i have deleted by mistakely all the rows that should not be deleted,but fortunately we have the backup so 
#we will use the backup data.
#The backup data is laptop.
# In these data there is no duplicates.
#Lets do cleaning now
# to change the datatype of inches
alter table laptop modify column inches decimal(10,1); 
SELECT * FROM campusx.laptop;
# To delete gb from ram column
update laptop l1
set ram=
(select replace(Ram,"GB",' ') from laptop l2
 where l2.index_no=l1.index_no);
 select * from laptop;
 #Since we have removed gb in ram column now we will change it to integer
 alter table laptop modify column Ram INTEGER;

 alter table laptop modify column inches decimal(10,1);
  #Weight writin os name in structure;
  update laptop l1
  set Weight=(select replace(weight,"kg"," ") from laptop l2
  where l2.index_no=l1.index_no);
  select* from laptop;
  #Here again we change the dtype to decimal 
alter table laptop modify column Weight  decimal(10,2);
#Rounding the price column;
update laptop l1
set price=(select round(price) from laptop l2
  where l2.index_no=l1.index_no);
  #converting price datatype from double to integer
alter table laptop modify column Price INTEGER;
#Working on OpSys;
Select OpSys,
CASE
    WHEN OpSys like '%mac%' then 'macos'
    WHEN OpSys like  'windows%' then 'windows'
	WHEN OpSys like  '%linux%' then 'linux'
	WHEN OpSys='No Os' then 'N/A'
    ELSE 'other'
END AS 'os_brand'
from laptop;
#To update  the new column os_brand values permanently inplace of OPSYs in the laptop ;
update laptop
set OpSys=CASE
    WHEN OpSys like '%mac%' then 'macos'
    WHEN OpSys like  'windows%' then 'windows'
	WHEN OpSys like  '%linux%' then 'linux'
	WHEN OpSys='No Os' then 'N/A'
    ELSE 'other'
END;
#Lets work with GPU;
alter table laptop
add column gpu_brand varchar(255) after Gpu,
add column gpu_name varchar(255) after gpu_brand;
select * from laptop;
update laptop l1
set gpu_brand=(select substring_index(Gpu," ",1) from laptop l2
                where l2.index_no=l1.index_no);
select * from laptop;
select * from laptop;
update laptop l1
set gpu_name=(select replace(Gpu,gpu_brand," ") from laptop l2
              where l2.index_no=l1.index_no);#inside query will replace Gpuname by removing gpubrand and adding nothing bto it.
select * from laptop;
#Now lets drop the original Gpu column;
alter table laptop drop column Gpu;
Select * from laptop;
##lets do for cpu;
alter table laptop
add column cpu_brand varchar(255) after cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed varchar(255) after cpu_name ;
select * from laptop;
#updating the cpu_brand column:
update laptop l1
set cpu_brand=(select substring_index(Cpu," ",1) from laptop l2
			where l2.index_no=l1.index_no);
select * from laptop;
#Now lets try to fill processor speed;
update laptop l1
set cpu_speed=(select cast(replace(substring_index(Cpu," ",-1),"GHz","c ")
                       as decimal(10,2)) from laptop l2
			where l2.index_no=l1.index_no);
select * from laptop;
select * from laptop;
select ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",-1)
from  laptop;
alter table laptop 
add column resolution_width INTEGER after ScreenResolution,
add column resolution_height INTEGER after resolution_width;
select * from laptop;
update laptop l1
set resolution_width=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",1),
resolution_height=SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",-1);
select * from laptop;
alter table laptop
add column touchscreen INTEGER after resolution_height;
select * from laptop;
select ScreenResolution LIKE '%touch%' from laptop;
update laptop
set touchscreen= ScreenResolution LIKE '%touch%';
select * from laptop;
alter table laptop
drop column ScreenResolution;
Select * from laptop;
#updating cpu_name
update laptop
set cpu_name=substring_index(SUBSTRING_INDEX(cpu," " ,3)," ",-2);
select * from laptop;
#removing Cpu column permannently
alter table laptop
drop column Cpu;
select * from laptop;
#Now lets work on the Memory Column:
#memory column will be converted into type,primary and secondary
#lets first create the three new columns;
alter table laptop
add column memory_type varchar(255) after memory,
add column primary_storage  varchar(255) after memory_type,
add column secondary_storage  varchar(255) after primary_storage;
select memory,
case 
when memory like '%SSD%' and memory like '%HDD%'then 'Hybrid'
when memory like '%SSD%'  then  'SSD'
when memory like '%HDD%' then  'HDD'
when memory like '%flash Storage%' then 'Flash Storage'
when memory like  '%hybrid%' then 'hybrid'
when memory like '%flash Storage%' and memory like '%HDD%'then 'Hybrid'
else
null
end as 'memory_type'
from laptop;
update laptop
set memory_type=case 
when memory like '%SSD%' and memory like '%HDD%'then 'Hybrid'
when memory like '%SSD%'  then  'SSD'
when memory like '%HDD%' then  'HDD'
when memory like '%flash Storage%' then 'Flash Storage'
when memory like  '%hybrid%' then 'hybrid'
when memory like '%flash Storage%' and memory like '%HDD%'then 'Hybrid'
else
null
end;
select * from laptop;
#lets do for primary and  secondary  
select memory,
REGEXP_SUBSTR(substring_index(memory,'+',1),'[0-9]+'),
case when memory like '%+%' then substring_index(memory,'+',-1) else 0 end
from laptop;
update  LAPTOP
SET primary_storage=REGEXP_SUBSTR(substring_index(memory,'+',1),'[0-9]+'),
secondary_storage=case when memory like '%+%' then substring_index(memory,'+',-1) else 0 end;
select * from laptop;
select primary_storage,
case when primary_storage<3 then primary_storage*1024 else primary_storage end,
secondary_storage,
case when secondary_storage<3 then secondary_storage*1024 else secondary_storage end
from laptop;
update laptop 
set primary_storage=case when primary_storage<3 then primary_storage*1024 else primary_storage end,
secondary_storage =case when secondary_storage<3 then secondary_storage*1024 else secondary_storage end;
select * from laptop;
alter table laptop
drop column memory;
select * from laptop;
select * from laptop;
select data_length/1024 from information_schema.Tables
where table_schema='campusx' and table_name='laptop';
select * from laptop;













 




                



  
  
 