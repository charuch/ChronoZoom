CREATE PROCEDURE TracePathToRoot 
	@collection_id UNIQUEIDENTIFIER,
	@current_timeline_id UNIQUEIDENTIFIER,
	@include_sibling BIT 
AS
BEGIN
	DECLARE @cid UNIQUEIDENTIFIER
	DECLARE @pid UNIQUEIDENTIFIER
	DECLARE @path TABLE (
		Id UNIQUEIDENTIFIER
	)
	SET @cid = @current_timeline_id
	WHILE @cid <> CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) 
	BEGIN
		SELECT @pid=Timeline_Id FROM Timelines WHERE Id = @cid 
		IF @include_sibling <> 0 AND @pid <> CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
		BEGIN 
			INSERT INTO @path SELECT Id FROM Timelines WHERE Timeline_Id = @pid
		END
		ELSE
		BEGIN
			INSERT INTO @path VALUES (@cid)
		END
		SET @cid = @pid
	END
	SELECT Timelines.* FROM Timelines JOIN @path ON Timelines.Id = "@path".Id ORDER BY DEPTH
END
