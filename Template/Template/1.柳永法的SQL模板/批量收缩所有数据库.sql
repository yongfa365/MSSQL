--批量收缩所有数据库  
DECLARE cur CURSOR FOR SELECT name FROM Master..SysDatabases WHERE name NOT IN ('master','model','msdb','Northwind','pubs')  
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





--哪个表或者索引占用Pool缓冲空间最多?
DECLARE cur CURSOR
FOR
    SELECT  name
    FROM    Master..SysDatabases
    WHERE   name NOT IN ( 'master', 'model', 'msdb', 'Northwind', 'pubs' )  
DECLARE @tb SYSNAME   
  
OPEN cur   
FETCH NEXT FROM cur INTO @tb   
WHILE @@fetch_status = 0
    BEGIN   
	
        SELECT  COUNT(*) * 8 / 1024 AS MBUsed ,
                DB_NAME(MAX(bd.database_id)) DBName ,
                obj.name TableName ,
                b.name OtherName ,
                b.type_desc ,
                obj.index_id
        FROM    sys.dm_os_buffer_descriptors AS bd
                INNER JOIN ( SELECT OBJECT_NAME(object_id) AS name ,
                                    index_id ,
                                    allocation_unit_id ,
                                    object_id
                             FROM   sys.allocation_units AS au
                                    INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id
                                                              AND ( au.type = 1
                                                              OR au.type = 3
                                                              )
                             UNION ALL
                             SELECT OBJECT_NAME(object_id) AS name ,
                                    index_id ,
                                    allocation_unit_id ,
                                    object_id
                             FROM   sys.allocation_units AS au
                                    INNER JOIN sys.partitions AS p ON au.container_id = p.partition_id
                                                              AND au.type = 2
                           ) AS obj ON bd.allocation_unit_id = obj.allocation_unit_id
                LEFT JOIN sys.indexes b ON b.object_id = obj.object_id
                                           AND b.index_id = obj.index_id
        WHERE   database_id = DB_ID(@tb)
        GROUP BY obj.name ,
                obj.index_id ,
                b.name ,
                b.type_desc
        ORDER BY MBUsed DESC;

        FETCH NEXT FROM cur INTO @tb   

    END   
CLOSE cur   
DEALLOCATE cur 
