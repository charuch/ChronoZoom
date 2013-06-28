CREATE PROCEDURE TimelineSubtreeQuery
	@collection_id UNIQUEIDENTIFIER,
	@lca UNIQUEIDENTIFIER,
	@min_span DECIMAL,
	@startTime DECIMAL,
	@endTime DECIMAL,
	@max_elem INT,
	@return_path_to_root BIT,
	@include_sibling BIT 
AS
BEGIN
	DECLARE @subtree_size INT
	DECLARE @current_level_cnt INT
	DECLARE @cnt INT
	DECLARE @chld_cnt INT
	DECLARE @num_ge_min_span INT
	DECLARE @current_id UNIQUEIDENTIFIER
	DECLARE @current_level TABLE (
		Id UNIQUEIDENTIFIER
	)
	DECLARE @next_level TABLE (
		Id UNIQUEIDENTIFIER
	)
	DECLARE @chld TABLE (
		Id UNIQUEIDENTIFIER
	)
	DECLARE @results TABLE (
		Id UNIQUEIDENTIFIER
	)
	DECLARE cur_timeline_subtree_query CURSOR LOCAL FOR SELECT Id FROM @current_level
	SET @subtree_size = 0
	IF @lca = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
		INSERT INTO @current_level SELECT Id FROM Timelines WHERE Depth = 0 AND Collection_ID =  @collection_id
	ELSE
	BEGIN
		INSERT INTO @current_level VALUES (@lca)
		SELECT @subtree_size=SubtreeSize FROM Timelines WHERE Id = @lca
	END
	SET @cnt = 0
	WHILE (@cnt < @max_elem)
	BEGIN
		SELECT @current_level_cnt=COUNT(Id) FROM @current_level
		IF @current_level_cnt = 0
			BREAK
		OPEN cur_timeline_subtree_query
		FETCH NEXT FROM cur_timeline_subtree_query INTO @current_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @results VALUES(@current_id)
			SET @cnt = @cnt + 1
			IF @cnt >= @max_elem
				BREAK
			SELECT @num_ge_min_span=COUNT(Id) FROM (SELECT TOP(1) Id FROM Timelines WHERE Timeline_ID = @current_id AND ToYear - FromYear >= @min_span) AS ChildTimelines
			IF @num_ge_min_span > 0
			BEGIN
				IF @cnt < @max_elem
					DELETE FROM @chld
					INSERT INTO @chld SELECT Id FROM Timelines WHERE Timeline_ID = @current_id AND ToYear - FromYear >= @min_span AND ((FromYear >= @startTime AND FromYear <= @endTime) OR (ToYear >= @startTime AND ToYear <= @endTime) OR (FromYear <= @startTime AND ToYear >= @endTime) OR (FromYear >= @startTime AND ToYear <= @endTime))
					SELECT @chld_cnt=COUNT(Id) FROM @chld
					IF @cnt + @chld_cnt <= @max_elem
						INSERT INTO @next_level SELECT Id FROM @chld
				ELSE
					BREAK
			END 
			FETCH NEXT FROM cur_timeline_subtree_query INTO @current_id
		END
		DELETE FROM @current_level
		INSERT INTO @current_level SELECT Id FROM @next_level
		DELETE FROM @next_level
		CLOSE cur_timeline_subtree_query 
	END
	DEALLOCATE cur_timeline_subtree_query
	SELECT Timelines.* FROM Timelines JOIN @results ON Timelines.Id = "@results".Id ORDER BY Depth 
	IF @return_path_to_root <> 0 AND @lca <> CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
		EXEC TracePathToRoot @collection_id, @lca, @include_sibling
END