
use VIP;
go
create table student1
(
   id int primary key identity(1000,1),
   name nvarchar(20) not null,   --����
   sex nvarchar(1) not null,     --�Ա�    1λ
   num nvarchar(11) not null,    --ѧ��   10λ
   grade int,                    --�꼶
   acad nvarchar(20),            --Ժϵ
   tel nvarchar(11) not null,    --�绰  11λ
   qq nvarchar(15),              --qq
)
select * from student1;
go