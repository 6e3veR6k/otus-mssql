declare @command VARCHAR(4096),
		@dbname VARCHAR(255),
		@path VARCHAR(1024),
		@filename VARCHAR(255),
		@dateFrom DATETIME, 
		@dateTo DATETIME, 
		@dateMonthFrom DATETIME, 
		@dateMonthTo DATETIME, 
		@EventIdFrom BIGINT, 
		@EventIdTo BIGINT,
		@batchsize INT,
		@query VARCHAR(1000)

SELECT @dbname = DB_NAME();
SET @path = 'D:\Test\';

SET @dateFrom = '2015-12-01';
SET @dateTo = '2016-03-01';
SET @dateMonthFrom = @dateFrom;

WHILE @dateMonthFrom < @dateTo
BEGIN
	SET @dateMonthTo = DATEADD(month, 1, @dateMonthFrom);

	SELECT @EventIdFrom = MIN(EventId), 
		@EventIdTo = MAX(EventId)
	FROM dbo.EventList
	WHERE EventDateUTC >= @dateMonthFrom
	AND EventDateUtc < @dateMonthTo;

	select @EventIdFrom, @EventIdTo

	SET @filename = 'Event-'+CONVERT(VARCHAR,@dateMonthFrom,112)+'-'+@dbname+'.txt';
	SET @batchsize = 10000000;

	SET @query = 'SELECT * FROM ['+@dbname+'].dbo.EventList WHERE EventId >= '+CAST(@EventIdFrom AS VARCHAR)+' AND EventId <= '+CAST(@EventIdTo AS VARCHAR);

	set @command = 'bcp "'+@query+'" queryout '+@path+@filename+' -d '+@dbname+' -w -T -b '+CAST(@batchsize AS VARCHAR(255));

	exec master..xp_cmdshell @command

	SET @filename = 'Event-'+@dbname+'.txt';

	SET @query = 'SELECT 
			E.EventId,
			E.PathId,
			NF.EventDateUtc,
			E.EventTypeId
	     FROM ['+@dbname+'].dbo.EventListEvent AS E
			JOIN ['+@dbname+'].dbo.EventList AS NF
		 WHERE E.EventId >= '+CAST(@EventIdFrom AS VARCHAR)+' AND E.EventId <= '+CAST(@EventIdTo AS VARCHAR);

	set @command = 'bcp "'+@query+'" queryout '+@path+@filename+' -d '+@dbname+' -w -T -b '+CAST(@batchsize AS VARCHAR(255));

	SET @dateMonthFrom = @dateMonthTo;
END