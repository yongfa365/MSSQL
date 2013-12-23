
--http://blog.csdn.net/billpu/article/details/7362139
﻿--查询缓冲池内数据库缓冲池中各个数据库的分布情况
SELECT  DBName = CASE database_id
                   WHEN 32767 THEN N'ResourchDB'
                   ELSE DB_NAME(database_id)
                 END ,
        COUNT(*) AS cached_pages_count ,
        COUNT(*) * 8 / 1024 AS [MBUsed] ,
        SUM(CAST([free_space_in_bytes] AS BIGINT)) / ( 1024 * 1024 ) AS [MBEmpty]
FROM    sys.dm_os_buffer_descriptors
GROUP BY DB_NAME(database_id) ,
        database_id
ORDER BY cached_pages_count DESC
