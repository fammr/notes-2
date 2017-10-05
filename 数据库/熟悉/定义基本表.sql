use STU;

create table Student          --ѧ����ϵ
(
   sno char(10) primary key,  --ѧ��,����
   sname varchar(20) not null, --����
   sage smallint,              --����(�Ƚ�С,ֱ����smallint)
   ssex char(2),               --�Ա�
   sdept varchar(20)             --Ժϵ
)

create table Course            --�γ̹�ϵ
(
   cno char(10),               --�γ̺�(����)
   primary key(cno),           --
   cname varchar(20),          --�γ���
   cpno char(10),              --���п�
   credit smallint             --ѧ��(�Ƚ�С,ֱ����smallint)
)

create table SC                --ѡ�޹�ϵ
( 
   sno char(10),               --ѧ��
   cno char(10),               --�γ̺�
   grade smallint,             --�ɼ�
   primary key(sno,cno)        --ѧ�źͿγ̺�(����)
)

--ɾ����ϵ,���е�����Ҳ�ᱻɾ��
drop table Student;   --һ��һ����ɾ��,���ݽ����ܱ��ָ�

--���ӱ��е�����
--allow null (����ӵ�����Ҫ����Ϊ��)
alter table Student add phone char(16);

--�޸ı��е�ĳ����
alter table Student alter column sdept varchar(100) not null;

--ɾ�����е�ĳ����
alter table Student drop column sage;

--1������Student��Course��SC���ű���ʱ�����������Ψһ��Unique����
--2��ΪStudent����Ӽ��ᣨ50�����ȵı䳤�ַ������У��鿴��ṹ��
alter table Student add guanji varchar(50);

--3����Student���еġ����ᡱ�е����;��ȸ�Ϊ100���鿴��ṹ��
alter table Student alter column guanji varchar(100);
--4��ɾ��Student��ġ����ᡱ�С�
alter table Student drop column guanji;
--5��ɾ�������ű�
drop table Student;
drop table SC;
drop table Course;

--����ϵģʽ������˳��
insert into Student values('01001','����',27,'M','CS','10');
--��ָ��������˳��,Ҳ������Ӳ�������(��null����Ϊ����)
insert into Student(sno,sage,sname) values('01002',20,'����');

--ɾ������Ԫ��
delete from Student where sno='1';

--ɾ�����Ԫ��
delete from Student where ssex='F';

--ɾ��������ϵ�е���������
delete from Student;

--ɾ������������ĳ��(ĳЩ)Ԫ�������ֵ
--��:��001ѧ��ת��MAϵ
update Student set sdept='MA',sage=sage+1 where sno='001';
--���е�ѧ�������1
update Student set sage=sage+1;

     /*----------------��ϰ-------------------*/
--1��ΪStudent��10�����ϣ���Course��8�����ϣ���SC��25�����ϣ�����Ӽ�¼��
insert into Student values('01001','qq',27,'M','CS');
insert into Student values('01002','ww',20,'M','IS');
insert into Student values('01003','ee',22,'F','CS');
insert into Student values('01004','rr',18,'M','MA');
insert into Student values('01005','tt',26,'M','CS');
insert into Student values('01006','yy',20,'F','IS');
insert into Student values('01007','uu',25,'M','CS');
insert into Student values('01008','ii',21,'F','CS');
insert into Student values('01009','oo',22,'F','MA');
insert into Student values('010010','pp',21,'M','CS');

insert into Course values('1','���ݽṹ','5',5);
insert into Course values('2','��ѧ','4',1);
insert into Course values('3','Ӣ��','2',5);
insert into Course values('4','����','1',4);
insert into Course values('5','C����','4',2);
insert into Course values('6','C++','4',1);
insert into Course values('7','Java','1',2);
insert into Course values('8','Android','7',4);
insert into Course values('9','C#','8',5);

insert into SC values('01001','1',70);
insert into SC values('01001','2',80);
insert into SC values('01001','3',40);
insert into SC values('01001','4',45);
insert into SC values('01001','5',61);
insert into SC values('01002','7',61);
insert into SC values('01002','5',61);
insert into SC values('01002','8',61);
insert into SC values('01002','1',61);
insert into SC values('01003','5',61);
insert into SC values('01003','8',61);
--2��ΪStudent������С��༶�š� ��10�����ȶ����ַ�������
alter table Student add classnum char(10);
alter table Student alter column classnum varchar(100);
--3��Ϊѧ����д�༶�ţ����֣���
update Student set classnum='10'; 
--4����ÿ��ͬѧ�İ༶��ǰ��/������ϡ�T����
--update ���� set �ֶ���=�ֶ���+'Ҫ����ַ���'
update Student set classnum='T'+classnum;
--5��ɾ���༶��ǰ��/����ġ�T����
--update �� set �ֶ�=substring(�ֶ�,2,len(�ֶ�)-1) �Ϳ�����
--substring �ǽ�ȡ�ַ��� 2 �Ǵӵڶ�����ȡ  len(�ֶ�)-1 �ǽ�ȡ���ٸ�
update Student set classnum=SUBSTRING(classnum,2,len(classnum)-1);
--6��ɾ���༶��Ϊ�յ�ѧ����
delete from Student where classnum is null;
--7��ɾ���ɼ�����50�ֵ�ѧ����ѡ����Ϣ��
delete from SC where grade<50;

       /*-----------���ݲ�ѯ------------*/
select sname from Student;
--select�Ӿ��ȱʡ����Ǳ����ظ�Ԫ��(all),����distinctȡ���ظ�Ԫ��
--ȥ���ظ�Ԫ��ʱ:��ʱ
select all sdept from Student;
select distinct sdept from Student;
select distinct sdept,ssex from Student;
--�Ǻ�*:����ϵģʽ�����Ե�˳������
select * from Student;

--select�Ӿ�--����
--Ϊ������е�ĳ�����Ը���,ʹ����߿ɶ���

select sno as 'ѧ��',cno as �γ̺�,grade as �ɼ� from SC; --�����ʾ������Ч����ԭ��ѧ��������ʾ����sno,������ʾѧ��
--��ѧ�Ŷ�Ӧ�ĳ�������ʾ����,��������������birthyear
select sno,YEAR(GETDATE())-sage as birthyear from Student; 

--where�Ӿ�
--�Ƚϣ�<��<=��>��>=��=��<> ��
--ȷ����Χ��
--	Between  A  and  B��Not Between A and B
--ȷ�����ϣ�IN��NOT IN
--�ַ�ƥ�䣺LIKE��NOT LIKE
--��ֵ��IS NULL��IS NOT NULL
--����������AND��OR��NOT

--where�Ӿ�--like
--�ַ�ƥ��:like,not like 
--1.ͨ���
   --%   ƥ�������ַ���
   --_   ƥ������һ���ַ�
--2.��Сд����
--��:�г����ŵ�ѧ����ѧ��,����
select sno as 'ѧ��',sname as '����' from Student where sname like '��%'
--�����г������ҵ���(2����)��ѧ����ѧ�š�������
select sno,sname from Student where sname like '��_'

--where�Ӿ�----ת���escape
--��:�г��γ������д���'_'�Ŀγ̺ż��γ���
select cno,cname from Course where cname like '%\_%' escape '\';

--    from�Ӿ�
--�г���Ҫ����ѯ�Ĺ�ϵ(��)
--�����г�����ѧ����ѧ�š��������κš��ɼ���
select Student.sno,sname,cno,grade from Student,SC where Student.sno=SC.sno;--������Ҫ����2�ű�

--    order by�Ӿ�
--ָ���������������д���
--��ʱ
--ASC����(ȱʡ),DESC(����)
--�����г�CSϵ�е�������ѧ�š��������Ա�����䣬��������������У�����
select sno,sname,ssex,sage from Student where sdept='CS' and ssex='M' order by sage desc;

--����ѡ��C01��C02��ѧ��ѧ��
select sno from SC where cno='C01' or cno='C02';

--�����ɼ���70����80��֮���ѧ��ѧ��,�γ̺źͳɼ�
select sno,cno,grade from SC where grade<=80 and grade>=70;  --OK
select * from SC where grade between 70 and 80;              --OK

--����ѧ��Ϊ001,003,004��ͬѧ������,����(���䰴��������)
select sname,sage from Student where sno='001' or sno='003' or sno='004' order by sage; --OK
select sno,sage from Student where sno in('001','003','004') order by sage;             --very good

--��������ͬѧ��ѧ�γ̵Ŀγ̺ż��ɼ�
select cno,grade from SC,Student where 
SC.sno = Student.sno and sname='����';

--��������ѧ����������ѡ�����ƺͳɼ�
select sname,cname,grade from Student,SC,Course where 
Student.sno=SC.sno and SC.cno=Course.cno;

--��ѯѡ�ޡ�c05���γ̣��������䲻����26���ѧ����ѧ�źͳɼ��������ɼ��������С� 
select Student.sno,grade from Student,SC where 
Student.sno=SC.sno and cno='c05' and sage<=26 order by grade DESC;


         /*------------��ϰ--select-------------*/
--1����ѯMAϵ��Ůͬѧ��
select * from Student where sdept='MA' and ssex='F';
--2����ѯCSϵ�����ѧ��ѡ�޵Ŀγ̣��г�ѧ�ţ��γ̺źͳɼ���
select Student.sno as 'ѧ��',cno as '�γ̺�',grade as '�ɼ�',sname from Student,SC where Student.sno=SC.sno and sdept='CS' and sname like '��%';
--3����ѯѡ�������ݿ�γ̵�ѧ����ѧ�ţ��ɼ������ɼ��������С�
select Student.sno,grade from Student,SC,Course where Student.sno=SC.sno and SC.cno=Course.cno and cname='���ݿ�' order by grade DESC;
--4���ҳ�ѧ��Ϊ4�����ϵĿγ̵�ѡ��������г�ѧ�ţ��γ������ɼ���
select Student.sno as 'ѧ��',sname as '�γ���',grade as '�ɼ�' from Student,SC,Course
where Student.sno=SC.sno and SC.cno=Course.cno and credit>4;
--5���������ݿ�ĳɼ���90�����ϵ�ѧ����ѧ�ź�������
select Student.sno,sname from Student,SC,Course where Student.sno=SC.sno and SC.cno=Course.cno and grade>90 and cname='���ݿ�';

--         �Ӳ�ѯ(Subquery)
--�Ӳ�ѯ��Ƕ������һ��ѯ�е�select-from-where ���ʽ(where/having)
--SQL������Ƕ��,���ڶ���½��з���,�Ӳ�ѯ�Ľ����Ϊ����ѯ�Ĳ�������
--�����ö���򵥲�ѯ�����ɸ��Ӳ�ѯ,����ǿSQL�Ĳ�ѯ����
--�Ӳ�ѯ�в�����order by�Ӿ�,order by�Ӿ�ֻ�ܶ����ղ�ѯ�����������

--���ص�ֵ���Ӳ�ѯ��ֻ����һ��һ��
--����ѯ�뵥ֵ�Ӳ�ѯ֮���ñȽ��������������

--�ҳ���001ͬ���ѧ��
select * from Student where sage=
(select sage from Student where sno='001');

--�Ӳ�ѯ���ض���һ��
--�������In��All��Some(��Any)��Exists

--��ֵ���Ӳ�ѯ���ؼ��е�ĳһ����ȣ��򷵻�true
-- IN ���������Զ�ֵ�еĳ�Ա
--������ѯѡ�ޡ�C01���γ̵�ѧ����ѧ�š�����

select * from Student where sno in(select sno from SC where cno='C01');

--�Ӳ�ѯ������ֵ��ԱIn
--���� ��ѯѡ���� �����ݿ⡯��ѧ����ѧ�ź�����
select sno,sname from Student where sno in
(select sno from SC where cno in
(select cno from Course where cname='���ݿ�'));

--����ѡ�޿γ�C02��ѧ���гɼ���ߵ�ѧ����ѧ��
select sno from SC where cno='C02' and grade>=all
(select grade from SC where cno='C02');

--�Ӳ�ѯ������ֵ�Ƚ�Some/Any
--��ֵ�Ƚϣ�����һ��
--����ѯ���ֵ�Ӳ�ѯ֮��ıȽ�����Some/Any������
--ֵs���Ӳ�ѯ���ؼ�R�е�ĳһ������ʱ���� Ture
--s > Some RΪTrue  �� 
--s > Any RΪTrue 
--Some(������Any)��ʾĳһ��������һ����
-- > some��< some��<=some��>=some��<> some
--= some �ȼ��� in��<> some ���ȼ��� not in 

--��ѯ������һ��Ůͬѧ��������ͬѧ
select sname from Student where sage>some(select sage from Student where ssex='f')
and ssex='m';


































