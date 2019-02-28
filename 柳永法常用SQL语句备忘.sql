--------------------------数据库操作-------------------------- 
--建数据库  
create database yongfa365_com  
on  
( name = yongfa365_comt,  
  filename = 'd:\yongfa365_com.mdf',  
  size = 4,  
  maxsize = 10,  
  filegrowth = 1  
)  


--删数据库
drop database yongfa365_com  

--备份数据库
backup database yongfa365_com to disk='d:\yongfa365_com.bak'  

--批量收缩所有数据库  适用SQL Server 2000/2005
DECLARE cur CURSOR FOR SELECT name FROM Master..SysDatabases WHERE name NOT IN ('master','model','msdb','Northwind','pubs','tempdb')  
DECLARE @tb SYSNAME  

OPEN cur  
FETCH NEXT FROM cur INTO @tb  
WHILE @@fetch_status = 0  
    BEGIN  
        DUMP TRANSACTION  @tb  WITH NO_LOG  
        BACKUP LOG  @tb WITH NO_LOG  
        DBCC shrinkdatabase(@tb)  
        FETCH NEXT FROM cur INTO @tb  
    END  
CLOSE cur  
DEALLOCATE cur   


--批量收缩所有数据库  适用所有SQL Server
DECLARE cur CURSOR FOR SELECT name FROM Master..SysDatabases WHERE name NOT IN ('master','model','msdb','Northwind','pubs','tempdb')  
DECLARE @tb SYSNAME  

OPEN cur  
FETCH NEXT FROM cur INTO @tb  
WHILE @@fetch_status = 0  
    BEGIN  
        EXEC('ALTER DATABASE '+@tb+' SET RECOVERY SIMPLE;')  
        DBCC shrinkdatabase (@tb);  
        EXEC('ALTER DATABASE '+@tb+' SET RECOVERY FULL;')  

        FETCH NEXT FROM cur INTO @tb  
    END  
CLOSE cur  
DEALLOCATE cur   


--删除数据库日志文件（有时能删几十G）  
DBCC ERRORLOG  
GO 6  

--------------------------数据库操作--------------------------  














----------------------------表操作----------------------------  
--删除表
drop table movies  

--SQL Server通用建表结构
Create Table [test] (  
  [Id] int primary key identity(1,1),--ID，主键，自动号  
  [txtTitle] nvarchar(255),--标题  
  [txtContent] nvarchar(MAX),--内容  
  [Adder] nvarchar(20),--添加人  
  [AddTime] datetime Default (getdate()),--提交时间  
  [ModiTime] datetime Default (getdate()),--修改时间  
  [Hits] int Default (0),--点击数  
  [Flags] int Default (0) ,--标识  
  [SortID] int Default (0)--排序号  
 )  


--SQLite建表
Create Table [test] (  
  [Id] integer Primary key not null,  
  [txtTitle] text null,--标题  
  [txtContent] text null,--内容  
  [Adder]  text null,--添加人  
  [AddTime]  text DEFAULT (datetime('now','localtime')) not null,--提交时间  
  [ModiTime]  text DEFAULT (datetime('now','localtime')) not null,--修改时间  
  [Hits] integer Default (0)  not null,--点击数  
  [Flags] integer Default (0)  not null ,--标识  
  [SortID] integer Default (0)  not null--排序号  
 )  

--ACCESS使用SQL语句建表
CREATE TABLE 表名 (  
  [Id] AutoIncrement NOT NULL ,  
  [AddTime] Date NULL ,  
  [Hits] Integer NULL ,  
  [Title] Text (255) NULL ,  
  [Remark] Memo NULL ,  
  [RMB] Currency NULL ,  
  [Flags] bit NULL ,  

  PRIMARY KEY (ID)  
)  

CREATE INDEX IDX_Log_CreateTime ON [dbo].[PerfLog] ([CreateTime] desc)
--重命名表
sp_rename '表名', '新表名', 'object'  
----------------------------表操作----------------------------  










---------------------------字段操作--------------------------- 
--添加字段  
alter table [表名] add [字段名] [varchar] (50) not null default('默认')  

--删除字段 
 alter table [表名] drop column [字段名]  

--修改字段  
alter table [表名] alter column [字段名] varchar(50)  

--添加约束  
alter table [表名] add constraint [约束名] check ([约束字段] <= '2009-1-1')  

--删除约束  
alter table [表名] drop constraint [约束名]  

--添加默认值  
alter table [表名] add constraint [默认值名] default 'http://www.yongfa365.com/' for [字段名]  

--删除默认值  
alter table [表名] drop constraint [默认值名]  



USE XXXXDB
go

IF COL_LENGTH(N'[dbo].[Pkg_InsuranceTicketInfo]', N'IsTransfer') IS  NULL    
BEGIN
ALTER TABLE [dbo].[InsuranceTicketInfo] ADD [IsTransfer]  bit Not  NULL  CONSTRAINT conIstransfer  DEFAULT 1
alter table [dbo].[InsuranceTicketInfo] drop constraint conIstransfer
alter table [dbo].[InsuranceTicketInfo] add constraint conIstransfer   DEFAULT 0 for [IsTransfer]  
END
GO


--让SQL Server 自动编号ID从1开始  
dbcc checkident('表名',reseed,0)  

---------------------------字段操作---------------------------  





----------------------表及字段描述信息------------------------  

--为表添加描述信息
EXEC sp_addextendedproperty N'MS_Description' , N'人员信息表' , N'SCHEMA' , N'dbo' , N'TABLE' , N'表名' , NULL , NULL  

--为字段XingMing添加描述信息
EXEC sp_addextendedproperty N'MS_Description' , N'姓名' , N'SCHEMA' , N'dbo' , N'TABLE' , N'表名' , N'COLUMN' , N'XingMing'  

--更新表中列XingMing的描述属性：
EXEC sp_updateextendedproperty N'MS_Description' , N'真实姓名' , N'SCHEMA' , N'dbo' , 'TABLE' , '表名' , 'COLUMN' , N'XingMing'  

--删除表中列XingMing的描述属性：
EXEC sp_dropextendedproperty N'MS_Description' , N'SCHEMA' , N'dbo' , 'TABLE' , '表名' , 'COLUMN' , N'XingMing'  

----------------------表及字段描述信息------------------------  





---------------------------★★★★★数据操作★★★★★---------------------------
--插入数据
insert into [表名] (字段1,字段2) values (100,'http://www.yongfa365.com/')  

--删除数据
delete from [表名] where [字段名]>100  

--删除重复记录(效率低，适合少量数据操作,极不适合ACCESS使用)
delete from [表名] where id not in (select max(id) from [表名] group by txtTitle,txtContent)  

--NOT IN 效率太低，20000条数据都让access死掉了。可行的方法：建个临时表，在需要判断是否重复的字段上加主键，用insert into InfoTemp select * from Info将原表的数据导入临时表， 数据库可以自动筛去重复数据，delete * from Info 清空原表，再用insert into Info select * from InfoTemp 将临时表中数据导回原表  

--更新数据
set rowcount 100000 --设置最大可更新的条数
update [表名] set [字段1] = 200,[字段2] = 'http://www.yongfa365.com/' where [字段三] = 'haiwa'  

--多表，用一个表更新另一个表(SQL Server版)
update 表一  
set 表一.a = 表二.b  
from 表一,表二  
where 表一.id = 表二.id  

update 表一  
set a = 表二.b  
from 表二  
where id = 表二.id  

--多表，用一个表更新另一个表(ACCESS版)  
update 表一   
inner join 表二  
on 表一.id = 表二.id  
set 表一.a = 表二.b   

--查询结果存储到新表
select * into [新表表名] from [表名]  

--从table 表中取出从第 m 条到第 n 条的记录：(not in 版本)
select top n-m+1 * from [表名] where id not in (select top m-1 id from [表名])  

--例：取出第31到第40条记录
select top 10 * from [表名] where id not in (select top 30 id from [表名])  

--从table 表中取出从第 m 条到第 n 条的记录：(ROW_NUMBER 版本)  
SELECT  *  
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY id DESC ) AS idx ,  
                    *  
          FROM      dbo.Articles  
        ) a  
WHERE   a.idx BETWEEN m AND n  

--随机取10条数据,newid()是SQL数据库里的一个函数，跟数据库里的ID没关  
select top 10 * from [表名] order by newid()   

--随机取10条数据,如果是ACCESS数据库用order by rnd(数字字段)  
select top 10 * from [表名] order by rnd(id)  

--连接查询left join  
select * from Article left join Category on Article.CategoryID=Category.ID  



--查询结果插入到另一个表的相关字段里（可以插入一个表的字段，也可以是一个数字常量）  
insert into desttbl(fld1, fld2) select fld1, 5 from srctbl  

--把当前表里的数据再复制一份到这个表里  
insert into [表名] select * from [表名]  

--SQL 2008支持這種插入方法，使用,隔開各行  
DECLARE @Student TABLE (NO INT,Name NVARCHAR(4),Sex NVARCHAR(2),Age INT,Dept VARCHAR(2))  
INSERT INTO @Student VALUES  
( 95001,N'李勇',N'男',20,'CS'),  
( 95002,N'刘晨',N'女',19,'IS'),  
( 95003,N'王敏',N'女',18,'IS'),  
( 95004,N'张立',N'男',19,'MA'),  
( 96001,N'徐一',N'男',20,'IS'),  
( 96002,N'张三',N'女',21,'CS'),  
( 96003,N'李四',N'男',18,'IS')  

SELECT * FROM @Student  

--以逗号连接结果集所有行，使之变为一行
DECLARE @result NVARCHAR(MAX)  
SET @result = N''  
SELECT @result = @result + N',' + Name FROM @Student  

SELECT RIGHT(@result,LEN(@result) - 1)  


--向数据库中添加5000条数据
DECLARE @i int  
set @i=1  
while @i<=5000  
begin  
  insert into users(userid,username) values(@i,'username' convert(varchar(255),@i))  
  set @i=@i+1  
end  
go  

--统计SQL语句执行时间  
declare @dt datetime  
set @dt=getdate()  
	--要执行的SQL语句
SELECT [语句执行花费时间(毫秒)]=datediff(ms,@dt,getdate())  


--Case When语句  
SELECT UserName,sex=  
CASE  
  WHEN sex='男' THEN '男人'  
  WHEN sex='女' THEN '女人'  
  ELSE '哈哈'  
END  
,Age  
FROM Users  


--having使用方法
--一个表中的UserName有很多重复,
--只显示重复项:  
select UserName,COUNT(*) from Users group by UserName having count(*)>1   
--不显示重复项:   
select UserName,COUNT(*) from Users group by UserName having count(*)=1   


--相同ID的记录只取第一条.Start
DECLARE @StudentScore TABLE (Id INT,Name NVARCHAR(4),Score INT,CreateTime datetime)  
INSERT INTO @StudentScore VALUES  
( 6,N'张三',90,'2019-02-28'), 
( 5,N'张三',80,'2019-02-27'), 
( 4,N'张三',70,'2019-02-26'), 
( 3,N'李四',60,'2019-02-25'), 
( 2,N'李四',50,'2019-02-24'), 
( 1,N'王五',40,'2019-02-23')

--开窗函数，推荐使用
;WITH TempDB AS(
	SELECT ROW_NUMBER() OVER (PARTITION BY Name ORDER BY CreateTime) RowNum , * FROM @StudentScore
)
SELECT * FROM TempDB WHERE RowNum = 1

--另一种实现方法，不推荐
select * from @StudentScore where Id in (select min(Id) from @StudentScore group by Name)

--相同ID的记录只取第一条.End


--假执行，预执行
--事务开始
BEGIN TRANSACTION
	--要执行的SQL语句
--回滚
ROLLBACK





---------------------------数据操作---------------------------  
osql -S HP580DBSZ\DEV  -E（或者換成-U sa -P sa）  -i d:\PackageFHLog.sql 
直接用for xml path('')即可，例如用逗号把FieldName连起来：
select stuff((select ','+FieldName from TableName group by GBFieldName for xml path('')),1,1,'')

SELECT * INTO #TEMP1 FROM 
(
SELECT 'something1' AS A1, 1 AS A2
       UNION ALL
       SELECT 'something2' AS A1, 1 AS A2
       UNION ALL
       SELECT 'something3' AS A1, 2 AS A2
       UNION ALL
       SELECT 'something4' AS A1, 2 AS A2
       ) T

select stuff(
 (
    select ',' + A1 from 
    #TEMP1 T1 WHERE T1.A2 = T2.A2  for xml path('') 
 ) , 1 , 1 , '')  from  #TEMP1 T2 group by A2

 DELETE a FROM Pkg_ProdRTResourceList a INNER JOIN
(
 SELECT  rt.* from Pkg_ProdRTResourceList  rt left join dbo.Pkg_ProductMaster pm ON pm.ProductID = rt.ProductID
 WHERE pm.ProductType=0 AND pm.SubProdType=1 AND dbo.RegexIsMatch(rt.FareID,'[a-z]',1)=1
) b ON a.ProductID=b.ProductID AND a.SeqNo=b.SeqNo AND a.ResourceType=b.ResourceType AND a.ResourceID=b.ResourceID


--改逻辑文件名
RESTORE DATABASE XxxxDB FROM DISK = N'E:\XxxxDB.bak' 
WITH 
MOVE N'Xxxx' TO N'D:\XxxxDB.mdf',  
MOVE N'Xxxx_log' TO N'D:\XxxxDB_1.ldf',  NOUNLOAD,  STATS = 10, REPLACE

alter database XxxxDB modify file(name=Xxxx, newname=XxxxDB)
alter database XxxxDB modify file(name=Xxxx_log, newname=XxxxDB_log)







GO

------------------------------删除所有此db没用到的表-------------------------------------------
PRINT(N'--Step  II: 删除所有此db没用到的表。')

--这里是用到的
SELECT * INTO #TempIDs FROM dbo.CLR_Split(dbo.RegexReplace('
TableA
TableB
TableC
','\s+','|',1),'|',1)

DECLARE @TableName NVARCHAR(max)
DECLARE Table_Cursor CURSOR FOR SELECT [name] FROM sysobjects WHERE xtype = 'U' AND name NOT IN(SELECT id FROM #TempIDs);
OPEN Table_Cursor;
FETCH NEXT FROM Table_Cursor INTO @TableName;
WHILE ( @@FETCH_STATUS = 0 )
BEGIN
DECLARE @sql NVARCHAR(max)
 SET @sql='drop table '+@TableName
 PRINT @sql +' doing'
 EXEC(@sql)
 FETCH NEXT FROM Table_Cursor INTO @TableName;
END;
CLOSE Table_Cursor;
DEALLOCATE Table_Cursor;

DROP TABLE #TempIDs
GO

------------------------------删除所有外键-------------------------------------------
PRINT(N'--Step I: 删除所有外键。')


SET XACT_ABORT ON;
BEGIN TRAN;
DECLARE @SQL VARCHAR(max);
DECLARE CUR_FK CURSOR LOCAL
FOR
    SELECT  'alter table [' + OBJECT_NAME(fkeyid) + '] drop constraint '
            + OBJECT_NAME(constid)
    FROM    sysreferences;

OPEN CUR_FK;
FETCH CUR_FK INTO @SQL;
WHILE @@FETCH_STATUS = 0
    BEGIN
            PRINT ( @SQL );
EXEC(@SQL)

        FETCH CUR_FK INTO @SQL;
    END;
CLOSE CUR_FK;
DEALLOCATE CUR_FK;

commit tran
