﻿IF OBJECT_ID('fun_getPY') IS NOT NULL 
    DROP FUNCTION fun_getPY

CREATE FUNCTION fun_getPY (@str NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS 
BEGIN
    DECLARE @word NCHAR(1) , @py NVARCHAR(4000)
    SET @PY = ''
    WHILE LEN(@str) > 0 
        BEGIN
            SET @word = LEFT(@str,1)
            SET @PY = @PY + (CASE WHEN UNICODE(@word) BETWEEN 19968 AND 19968 + 20901
                                  THEN (
                                        SELECT TOP 1
                                                py
                                        FROM    (
													SELECT 'A' AS py,N'驁' AS word
													UNION ALL SELECT 'B',N'簿'
													UNION ALL SELECT 'C',N'錯'
													UNION ALL SELECT 'D',N'鵽'
													UNION ALL SELECT 'E',N'樲'
													UNION ALL SELECT 'F',N'鰒'
													UNION ALL SELECT 'G',N'腂'
													UNION ALL SELECT 'H',N'夻'
													UNION ALL SELECT 'J',N'攈'
													UNION ALL SELECT 'K',N'穒'
													UNION ALL SELECT 'L',N'鱳'
													UNION ALL SELECT 'M',N'旀'
													UNION ALL SELECT 'N',N'桛'
													UNION ALL SELECT 'O',N'漚'
													UNION ALL SELECT 'P',N'曝'
													UNION ALL SELECT 'Q',N'囕'
													UNION ALL SELECT 'R',N'鶸'
													UNION ALL SELECT 'S',N'蜶'
													UNION ALL SELECT 'T',N'籜'
													UNION ALL SELECT 'W',N'鶩'
													UNION ALL SELECT 'X',N'鑂'
													UNION ALL SELECT 'Y',N'韻'
													UNION ALL SELECT 'Z',N'咗'
                                                ) T
                                        WHERE   word >= @word COLLATE Chinese_PRC_CS_AS_KS_WS
                                        ORDER BY py ASC
                                       )
                                  --如果非汉字字符，返回原字符
                                  ELSE @word
                             END)
            SET @str = RIGHT(@str,LEN(@str) - 1)
        END
    RETURN @PY
END

--函数调用实例：
SELECT  dbo.fun_getPY('中华人民共和国')