USE RUB_INF
GO
--select * from BandGap.dbo.Graph ORDER BY SubstanceID
/*
select * from BandGap.dbo.LitReferences


select * from RUB_INF.dbo.Tenant	-- 3
select * from RUB_INF.dbo.TypeInfo	-- Literature Reference=3
select * from RUB_INF.dbo.AspNetUsers	-- 1=...........


select * from BandGap.dbo.LitReferences WHERE ReferenceID>0		-- 1861
*/
-- =========================================== LitReferences ===========================================
DECLARE @retval int
DECLARE @ObjectId int, @TenantId int=3, @_created datetime, @_createdBy int=1, @_updated datetime, @_updatedBy int=1, @TypeId int=3, @RubricId int=91
DECLARE @SortCode int=0, @AccessControl int=0, @IsPublished bit=1, @ExternalId int, @ObjectName varchar(512), @ObjectNameUrl varchar(256), @ObjectFilePath varchar(256), @ObjectDescription varchar(1024)
DECLARE @Authors varchar(512), @Title varchar(1024), @Journal varchar(256), @Year int, @Volume varchar(32), @Number varchar(32), @StartPage varchar(32), @EndPage varchar(32), @DOI varchar(256), @URL varchar(256), @BibTeX varchar(4096), @showResultsInRecordset bit=0

-- LitReferences
DECLARE @ReferenceID int
declare c1 cursor local for select ReferenceID,Authors,Title,Journal,[Year],Vol,Num,IPage,EPage,DOI from BandGap.dbo.LitReferences WHERE ReferenceID>0 -- 1861
open c1
while (1=1)
begin
	fetch c1 into @ReferenceID, @Authors, @Title, @Journal, @Year, @Volume, @Number, @StartPage, @EndPage, @DOI
	if @@fetch_status <> 0 break
	PRINT 'Processing ReferenceID=' + CAST(@ReferenceID as varchar(8))
	SET @ObjectId=0
	SET @ExternalId = @ReferenceID
	-- SET @ObjectName = LEFT(TRIM(ISNULL(@Authors,'') + ' ' + ISNULL(@Title,'')) COLLATE Latin1_General_100_CI_AS_KS_SC_UTF8, 110)
	SET @ObjectName = LEFT(TRIM(ISNULL(dbo.fn_StripHTML(@Authors),'') + ' ' + ISNULL(dbo.fn_StripHTML(@Title),'')), 512)
	IF LEN(TRIM(ISNULL(@Authors,'') + ' ' + ISNULL(@Title,'')))>1024
		SET @ObjectDescription = TRIM(ISNULL(dbo.fn_StripHTML(@Authors),'') + ' ' + ISNULL(dbo.fn_StripHTML(@Title),''))
	else
		SET @ObjectDescription = TRIM(ISNULL(@Authors,'') + ' ' + ISNULL(@Title,''))
	EXEC @retval = RUB_INF.dbo.ObjectInfo_Reference_UpdateInsert @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, 
	@ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription,			@Authors, @Title, @Journal, @Year, @Volume, @Number, @StartPage, @EndPage, @DOI, @URL, @BibTeX, @showResultsInRecordset
	PRINT '		ReferenceID=' + CAST(@ReferenceID as varchar(8)) + ' done [ObjectId=' + CAST(@ObjectId as varchar(16)) + ']'
end
close c1
deallocate c1
GO
-- select * from RUB_INF.dbo.ObjectInfo where TypeId=3 and TenantId=3	-- 1861
/*
delete from RUB_INF.dbo.Reference WHERE ReferenceId IN (select ObjectId from ObjectInfo where TenantId=3 and TypeId=3)	-- 1861
delete from RUB_INF.dbo.ObjectInfo where TypeId=3 and TenantId=3	-- 1861
*/


-- select SubstanceID, NumElements, El1, X1, El2, X2, El3, X3, El4, X4, [Elements], Compound from BandGap.dbo.Substances WHERE NumElements<5 -- 4752
-- select * from BandGap.dbo.Substances -- 5007
-- =========================================== Substances (1-4) ===========================================
DECLARE @retval int
DECLARE @ObjectId int, @TenantId int=3, @_created datetime, @_createdBy int=1, @_updated datetime, @_updatedBy int=1, @TypeId int=8 /*Composition*/, @RubricId int=85
DECLARE @SortCode int=0, @AccessControl int=0, @IsPublished bit=1, @ExternalId int, @ObjectName varchar(512), @ObjectNameUrl varchar(256), @ObjectFilePath varchar(256), @ObjectDescription varchar(1024)
DECLARE @NumElements int, @El1 varchar(2), @X1 float, @El2 varchar(2), @X2 float, @El3 varchar(2), @X3 float, @El4 varchar(2), @X4 float, @Elements varchar(256), @Compound varchar(256)
DECLARE @ElemNumber int, @CompositionItems dbo.CompositionItem, @Xml xml, @showResultsInRecordset bit=0

-- Substances
DECLARE @SubstanceID int
declare c1 cursor local for select SubstanceID, NumElements, El1, X1, El2, X2, El3, X3, El4, X4, [Elements], Compound from BandGap.dbo.Substances WHERE NumElements<5 -- 4752
	AND SubstanceID NOT IN (1415, 4123, 4124, 4552)	-- 4748
open c1
while (1=1)
begin
	fetch c1 into @SubstanceID, @NumElements, @El1, @X1, @El2, @X2, @El3, @X3, @El4, @X4, @Elements, @Compound
	if @@fetch_status <> 0 break
	PRINT 'Processing SubstanceID=' + CAST(@SubstanceID as varchar(8))
	SET @ObjectId=0
	SET @ExternalId = @SubstanceID
	SET @ObjectName = Left(@Compound, 512)
	SET @ObjectDescription = @Compound
	SET @ElemNumber=0
	SET @Elements = '-'+@El1+'-'
	if @NumElements>1
		SET @Elements = @Elements + @El2 + '-'
	if @NumElements>2
		SET @Elements = @Elements + @El3 + '-'
	if @NumElements>3
		SET @Elements = @Elements + @El4 + '-'
	SET @RubricId = 85 + @NumElements
	DELETE FROM @CompositionItems;
	if @NumElements=1
		INSERT INTO @CompositionItems(CompoundIndex, ElementName, ValueAbsolute, ValuePercent) VALUES (1, @El1, 1, 0)
	else
		INSERT INTO @CompositionItems(CompoundIndex, ElementName, ValueAbsolute, ValuePercent) VALUES (1, @El1, @X1, 0)
	if @NumElements>1
		INSERT INTO @CompositionItems(CompoundIndex, ElementName, ValueAbsolute, ValuePercent) VALUES (2, @El2, @X2, 0)
	if @NumElements>2
		INSERT INTO @CompositionItems(CompoundIndex, ElementName, ValueAbsolute, ValuePercent) VALUES (3, @El3, @X3, 0)
	if @NumElements>3
		INSERT INTO @CompositionItems(CompoundIndex, ElementName, ValueAbsolute, ValuePercent) VALUES (4, @El4, @X4, 0)
	EXEC @retval = RUB_INF.dbo.ObjectInfo_Composition_UpdateInsert @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, 
	@ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription,			@ElemNumber, @Elements, @CompositionItems, @Xml, @showResultsInRecordset=0
	PRINT '		SubstanceID=' + CAST(@SubstanceID as varchar(8)) + ' done [ObjectId=' + CAST(@ObjectId as varchar(16)) + '; NumElements=' + CAST(@NumElements as varchar(16)) + ']'
end
close c1
deallocate c1
/*
select SubstanceID, NumElements, El1, X1, El2, X2, El3, X3, El4, X4, [Elements], Compound from BandGap.dbo.Substances WHERE NumElements<5 -- 4752
	AND SubstanceID NOT IN (select ExternalId from ObjectInfo where TenantId=3 and TypeId=8) 
select * from ObjectInfo where TenantId=3 and TypeId=8	-- 4748
DELETE FROM Composition WHERE SampleId IN (select ObjectId from ObjectInfo where TenantId=3 and TypeId=8)	-- 15977
DELETE FROM [Sample] WHERE SampleId IN (select ObjectId from ObjectInfo where TenantId=3 and TypeId=8)	-- 4748
DELETE FROM ObjectInfo where TenantId=3 and TypeId=8	-- 4748
*/
GO

--	exploration for troubleshooting: 
-- select * from ObjectInfo WHERE ExternalId=4552
-- select * from BandGap.dbo.Substances where SubstanceID=4552
-- select * from BandGap.dbo.Gap WHERE SubstanceID IN (select SubstanceID from BandGap.dbo.Substances where NumElements<5) ORDER BY SubstanceID -- 10269
-- =========================================== Gap ===========================================
DECLARE @retval int
DECLARE @ObjectId int, @TenantId int=3, @_created datetime, @_createdBy int=1, @_updated datetime, @_updatedBy int=1, @TypeId int=8 /*Composition*/, @RubricId int=85 -- pre NumElements=1
DECLARE @SortCode int=0, @AccessControl int=0, @IsPublished bit=1, @ExternalId int, @ObjectName varchar(512), @ObjectNameUrl varchar(256), @ObjectFilePath varchar(256), @ObjectDescription varchar(1024)
DECLARE @Modification varchar(64), @CrystalSystem varchar(64), @StructureType varchar(64), @SpaceGroup varchar(64), @Direction varchar(64), @Temperature1 float, @Temperature2 float
DECLARE @E1 float, @E2 float, @IsCalculated bit, @Comments varchar(256)
DECLARE @ElemNumber int, @CompositionItems dbo.CompositionItem, @Xml xml, @showResultsInRecordset bit=0
DECLARE @ReferenceObjectId int, @SubstanceObjectId int
DECLARE @PropertyId int, @ValueInt bigint, @ValueFloat float, @ValueString varchar(4096), @ValueEpsilon float, @PropertyName varchar(64), @Comment varchar(256)

-- Substances
DECLARE @prevSubstanceID int=0, @SubstanceID int, @ReferenceID int, @PrimaryKey int, @Row int
declare c1 cursor local for 
	SELECT SubstanceID, Modification, CrystalSystem, StructureType, SpaceGroup, Direction, Temperature1, Temperature2, E1, E2, IsCalculated, Comments, ReferenceID, PrimaryKey
		FROM BandGap.dbo.Gap WHERE 
			SubstanceID NOT IN (1415, 4123, 4124, 4552)	AND
			--PrimaryKey=40644 AND 
			SubstanceID IN (select SubstanceID from BandGap.dbo.Substances where NumElements<5) ORDER BY SubstanceID
open c1
while (1=1)
begin
	fetch c1 into @SubstanceID, @Modification, @CrystalSystem, @StructureType, @SpaceGroup, @Direction, @Temperature1, @Temperature2, @E1, @E2, @IsCalculated, @Comments, @ReferenceID, @PrimaryKey
	if @@fetch_status <> 0 break
	PRINT 'Processing PrimaryKey=' + CAST(@PrimaryKey as varchar(16))

	SET @ReferenceObjectId=NULL
	select TOP 1 @ReferenceObjectId = ObjectId from dbo.ObjectInfo WHERE TenantId=3 AND TypeId=3 AND RubricId=91 AND ExternalId=@ReferenceID
	SET @SubstanceObjectId=NULL
	select TOP 1 @SubstanceObjectId = ObjectId from dbo.ObjectInfo WHERE TenantId=3 AND TypeId=8 AND ExternalId=@SubstanceID
	IF @ReferenceObjectId IS NULL OR @SubstanceObjectId IS NULL
	BEGIN
		DECLARE @msg as varchar(256) = 'Error: @ReferenceObjectId IS NULL OR @SubstanceObjectId IS NULL [ReferenceObjectId='+ISNULL(CAST(@ReferenceObjectId as varchar(16)),'NULL')+'; SubstanceObjectId='+ISNULL(CAST(@SubstanceObjectId as varchar(16)),'NULL')+'; PrimaryKey=' + CAST(@PrimaryKey as varchar(16)) + ']'
		RAISERROR (@msg, 16, 0);
	END
	if @prevSubstanceID<>@SubstanceID
	begin
		SET @Row=1
		SET @prevSubstanceID=@SubstanceID
	end
	ELSE
	begin
		SET @Row=@Row+1
	end
	if LEN(ISNULL(@Modification,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Modification'	--	'row'+CAST(@Row as varchar(8))+'_Modification'
		SET @ValueString = @Modification
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=10
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@CrystalSystem,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'CrystalSystem'	-- 'row'+CAST(@Row as varchar(8))+'_CrystalSystem'
		SET @ValueString = @CrystalSystem
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=20
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@StructureType,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'StructureType'	-- 'row'+CAST(@Row as varchar(8))+'_StructureType'
		SET @ValueString = @StructureType
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=30
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@SpaceGroup,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'SpaceGroup'	-- 'row'+CAST(@Row as varchar(8))+'_SpaceGroup'
		SET @ValueString = @SpaceGroup
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=40
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Direction,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Direction'	-- 'row'+CAST(@Row as varchar(8))+'_Direction'
		SET @ValueString = @Direction
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=50
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	IF @Temperature1=@Temperature2 
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Temperature'	-- 'row'+CAST(@Row as varchar(8))+'_Temperature'
		SET @ValueFloat = @Temperature1
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=60
		EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
	end
	else if @Temperature1 IS NOT NULL OR @Temperature2 IS NOT NULL
	begin
		if @Temperature1 IS NOT NULL 
		begin
			SET @PropertyId=NULL
			SET @PropertyName = 'Temperature'	-- 'row'+CAST(@Row as varchar(8))+'_Temperature'
			SET @ValueFloat = @Temperature1
			SET @Comment = CAST(@PrimaryKey as varchar(16))
			SET @SortCode=60
			EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
		end
		if @Temperature2 IS NOT NULL 
		begin
			SET @PropertyId=NULL
			SET @PropertyName = 'Temperature'	-- 'row'+CAST(@Row as varchar(8))+'_Temperature'
			SET @ValueFloat = @Temperature2
			SET @Comment = CAST(@PrimaryKey as varchar(16))
			SET @SortCode=60
			EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
		end
		--SET @PropertyId=NULL
		--SET @PropertyName = 'Temperature'	-- 'row'+CAST(@Row as varchar(8))+'_Temperature'
		--SET @ValueString = CAST(ISNULL(@Temperature1,'NULL') as varchar(16)) + '-' + CAST(ISNULL(@Temperature2,'NULL') as varchar(16))
		--SET @Comment = CAST(@PrimaryKey as varchar(16))
		--EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	IF @E1=@E2
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'E<sub>g</sub>'	-- 'row'+CAST(@Row as varchar(8))+'_E'
		SET @ValueFloat = @E1
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=70
		EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
	end
	else if @E1 IS NOT NULL OR @E2 IS NOT NULL
	begin
		if @E1 IS NOT NULL 
		begin
			SET @PropertyId=NULL
			SET @PropertyName = 'E<sub>g</sub>'	-- 'row'+CAST(@Row as varchar(8))+'_E'
			SET @ValueFloat = @E1
			SET @Comment = CAST(@PrimaryKey as varchar(16))
			SET @SortCode=70
			EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
		end
		if @E2 IS NOT NULL 
		begin
			SET @PropertyId=NULL
			SET @PropertyName = 'E<sub>g</sub>'	-- 'row'+CAST(@Row as varchar(8))+'_E'
			SET @ValueFloat = @E2
			SET @Comment = CAST(@PrimaryKey as varchar(16))
			SET @SortCode=70
			EXEC @retval = RUB_INF.dbo.PropertyFloat_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
		end
		--SET @PropertyId=NULL
		--SET @PropertyName = 'row'+CAST(@Row as varchar(8))+'_E'
		--SET @ValueString = CAST(ISNULL(@E1,'NULL') as varchar(16)) + '-' + CAST(ISNULL(@E2,'NULL') as varchar(16))
		--SET @Comment = CAST(@PrimaryKey as varchar(16))
		--EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	-- @IsCalculated always set
	SET @PropertyId=NULL
	SET @PropertyName = 'IsCalculated'	-- 'row'+CAST(@Row as varchar(8))+'_IsCalculated'
	SET @ValueInt = @IsCalculated
	SET @Comment = CAST(@PrimaryKey as varchar(16))
	SET @SortCode=80
	EXEC @retval = RUB_INF.dbo.PropertyInt_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueInt, @ValueEpsilon, @PropertyName, @Comment
	-- @ReferenceObjectId always set
	if @ReferenceObjectId IS NOT NULL AND @ReferenceObjectId>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'ReferenceId'	-- 'row'+CAST(@Row as varchar(8))+'_ReferenceId'
		SET @ValueInt = @ReferenceObjectId
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=90
		EXEC @retval = RUB_INF.dbo.PropertyInt_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueInt, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Comments,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Comment'	-- 'row'+CAST(@Row as varchar(8))+'_Comment'
		SET @ValueString = @Comments
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=100
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	PRINT '		PrimaryKey=' + CAST(@PrimaryKey as varchar(8)) + ' done'
end
close c1
deallocate c1
GO
/*
	UPDATE dbo.PropertyString SET SortCode=10 WHERE PropertyName = 'Modification' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyString SET SortCode=20 WHERE PropertyName = 'CrystalSystem' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyString SET SortCode=30 WHERE PropertyName = 'StructureType' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyString SET SortCode=40 WHERE PropertyName = 'SpaceGroup' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyString SET SortCode=50 WHERE PropertyName = 'Direction' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyFloat SET SortCode=60 WHERE PropertyName = 'Temperature' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyFloat SET SortCode=70 WHERE PropertyName = 'E' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyInt SET SortCode=80 WHERE PropertyName = 'IsCalculated' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyInt SET SortCode=90 WHERE PropertyName = 'ReferenceId' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
	UPDATE dbo.PropertyString SET SortCode=100 WHERE PropertyName = 'Comment' AND ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)

	-- @IsCalculated always set
	SET @PropertyId=NULL
	SET @PropertyName = 'IsCalculated'	-- 'row'+CAST(@Row as varchar(8))+'_IsCalculated'
	SET @ValueInt = @IsCalculated
	SET @Comment = CAST(@PrimaryKey as varchar(16))
	SET @SortCode=80
	EXEC @retval = RUB_INF.dbo.PropertyInt_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueInt, @ValueEpsilon, @PropertyName, @Comment
	-- @ReferenceObjectId always set
	if @ReferenceObjectId IS NOT NULL AND @ReferenceObjectId>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'ReferenceId'	-- 'row'+CAST(@Row as varchar(8))+'_ReferenceId'
		SET @ValueInt = @ReferenceObjectId
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=90
		EXEC @retval = RUB_INF.dbo.PropertyInt_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueInt, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Comments,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Comment'	-- 'row'+CAST(@Row as varchar(8))+'_Comment'
		SET @ValueString = @Comments
		SET @Comment = CAST(@PrimaryKey as varchar(16))
		SET @SortCode=100
		EXEC @retval = RUB_INF.dbo.PropertyString_UpdateInsert @PropertyId output, @SubstanceObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	PRINT '		PrimaryKey=' + CAST(@PrimaryKey as varchar(8)) + ' done'
end


select * from PropertyBigString WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3) -- 0
select * from PropertyString WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3) -- 28992
select * from PropertyInt WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)	-- 20527
select * from PropertyFloat WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)	-- 15149
DELETE  from PropertyBigString WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)
DELETE  from PropertyString WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)
DELETE  from PropertyInt WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)
DELETE  from PropertyFloat WHERE ObjectId IN (select ObjectId FROM ObjectInfo WHERE TenantId=3)
*/





--	exploration for troubleshooting: 
-- select * from ObjectInfo WHERE ExternalId=4552
-- select * from BandGap.dbo.Substances where SubstanceID=4552
-- select * from BandGap.dbo.Gap WHERE SubstanceID IN (select SubstanceID from BandGap.dbo.Substances where NumElements<5) ORDER BY SubstanceID -- 10269
-- =========================================== Substance - ReferenceId ===========================================
DECLARE @retval int
DECLARE @ObjectId int, @TenantId int=3, @_created datetime, @_createdBy int=1, @_updated datetime, @_updatedBy int=1--, @TypeId int=8 /*Composition*/, @RubricId int=85 -- pre NumElements=1
DECLARE @ReferenceObjectId int, @SubstanceObjectId int
DECLARE @SubstanceID int, @ReferenceID int, @PrimaryKey int, @Row int
/*
select SubstanceID, NumElements, El1, X1, El2, X2, El3, X3, El4, X4, [Elements], Compound from BandGap.dbo.Substances WHERE NumElements<5 -- 4752
	AND SubstanceID NOT IN (select ExternalId from ObjectInfo where TenantId=3 and TypeId=8) 
select ObjectId, ExternalId from ObjectInfo where TenantId=3 and TypeId=8	-- 4748
*/
-- Substances
SET NOCOUNT ON;
declare c1 cursor local for -- All Substances in target DB with links in original
	SELECT ObjectId, ExternalId from ObjectInfo where TenantId=3 and TypeId=8	-- 4748
open c1
while (1=1)
begin
	fetch c1 into @SubstanceObjectId, @SubstanceID
	if @@fetch_status <> 0 break
	PRINT 'Processing LINKS @SubstanceObjectId=' + CAST(@SubstanceObjectId as varchar(16)) + '; ExternalId(SubstanceID)=' + CAST(@SubstanceID as varchar(16))

	INSERT INTO dbo.ObjectLinkObject(ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy)
		SELECT DISTINCT @SubstanceObjectId as ObjectId, ObjectId as LinkedObjectId, 0 as SortCode, getdate(), @_createdBy, getdate(), @_createdBy
			FROM BandGap.dbo.Gap as G
			INNER JOIN dbo.ObjectInfo as R ON G.ReferenceID=R.ExternalId AND R.TypeId=3
		WHERE G.SubstanceID=@SubstanceID
--select DISTINCT SubstanceID, ReferenceID from BandGap.dbo.Gap WHERE SubstanceID=4750
/*
select DISTINCT SubstanceID, ReferenceID, ObjectId as ReferenceObjectId from BandGap.dbo.Gap as G
INNER JOIN dbo.ObjectInfo as R ON G.ReferenceID=R.ExternalId AND R.TypeId=3
WHERE G.SubstanceID=4750
*/
	PRINT '		done'
end
close c1
deallocate c1
SET NOCOUNT OFF;
GO
/*
DELETE from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
DELETE from ObjectLinkObject WHERE LinkedObjectId IN (select ObjectId from ObjectInfo WHERE TenantId=3)
*/
