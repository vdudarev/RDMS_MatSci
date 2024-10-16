USE [master]
GO
/****** Object:  Database [RUB_Clear]    Script Date: 16/10/2024 18:34:36 ******/
CREATE DATABASE [RUB_Clear]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RUB_INF', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RUB_Clear.mdf' , SIZE = 11712KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'RUB_INF_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RUB_Clear_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [RUB_Clear] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RUB_Clear].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RUB_Clear] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RUB_Clear] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RUB_Clear] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RUB_Clear] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RUB_Clear] SET ARITHABORT OFF 
GO
ALTER DATABASE [RUB_Clear] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RUB_Clear] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [RUB_Clear] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RUB_Clear] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RUB_Clear] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RUB_Clear] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RUB_Clear] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RUB_Clear] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RUB_Clear] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RUB_Clear] SET  DISABLE_BROKER 
GO
ALTER DATABASE [RUB_Clear] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RUB_Clear] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RUB_Clear] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RUB_Clear] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RUB_Clear] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RUB_Clear] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RUB_Clear] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RUB_Clear] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [RUB_Clear] SET  MULTI_USER 
GO
ALTER DATABASE [RUB_Clear] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RUB_Clear] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RUB_Clear] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RUB_Clear] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [RUB_Clear] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [RUB_Clear] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [RUB_Clear] SET QUERY_STORE = OFF
GO
USE [RUB_Clear]
GO
/****** Object:  User [webshop]    Script Date: 16/10/2024 18:34:36 ******/
CREATE USER [webshop] FOR LOGIN [webshop] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [vrouser]    Script Date: 16/10/2024 18:34:36 ******/
CREATE USER [vrouser] FOR LOGIN [vrouser] WITH DEFAULT_SCHEMA=[vro]
GO
ALTER ROLE [db_owner] ADD MEMBER [webshop]
GO
/****** Object:  Schema [vro]    Script Date: 16/10/2024 18:34:36 ******/
CREATE SCHEMA [vro]
GO
/****** Object:  UserDefinedTableType [dbo].[CompositionItem]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[CompositionItem] AS TABLE(
	[CompositionId] [int] NULL,
	[SampleId] [int] NULL,
	[CompoundIndex] [int] NULL,
	[ElementName] [varchar](2) NULL,
	[ValueAbsolute] [float] NULL,
	[ValuePercent] [float] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[Elements]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[Elements] AS TABLE(
	[Value] [varchar](2) NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[FilterCompositionItem]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[FilterCompositionItem] AS TABLE(
	[ElementName] [varchar](2) NULL,
	[ValueAbsoluteMin] [float] NULL,
	[ValueAbsoluteMax] [float] NULL,
	[ValuePercentMin] [float] NULL,
	[ValuePercentMax] [float] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[FilterPropertyItem]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[FilterPropertyItem] AS TABLE(
	[PropertyName] [varchar](256) NULL,
	[PropertyType] [varchar](32) NULL,
	[ValueMin] [float] NULL,
	[ValueMax] [float] NULL,
	[ValueString] [varchar](256) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[Integers]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[Integers] AS TABLE(
	[Value] [int] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ObjectLinkObjectItem]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[ObjectLinkObjectItem] AS TABLE(
	[ObjectLinkObjectId] [int] NULL,
	[ObjectId] [int] NULL,
	[LinkedObjectId] [int] NULL,
	[SortCode] [int] NULL,
	[LinkTypeObjectId] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[Strings]    Script Date: 16/10/2024 18:34:36 ******/
CREATE TYPE [dbo].[Strings] AS TABLE(
	[Value] [varchar](256) NOT NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[AreElementsOk]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[AreElementsOk]
(
    @Elements varchar(max)
)
-- Check for repeating elements in chemical system
-- introduced after system in Phases: Ca-Te-Te, Fe-Fe-Se, Se-Yb-Yb, O-Rb-Hf-Hf
-- PRINT [dbo].[AreElementsOk]('-S-Sr-Sc-F-')
-- PRINT [dbo].[AreElementsOk]('-S-S-Sr-Sc-F-')
RETURNS bit
AS
BEGIN
    if EXISTS (SELECT value, count(value) as cnt FROM dbo.mySTRING_SPLIT(@Elements, '-') GROUP BY value HAVING count(value)>1)
		return 0	-- ERROR - we have repeating elements
	return 1	-- OK
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetChamberFromString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetChamberFromString] (@name varchar(1024))
RETURNS varchar(32)		-- 'K3'
AS
-- PRINT dbo.[fn_GetChamberFromString]('4434 synthesis (co deposition, 190815-K7-2, id=40934)')
BEGIN
	DECLARE @i1 int = CHARINDEX ('-', @name)
	DECLARE @i2 int = CHARINDEX ('-', @name, @i1+1)
	if (@i1>0 AND @i2>1)
	begin
		RETURN SUBSTRING(@name, @i1+1, @i2-@i1-1)
	end
	SET @i1 = CHARINDEX ('_', @name)
	SET @i2 = CHARINDEX ('_', @name, @i1+1)
	if (@i1>0 AND @i2>1)
	begin
		RETURN SUBSTRING(@name, @i1+1, @i2-@i1-1)
	end
	RETURN NULL
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetMeasurementAreaObjectId]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetMeasurementAreaObjectId](
@TenantId int,
@TypeId_MeasurementArea int,	-- "Measurement Area" or "Composition" TypeId
@EDXCSV_ObjectId int,
@MeasurementArea_PropertyName varchar(64)='Measurement Area',
@MeasurementArea_Index int -- not zero-based, starts from 1
) RETURNS int
AS
-- Project "Dimension"
-- PRINT [dbo].[fn_GetMeasurementAreaObjectId](2, 8, 6678, 'Measurement Area', 1)
BEGIN
DECLARE @ObjectId int
	SELECT @ObjectId = ObjectId from dbo.PropertyInt WHERE PropertyName=@MeasurementArea_PropertyName and [Value]=@MeasurementArea_Index and ObjectId IN (
		select LinkedObjectId from dbo.ObjectLinkObject as L 
		inner join dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId AND TypeId=@TypeId_MeasurementArea
		where L.ObjectId=@EDXCSV_ObjectId
	)
RETURN ISNULL(@ObjectId, 0)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetRubricNameUrl_QuickByParent]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	get rubric path for URL
-- =============================================
CREATE    FUNCTION [dbo].[fn_GetRubricNameUrl_QuickByParent]
(	
@RubricId int			-- ИД рубрики до которой надо построить RubricNameURL
)
RETURNS varchar(8000)
AS
-- возвращаем СТРОКУ с путем до текущей рубрики. Построение пути начинаем с рубрики, следующей за @StartRubricID
---- пример использования:
---- PRINT [dbo].[fn_GetRubricNameUrl](340177)
BEGIN
	DECLARE @ParentId int, @Parent_RubricNameUrl varchar(8000), @RubricNameUrl varchar(8000), @RubricName varchar(256)
	SELECT TOP 1 @Parent_RubricNameUrl=ISNULL(PRI.RubricNameUrl, ''), @ParentId=RI.ParentId, @RubricNameUrl=RI.RubricNameUrl, @RubricName=RI.RubricName
		FROM dbo.RubricInfo as RI
		LEFT OUTER JOIN dbo.RubricInfo as PRI ON RI.ParentId=PRI.RubricId
	WHERE RI.RubricId=@RubricId
	--IF @RubricNameUrl IS NOT NULL AND LEN(@RubricNameUrl)>0
	--	RETURN @RubricNameUrl
	if @Parent_RubricNameUrl=''
		SET @RubricNameUrl = dbo.fn_Transliterate4URL(@RubricName)
	else
		SET @RubricNameUrl = @Parent_RubricNameUrl + '_' + dbo.fn_Transliterate4URL(@RubricName)
	RETURN @RubricNameUrl
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetRubricPathStringFull]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	Get rubric path (going from the node to tree root)
-- =============================================
CREATE      FUNCTION [dbo].[fn_GetRubricPathStringFull]
(	
@RubricId int,			-- Id of a rubric for which we are building a path
@Separator varchar(8)	-- separator in path
)
RETURNS varchar(8000)
AS
-- return a string with a path to current rubric
---- example:
---- PRINT [dbo].[fn_GetRubricPathStringFull](14167, ' -> ')
---- PRINT [dbo].[fn_GetRubricPathStringFull](14166, ' -> ')
BEGIN
	DECLARE @RetVal varchar(8000), @RubricName varchar(256), @ParentId int, @count int
	SET @RetVal=''
	SET @count=0
	WHILE (@RubricId IS NOT NULL AND @RubricId>0) AND @count<20
	begin
		SELECT TOP 1 @RubricName=RubricName, @ParentId=ParentId
			FROM dbo.RubricInfo WHERE RubricId=@RubricId
		SET @RubricName = ISNULL(@RubricName, '')
		SET @ParentId = ISNULL(@ParentId, 0)
		
		if LEN(@RetVal)=0
			SET @RetVal = @RubricName
		else
			SET @RetVal = @RubricName + @Separator + @RetVal
		SET @RubricId=@ParentId
		SET @count = @count + 1
	end
	RETURN @RetVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUserClaimCSV]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetUserClaimCSV]
(
    @UserId int,
    @ClaimType nvarchar(max)
)
-- Gets all claim values of specified claim (or all claims if NULL) for the User (specified by @UserId)
-- PRINT [dbo].[fn_GetUserClaimCSV](9, NULL)
-- PRINT [dbo].[fn_GetUserClaimCSV](9, 'Project')
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @ret nvarchar(max)
	SELECT @ret = COALESCE(@ret + ', ', '') + ClaimValue
	FROM dbo.AspNetUserClaims WHERE UserId=@UserId and ClaimType=IIF(@ClaimType IS NULL, ClaimType, @ClaimType)
	ORDER BY ClaimType, ClaimValue
	return @ret
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUserId_ByUserIdFromMDI]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Gets UserId in destination database by UserId in [RUB_MDI] database (NormalizedUserName is analyzed)
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetUserId_ByUserIdFromMDI]
(
	@srcUserId int,			-- UserId in [RUB_MDI] database
	@dstUserIdDefault int	-- Fallback if UserId in current database is not found
)
RETURNS int
AS
-- PRINT dbo.fn_GetUserId_ByUserIdFromMDI(7, 2)
BEGIN
	-- Declare the return variable here
	DECLARE @dstUserId int
	select @dstUserId=Id from dbo.AspNetUsers WHERE NormalizedUserName=(select NormalizedUserName from [RUB_MDI].dbo.AspNetUsers where Id=@srcUserId)
	RETURN ISNULL(@dstUserId, @dstUserIdDefault)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUserIdByName]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetUserIdByName] (@name NVARCHAR(MAX))
RETURNS int
AS
-- PRINT [dbo].[fn_GetUserIdByName]('Dudarev Victor')
-- PRINT [dbo].[fn_GetUserIdByName]('Zehl Rico')
BEGIN
	DECLARE @UserId int;
	SELECT TOP 1 @UserId=UserId from dbo.AspNetUserClaims as C
	INNER JOIN dbo.AspNetUsers as U ON C.UserId=U.Id
		WHERE C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name' AND UPPER(C.ClaimValue)=UPPER(@name)
		ORDER BY U.LockoutEnd ASC
    RETURN @UserId
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUserName]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetUserName] (@UserId int)
RETURNS NVARCHAR(MAX)
AS
-- PRINT [dbo].[fn_GetUserName](1)
-- PRINT [dbo].[fn_GetUserName](31)
BEGIN
	DECLARE @UserName NVARCHAR(MAX);
	SELECT TOP 1 @UserName=C.ClaimValue from dbo.AspNetUserClaims as C
	INNER JOIN dbo.AspNetUsers as U ON C.UserId=U.Id
		WHERE C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name' AND C.UserId=@UserId
		ORDER BY U.LockoutEnd ASC
    RETURN @UserName
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetUserRolesCSV]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetUserRolesCSV]
(
    @UserId int
)
-- Gets all roles for the User (specified by @UserId)
-- PRINT [dbo].[fn_GetUserRolesCSV](1)
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @roles varchar(1024) 
	SELECT @roles = COALESCE(@roles + ', ', '') + R.[Name]
	FROM dbo.AspNetRoles as R
	INNER JOIN dbo.AspNetUserRoles as UR ON R.Id = UR.RoleId
	WHERE UR.UserId=@UserId
	ORDER BY [Name]
	return @roles
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_IncrementVersionInName]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_IncrementVersionInName] (@name VARCHAR(512))
RETURNS VARCHAR(512)
AS
-- PRINT [dbo].[fn_IncrementVersionInName]('abc')
-- PRINT [dbo].[fn_IncrementVersionInName]('abc_57q')
-- PRINT [dbo].[fn_IncrementVersionInName]('abc_57')
BEGIN
--PRINT CHARINDEX('_','abc_1_2')	-- 4
--PRINT CHARINDEX('_',REVERSE('abc_1_2'))	-- 2
--PRINT LEN('abc_1_2') - CHARINDEX('_',REVERSE('abc_1_2')) + 1	-- 6
--PRINT (TRY_PARSE('11a' AS int) IS NULL)
DECLARE @i int, @ver int, @newName varchar(512)
SET @i = CHARINDEX('_',REVERSE(@name)) - 1
IF @i>0
	SET @ver = TRY_PARSE(RIGHT(@name, @i) AS int)
IF @ver IS NOT NULL	-- version is recognized in previous name => set up future name as "+1"
begin
	SET @ver = @ver + 1
	SET @newName = LEFT(@name, LEN(@name)-LEN(RIGHT(@name, @i))) + CAST(@ver as varchar(16))
end
ELSE	-- no version
begin
	SET @newName = @Name + '_2'
end
RETURN @newName
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SqlSanitize]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_SqlSanitize] (@sql VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
-- PRINT [dbo].[fn_SqlSanitize]('select ''-- abc')
BEGIN
	SET @sql = REPLACE(@sql, '''', '''''')
    RETURN @sql
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_StripHTML]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_StripHTML] (@HTMLText VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
-- PRINT [dbo].[fn_StripHTML]('<root><DeliveryComment>fgfg</DeliveryComment></root>')
BEGIN
    DECLARE @Start INT
    DECLARE @End INT
    DECLARE @Length INT
    SET @Start = CHARINDEX('<',@HTMLText)
    SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
    SET @Length = (@End - @Start) + 1
    WHILE @Start > 0 AND @End > 0 AND @Length > 0
    BEGIN
        SET @HTMLText = STUFF(@HTMLText,@Start,@Length,'')
        SET @Start = CHARINDEX('<',@HTMLText)
        SET @End = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
        SET @Length = (@End - @Start) + 1
    END
    RETURN LTRIM(RTRIM(@HTMLText))
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Transliterate]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* Transliteration GOST 7.79-2000 http://www.gsnti-norms.ru/norms/common/doc.asp?2&/norms/stands/7_79.htm */
CREATE      FUNCTION [dbo].[fn_Transliterate](@str varchar(4000))
returns varchar(8000)
-- PRINT [dbo].[fn_Transliterate]('Компьютеры')
-- PRINT [dbo].[fn_Transliterate4URL]('Компьютеры')
AS
BEGIN
	declare
		@len int,
		@i int,
		@chr varchar(1),
		@uChr varchar(1),
		@resChr varchar(3),
		@result varchar(8000)

	SET @result = ''
	SET @len = len(@str)
	SET @i = 1
  
	WHILE @i <= @len
	BEGIN
		set @chr = substring(@str, @i, 1)
		set @uChr = upper(@chr)

		IF @uChr in ('А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 
				'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
				'Ä', 'Ö', 'Ü', 'ß')
		begin
			set @resChr = case @uChr 
					when 'А' then 'a'
					when 'Б' then 'b'
					when 'В' then 'v'
					when 'Г' then 'g'
					when 'Д' then 'd'
					when 'Е' then 'e'
					when 'Ё' then 'yo'
					when 'Ж' then 'zh'
					when 'З' then 'z'
					when 'И' then 'i'
					when 'Й' then 'j'
					when 'К' then 'k'
					when 'Л' then 'l'
					when 'М' then 'm'
					when 'Н' then 'n'
					when 'О' then 'o'
					when 'П' then 'p'
					when 'Р' then 'r'
					when 'С' then 's'
					when 'Т' then 't'
					when 'У' then 'u'
					when 'Ф' then 'f'
					when 'Х' then 'kh'	-- when 'Х' then 'x'
					when 'Ц' then 'ts'	-- when 'Ц' then 'c'
					when 'Ч' then 'ch'
					when 'Ш' then 'sh'
					when 'Щ' then 'sch'	--		when 'Щ' then 'shh'
					when 'Ъ' then '``'
					when 'Ы' then 'y'''
					when 'Ь' then '`'
					when 'Э' then 'e`'
					when 'Ю' then 'yu'
					when 'Я' then 'ya'
					when 'Ä' then 'ae'
					when 'Ö' then 'oe'
					when 'Ü' then 'ue'
					when 'ß' then 'ss'
					else '' end
			if len(@resChr) <> 0 and 
				ASCII(@chr) in (ASCII('А'), ASCII('Б'), ASCII('В'), ASCII('Г'), ASCII('Д'), ASCII('Е'), ASCII('Ё'), ASCII('Ж'), ASCII('З'), ASCII('И'), 
						ASCII('Й'), ASCII('К'), ASCII('Л'), ASCII('М'), ASCII('Н'), ASCII('О'), ASCII('П'), ASCII('Р'), ASCII('С'), ASCII('Т'), 
						ASCII('У'), ASCII('Ф'), ASCII('Х'), ASCII('Ц'), ASCII('Ч'), ASCII('Ш'), ASCII('Щ'), ASCII('Ы'), ASCII('Э'), ASCII('Ю'), ASCII('Я')
						, ASCII('Ä'), ASCII('Ö'), ASCII('Ü'), ASCII('ß'))
			set @resChr = upper(substring(@resChr, 1, 1)) + substring(@resChr, 2, len(@resChr) - 1)

			set @result = @result + @resChr
		end
		ELSE
			set @result = @result + @chr

		set @i = @i + 1
  END -- WHILE @i <= @len

  RETURN (@result)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Transliterate4URL]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      FUNCTION [dbo].[fn_Transliterate4URL](@str varchar(4000))
returns varchar(8000)
AS 
-- PRINT [dbo].[fn_Transliterate4URL]('Набор аксессуаров Baader Q - Turret, 1,25"')
BEGIN
	declare @len int, @i int, @chr varchar(1), @allowed varchar(256), @result varchar(8000)
	SET @allowed = '-_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	SET @str = REPLACE(@str,'+','plus')
	SET @str = REPLACE(@str,' ','-')
	SET @str = REPLACE(@str,',','_')
	SET @str = REPLACE(@str,'.','_')
	SET @str = [dbo].[fn_Transliterate](@str)

	SET @result = ''
	SET @len = LEN(@str)
	SET @i = 1
	WHILE @i <= @len
	BEGIN
		set @chr = SUBSTRING(@str, @i, 1)
		if CHARINDEX(@chr, @allowed)>0
		begin
			set @result = @result + @chr
		end
		set @i = @i + 1
	END
	SET @i = 0
	SET @len = LEN(@result)
	WHILE @len<>@i
	begin
		SET @i=@len
		SET @result=REPLACE(@result,'__','_')
		SET @result=REPLACE(@result,'--','-')
		SET @result=REPLACE(@result,'_-','-')
		SET @result=REPLACE(@result,'-_','-')
		SET @len=LEN(@result)
	end
	RETURN (LOWER(@result))
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Transliterate4URLFields]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      FUNCTION [dbo].[fn_Transliterate4URLFields](@str varchar(4000))
returns varchar(8000)
AS 
-- PRINT [dbo].[fn_Transliterate4URL]('Набор аксессуаров Baader Q - Turret, 1,25"')
-- PRINT [dbo].[fn_Transliterate4URLFields]('Набор аксессуаров Baader Q - Turret, 1,25"')
-- PRINT [dbo].[fn_Transliterate4URLFields]('#a#Диагональ#/a# дисплея')
BEGIN
	declare @len int, @i int, @chr varchar(1), @allowed varchar(256)
	DECLARE @result varchar(8000) = [dbo].[fn_Transliterate4URL]([dbo].[_fn_ReplacePhrases](@str, ''))
	SET @result = REPLACE(@result,'_','-')
	SET @i = 0
	SET @len = LEN(@result)
	WHILE @len<>@i
	begin
		SET @i=@len
		SET @result=REPLACE(@result,'--','-')
		SET @len=LEN(@result)
	end
	RETURN (LOWER(@result))
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnRubricInfo_CalculateLeafFlag]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[fnRubricInfo_CalculateLeafFlag]
(@RubricId int) 
RETURNS int
AS
BEGIN
-- Calculate the LeafFlag for a given rubric
DECLARE @LeafFlagDB int, @LeafFlag int, @WithObjects int, @WithLinkedObjects int, @EndRubric int
-- Least significant bit:
-- 0x1 - presence of objects (in ObjectInfo): 0 - no objects; 1 - there are objects;
-- 0x2 - presence of objects (in ObjectLinkRubric): 0 - no objects; 1 - links exist;
-- 0x4 - Is Rubric End / Leaf (child free): 0 - no children (leaf); 1 - there are children (not leaf);
SELECT @LeafFlagDB=LeafFlag FROM dbo.RubricInfo WHERE RubricId=@RubricId
IF @LeafFlagDB IS NULL	-- not found
	RETURN -1;

IF EXISTS (SELECT TOP 1 ObjectId FROM dbo.ObjectInfo WHERE RubricId=@RubricId)
	SET @WithObjects=1
ELSE
	SET @WithObjects=0

IF EXISTS (SELECT TOP 1 ObjectId FROM dbo.ObjectLinkRubric WHERE RubricId=@RubricId)
	SET @WithLinkedObjects=1
ELSE
	SET @WithLinkedObjects=0

IF EXISTS (SELECT TOP 1 RubricId FROM dbo.RubricInfo WHERE ParentId=@RubricId)
	SET @EndRubric=0
ELSE
	SET @EndRubric=1

SET @LeafFlag = 4 * @EndRubric + 2 * @WithLinkedObjects + @WithObjects

RETURN @LeafFlag
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetElementsCountFromString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetElementsCountFromString] (
@Elements varchar(32)
)
RETURNS int	-- Подсчитывает количество элементов в химической системе (ведущие и оконечные тире не влияют)
-- PRINT [dbo].[GetElementsCountFromString]('-S-Sr-Sc-F-')
AS
BEGIN
	DECLARE @RetVal varchar(32)
	DECLARE @ch varchar(1)
	DECLARE @i int, @Count int, @Len int
	SET @RetVal = ''
	SET @i = 1
	SET @Count = 0
	SET @Elements = @Elements + '-'		-- гарантированно заканчиваем строку на '-'
	SET @Len=Len(@Elements)
	while @i<=@Len
	begin
		SET @ch = SUBSTRING (@Elements, @i, 1)
		IF @ch='-'
		begin
			if @RetVal<>''
			begin
				SET @Count = @Count + 1
				SET @RetVal = ''
			end
		end
		ELSE
			SET @RetVal = @RetVal + @ch
		SET @i = @i+1
	end
	RETURN @Count
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetFilterString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[GetFilterString] (
@TenantId int, 
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0,
@FilterCompositionItems dbo.FilterCompositionItem READONLY,
@FilterPropertyItems dbo.FilterPropertyItem READONLY,
@TypeId int=null,
@SearchPhrase varchar(512)=null,
@CreatedByUser int=null,
@CreatedMin datetime=null,	
@CreatedMax datetime=null,
@ObjectId int=null,
@ExternalId int=null,
@JSON varchar(max)	-- all filter values (extensibility for future)
)
RETURNS NVARCHAR(4000)
-- PRINT [dbo].[GetFilterString](...)
AS
BEGIN
	DECLARE @PropertyCount int
	select @PropertyCount=count(PropertyName) from @FilterPropertyItems
	SET @SearchPhrase = ISNULL(@SearchPhrase, '')
DECLARE @filter NVARCHAR(4000) = ' AND TenantId=@TenantId'
	-- consider all filters
	SET @filter = @filter + [dbo].[GetFilterString_CompositionItems](@TenantId, @FilterCompositionItems, @JSON)
	SET @filter = @filter + [dbo].[GetFilterString_PropertyItems](@TenantId, @FilterPropertyItems, @JSON)
	IF ISNULL(@TypeId,0)!=0
		SET @filter = @filter + ' AND TypeId=@TypeId'
	IF LEN(@SearchPhrase)>0
		SET @filter = @filter + ' AND (ObjectName LIKE ''%'' + @SearchPhrase + ''%'' OR ObjectDescription LIKE ''%'' + @SearchPhrase + ''%'')'
	IF @CreatedByUser>0
		SET @filter = @filter + ' AND _createdBy=@CreatedByUser'
	IF @CreatedMin IS NOT NULL
		SET @filter = @filter + ' AND _created>=@CreatedMin'
	IF @CreatedMax IS NOT NULL
		SET @filter = @filter + ' AND _created<=@CreatedMax'
	IF @ObjectId != 0
		SET @filter = @filter + ' AND ObjectId=@ObjectId'
	IF @ExternalId != 0
		SET @filter = @filter + ' AND ExternalId=@ExternalId'
-- @AccessControl + @UserId

	--IF @AccessControl >= 0 and @UserId > 0	-- restrictions with user
	--begin
	--	SET @filter = @filter + ' AND (AccessControl<=@AccessControl OR _createdBy=@UserId)'
	--end

	IF @AccessControl >= 0 and @UserId != 0	-- restrictions with user
	begin
		SET @filter = @filter + ' AND (AccessControl<=@AccessControl OR _createdBy=@UserId)'
	end
	ELSE IF @AccessControl = 0	-- restrictions for anonymous user (public)
	begin
		SET @filter = @filter + ' AND AccessControl<=@AccessControl'
	end
	ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
	begin
		SET @filter = @filter;
	end
	ELSE	-- exception
	begin
		return cast('Unknown security context' as int);
	end;
	--IF @AccessControl>=0 AND @AccessControl<3		-- all rubrics with public or protected
	--	SET @filter = @filter + ' AND AccessControl<=@AccessControl'
	--ELSE IF @AccessControl=3 AND @UserId>0		-- all rubrics with public or protected OR private for current user
	--	SET @filter = @filter + ' AND (AccessControl<@AccessControl OR _createdBy=@UserId)'
	-- make filter expression with WHERE
	IF LEN(@filter)>0
		SET @filter = ' WHERE ' + RIGHT(@filter, LEN(@filter)-4)
	RETURN @filter
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetFilterString_CompositionItem]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[GetFilterString_CompositionItem]
(@ElementName varchar(2), @ValueAbsoluteMin float, @ValueAbsoluteMax float, @ValuePercentMin float, @ValuePercentMax float)
RETURNS NVARCHAR(4000)
AS
-- PRINT [dbo].[GetFilterString_CompositionItem]('As', 1, 1, NULL, NULL)
BEGIN
	SET @ElementName = [dbo].[fn_SqlSanitize](ISNULL(@ElementName, ''))

	DECLARE @retVal varchar(4000)=''	-- AND ObjectId IN (select SampleId from dbo.vSample WHERE TenantId=@TenantId AND dbo.IsSystemContainsAllElementsComposition([Elements], @FilterCompositionItems)=1)'

	IF (@ValueAbsoluteMin IS NOT NULL OR @ValueAbsoluteMax IS NOT NULL)				-- Absolute
	BEGIN
		IF @ValueAbsoluteMin IS NOT NULL
			SET @retVal = @retVal + ' AND ValueAbsolute>=' + CAST(@ValueAbsoluteMin as varchar(32))
		IF @ValueAbsoluteMax IS NOT NULL
			SET @retVal = @retVal + ' AND ValueAbsolute<=' + CAST(@ValueAbsoluteMax as varchar(32))
	END
	ELSE IF (@ValuePercentMin IS NOT NULL OR @ValuePercentMax IS NOT NULL)				-- Absolute
	BEGIN
		IF @ValuePercentMin IS NOT NULL
			SET @retVal = @retVal + ' AND ValuePercent>=' + CAST(@ValuePercentMin as varchar(32))
		IF @ValuePercentMax IS NOT NULL
			SET @retVal = @retVal + ' AND ValuePercent<=' + CAST(@ValuePercentMax as varchar(32))
	END

	IF @retVal<>''	-- USE COMPOSITION
	begin
		IF @ElementName<>''		-- ElementName
			SET @retVal = @retVal + ' AND ElementName=''' + @ElementName + ''''

		SET @retVal = ' AND ObjectId IN (select SampleId from dbo.vComposition WHERE TenantId=@TenantId '+ @retVal +')'
	end
	ELSE IF @ElementName<>''	-- USE SYSTEM
	begin
		SET @retVal = ' AND ObjectId IN (select SampleId from dbo.vSample WHERE TenantId=@TenantId AND CHARINDEX(''-'+@ElementName+'-'', Elements)>0)'
	end
    RETURN @retVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetFilterString_CompositionItems]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[GetFilterString_CompositionItems] (
@TenantId int, 
@FilterCompositionItems dbo.FilterCompositionItem READONLY,
@JSON varchar(max)	-- all filter values (extensibility for future)
)
RETURNS NVARCHAR(4000)
-- DECLARE @C dbo.FilterCompositionItem PRINT [dbo].[GetFilterString_CompositionItems](1, @C, '')
-- DECLARE @C dbo.FilterCompositionItem INSERT INTO @C(ElementName) VALUES('Ga'),('As') PRINT [dbo].[GetFilterString_CompositionItems](1, @C, '')
-- DECLARE @C dbo.FilterCompositionItem INSERT INTO @C(ElementName, ValueAbsoluteMin, ValueAbsoluteMax) VALUES('Ga',1,1),('As',1,1) PRINT [dbo].[GetFilterString_CompositionItems](1, @C, '')
AS
BEGIN
	DECLARE @filter NVARCHAR(4000) = '';
	/*
	DECLARE @CompositionCount int
	select @CompositionCount=count(ElementName) from @FilterCompositionItems
	IF @CompositionCount>0
	begin
		-- SET @filter = ' AND TypeId IN (select TypeId from dbo.TypeInfo WHERE TableName IN (''Sample'', ''Composition''))'
		-- 1. consider only chemical systems
		DECLARE @Elements dbo.[Elements]
		INSERT INTO @Elements([Value]) SELECT ElementName from @FilterCompositionItems WHERE LEN(ElementName)>0 AND ISNULL(ValueAbsoluteMin,0)=0 AND ISNULL(ValueAbsoluteMax,0)=0 AND ISNULL(ValuePercentMin,0)=0 AND ISNULL(ValuePercentMax,0)=0
		if (@@ROWCOUNT>0)
			SET @filter = @filter + ' AND ObjectId IN (select SampleId from dbo.vSample WHERE TenantId=@TenantId AND dbo.IsSystemContainsAllElementsComposition([Elements], @FilterCompositionItems)=1)'
		-- DELETE FROM @FilterCompositionItems WHERE ISNULL(ValueAbsoluteMin,0)=0 AND ISNULL(ValueAbsoluteMax,0)=0 AND ISNULL(ValuePercentMin,0)=0 AND ISNULL(ValuePercentMax,0)=0
		-- 2. consider chemical compounds
		DECLARE @FilterCompositionItemsONLY dbo.FilterCompositionItem
		INSERT INTO @FilterCompositionItemsONLY(ElementName, ValueAbsoluteMin, ValueAbsoluteMax, ValuePercentMin, ValuePercentMax)
			SELECT ElementName, ValueAbsoluteMin, ValueAbsoluteMax, ValuePercentMin, ValuePercentMax FROM @FilterCompositionItems 
				WHERE ISNULL(ValueAbsoluteMin,0)<>0 OR ISNULL(ValueAbsoluteMax,0)<>0 OR ISNULL(ValuePercentMin,0)<>0 OR ISNULL(ValuePercentMax,0)<>0
		if (@@ROWCOUNT>0)
		begin
-- TO DO
		-- dbo.Composition: SampleId, ElementName, ValueAbsolute, ValuePercent
			-- SET @filter = @filter + ' AND ObjectId IN (select SampleId from dbo.Composition WHERE dbo.IsCompositionFits([Elements], @FilterCompositionItemsONLY)=1)'
			SET @filter = @filter
		end

	end
	*/
	SELECT @filter = COALESCE(@filter, '') + [dbo].[GetFilterString_CompositionItem](ElementName, ValueAbsoluteMin, ValueAbsoluteMax, ValuePercentMin, ValuePercentMax)
		FROM @FilterCompositionItems
	RETURN @filter
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetFilterString_PropertyItem]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[GetFilterString_PropertyItem]
(@PropertyName varchar(256), @PropertyType varchar(32), @ValueMin float, @ValueMax float, @ValueString varchar(256))
RETURNS NVARCHAR(4000)
AS
-- PRINT [dbo].[GetFilterString_PropertyItem]('E', 'Float', 2, 3, NULL)
-- PRINT [dbo].[GetFilterString_PropertyItem]('E', 'Float', 2, NULL, NULL)
-- PRINT [dbo].[GetFilterString_PropertyItem]('E', 'Int', NULL, 5, NULL)
-- PRINT [dbo].[GetFilterString_PropertyItem]('Comment', 'String', NULL, 0, 'string')
-- PRINT [dbo].[GetFilterString_PropertyItem]('Comment', 'String', NULL, 1, 'string')
-- PRINT [dbo].[GetFilterString_PropertyItem]('Comment', 'String', NULL, 2, 'string')
-- PRINT [dbo].[GetFilterString_PropertyItem]('Comment', 'String', NULL, 3, 'string')
BEGIN
	DECLARE @retVal varchar(4000)=''
	SET @PropertyName = ISNULL(@PropertyName, '')
	SET @PropertyName = [dbo].[fn_SqlSanitize](@PropertyName)
	IF LEN(@PropertyName)<1
		return @retVal;
	IF (@PropertyType='Float' OR @PropertyType='Int') and (@ValueMin IS NOT NULL OR @ValueMax IS NOT NULL)
	BEGIN
		IF @ValueMin IS NOT NULL
			SET @retVal = @retVal + '[Value]>=' + CAST(@ValueMin as varchar(32))
		IF @ValueMax IS NOT NULL
		begin
			IF @retVal<>''
				SET @retVal = @retVal + ' AND '
			SET @retVal = @retVal + '[Value]<=' + CAST(@ValueMax as varchar(32))
		end
		SET @retVal = CONCAT(' AND ObjectId IN (select ObjectId from dbo.[Property', @PropertyType, '] where PropertyName=''' , @PropertyName , ''' AND ', @retVal, ')') 
	END
	ELSE IF (@PropertyType='BigString' OR @PropertyType='String') and @ValueString is not null
	BEGIN
		SET @ValueString = [dbo].[fn_SqlSanitize](@ValueString)
		SET @ValueMax = ISNULL(@ValueMax, 0)
		IF @ValueMax=1	-- StartsWith
			SET @retVal = CONCAT(' AND ObjectId IN (select ObjectId from dbo.[Property', @PropertyType, '] where PropertyName=''' , @PropertyName , ''' AND [Value] LIKE ''', @ValueString, '%'')') 
		ELSE IF @ValueMax=2	-- EndsWith
			SET @retVal = CONCAT(' AND ObjectId IN (select ObjectId from dbo.[Property', @PropertyType, '] where PropertyName=''' , @PropertyName , ''' AND [Value] LIKE ''%', @ValueString, ''')') 
		ELSE IF @ValueMax=3	-- StartsWith + EndsWith
			SET @retVal = CONCAT(' AND ObjectId IN (select ObjectId from dbo.[Property', @PropertyType, '] where PropertyName=''' , @PropertyName , ''' AND [Value] LIKE ''%', @ValueString, '%'')') 
		ELSE				-- ==
			SET @retVal = CONCAT(' AND ObjectId IN (select ObjectId from dbo.[Property', @PropertyType, '] where PropertyName=''' , @PropertyName , ''' AND [Value]=''', @ValueString, ''')') 
	END
    RETURN @retVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetFilterString_PropertyItems]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       FUNCTION [dbo].[GetFilterString_PropertyItems] (
@TenantId int,
@FilterPropertyItems dbo.FilterPropertyItem READONLY,
@JSON varchar(max)	-- all filter values (extensibility for future)
)
RETURNS NVARCHAR(4000)
-- DECLARE @F dbo.FilterPropertyItem; INSERT @F(PropertyName, PropertyType, ValueMin, ValueMax, ValueString) VALUES('E', 'Float', 2, null, NULL), ('Q', 'Int', NULL, 3, NULL), ('Com', 'String', NULL, NULL, 'q"a''z'); PRINT [dbo].[GetFilterString_PropertyItems](3, @F, '')
AS
BEGIN
	-- DECLARE @PropertyName varchar(64), @PropertyType varchar(32), @ValueMin float, @ValueMax float, @ValueString varchar(256)
	DECLARE @filter NVARCHAR(4000) = '';
	SELECT @filter = COALESCE(@filter, '') + [dbo].[GetFilterString_PropertyItem](PropertyName, PropertyType, ValueMin, ValueMax, ValueString)
		FROM @FilterPropertyItems
	RETURN @filter
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetSortedElementsFromString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetSortedElementsFromString] (
@Elements varchar(256)
)
RETURNS varchar(256)	-- Получаем список отсортированных элементов с префиксом и сууфиксом '-'
-- PRINT [dbo].[GetSortedElementsFromString]('-S-Sr-Sc-F-')
-- PRINT [dbo].[GetSortedElementsFromString]('S-Sr-Sc-F')
AS
BEGIN
	DECLARE @TableVar table(El varchar(2) NOT NULL)
	DECLARE @RetVal varchar(256)
	DECLARE @El varchar(2), @ch varchar(1)
	DECLARE @i int, @Len int
	SET @RetVal = ''
	SET @i = 1
	SET @Elements = @Elements + '-'		-- гарантированно заканчиваем строку на '-'
	SET @Len=Len(@Elements)
	while @i<=@Len
	begin
		SET @ch = SUBSTRING (@Elements, @i, 1)
		IF @ch='-'
		begin
			if @RetVal<>''
			begin
				INSERT INTO @TableVar(El) Values (@RetVal)
				SET @RetVal = ''
			end
		end
		ELSE
			SET @RetVal = @RetVal + @ch
		SET @i = @i+1
	end
	-- теперь отсортируем табличку и получим упорядоченный набор
	SET @RetVal = ''
	declare c1 cursor local FORWARD_ONLY STATIC for 
		SELECT El FROM @TableVar ORDER BY El
	open c1
	while (1=1)
	begin
		fetch c1 into @El
		if @@fetch_status <> 0 break
		if @El IS NOT NULL
			SET @RetVal = @RetVal + @El + '-'
	end
	close c1
	deallocate c1
	IF LEN(@RetVal)>0
		SET @RetVal = '-' + @RetVal
	RETURN @RetVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetTypeIdForCompact]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[GetTypeIdForCompact]
(
    @Characterization varchar(256), 
	@ProcessingState varchar(256),
	@CadRefFileName varchar(256)
)
-- Get Type for COMPACT document
-- PRINT [dbo].[GetTypeIdForCompact]('photo', 'Processed Data', '0008457 AgAuCuPdPt library test 1_000062373.jpg')
-- PRINT [dbo].[GetTypeIdForCompact]('chem. composition', 'Processed Data', '0008457 AgAuCuPdPt on Ti EDX map_000061977.txt')
-- PRINT [dbo].[GetTypeIdForCompact]('chem. composition', 'Processed Data', '0008457 AgAuCuPdPt on Ti EDX map_000061977.jpg')
RETURNS int
AS
BEGIN
	DECLARE @ext varchar(4) = LOWER(RIGHT(@CadRefFileName, 4))
    if @Characterization='Sample'
		RETURN 6	-- Sample
    if @Characterization='Synthesis'
		RETURN 18	-- Synthesis

    if @Characterization='photo'
		RETURN 12	-- Photo

-- APT
    if @Characterization='APT'
		RETURN 20	-- APT

-- chem. composition == EDX
    if @Characterization='chem. composition' AND (@ext='.txt' OR @ext='.csv')
		RETURN 13	-- EDX CSV
    if @Characterization='chem. composition' AND (@ext='.png' OR @ext='.jpg' OR @ext='jpeg' OR @ext='gif' OR @ext='bmp' OR @ext='.tif' OR @ext='tiff')
		RETURN 15	-- EDX Image

-- el. resistance == HTTS Resistance CSV
    if @Characterization='el. resistance' AND (@ext='.txt' OR @ext='.csv')
		RETURN 14	-- HTTS Resistance CSV
    if @Characterization='el. resistance' AND (@ext='.png' OR @ext='.jpg' OR @ext='jpeg' OR @ext='gif' OR @ext='bmp' OR @ext='.tif' OR @ext='tiff')
		RETURN 16	-- HTTS Resistance Image

-- magnetic properties
    if @Characterization='magnetic properties'
		RETURN 21	-- Magnetic properties
-- nanoindentation
    if @Characterization='nanoindentation'
		RETURN 22	-- Nanoindentation
-- oscilloscope
    if @Characterization='oscilloscope'
		RETURN 23	-- Oscilloscope
-- SEM (image)
    if @Characterization='SEM (image)'
		RETURN 24	-- SEM (image)
-- synchrotron
    if @Characterization='synchrotron'
		RETURN 25	-- Synchrotron
-- TEM image
    if @Characterization='TEM image'
		RETURN 26	-- TEM image
-- thickness
    if @Characterization='thickness'
		RETURN 27	-- Thickness
-- topography
    if @Characterization='topography'
		RETURN 28	-- Topography
-- UV-VIS
    if @Characterization='UV-VIS'
		RETURN 29	-- UV-VIS
-- XPS
    if @Characterization='XPS'
		RETURN 30	-- XPS
-- XRD
    if @Characterization='XRD' AND (@ext='.txt' OR @ext='.csv')
		RETURN 17	-- XRD CSV
    if @Characterization='XRD' AND (@ext='.png' OR @ext='.jpg' OR @ext='jpeg' OR @ext='gif' OR @ext='bmp' OR @ext='.tif' OR @ext='tiff')
		RETURN 31	-- XRD Image

-- other
	-- BY DEFAULT
	return 7	-- Raw Document
END
GO
/****** Object:  UserDefinedFunction [dbo].[Int2FixedLengthString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[Int2FixedLengthString]
(
	@Number int,	-- number, which will be filled with zeroes from left till thwe length @LengthRequired is assumed
	@LengthRequired int=8	-- required string length (in the result)
)
RETURNS varchar(8000)
-- returns a string of fixed length @LengthRequired (filled by 0) from @Number number
AS
BEGIN
	DECLARE @RetVal varchar(8000), @Length int
	SET @RetVal = CAST(@Number AS varchar(16))
	SET @Length = LEN(@RetVal)

	if @Length<@LengthRequired
		SET @RetVal = REPLICATE('0', @LengthRequired-LEN(@RetVal))+ @RetVal

	RETURN @RetVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsSystemContainsAllElements]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsSystemContainsAllElements]
(
	@System varchar(256),	-- 	'-As-Ga-'
	@Elements dbo.[Elements] READONLY		-- ['As', 'Ga']
)
-- DECLARE @dt as dbo.[Elements]; INSERT INTO @dt VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElements]('-S-Sr-Sc-F-', @dt)
-- DECLARE @dt as dbo.[Elements]; INSERT INTO @dt VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElements]('-As-Ga-', @dt)
-- DECLARE @dt as dbo.[Elements]; INSERT INTO @dt VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElements]('-As-', @dt)
-- Ag-Au-Pd-Pt-X
-- DECLARE @dt as dbo.[Elements]; INSERT INTO @dt VALUES('Ag'),('Au'),('Pd'),('Pt'); select * from vSample where TypeId=6 and ElemNumber=5 and [dbo].[IsSystemContainsAllElements](Elements, @dt)=1
-- Au-Pd-Pt-Rh-X
-- DECLARE @dt as dbo.[Elements]; INSERT INTO @dt VALUES('Au'),('Pd'),('Rh'),('Pt'); select * from vSample where TypeId=6 and [dbo].[IsSystemContainsAllElements](Elements, @dt)=1
RETURNS bit
AS
BEGIN
    if EXISTS (select top 1 [Value] from @Elements WHERE CHARINDEX ('-'+[Value]+'-', @System)=0)
		return 0	-- Missing Element Is Found
	return 1	-- OK
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsSystemContainsAllElementsComposition]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[IsSystemContainsAllElementsComposition]
(
	@System varchar(256),	-- 	'-As-Ga-'
	@FilterCompositionItems dbo.FilterCompositionItem READONLY	-- ['As', 'Ga']
)
-- DECLARE @dt as dbo.[FilterCompositionItem]; INSERT INTO @dt(ElementName) VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElementsComposition]('-S-Sr-Sc-F-', @dt)
-- DECLARE @dt as dbo.[FilterCompositionItem]; INSERT INTO @dt(ElementName) VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElementsComposition]('-As-Ga-', @dt)
-- DECLARE @dt as dbo.[FilterCompositionItem]; INSERT INTO @dt(ElementName) VALUES('As'),('Ga'); PRINT [dbo].[IsSystemContainsAllElementsComposition]('-As-', @dt)
RETURNS bit
AS
BEGIN
    if EXISTS (select top 1 ElementName from @FilterCompositionItems WHERE LEN(ElementName)>0 AND CHARINDEX('-'+ElementName+'-', @System)=0)
		return 0	-- Missing Element Is Found
	return 1	-- OK
END
GO
/****** Object:  UserDefinedFunction [dbo].[NormalizeElements]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[NormalizeElements] (
@Elements varchar(256)
)
RETURNS varchar(256)	-- List of elements
-- remove left and right dashes (nothing more), i.e. instead of '--As-Ga--' we will get 'As-Ga'
-- PRINT [dbo].[NormalizeElements]('--As-Ga--')
-- PRINT [dbo].[NormalizeElements]('--Ga-As--')
-- PRINT RTRIM(LTRIM('--Ga-As--', '-'), '-')
AS
BEGIN
	--while LEFT(@Elements, 1)='-'
	--	SET @Elements=RIGHT(@Elements, LEN(@Elements)-1)
	--while RIGHT(@Elements, 1)='-'
	--	SET @Elements=LEFT(@Elements, LEN(@Elements)-1)
	RETURN RTRIM(LTRIM(@Elements, '-'), '-')
END
GO
/****** Object:  UserDefinedFunction [dbo].[ValidateElements]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[ValidateElements]
(
    @Elements varchar(max)
)
-- Проверка на повторяющиеся элементы в химической системе и на существование самих элементов
-- введена после того, как в БД Фазы нашлись системы: Ca-Te-Te, Fe-Fe-Se, Se-Yb-Yb, O-Rb-Hf-Hf
-- PRINT [dbo].[ValidateElements]('-S-Sr-Sc-F-')	-- NULL
-- PRINT [dbo].[ValidateElements]('-S-S-Sr-Sc-F-')	-- Repeated element: S
-- PRINT [dbo].[ValidateElements]('-S-X-Sr-Sc-F-')	-- Unknown element: X
RETURNS varchar(256)
AS
BEGIN
	DECLARE @msg varchar(256) = NULL
	SET @Elements = TRIM('-' FROM @Elements)

	SELECT TOP 1 @msg=[value] FROM STRING_SPLIT(@Elements, '-') as S
		LEFT OUTER JOIN dbo.ElementInfo as E WITH (NOLOCK) ON S.[value]=E.ElementName WHERE E.ElementName IS NULL
	IF @msg IS NOT NULL
		RETURN 'Unknown element: "' + @msg + '"'

	SELECT @msg=[value] FROM STRING_SPLIT(@Elements, '-') GROUP BY [value] HAVING count([value])>1
	IF @msg IS NOT NULL
		RETURN 'Repeated element: "' + @msg + '"'

	RETURN @msg
END
GO
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetRoleClaims]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetRoleClaims]
as
-- SELECT * FROM [vro].[vroAspNetRoleClaims]
-- UPDATE [vro].[vroAspNetRoleClaims] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetRoleClaims 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetRoleClaims WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetRoles]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetRoles]
as
-- SELECT * FROM [vro].[vroAspNetRoles]
-- UPDATE [vro].[vroAspNetRoles] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetRoles 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetRoles WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetUserClaims]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetUserClaims]
as
-- SELECT * FROM [vro].[vroAspNetUserClaims]
-- UPDATE [vro].[vroAspNetUserClaims] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetUserClaims 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetUserClaims WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetUserLogins]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetUserLogins]
as
-- SELECT * FROM [vro].[vroAspNetUserLogins]
-- UPDATE [vro].[vroAspNetUserLogins] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetUserLogins 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetUserLogins WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetUserRoles]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetUserRoles]
as
-- SELECT * FROM [vro].[vroAspNetUserRoles]
-- UPDATE [vro].[vroAspNetUserRoles] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetUserRoles 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetUserRoles WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[Email] [nvarchar](256) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetUsers]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetUsers]
as
-- SELECT * FROM [vro].[vroAspNetUsers]
-- UPDATE [vro].[vroAspNetUsers] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetUsers 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetUsers WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserTokens](
	[UserId] [int] NOT NULL,
	[LoginProvider] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroAspNetUserTokens]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroAspNetUserTokens]
as
-- SELECT * FROM [vro].[vroAspNetUserTokens]
-- UPDATE [vro].[vroAspNetUserTokens] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.AspNetUserTokens 
UNION ALL SELECT TOP 0 * FROM dbo.AspNetUserTokens WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[Composition]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Composition](
	[CompositionId] [int] NOT NULL,
	[SampleId] [int] NOT NULL,
	[CompoundIndex] [int] NOT NULL,
	[ElementName] [varchar](2) NOT NULL,
	[ValueAbsolute] [float] NULL,
	[ValuePercent] [float] NOT NULL,
 CONSTRAINT [PK_SampleComposition] PRIMARY KEY CLUSTERED 
(
	[CompositionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroComposition]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroComposition]
as
-- SELECT * FROM [vro].[vroComposition]
-- UPDATE [vro].[vroComposition] SET CompositionId=CompositionId+1 WHERE CompositionId=1
SELECT * FROM dbo.Composition 
UNION ALL SELECT TOP 0 * FROM dbo.Composition WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[ElementInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ElementInfo](
	[ElementId] [int] NOT NULL,
	[ElementName] [varchar](2) NOT NULL,
 CONSTRAINT [PK_Elements] PRIMARY KEY CLUSTERED 
(
	[ElementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroElementInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroElementInfo]
as
-- SELECT * FROM [vro].[vroElementInfo]
-- UPDATE [vro].[vroElementInfo] SET ElementId=ElementId+1 WHERE ElementId=1
SELECT * FROM dbo.ElementInfo 
UNION ALL SELECT TOP 0 * FROM dbo.ElementInfo WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[Handover]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Handover](
	[HandoverId] [int] NOT NULL,
	[SampleObjectId] [int] NOT NULL,
	[DestinationUserId] [int] NOT NULL,
	[DestinationConfirmed] [datetime] NULL,
	[DestinationComments] [varchar](128) NULL,
	[Json] [varchar](max) NULL,
	[Amount] [float] NULL,
	[MeasurementUnit] [varchar](32) NULL,
 CONSTRAINT [PK_Handover] PRIMARY KEY CLUSTERED 
(
	[HandoverId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroHandover]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroHandover]
as
-- SELECT * FROM [vro].[vroHandover]
-- UPDATE [vro].[vroHandover] SET HandoverId=HandoverId+1 WHERE HandoverId=1
SELECT * FROM dbo.Handover 
UNION ALL SELECT TOP 0 * FROM dbo.Handover WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[ObjectInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ObjectInfo](
	[ObjectId] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[RubricId] [int] NULL,
	[SortCode] [int] NOT NULL,
	[AccessControl] [int] NOT NULL,
	[IsPublished] [bit] NOT NULL,
	[ExternalId] [int] NULL,
	[ObjectName] [varchar](512) NOT NULL,
	[ObjectNameUrl] [varchar](256) NOT NULL,
	[ObjectFilePath] [varchar](256) NULL,
	[ObjectFileHash] [varchar](128) NULL,
	[ObjectDescription] [varchar](1024) NULL,
 CONSTRAINT [PK_ObjectInfo] PRIMARY KEY CLUSTERED 
(
	[ObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroObjectInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroObjectInfo]
as
-- SELECT * FROM [vro].[vroObjectInfo]
-- UPDATE [vro].[vroObjectInfo] SET ObjectId=ObjectId+1 WHERE ObjectId=1
SELECT * FROM dbo.ObjectInfo 
UNION ALL SELECT TOP 0 * FROM dbo.ObjectInfo WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[ObjectLinkObject]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ObjectLinkObject](
	[ObjectLinkObjectId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[LinkedObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[LinkTypeObjectId] [int] NULL,
 CONSTRAINT [PK_ObjectLinkObject] PRIMARY KEY CLUSTERED 
(
	[ObjectLinkObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroObjectLinkObject]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroObjectLinkObject]
as
-- SELECT * FROM [vro].[vroObjectLinkObject]
-- UPDATE [vro].[vroObjectLinkObject] SET ObjectLinkObjectId=ObjectLinkObjectId+1 WHERE ObjectLinkObjectId=1
SELECT * FROM dbo.ObjectLinkObject 
UNION ALL SELECT TOP 0 * FROM dbo.ObjectLinkObject WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[ObjectLinkRubric]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ObjectLinkRubric](
	[ObjectLinkRubricId] [int] IDENTITY(1,1) NOT NULL,
	[RubricId] [int] NOT NULL,
	[ObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
 CONSTRAINT [PK_ObjectLinkRubric] PRIMARY KEY CLUSTERED 
(
	[ObjectLinkRubricId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroObjectLinkRubric]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroObjectLinkRubric]
as
-- SELECT * FROM [vro].[vroObjectLinkRubric]
-- UPDATE [vro].[vroObjectLinkRubric] SET ObjectLinkRubricId=ObjectLinkRubricId+1 WHERE ObjectLinkRubricId=1
SELECT * FROM dbo.ObjectLinkRubric 
UNION ALL SELECT TOP 0 * FROM dbo.ObjectLinkRubric WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[PropertyBigString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyBigString](
	[PropertyBigStringId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[Row] [int] NULL,
	[Value] [varchar](max) NOT NULL,
	[PropertyName] [varchar](256) NOT NULL,
	[Comment] [varchar](256) NULL,
	[SourceObjectId] [int] NULL,
 CONSTRAINT [PK_PropertyBigString] PRIMARY KEY CLUSTERED 
(
	[PropertyBigStringId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroPropertyBigString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroPropertyBigString]
as
-- SELECT * FROM [vro].[vroPropertyBigString]
-- UPDATE [vro].[vroPropertyBigString] SET PropertyBigStringId=PropertyBigStringId+1 WHERE PropertyBigStringId=1
SELECT * FROM dbo.PropertyBigString 
UNION ALL SELECT TOP 0 * FROM dbo.PropertyBigString WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[PropertyFloat]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyFloat](
	[PropertyFloatId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[Row] [int] NULL,
	[Value] [float] NOT NULL,
	[ValueEpsilon] [float] NULL,
	[PropertyName] [varchar](256) NOT NULL,
	[Comment] [varchar](256) NULL,
	[SourceObjectId] [int] NULL,
 CONSTRAINT [PK_PropertyFloat] PRIMARY KEY CLUSTERED 
(
	[PropertyFloatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroPropertyFloat]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [vro].[vroPropertyFloat]
as
-- SELECT * FROM [vro].[vroPropertyFloat]
-- UPDATE [vro].[vroPropertyFloat] SET PropertyFloatId=PropertyFloatId+1 WHERE PropertyFloatId=1
SELECT * FROM dbo.PropertyFloat 
UNION ALL SELECT TOP 0 * FROM dbo.PropertyFloat WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[PropertyInt]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyInt](
	[PropertyIntId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[Row] [int] NULL,
	[Value] [bigint] NOT NULL,
	[PropertyName] [varchar](256) NOT NULL,
	[Comment] [varchar](256) NULL,
	[SourceObjectId] [int] NULL,
 CONSTRAINT [PK_PropertyInt] PRIMARY KEY CLUSTERED 
(
	[PropertyIntId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroPropertyInt]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [vro].[vroPropertyInt]
as
-- SELECT * FROM [vro].[vroPropertyInt]
-- UPDATE [vro].[vroPropertyInt] SET PropertyIntId=PropertyIntId+1 WHERE PropertyIntId=1
SELECT * FROM dbo.PropertyInt 
UNION ALL SELECT TOP 0 * FROM dbo.PropertyInt WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [dbo].[vHandover]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vHandover]
AS
SELECT        OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, 
                         OI.ObjectFileHash, OI.ObjectDescription, T.HandoverId, T.SampleObjectId, T.DestinationUserId, T.DestinationConfirmed, T.DestinationComments, T.Json, T.Amount, T.MeasurementUnit
FROM            dbo.ObjectInfo AS OI INNER JOIN
                         dbo.Handover AS T ON T.HandoverId = OI.ObjectId
GO
/****** Object:  Table [dbo].[PropertyString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyString](
	[PropertyStringId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[Row] [int] NULL,
	[Value] [varchar](4096) NOT NULL,
	[PropertyName] [varchar](256) NOT NULL,
	[Comment] [varchar](256) NULL,
	[SourceObjectId] [int] NULL,
 CONSTRAINT [PK_PropertyString] PRIMARY KEY CLUSTERED 
(
	[PropertyStringId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroPropertyString]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [vro].[vroPropertyString]
as
-- SELECT * FROM [vro].[vroPropertyString]
-- UPDATE [vro].[vroPropertyString] SET PropertyStringId=PropertyStringId+1 WHERE PropertyStringId=1
SELECT * FROM dbo.PropertyString 
UNION ALL SELECT TOP 0 * FROM dbo.PropertyString WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[Reference]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reference](
	[ReferenceId] [int] NOT NULL,
	[Authors] [varchar](512) NOT NULL,
	[Title] [varchar](1024) NOT NULL,
	[Journal] [varchar](256) NULL,
	[Year] [int] NOT NULL,
	[Volume] [varchar](32) NULL,
	[Number] [varchar](32) NULL,
	[StartPage] [varchar](32) NULL,
	[EndPage] [varchar](32) NULL,
	[DOI] [varchar](256) NULL,
	[URL] [varchar](256) NULL,
	[BibTeX] [varchar](4096) NULL,
 CONSTRAINT [PK_Reference] PRIMARY KEY CLUSTERED 
(
	[ReferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroReference]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroReference]
as
-- SELECT * FROM [vro].[vroReference]
-- UPDATE [vro].[vroReference] SET ReferenceId=ReferenceId+1 WHERE ReferenceId=1
SELECT * FROM dbo.Reference 
UNION ALL SELECT TOP 0 * FROM dbo.Reference WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[RubricInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RubricInfo](
	[RubricId] [int] NOT NULL,
	[TenantId] [int] NOT NULL,
	[_created] [datetime] NOT NULL,
	[_createdBy] [int] NOT NULL,
	[_updated] [datetime] NOT NULL,
	[_updatedBy] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[ParentId] [int] NULL,
	[Level] [int] NOT NULL,
	[LeafFlag] [int] NOT NULL,
	[Flags] [int] NOT NULL,
	[SortCode] [int] NOT NULL,
	[AccessControl] [int] NOT NULL,
	[IsPublished] [bit] NOT NULL,
	[RubricName] [varchar](256) NOT NULL,
	[RubricNameUrl] [varchar](256) NOT NULL,
	[RubricPath] [varchar](256) NOT NULL,
 CONSTRAINT [PK_RubricInfo] PRIMARY KEY CLUSTERED 
(
	[RubricId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroRubricInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroRubricInfo]
as
-- SELECT * FROM [vro].[vroRubricInfo]
-- UPDATE [vro].[vroRubricInfo] SET RubricId=RubricId+1 WHERE RubricId=1
SELECT * FROM dbo.RubricInfo 
UNION ALL SELECT TOP 0 * FROM dbo.RubricInfo WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[RubricInfoAdds]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RubricInfoAdds](
	[RubricId] [int] NOT NULL,
	[RubricText] [varchar](max) NOT NULL,
 CONSTRAINT [PK_RubricInfoAdds] PRIMARY KEY CLUSTERED 
(
	[RubricId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [vro].[vroRubricInfoAdds]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroRubricInfoAdds]
as
-- SELECT * FROM [vro].[vroRubricInfoAdds]
-- UPDATE [vro].[vroRubricInfoAdds] SET RubricId=RubricId+1 WHERE RubricId=1
SELECT * FROM dbo.RubricInfoAdds 
UNION ALL SELECT TOP 0 * FROM dbo.RubricInfoAdds WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[Sample]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sample](
	[SampleId] [int] NOT NULL,
	[ElemNumber] [int] NOT NULL,
	[Elements] [varchar](256) NOT NULL,
 CONSTRAINT [PK_SampleInfo] PRIMARY KEY CLUSTERED 
(
	[SampleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroSample]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroSample]
as
-- SELECT * FROM [vro].[vroSample]
-- UPDATE [vro].[vroSample] SET SampleId=SampleId+1 WHERE SampleId=1
SELECT * FROM dbo.[Sample] 
UNION ALL SELECT TOP 0 * FROM dbo.[Sample] WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[Tenant]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tenant](
	[TenantId] [int] NOT NULL,
	[_date] [datetime] NOT NULL,
	[Language] [varchar](32) NULL,
	[TenantUrl] [varchar](32) NOT NULL,
	[TenantName] [varchar](128) NOT NULL,
	[AccessControl] [int] NOT NULL,
 CONSTRAINT [PK_Tenant] PRIMARY KEY CLUSTERED 
(
	[TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroTenant]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroTenant]
as
-- SELECT * FROM [vro].[vroTenant]
-- UPDATE [vro].[vroTenant] SET TenantId=TenantId+1 WHERE TenantId=1
SELECT * FROM dbo.Tenant
UNION ALL SELECT TOP 0 * FROM dbo.Tenant WHERE 1=0		-- to make view read-only
GO
/****** Object:  Table [dbo].[TypeInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeInfo](
	[TypeId] [int] NOT NULL,
	[IsHierarchical] [bit] NOT NULL,
	[TypeIdForRubric] [int] NULL,
	[TypeName] [varchar](64) NOT NULL,
	[TableName] [varchar](64) NOT NULL,
	[UrlPrefix] [varchar](64) NOT NULL,
	[TypeComment] [varchar](256) NULL,
	[ValidationSchema] [varchar](256) NULL,
	[DataSchema] [varchar](256) NULL,
	[SettingsJson] [varchar](8000) NULL,
	[FileRequired] [bit] NOT NULL,
	[_date] [datetime] NOT NULL,
 CONSTRAINT [PK_TypeInfo] PRIMARY KEY CLUSTERED 
(
	[TypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [vro].[vroTypeInfo]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vroTypeInfo]
as
-- SELECT * FROM [vro].[vroTypeInfo]
-- UPDATE [vro].[vroTypeInfo] SET TypeId=TypeId+1 WHERE TypeId=1
SELECT * FROM dbo.TypeInfo
UNION ALL SELECT TOP 0 * FROM dbo.TypeInfo WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [dbo].[vComposition]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vComposition]
AS
SELECT        OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, 
                         OI.ObjectFileHash, OI.ObjectDescription, T.SampleId, T.ElemNumber, T.Elements, C.CompositionId, C.CompoundIndex, C.ElementName, C.ValueAbsolute, C.ValuePercent
FROM            dbo.ObjectInfo AS OI INNER JOIN
                         dbo.Sample AS T ON T.SampleId = OI.ObjectId INNER JOIN
                         dbo.Composition AS C ON C.SampleId = T.SampleId
GO
/****** Object:  View [vro].[vrovComposition]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vrovComposition]
as
-- SELECT * FROM [vro].[vrovComposition]
-- UPDATE [vro].[vrovComposition] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.vComposition 
UNION ALL SELECT TOP 0 * FROM dbo.vComposition WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [vro].[vrovHandover]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vrovHandover]
as
-- SELECT * FROM [vro].[vrovHandover]
-- UPDATE [vro].[vrovHandover] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.vHandover 
UNION ALL SELECT TOP 0 * FROM dbo.vHandover WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [dbo].[vObjectLinkObject]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vObjectLinkObject]
AS
SELECT        OLO.ObjectLinkObjectId, OLO.ObjectId, OLO.LinkedObjectId, OLO.SortCode, OLO._created, OLO._createdBy, OLO._updated, OLO._updatedBy, OLO.LinkTypeObjectId, Parent.ObjectId AS ParentObjectId, 
                         Parent.TenantId AS ParentTenantId, Parent._created AS Parent_created, Parent._createdBy AS Parent_createdBy, Parent._updated AS Parent_updated, Parent._updatedBy AS Parent_updatedBy, Parent.TypeId AS ParentTypeId, 
                         Parent.RubricId AS ParentRubricId, Parent.SortCode AS ParentSortCode, Parent.AccessControl AS ParentAccessControl, Parent.IsPublished AS ParentIsPublished, Parent.ExternalId AS ParentExternalId, 
                         Parent.ObjectName AS ParentObjectName, Parent.ObjectNameUrl AS ParentObjectNameUrl, Parent.ObjectFilePath AS ParentObjectFilePath, Parent.ObjectFileHash AS ParentObjectFileHash, 
                         Parent.ObjectDescription AS ParentObjectDescription, Child.ObjectId AS ChildObjectId, Child.TenantId AS ChildTenantId, Child._created AS Child_created, Child._createdBy AS Child_createdBy, Child._updated AS Child_updated, 
                         Child._updatedBy AS Child_updatedBy, Child.TypeId AS ChildTypeId, Child.RubricId AS ChildRubricId, Child.SortCode AS ChildSortCode, Child.AccessControl AS ChildAccessControl, Child.IsPublished AS ChildIsPublished, 
                         Child.ExternalId AS ChildExternalId, Child.ObjectName AS ChildObjectName, Child.ObjectNameUrl AS ChildObjectNameUrl, Child.ObjectFilePath AS ChildObjectFilePath, Child.ObjectFileHash AS ChildObjectFileHash, 
                         Child.ObjectDescription AS ChildObjectDescription
FROM            dbo.ObjectLinkObject AS OLO INNER JOIN
                         dbo.ObjectInfo AS Parent ON OLO.ObjectId = Parent.ObjectId INNER JOIN
                         dbo.ObjectInfo AS Child ON OLO.LinkedObjectId = Child.ObjectId
GO
/****** Object:  View [vro].[vrovObjectLinkObject]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vrovObjectLinkObject]
as
-- SELECT * FROM [vro].[vrovObjectLinkObject]
-- UPDATE [vro].[vrovObjectLinkObject] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.vObjectLinkObject 
UNION ALL SELECT TOP 0 * FROM dbo.vObjectLinkObject WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [dbo].[vReference]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vReference]
AS
SELECT        OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, 
                         OI.ObjectFileHash, OI.ObjectDescription, T.ReferenceId, T.Authors, T.Title, T.Journal, T.Year, T.Volume, T.Number, T.StartPage, T.EndPage, T.DOI, T.URL, T.BibTeX
FROM            dbo.ObjectInfo AS OI INNER JOIN
                         dbo.Reference AS T ON T.ReferenceId = OI.ObjectId
GO
/****** Object:  View [vro].[vrovReference]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vrovReference]
as
-- SELECT * FROM [vro].[vrovReference]
-- UPDATE [vro].[vrovReference] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.vReference 
UNION ALL SELECT TOP 0 * FROM dbo.vReference WHERE 1=0		-- to make view read-only
GO
/****** Object:  View [dbo].[vSample]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSample]
AS
SELECT        OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, 
                         OI.ObjectFileHash, OI.ObjectDescription, T.SampleId, T.ElemNumber, T.Elements
FROM            dbo.ObjectInfo AS OI INNER JOIN
                         dbo.Sample AS T ON T.SampleId = OI.ObjectId
GO
/****** Object:  View [vro].[vrovSample]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [vro].[vrovSample]
as
-- SELECT * FROM [vro].[vrovSample]
-- UPDATE [vro].[vrovSample] SET Id=Id+1 WHERE Id=1
SELECT * FROM dbo.vSample 
UNION ALL SELECT TOP 0 * FROM dbo.vSample WHERE 1=0		-- to make view read-only
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetRubricPath]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetRubricPath]
(	
@TenantId int, 
@RubricId int
)
RETURNS TABLE
AS
-- SELECT * FROM [dbo].[fn_GetRubricPath](1, 14)
RETURN 
(
	WITH CTE(RubricId, _createdBy, TypeId, ParentID, bLev, [Level], LeafFlag, Flags, SortCode, AccessControl, IsPublished, RubricName, RubricNameUrl, RubricPath) AS
	(
		SELECT RubricId, _createdBy, TypeId, ParentID, 0 as bLev, [Level], LeafFlag, Flags, SortCode, AccessControl, IsPublished, RubricName, RubricNameUrl, RubricPath
		FROM dbo.RubricInfo WITH (NOLOCK)
		WHERE TenantId=@TenantId AND RubricId=@RubricId
		UNION ALL
		SELECT R.RubricId, R._createdBy, R.TypeId, R.ParentID, T.bLev+1, R.[Level], R.LeafFlag, R.Flags, R.SortCode, R.AccessControl, R.IsPublished, R.RubricName, R.RubricNameUrl, R.RubricPath
		FROM dbo.RubricInfo as R
			INNER JOIN CTE As T ON T.ParentId=R.RubricId
	)
	SELECT * FROM CTE --ORDER BY [Level]
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetObjectNonTableProperties]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetObjectNonTableProperties]
(	
@ObjectId int
)
RETURNS TABLE
AS
-- SELECT * FROM [dbo].[fn_GetObjectNonTableProperties](9006) ORDER BY SortCode, PropertyName
RETURN 
(
	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyFloat WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyIntId as PropertyId, 'Int' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyInt WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyStringId as PropertyId, 'String' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyString WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyBigStringId as PropertyId, 'BigString' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyBigString WHERE [Row] IS NULL AND ObjectId=@ObjectId
	--ORDER BY SortCode, PropertyName
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetObjectTableProperties]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetObjectTableProperties]
(	
@ObjectId int
)
RETURNS TABLE
AS
-- SELECT * FROM [dbo].[fn_GetObjectTableProperties](9006) ORDER BY Row, SortCode, PropertyName
RETURN 
(
	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment
	FROM dbo.PropertyFloat WHERE [Row]>0 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyIntId as PropertyId, 'Int' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment
	FROM dbo.PropertyInt WHERE [Row]>0 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyStringId as PropertyId, 'String' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment
	FROM dbo.PropertyString WHERE [Row]>0 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyBigStringId as PropertyId, 'BigString' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Value], NULL as ValueEpsilon, PropertyName, Comment
	FROM dbo.PropertyBigString WHERE [Row]>0 AND ObjectId=@ObjectId
	--ORDER BY SortCode, PropertyName
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetObjectProperties]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetObjectProperties]
(	
@ObjectId int
)
RETURNS TABLE
AS
-- SELECT * FROM [dbo].[fn_GetObjectProperties](9006) ORDER BY Row, SortCode, PropertyName
RETURN 
(
	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyIntId as PropertyId, 'Int' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyInt WHERE ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyStringId as PropertyId, 'String' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyString WHERE ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyBigStringId as PropertyId, 'BigString' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId
	--ORDER BY SortCode, PropertyName
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetParentObjects]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetParentObjects]
(	
@TenantId int,	-- current TenantId (to avoid extra join on @ObjectId)
@ObjectId int,	-- current object
@TypeId int		-- Type filter: >0 - filter by ==@TypeId; otherwise - no filter; 
)
RETURNS TABLE	-- ObjectInfo structure with PARENT objects (relative to current @ObjectId)
AS
-- SELECT * FROM [dbo].[fn_GetParentObjects](7, 55563, null)
-- SELECT * FROM [dbo].[fn_GetParentObjects](7, 55563, 6)
-- SELECT * FROM [dbo].[fn_GetParentObjects](7, 55563, 5)
RETURN 
(
	select OI.* from dbo.ObjectLinkObject as OLO 
		INNER JOIN dbo.ObjectInfo as OI ON OLO.ObjectId=OI.ObjectId AND OI.TenantId=@TenantId
	WHERE OLO.LinkedObjectId=@ObjectId AND OI.TypeId=IIF(@TypeId>0, @TypeId, OI.TypeId)
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetChildObjects]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_GetChildObjects]
(	
@TenantId int,	-- current TenantId (to avoid extra join on @ObjectId)
@ObjectId int,	-- current object
@TypeId int		-- Type filter: >0 - filter by ==@TypeId; otherwise - no filter; 
)
RETURNS TABLE	-- ObjectInfo structure with CHILD objects (relative to current @ObjectId)
AS
-- SELECT * FROM [dbo].[fn_GetChildObjects](7, 55562, null)
-- SELECT * FROM [dbo].[fn_GetChildObjects](7, 55562, 6)
-- SELECT * FROM [dbo].[fn_GetChildObjects](7, 55562, 5)
RETURN 
(
	select OI.* from dbo.ObjectLinkObject as OLO 
		INNER JOIN dbo.ObjectInfo as OI ON OLO.LinkedObjectId=OI.ObjectId AND OI.TenantId=@TenantId
	WHERE OLO.ObjectId=@ObjectId AND OI.TypeId=IIF(@TypeId>0, @TypeId, OI.TypeId)
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CompactSamples]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_CompactSamples] (
@TenantId int
)
RETURNS TABLE	-- (OBJECT_ID int)
-- SELECT * FROM dbo.fn_CompactSamples(7) Order by Created	-- MDI
AS
RETURN 
(
	select ObjectId as ProjectId, ExternalId, 
		(select TOP 1 ObjectId from [dbo].[fn_GetParentObjects](@TenantId, /**/s.ObjectId, /*TypeId*/6)) as ParentProjectId,
	s.AccessControl, IIF(AccessControl>1, 1, 0) as [WCAccessControl],
	_created as [Created],
	ElemNumber,
	
	(select TOP 1 ObjectId from [dbo].[fn_GetChildObjects](@TenantId, /**/s.ObjectId, /*TypeId*/5)) as [SubstrateId],
	
	(select count(ObjectId) from [dbo].[fn_GetChildObjects](@TenantId, /**/s.ObjectId, /*TypeId*/18)) as [DepositionCount],
	(select count(ObjectId) from [dbo].[fn_GetChildObjects](@TenantId, /**/s.ObjectId, /*TypeId*/null) WHERE TypeId NOT IN (5,6,18)) as [CharacterizationCount],
	
	(select TOP 1 dbo.fn_GetChamberFromString(ObjectName) from [dbo].[fn_GetChildObjects](@TenantId, /**/s.ObjectId, /*TypeId*/18)) as [Chamber],
	_createdBy,
	dbo.fn_GetUserName(_createdBy) as [CreatedByPerson],	-- varchar(32)
	ObjectName as [ProjectName],
	SUBSTRING([Elements], 2, LEN([Elements])-2) as SampleMaterial,
	[Elements],
	
	(select TOP 1 ObjectName from [dbo].[fn_GetChildObjects](@TenantId, /**/s.ObjectId, /*TypeId*/5)) as [SubstrateMaterial],
	
	CAST(ISNULL(ExternalId, ObjectId) as varchar(20)) as [CN_PROJEKT_ID]
	from dbo.vSample as s WHERE TenantId=@TenantId and TypeId=6
)
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetRoleClaims_RoleId]    Script Date: 16/10/2024 18:34:36 ******/
CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [RoleNameIndex]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[NormalizedName] ASC
)
WHERE ([NormalizedName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserClaims_UserId]    Script Date: 16/10/2024 18:34:36 ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserLogins_UserId]    Script Date: 16/10/2024 18:34:36 ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserRoles_RoleId]    Script Date: 16/10/2024 18:34:36 ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [EmailIndex]    Script Date: 16/10/2024 18:34:36 ******/
CREATE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UserNameIndex]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedUserName] ASC
)
WHERE ([NormalizedUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-Composition-SampleId_ElementName]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-Composition-SampleId_ElementName] ON [dbo].[Composition]
(
	[SampleId] ASC,
	[ElementName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Elements_Element]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Elements_Element] ON [dbo].[ElementInfo]
(
	[ElementName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-ObjectInfo_Tenant-FileHash]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-ObjectInfo_Tenant-FileHash] ON [dbo].[ObjectInfo]
(
	[TenantId] ASC,
	[ObjectFileHash] ASC
)
WHERE ([ObjectFileHash] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-ObjectInfo_Tenant-Type-ObjectName]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-ObjectInfo_Tenant-Type-ObjectName] ON [dbo].[ObjectInfo]
(
	[TenantId] ASC,
	[TypeId] ASC,
	[ObjectName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-ObjectInfo_Tenant-Url]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-ObjectInfo_Tenant-Url] ON [dbo].[ObjectInfo]
(
	[TenantId] ASC,
	[ObjectNameUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UIX_ObjectLinkObject]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ObjectLinkObject] ON [dbo].[ObjectLinkObject]
(
	[ObjectId] ASC,
	[LinkedObjectId] ASC,
	[LinkTypeObjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UIX_ObjectLinkRubric]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ObjectLinkRubric] ON [dbo].[ObjectLinkRubric]
(
	[ObjectId] ASC,
	[RubricId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-PropertyBigString]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-PropertyBigString] ON [dbo].[PropertyBigString]
(
	[ObjectId] ASC,
	[Row] ASC,
	[PropertyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-PropertyFloat]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-PropertyFloat] ON [dbo].[PropertyFloat]
(
	[ObjectId] ASC,
	[Row] ASC,
	[PropertyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-PropertyInt]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-PropertyInt] ON [dbo].[PropertyInt]
(
	[ObjectId] ASC,
	[Row] ASC,
	[PropertyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-PropertyString]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-PropertyString] ON [dbo].[PropertyString]
(
	[ObjectId] ASC,
	[Row] ASC,
	[PropertyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX-RubricInfo_Tenant-Url]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX-RubricInfo_Tenant-Url] ON [dbo].[RubricInfo]
(
	[TenantId] ASC,
	[RubricNameUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UIX_TypeInfo-TypeName]    Script Date: 16/10/2024 18:34:36 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UIX_TypeInfo-TypeName] ON [dbo].[TypeInfo]
(
	[TypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObjectInfo] ADD  CONSTRAINT [DF_ObjectInfo__created]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[ObjectInfo] ADD  CONSTRAINT [DF_ObjectInfo_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[ObjectInfo] ADD  CONSTRAINT [DF_ObjectInfo_AccessControl]  DEFAULT ((0)) FOR [AccessControl]
GO
ALTER TABLE [dbo].[ObjectInfo] ADD  CONSTRAINT [DF_ObjectInfo_IsPublished]  DEFAULT ((1)) FOR [IsPublished]
GO
ALTER TABLE [dbo].[ObjectLinkObject] ADD  CONSTRAINT [DF_ObjectLinkObject_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[ObjectLinkRubric] ADD  CONSTRAINT [DF_ObjectLinkRubric_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[PropertyBigString] ADD  CONSTRAINT [DF_PropertyBigString_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[PropertyBigString] ADD  CONSTRAINT [DF_PropertyBigString__created]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[PropertyBigString] ADD  CONSTRAINT [DF_PropertyBigString__updated]  DEFAULT (getdate()) FOR [_updated]
GO
ALTER TABLE [dbo].[PropertyFloat] ADD  CONSTRAINT [DF_PropertyFloat_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[PropertyFloat] ADD  CONSTRAINT [DF_PropertyFloat__created]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[PropertyFloat] ADD  CONSTRAINT [DF_PropertyFloat__updated]  DEFAULT (getdate()) FOR [_updated]
GO
ALTER TABLE [dbo].[PropertyInt] ADD  CONSTRAINT [DF_PropertyInt_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[PropertyInt] ADD  CONSTRAINT [DF_PropertyInt__created]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[PropertyInt] ADD  CONSTRAINT [DF_PropertyInt__updated]  DEFAULT (getdate()) FOR [_updated]
GO
ALTER TABLE [dbo].[PropertyString] ADD  CONSTRAINT [DF_PropertyString_SortCode]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[PropertyString] ADD  CONSTRAINT [DF_PropertyString__created]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[PropertyString] ADD  CONSTRAINT [DF_PropertyString__updated]  DEFAULT (getdate()) FOR [_updated]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Year]  DEFAULT ((0)) FOR [Year]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF_RubricInfo_TenantId]  DEFAULT ((1)) FOR [TenantId]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF__RubricInf___crea__2A164134]  DEFAULT (getdate()) FOR [_created]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF_RubricInfo__createdBy]  DEFAULT ((1)) FOR [_createdBy]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF__RubricInf___upda__2B0A656D]  DEFAULT (getdate()) FOR [_updated]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF_RubricInfo__updatedBy]  DEFAULT ((1)) FOR [_updatedBy]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF_RubricInfo_LeafFlag]  DEFAULT ((0)) FOR [LeafFlag]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF__RubricInf__Flags__29221CFB]  DEFAULT ((0)) FOR [Flags]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF__RubricInf__SortT__2BFE89A6]  DEFAULT ((0)) FOR [SortCode]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF_RubricInfo_AccessControl]  DEFAULT ((0)) FOR [AccessControl]
GO
ALTER TABLE [dbo].[RubricInfo] ADD  CONSTRAINT [DF__RubricInf__IsPub__282DF8C2]  DEFAULT ((1)) FOR [IsPublished]
GO
ALTER TABLE [dbo].[Tenant] ADD  CONSTRAINT [DF_Tenant__date]  DEFAULT (getdate()) FOR [_date]
GO
ALTER TABLE [dbo].[Tenant] ADD  CONSTRAINT [DF_Tenant_AccessControl]  DEFAULT ((0)) FOR [AccessControl]
GO
ALTER TABLE [dbo].[TypeInfo] ADD  CONSTRAINT [DF__TypeInfo__IsHier__2CF2ADDF]  DEFAULT ((0)) FOR [IsHierarchical]
GO
ALTER TABLE [dbo].[TypeInfo] ADD  CONSTRAINT [DF_TypeInfo_FileRequired]  DEFAULT ((0)) FOR [FileRequired]
GO
ALTER TABLE [dbo].[TypeInfo] ADD  CONSTRAINT [DF_TypeInfo__date]  DEFAULT (getdate()) FOR [_date]
GO
ALTER TABLE [dbo].[AspNetRoleClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetRoleClaims] CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserTokens] CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[Composition]  WITH CHECK ADD  CONSTRAINT [FK_SampleComposition_Elements] FOREIGN KEY([ElementName])
REFERENCES [dbo].[ElementInfo] ([ElementName])
GO
ALTER TABLE [dbo].[Composition] CHECK CONSTRAINT [FK_SampleComposition_Elements]
GO
ALTER TABLE [dbo].[Composition]  WITH CHECK ADD  CONSTRAINT [FK_SampleComposition_SampleInfo] FOREIGN KEY([SampleId])
REFERENCES [dbo].[Sample] ([SampleId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Composition] CHECK CONSTRAINT [FK_SampleComposition_SampleInfo]
GO
ALTER TABLE [dbo].[Handover]  WITH CHECK ADD  CONSTRAINT [FK_Handover_AspNetUsers] FOREIGN KEY([DestinationUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Handover] CHECK CONSTRAINT [FK_Handover_AspNetUsers]
GO
ALTER TABLE [dbo].[Handover]  WITH CHECK ADD  CONSTRAINT [FK_Handover_ObjectInfo] FOREIGN KEY([HandoverId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[Handover] CHECK CONSTRAINT [FK_Handover_ObjectInfo]
GO
ALTER TABLE [dbo].[Handover]  WITH CHECK ADD  CONSTRAINT [FK_Handover_ObjectInfo_Sample] FOREIGN KEY([SampleObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Handover] CHECK CONSTRAINT [FK_Handover_ObjectInfo_Sample]
GO
ALTER TABLE [dbo].[ObjectInfo]  WITH CHECK ADD  CONSTRAINT [FK_ObjectInfo_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectInfo] CHECK CONSTRAINT [FK_ObjectInfo_AspNetUsers]
GO
ALTER TABLE [dbo].[ObjectInfo]  WITH CHECK ADD  CONSTRAINT [FK_ObjectInfo_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectInfo] CHECK CONSTRAINT [FK_ObjectInfo_AspNetUsers1]
GO
ALTER TABLE [dbo].[ObjectInfo]  WITH CHECK ADD  CONSTRAINT [FK_ObjectInfo_RubricInfo] FOREIGN KEY([RubricId])
REFERENCES [dbo].[RubricInfo] ([RubricId])
GO
ALTER TABLE [dbo].[ObjectInfo] CHECK CONSTRAINT [FK_ObjectInfo_RubricInfo]
GO
ALTER TABLE [dbo].[ObjectInfo]  WITH CHECK ADD  CONSTRAINT [FK_ObjectInfo_Tenant] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Tenant] ([TenantId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ObjectInfo] CHECK CONSTRAINT [FK_ObjectInfo_Tenant]
GO
ALTER TABLE [dbo].[ObjectInfo]  WITH CHECK ADD  CONSTRAINT [FK_ObjectInfo_TypeInfo] FOREIGN KEY([TypeId])
REFERENCES [dbo].[TypeInfo] ([TypeId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ObjectInfo] CHECK CONSTRAINT [FK_ObjectInfo_TypeInfo]
GO
ALTER TABLE [dbo].[ObjectLinkObject]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkObject_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectLinkObject] CHECK CONSTRAINT [FK_ObjectLinkObject_AspNetUsers]
GO
ALTER TABLE [dbo].[ObjectLinkObject]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkObject_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectLinkObject] CHECK CONSTRAINT [FK_ObjectLinkObject_AspNetUsers1]
GO
ALTER TABLE [dbo].[ObjectLinkObject]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkObject_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[ObjectLinkObject] CHECK CONSTRAINT [FK_ObjectLinkObject_ObjectInfo]
GO
ALTER TABLE [dbo].[ObjectLinkObject]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkObject_ObjectInfo_LinkTypeObjectId] FOREIGN KEY([LinkTypeObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[ObjectLinkObject] CHECK CONSTRAINT [FK_ObjectLinkObject_ObjectInfo_LinkTypeObjectId]
GO
ALTER TABLE [dbo].[ObjectLinkObject]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkObject_ObjectInfo2] FOREIGN KEY([LinkedObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ObjectLinkObject] CHECK CONSTRAINT [FK_ObjectLinkObject_ObjectInfo2]
GO
ALTER TABLE [dbo].[ObjectLinkRubric]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkRubric_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectLinkRubric] CHECK CONSTRAINT [FK_ObjectLinkRubric_AspNetUsers]
GO
ALTER TABLE [dbo].[ObjectLinkRubric]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkRubric_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ObjectLinkRubric] CHECK CONSTRAINT [FK_ObjectLinkRubric_AspNetUsers1]
GO
ALTER TABLE [dbo].[ObjectLinkRubric]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkRubric_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[ObjectLinkRubric] CHECK CONSTRAINT [FK_ObjectLinkRubric_ObjectInfo]
GO
ALTER TABLE [dbo].[ObjectLinkRubric]  WITH CHECK ADD  CONSTRAINT [FK_ObjectLinkRubric_RubricInfo] FOREIGN KEY([RubricId])
REFERENCES [dbo].[RubricInfo] ([RubricId])
GO
ALTER TABLE [dbo].[ObjectLinkRubric] CHECK CONSTRAINT [FK_ObjectLinkRubric_RubricInfo]
GO
ALTER TABLE [dbo].[PropertyBigString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBigString_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyBigString] CHECK CONSTRAINT [FK_PropertyBigString_AspNetUsers]
GO
ALTER TABLE [dbo].[PropertyBigString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBigString_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyBigString] CHECK CONSTRAINT [FK_PropertyBigString_AspNetUsers1]
GO
ALTER TABLE [dbo].[PropertyBigString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBigString_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[PropertyBigString] CHECK CONSTRAINT [FK_PropertyBigString_ObjectInfo]
GO
ALTER TABLE [dbo].[PropertyBigString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyBigString_ObjectInfo2] FOREIGN KEY([SourceObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PropertyBigString] CHECK CONSTRAINT [FK_PropertyBigString_ObjectInfo2]
GO
ALTER TABLE [dbo].[PropertyFloat]  WITH CHECK ADD  CONSTRAINT [FK_PropertyFloat_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyFloat] CHECK CONSTRAINT [FK_PropertyFloat_AspNetUsers]
GO
ALTER TABLE [dbo].[PropertyFloat]  WITH CHECK ADD  CONSTRAINT [FK_PropertyFloat_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyFloat] CHECK CONSTRAINT [FK_PropertyFloat_AspNetUsers1]
GO
ALTER TABLE [dbo].[PropertyFloat]  WITH CHECK ADD  CONSTRAINT [FK_PropertyFloat_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[PropertyFloat] CHECK CONSTRAINT [FK_PropertyFloat_ObjectInfo]
GO
ALTER TABLE [dbo].[PropertyFloat]  WITH CHECK ADD  CONSTRAINT [FK_PropertyFloat_ObjectInfo2] FOREIGN KEY([SourceObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PropertyFloat] CHECK CONSTRAINT [FK_PropertyFloat_ObjectInfo2]
GO
ALTER TABLE [dbo].[PropertyInt]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInt_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyInt] CHECK CONSTRAINT [FK_PropertyInt_AspNetUsers]
GO
ALTER TABLE [dbo].[PropertyInt]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInt_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyInt] CHECK CONSTRAINT [FK_PropertyInt_AspNetUsers1]
GO
ALTER TABLE [dbo].[PropertyInt]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInt_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[PropertyInt] CHECK CONSTRAINT [FK_PropertyInt_ObjectInfo]
GO
ALTER TABLE [dbo].[PropertyInt]  WITH CHECK ADD  CONSTRAINT [FK_PropertyInt_ObjectInfo2] FOREIGN KEY([SourceObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PropertyInt] CHECK CONSTRAINT [FK_PropertyInt_ObjectInfo2]
GO
ALTER TABLE [dbo].[PropertyString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyString_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyString] CHECK CONSTRAINT [FK_PropertyString_AspNetUsers]
GO
ALTER TABLE [dbo].[PropertyString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyString_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PropertyString] CHECK CONSTRAINT [FK_PropertyString_AspNetUsers1]
GO
ALTER TABLE [dbo].[PropertyString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyString_ObjectInfo] FOREIGN KEY([ObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
GO
ALTER TABLE [dbo].[PropertyString] CHECK CONSTRAINT [FK_PropertyString_ObjectInfo]
GO
ALTER TABLE [dbo].[PropertyString]  WITH CHECK ADD  CONSTRAINT [FK_PropertyString_ObjectInfo2] FOREIGN KEY([SourceObjectId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PropertyString] CHECK CONSTRAINT [FK_PropertyString_ObjectInfo2]
GO
ALTER TABLE [dbo].[Reference]  WITH CHECK ADD  CONSTRAINT [FK_Reference_ObjectInfo] FOREIGN KEY([ReferenceId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Reference] CHECK CONSTRAINT [FK_Reference_ObjectInfo]
GO
ALTER TABLE [dbo].[RubricInfo]  WITH CHECK ADD  CONSTRAINT [FK_RubricInfo_AspNetUsers] FOREIGN KEY([_createdBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[RubricInfo] CHECK CONSTRAINT [FK_RubricInfo_AspNetUsers]
GO
ALTER TABLE [dbo].[RubricInfo]  WITH CHECK ADD  CONSTRAINT [FK_RubricInfo_AspNetUsers1] FOREIGN KEY([_updatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[RubricInfo] CHECK CONSTRAINT [FK_RubricInfo_AspNetUsers1]
GO
ALTER TABLE [dbo].[RubricInfo]  WITH NOCHECK ADD  CONSTRAINT [FK_RubricInfo_RubricInfo] FOREIGN KEY([ParentId])
REFERENCES [dbo].[RubricInfo] ([RubricId])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[RubricInfo] CHECK CONSTRAINT [FK_RubricInfo_RubricInfo]
GO
ALTER TABLE [dbo].[RubricInfo]  WITH CHECK ADD  CONSTRAINT [FK_RubricInfo_Tenant] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Tenant] ([TenantId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RubricInfo] CHECK CONSTRAINT [FK_RubricInfo_Tenant]
GO
ALTER TABLE [dbo].[RubricInfo]  WITH CHECK ADD  CONSTRAINT [FK_RubricInfo_TypeInfo] FOREIGN KEY([TypeId])
REFERENCES [dbo].[TypeInfo] ([TypeId])
GO
ALTER TABLE [dbo].[RubricInfo] CHECK CONSTRAINT [FK_RubricInfo_TypeInfo]
GO
ALTER TABLE [dbo].[RubricInfoAdds]  WITH CHECK ADD  CONSTRAINT [FK_RubricInfoAdds_RubricInfo] FOREIGN KEY([RubricId])
REFERENCES [dbo].[RubricInfo] ([RubricId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RubricInfoAdds] CHECK CONSTRAINT [FK_RubricInfoAdds_RubricInfo]
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD  CONSTRAINT [FK_Sample_ObjectInfo] FOREIGN KEY([SampleId])
REFERENCES [dbo].[ObjectInfo] ([ObjectId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Sample] CHECK CONSTRAINT [FK_Sample_ObjectInfo]
GO
ALTER TABLE [dbo].[TypeInfo]  WITH CHECK ADD  CONSTRAINT [TypeInfo_SettingsJson] CHECK  ((isjson([SettingsJson])=(1)))
GO
ALTER TABLE [dbo].[TypeInfo] CHECK CONSTRAINT [TypeInfo_SettingsJson]
GO
/****** Object:  StoredProcedure [dbo].[_GetObjectIdOfTypeByName]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[_GetObjectIdOfTypeByName]
@TenantId int,
@TypeId int,			-- TypeId of Object to find
@TypeName varchar(64),	-- used only if @TypeId is not set (NULL OR less than 1)
@RubricId int,			-- RubricId (if new Object is created)
@ObjectName varchar(512)
AS
-- Get ObjectId by ObjectName (if no object with specified name found (case-insensitive), then create it)
-- DECLARE @ObjectId int; EXEC @ObjectId=[dbo].[_GetObjectIdOfTypeByName] 4, 0, 'Substrate', 154, 'Sapphire'; PRINT @ObjectId
IF @ObjectName='' OR @ObjectName IS NULL
	RETURN 0
DECLARE @ObjectId int
IF @TypeId IS NULL OR @TypeId<1
	SELECT @TypeId=TypeId FROM dbo.TypeInfo WHERE UPPER(TypeName)=UPPER(@TypeName)
SELECT TOP 1 @ObjectId=ObjectId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND UPPER(ObjectName)=UPPER(@ObjectName)
IF @ObjectId IS NULL	-- create
BEGIN
	DECLARE @_userId int = 1;	-- ADMIN
	DECLARE @_date datetime = getdate()	-- ADMIN
	EXEC [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_date, @_userId, @_date,	@_userId, @TypeId, @RubricId, 0/*SortCode*/,
	0/*AccessControl*/, 1/*IsPublished*/, null/*@ExternalId*/, @ObjectName, null/*@ObjectNameUrl*/, null/*ObjectFilePath*/,  null/*ObjectDescription*/, 1/*showResultsInRecordset*/ 
END
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[_GetRubricIdByRubricName]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[_GetRubricIdByRubricName]
@TenantId int,
@ParentId int,
@RubricName varchar(256)='',
@CreateRubric bit=1,
@TypeId int=2,
@UserId int=2,
@AccessControl int=0,
@IsPublished bit=1
AS
-- EXEC [dbo].[_GetRubricIdByRubricName] 1, 0, 'рубрика', 1, 2, 2, 0, 1 
-- DON'T frorget to call: EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId
IF @RubricName=''
	RETURN 0
DECLARE @RubricId int;
SELECT TOP 1 @RubricId=RubricId FROM dbo.RubricInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND RubricId>0 AND ISNULL(ParentId,0)=ISNULL(@ParentId,0) AND UPPER(RubricName)=UPPER(@RubricName)
--PRINT 'SELECT TOP 1 RubricId FROM dbo.RubricInfo WHERE TenantId=' + CAST(@TenantId as varchar(8)) + ' AND TypeId=' + CAST(@TypeId as varchar(8)) + ' AND RubricId>0 AND ISNULL(ParentId,0)=ISNULL(' + CAST(@ParentId as varchar(8)) + ',0) AND UPPER(RubricName)=UPPER(''' + @RubricName + ''')'
IF @RubricId IS NULL AND @CreateRubric=1	-- It's required to CREATE(!) rubric
BEGIN
	DECLARE @Level int
	DECLARE @RubricNameUrl varchar(8000)=''	-- varchar(256)=''
	-- calculate next @RubricId
	SET @RubricId = NULL
	SELECT @RubricId = MAX(RubricId) + 1 FROM dbo.RubricInfo
	IF @RubricId IS NULL
		SET @RubricId=1
	IF ISNULL(@ParentId, 0)=0	-- root rubric
	begin
 		SET @Level=0
	end
	ELSE -- try to find parent
	begin
		SELECT @Level=[Level], @RubricNameUrl=RubricNameUrl FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricId>0 AND TypeId=@TypeId AND RubricId=@ParentId
		IF @Level IS NULL	-- no parent rubric not found
			SET @RubricId = 0	-- error (throw?), no rubric creation
		ELSE
			SET @Level = @Level + 1
	end
	IF @RubricId>0
	begin
		IF @RubricNameUrl!=''
			SET @RubricNameUrl=@RubricNameUrl+'_'
		SET @RubricNameUrl = @RubricNameUrl + dbo.fn_Transliterate4URL(@RubricName)
		if	LEN(@RubricNameUrl)>256 -- need to shorten URL
			OR 
			EXISTS (select RubricId from dbo.RubricInfo WHERE TenantId=@TenantId AND RubricId>0 AND TypeId=@TypeId AND RubricNameUrl=@RubricNameUrl) -- RubricName is unique, but RubricNameUrl is not => add hash
		begin
			SET @RubricNameUrl = LEFT(@RubricNameUrl, 220) + '_' + CONVERT(VARCHAR(32),HashBytes('MD5', '@RubricNameUrl'),2)
		end
		INSERT INTO dbo.RubricInfo (RubricId, TenantId, _createdBy, _updatedBy, TypeId, ParentId, [Level], LeafFlag, Flags, SortCode, AccessControl, IsPublished, RubricName, RubricNameUrl, RubricPath)
		VALUES(@RubricId, @TenantId, @UserId, @UserId, @TypeId, NULLIF(@ParentId,0), @Level, /*@LeafFlag*/ 0, /*Flags*/ 0, /*SortCode*/ 0, @AccessControl, @IsPublished, @RubricName, @RubricNameUrl, '')

		DECLARE @RubricPath varchar(256) = LEFT(dbo.fn_GetRubricPathStringFull(@RubricId,'}'), 256)
		SET @RubricNameUrl = dbo.fn_GetRubricNameUrl_QuickByParent(@RubricId)
		UPDATE dbo.RubricInfo
			SET RubricPath=@RubricPath, RubricNameUrl=@RubricNameUrl
			WHERE TenantId=@TenantId AND RubricId=@RubricId
	end
END
--ELSE IF @CreateRubric=1	-- update date in rubric
--	UPDATE dbo.RubricInfo SET _updated = getdate() WHERE TenantId=@TenantId AND RubricId=@RubricId
RETURN @RubricId
GO
/****** Object:  StoredProcedure [dbo].[_GetRubricIdByRubricPath]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[_GetRubricIdByRubricPath]
@TenantId int,
@RubricPath varchar(8000)='',	-- Rubric_Level0}Rubric_Level1}...}Rubric_LevelN
@Separator varchar(16)='}',	-- separator between rubrics
@CreateRubric bit=1,		-- create rubrics by path (0 - no, 1 - yes)
@TypeId int=2,
@UserId int=2,
@AccessControl int=0,
@IsPublished bit=1
AS
-- DECLARE @Res int; EXEC @Res = [dbo].[_GetRubricIdByRubricPath] 4, 'Rubric_Level0}Rubric_Level1}Rubric_Level2}Rubric_Level3}Rubric_Level4', '}', 1, 2, 2, 0, 1; PRINT @Res;
-- DECLARE @Res int; EXEC @Res = [dbo].[_GetRubricIdByRubricPath] 4, 'Rubric_Level0}Rubric_Level1}Rubric_Level2', '}', 1, 2, 2, 0, 1; PRINT @Res;
-- DON'T frorget to call: EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId
-- EXEC [dbo].[ProcRubric_NormaliseTree] 4, 2
DECLARE @RubricId int, @ParentId int, @Level int, @i int, @RubricName varchar(255)
IF @RubricPath IS NULL OR @RubricPath=''
	RETURN 0
SET @Level = -1
SET @RubricId = 0
WHILE @RubricPath <> ''
begin
	SET @Level = @Level + 1
	SET @ParentId = @RubricId

	SET @i = CHARINDEX(@Separator, @RubricPath)
-- print '@i=' + CAST(@i as varchar(15))
	if @i > 0		-- нашли разделитель
	begin
		SET @RubricName = LEFT(@RubricPath, @i - 1)
		SET @RubricPath = RIGHT(@RubricPath, LEN(@RubricPath) - @i - LEN(@Separator) + 1)
	end
	else
	begin
		SET @RubricName = @RubricPath
		SET @RubricPath = ''
	end
-- print '@RubricPath = ' + @RubricPath + ', @ParentId=' + CAST(@ParentId as varchar(15)) + ', @RubricName=' + @RubricName
	EXECUTE @RubricId = [dbo].[_GetRubricIdByRubricName] @TenantId, @ParentId, @RubricName, @CreateRubric, @TypeId, @UserId, @AccessControl, @IsPublished
-- print '@RubricId = ' + CAST(@RubricId as varchar(15))
end
RETURN @RubricId
GO
/****** Object:  StoredProcedure [dbo].[Change_Created]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Change_Created]
@TenantId int=7,
@TypeId int=6	-- Sample
AS
--select ProjectId, Created, * from [EdgePLM COMPACT].dbo.Samples;
--select S.Created, OI.* from dbo.ObjectInfo as OI 
--INNER JOIN [EdgePLM COMPACT].dbo.Samples as S ON OI.ExternalId=S.ProjectId
--where OI.TenantId=7 and OI.TypeId=6 and OI.ExternalId>0
UPDATE 
    OI
SET 
    OI._created = S.Created
FROM 
    dbo.ObjectInfo as OI 
    INNER JOIN [EdgePLM COMPACT].dbo.Samples as S ON OI.ExternalId=S.ProjectId
where OI.TenantId=@TenantId and OI.TypeId=@TypeId and OI.ExternalId>0
GO
/****** Object:  StoredProcedure [dbo].[Change_ShiftObjectsToParent]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Change_ShiftObjectsToParent]
@TenantId int=7,
@TypeId int=6,	-- Sample
@UserId int=28	-- sabrina.baha@rub.de
AS
-- select * from dbo.AspNetUsers where Id=@UserId
-- UPDATE dbo.RubricInfo set _createdBy=@UserId WHERE TenantId=@TenantId and RubricId IN (select RubricId from ObjectInfo where TenantId=@TenantId AND _createdBy=@UserId)

select DISTINCT OI.RubricID, (select count(*) from ObjectInfo where RubricId=OI.RubricId) as ObjCount, RI.RubricPath 
--INTO dbo._Sabrina
from dbo.ObjectInfo as OI 
INNER JOIN RubricInfo as RI on OI.RubricId=RI.RubricId

WHERE oi.TenantId=@TenantId AND oi._createdBy=@UserId-- AND TypeId=@TypeId
	--AND oi.RubricId IN (select RubricId from RubricInfo WHERE RubricId NOT IN (select ParentId from RubricInfo))
ORDER BY RI.RubricPath

-- set RubricID to Parent Rubric for Objects
--UPDATE 
--    OI
--SET 
--    OI.RubricID = RI.ParentId
--FROM 
--    dbo.ObjectInfo as OI 
--    INNER JOIN RubricInfo as RI ON OI.RubricId=RI.RubricId
--where OI.TenantId=@TenantId AND OI.RubricId IN (select RubricId from dbo._Sabrina) --and OI.TypeId=@TypeId and OI.ExternalId>0
--GO

-- 
--delete from RubricInfo where RubricId IN (select RubricId from dbo._Sabrina where RubricId NOT IN (select RubricId from ObjectInfo))
-- select * from dbo._Sabrina where RubricId NOT IN (select RubricId from ObjectInfo)
GO
/****** Object:  StoredProcedure [dbo].[ChangeOwnerShip]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ChangeOwnerShip]
@TenantId int,
@CreatedByPerson varchar(32)
AS
-- EXEC [dbo].[ChangeOwnerShip] 7, 'Thelen Felix'
-- EXEC [dbo].[ChangeOwnerShip] 7, 'Fortmann Jill'
-- EXEC [dbo].[ChangeOwnerShip] 7, 'Thienhaus Sigurd'
-- EXEC [dbo].[ChangeOwnerShip] 7, 'Mockute Aurelija'
DECLARE @ObjectId int, @RubricId int
DECLARE @TypeId_Sample int = [dbo].[GetTypeIdForCompact]('Sample', 'Sample', null)	-- TypeId==6 for Sample Object
DECLARE @UserId int = [dbo].[fn_GetUserIdByName](@CreatedByPerson)
PRINT 'UserID=' + CAST(ISNULL(@UserId, 'null') as varchar(16))
if @UserId is null
begin
	PRINT 'UserId is not found for ' + @CreatedByPerson
	return 0
end
declare c1 cursor local for select ObjectId, RubricId from ObjectInfo where TenantId=@TenantId and TypeId=@TypeId_Sample and ExternalId IN (SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE CreatedByPerson=@CreatedByPerson) ORDER BY ObjectId
open c1
while (1=1)
begin
	fetch c1 into @ObjectId, @RubricId
	if @@fetch_status <> 0 break
	PRINT '--- Processing @ObjectId=' + CAST(@ObjectId as varchar(16)) + ', @RubricId=' + CAST(@RubricId as varchar(16))
	
	UPDATE dbo.RubricInfo set _createdBy=@UserId WHERE TenantId=@TenantId and RubricId=@RubricId
	UPDATE dbo.ObjectInfo set _createdBy=@UserId WHERE TenantId=@TenantId and ObjectId IN 
	(
		select @ObjectId
		UNION ALL
		select LinkedObjectId from dbo.ObjectLinkObject as olo
		INNER JOIN ObjectInfo as OI on OI.ObjectId=olo.LinkedObjectId AND OI.RubricId=@RubricId AND OI.TenantId=@TenantId
		WHERE olo.ObjectId=@ObjectId
	)
	
	select LinkedObjectId from dbo.ObjectLinkObject as olo
		INNER JOIN ObjectInfo as OI on OI.ObjectId=olo.LinkedObjectId AND OI.RubricId=@RubricId AND OI.TenantId=@TenantId
		WHERE olo.ObjectId=@ObjectId

end
close c1
deallocate c1
GO
/****** Object:  StoredProcedure [dbo].[Clear_Tenant]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Clear_Tenant]
@TenantId int
AS
-- EXEC [dbo].[Clear_Tenant] 5
DECLARE @objIds as dbo.Integers
INSERT INTO @objIds([Value]) select ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId

DELETE FROM dbo.PropertyBigString WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.PropertyFloat WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.PropertyInt WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.PropertyString WHERE ObjectId IN (select [Value] from @objIds)
--DBCC CHECKIDENT ('PropertyBigString', RESEED, 0);
--DBCC CHECKIDENT ('PropertyFloat', RESEED, 0);
--DBCC CHECKIDENT ('PropertyInt', RESEED, 0);
--DBCC CHECKIDENT ('PropertyString', RESEED, 0);
--DBCC CHECKIDENT ('AspNetUsers', RESEED, 4);
/*
SET IDENTITY_INSERT AspNetUsers ON;
INSERT INTO AspNetUsers([Id]
      ,[UserName]
      ,[NormalizedUserName]
      ,[Email]
      ,[NormalizedEmail]
      ,[EmailConfirmed]
      ,[PasswordHash]
      ,[SecurityStamp]
      ,[ConcurrencyStamp]
      ,[PhoneNumber]
      ,[PhoneNumberConfirmed]
      ,[TwoFactorEnabled]
      ,[LockoutEnd]
      ,[LockoutEnabled]
      ,[AccessFailedCount]) select 3 as [Id]
      ,[UserName]
      ,'_'+[NormalizedUserName]
      ,[Email]
      ,[NormalizedEmail]
      ,[EmailConfirmed]
      ,[PasswordHash]
      ,[SecurityStamp]
      ,[ConcurrencyStamp]
      ,[PhoneNumber]
      ,[PhoneNumberConfirmed]
      ,[TwoFactorEnabled]
      ,[LockoutEnd]
      ,[LockoutEnabled]
      ,[AccessFailedCount] FROM AspNetUsers WHERE Id=9 
SET IDENTITY_INSERT AspNetUsers OFF;
*/

DELETE FROM dbo.ObjectLinkObject WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.ObjectLinkObject WHERE LinkedObjectId IN (select [Value] from @objIds)

DELETE FROM dbo.Handover WHERE HandoverId IN (select [Value] from @objIds)
DELETE FROM dbo.Reference WHERE ReferenceId IN (select [Value] from @objIds)
DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.Composition WHERE SampleId IN (select SampleId FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @objIds))
DELETE FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @objIds)
DELETE FROM dbo.ObjectInfo WHERE ObjectId IN (select [Value] from @objIds)
DELETE FROM dbo.RubricInfo WHERE TenantId=@TenantId
GO
/****** Object:  StoredProcedure [dbo].[Delete_Compositions]    Script Date: 16/10/2024 18:34:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DELETE Compositions objects for specified EDX CSV
CREATE     PROCEDURE [dbo].[Delete_Compositions]
@TenantId int,
@RubricId int	-- "Measurement Areas" rubric
AS
-- EXEC [dbo].[Delete_Compositions] 1, 1093
SET NOCOUNT ON;
DECLARE @Compositions dbo.Integers
-- select all ObjectIds for Compositions, created for @ObjectId (EDX CSV)
	INSERT INTO @Compositions([Value])
		select ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId
-- delete all properties, associated with 
DELETE FROM dbo.PropertyBigString WHERE ObjectId IN (select [Value] from @Compositions)
DELETE FROM dbo.PropertyString WHERE ObjectId IN (select [Value] from @Compositions)
DELETE FROM dbo.PropertyInt WHERE ObjectId IN (select [Value] from @Compositions)
DELETE FROM dbo.PropertyFloat WHERE ObjectId IN (select [Value] from @Compositions)

DELETE FROM dbo.Composition WHERE SampleId IN (select [Value] from @Compositions)
DELETE FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @Compositions)
DELETE from dbo.ObjectLinkObject WHERE ObjectId IN (select [Value] from @Compositions)			-- delete links to compositions
DELETE from dbo.ObjectLinkObject WHERE LinkedObjectId IN (select [Value] from @Compositions)	-- delete links from compositions
SET NOCOUNT OFF;
DELETE FROM dbo.ObjectInfo WHERE ObjectId IN (select [Value] from @Compositions)
RETURN @@ROWCOUNT
GO
/****** Object:  StoredProcedure [dbo].[Delete_NestedObjects]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DELETE Compositions objects for specified EDX CSV
CREATE    PROCEDURE [dbo].[Delete_NestedObjects]
@TenantId int,
@ObjectId int	-- Core Object, for example, EDX ObjectId (EDX CSV) with linked compositions
AS
-- EXEC [dbo].[Delete_NestedObjects] 2, 6678
SET NOCOUNT ON;
DECLARE @NestedObjectIds dbo.Integers
-- select all ObjectIds for Compositions, created for @ObjectId (EDX CSV)
	INSERT INTO @NestedObjectIds([Value])
		select LinkedObjectId from dbo.ObjectLinkObject As L
		INNER JOIN dbo.ObjectInfo as O1 ON L.ObjectId=O1.ObjectId
		WHERE L.ObjectId=@ObjectId and O1.TenantId=@TenantId
-- delete all properties, associated with 
DELETE FROM dbo.PropertyBigString WHERE ObjectId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.PropertyString WHERE ObjectId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.PropertyInt WHERE ObjectId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.PropertyFloat WHERE ObjectId IN (select [Value] from @NestedObjectIds)

DELETE FROM dbo.Composition WHERE SampleId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.Reference WHERE ReferenceId IN (select [Value] from @NestedObjectIds)
DELETE FROM dbo.Handover WHERE HandoverId IN (select [Value] from @NestedObjectIds)
DELETE from dbo.ObjectLinkObject WHERE ObjectId IN (select [Value] from @NestedObjectIds)			-- delete links to compositions
DELETE from dbo.ObjectLinkObject WHERE LinkedObjectId IN (select [Value] from @NestedObjectIds)	-- delete links from compositions
SET NOCOUNT OFF;
DELETE FROM dbo.ObjectInfo WHERE ObjectId IN (select [Value] from @NestedObjectIds)
RETURN @@ROWCOUNT
GO
/****** Object:  StoredProcedure [dbo].[Delete_ProjectSubtreeComplete]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Delete_ProjectSubtreeComplete]
@TenantId int,
@RubricPath varchar(256),
@TypeId int=2
AS
-- EXEC [dbo].[Delete_ProjectSubtreeComplete] 5, 'Area C}C04}%', 2
--SET NOCOUNT ON;
DECLARE @Objects dbo.Integers
	INSERT INTO @Objects([Value])
		select OI.ObjectId from dbo.ObjectInfo as OI
			INNER JOIN dbo.RubricInfo as RI ON RI.RubricId=OI.RubricId AND RI.TenantId=OI.TenantId
		WHERE RI.TenantId=@TenantId AND RI.TypeId=@TypeId AND RI.RubricPath LIKE @RubricPath
-- delete all properties, associated with 
DELETE FROM dbo.PropertyBigString WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyString WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyInt WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyFloat WHERE ObjectId IN (select [Value] from @Objects)

DELETE FROM dbo.Composition WHERE SampleId IN (select [Value] from @Objects)
DELETE FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @Objects)
DELETE from dbo.ObjectLinkObject WHERE ObjectId IN (select [Value] from @Objects)			-- delete links to compositions
DELETE from dbo.ObjectLinkObject WHERE LinkedObjectId IN (select [Value] from @Objects)	-- delete links from compositions
SET NOCOUNT OFF;
DELETE FROM dbo.Reference WHERE ReferenceId IN (select [Value] from @Objects)
DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.RubricInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND RubricPath LIKE @RubricPath
RETURN @@ROWCOUNT
GO
/****** Object:  StoredProcedure [dbo].[Delete_Tenant]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [dbo].[Delete_Tenant]
@TenantId int
AS
-- EXEC [dbo].[Delete_Tenant] 1
-- EXEC [dbo].[Delete_Tenant] 2
-- EXEC [dbo].[Delete_Tenant] 3
SET NOCOUNT ON;
DECLARE @Objects dbo.Integers
	INSERT INTO @Objects([Value])
		select ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId
-- delete all properties, associated with 
DELETE FROM dbo.PropertyBigString WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyString WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyInt WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.PropertyFloat WHERE ObjectId IN (select [Value] from @Objects)

DELETE FROM dbo.Composition WHERE SampleId IN (select [Value] from @Objects)
DELETE FROM dbo.[Sample] WHERE SampleId IN (select [Value] from @Objects)
DELETE from dbo.ObjectLinkObject WHERE ObjectId IN (select [Value] from @Objects)			-- delete links to compositions
DELETE from dbo.ObjectLinkObject WHERE LinkedObjectId IN (select [Value] from @Objects)	-- delete links from compositions
SET NOCOUNT OFF;
DELETE FROM dbo.Reference WHERE ReferenceId IN (select [Value] from @Objects)
DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId IN (select [Value] from @Objects)
DELETE FROM dbo.ObjectInfo WHERE TenantId=@TenantId
DELETE FROM dbo.RubricInfo WHERE TenantId=@TenantId
DELETE FROM dbo.Tenant WHERE TenantId=@TenantId
RETURN @@ROWCOUNT
GO
/****** Object:  StoredProcedure [dbo].[Get_ObjectInfoLinked]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Get_ObjectInfoLinked]
@TenantId int,
@ObjectId int
AS
-- EXEC [dbo].Get_ObjectInfoLinked 1, 8
select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
FROM dbo.ObjectLinkObject as L
INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
	LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
WHERE L.ObjectId=@objectId
ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
GO
/****** Object:  StoredProcedure [dbo].[Get_ObjectInfoLinked_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[Get_ObjectInfoLinked_AccessControl]
@TenantId int,
@ObjectId int,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
AS
-- EXEC [dbo].Get_ObjectInfoLinked_AccessControl 1, 25987, 3, 2
IF @AccessControl>=0 and @UserId>0
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.ObjectId=@objectId AND (O.AccessControl<=@AccessControl OR O._createdBy=@UserId)
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
ELSE IF  @AccessControl=0
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.ObjectId=@objectId AND O.AccessControl<=@AccessControl
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.ObjectId=@objectId
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
GO
/****** Object:  StoredProcedure [dbo].[Get_ObjectInfoLinked_Reverse]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [dbo].[Get_ObjectInfoLinked_Reverse]
@TenantId int,
@ObjectId int
AS
-- EXEC [dbo].Get_ObjectInfoLinked_Reverse 8
select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
FROM dbo.ObjectLinkObject as L
INNER JOIN dbo.ObjectInfo as O ON L.ObjectId=O.ObjectId AND O.TenantId=@TenantId
	LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
WHERE L.LinkedObjectId=@objectId
ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
GO
/****** Object:  StoredProcedure [dbo].[Get_ObjectInfoLinked_Reverse_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Get_ObjectInfoLinked_Reverse_AccessControl]
@TenantId int,
@ObjectId int,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
AS
-- EXEC [dbo].Get_ObjectInfoLinked_Reverse_AccessControl 8, 2, 1
IF  @AccessControl>=0 and @UserId>0
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.ObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.LinkedObjectId=@objectId AND (O.AccessControl<=@AccessControl OR O._createdBy=@UserId)
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
ELSE IF @AccessControl=0
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.ObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.LinkedObjectId=@objectId AND O.AccessControl<=@AccessControl
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
	L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, L.LinkTypeObjectId,
	O.*, LTO.ObjectName as LinkTypeObjectName, LTO.ObjectNameUrl as LinkTypeObjectNameUrl
	FROM dbo.ObjectLinkObject as L
	INNER JOIN dbo.ObjectInfo as O ON L.ObjectId=O.ObjectId AND O.TenantId=@TenantId
		LEFT OUTER JOIN dbo.ObjectInfo as LTO ON L.LinkTypeObjectId=LTO.ObjectId
	WHERE L.LinkedObjectId=@objectId
	ORDER BY LTO.ObjectName, O.TypeId, L.SortCode, O.ObjectName
END
GO
/****** Object:  StoredProcedure [dbo].[Get_PropertyNameByType]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Get_PropertyNameByType]
@TenantId int,
@TypeId int=0
AS
-- EXEC [dbo].[Get_PropertyNameByType] @TenantId=1, @TypeId=9
-- EXEC [dbo].[Get_PropertyNameByType] @TenantId=1, @TypeId=0
IF @TypeId>0
	SELECT DISTINCT 'BigString' as PropertyType, PropertyName FROM dbo.PropertyBigString as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
		WHERE O.TypeId=@TypeId
	UNION ALL
	SELECT DISTINCT 'String' as PropertyType, PropertyName FROM dbo.PropertyString as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
		WHERE O.TypeId=@TypeId
	UNION ALL
	SELECT DISTINCT 'Int' as PropertyType, PropertyName FROM dbo.PropertyInt as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
		WHERE O.TypeId=@TypeId
	UNION ALL
	SELECT DISTINCT 'Float' as PropertyType, PropertyName FROM dbo.PropertyFloat as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
		WHERE O.TypeId=@TypeId
	ORDER BY PropertyType, PropertyName
ELSE
	SELECT DISTINCT 'BigString' as PropertyType, PropertyName FROM dbo.PropertyBigString as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
	UNION ALL
	SELECT DISTINCT 'String' as PropertyType, PropertyName FROM dbo.PropertyString as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
	UNION ALL
	SELECT DISTINCT 'Int' as PropertyType, PropertyName FROM dbo.PropertyInt as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
	UNION ALL
	SELECT DISTINCT 'Float' as PropertyType, PropertyName FROM dbo.PropertyFloat as P
		INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
	ORDER BY PropertyType, PropertyName
GO
/****** Object:  StoredProcedure [dbo].[GetElements_Filter]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetElements_Filter]
@TenantId int, 
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - private	/// -1 - NONE == ADMIN
@UserId int=0,
@FilterCompositionItems dbo.FilterCompositionItem READONLY,
@FilterPropertyItems dbo.FilterPropertyItem READONLY,
@TypeId int=null,
@SearchPhrase varchar(512)=null,
@CreatedByUser int=null,
@CreatedMin datetime=null,	
@CreatedMax datetime=null,
@ObjectId int=null,
@ExternalId int=null,
@JSON varchar(max)=null	-- all filter values (extensibility for future)
-- EXEC dbo.[GetElements_Filter]
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 3, -1, 0, @C, @P, null, '', 0, '20220101', '20240101'
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 1, 0, 0, @C, @P, null, '', 0, null, null
AS
DECLARE @filter NVARCHAR(2000) = [dbo].[GetFilterString] (@TenantId, @AccessControl, @UserId, @FilterCompositionItems, @FilterPropertyItems, @TypeId, @SearchPhrase, @CreatedByUser, @CreatedMin, @CreatedMax, @ObjectId, @ExternalId, @JSON);
--PRINT @filter
DECLARE @params NVARCHAR(4000) = '@TenantId int, @AccessControl int, @UserId int, @FilterCompositionItems dbo.FilterCompositionItem READONLY, @FilterPropertyItems dbo.FilterPropertyItem READONLY, @TypeId int, @SearchPhrase varchar(256), @CreatedByUser int, @CreatedMin datetime, @CreatedMax datetime, @ObjectId int, @ExternalId int, @JSON varchar(max)';
DECLARE @SQL NVARCHAR(4000) = '-- dbo.GetGetAvailableElements:
SELECT DISTINCT E.[value] as Element from dbo.vSample as S CROSS APPLY STRING_SPLIT(substring([Elements], 2, LEN([Elements])-2), ''-'') as E '
+ @filter + ' ORDER BY Element';
PRINT @SQL
EXEC sp_executesql @SQL, @params, @TenantId=@TenantId, @AccessControl=@AccessControl, @UserId=@UserId, @FilterCompositionItems=@FilterCompositionItems, @FilterPropertyItems=@FilterPropertyItems, @TypeId=@TypeId, @SearchPhrase=@SearchPhrase, @CreatedByUser=@CreatedByUser, @CreatedMin=@CreatedMin, @CreatedMax=@CreatedMax, @ObjectId=@ObjectId, @ExternalId=@ExternalId, @JSON=@JSON;
GO
/****** Object:  StoredProcedure [dbo].[GetLastAdditions_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE        PROCEDURE [dbo].[GetLastAdditions_AccessControl]
@TenantId int,
@TargetUserId int,
@MaxCount int=10,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetLastAdditions_AccessControl 1, 0, 10, 2, 1
AS
IF @AccessControl>=0 and @UserId>0
BEGIN
    SELECT TOP (@MaxCount) * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND _createdBy=IIF(@TargetUserId>0, @TargetUserId, _createdBy) AND (AccessControl<=@AccessControl OR _createdBy=@UserId) ORDER BY _created desc
END
ELSE IF @AccessControl=0
BEGIN
    SELECT TOP (@MaxCount) * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND _createdBy=IIF(@TargetUserId>0, @TargetUserId, _createdBy) AND AccessControl<=@AccessControl ORDER BY _created desc
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
    SELECT TOP (@MaxCount) * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND _createdBy=IIF(@TargetUserId>0, @TargetUserId, _createdBy) ORDER BY _created desc
END




GO
/****** Object:  StoredProcedure [dbo].[GetObjectInfo_Filter]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[GetObjectInfo_Filter]
@TenantId int, 
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - private	/// -1 - NONE == ADMIN
@UserId int=0,
@FilterCompositionItems dbo.FilterCompositionItem READONLY,
@FilterPropertyItems dbo.FilterPropertyItem READONLY,
@TypeId int=null,
@SearchPhrase varchar(512)=null,
@CreatedByUser int=null,
@CreatedMin datetime=null,	
@CreatedMax datetime=null,
@ObjectId int=null,
@ExternalId int=null,
@JSON varchar(max)=null	-- all filter values (extensibility for future)
-- EXEC dbo.[[GetObjectInfo_Filter]]
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 3, -1, 0, @C, @P, null, '', 0, '20220101', '20240101'
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 1, 0, 0, @C, @P, null, '', 0, null, null
AS
DECLARE @filter NVARCHAR(2000) = [dbo].[GetFilterString] (@TenantId, @AccessControl, @UserId, @FilterCompositionItems, @FilterPropertyItems, @TypeId, @SearchPhrase, @CreatedByUser, @CreatedMin, @CreatedMax, @ObjectId, @ExternalId, @JSON);
--PRINT @filter
DECLARE @params NVARCHAR(4000) = '@TenantId int, @AccessControl int, @UserId int, @FilterCompositionItems dbo.FilterCompositionItem READONLY, @FilterPropertyItems dbo.FilterPropertyItem READONLY, @TypeId int, @SearchPhrase varchar(256), @CreatedByUser int, @CreatedMin datetime, @CreatedMax datetime, @ObjectId int, @ExternalId int, @JSON varchar(max)';
-- vSample OR ObjectInfo ??
DECLARE @SQL NVARCHAR(4000) = 'SELECT * from dbo.ObjectInfo ' + @filter + ' ORDER BY TypeId, ObjectName';	-- ElemNumber
PRINT @SQL
EXEC sp_executesql @SQL, @params, @TenantId=@TenantId, @AccessControl=@AccessControl, @UserId=@UserId, @FilterCompositionItems=@FilterCompositionItems, @FilterPropertyItems=@FilterPropertyItems, @TypeId=@TypeId, @SearchPhrase=@SearchPhrase, @CreatedByUser=@CreatedByUser, @CreatedMin=@CreatedMin, @CreatedMax=@CreatedMax, @ObjectId=@ObjectId, @ExternalId=@ExternalId, @JSON=@JSON;
GO
/****** Object:  StoredProcedure [dbo].[GetObjectList]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetObjectList]
@TenantId int=0,
@TypeId int=0,
@ShowAdjacentTables bit=0
-- EXEC dbo.GetObjectList 1, 3
AS
DECLARE @TableName varchar(64)='';
IF @ShowAdjacentTables=1
begin
	SET NOCOUNT ON;
	SELECT top 1 @TableName=TableName FROM dbo.TypeInfo WHERE TypeId=@TypeId
	SET NOCOUNT OFF;
end;

if @TableName<>'ObjectInfo' AND @TableName<>''	-- DELETE DATA from Connected table
begin
	DECLARE @params NVARCHAR(1000) = '';
	DECLARE @SQL NVARCHAR(1000) = 'SELECT T.*, OI.* FROM dbo.[' + @TableName + '] AS T
	INNER JOIN dbo.ObjectInfo as OI ON T.' + @TableName + 'Id=OI.ObjectId
	WHERE OI.TenantId=@TenantId AND OI.TypeId=@TypeId ORDER BY OI.SortCode, OI.ObjectName';
	EXEC sp_executesql @SQL, @params;
end
else
begin
	SELECT * FROM dbo.ObjectInfo
		WHERE TenantId=@TenantId AND TypeId=@TypeId ORDER BY SortCode, ObjectName
end
GO
/****** Object:  StoredProcedure [dbo].[GetObjectList_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[GetObjectList_AccessControl]
@TenantId int,
@TypeId int=0,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
AS
-- EXEC GetObjectList_AccessControl 1, -2, -1, 2
IF @AccessControl>=0 and @UserId>0
BEGIN
	select * FROM dbo.ObjectInfo
	WHERE TenantId=@TenantId AND TypeId=@TypeId AND (AccessControl<=@AccessControl OR _createdBy=@UserId)
	ORDER BY SortCode, ObjectName
END
ELSE IF  @AccessControl=0
BEGIN
	select * FROM dbo.ObjectInfo
	WHERE TenantId=@TenantId AND TypeId=@TypeId AND AccessControl<=@AccessControl
	ORDER BY SortCode, ObjectName
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	select * FROM dbo.ObjectInfo
	WHERE TenantId=@TenantId AND TypeId=@TypeId
	ORDER BY SortCode, ObjectName
END
GO
/****** Object:  StoredProcedure [dbo].[GetObjectList_AccessControlModify]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[GetObjectList_AccessControlModify]
@TenantId int=0,
@TypeId int=0,
@IsAdmin int=0, -- 0 - PowerUser; -1 - Administrator
@UserId int=0
-- EXEC dbo.[GetObjectList_AccessControlModify] 1, 3, 7
AS
if @IsAdmin=0
BEGIN
    SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND _createdBy=@UserId ORDER BY SortCode, ObjectName
END
ELSE	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
    SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId ORDER BY SortCode, ObjectName
END
GO
/****** Object:  StoredProcedure [dbo].[GetPropertiesAllForObject]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[GetPropertiesAllForObject]
@TenantId int,
@ObjectId int
-- EXEC dbo.GetPropertiesAllForObject 7, 75061
AS
IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
	SELECT * FROM [dbo].[fn_GetObjectProperties](@ObjectId) ORDER BY [Row], SortCode, PropertyName
end
GO
/****** Object:  StoredProcedure [dbo].[GetPropertiesAllForObject_Join_Template]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[GetPropertiesAllForObject_Join_Template]
@TenantId int,
@ObjectId int,
@TypeId int=null
-- EXEC dbo.GetPropertiesAllForObject_Join_Template 4, 9006
AS
DECLARE @TemplateObjectId int, @msg varchar(256);
if ISNULL(@TypeId, 0)=0
	select @TypeId=TypeId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId
IF ISNULL(@TypeId, 0)=0
begin
	SET @msg = 'Error (GetPropertiesAllForObject_Join_Template): ObjectId not found in tenant and TypeId is not set [TenantId='+CAST(@TenantId as varchar(16))+', ObjectId='+CAST(@ObjectId as varchar(16))+', TypeId='+CAST(@TypeId as varchar(16))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
select TOP 1 @TemplateObjectId=ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName='_Template'
IF @TemplateObjectId IS NULL	-- 11429
begin
	SET @msg = 'Error (GetPropertiesAllForObject_Join_Template): _Template object not found for type [TypeId='+CAST(@TypeId as varchar(16))+', ObjectId='+CAST(@ObjectId as varchar(16))+', TypeId='+CAST(@TypeId as varchar(16))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
SELECT V.PropertyId, T.PropertyId as TemplatePropertyId, 
	ISNULL(T.PropertyType, V.PropertyType) as PropertyType, 
	T.[Row], 
	V.ObjectId, 
	ISNULL(T.SortCode, 
		ISNULL((SELECT TOP 1 SortCode FROM [dbo].[fn_GetObjectNonTableProperties](@TemplateObjectId) WHERE PropertyName=V.PropertyName), V.SortCode)
		) as SortCode, V.SortCode as ObjectSortCode, T.SortCode as TemplateSortCode, 
	V._created, V._createdBy, V._updated, V._updatedBy, 
	CAST(V.[Value] as varchar(max)) as [Value], V.ValueEpsilon, 
	ISNULL(T.PropertyName, V.PropertyName) as PropertyName, 
	ISNULL(T.Comment, V.Comment) as Comment, T.Comment as TemplateComment,
	V.SourceObjectId
FROM [dbo].[fn_GetObjectNonTableProperties](@TemplateObjectId) as T
FULL OUTER JOIN [dbo].[fn_GetObjectNonTableProperties](@ObjectId) as V ON T.PropertyName=V.PropertyName AND T.PropertyType=V.PropertyType
--ORDER BY T.SortCode, V.SortCode, T.PropertyName, V.PropertyName
ORDER BY SortCode, PropertyName
GO
/****** Object:  StoredProcedure [dbo].[GetRubricChildren_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetRubricChildren_AccessControl]
@TenantId int,
@RubricId int,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetRubricChildren_AccessControl 1, 2, 2, 1
AS
IF @AccessControl>=0 and @UserId>0
BEGIN
	SELECT * FROM dbo.RubricInfo WHERE TenantId=@TenantId and ParentId=@RubricId AND (AccessControl<=@AccessControl OR _createdBy=@UserId) ORDER BY SortCode, RubricName
END
ELSE IF @AccessControl=0
BEGIN
	SELECT * FROM dbo.RubricInfo WHERE TenantId=@TenantId and ParentId=@RubricId AND AccessControl<=@AccessControl ORDER BY SortCode, RubricName
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	SELECT * FROM dbo.RubricInfo WHERE TenantId=@TenantId and ParentId=@RubricId ORDER BY SortCode, RubricName
END
GO
/****** Object:  StoredProcedure [dbo].[GetRubricObjects_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[GetRubricObjects_AccessControl]
@TenantId int,
@RubricId int,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetRubricObjects_AccessControl 1, 2, 2, 1
AS
IF @AccessControl>=0 and @UserId>0
BEGIN
    -- SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId AND (AccessControl<=@AccessControl OR _createdBy=@UserId) ORDER BY SortCode, ObjectName
/*
	SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND (AccessControl<=@AccessControl OR _createdBy=@UserId) AND ObjectId IN (
			SELECT ObjectId from dbo.ObjectInfo WHERE RubricId=@RubricId
			UNION ALL
			SELECT ObjectId from dbo.ObjectLinkRubric WHERE RubricId=@RubricId
		) ORDER BY SortCode, ObjectName
*/
    SELECT ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription 
		FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND (AccessControl<=@AccessControl OR _createdBy=@UserId) AND RubricId=@RubricId
	UNION ALL
	SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OLR.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
		FROM dbo.ObjectInfo as OI
		INNER JOIN dbo.ObjectLinkRubric as OLR ON OLR.RubricId=@RubricId AND OI.ObjectId=OLR.ObjectId
		WHERE OI.TenantId=@TenantId AND (OI.AccessControl<=@AccessControl OR OI._createdBy=@UserId)
	ORDER BY SortCode, ObjectName
END
ELSE IF @AccessControl=0
BEGIN
    -- SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId AND AccessControl<=@AccessControl ORDER BY SortCode, ObjectName
/*
	SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND AccessControl<=@AccessControl AND ObjectId IN (
			SELECT ObjectId from dbo.ObjectInfo WHERE RubricId=@RubricId
			UNION ALL
			SELECT ObjectId from dbo.ObjectLinkRubric WHERE RubricId=@RubricId
		) ORDER BY SortCode, ObjectName
*/
    SELECT ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription 
		FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND AccessControl<=@AccessControl AND RubricId=@RubricId
	UNION ALL
	SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OLR.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
		FROM dbo.ObjectInfo as OI
		INNER JOIN dbo.ObjectLinkRubric as OLR ON OLR.RubricId=@RubricId AND OI.ObjectId=OLR.ObjectId
		WHERE OI.TenantId=@TenantId AND OI.AccessControl<=@AccessControl
	ORDER BY SortCode, ObjectName
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
    -- SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId ORDER BY SortCode, ObjectName
/*
    SELECT * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId IN (
			SELECT ObjectId from dbo.ObjectInfo WHERE RubricId=@RubricId
			UNION ALL
			SELECT ObjectId from dbo.ObjectLinkRubric WHERE RubricId=@RubricId
		) ORDER BY SortCode, ObjectName
*/
    SELECT ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription 
		FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId
	UNION ALL
	SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId, OLR.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
		FROM dbo.ObjectInfo as OI
		INNER JOIN dbo.ObjectLinkRubric as OLR ON OLR.RubricId=@RubricId AND OI.ObjectId=OLR.ObjectId
		WHERE OI.TenantId=@TenantId
	ORDER BY SortCode, ObjectName
END
GO
/****** Object:  StoredProcedure [dbo].[GetRubricPath]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetRubricPath]
@TenantId int,
@RubricId int
AS
---- EXEC [GetRubricPath] 1, 7
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
SELECT * FROM [dbo].[fn_GetRubricPath](@TenantId, @RubricId) ORDER BY [Level]
GO
/****** Object:  StoredProcedure [dbo].[GetRubricTree_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE        PROCEDURE [dbo].[GetRubricTree_AccessControl]
@TenantId int=0,
@TypeId int=0,
@MaxLevel int=10,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetRubricTree_AccessControl 1, 2, 10, 2, 1
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
IF @AccessControl>=0 and @UserId>0
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL AND (AccessControl<=@AccessControl OR _createdBy=@UserId)
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId AND (T.[Level]+1)<=@MaxLevel AND (FPI.AccessControl<=@AccessControl OR FPI._createdBy=@UserId)
	)
	SELECT * FROM CTE ORDER BY RowNum
END
ELSE IF @AccessControl=0
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL AND AccessControl<=@AccessControl
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId AND (T.[Level]+1)<=@MaxLevel AND FPI.AccessControl<=@AccessControl
	)
	SELECT * FROM CTE ORDER BY RowNum
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL-- AND (AccessControl<=@AccessControl OR _createdBy=@UserId)
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId AND (T.[Level]+1)<=@MaxLevel-- AND (FPI.AccessControl<=@AccessControl OR FPI._createdBy=@UserId)
	)
	SELECT * FROM CTE ORDER BY RowNum
END
GO
/****** Object:  StoredProcedure [dbo].[GetRubricWithPathOpened_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[GetRubricWithPathOpened_AccessControl]
@TenantId int,
@TypeId int,
@RubricId int,
@MaxLevel int=10,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetRubricWithPathOpened_AccessControl 1, 2, 49, 0, -1, 0
-- EXEC dbo.GetRubricWithPathOpened_AccessControl 1, 2, 49, 0, 2, 2
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
SET NOCOUNT ON;
DECLARE @ArrayRubricID table(RubricId int) -- таблица для временного хранения ИД рубрик
-- Fill in the path table
INSERT @ArrayRubricID 
	SELECT RubricId FROM [dbo].[fn_GetRubricPath](@TenantId, @RubricId);
SET NOCOUNT OFF;
IF @AccessControl>=0 and @UserId>0
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL AND (AccessControl<=@AccessControl OR _createdBy=@UserId)
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId AND (FPI.AccessControl<=@AccessControl OR FPI._createdBy=@UserId)
			AND (FPI.ParentID IN (SELECT RubricId FROM @ArrayRubricID) OR (T.[Level]+1)<=@MaxLevel)
	)
	SELECT * FROM CTE ORDER BY RowNum
END
ELSE IF @AccessControl=0
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL AND AccessControl<=@AccessControl
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId AND FPI.AccessControl<=@AccessControl
			AND (FPI.ParentID IN (SELECT RubricId FROM @ArrayRubricID) OR (T.[Level]+1)<=@MaxLevel)
	)
	SELECT * FROM CTE ORDER BY RowNum
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath, RowNum) AS
	(
		SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
	[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricNameUrl, RubricPath,
			[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
				(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
		FROM [dbo].[RubricInfo]
		WHERE TenantId=@TenantId AND TypeId=@TypeId AND ParentId IS NULL-- AND (AccessControl<=@AccessControl OR _createdBy=@UserId)
		UNION ALL
		SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
	FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricNameUrl, FPI.RubricPath, 
			T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
				OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
				As RowNum
		FROM dbo.RubricInfo AS FPI
				INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
		WHERE FPI.TenantId=@TenantId AND FPI.TypeId=@TypeId-- AND (FPI.AccessControl<=@AccessControl OR FPI._createdBy=@UserId)
			AND (FPI.ParentID IN (SELECT RubricId FROM @ArrayRubricID) OR (T.[Level]+1)<=@MaxLevel)
	)
	SELECT * FROM CTE ORDER BY RowNum
END
GO
/****** Object:  StoredProcedure [dbo].[GetSample_Filter]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetSample_Filter]
@TenantId int, 
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - private	/// -1 - NONE == ADMIN
@UserId int=0,
@FilterCompositionItems dbo.FilterCompositionItem READONLY,
@FilterPropertyItems dbo.FilterPropertyItem READONLY,
@TypeId int=null,
@SearchPhrase varchar(512)=null,
@CreatedByUser int=null,
@CreatedMin datetime=null,	
@CreatedMax datetime=null,
@ObjectId int=null,
@ExternalId int=null,
@JSON varchar(max)=null	-- all filter values (extensibility for future)
-- EXEC dbo.[[GetSample_Filter]]
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 3, -1, 0, @C, @P, null, '', 0, '20220101', '20240101'
-- DECLARE @C as dbo.FilterCompositionItem; DECLARE @P as dbo.FilterPropertyItem; EXEC dbo.[GetElements_Filter] 1, 0, 0, @C, @P, null, '', 0, null, null
AS
DECLARE @filter NVARCHAR(2000) = [dbo].[GetFilterString] (@TenantId, @AccessControl, @UserId, @FilterCompositionItems, @FilterPropertyItems, @TypeId, @SearchPhrase, @CreatedByUser, @CreatedMin, @CreatedMax, @ObjectId, @ExternalId, @JSON);
--PRINT @filter
DECLARE @params NVARCHAR(4000) = '@TenantId int, @AccessControl int, @UserId int, @FilterCompositionItems dbo.FilterCompositionItem READONLY, @FilterPropertyItems dbo.FilterPropertyItem READONLY, @TypeId int, @SearchPhrase varchar(256), @CreatedByUser int, @CreatedMin datetime, @CreatedMax datetime, @ObjectId int, @ExternalId int, @JSON varchar(max)';
-- vSample OR ObjectInfo ??
DECLARE @SQL NVARCHAR(4000) = 'SELECT * from dbo.vSample ' + @filter + ' ORDER BY TypeId, ObjectName';	-- ElemNumber
PRINT @SQL
EXEC sp_executesql @SQL, @params, @TenantId=@TenantId, @AccessControl=@AccessControl, @UserId=@UserId, @FilterCompositionItems=@FilterCompositionItems, @FilterPropertyItems=@FilterPropertyItems, @TypeId=@TypeId, @SearchPhrase=@SearchPhrase, @CreatedByUser=@CreatedByUser, @CreatedMin=@CreatedMin, @CreatedMax=@CreatedMax, @ObjectId=@ObjectId, @ExternalId=@ExternalId, @JSON=@JSON;

GO
/****** Object:  StoredProcedure [dbo].[GetTemplatePropertiesForType]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetTemplatePropertiesForType]
@TenantId int,
@TypeId int
-- get NON-table template
-- There should be an object of given type called "_Template"
-- EXEC dbo.[GetTemplatePropertiesForType] 3, 11
AS
DECLARE @ObjectId int
select TOP 1 @ObjectId=ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName='_Template'
IF @ObjectId IS NOT NULL
begin
	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyFloat WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyIntId as PropertyId, 'Int' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyInt WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyStringId as PropertyId, 'String' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyString WHERE [Row] IS NULL AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyBigStringId as PropertyId, 'BigString' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyBigString WHERE [Row] IS NULL AND ObjectId=@ObjectId
	ORDER BY SortCode, PropertyName
end
GO
/****** Object:  StoredProcedure [dbo].[GetTemplateTablePropertiesForType]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetTemplateTablePropertiesForType]
@TenantId int,
@TypeId int
-- get TABLE template
-- There should be an object of given type called "_Template"
-- EXEC dbo.[GetTemplateTablePropertiesForType] 3, 11
AS
DECLARE @ObjectId int
select TOP 1 @ObjectId=ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName='_Template'
IF @ObjectId IS NOT NULL
begin
	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyFloat WHERE [Row]=-1 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyIntId as PropertyId, 'Int' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyInt WHERE [Row]=-1 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyStringId as PropertyId, 'String' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyString WHERE [Row]=-1 AND ObjectId=@ObjectId
	UNION ALL
	SELECT PropertyBigStringId as PropertyId, 'BigString' as PropertyType, [Row], 
		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Value], NULL as ValueEpsilon, PropertyName, Comment, SourceObjectId
	FROM dbo.PropertyBigString WHERE [Row]=-1 AND ObjectId=@ObjectId
	ORDER BY SortCode, PropertyName
end
GO
/****** Object:  StoredProcedure [dbo].[GetUserList_AccessControl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[GetUserList_AccessControl]
@TenantId int=0,
@AccessControl int=0, -- 0 - public; 1 - protected; 2 - protectedNDA; 3 - private	/// -1 - NONE == ADMIN
@UserId int=0
-- EXEC dbo.GetUserList_AccessControl 7, -1, 0
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
IF @AccessControl>=0 and @UserId>0
BEGIN
	SELECT U.*, --ISNULL(C.ClaimValue, U.UserName) as [Name], CP.ClaimValue as Project
		[dbo].[fn_GetUserClaimCSV](U.Id, 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name') as [Name],
		[dbo].[fn_GetUserClaimCSV](U.Id, 'Project') as [Project]
	FROM dbo.AspNetUsers as U 
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as C ON U.Id=C.UserId AND C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as CP ON U.Id=CP.UserId AND CP.ClaimType='Project'
	WHERE U.Id IN (select _createdBy FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND (AccessControl<=@AccessControl OR _createdBy=@UserId))
	ORDER BY [Name]
END
ELSE IF @AccessControl=0
BEGIN
	SELECT U.*, --ISNULL(C.ClaimValue, U.UserName) as [Name], CP.ClaimValue as Project
		[dbo].[fn_GetUserClaimCSV](U.Id, 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name') as [Name],
		[dbo].[fn_GetUserClaimCSV](U.Id, 'Project') as [Project]
	FROM dbo.AspNetUsers as U 
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as C ON U.Id=C.UserId AND C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as CP ON U.Id=CP.UserId AND CP.ClaimType='Project'
	WHERE U.Id IN (select _createdBy FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND AccessControl<=@AccessControl)
	ORDER BY [Name]
END
ELSE IF @AccessControl=-1	-- NO ACCESS CONTROL (ADMIN MODE)
BEGIN
	SELECT U.*, --ISNULL(C.ClaimValue, U.UserName) as [Name], CP.ClaimValue as Project
		[dbo].[fn_GetUserClaimCSV](U.Id, 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name') as [Name],
		[dbo].[fn_GetUserClaimCSV](U.Id, 'Project') as [Project]
	FROM dbo.AspNetUsers as U 
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as C ON U.Id=C.UserId AND C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
	-- LEFT OUTER JOIN dbo.AspNetUserClaims as CP ON U.Id=CP.UserId AND CP.ClaimType='Project'
	WHERE U.Id IN (select _createdBy FROM dbo.ObjectInfo WHERE TenantId=@TenantId)
	ORDER BY [Name]
END

GO
/****** Object:  StoredProcedure [dbo].[GetUserListAll]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [dbo].[GetUserListAll]
-- EXEC dbo.GetUserListAll
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
SELECT U.*, ISNULL(C.ClaimValue, U.UserName) as [Name], CP.ClaimValue as Project
	FROM dbo.AspNetUsers as U 
	LEFT OUTER JOIN dbo.AspNetUserClaims as C ON U.Id=C.UserId AND C.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
	LEFT OUTER JOIN dbo.AspNetUserClaims as CP ON U.Id=CP.UserId AND CP.ClaimType='Project'
	ORDER BY [Name]
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_Composition_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[ObjectInfo_Composition_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,
@_createdBy int,
@_updated datetime,
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
-- @SampleId == @ObjectId,

@ElemNumber int,	-- IGNORE (calculated by SQL)
@Elements varchar(256),	-- (verified against ElementInfo)

-- dbo.Composition
@CompositionItems dbo.CompositionItem readonly,
@Xml [xml]=null,	-- IGNORE
@showResultsInRecordset bit=1 -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will folow =================================================
AS
SET NOCOUNT ON;

DECLARE @msg varchar(256) = ''
--DECLARE @ElemNumber int=0
SET @ElemNumber=0
--DECLARE @Elements varchar(256) = ''
SET @Elements=''
select @Elements = @Elements + ElementName + '-' FROM @CompositionItems

DECLARE @ValuePercent float=0, @ValueAbsolute float=0, @cnt int=0, @ElementName varchar(2)
-- because of the raw data, restiction is loose
SELECT top 1 @ElementName=ElementName, @ValuePercent=ValuePercent FROM @CompositionItems WHERE NOT (ValuePercent >= -10 AND ValuePercent <= 110)
IF @ElementName IS NOT NULL	-- EXISTS
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): Every Percentage should be in [-10; 110], but ' + @ElementName + '=' + CAST(@ValuePercent as varchar(16))
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;
IF EXISTS(SELECT ElementName FROM @CompositionItems WHERE ValueAbsolute < 0)
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): Every Absolute should be >= 0'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;

DECLARE @el varchar(2)=NULL
SELECT TOP 1 @el=ElementName FROM @CompositionItems WHERE ElementName NOT IN (SELECT ElementName FROM dbo.ElementInfo)
IF @el IS NOT NULL
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): Element ' + @el + ' is not found in known elements list'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;

select @ValuePercent=SUM(ValuePercent), @ValueAbsolute=SUM(ValueAbsolute), @cnt=count(ElementName) FROM @CompositionItems
IF @cnt<1
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): @CompositionItems has no rows'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;
IF @ValuePercent>0 AND @ValueAbsolute>0
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): Can not mix Percentage and Absolute values'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;
IF @ValuePercent>0 AND (@ValuePercent<99/*99.9*/ OR @ValuePercent>101/*100.1*/)
BEGIN
	SET @msg = 'Error (ObjectInfo_Composition_UpdateInsert): Sum of Percentage should be equal to 100% [Percentage='+ CAST(@ValuePercent as varchar(32))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
END;

--DECLARE @showResultsInRecordset int=0
DECLARE @id int;
EXEC @id = [dbo].[ObjectInfo_Sample_UpdateInsert] @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, @ElemNumber, @Elements, 0/*@showResultsInRecordset, */
if @ObjectId>0
BEGIN
	DELETE FROM dbo.Composition WHERE SampleId=@ObjectId
	DECLARE @CompositionId int=NULL
	SELECT @CompositionId = MAX(CompositionId) FROM dbo.Composition
	IF @CompositionId IS NULL
		SET @CompositionId=0
	INSERT INTO dbo.Composition(CompositionId, SampleId, CompoundIndex, ElementName, ValueAbsolute, ValuePercent)
		SELECT @CompositionId + ROW_NUMBER() OVER(ORDER BY CompoundIndex ASC) as CompositionId, @ObjectId as SampleId, CompoundIndex, ElementName, ValueAbsolute, 
			IIF(@ValuePercent=0 AND @ValueAbsolute>0, ValueAbsolute/@ValueAbsolute*100, ValuePercent) as ValuePercent		-- ALWAYS CALCULATE ValuePercent
			FROM @CompositionItems ORDER BY CompoundIndex, ElementName
END
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 *, (select * from dbo.Composition WHERE SampleId=@ObjectId for xml path('item'), root('root')) as [Xml] 
		FROM dbo.vSample WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_Delete]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectInfo_Delete]
@TenantId int,
@ObjectId int
AS
-- EXEC dbo.ObjectInfo_Delete 1, 3
BEGIN
	SET NOCOUNT ON;
	DECLARE @RubricId int, @TypeId int, @TableName varchar(64)
	SELECT top 1 @RubricId=RubricId, @TypeId=TypeId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId
	SELECT top 1 @TableName=TableName FROM dbo.TypeInfo WHERE TypeId=@TypeId

	DECLARE @dt as dbo.Integers;
	DELETE FROM dbo.ObjectLinkObject WHERE LinkedObjectId=@ObjectId OR ObjectId=@ObjectId
	DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId=@ObjectId
	-- properties, that were derived from the current object
	DELETE FROM dbo.PropertyBigString WHERE SourceObjectId=@ObjectId
	DELETE FROM dbo.PropertyFloat WHERE SourceObjectId=@ObjectId
	DELETE FROM dbo.PropertyInt WHERE SourceObjectId=@ObjectId
	DELETE FROM dbo.PropertyString WHERE SourceObjectId=@ObjectId
	-- own properties of the object
	DELETE FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId
	DELETE FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId
	DELETE FROM dbo.PropertyInt WHERE ObjectId=@ObjectId
	DELETE FROM dbo.PropertyString WHERE ObjectId=@ObjectId

	if @TableName<>'ObjectInfo' AND @TableName<>''	-- DELETE DATA from Connected table
	begin
		DECLARE @params NVARCHAR(1000) = '@ObjectId int';
		DECLARE @SQL NVARCHAR(1000) = 'DELETE FROM dbo.[' + @TableName + '] WHERE ' + @TableName + 'Id = @ObjectId';
		EXEC sp_executesql @SQL, @params, @ObjectId=@ObjectId;
	end

	SET NOCOUNT OFF;
	DELETE FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId
	SET NOCOUNT ON;
	EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId
	SET NOCOUNT OFF;
END

GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_Handover_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[ObjectInfo_Handover_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,
@_createdBy int,
@_updated datetime,
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
-- @HandoverId == @ObjectId,
@SampleObjectId int,	-- ObjectId (for sample)
@DestinationUserId int,	-- Destination User 
@DestinationConfirmed datetime,	-- NULL (Destination User has not received the sample); NOT NULL = Handover successfull
@DestinationComments varchar(128),	-- Comments, that could be filled by the user upon receivement
@Json varchar(max),	-- some JSON for the future extensibility
@Amount float,
@MeasurementUnit varchar(32),
@showResultsInRecordset bit=1 -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will follow =================================================
AS
SET NOCOUNT ON;
DECLARE @id int;
EXEC @id = [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, 0 /*@showResultsInRecordset*/
if @Amount<=0
begin
	SET @Amount=NULL
	SET @MeasurementUnit=NULL
end
if EXISTS (select top 1 HandoverId from dbo.[Handover] WHERE HandoverId=@id)
BEGIN
	UPDATE dbo.[Handover] SET SampleObjectId=@SampleObjectId, DestinationUserId=@DestinationUserId, DestinationConfirmed=@DestinationConfirmed, DestinationComments=@DestinationComments, [Json]=@Json,
		Amount=@Amount, MeasurementUnit=@MeasurementUnit
	WHERE HandoverId=@id
END
ELSE
BEGIN
	INSERT INTO dbo.[Handover](HandoverId, SampleObjectId, DestinationUserId, DestinationConfirmed, DestinationComments, [Json], Amount, MeasurementUnit)
		VALUES(@id, @SampleObjectId, @DestinationUserId, @DestinationConfirmed, @DestinationComments, @Json, @Amount, @MeasurementUnit)
END
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 * FROM dbo.vHandover WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_Reference_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[ObjectInfo_Reference_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,
@_createdBy int,
@_updated datetime,
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
--@showResultsInRecordset bit=0, -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will folow =================================================
-- @ReferenceId == @ObjectId,
@Authors varchar(512),
@Title varchar(1024),
@Journal varchar(256),
@Year int,
@Volume varchar(32),
@Number varchar(32),
@StartPage varchar(32),
@EndPage varchar(32),
@DOI varchar(256),
@URL varchar(256),
@BibTeX varchar(4096),
@showResultsInRecordset bit=1 -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will folow =================================================
AS
SET NOCOUNT ON;
DECLARE @id int;
EXEC @id = [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, 0/*@showResultsInRecordset, */
if EXISTS (select top 1 ReferenceId from dbo.[Reference] WHERE ReferenceId=@id)
BEGIN
	UPDATE dbo.[Reference] SET Authors=@Authors, Title=@Title, Journal=@Journal, [Year]=@Year, Volume=@Volume, Number=@Number,
		StartPage=@StartPage, EndPage=@EndPage, DOI=@DOI, [URL]=@URL, BibTeX=@BibTeX
		WHERE ReferenceId=@id
END
ELSE
BEGIN
	INSERT INTO dbo.[Reference](ReferenceId, Authors, Title, Journal, [Year], Volume, Number, StartPage, EndPage, DOI, [URL], BibTeX)
		VALUES(@id, @Authors, @Title, @Journal, @Year, @Volume, @Number, @StartPage, @EndPage, @DOI, @URL, @BibTeX)
END
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 * FROM dbo.vReference WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_Sample_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectInfo_Sample_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,
@_createdBy int,
@_updated datetime,
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
-- @SampleId == @ObjectId,
@ElemNumber int,	-- IGNORE (calculated by SQL)
@Elements varchar(256),	-- (verified against ElementInfo)
@showResultsInRecordset bit=1 -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will follow =================================================
AS
SET NOCOUNT ON;
--DECLARE @showResultsInRecordset int=0
-- CHECK @Elements and calculate @ElemNumber - BEGIN
DECLARE @msg varchar(256) = [dbo].[ValidateElements](@Elements)
IF @msg IS NOT NULL
begin
	SET @msg = 'Error (ObjectInfo_Sample_UpdateInsert): dbo.ValidateElements failed: ' + @msg
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
SET @Elements = dbo.GetSortedElementsFromString(@Elements)
SET @ElemNumber = dbo.GetElementsCountFromString(@Elements)
if @ElemNumber<1
begin
	SET @msg = 'Error (ObjectInfo_Sample_UpdateInsert): dbo.ValidateElements failed: ElemNumber' + CAST(@ElemNumber as varchar(16))
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
-- CHECK @Elements and calculate @ElemNumber - END
DECLARE @id int;
EXEC @id = [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, 0 /*@showResultsInRecordset*/
if EXISTS (select top 1 SampleId from dbo.[Sample] WHERE SampleId=@id)
BEGIN
	UPDATE dbo.[Sample] SET ElemNumber=@ElemNumber, [Elements]=@Elements WHERE SampleId=@id
END
ELSE
BEGIN
	INSERT INTO dbo.[Sample](SampleId, ElemNumber, [Elements])
		VALUES(@id, @ElemNumber, @Elements)
END
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 * FROM dbo.vSample WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_SampleFull_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectInfo_SampleFull_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,
@_createdBy int,
@_updated datetime,
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
-- @SampleId == @ObjectId,
@ElemNumber int,	-- IGNORE (calculated by SQL)
@Elements varchar(256),	-- (verified against ElementInfo)
@SubstrateObjectId int,	-- Custom form for Sample
@Type int,	-- Custom form for Sample
@WaferId int,	-- Wafer Identifier for a sample ("Wafer ID" integer property)
@showResultsInRecordset bit=1 -- END of ObjectInfo_UpdateInsert	-- Don't uncomment otherwise Dapper error will follow =================================================
AS
SET NOCOUNT ON;
--DECLARE @showResultsInRecordset int=0
-- CHECK @Elements and calculate @ElemNumber - BEGIN
DECLARE @msg varchar(256) = [dbo].[ValidateElements](@Elements)
IF @msg IS NOT NULL
begin
	SET @msg = 'Error (ObjectInfo_Sample_UpdateInsert): dbo.ValidateElements failed: ' + @msg
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
SET @Elements = dbo.GetSortedElementsFromString(@Elements)
SET @ElemNumber = dbo.GetElementsCountFromString(@Elements)
if @ElemNumber<1
begin
	SET @msg = 'Error (ObjectInfo_Sample_UpdateInsert): dbo.ValidateElements failed: ElemNumber' + CAST(@ElemNumber as varchar(16))
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
-- CHECK @Elements and calculate @ElemNumber - END
DECLARE @id int;
EXEC @id = [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, 0 /*@showResultsInRecordset*/
if EXISTS (select top 1 SampleId from dbo.[Sample] WHERE SampleId=@id)
BEGIN
	UPDATE dbo.[Sample] SET ElemNumber=@ElemNumber, [Elements]=@Elements WHERE SampleId=@id
END
ELSE
BEGIN
	INSERT INTO dbo.[Sample](SampleId, ElemNumber, [Elements])
		VALUES(@id, @ElemNumber, @Elements)
END
-- Substrate
	DELETE FROM dbo.ObjectLinkObject WHERE ObjectId=@id AND LinkedObjectId IN (select ObjectId from dbo.ObjectInfo where TenantId=@TenantId AND TypeId=5 /* Substrate */)
	if @SubstrateObjectId>0 and exists (select ObjectId from dbo.ObjectInfo where TenantId=@TenantId AND TypeId=5 and ObjectId=@SubstrateObjectId)
	begin
		INSERT INTO dbo.ObjectLinkObject (ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy)
			VALUES(@id, @SubstrateObjectId, -1000, @_created, @_createdBy, @_updated, @_updatedBy)
	end
-- Type (as an integer property called "Type")
	DECLARE @typePropertyId int
	SELECT top 1 @typePropertyId=PropertyIntId FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName='Type'
	IF @typePropertyId>0
	begin
		UPDATE dbo.PropertyInt SET [Value]=@Type, _updated = getdate(), _updatedBy=@_updatedBy WHERE PropertyIntId=@typePropertyId
	end
	else
	begin
		INSERT INTO dbo.PropertyInt (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
			[Row], [Value], /*ValueEpsilon, */PropertyName, Comment)
		VALUES (@ObjectId, 0, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
			NULL/*@Row*/, @Type, /*@ValueEpsilon, */'Type', NULL)
	end
-- Wafer ID (as an integer property called "Wafer ID")
	DECLARE @waferIdPropertyId int
	SELECT top 1 @waferIdPropertyId=PropertyIntId FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName='Wafer ID'
	IF @waferIdPropertyId>0
	begin
		if @WaferId>0
			UPDATE dbo.PropertyInt SET [Value]=@WaferId, _updated = getdate(), _updatedBy=@_updatedBy WHERE PropertyIntId=@waferIdPropertyId
		else
			DELETE FROM dbo.PropertyInt WHERE PropertyIntId=@waferIdPropertyId
	end
	else if @WaferId>0
	begin
		INSERT INTO dbo.PropertyInt (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
			[Row], [Value], /*ValueEpsilon, */PropertyName, Comment)
		VALUES (@ObjectId, 0, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
			NULL/*@Row*/, @WaferId, /*@ValueEpsilon, */'Wafer ID', NULL)
	end
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 * FROM dbo.vSample WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectInfo_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE        PROCEDURE [dbo].[ObjectInfo_UpdateInsert]
@ObjectId int output,
@TenantId int,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@TypeId int,
@RubricId int,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@ExternalId int=null,
@ObjectName varchar(512)='',
@ObjectNameUrl varchar(256)='',	-- IGNORE
@ObjectFilePath varchar(256)=null,
@ObjectDescription varchar(1024)=null,
@showResultsInRecordset bit=1
AS
-- EXEC dbo.ProcRubric_NormaliseTree 1, 1
SET NOCOUNT ON;
DECLARE @msg varchar(512)
SET @ObjectName = RTRIM(LTRIM(ISNULL(@ObjectName, '')))
IF LEN(@ObjectName)=0
begin
	RAISERROR ('Error (ObjectInfo_UpdateInsert): Name can not be empty', 16, 0);
	RETURN 0;
end
IF @ExternalId=0
	SET @ExternalId=NULL
DECLARE @ObjectNameUrlDB varchar(256), @LeafFlagDB int, @ObjectFileHash varchar (128), @ObjectIdDuplicateName int
SELECT @ObjectNameUrlDB=OI.ObjectNameUrl, @LeafFlagDB=RI.LeafFlag, @ObjectFileHash=ObjectFileHash
	FROM dbo.ObjectInfo as OI
	LEFT OUTER JOIN dbo.RubricInfo as RI ON RI.RubricId=OI.RubricId
	WHERE ObjectId>0 AND ObjectId=@ObjectId
IF @ObjectNameUrlDB IS NOT NULL -- EXISTS (SELECT TOP 1 ObjectId FROM ObjectInfo WHERE ObjectId=@ObjectId)
BEGIN
	select TOP 1 @ObjectIdDuplicateName=ObjectId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName=@ObjectName AND ObjectId<>@ObjectId
	IF @ObjectIdDuplicateName IS NOT NULL
	begin
		SET @msg = 'Error (ObjectInfo_UpdateInsert): Name "' + @ObjectName + '" must be unique within type [ObjectId_DuplicateName=' + CAST(@ObjectIdDuplicateName as varchar(16)) + ']'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	UPDATE dbo.ObjectInfo SET -- TenantId=@TenantId, _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, TypeId=IIF(ISNULL(@TypeId, 0)<>0, @TypeId, TypeId), 
		RubricId=@RubricId, SortCode=@SortCode, AccessControl=@AccessControl, IsPublished=@IsPublished, ExternalId=@ExternalId,
		ObjectName=@ObjectName, 
		-- by Sabrina Request - be careful - BEGIN
		ObjectNameUrl=LOWER(@ObjectNameUrl), 
		-- by Sabrina Request - be careful - END
		ObjectFilePath=@ObjectFilePath, ObjectFileHash=IIF(@ObjectFilePath IS NULL, NULL, @ObjectFileHash),
		ObjectDescription=@ObjectDescription
	WHERE ObjectId=@ObjectId
END
ELSE    -- add record
BEGIN
	SET @ObjectId=NULL
	SELECT @ObjectId = MAX(ObjectId)+1 FROM dbo.ObjectInfo
	IF @ObjectId IS NULL
		SET @ObjectId=1
	IF @ObjectNameUrl IS NULL OR @ObjectNameUrl=''
		SET @ObjectNameUrl=dbo.fn_Transliterate4URL(dbo.fn_StripHTML(@ObjectName)) + '-' + CAST(@ObjectId as varchar(16))
	IF EXISTS(select ObjectId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName=@ObjectName)
	begin
		SET @msg = 'Error (ObjectInfo_UpdateInsert): Name "' + @ObjectName + '" must be unique within type'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	if @ExternalId=-1	-- auto SET
	begin
		SET @ExternalId=ISNULL((SELECT MAX(ExternalId)+1 FROM dbo.ObjectInfo with (nolock) WHERE TenantId=@TenantId AND TypeId=@TypeId), 1)
	end
	INSERT INTO dbo.ObjectInfo (ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId,  RubricId, 
		SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectDescription)
	VALUES(@ObjectId, @TenantId, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/, @TypeId, @RubricId, 
		@SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, LOWER(@ObjectNameUrl), @ObjectFilePath, @ObjectDescription)
	if @LeafFlagDB IS NOT NULL AND @LeafFlagDB&1=0
	begin
		UPDATE dbo.RubricInfo SET LeafFlag=dbo.fnRubricInfo_CalculateLeafFlag(@RubricId) 
			WHERE RubricId=@RubricId
	end
END
SET NOCOUNT OFF;
IF @showResultsInRecordset=1
begin
	SELECT top 1 * FROM dbo.ObjectInfo WHERE ObjectId=@ObjectId
end
RETURN @ObjectId
GO
/****** Object:  StoredProcedure [dbo].[ObjectLinkObject_LinkAdd]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectLinkObject_LinkAdd]
@TenantId int,
@ObjectId int,
@LinkedObjectId int,
@_created datetime,	-- IGNORED
@_createdBy int,	
@_updated datetime, -- IGNORED
@_updatedBy int,
@SortCode int,
@LinkTypeObjectId int
AS
BEGIN
	SET NOCOUNT ON;
	if @LinkTypeObjectId=0
		SET @LinkTypeObjectId=NULL
	DECLARE @msg varchar(256) = ''
	-- make sure that @ObjectId is in the current tenant
	if NOT EXISTS(select ObjectId from dbo.ObjectInfo where TenantId=@TenantId and ObjectId=@ObjectId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinkAdd): @ObjectId=' + CAST(@ObjectId as varchar(16)) + ' is not found in TenantId='+ CAST(@TenantId as varchar(16))
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	-- make sure that @LinkedObjectId is in the current tenant
	if NOT EXISTS(select ObjectId from dbo.ObjectInfo where TenantId=@TenantId and ObjectId=@LinkedObjectId AND @ObjectId<>@LinkedObjectId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinkAdd): @LinkedObjectId=' + CAST(@LinkedObjectId as varchar(16)) + ' is not found in TenantId='+ CAST(@TenantId as varchar(16))
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	-- make sure that @LinkTypeObjectId is in the current tenant and defined
	if @LinkTypeObjectId IS NOT NULL AND NOT EXISTS(select ObjectId from dbo.ObjectInfo where TenantId=@TenantId and ObjectId=@LinkTypeObjectId AND @ObjectId<>@LinkTypeObjectId AND @LinkedObjectId<>@LinkTypeObjectId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinkAdd): @LinkTypeObjectId=' + CAST(@LinkTypeObjectId as varchar(16)) + ' is not found in TenantId='+ CAST(@TenantId as varchar(16))
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end

	declare @ObjectLinkObjectId int, @SortCodeDB int, @LinkTypeObjectIdDB int
	select @ObjectLinkObjectId=ObjectLinkObjectId, @SortCodeDB=SortCode, @LinkTypeObjectIdDB=LinkTypeObjectId from dbo.ObjectLinkObject WHERE ObjectId=@ObjectId and LinkedObjectId=@LinkedObjectId
	-- make sure that all records in @LinkedObjects are in the current tenant
	SET NOCOUNT OFF;
	IF @ObjectLinkObjectId IS NOT NULL	-- EXISTS
	begin
		UPDATE dbo.ObjectLinkObject set _updated=getdate(), 
			SortCode=IIF(@SortCode IS NULL, @SortCodeDB, @SortCode), 
			LinkTypeObjectId=IIF(@LinkTypeObjectId IS NULL, @LinkTypeObjectIdDB, @LinkTypeObjectId) 
		WHERE ObjectLinkObjectId=@ObjectLinkObjectId
	end
	ELSE
	begin
		INSERT INTO dbo.ObjectLinkObject(ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, LinkTypeObjectId)
			VALUES (@ObjectId, @LinkedObjectId, ISNULL(@SortCode, 0), getdate(), @_createdBy, getdate(), @_createdBy, @LinkTypeObjectId)
	end
END
GO
/****** Object:  StoredProcedure [dbo].[ObjectLinkObject_LinksInsertForStagedFiles]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectLinkObject_LinksInsertForStagedFiles]
@LinkedObjects dbo.ObjectLinkObjectItem READONLY,
@TenantId int,
@UserId int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @msg varchar(256) = ''
	-- make sure that all records in @LinkedObjects are in the current tenant
	IF EXISTS(select O1.TenantId, O2.TenantId, O3.TenantId		FROM @LinkedObjects as L
				INNER JOIN dbo.ObjectInfo as O1 ON L.ObjectId=O1.ObjectId
				INNER JOIN dbo.ObjectInfo as O2 ON L.LinkedObjectId=O2.ObjectId
				LEFT OUTER JOIN dbo.ObjectInfo as O3 ON L.LinkTypeObjectId=O3.ObjectId
				WHERE O1.TenantId<>@TenantId OR O2.TenantId<>@TenantId OR ISNULL(O3.TenantId, @TenantId)<>@TenantId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinksInsertForStagedFiles): Mismatch TenantId found in objects linked in @LinkedObjects (report this error, please)'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	-- IMPORTANT: from @LinkedObjects WE TAKE ObjectId & LinkedObjectId & SortCode (ObjectLinkObjectId - skipped!!!)

	-- UPDATE EXISTING (There should exist no records in fact)
	--UPDATE OL
	--	SET OL.SortCode=ISNULL(L.SortCode, 0), _updated=getdate(), _updatedBy=@_updatedBy
	--FROM dbo.ObjectLinkObject as OL
	--	INNER JOIN @LinkedObjects as L ON L.LinkedObjectId=OL.LinkedObjectId
	--WHERE OL.ObjectId=@ObjectId AND OL.SortCode<>ISNULL(L.SortCode,0)
		
	-- INSERT NEW
	INSERT INTO dbo.ObjectLinkObject(ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, LinkTypeObjectId)
		SELECT LO.ObjectId, LO.LinkedObjectId, ISNULL(LO.SortCode, 0), getdate(), @UserId, getdate(), @UserId, IIF(LO.LinkTypeObjectId=0, NULL, LO.LinkTypeObjectId)
			FROM @LinkedObjects as LO
			LEFT OUTER JOIN ObjectLinkObject as OLO ON OLO.ObjectId=LO.ObjectId AND OLO.LinkedObjectId=LO.LinkedObjectId
			WHERE OLO.ObjectLinkObjectId IS NULL
	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[ObjectLinkObject_LinksUpdate]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ObjectLinkObject_LinksUpdate]
@LinkedObjects dbo.ObjectLinkObjectItem READONLY,
@TenantId int,
@ObjectId int,
@_created datetime,	-- IGNORED
@_createdBy int,	
@_updated datetime, -- IGNORED
@_updatedBy int,
@skipOutput bit=0	-- skip final recordset output
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @msg varchar(256) = ''
	-- make sure that @ObjectId is in the current tenant
	if NOT EXISTS(select ObjectId from dbo.ObjectInfo where TenantId=@TenantId and ObjectId=@ObjectId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinksUpdate): @ObjectId=' + CAST(@ObjectId as varchar(16)) + ' is not found in TenantId='+ CAST(@TenantId as varchar(16))
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	-- make sure that all records in @LinkedObjects are in the current tenant
	IF EXISTS(select O1.TenantId, O2.TenantId, O3.TenantId		FROM @LinkedObjects as L
				INNER JOIN dbo.ObjectInfo as O1 ON L.ObjectId=O1.ObjectId
				INNER JOIN dbo.ObjectInfo as O2 ON L.LinkedObjectId=O2.ObjectId
				LEFT OUTER JOIN dbo.ObjectInfo as O3 ON L.LinkTypeObjectId=O3.ObjectId
				WHERE O1.TenantId<>@TenantId OR O2.TenantId<>@TenantId OR ISNULL(O3.TenantId, @TenantId)<>@TenantId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinksUpdate): Mismatch TenantId found in objects linked in @LinkedObjects (report this error, please)'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	-- make sure that all records in @LinkedObjects are in the current tenant
	IF EXISTS(select OLO.LinkedObjectId, O1.TenantId, O2.TenantId, O3.TenantId		FROM @LinkedObjects as L
				INNER JOIN dbo.ObjectLinkObject as OLO ON L.LinkedObjectId=OLO.LinkedObjectId
				INNER JOIN dbo.ObjectInfo as O1 ON OLO.ObjectId=O1.ObjectId
				INNER JOIN dbo.ObjectInfo as O2 ON OLO.LinkedObjectId=O2.ObjectId
				LEFT OUTER JOIN dbo.ObjectInfo as O3 ON L.LinkTypeObjectId=O3.ObjectId
				WHERE O1.TenantId<>@TenantId OR O2.TenantId<>@TenantId OR ISNULL(O3.TenantId, @TenantId)<>@TenantId)
	begin
		SET @msg = 'Error (ObjectLinkObject_LinksUpdate): Mismatch TenantId found in objects linked in references (LinkedObjectId) from @LinkedObjects (report this error, please)'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end

	-- IMPORTANT: from @LinkedObjects WE TAKE ONLY LinkedObjectId & SortCode
	-- Delete unbound
	DELETE FROM dbo.ObjectLinkObject WHERE ObjectId=@ObjectId AND LinkedObjectId NOT IN (select LinkedObjectId FROM @LinkedObjects)

	-- UPDATE EXISTING commented out on April 2024
	/*
	UPDATE OL
		SET OL.SortCode=ISNULL(L.SortCode, 0), OL.LinkTypeObjectId=L.LinkTypeObjectId, _updated=getdate(), _updatedBy=@_updatedBy
	FROM dbo.ObjectLinkObject as OL
		INNER JOIN @LinkedObjects as L ON L.LinkedObjectId=OL.LinkedObjectId
	WHERE OL.ObjectId=@ObjectId AND (OL.SortCode<>ISNULL(L.SortCode,0) OR ISNULL(OL.LinkTypeObjectId,0)<>ISNULL(L.LinkTypeObjectId,0))
	*/

	-- INSERT NEW
	INSERT INTO dbo.ObjectLinkObject(ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, LinkTypeObjectId)
		SELECT @ObjectId as ObjectId, LinkedObjectId, ISNULL(SortCode, 0), getdate(), @_createdBy, getdate(), @_createdBy, IIF(LinkTypeObjectId=0, NULL, LinkTypeObjectId)
			FROM @LinkedObjects
			WHERE LinkedObjectId NOT IN (select LinkedObjectId from dbo.ObjectLinkObject where ObjectId=@ObjectId) AND LinkedObjectId<>@ObjectId
	SET NOCOUNT OFF;
	if @skipOutput=0
	begin
		EXEC [dbo].Get_ObjectInfoLinked @TenantId, @ObjectId;
	end
END
GO
/****** Object:  StoredProcedure [dbo].[ProcRubric_NormaliseTree]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[ProcRubric_NormaliseTree] 
@TenantId int,
@TypeId int,
@RubricId int=0,  -- ParentId, по которому нужно выполнять нормализацию
@Level int=0,
@Path varchar(8000)=''
AS
-- Normalizes rubrics Tree after update
-- INIT (CLEAR ALL MetaInfo Except ParentId itself):
---- UPDATE dbo.RubricInfo SET [Level]=-1, LeafFlag=0, RubricNameUrl='', RubricPath=''
-- Update RubricPath only (based on ParentId only):
---- UPDATE dbo.RubricInfo SET RubricPath = LEFT([dbo].[fn_GetRubricPathStringFULL](RubricID,'}'), 256)
-- RESULT:
---- select * from RubricInfo order by RubricPath
-- Normalize Level+LeafFlag+RubricPath:
---- EXEC [dbo].[ProcRubric_NormaliseTree] 1, 1
DECLARE @new_path varchar(8000)
SET NOCOUNT ON;
IF ISNULL(@RubricId, 0)=0 AND @Level=0  -- MAIN CALL
BEGIN
	UPDATE dbo.RubricInfo SET [Level]=0 WHERE TenantId=@TenantId AND TypeId=@TypeId AND ISNULL(ParentId,0)=0
	-- root rubrics
	declare c1 cursor local for select RubricID, [Level] from dbo.RubricInfo Where TenantId=@TenantId AND TypeId=@TypeId AND ISNULL(ParentID, 0)=0
	open c1
	while (1=1)
	begin
		fetch c1 into @RubricID, @Level
		if @@fetch_status <> 0 break
		SET @new_path='.' + CAST(@RubricId As varchar(16)) + '.'
		EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId, @RubricID, @Level, @new_path
	end
	close c1
	deallocate c1
	-- updates ALL LeafFlag of ALL rubrics, that are in a tree
	declare c2 cursor local FORWARD_ONLY STATIC for select RubricId from dbo.RubricInfo Where TenantId=@TenantId AND TypeId=@TypeId
	open c2
	while (1=1)
	begin
		fetch c2 into @RubricId
		if @@fetch_status <> 0 break
		UPDATE dbo.RubricInfo 
			SET LeafFlag = dbo.fnRubricInfo_CalculateLeafFlag(@RubricId),
				RubricPath = LEFT(dbo.fn_GetRubricPathStringFULL(@RubricId,'}'), 256)
		WHERE RubricId=@RubricId
	end
	close c2
	deallocate c2
END
ELSE  -- рекурсия
BEGIN
	declare cr cursor local FORWARD_ONLY STATIC for select RubricId from dbo.RubricInfo Where TenantId=@TenantId AND TypeId=@TypeId AND ParentId=@RubricId
--Print 'select RubricId from dbo.RubricInfo Where RubricId>0 AND ParentId=' + CAST(@RubricId As varchar(16))
	SET @Level=@Level+1
	open cr
	while (1=1)
	begin
		fetch cr into @RubricId
		if @@fetch_status <> 0 break
		SET @new_path='.' + CAST(@RubricId As varchar(16)) + '.'
		IF CHARINDEX(@new_path, @Path) > 0	-- цикл
			PRINT 'ATTENTION! LOOP found: ' + @Path + CAST(@RubricId As varchar(16)) + '.'
		ELSE
		BEGIN
			UPDATE dbo.RubricInfo SET [Level]=@Level WHERE RubricId=@RubricId
			SET @new_path=@Path + CAST(@RubricId As varchar(16)) + '.'
--Print 'CALL for @RubricId=' + CAST(@RubricId As varchar(16))
			EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId, @RubricID, @Level, @new_path
		END
	end
	close cr
	deallocate cr
END
SET NOCOUNT OFF;
GO
/****** Object:  StoredProcedure [dbo].[ProcRubric_NormaliseTree_All]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[ProcRubric_NormaliseTree_All] 
AS
DECLARE @TenantId int, @TypeId int
-- Normalizes rubrics Tree after update
-- EXEC [dbo].[ProcRubric_NormaliseTree_All]
DECLARE @new_path varchar(8000)
declare c1 cursor local for select DISTINCT TenantId, TypeId from dbo.RubricInfo
open c1
while (1=1)
begin
	fetch c1 into @TenantId, @TypeId
	if @@fetch_status <> 0 break
	PRINT 'Normalizing Tree for TenantId=' + CAST(@TenantId as varchar(8)) + ', TypeId=' + CAST(@TypeId as varchar(8))
	EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId
end
close c1
deallocate c1
GO
/****** Object:  StoredProcedure [dbo].[ProcRubric_NormaliseUrl]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ProcRubric_NormaliseUrl] 
@TenantId int,
@TypeId int
AS
-- Normalizes URL in rubrics Tree
-- EXEC [dbo].[ProcRubric_NormaliseUrl] 1, 2
DECLARE @RubricName varchar(256), @RubricNameUrl varchar(256)
DECLARE @RubricId int, @ParentId int, @Level int;
EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId;
declare c1 cursor local for select DISTINCT RubricId, ParentId, [Level], RubricName from dbo.RubricInfo WHERE TenantId=@TenantId AND TypeId=@TypeId
open c1
while (1=1)
begin
	fetch c1 into @RubricId, @ParentId, @Level, @RubricName
	if @@fetch_status <> 0 break
	SET @RubricNameUrl = ''
	SELECT @RubricNameUrl=RubricNameUrl FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricId>0 AND TypeId=@TypeId AND RubricId=@ParentId
	IF @RubricNameUrl<>''
		SET @RubricNameUrl = @RubricNameUrl + '_'
	SET @RubricNameUrl = @RubricNameUrl + dbo.fn_Transliterate4URL(@RubricName)
	UPDATE dbo.RubricInfo SET RubricNameUrl=@RubricNameUrl WHERE TenantId=@TenantId AND RubricId=@RubricId;
end
close c1
deallocate c1
GO
/****** Object:  StoredProcedure [dbo].[Property_Delete]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Property_Delete]
@TenantId int,
@mode varchar(128),
@PropertyId int
AS
-- EXEC [dbo].[Property_Delete] 1, 'Int', 1
IF @PropertyId IS NULL OR @PropertyId<1
begin
	RAISERROR ('Error (Property_Delete): PropertyId must be specified', 16, 0);
	RETURN 404;
end
IF @mode='Int'
begin	
	IF EXISTS(select top 1 P.ObjectId from dbo.ObjectInfo O INNER JOIN dbo.PropertyInt P ON P.ObjectId=O.ObjectId where O.TenantId=@TenantId and P.PropertyIntId=@PropertyId)
		DELETE FROM dbo.PropertyInt WHERE PropertyIntId=@PropertyId
end
ELSE IF @mode='Float'
begin	
	IF EXISTS(select top 1 P.ObjectId from dbo.ObjectInfo O INNER JOIN dbo.PropertyFloat P ON P.ObjectId=O.ObjectId where O.TenantId=@TenantId and P.PropertyFloatId=@PropertyId)
		DELETE FROM dbo.PropertyFloat WHERE PropertyFloatId=@PropertyId
end
ELSE IF @mode='String'
begin	
	IF EXISTS(select top 1 P.ObjectId from dbo.ObjectInfo O INNER JOIN dbo.PropertyString P ON P.ObjectId=O.ObjectId where O.TenantId=@TenantId and P.PropertyStringId=@PropertyId)
		DELETE FROM dbo.PropertyString WHERE PropertyStringId=@PropertyId
end
ELSE IF @mode='BigString'
begin	
	IF EXISTS(select top 1 P.ObjectId from dbo.ObjectInfo O INNER JOIN dbo.PropertyBigString P ON P.ObjectId=O.ObjectId where O.TenantId=@TenantId and P.PropertyBigStringId=@PropertyId)
		DELETE FROM dbo.PropertyBigString WHERE PropertyBigStringId=@PropertyId
end
ELSE
begin
	RAISERROR ('Error (Property_Delete): mode value is incorrect', 16, 0);
end
RETURN 0;
GO
/****** Object:  StoredProcedure [dbo].[PropertyBigString_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PropertyBigString_UpdateInsert]
@TenantId int,
@PropertyId int output,
@ObjectId int,
@SortCode int=0,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@Row int,
@Value varchar(max),
@ValueEpsilon float,-- ignored
@PropertyName varchar(256),
@Comment varchar(256)=null,
@SourceObjectId int=0,
@DeleteOnNullValues bit=0	-- 0 (by default - usage from WebInterface) == user must specify a value; 1 (data export mode) - on NULL values and @Row>0 - delete corresponding cell value (if exists)
AS
SET NOCOUNT ON;
if @SourceObjectId=0
	SET @SourceObjectId=NULL
DECLARE @msg varchar(256)
SET @PropertyId = ISNULL(@PropertyId, 0)
IF @Row<1 AND @Row<>-1
	SET @Row=NULL
IF @ObjectId IS NULL OR @ObjectId=0
begin
	SET @msg = 'Error (PropertyBigString_UpdateInsert): ObjectId must be set [@PropertyName='+ISNULL(@PropertyName,'NULL')+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @PropertyName IS NULL OR LEN(@PropertyName)<1
begin
	RAISERROR ('Error (PropertyBigString_UpdateInsert): PropertyName must be set', 16, 0);
	RETURN 0;
end
IF NOT EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
	SET @msg = 'Error (PropertyBigString_UpdateInsert): ObjectId must be in the same tenant [@TenantId='+CAST(@TenantId as varchar(8))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF (@Value IS NULL OR LEN(@Value)<1) AND @DeleteOnNullValues=0
begin
	SET @msg = 'Error (PropertyBigString_UpdateInsert): Value must be set [@PropertyName='+@PropertyName+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
ELSE IF (@Value IS NULL OR LEN(@Value)<1) AND @DeleteOnNullValues=1	-- DELETE
begin
	if @Row>0
		DELETE FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		DELETE FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
	RETURN 0;
end

DECLARE @newPropertyId int
if @PropertyId>0
	SELECT top 1 @newPropertyId=PropertyBigStringId FROM dbo.PropertyBigString WHERE PropertyBigStringId=@PropertyId
if @newPropertyId IS NULL
begin
	if @Row>0
		SELECT top 1 @newPropertyId=PropertyBigStringId FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		SELECT top 1 @newPropertyId=PropertyBigStringId FROM dbo.PropertyBigString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
end
IF @newPropertyId IS NOT NULL -- EXISTS Big
BEGIN
	UPDATE dbo.PropertyBigString SET -- _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, -- TypeId=@TypeId, 
		SortCode=@SortCode, [Row]=@Row, [Value]=@Value, /*ValueEpsilon=@ValueEpsilon, */PropertyName=@PropertyName, Comment=@Comment, SourceObjectId=@SourceObjectId
	WHERE PropertyBigStringId=@newPropertyId
	SET @PropertyId=-@newPropertyId
END
ELSE    -- add record
BEGIN
	INSERT INTO dbo.PropertyBigString (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
		[Row], [Value], /*ValueEpsilon, */PropertyName, Comment, SourceObjectId)
	VALUES (@ObjectId, @SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
		@Row, @Value, /*@ValueEpsilon, */@PropertyName, @Comment, @SourceObjectId)
	SET @PropertyId = SCOPE_IDENTITY()
END
SET NOCOUNT OFF;
--SELECT top 1 * FROM dbo.PropertyBigString WHERE PropertyFloatId=@PropertyId
RETURN @PropertyId
GO
/****** Object:  StoredProcedure [dbo].[PropertyFloat_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PropertyFloat_UpdateInsert]
@TenantId int,
@PropertyId int output,
@ObjectId int,
@SortCode int=0,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@Row int,
@Value float,
@ValueEpsilon float,
@PropertyName varchar(256),
@Comment varchar(256)=null,
@SourceObjectId int=0,
@DeleteOnNullValues bit=0	-- 0 (by default - usage from WebInterface) == user must specify a value; 1 (data export mode) - on NULL values and @Row>0 - delete corresponding cell value (if exists)
AS
SET NOCOUNT ON;
if @SourceObjectId=0
	SET @SourceObjectId=NULL
DECLARE @msg varchar(256)
SET @PropertyId = ISNULL(@PropertyId, 0)
IF @Row<1 AND @Row<>-1
	SET @Row=NULL
IF @ObjectId IS NULL OR @ObjectId=0
begin
	SET @msg = 'Error (PropertyFloat_UpdateInsert): ObjectId must be set [@PropertyName='+ISNULL(@PropertyName,'NULL')+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @PropertyName IS NULL OR LEN(@PropertyName)<1
begin
	RAISERROR ('Error (PropertyFloat_UpdateInsert): PropertyName must be set', 16, 0);
	RETURN 0;
end
IF NOT EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
	SET @msg = 'Error (PropertyFloat_UpdateInsert): ObjectId must be in the same tenant [@TenantId='+CAST(@TenantId as varchar(8))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @Value IS NULL AND @DeleteOnNullValues=0
begin
	SET @msg = 'Error (PropertyFloat_UpdateInsert): Value must be set [@PropertyName='+@PropertyName+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
ELSE IF @Value IS NULL AND @DeleteOnNullValues=1	-- DELETE
begin
	if @Row>0
		DELETE FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		DELETE FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
	RETURN 0;
end
DECLARE @newPropertyId int
if @PropertyId>0
	SELECT top 1 @newPropertyId=PropertyFloatId FROM dbo.PropertyFloat WHERE PropertyFloatId=@PropertyId
if @newPropertyId IS NULL
begin
	if @Row>0
		SELECT top 1 @newPropertyId=PropertyFloatId FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		SELECT top 1 @newPropertyId=PropertyFloatId FROM dbo.PropertyFloat WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
end
IF @newPropertyId IS NOT NULL -- EXISTS 
BEGIN
	UPDATE dbo.PropertyFloat SET -- _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, -- TypeId=@TypeId, 
		SortCode=@SortCode, [Row]=@Row, [Value]=@Value, ValueEpsilon=@ValueEpsilon, PropertyName=@PropertyName, Comment=@Comment, SourceObjectId=@SourceObjectId
	WHERE PropertyFloatId=@newPropertyId
	SET @PropertyId=-@newPropertyId
END
ELSE    -- add record
BEGIN
	INSERT INTO dbo.PropertyFloat (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
		[Row], [Value], ValueEpsilon, PropertyName, Comment, SourceObjectId)
	VALUES (@ObjectId, @SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
		@Row, @Value, @ValueEpsilon, @PropertyName, @Comment, @SourceObjectId)
	SET @PropertyId = SCOPE_IDENTITY()
END
SET NOCOUNT OFF;
--SELECT top 1 * FROM dbo.PropertyFloat WHERE PropertyFloatId=@PropertyId
RETURN @PropertyId
GO
/****** Object:  StoredProcedure [dbo].[PropertyInt_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PropertyInt_UpdateInsert]
@TenantId int,
@PropertyId int output,
@ObjectId int,
@SortCode int=0,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@Row int,
@Value bigint,
@ValueEpsilon float,-- ignored
@PropertyName varchar(256),
@Comment varchar(256)=null,
@SourceObjectId int=0,
@DeleteOnNullValues bit=0	-- 0 (by default - usage from WebInterface) == user must specify a value; 1 (data export mode) - on NULL values and @Row>0 - delete corresponding cell value (if exists)
AS
SET NOCOUNT ON;
if @SourceObjectId=0
	SET @SourceObjectId=NULL
DECLARE @msg varchar(256)
SET @PropertyId = ISNULL(@PropertyId, 0)
IF @Row<1 AND @Row<>-1
	SET @Row=NULL
IF @ObjectId IS NULL OR @ObjectId=0
begin
	SET @msg = 'Error (PropertyInt_UpdateInsert): ObjectId must be set [@PropertyName='+ISNULL(@PropertyName,'NULL')+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @PropertyName IS NULL OR LEN(@PropertyName)<1
begin
	RAISERROR ('Error (PropertyInt_UpdateInsert): PropertyName must be set', 16, 0);
	RETURN 0;
end
IF NOT EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
	SET @msg = 'Error (PropertyInt_UpdateInsert): ObjectId must be in the same tenant [@TenantId='+CAST(@TenantId as varchar(8))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @Value IS NULL AND @DeleteOnNullValues=0
begin
	SET @msg = 'Error (PropertyInt_UpdateInsert): Value must be set [@PropertyName='+@PropertyName+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
ELSE IF @Value IS NULL AND @DeleteOnNullValues=1	-- DELETE
begin
	if @Row>0
		DELETE FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		DELETE FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
	RETURN 0;
end

DECLARE @newPropertyId int
if @PropertyId>0
	SELECT top 1 @newPropertyId=PropertyIntId FROM dbo.PropertyInt WHERE PropertyIntId=@PropertyId
if @newPropertyId IS NULL
begin
	if @Row>0
		SELECT top 1 @newPropertyId=PropertyIntId FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		SELECT top 1 @newPropertyId=PropertyIntId FROM dbo.PropertyInt WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
end
IF @newPropertyId IS NOT NULL -- EXISTS 
BEGIN
	UPDATE dbo.PropertyInt SET -- _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, -- TypeId=@TypeId, 
		SortCode=@SortCode, [Row]=@Row, [Value]=@Value, /*ValueEpsilon=@ValueEpsilon, */PropertyName=@PropertyName, Comment=@Comment, SourceObjectId=@SourceObjectId
	WHERE PropertyIntId=@newPropertyId
	SET @PropertyId=-@newPropertyId
END
ELSE    -- add record
BEGIN
	INSERT INTO dbo.PropertyInt (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
		[Row], [Value], /*ValueEpsilon, */PropertyName, Comment, SourceObjectId)
	VALUES (@ObjectId, @SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
		@Row, @Value, /*@ValueEpsilon, */@PropertyName, @Comment, @SourceObjectId)
	SET @PropertyId = SCOPE_IDENTITY()
END
SET NOCOUNT OFF;
--SELECT top 1 * FROM dbo.PropertyInt WHERE PropertyFloatId=@PropertyId
RETURN @PropertyId
GO
/****** Object:  StoredProcedure [dbo].[PropertyString_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PropertyString_UpdateInsert]
@TenantId int,
@PropertyId int output,
@ObjectId int,
@SortCode int=0,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@Row int,
@Value varchar(4096),
@ValueEpsilon float,-- ignored
@PropertyName varchar(256),
@Comment varchar(256)=null,
@SourceObjectId int=0,
@DeleteOnNullValues bit=0	-- 0 (by default - usage from WebInterface) == user must specify a value; 1 (data export mode) - on NULL values and @Row>0 - delete corresponding cell value (if exists)
AS
SET NOCOUNT ON;
if @SourceObjectId=0
	SET @SourceObjectId=NULL
DECLARE @msg varchar(256)
SET @PropertyId = ISNULL(@PropertyId, 0)
IF @Row<1 AND @Row<>-1
	SET @Row=NULL
IF @ObjectId IS NULL OR @ObjectId=0
begin
	SET @msg = 'Error (PropertyString_UpdateInsert): ObjectId must be set [@PropertyName='+ISNULL(@PropertyName,'NULL')+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF @PropertyName IS NULL OR LEN(@PropertyName)<1
begin
	RAISERROR ('Error (PropertyString_UpdateInsert): PropertyName must be set', 16, 0);
	RETURN 0;
end
IF NOT EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
	SET @msg = 'Error (PropertyString_UpdateInsert): ObjectId must be in the same tenant [@TenantId='+CAST(@TenantId as varchar(8))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
IF (@Value IS NULL OR LEN(@Value)<1) AND @DeleteOnNullValues=0
begin
	SET @msg = 'Error (PropertyString_UpdateInsert): Value must be set [@PropertyName='+@PropertyName+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
ELSE IF (@Value IS NULL OR LEN(@Value)<1) AND @DeleteOnNullValues=1	-- DELETE
begin
	if @Row>0
		DELETE FROM dbo.PropertyString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		DELETE FROM dbo.PropertyString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
	RETURN 0;
end

DECLARE @newPropertyId int
if @PropertyId>0
	SELECT top 1 @newPropertyId=PropertyStringId FROM dbo.PropertyString WHERE PropertyStringId=@PropertyId
if @newPropertyId IS NULL
begin
	if @Row>0
		SELECT top 1 @newPropertyId=PropertyStringId FROM dbo.PropertyString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row]=@Row
	else if @Row IS NULL
		SELECT top 1 @newPropertyId=PropertyStringId FROM dbo.PropertyString WHERE ObjectId=@ObjectId AND PropertyName=@PropertyName AND [Row] IS NULL
end
IF @newPropertyId IS NOT NULL -- EXISTS 
BEGIN
	UPDATE dbo.PropertyString SET -- _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, -- TypeId=@TypeId, 
		SortCode=@SortCode, [Row]=@Row, [Value]=@Value, /*ValueEpsilon=@ValueEpsilon, */PropertyName=@PropertyName, Comment=@Comment, SourceObjectId=@SourceObjectId
	WHERE PropertyStringId=@newPropertyId
	SET @PropertyId=-@newPropertyId
END
ELSE    -- add record
BEGIN
	INSERT INTO dbo.PropertyString (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy,
		[Row], [Value], /*ValueEpsilon, */PropertyName, Comment, SourceObjectId)
	VALUES (@ObjectId, @SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/,
		@Row, @Value, /*@ValueEpsilon, */@PropertyName, @Comment, @SourceObjectId)
	SET @PropertyId = SCOPE_IDENTITY()
END
SET NOCOUNT OFF;
--SELECT top 1 * FROM dbo.PropertyString WHERE PropertyFloatId=@PropertyId
RETURN @PropertyId
GO
/****** Object:  StoredProcedure [dbo].[RubricInfo_Delete]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[RubricInfo_Delete]
@TenantId int,
@RubricId int
AS
-- EXEC dbo.RubricInfo_Delete 3
BEGIN
	SET NOCOUNT ON;
	if EXISTS(select ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND RubricId=@RubricId)
	begin 
		RAISERROR  ('Error (RubricInfo_Delete): can''t delete rubric with objects', 16, 0);
	end 
	DECLARE @dt as dbo.Integers;

WITH CTE(RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricPath, RowNum) AS
(
	SELECT RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, ParentId, 
[Level], LeafFlag, Flags, SortCode, IsPublished, AccessControl, RubricName, RubricPath,
		[dbo].[Int2FixedLengthString](ROW_NUMBER() OVER 
			(ORDER BY SortCode ASC, RubricName ASC, RubricId ASC), 8) As RowNum
	FROM dbo.RubricInfo
	WHERE TenantId=@TenantId AND RubricId=@RubricId
	UNION ALL
	SELECT FPI.RubricId, FPI.TenantId, FPI._created, FPI._createdBy, FPI._updated, FPI._updatedBy, FPI.TypeId, FPI.ParentId, 
FPI.[Level], FPI.LeafFlag, FPI.Flags, FPI.SortCode, FPI.IsPublished, FPI.AccessControl, FPI.RubricName, FPI.RubricPath, 
		T.RowNum+'.'+[dbo].[Int2FixedLengthString](ROW_NUMBER() 
			OVER (ORDER BY FPI.SortCode ASC, FPI.RubricName ASC, FPI.RubricId ASC), 8) 
			As RowNum
	FROM dbo.RubricInfo AS FPI
			INNER JOIN CTE As T ON T.RubricId=FPI.ParentId
)
INSERT INTO @dt([Value]) SELECT RubricId FROM CTE ORDER BY RowNum
	DECLARE @TypeId int
	SELECT @TypeId=TypeId FROM dbo.RubricInfo WHERE RubricId=@RubricId
	SET NOCOUNT OFF;
	DELETE FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricId IN (select [Value] from @dt)
	SET NOCOUNT ON;
	EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeId
	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[RubricInfo_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[RubricInfo_UpdateInsert]
@RubricId int output,
@TenantId int,
@_created datetime,	-- ignored
@_createdBy int,
@_updated datetime,	-- ignored
@_updatedBy int,
@TypeId int,
@ParentId int=0,
@Level int=0, 
@LeafFlag int=0,
@Flags int=0,
@SortCode int=0,
@AccessControl int=0,
@IsPublished bit=1,
@RubricName varchar(256)='',
@RubricNameUrl varchar(256)='',	-- IGNORE
@RubricPath varchar(256)='',	-- IGNORE
@skipOutput bit=0	-- skip final recordset output
AS
-- EXEC dbo.ProcRubric_NormaliseTree 1, 1
SET NOCOUNT ON;
IF @RubricName IS NULL OR LEN(@RubricName)=0
begin
	RAISERROR  ('Error (RubricInfo_UpdateInsert): Name can not be empty', 16, 0);
end
if @ParentId=0 
	SET @ParentId=NULL
DECLARE @RubricPathDB varchar(256), @ParentIdDB int = 0
SELECT @RubricPathDB=RubricPath, @ParentIdDB=ISNULL(ParentId, 0) FROM dbo.RubricInfo WHERE RubricId!=0 AND RubricId=@RubricId
IF @RubricPathDB IS NOT NULL -- EXISTS (SELECT TOP 1 RubricId FROM dbo.RubricInfo WHERE RubricId=@RubricId)
BEGIN
	UPDATE dbo.RubricInfo SET -- TenantId=@TenantId, _created=@_created, _createdBy=@_createdBy, 
		_updated = getdate(), _updatedBy=@_updatedBy, -- TypeId=@TypeId, 
		ParentId=@ParentId, [Level]=@Level, LeafFlag=@LeafFlag, Flags=@Flags, SortCode=@SortCode, 
		AccessControl=@AccessControl, IsPublished=@IsPublished, RubricName=@RubricName--, RubricPath=ISNULL(@RubricPath,'')
	WHERE RubricId=@RubricId
END
ELSE    -- add record
BEGIN
	SET @RubricId=NULL
	SELECT @RubricId = MAX(RubricId)+1 FROM dbo.RubricInfo
	IF @RubricId IS NULL
		SET @RubricId=1
	SET @RubricNameUrl = ISNULL(@RubricNameUrl, '')
	if @RubricNameUrl='' SET @RubricNameUrl = LEFT(dbo.fn_Transliterate4URL(@RubricName), 256)
	INSERT INTO dbo.RubricInfo (RubricId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId,
		ParentId, [Level], LeafFlag, Flags, SortCode, AccessControl, IsPublished, RubricName, RubricNameUrl, RubricPath)
	VALUES(@RubricId, @TenantId, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/, @TypeId,
		@ParentId, @Level, @LeafFlag, @Flags, @SortCode, @AccessControl, @IsPublished, @RubricName, @RubricNameUrl, ISNULL(@RubricPath,''))
END
SET @RubricPath = LEFT(dbo.fn_GetRubricPathStringFull(@RubricId,'}'), 256)
	if @RubricPathDB IS NULL -- new record
	begin
		SET @RubricNameUrl = dbo.fn_GetRubricNameUrl_QuickByParent(@RubricId)
		if LEN(@RubricNameUrl)>256
			SET @RubricNameUrl = LEFT(@RubricNameUrl, 240) + '_' + CAST(@RubricId as varchar(16))
		UPDATE dbo.RubricInfo
			SET RubricPath=@RubricPath, RubricNameUrl=@RubricNameUrl
			WHERE RubricId=@RubricId
		EXEC dbo.ProcRubric_NormaliseTree @TenantId, @TypeId
	end
	else
	begin
		UPDATE dbo.RubricInfo
			SET RubricPath=@RubricPath -- , RubricNameUrl=@RubricNameUrl
			WHERE RubricId=@RubricId
		if @ParentIdDB<>ISNULL(@ParentId, 0)
		begin
			EXEC dbo.ProcRubric_NormaliseTree @TenantId, @TypeId
		end
	end
SET NOCOUNT OFF;
if @skipOutput=0
begin
	SELECT * FROM dbo.RubricInfo WHERE RubricId=@RubricId
end
RETURN @RubricId
GO
/****** Object:  StoredProcedure [dbo].[RubricInfoAdds_Update]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[RubricInfoAdds_Update]
@RubricId int,
@TenantId int,
@RubricText varchar(max)=null
AS
-- EXEC dbo.RubricInfoAdds_Update 47, 1, 'qaz'
IF LTRIM(RTRIM(ISNULL(@RubricText, '')))=''
BEGIN
	DELETE FROM dbo.RubricInfoAdds WHERE RubricId=@RubricId-- AND EXISTS (select RubricId from dbo.RubricInfo WHERE RubricId=@RubricId AND TenantId=@TenantId)
END
ELSE
BEGIN
	UPDATE dbo.RubricInfoAdds SET RubricText=@RubricText WHERE RubricId=@RubricId
	IF @@ROWCOUNT=0
	BEGIN
		INSERT INTO dbo.RubricInfoAdds (RubricId, RubricText)
			VALUES(@RubricId, @RubricText)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[SampleAddLinkedSubSample]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SampleAddLinkedSubSample]
@ObjectId int,	-- input: "parent" object,
@TenantId int,
@_createdBy int,
@TypeId int=6,	-- Sample
@newObjectName varchar(512),
@newObjectDescription varchar(1024),
@TypeValue int=NULL	-- NULL - take from parent (otherwise - as stated)
AS
begin
	DECLARE @newObjectNameUrl varchar(256)
	DECLARE @newObjectId int

	SELECT @newObjectId=MAX(ObjectId)+1 FROM dbo.ObjectInfo
	SET @newObjectNameUrl=LOWER(dbo.fn_Transliterate4URL(dbo.fn_StripHTML(@newObjectName)) + '-' + CAST(@newObjectId as varchar(16)))

	INSERT INTO dbo.ObjectInfo (ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId,  RubricId, 
			SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectDescription)
		SELECT @newObjectId, TenantId, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/, TypeId, RubricId, SortCode,
			AccessControl, IsPublished, ExternalId, @newObjectName, @newObjectNameUrl, null/*@StepObjectFilePath*/, @newObjectDescription
		FROM dbo.ObjectInfo WHERE ObjectId=@ObjectId

	INSERT INTO dbo.[Sample](SampleId, ElemNumber, [Elements])
		SELECT @newObjectId, ElemNumber, [Elements]	
		FROM dbo.[Sample] WHERE SampleId=@ObjectId

	-- copy Type of Sample
	IF @TypeValue IS NULL
	begin
		INSERT INTO dbo.PropertyInt(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment)
			select @newObjectId, SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/, [Row], [Value], PropertyName, Comment
				FROM dbo.PropertyInt where ObjectId=@ObjectId and PropertyName='Type'
	end
	ELSE
	begin
		INSERT INTO dbo.PropertyInt(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment)
			select @newObjectId, SortCode, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/, [Row], @TypeValue as [Value], PropertyName, Comment
				FROM dbo.PropertyInt where ObjectId=@ObjectId and PropertyName='Type'
	end

	INSERT INTO dbo.ObjectLinkObject(ObjectId, LinkedObjectId ,SortCode, _created, _createdBy, _updated, _updatedBy)
		-- bind parent sample
		SELECT @ObjectId, @newObjectId, 0, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/
		-- bind substrate
		UNION ALL
		SELECT @newObjectId, LinkedObjectId, 0, getdate(), @_createdBy, getdate(), @_createdBy/*@_updatedBy*/
			FROM dbo.ObjectLinkObject WHERE ObjectId=@ObjectId and LinkedObjectId IN (select ObjectId from dbo.ObjectInfo where TypeId=5 /*Substrate*/)
	RETURN @newObjectId
end
GO
/****** Object:  StoredProcedure [dbo].[SampleAddProcessingStep]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SampleAddProcessingStep]
@ObjectId int,	-- input: "parent" object,
@TenantId int,
@_createdBy int,
@StepDescription varchar(1024),
@TypeId int=6	-- Sample
AS
SET NOCOUNT ON;
DECLARE @msg varchar(256), @ObjectName varchar(512), @newObjectName varchar(512), @newObjectNameUrl varchar(256)
DECLARE @newObjectId int
	SELECT top 1 @ObjectName=ObjectName from dbo.ObjectInfo where TenantId=@TenantId AND ObjectId=@ObjectId AND TypeId=@TypeId
	IF @ObjectName IS NULL
	begin
		SET @msg = 'Error (SampleAddProcessingStep): Sample not found [ObjectId=' + CAST(@ObjectId as varchar(16)) + ']'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	SET @newObjectName = [dbo].[fn_IncrementVersionInName](@ObjectName)

	EXECUTE @newObjectId = [dbo].[SampleAddLinkedSubSample] @ObjectId, @TenantId, @_createdBy, @TypeId, @newObjectName, @StepDescription
SET NOCOUNT OFF;
SELECT @newObjectId as Res
RETURN @newObjectId
GO
/****** Object:  StoredProcedure [dbo].[SampleSplitIntoPieces]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SampleSplitIntoPieces]
@ObjectId int,	-- input: "parent" object,
@TenantId int,
@_createdBy int,
@PieceDescription varchar(1024),
@PieceCount int,
@TypeId int=6	-- Sample
AS
SET NOCOUNT ON;
DECLARE @msg varchar(256), @ObjectName varchar(512), @newObjectName varchar(512), @newPieceDescription varchar(1024), @newObjectNameUrl varchar(256)
DECLARE @newObjectId int, @i int
	SELECT top 1 @ObjectName=ObjectName from dbo.ObjectInfo where TenantId=@TenantId AND ObjectId=@ObjectId AND TypeId=@TypeId
	IF @ObjectName IS NULL
	begin
		SET @msg = 'Error (SampleSplitIntoPieces): Sample not found [ObjectId=' + CAST(@ObjectId as varchar(16)) + ']'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	IF @PieceCount<2
	begin
		SET @msg = 'Error (SampleSplitIntoPieces): PieceCount is less than 2 [@PieceCount=' + CAST(@PieceCount as varchar(16)) + ']'
		RAISERROR (@msg, 16, 0);
		RETURN 0;
	end
	SET @i = 1

	-- 2024-10-02 calculate vacant @i - begin
	SET @newObjectName = @ObjectName + ' piece ' + CAST(@i as varchar(16))
	WHILE EXISTS(SELECT ObjectId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName=@newObjectName) AND @i<1000
	begin
		SET @i = @i+1
		SET @newObjectName = @ObjectName + ' piece ' + CAST(@i as varchar(16))
	end
	DECLARE @shift int = @i-1
	-- 2024-10-02 calculate vacant @i - end

	WHILE @i<=@PieceCount+@shift
	begin
		SET @newObjectName = @ObjectName + ' piece ' + CAST(@i as varchar(16))
		SET @newPieceDescription = @PieceDescription + ' (piece ' + CAST(@i as varchar(16)) + ')'
		EXECUTE @newObjectId = [dbo].[SampleAddLinkedSubSample] @ObjectId, @TenantId, @_createdBy, @TypeId, @newObjectName, @newPieceDescription, 5 /*Type property*/
		SET @i = @i+1
	end

SET NOCOUNT OFF;
SELECT @newObjectId as Res
RETURN @newObjectId

GO
/****** Object:  StoredProcedure [dbo].[TransferInfProjects]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferInfProjects]
-- SOURCE
@srcDatabase varchar(32)='[RUB_MDI]',	-- mdi.matinf.pro
@srcTenantId int=7,	-- mdi.matinf.pro
@srcRubricPath varchar(256)='Nonindustry}CRC 1625',	-- RubricPath from which we are copying to destination ('}'-separated path)
-- DESTINATION
@dstDatabase varchar(32)='[RUB_CRC1625]',	-- crc1625.mdi.ruhr-uni-bochum.de
@dstTenantId int=4,	-- crc1625.mdi.ruhr-uni-bochum.de
@dstRubricPath varchar(256)='',	-- RubricPath TO which we are copying (empty==root, by default, '}'-separated path)
-- SETTINGS
@dstDefaultUserId int=2		-- some default user (if by Email user can not be found), vic.dudarev@gmail.com
/*
-- ROOT stored procedure:
-- 1: MDI -> CRC1625
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='', @dstDefaultUserId=2
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625}Area A}A01}Ag-Au-Pd-Pt-X', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='Area A}A01}Ag-Au-Pd-Pt-X', @dstDefaultUserId=2
-- 2: MDI -> DEMI
-- EXEC [RUB_DEMI].[dbo].[TransferInfProjects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}ERC DEMI', @dstDatabase='[RUB_DEMI]', @dstTenantId=8, @dstRubricPath='', @dstDefaultUserId=2;
-- Transfers projects from one tenant to another (within a single database server instance)
-- transfers rubrics and after that runs dbo.TransferInfProjects_Objects - to transfer the objects
*/
-- PREREQUISITES: 
-- 1) Types Are Equal (with TypeIds)
-- 2) LinkTypes Objects Are Equal (the same ObjectId for TypeId=-2	-- Link Type)
-- 3) target users are in destination (otherwise @dstDefaultUserId is used)
as
DECLARE @TypeIdRubric int=2		-- Projects (General rubrics)
DECLARE @Separator varchar(16)='}'	-- separator between rubrics
DECLARE @srcRubricPathItem varchar(256), @dstRubricPathItem varchar(256)
DECLARE @CreateRubric bit=1			-- create rubrics by path (0 - no, 1 - yes)
DECLARE @retval int, @AccessControl int, @IsPublished bit;
DECLARE @srcUserId int, @dstUserId int, @srcUpdUserId int, @dstUpdUserId int;
DECLARE @_created datetime, @_updated datetime;
DECLARE @srcRubricId int, @dstRubricId int;
DECLARE @RubricsCountAdded int = 0, @RubricsCountExists int = 0;
DECLARE @ParmDefinition nvarchar(1024), @sqlCommand nvarchar(max)

DECLARE @dtformat as varchar(256)='yyyy-MM-dd HH:mm:ss.FF'
DECLARE @msg as varchar(256)
DECLARE @MaxObjectId int
-- =================================
-- PREREQUISITES
-- =================================
-- 1. check types

IF @dstDatabase<>'[RUB_CRC247]' AND EXISTS (
	select MDI.TypeId as TypeId1, MDI.TypeName as TypeName1, --MDI.TypeComment as Comment1, 
	'|||' as __, 
	O.TypeId as TypeId2, O.TypeName as TypeName2--, O.TypeComment as Comment2 
	from [RUB_MDI].dbo.TypeInfo as MDI
	FULL OUTER JOIN /*RUB_CRC1625.*/dbo.TypeInfo as O ON MDI.TypeId=O.TypeId
	WHERE MDI.TypeId IS NULL OR O.TypeId IS NULL OR MDI.TypeName<>O.TypeName -- OR MDI.IsHierarchical<>O.IsHierarchical OR MDI.TypeIdForRubric<>O.TypeIdForRubric OR MDI.TableName<>o.TableName OR MDI.UrlPrefix<>O.UrlPrefix OR MDI.TypeComment<>O.TypeComment OR MDI.ValidationSchema<>O.ValidationSchema OR MDI.DataSchema<>O.DataSchema OR MDI.SettingsJson<>O.SettingsJson
) 
begin
	SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR - TYPES MISMATCH';
	THROW 50001, @msg, 0;
	PRINT @msg;
end

-- 2. LinkTypes Objects Are Equal (the same ObjectId for TypeId=-2	-- Link Type)
IF EXISTS (
	select MDI.ObjectId as ObjectId1, MDI.ObjectName as ObjectName1,
	'|||' as __, 
	O.ObjectId as ObjectId2, O.ObjectName as ObjectName2--, O.TypeComment as Comment2 
	from [RUB_MDI].dbo.ObjectInfo as MDI
	FULL OUTER JOIN /*RUB_CRC1625.*/dbo.ObjectInfo as O ON MDI.ObjectId=O.ObjectId and O.TypeId=-2
	WHERE MDI.TypeId=-2 and MDI.ObjectID>=-10 and (MDI.ObjectId IS NULL OR O.ObjectId IS NULL OR MDI.ObjectName<>O.ObjectName)
) 
begin
	SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR - LINK OBJECTS MISMATCH [TypeId=-2]';
	THROW 50001, @msg, 0;
	PRINT @msg;
end

-- =================================
-- MAIN JOB
-- =================================
-- 0. TRANSFER Substrates: TypeId=5	(copy notfound Substrates (TypeId=5) from source to destination)
SELECT @MaxObjectId = MAX(ObjectId) FROM /*[RUB_CRC1625].*/dbo.ObjectInfo
SELECT @dstRubricId=RubricId FROM /*[RUB_CRC1625].*/dbo.RubricInfo where RubricNameUrl='service_substrates'
if @dstRubricId is NULL
begin
	SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR - Rubric with RubricNameUrl="service_substrates" was not found';
	THROW 50001, @msg, 0;
	PRINT @msg;
end
INSERT INTO /*[RUB_CRC1625].*/dbo.ObjectInfo (ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription)
	select @MaxObjectId + ROW_NUMBER() OVER (ORDER BY ObjectId) as ObjectId, @dstTenantId, _created, @dstDefaultUserId as _createdBy, _updated, @dstDefaultUserId as _updatedBy, TypeId, @dstRubricId as RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription
		from [RUB_MDI].dbo.ObjectInfo as T1 where ObjectId IN (
		select T1.ObjectId from [RUB_MDI].dbo.ObjectInfo as T1
		FULL OUTER JOIN /*[RUB_CRC1625].*/dbo.ObjectInfo as T2 ON T2.TypeId=5 AND T1.ObjectName=T2.ObjectName
		WHERE T1.TypeId=5 AND T2.ObjectId IS NULL
	)

-- 1. TRANSFER Rubrics: RubricInfo
declare cRubrics cursor local FORWARD_ONLY STATIC for select RubricId, _created, _createdBy, _updated, _updatedBy, AccessControl, IsPublished, RubricPath from [RUB_MDI].dbo.RubricInfo WHERE TenantId=@srcTenantId AND RubricPath LIKE @srcRubricPath+@Separator+'%' order by [Level]
open cRubrics
while (1=1)
begin
	fetch cRubrics into @srcRubricId, @_created, @srcUserId, @_updated, @srcUpdUserId, @AccessControl, @IsPublished, @srcRubricPathItem
	if @@fetch_status <> 0 break
	PRINT FORMAT(getdate(), @dtformat) + ' --- Processing srcRubricId=' + CAST(@srcRubricId as varchar(16)) + ', srcRubricPath=' + @srcRubricPathItem

	-- pure source path withpit prefix
	SET @srcRubricPathItem = RIGHT(@srcRubricPathItem, LEN(@srcRubricPathItem)-LEN(@srcRubricPath)-1)	
	-- destination path
	SET @dstRubricPathItem = @dstRubricPath + IIF(Len(@dstRubricPath)>0, @Separator, '') + @srcRubricPathItem	
	PRINT FORMAT(getdate(), @dtformat) + '     @srcRubricPathItem=' + @srcRubricPathItem + ', @dstRubricPathItem=' + @dstRubricPathItem

	-- 0. detect dstUserId for RUBRIC
	SET @dstUserId = dbo.fn_GetUserId_ByUserIdFromMDI(@srcUserId, @dstDefaultUserId);
	SET @dstUpdUserId = dbo.fn_GetUserId_ByUserIdFromMDI(@srcUpdUserId, @dstDefaultUserId);

	-- transfer rubric
	-- 1.a. try to locate it (if already there)
	SET @dstRubricId=NULL
	SELECT TOP 1 @dstRubricId=RubricId FROM /*[RUB_CRC1625].*/[dbo].RubricInfo WHERE TenantId=@dstTenantId and RubricPath=@dstRubricPathItem
		--SET @ParmDefinition=N'@dstTenantId int, @dstRubricPathItem varchar(256)';
		--SET @sqlCommand='SELECT TOP 1 @dstRubricId=RubricId FROM '+@dstDatabase+'.[dbo].RubricInfo WHERE TenantId=@dstTenantId and RubricPath=@dstRubricPathItem';
		--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @dstTenantId = @dstTenantId, @dstRubricPathItem = @dstRubricPathItem;

	IF @dstRubricId IS NULL	-- not found
	begin
		EXEC @dstRubricId = /*[RUB_CRC1625].*/[dbo].[_GetRubricIdByRubricPath] @dstTenantId, @dstRubricPathItem, @Separator, @CreateRubric, @TypeIdRubric, @dstUserId, @AccessControl, @IsPublished;
			--SET @ParmDefinition=N'@dstTenantId int, @dstRubricPathItem varchar(256), @Separator varchar(16), @CreateRubric bit, @TypeIdRubric int, @dstUserId int, @AccessControl int, @IsPublished bit';
			--SET @sqlCommand='EXEC @dstRubricId = '+@dstDatabase+'.[_GetRubricIdByRubricPath] @dstTenantId, @dstRubricPathItem, @Separator, @CreateRubric, @TypeIdRubric, @dstUserId, @AccessControl, @IsPublished';
			--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @dstTenantId=@dstTenantId, @dstRubricPathItem=@dstRubricPathItem, @Separator=@Separator, @CreateRubric=@CreateRubric, @TypeIdRubric=@TypeIdRubric, @dstUserId=@dstUserId, @AccessControl=@AccessControl, @IsPublished=@IsPublished;
		SET @RubricsCountAdded = @RubricsCountAdded + 1
		PRINT FORMAT(getdate(), @dtformat) + ' ... created dstRubricId=' + CAST(@dstRubricId as varchar(16)) + ', dstRubricPathItem=' + @dstRubricPathItem
	end
	ELSE
	begin
		SET @RubricsCountExists = @RubricsCountExists + 1
		PRINT FORMAT(getdate(), @dtformat) + ' ... exists dstRubricId=' + CAST(@dstRubricId as varchar(16)) + ', dstRubricPathItem=' + @dstRubricPathItem
	end
	-- make the same "metadata" for rubric
	UPDATE /*[RUB_CRC1625].*/[dbo].RubricInfo SET _created=@_created, _createdBy=@dstUserId, _updated=@_updated, _updatedBy=@dstUpdUserId WHERE RubricId=@dstRubricId
	-- 1.b. make proper RubricInfoAdds.@RubricText
	EXEC [dbo].[TransferInfProjects_RubricText] @srcRubricId=@srcRubricId, @dstRubricId=@dstRubricId
end
close cRubrics
deallocate cRubrics
PRINT FORMAT(getdate(), @dtformat) + ' Transfer Projects/Rubrics Complete! Total rubrics: ' + CAST(@RubricsCountExists+@RubricsCountAdded as varchar(16)) + ' (Added: ' + CAST(@RubricsCountAdded as varchar(16)) + '; Exists: ' + CAST(@RubricsCountExists as varchar(16)) + ')'

-- 2. NORMALIZE RUBRIC TREE (after objects and links)
PRINT FORMAT(getdate(), @dtformat) + ' Rubrics Normalization (Preliminary) started...'
EXEC /*[RUB_CRC1625].*/[dbo].[ProcRubric_NormaliseTree] @dstTenantId, @TypeIdRubric
	--SET @ParmDefinition=N'@dstTenantId int, @TypeIdRubric int';
	--SET @sqlCommand='EXEC '+@dstDatabase+'.[dbo].[ProcRubric_NormaliseTree] @dstTenantId, @TypeIdRubric';
	--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @dstTenantId = @dstTenantId, @TypeIdRubric = @TypeIdRubric;
PRINT FORMAT(getdate(), @dtformat) + ' Rubrics Normalization (Preliminary) finished!'

-- 3. here traverse all objects/links in the rubric and transfer them
EXEC [dbo].[TransferInfProjects_Objects] @srcDatabase, @srcTenantId, @srcRubricPath, @dstDatabase, @dstTenantId, @dstRubricPath, @dstDefaultUserId

-- 4. END(Finalize). NORMALIZE RUBRIC TREE (after objects and links)
PRINT FORMAT(getdate(), @dtformat) + ' Rubrics Normalization (Final) started...'
EXEC /*[RUB_CRC1625].*/[dbo].[ProcRubric_NormaliseTree] @dstTenantId, @TypeIdRubric
	--SET @ParmDefinition=N'@dstTenantId int, @TypeIdRubric int';
	--SET @sqlCommand='EXEC '+@dstDatabase+'.[dbo].[ProcRubric_NormaliseTree] @dstTenantId, @TypeIdRubric';
	--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @dstTenantId = @dstTenantId, @TypeIdRubric = @TypeIdRubric;
PRINT FORMAT(getdate(), @dtformat) + ' Rubrics Normalization (Final) finished!'
GO
/****** Object:  StoredProcedure [dbo].[TransferInfProjects_Objects]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferInfProjects_Objects]
-- SOURCE
@srcDatabase varchar(32)='[RUB_MDI]',	-- mdi.matinf.pro
@srcTenantId int=7,	-- mdi.matinf.pro
@srcRubricPath varchar(256)='Nonindustry}CRC 1625',	-- RubricPath from which we are copying to destination ('}'-separated path)
-- DESTINATION
@dstDatabase varchar(32)='[RUB_CRC1625]',	-- crc1625.mdi.ruhr-uni-bochum.de
@dstTenantId int=4,	-- crc1625.mdi.ruhr-uni-bochum.de
@dstRubricPath varchar(256)='',	-- RubricPath TO which we are copying (empty==root, by default, '}'-separated path)
-- SETTINGS
@dstDefaultUserId int=2		-- some default user (if by Email user can not be found), vic.dudarev@gmail.com
/*
-- This is dependant stored procedure (must be run from dbo.TransferInfProjects)
-- 1: MDI -> CRC1625
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='', @dstDefaultUserId=2
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects_Objects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='', @dstDefaultUserId=2
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects_Objects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625}Area A}A01}Ag-Au-Pd-Pt-X', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='Area A}A01}Ag-Au-Pd-Pt-X', @dstDefaultUserId=2
-- EXEC [RUB_CRC1625].[dbo].[TransferInfProjects_Objects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625}Area A}A01', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='Area A}A01', @dstDefaultUserId=2
-- 2: MDI -> DEMI
-- EXEC [RUB_DEMI].[dbo].[TransferInfProjects_Objects] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}ERC DEMI', @dstDatabase='[RUB_DEMI]', @dstTenantId=8, @dstRubricPath='', @dstDefaultUserId=2;
*/
-- PREREQUISITES: 
-- 1) Types Are Equal (with TypeIds)
-- 2) Users are in destination (otherwise @dstDefaultUserId is used)
AS

/*
DECLARE @srcDatabase as varchar(32)='[RUB_MDI]'	-- mdi.matinf.pro
DECLARE @srcTenantId as int=7	-- mdi.matinf.pro
DECLARE @srcRubricPath as varchar(256)='Nonindustry}CRC 1625}Area A}A01}Ag-Au-Pd-Pt-X'	-- RubricPath from which we are copying to destination ('}'-separated path)
-- DESTINATION
DECLARE @dstDatabase varchar(32)='[RUB_CRC1625]'	-- crc1625.mdi.ruhr-uni-bochum.de
DECLARE @dstTenantId int=4	-- crc1625.mdi.ruhr-uni-bochum.de
DECLARE @dstRubricPath varchar(256)='Area A}A01}Ag-Au-Pd-Pt-X'	-- RubricPath TO which we are copying (empty==root, by default, '}'-separated path)
-- SETTINGS
DECLARE @dstDefaultUserId int=2		-- some default user (if by Email user can not be found), vic.dudarev@gmail.com
*/



DECLARE @dtformat as varchar(256)='yyyy-MM-dd HH:mm:ss.FF'
DECLARE @msg as varchar(256)
DECLARE @TypeIdRubric int=2		-- Projects (General rubrics)
DECLARE @Separator varchar(16)='}'	-- separator between rubrics
DECLARE @srcRubricPathItem0 varchar(256), @srcRubricPathItem varchar(256), @srcParentRubricPathItem varchar(256), @dstRubricPathItem varchar(256)
DECLARE @CreateRubric bit=1			-- create rubrics by path (0 - no, 1 - yes)
DECLARE @retval int, @AccessControl int, @IsPublished bit, @mode int;
DECLARE @srcUserId int, @dstUserId int, @dstUserId_updated int;
DECLARE @srcRubricId int, @dstRubricId int;
DECLARE @ObjectsCountAdded int = 0, @ObjectsCountExists int = 0;
DECLARE @ObjectLinksCountAdded int = 0, @ObjectLinksCountUpdated int = 0;
DECLARE @RowsCount int
DECLARE @dstRubricIdParent int	-- destination RubricId for "Parent" object

DECLARE @RubricsCountAdded int = 0
DECLARE @RChild_created datetime, @RChild_createdBy int, @RChild_updated datetime, @RChild_updatedBy int

DECLARE @oObjectId int, @oTenantId int, @o_created datetime, @o_createdBy int, @o_updated datetime, @o_updatedBy int, @oTypeId int, @oRubricId int, @oSortCode int, @oAccessControl int, @oIsPublished int, @oExternalId int, @oObjectName varchar(512), @oObjectNameUrl varchar(256), @oObjectFilePath varchar(256), @oObjectFileHash varchar(128), @oObjectDescription varchar(1024), @oRubricPath varchar(256)
DECLARE @dstObjectId int, @dstObject_RubricId int;
DECLARE @dstObjectLinkRubricId int, @l_created datetime

--DECLARE @Linked_ObjectsCountAdded int = 0, @Linked_ObjectsCountExists int = 0;
--DECLARE @Linked_ObjectLinksCountAdded int = 0, @Linked_ObjectLinksCountUpdated int = 0;
DECLARE @ParmDefinition nvarchar(1024), @sqlCommand nvarchar(max)
DECLARE @dstTypeId int, @dstObjectName varchar(512), @transferObjectType varchar(64)



BEGIN TRY
PRINT FORMAT(getdate(), @dtformat) + ' === START TransferInfProjects_Objects'

-- Create a table of distinct objects to transfer
DROP TABLE IF EXISTS dbo._TransferInfProjects;
--select * into dbo._TransferInfProjects from @Objects;
--select * from dbo._TransferInfProjects
--DECLARE @Objects AS TABLE (srcObjectId int, dstObjectId int, TypeId int, srcRubricId int, dstRubricId int, dstUserId int, step int, comment varchar(256));
CREATE TABLE dbo._TransferInfProjects (Id int identity, dt datetime DEFAULT GETDATE(), srcObjectId int, dstObjectId int, TypeId int, srcRubricId int, dstRubricId int, dstUserId int, step int, [action] varchar(64), comment varchar(1024));
-- TypeId=5 == Prerequisite: Substrates & link types Objects must be added to form proper connections
INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step)
	select Src.ObjectId as srcObjectId, -- Src.ObjectName as srcObjectName, 
			Dst.ObjectId as dstObjectId, -- Dst.ObjectName as dstObjectName
			Src.TypeId,					-- TypeId must be the same in both databases!!!
			Src.RubricId,				-- source database rubricId
			Dst.RubricId,				-- destination database rubricId
			dst._createdBy,				-- destination author: UserId
			0 as step
	from RUB_MDI.dbo.ObjectInfo as Src 
	INNER JOIN dbo.ObjectInfo as Dst ON Dst.TypeId=5 AND Src.ObjectName=Dst.ObjectName 
	WHERE Src.TypeId=5
		UNION ALL
	select Src.ObjectId as srcObjectId, -- Src.ObjectName as srcObjectName, 
			Dst.ObjectId as dstObjectId, -- Dst.ObjectName as dstObjectName
			Src.TypeId,					-- TypeId must be the same in both databases!!!
			Src.RubricId,				-- source database rubricId
			Dst.RubricId,				-- destination database rubricId
			dst._createdBy,				-- destination author: UserId
			0 as step
	from RUB_MDI.dbo.ObjectInfo as Src 
	INNER JOIN dbo.ObjectInfo as Dst ON Dst.TypeId=-2 AND Src.ObjectName=Dst.ObjectName 
	WHERE Src.TypeId=-2

select @RowsCount=count(*) from dbo._TransferInfProjects
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 1: Traversing rubrics started... @dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'
-- RubricInfo: traverse all source rubrics
declare cRubrics cursor local FORWARD_ONLY STATIC for select RubricId, _createdBy, AccessControl, IsPublished, RubricPath from [RUB_MDI].dbo.RubricInfo WHERE TenantId=@srcTenantId 
	AND (RubricPath LIKE @srcRubricPath+@Separator+'%'-- OR RubricPath=@srcRubricPath
	OR RubricPath=@srcRubricPath	-- 2024-09-19 Added (case with sample 10158 transfer)
	) order by [Level]
open cRubrics
while (1=1)
begin
	fetch cRubrics into @srcRubricId, @srcUserId, @AccessControl, @IsPublished, @srcRubricPathItem0
	if @@fetch_status <> 0 break
	PRINT FORMAT(getdate(), @dtformat) + ' --- Processing RUBRIC srcRubricId=' + CAST(@srcRubricId as varchar(16)) + ', srcRubricPath=' + @srcRubricPathItem0

-- RubricPath detection-lite BEGIN
	-- pure source path without prefix
	SET @srcRubricPathItem = IIF(@srcRubricPathItem0=@srcRubricPath, 
		'',
		RIGHT(@srcRubricPathItem0, LEN(@srcRubricPathItem0)-LEN(@srcRubricPath)-1)
		)
	-- destination path
	SET @dstRubricPathItem = @dstRubricPath + IIF(Len(@dstRubricPath)>0 and len(@srcRubricPathItem)>0, @Separator, '') + @srcRubricPathItem	
	PRINT FORMAT(getdate(), @dtformat) + '     @srcRubricPathItem=' + @srcRubricPathItem + ', @dstRubricPathItem=' + @dstRubricPathItem

	SET @dstRubricId=NULL
	SELECT TOP 1 @dstRubricId=RubricId, @dstUserId=_createdBy FROM /*[RUB_CRC1625].*/[dbo].RubricInfo WHERE TenantId=@dstTenantId and RubricPath=@dstRubricPathItem
	IF @dstRubricId IS NULL AND LEN(@dstRubricPathItem)>0
	begin
		SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR - Rubric was not created [dstRubricPathItem=' + @dstRubricPathItem + ', srcRubricPathItem0=' + @srcRubricPathItem0 + ']';
		THROW 50001, @msg, 0;
		PRINT @msg;
	end
-- RubricPath detection-lite - END
		SET @dstUserId=dbo.fn_GetUserId_ByUserIdFromMDI(@o_createdBy, @dstDefaultUserId);
	INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action], comment)
		VALUES (NULL, NULL, NULL, @srcRubricId, @dstRubricId, @dstUserId, NULL, '', 'start processing in dbo.TransferInfProjects_Objects: ' + @srcRubricPathItem0 + ' => ' + @dstRubricPathItem)
	-- here traverse all physical objects and links in the rubric and transfer them
-- a. Physical objects, located in the rubric
	declare cObjects cursor local FORWARD_ONLY STATIC for
    SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId,  OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
			, RI.RubricPath, 'a. Physical objects' as TransferObjectType
		FROM [RUB_MDI].dbo.ObjectInfo as OI
		INNER JOIN [RUB_MDI].dbo.RubricInfo as RI ON OI.RubricId=RI.RubricId
			WHERE OI.TenantId=@srcTenantId AND OI.RubricId=@srcRubricId
	UNION
-- b. References of objects in a rubric (links via ObjectLinkRubric)
	SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, RI.RubricId, OLR.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
			, RI.RubricPath, 'b. References of objects' as TransferObjectType
		FROM [RUB_MDI].dbo.ObjectInfo as OI
		INNER JOIN [RUB_MDI].dbo.ObjectLinkRubric as OLR ON OLR.RubricId=@srcRubricId AND OI.ObjectId=OLR.ObjectId
		INNER JOIN [RUB_MDI].dbo.RubricInfo as RI ON OLR.RubricId=RI.RubricId
		WHERE OI.TenantId=@srcTenantId
/*
	UNION ALL
-- c. One level of nested objects (links via ObjectLinkObject to the upper ones a+b)
    SELECT OI.ObjectId, OI.TenantId, OI._created, OI._createdBy, OI._updated, OI._updatedBy, OI.TypeId, OI.RubricId,  OI.SortCode, OI.AccessControl, OI.IsPublished, OI.ExternalId, OI.ObjectName, OI.ObjectNameUrl, OI.ObjectFilePath, OI.ObjectFileHash, OI.ObjectDescription 
			, RI.RubricPath
		FROM [RUB_MDI].dbo.ObjectInfo as OI
		INNER JOIN [RUB_MDI].dbo.RubricInfo as RI ON OI.RubricId=RI.RubricId
		WHERE OI.TenantId=@srcTenantId AND OI.ObjectId IN (-- a + b
			select LinkedObjectId from [RUB_MDI].dbo.ObjectLinkObject where ObjectId IN (
				-- a. Physical objects, located in the rubric
				SELECT OI.ObjectId FROM [RUB_MDI].dbo.ObjectInfo as OI
				WHERE OI.TenantId=@srcTenantId AND OI.RubricId=@srcRubricId
					UNION ALL
				-- b. References of objects in rubric (links via ObjectLinkRubric)
				SELECT OI.ObjectId FROM [RUB_MDI].dbo.ObjectInfo as OI
				INNER JOIN [RUB_MDI].dbo.ObjectLinkRubric as OLR ON OI.ObjectId=OLR.ObjectId
				WHERE OI.TenantId=@srcTenantId AND OLR.RubricId=@srcRubricId
			)
		)
*/
	ORDER BY ObjectId	-- SortCode, ObjectName

	open cObjects
	while (1=1)
	begin
		fetch cObjects into @oObjectId, @oTenantId, @o_created, @o_createdBy, @o_updated, @o_updatedBy, @oTypeId, @oRubricId, @oSortCode, @oAccessControl, @oIsPublished, @oExternalId, @oObjectName, @oObjectNameUrl, @oObjectFilePath, @oObjectFileHash, @oObjectDescription, @oRubricPath, @transferObjectType
		if @@fetch_status <> 0 break
		
-- === Object-Transfer COPY 1 - begin
		SET @dstObjectId=NULL
		-- try to find object in destination database by (TypeId, ObjectName)
		SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and TypeId=@oTypeId AND UPPER(ObjectName)=UPPER(@oObjectName)
		IF @dstObjectId IS NULL	-- NOT EXIST	=> try to find by ObjectNameUrl
		begin
			SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId, 
				@dstTypeId=TypeId, @dstObjectName=ObjectName 
			FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and ObjectNameUrl=@oObjectNameUrl
			IF @dstObjectId IS NOT NULL 
				PRINT 'WARNING-USER_ERROR: ObjectUrl MATCH ' + @oObjectNameUrl + ' (srcTypeId=' + CAST(@oTypeId as varchar(16)) + ', srcObjectName="' + @oObjectName + '") == (dstTypeId=' + CAST(@dstTypeId as varchar(16)) + ', dstObjectName="' + @dstObjectName + '")'
		end
		IF @dstObjectId IS NULL	-- NOT EXIST	=> try to find by ObjectFileHash
		begin
			SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId, 
				@dstTypeId=TypeId, @dstObjectName=ObjectName 
			FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and ObjectFileHash=@oObjectFileHash
			IF @dstObjectId IS NOT NULL 
				PRINT 'WARNING-USER_ERROR: ObjectFileHash MATCH ' + @oObjectFileHash + ' (srcTypeId=' + CAST(@oTypeId as varchar(16)) + ', srcObjectName="' + @oObjectName + '") == (dstTypeId=' + CAST(@dstTypeId as varchar(16)) + ', dstObjectName="' + @dstObjectName + '")'
		end

		SET @dstUserId=dbo.fn_GetUserId_ByUserIdFromMDI(@o_createdBy, @dstDefaultUserId);

-- Transfer Object (CREATE PHYSICALLY _OR_ IF EXISTS - place a link to rubric)
		PRINT FORMAT(getdate(), @dtformat) + ' --- Processing object ' + @oObjectName + ' [dstObjectId=' + CAST(@dstObjectId as varchar(16)) + ', oObjectId=' + CAST(@oObjectId as varchar(16)) + ', oRubricPath=' + @oRubricPath + ', oTypeId=' + CAST(@oTypeId as varchar(16)) + ']'
		IF @dstObjectId IS NULL	-- NOT EXIST
		begin -- ADD PHYSICAL OBJECT

			-- CHECK For possible unique index conflicts (ObjectNameUrl, ObjectFileHash) - begin
			begin
				select top 1 @dstObjectId=ObjectId from /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE ObjectNameUrl=@oObjectNameUrl
				if @dstObjectId IS NOT NULL
				begin
					SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR: Object in destination database was not found by name "' + @oObjectName + '" and TypeId=' + CAST(@oTypeId as varchar(16)) + '. But there is an object with matching ObjectNameUrl="' + @oObjectNameUrl + '", dstObjectId=' + CAST(@dstObjectId as varchar(16));
					THROW 50001, @msg, 0;
					PRINT @msg;
				end
				IF @oObjectFileHash IS NOT NULL AND @dstObjectId IS NULL
				begin 
					select top 1 @dstObjectId=ObjectId from /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE ObjectFileHash=@oObjectFileHash
					if @dstObjectId IS NOT NULL
					begin
						SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR: Object in destination database was not found by name "' + @oObjectName + '" and TypeId=' + CAST(@oTypeId as varchar(16)) + '. But there is an object with matching ObjectFileHash="' + @oObjectFileHash + '", dstObjectId=' + CAST(@dstObjectId as varchar(16));
						THROW 50001, @msg, 0;
						PRINT @msg;
					end
				end
			end
			-- CHECK For possible unique index conflicts (ObjectNameUrl, ObjectFileHash) - end

			-- 0. detect dstUserId for OBJECT
			--EXEC dbo.GetCrossDBUserId @srcDatabase, @o_createdBy, @dstDatabase, @dstUserId output;
			--SET @dstUserId=ISNULL(@dstUserId, @dstDefaultUserId);
			SET @dstUserId_updated=dbo.fn_GetUserId_ByUserIdFromMDI(@o_updatedBy, @dstDefaultUserId);
			-- Get Next free ObjectId for @dstObjectId
			SELECT @dstObjectId = MAX(ObjectId)+1 FROM /*[RUB_CRC1625].*/dbo.ObjectInfo
			IF @dstObjectId IS NULL SET @dstObjectId=1
			-- INSERT
			INSERT INTO /*[RUB_CRC1625].*/[dbo].ObjectInfo(ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription)
				VALUES(@dstObjectId, @dstTenantId, @o_created, @dstUserId, @o_updated, @dstUserId_updated, @oTypeId, @dstRubricId, @oSortCode, @oAccessControl, @oIsPublished, @oExternalId, @oObjectName, @oObjectNameUrl, @oObjectFilePath, @oObjectFileHash, @oObjectDescription)
			SET @ObjectsCountAdded = @ObjectsCountAdded + 1
			-- table variable to make objects relations and stats
			-- Add (srcObjectId, dstObjectId) to a @List
			IF NOT EXISTS (select top 1 srcObjectId from dbo._TransferInfProjects where srcObjectId=@oObjectId)
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (@oObjectId, @dstObjectId, @oTypeId, @srcRubricId, @dstRubricId, @dstUserId, 10, @transferObjectType + ' added')
			ELSE
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (NULL, NULL, NULL, NULL, NULL, NULL, 10, 'ALREADY EXISTS srcObjectId=' + CAST(@oObjectId as varchar(16)))
		end
		ELSE	-- EXIST => Check PATH
		begin
			IF @dstObject_RubricId<>@dstRubricId	-- object/link is in another rubric => create link
			begin
				SET @dstObjectLinkRubricId=NULL;
				SET @l_created=NULL;
				select @dstObjectLinkRubricId=ObjectLinkRubricId, @l_created=_created from /*[RUB_CRC1625].*/dbo.ObjectLinkRubric WHERE ObjectId=@dstObjectId and RubricId=@dstRubricId
				IF @dstObjectLinkRubricId IS NULL
				begin
					INSERT INTO /*[RUB_CRC1625].*/dbo.ObjectLinkRubric(RubricId, ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy)
						VALUES(@dstRubricId, @dstObjectId, @oSortCode, getdate(), @dstUserId, getdate(), @dstUserId)
					SET @ObjectLinksCountAdded = @ObjectLinksCountAdded + 1
				end
				ELSE
				begin
					UPDATE /*[RUB_CRC1625].*/dbo.ObjectLinkRubric SET SortCode=@oSortCode, _createdBy=@dstUserId, _updatedBy=@dstUserId, _updated=getdate() 
						WHERE ObjectLinkRubricId=@dstObjectLinkRubricId
					SET @ObjectLinksCountUpdated = @ObjectLinksCountUpdated + 1
				end
			end
			SET @ObjectsCountExists = @ObjectsCountExists + 1
			-- table variable to make objects relations and stats
			-- Add (srcObjectId, dstObjectId) to a @List
			IF NOT EXISTS (select top 1 srcObjectId from dbo._TransferInfProjects where srcObjectId=@oObjectId)
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (@oObjectId, @dstObjectId, @oTypeId, @srcRubricId, @dstRubricId, @dstUserId, 10, @transferObjectType + ' exists')
			ELSE
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (NULL, NULL, NULL, NULL, NULL, NULL, 10, 'ALREADY EXISTS srcObjectId=' + CAST(@oObjectId as varchar(16)))
		end

-- === Object-Transfer COPY 1 - END

	end
	close cObjects
	deallocate cObjects
	-- it's wise to add all linked objects to those added
end
close cRubrics
deallocate cRubrics
select @RowsCount=count(*) from dbo._TransferInfProjects
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 1: Traversing rubrics finished... dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'


-- it's better to dig one level deeper through associations (sometimes only links for samples are placed and not all characterisation documents) - BEGIN
SET @transferObjectType = 'c. Associations of objects'
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 2: Dig one level deeper through associations started... dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'
	declare cObjects cursor local FORWARD_ONLY STATIC for
	SELECT ChildObjectId, ChildTenantId, Child_created, Child_createdBy, Child_updated, Child_updatedBy, ChildTypeId, ChildRubricId, ChildSortCode, ChildAccessControl, 
		ChildIsPublished, ChildExternalId, ChildObjectName, ChildObjectNameUrl, ChildObjectFilePath, ChildObjectFileHash, ChildObjectDescription, 
		RParent.RubricPath, RChild.RubricPath, L.dstRubricId/*fallback*/
			, RChild._created, RChild._createdBy, RChild._updated, RChild._updatedBy
		FROM dbo._TransferInfProjects as L
		INNER JOIN [RUB_MDI].[dbo].[vObjectLinkObject] as O ON L.srcObjectId=O.ParentObjectId
		INNER JOIN [RUB_MDI].dbo.RubricInfo as RChild ON RChild.RubricId=O.ChildRubricId	-- this is preferrable
		INNER JOIN [RUB_MDI].dbo.RubricInfo as RParent ON RParent.RubricId=O.ParentRubricId
		WHERE ParentTypeId<>5 AND ChildTypeId<>5	-- without substrates (they are considered above)
			AND ChildObjectId NOT IN (select srcObjectId from dbo._TransferInfProjects)	-- these were already transferred (see above)
		ORDER BY ChildObjectId
	open cObjects
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 2: Dig one level deeper through associations cursor opened...'
	while (1=1)
	begin
		SET @dstRubricIdParent=NULL
		fetch cObjects into @oObjectId, @oTenantId, @o_created, @o_createdBy, @o_updated, @o_updatedBy, @oTypeId, @oRubricId, @oSortCode, @oAccessControl, @oIsPublished, @oExternalId, @oObjectName, @oObjectNameUrl, @oObjectFilePath, @oObjectFileHash, @oObjectDescription, 
			@srcParentRubricPathItem, @srcRubricPathItem, @dstRubricIdParent
			, @RChild_created, @RChild_createdBy, @RChild_updated, @RChild_updatedBy
		if @@fetch_status <> 0 break
		
-- detect "Best possible" rubric - BEGIN
		SET @dstRubricId = NULL
		if LEFT(@srcRubricPathItem, LEN(@srcRubricPath)+1) = @srcRubricPath+@Separator		-- object is somewhere in the known path (that was copied)
		begin
			-- pure source path within prefix (already processed, rubrics are created)
			SET @srcRubricPathItem = RIGHT(@srcRubricPathItem, LEN(@srcRubricPathItem)-LEN(@srcRubricPath)-1)	
			-- destination path
			SET @dstRubricPathItem = @dstRubricPath + IIF(Len(@dstRubricPath)>0, @Separator, '') + @srcRubricPathItem	
			select @dstRubricId=RubricId from /*[RUB_CRC1625].*/[dbo].RubricInfo WHERE TenantId=@dstTenantId and RubricPath=@dstRubricPathItem
			PRINT FORMAT(getdate(), @dtformat) + '     "Best possible" rubric: @srcRubricPathItem=' + @srcRubricPathItem + ', @dstRubricPathItem=' + @dstRubricPathItem + ', @dstRubricId=' + CAST(@dstRubricId as varchar(16))
		end
		ELSE	-- difficult => some OTHER path => Fallback: take path from the original PARENT object
		begin
			if @srcParentRubricPathItem=@srcRubricPathItem	-- The same rubric (we have it)!
			begin
				SET @dstRubricId = @dstRubricIdParent
				PRINT FORMAT(getdate(), @dtformat) + '     "Best possible" rubric: The same rubric (we have it)! @srcRubricPathItem=' + @srcRubricPathItem + ', @dstRubricPathItem=' + @dstRubricPathItem + ', @dstRubricId=' + CAST(@dstRubricId as varchar(16))
			end
			else	-- other rubric
			begin
				if len(@srcRubricPathItem)>len(@srcParentRubricPathItem) AND LEFT(@srcRubricPathItem, LEN(@srcParentRubricPathItem)+1)=@srcParentRubricPathItem + @Separator
				begin
					DECLARE @RubricPathParent varchar(256)
					SELECT top 1 @RubricPathParent = RubricPath FROM dbo.RubricInfo WHERE RubricId=@dstRubricIdParent
					SET @dstRubricPathItem = @RubricPathParent + RIGHT(@srcRubricPathItem, LEN(@srcRubricPathItem)-LEN(@srcParentRubricPathItem))
					-- @oRubricId	// RChild.RubricId=O.ChildRubricId
					SELECT TOP 1 @dstRubricId=RubricId FROM /*[RUB_CRC1625].*/[dbo].RubricInfo WHERE TenantId=@dstTenantId and RubricPath=@dstRubricPathItem
					IF @dstRubricId IS NULL	-- not found
					begin
						EXEC @dstRubricId = /*[RUB_CRC1625].*/[dbo].[_GetRubricIdByRubricPath] @dstTenantId, @dstRubricPathItem, @Separator, @CreateRubric, @TypeIdRubric, @dstUserId, @AccessControl, @IsPublished;
							--SET @ParmDefinition=N'@dstTenantId int, @dstRubricPathItem varchar(256), @Separator varchar(16), @CreateRubric bit, @TypeIdRubric int, @dstUserId int, @AccessControl int, @IsPublished bit';
							--SET @sqlCommand='EXEC @dstRubricId = '+@dstDatabase+'.[_GetRubricIdByRubricPath] @dstTenantId, @dstRubricPathItem, @Separator, @CreateRubric, @TypeIdRubric, @dstUserId, @AccessControl, @IsPublished';
							--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @dstTenantId=@dstTenantId, @dstRubricPathItem=@dstRubricPathItem, @Separator=@Separator, @CreateRubric=@CreateRubric, @TypeIdRubric=@TypeIdRubric, @dstUserId=@dstUserId, @AccessControl=@AccessControl, @IsPublished=@IsPublished;
						SET @RubricsCountAdded = @RubricsCountAdded + 1
						PRINT FORMAT(getdate(), @dtformat) + ' ... "Best possible" rubric: created dstRubricId=' + CAST(@dstRubricId as varchar(16)) + ', dstRubricPathItem=' + @dstRubricPathItem + ' [srcRubricPathItem=' + @srcRubricPathItem + ', RubricPathParent=' + @RubricPathParent + ']'
					end
					UPDATE /*[RUB_CRC1625].*/[dbo].RubricInfo SET _created=@RChild_created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(@RChild_createdBy, @dstDefaultUserId), _updated=@RChild_updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(@RChild_updatedBy, @dstDefaultUserId) WHERE RubricId=@dstRubricId
					-- 1.b. make proper RubricInfoAdds.@RubricText
					EXEC [dbo].[TransferInfProjects_RubricText] @srcRubricId=@oRubricId, @dstRubricId=@dstRubricId

				end
				ELSE	-- Fallback
				begin
					SET @dstRubricId = @dstRubricIdParent
					PRINT FORMAT(getdate(), @dtformat) + '     "Best possible" rubric: Fallback(@srcParentRubricPathItem=' + @srcParentRubricPathItem + ', @srcRubricPathItem=' + @srcRubricPathItem + ') @dstRubricId=' + CAST(@dstRubricId as varchar(16))
				end
			end
		end
-- detect "Best possible" rubric - END

-- === Object-Transfer COPY 2 - BEGIN
		SET @dstObjectId=NULL
		-- try to find object
		SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and TypeId=@oTypeId AND UPPER(ObjectName)=UPPER(@oObjectName)
		IF @dstObjectId IS NULL	-- NOT EXIST	=> try to find by ObjectNameUrl
		begin
			SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId, 
				@dstTypeId=TypeId, @dstObjectName=ObjectName 
			FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and ObjectNameUrl=@oObjectNameUrl
			IF @dstObjectId IS NOT NULL 
				PRINT 'WARNING-USER_ERROR: ObjectUrl MATCH ' + @oObjectNameUrl + ' (srcTypeId=' + CAST(@oTypeId as varchar(16)) + ', srcObjectName="' + @oObjectName + '") == (dstTypeId=' + CAST(@dstTypeId as varchar(16)) + ', dstObjectName="' + @dstObjectName + '")'
		end
		IF @dstObjectId IS NULL	-- NOT EXIST	=> try to find by ObjectFileHash
		begin
			SELECT TOP 1 @dstObjectId=ObjectId, @dstObject_RubricId=RubricId, 
				@dstTypeId=TypeId, @dstObjectName=ObjectName 
			FROM /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE TenantId=@dstTenantId and ObjectFileHash=@oObjectFileHash
			IF @dstObjectId IS NOT NULL 
				PRINT 'WARNING-USER_ERROR: ObjectFileHash MATCH ' + @oObjectFileHash + ' (srcTypeId=' + CAST(@oTypeId as varchar(16)) + ', srcObjectName="' + @oObjectName + '") == (dstTypeId=' + CAST(@dstTypeId as varchar(16)) + ', dstObjectName="' + @dstObjectName + '")'
		end

		SET @dstUserId=dbo.fn_GetUserId_ByUserIdFromMDI(@o_createdBy, @dstDefaultUserId);
-- Transfer Object (CREATE PHYSICALLY _OR_ IF EXISTS - place a link to rubric)
		PRINT '--- Processing object ' + @oObjectName + ' [dstObjectId=' + CAST(@dstObjectId as varchar(16)) + ', oObjectId=' + CAST(@oObjectId as varchar(16)) + ', oRubricPath=' + @oRubricPath + ', oTypeId=' + CAST(@oTypeId as varchar(16)) + ']'
		IF @dstObjectId IS NULL	-- NOT EXIST
		begin -- ADD PHYSICAL OBJECT
/*
			-- CHECK For possible unique index conflicts (ObjectNameUrl, ObjectFileHash) - begin
			begin
				select top 1 @dstObjectId=ObjectId from /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE ObjectNameUrl=@oObjectNameUrl
				if @dstObjectId IS NOT NULL
				begin
					SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR: Object in destination database was not found by name "' + @oObjectName + '" and TypeId=' + CAST(@oTypeId as varchar(16)) + '. But there is an object with matching ObjectNameUrl="' + @oObjectNameUrl + '", dstObjectId=' + CAST(@dstObjectId as varchar(16));
					THROW 50001, @msg, 0;
					PRINT @msg;
				end
				IF @oObjectFileHash IS NOT NULL AND @dstObjectId IS NULL
				begin 
					select top 1 @dstObjectId=ObjectId from /*[RUB_CRC1625].*/[dbo].ObjectInfo WHERE ObjectFileHash=@oObjectFileHash
					if @dstObjectId IS NOT NULL
					begin
						SET @msg = FORMAT(getdate(), @dtformat) + ' CRITICAL ERROR: Object in destination database was not found by name "' + @oObjectName + '" and TypeId=' + CAST(@oTypeId as varchar(16)) + '. But there is an object with matching ObjectFileHash="' + @oObjectFileHash + '", dstObjectId=' + CAST(@dstObjectId as varchar(16));
						THROW 50001, @msg, 0;
						PRINT @msg;
					end
				end
			end
			-- CHECK For possible unique index conflicts (ObjectNameUrl, ObjectFileHash) - end
*/
			-- 0. detect dstUserId for OBJECT
			--EXEC dbo.GetCrossDBUserId @srcDatabase, @o_createdBy, @dstDatabase, @dstUserId output;
			--SET @dstUserId=ISNULL(@dstUserId, @dstDefaultUserId);
			SET @dstUserId_updated=dbo.fn_GetUserId_ByUserIdFromMDI(@o_updatedBy, @dstDefaultUserId);
			-- Get Next free ObjectId for @dstObjectId
			SELECT @dstObjectId = MAX(ObjectId)+1 FROM /*[RUB_CRC1625].*/dbo.ObjectInfo
			IF @dstObjectId IS NULL SET @dstObjectId=1
			-- INSERT
			INSERT INTO /*[RUB_CRC1625].*/[dbo].ObjectInfo(ObjectId, TenantId, _created, _createdBy, _updated, _updatedBy, TypeId, RubricId, SortCode, AccessControl, IsPublished, ExternalId, ObjectName, ObjectNameUrl, ObjectFilePath, ObjectFileHash, ObjectDescription)
				VALUES(@dstObjectId, @dstTenantId, @o_created, @dstUserId, @o_updated, @dstUserId_updated, @oTypeId, @dstRubricId, @oSortCode, @oAccessControl, @oIsPublished, @oExternalId, @oObjectName, @oObjectNameUrl, @oObjectFilePath, @oObjectFileHash, @oObjectDescription)
			SET @ObjectsCountAdded = @ObjectsCountAdded + 1
			-- table variable to make objects relations and stats
			-- Add (srcObjectId, dstObjectId) to a @List
			IF NOT EXISTS (select top 1 srcObjectId from dbo._TransferInfProjects where srcObjectId=@oObjectId)
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (@oObjectId, @dstObjectId, @oTypeId, @srcRubricId, @dstRubricId, @dstUserId, 20, @transferObjectType + ' added')
			ELSE
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (NULL, NULL, NULL, NULL, NULL, NULL, 20, 'ALREADY EXISTS srcObjectId=' + CAST(@oObjectId as varchar(16)))
		end
		ELSE	-- EXIST => Check PATH
		begin
			IF @dstObject_RubricId<>@dstRubricId	-- object/link is in another rubric => create link
			begin
				SET @dstObjectLinkRubricId=NULL;
				SET @l_created=NULL;
				select @dstObjectLinkRubricId=ObjectLinkRubricId, @l_created=_created from /*[RUB_CRC1625].*/dbo.ObjectLinkRubric WHERE ObjectId=@dstObjectId and RubricId=@dstRubricId
				IF @dstObjectLinkRubricId IS NULL
				begin
					INSERT INTO /*[RUB_CRC1625].*/dbo.ObjectLinkRubric(RubricId, ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy)
						VALUES(@dstRubricId, @dstObjectId, @oSortCode, getdate(), @dstUserId, getdate(), @dstUserId)
					SET @ObjectLinksCountAdded = @ObjectLinksCountAdded + 1
				end
				ELSE
				begin
					UPDATE /*[RUB_CRC1625].*/dbo.ObjectLinkRubric SET SortCode=@oSortCode, _createdBy=@dstUserId, _updatedBy=@dstUserId, _updated=getdate() 
						WHERE ObjectLinkRubricId=@dstObjectLinkRubricId
					SET @ObjectLinksCountUpdated = @ObjectLinksCountUpdated + 1
				end
			end
			SET @ObjectsCountExists = @ObjectsCountExists + 1
			-- table variable to make objects relations and stats
			-- Add (srcObjectId, dstObjectId) to a @List
			IF NOT EXISTS (select top 1 srcObjectId from dbo._TransferInfProjects where srcObjectId=@oObjectId)
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (@oObjectId, @dstObjectId, @oTypeId, @srcRubricId, @dstRubricId, @dstUserId, 20, @transferObjectType + ' exists')
			ELSE
				INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action])
					VALUES (NULL, NULL, NULL, NULL, NULL, NULL, 20, 'ALREADY EXISTS srcObjectId=' + CAST(@oObjectId as varchar(16)))
		end
-- === Object-Transfer COPY 2 - END
	end
	close cObjects
	deallocate cObjects
select @RowsCount=count(*) from dbo._TransferInfProjects
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 2: Dig one level deeper through associations finished... dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'
-- it's better to dig one level deeper through associations (sometimes only links for samples are places and not all characterisation documents) - END


SET @transferObjectType = 'UPDATE Graph table ObjectLinkObject'
-- FOR ALL Objects - UPDATE Graph table ObjectLinkObject (1 level down) - BEGIN
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 3: UPDATE Graph table ObjectLinkObject started... dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'
-- [RUB_MDI].dbo.ObjectLinkObject ||| [RUB_MDI].dbo.vObjectLinkObject
	-- UPDATE EXISTING
	--SET @dstUserId_updated=dbo.fn_GetUserId_ByUserIdFromMDI(@o_updatedBy, @dstDefaultUserId);
	UPDATE dstOLO 
		SET SortCode=srcOLO.SortCode, _created=srcOLO._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(srcOLO._createdBy, @dstDefaultUserId), _updated=srcOLO._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(srcOLO._updatedBy, @dstDefaultUserId), LinkTypeObjectId=srcOLO.LinkTypeObjectId
	FROM /*[RUB_CRC1625].*/dbo.ObjectLinkObject as dstOLO
		INNER JOIN dbo._TransferInfProjects as OParent on dstOLO.ObjectId=OParent.dstObjectId
		INNER JOIN dbo._TransferInfProjects as OChild on dstOLO.LinkedObjectId=OChild.dstObjectId
		INNER JOIN [RUB_MDI].dbo.ObjectLinkObject as srcOLO ON srcOLO.ObjectId=OParent.srcObjectId AND srcOLO.LinkedObjectId=OChild.srcObjectId AND ISNULL(srcOLO.LinkTypeObjectId, 0)=ISNULL(dstOLO.LinkTypeObjectId, 0)
	DECLARE @ObjectLinkObjectUpdated int = @@ROWCOUNT
	-- INSERT NEW links
	INSERT INTO /*[RUB_CRC1625].*/dbo.ObjectLinkObject(ObjectId, LinkedObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, LinkTypeObjectId)
		SELECT OParent.dstObjectId, OChild.dstObjectId, srcOLO.SortCode, srcOLO._created, dbo.fn_GetUserId_ByUserIdFromMDI(srcOLO._createdBy, @dstDefaultUserId), srcOLO._updated, dbo.fn_GetUserId_ByUserIdFromMDI(srcOLO._updatedBy, @dstDefaultUserId), srcOLO.LinkTypeObjectId
		FROM [RUB_MDI].dbo.ObjectLinkObject as srcOLO
			INNER JOIN dbo._TransferInfProjects as OParent on srcOLO.ObjectId=OParent.srcObjectId
			INNER JOIN dbo._TransferInfProjects as OChild on srcOLO.LinkedObjectId=OChild.srcObjectId
		LEFT OUTER JOIN /*[RUB_CRC1625].*/dbo.ObjectLinkObject as dstOLO ON dstOLO.ObjectId=OParent.dstObjectId AND dstOLO.LinkedObjectId=OChild.dstObjectId AND ISNULL(srcOLO.LinkTypeObjectId, 0)=ISNULL(dstOLO.LinkTypeObjectId, 0)
		WHERE dstOLO.ObjectLinkObjectId IS NULL
	DECLARE @ObjectLinkObjectInserted int = @@ROWCOUNT
select @RowsCount=count(*) from dbo._TransferInfProjects
PRINT FORMAT(getdate(), @dtformat) + ' TransferInfProjects_Objects 3: UPDATE Graph table ObjectLinkObject finished... dbo._TransferInfProjects contain ' + CAST(@RowsCount as varchar(16)) + ' row(s)'
-- FOR ALL Objects - UPDATE Graph table ObjectLinkObject (1 level down) - END



-- dbo._TransferInfProjects are populated - we can process extensions and properties!
	-- DECLARE srcObjectId int, dstObjectId int, TypeId int, srcRubricId int, dstRubricId int, dstUserId int
	declare @ExtensionTablesCount int=0, @PropertiesCount int=0, @ret int
	declare cObjectsAdds cursor local FORWARD_ONLY STATIC for
    SELECT srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId from dbo._TransferInfProjects ORDER BY srcObjectId
	open cObjectsAdds
	while (1=1)
	begin
		fetch cObjectsAdds into @oObjectId, @dstObjectId, @oTypeId, @oRubricId, @dstRubricId, @dstUserId
		if @@fetch_status <> 0 break
-- !!! BETTER !!! to make it later (after all linked objects are transferred also, othrwise sime identifiers could be not found) - BEGIN
-- FOR ALL Objects - Update Extension tables: Handover, Reference, Sample, Composition (PARAMETERS: @srcDatabase, @dstDatabase, @oObjectId, @dstObjectId, //@dstUserId)
		EXEC @ret = [dbo].[TransferInfProjects_Objects_ExtensionTables] @srcDatabase, @srcTenantId, @srcRubricPath, @dstDatabase, @dstTenantId, @dstRubricPath, @dstUserId, @oObjectId, @dstObjectId;
		SET @ExtensionTablesCount = @ExtensionTablesCount + @ret

-- FOR ALL Objects - Update PROPERTIES: 4 x tables Property* (PARAMETERS: @srcDatabase, @dstDatabase, @oObjectId, @dstObjectId, @dstUserId) - BEGIN
		EXEC @ret = [dbo].[TransferInfProjects_Objects_Properties] @srcDatabase, @srcTenantId, @srcRubricPath, @dstDatabase, @dstTenantId, @dstRubricPath, @dstUserId, @oObjectId, @dstObjectId;
		SET @PropertiesCount = @PropertiesCount + @ret
-- !!! BETTER !!! to make it later
	end		
close cObjectsAdds
deallocate cObjectsAdds

PRINT FORMAT(getdate(), @dtformat) + ' Transfer Objects Complete!'
PRINT '    Total objects: ' + CAST(@ObjectsCountExists+@ObjectsCountAdded as varchar(16)) + ' (Added: ' + CAST(@ObjectsCountAdded as varchar(16)) + '; Exists: ' + CAST(@ObjectsCountExists as varchar(16)) + ')'
PRINT '    Total object links: ' + CAST(@ObjectLinksCountAdded+@ObjectLinksCountUpdated as varchar(16)) + ' (Added: ' + CAST(@ObjectLinksCountAdded as varchar(16)) + '; Exists: ' + CAST(@ObjectLinksCountUpdated as varchar(16)) + ')'
PRINT '    Total ExtensionTables: ' + CAST(@ExtensionTablesCount as varchar(16)) + ', Properties: ' + CAST(@PropertiesCount as varchar(16)) + ')'
PRINT '    Total ObjectLinkObjectUpdated: ' + CAST(@ObjectLinkObjectUpdated as varchar(16)) + ', ObjectLinkObjectInserted: ' + CAST(@ObjectLinkObjectInserted as varchar(16)) + ')'

END TRY
BEGIN CATCH
	-- Catch and print the error
	SET @msg = 'ERROR: ' + ERROR_MESSAGE() + '. ERROR_NUMBER=' + cast(ERROR_NUMBER() as varchar(16)) + '; ERROR_LINE=' + cast(ERROR_LINE() as varchar(16)) + '; ERROR_PROCEDURE=' + ERROR_PROCEDURE()
	PRINT @msg
	INSERT INTO dbo._TransferInfProjects(srcObjectId, dstObjectId, TypeId, srcRubricId, dstRubricId, dstUserId, step, [action], comment)
		VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, @transferObjectType, @msg)
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[TransferInfProjects_Objects_ExtensionTables]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferInfProjects_Objects_ExtensionTables]
-- SOURCE
@srcDatabase varchar(32)='[RUB_MDI]',	-- mdi.matinf.pro
@srcTenantId int=7,	-- mdi.matinf.pro
@srcRubricPath varchar(256)='Nonindustry}CRC 1625',	-- RubricPath from which we are copying to destination ('}'-separated path)
-- DESTINATION
@dstDatabase varchar(32)='[RUB_CRC1625]',	-- crc1625.mdi.ruhr-uni-bochum.de
@dstTenantId int=4,	-- crc1625.mdi.ruhr-uni-bochum.de
@dstRubricPath varchar(256)='',	-- RubricPath TO which we are copying (empty==root, by default, '}'-separated path)
-- SETTINGS
@dstDefaultUserId int=2,	-- some default user (if by Email user can not be found), vic.dudarev@gmail.com
@oObjectId int,			-- ObjectId in source database
@dstObjectId int		-- ObjectId in target(destination) database
/*
-- EXEC [dbo].[TransferInfProjects_Objects_ExtensionTables] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='', @dstDefaultUserId=2, @oObjectId=62622, @dstObjectId=11091
*/
-- Makes sure, that all properties are transferred (extra properties in target that are missing in source are not touched)
AS
-- FOR ALL Objects - Update PROPERTIES: 4 x tables Property* (PARAMETERS: @srcDatabase, @dstDatabase, @oObjectId, @dstObjectId, @dstUserId) - BEGIN
BEGIN
	DECLARE @rc int=0
	-- FOR ALL Objects - Update Extension tables: Handover, Reference, Sample, Composition
	-- Handover
	DECLARE @sSampleObjectId int=NULL, @sDestinationUserId int=NULL, @dSampleObjectId int=NULL, @dDestinationUserId int=NULL
	select @sSampleObjectId=SampleObjectId, @sDestinationUserId=DestinationUserId from [RUB_MDI].dbo.Handover WHERE HandoverId=@oObjectId
	if @sSampleObjectId IS NOT NULL	-- need to transfer Handover
	begin 
		-- SampleObjectId
		SELECT TOP 1 @dSampleObjectId=ObjectId FROM /*[RUB_CRC1625].*/dbo.ObjectInfo WHERE TenantId=@dstTenantId and UPPER(ObjectName)=(select UPPER(ObjectName) from [RUB_MDI].dbo.ObjectInfo where ObjectId=@sSampleObjectId)
		-- DestinationUserId
		SET @dDestinationUserId=dbo.fn_GetUserId_ByUserIdFromMDI(@sDestinationUserId, @dstDefaultUserId);

		IF EXISTS (select top 1 HandoverId from /*[RUB_CRC1625].*/[dbo].Handover where HandoverId=@dstObjectId)
			UPDATE T 
				SET SampleObjectId=@dSampleObjectId, DestinationUserId=@dDestinationUserId, DestinationConfirmed=SRC.DestinationConfirmed, DestinationComments=SRC.DestinationComments, [Json]=SRC.[Json], Amount=SRC.Amount, MeasurementUnit=SRC.MeasurementUnit
			FROM /*[RUB_CRC1625].*/[dbo].Handover T
				INNER JOIN [RUB_MDI].dbo.Handover as SRC ON SRC.HandoverId=@oObjectId
			WHERE T.HandoverId=@dstObjectId
		else
			INSERT INTO /*[RUB_CRC1625].*/[dbo].Handover(HandoverId, SampleObjectId, DestinationUserId, DestinationConfirmed, DestinationComments, [Json], Amount, MeasurementUnit)
				SELECT @dstObjectId as HandoverId, @dSampleObjectId as SampleObjectId, @dDestinationUserId as DestinationUserId, DestinationConfirmed, DestinationComments, [Json], Amount, MeasurementUnit
					FROM [RUB_MDI].dbo.Handover WHERE HandoverId=@oObjectId
		SET @rc = @rc + 1
	end
	-- Reference
	DECLARE @sReferenceId int=NULL
	select @sReferenceId=ReferenceId from [RUB_MDI].dbo.Reference WHERE ReferenceId=@oObjectId
	if @sReferenceId IS NOT NULL	-- need to transfer Reference
	begin 
		IF EXISTS (select top 1 ReferenceId from /*[RUB_CRC1625].*/[dbo].Reference where ReferenceId=@dstObjectId)
			UPDATE T 
				SET Authors=SRC.Authors, Title=SRC.Title, Journal=SRC.Journal, [Year]=SRC.[Year], Volume=SRC.Volume, Number=SRC.Number, StartPage=SRC.StartPage, EndPage=SRC.EndPage, DOI=SRC.DOI, [URL]=SRC.[URL], BibTeX=SRC.BibTeX
			FROM /*[RUB_CRC1625].*/[dbo].Reference T
				INNER JOIN [RUB_MDI].dbo.Reference as SRC ON SRC.ReferenceId=@oObjectId
			WHERE T.ReferenceId=@dstObjectId
		else
			INSERT INTO /*[RUB_CRC1625].*/[dbo].Reference(ReferenceId, Authors, Title, Journal, [Year], Volume, Number, StartPage, EndPage, DOI, [URL], BibTeX)
				SELECT @dstObjectId as ReferenceId, Authors, Title, Journal, [Year], Volume, Number, StartPage, EndPage, DOI, [URL], BibTeX
					FROM [RUB_MDI].dbo.Reference WHERE ReferenceId=@oObjectId
		SET @rc = @rc + 1
	end
	-- Sample + Composition
	DECLARE @sSampleId int=NULL
	select @sSampleId=SampleId from [RUB_MDI].dbo.[Sample] WHERE SampleId=@oObjectId
	if @sSampleId IS NOT NULL	-- need to transfer Sample
	begin 
		IF EXISTS (select top 1 SampleId from /*[RUB_CRC1625].*/[dbo].[Sample] where SampleId=@dstObjectId)
			UPDATE T 
				SET ElemNumber=SRC.ElemNumber, [Elements]=SRC.[Elements]
			FROM /*[RUB_CRC1625].*/[dbo].[Sample] T
				INNER JOIN [RUB_MDI].dbo.[Sample] as SRC ON SRC.SampleId=@oObjectId
			WHERE T.SampleId=@dstObjectId
		else
			INSERT INTO /*[RUB_CRC1625].*/[dbo].[Sample](SampleId, ElemNumber, [Elements])
				SELECT @dstObjectId as SampleId, ElemNumber, [Elements]
					FROM [RUB_MDI].dbo.[Sample] WHERE SampleId=@oObjectId
		SET @rc = @rc + 1

		-- == NESTED Composition - BEGIN
		-- Composition
		IF EXISTS (select top 1 SampleId from [RUB_MDI].dbo.Composition WHERE SampleId=@oObjectId)
		BEGIN
			DELETE FROM /*[RUB_CRC1625].*/dbo.Composition WHERE SampleId=@dstObjectId AND ElementName NOT IN (select ElementName from [RUB_MDI].dbo.Composition WHERE SampleId=@oObjectId)
			UPDATE T 
				SET CompoundIndex=SRC.CompoundIndex, ValueAbsolute=SRC.ValueAbsolute, ValuePercent=SRC.ValuePercent
			FROM /*[RUB_CRC1625].*/dbo.Composition T
				INNER JOIN [RUB_MDI].dbo.Composition as SRC ON SRC.SampleId=@oObjectId AND SRC.ElementName=T.ElementName
			WHERE T.SampleId=@dstObjectId
			-- @NextCompositionId
			DECLARE @MaxCompositionId int
			SELECT @MaxCompositionId = MAX(CompositionId) FROM /*[RUB_CRC1625].*/dbo.Composition
			IF @MaxCompositionId IS NULL SET @MaxCompositionId=0

			INSERT /*[RUB_CRC1625].*/dbo.Composition(CompositionId, SampleId, CompoundIndex, ElementName, ValueAbsolute, ValuePercent)
				SELECT @MaxCompositionId + ROW_NUMBER() OVER (ORDER BY CompoundIndex, ElementName) as CompositionId, @dstObjectId as SampleId, CompoundIndex, ElementName, ValueAbsolute, ValuePercent
					FROM [RUB_MDI].dbo.Composition WHERE SampleId=@oObjectId and ElementName NOT IN (select ElementName from /*[RUB_CRC1625].*/dbo.Composition WHERE SampleId=@dstObjectId)
			SET @rc = @rc + 1
		END
		-- == NESTED Composition - END
	end
	RETURN @rc
END
GO
/****** Object:  StoredProcedure [dbo].[TransferInfProjects_Objects_Properties]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferInfProjects_Objects_Properties]
-- SOURCE
@srcDatabase varchar(32)='[RUB_MDI]',	-- mdi.matinf.pro
@srcTenantId int=7,	-- mdi.matinf.pro
@srcRubricPath varchar(256)='Nonindustry}CRC 1625',	-- RubricPath from which we are copying to destination ('}'-separated path)
-- DESTINATION
@dstDatabase varchar(32)='[RUB_CRC1625]',	-- crc1625.mdi.ruhr-uni-bochum.de
@dstTenantId int=4,	-- crc1625.mdi.ruhr-uni-bochum.de
@dstRubricPath varchar(256)='',	-- RubricPath TO which we are copying (empty==root, by default, '}'-separated path)
-- SETTINGS
@dstUserId int=2,		-- user-object-owner
@oObjectId int,			-- ObjectId in source database
@dstObjectId int		-- ObjectId in target(destination) database
/*
-- EXEC [dbo].[TransferInfProjects_Objects_Properties] @srcDatabase='[RUB_MDI]', @srcTenantId=7, @srcRubricPath='Nonindustry}CRC 1625', @dstDatabase='[RUB_CRC1625]', @dstTenantId=4, @dstRubricPath='', @dstUserId=2, @oObjectId=62622, @dstObjectId=11091
*/
-- Makes sure, that all properties are transferred (extra properties in target that are missing in source are not touched)
-- not valid any more (see updates, old code is commented) WARNING: Drawback - here _createdBy and _updatedBy for all properties are taken from @dstUserId (not from original source properties)
AS
-- FOR ALL Objects - Update PROPERTIES: 4 x tables Property* (PARAMETERS: @srcDatabase, @dstDatabase, @oObjectId, @dstObjectId, @dstUserId) - BEGIN
BEGIN
	DECLARE @rc int=0
	-- PropertyFloat
/*
	MERGE INTO /*[RUB_CRC1625].*/dbo.PropertyFloat AS Dst
	USING [RUB_MDI].dbo.PropertyFloat AS Src
	ON Dst.ObjectId=@dstObjectId AND Src.ObjectId=@oObjectId AND Dst.PropertyName=Src.PropertyName AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) 
		--AND Dst.SortCode=Src.SortCode and Dst.[Value]=Src.[Value] and ISNULL(Dst.ValueEpsilon, 0)=ISNULL(Src.ValueEpsilon, 0) and ISNULL(Dst.Comment,'')=ISNULL(Src.Comment,'')
	WHEN MATCHED THEN
		--UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=@dstUserId, _updated=Src._updated, _updatedBy=@dstUserId, [Value]=Src.[Value], ValueEpsilon=Src.ValueEpsilon, Comment=Src.Comment
		UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], ValueEpsilon=Src.ValueEpsilon, Comment=Src.Comment
	WHEN NOT MATCHED BY Target THEN
		INSERT (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], ValueEpsilon, PropertyName, Comment) 
		--VALUES (@dstObjectId, Src.SortCode, Src._created, @dstUserId, Src._updated, @dstUserId, Src.[Row], Src.[Value], Src.ValueEpsilon, Src.PropertyName, Src.Comment);
		VALUES (@dstObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.ValueEpsilon, Src.PropertyName, Src.Comment);
*/	
	UPDATE Dst 
		SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], ValueEpsilon=Src.ValueEpsilon, Comment=Src.Comment
	FROM /*[RUB_CRC1625].*/dbo.PropertyFloat Dst
		INNER JOIN [RUB_MDI].dbo.PropertyFloat as Src ON Src.ObjectId=@oObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
	WHERE Dst.ObjectId=@dstObjectId
	SET @rc = @rc + @@ROWCOUNT
	INSERT INTO dbo.PropertyFloat(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], ValueEpsilon, PropertyName, Comment)
		SELECT @dstObjectId as ObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.ValueEpsilon, Src.PropertyName, Src.Comment
		FROM [RUB_MDI].dbo.PropertyFloat AS Src 
		LEFT OUTER JOIN dbo.PropertyFloat AS Dst ON Dst.ObjectId=@dstObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
		WHERE Src.ObjectId=@oObjectId AND Dst.PropertyFloatId IS NULL
	SET @rc = @rc + @@ROWCOUNT

	-- PropertyInt
/*
	MERGE INTO /*[RUB_CRC1625].*/dbo.PropertyInt AS Dst
	USING [RUB_MDI].dbo.PropertyInt AS Src
	ON Dst.ObjectId=@dstObjectId AND Src.ObjectId=@oObjectId AND Dst.PropertyName=Src.PropertyName AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) 
		--AND Dst.SortCode=Src.SortCode and Dst.[Value]=Src.[Value] and ISNULL(Dst.ValueEpsilon, 0)=ISNULL(Src.ValueEpsilon, 0) and ISNULL(Dst.Comment,'')=ISNULL(Src.Comment,'')
	WHEN MATCHED THEN
		--UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=@dstUserId, _updated=Src._updated, _updatedBy=@dstUserId, [Value]=Src.[Value], Comment=Src.Comment
		UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	WHEN NOT MATCHED BY Target THEN
		INSERT (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment) 
		--VALUES (@dstObjectId, Src.SortCode, Src._created, @dstUserId, Src._updated, @dstUserId, Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
		VALUES (@dstObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
*/
	UPDATE Dst 
		SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	FROM /*[RUB_CRC1625].*/dbo.PropertyInt Dst
		INNER JOIN [RUB_MDI].dbo.PropertyInt as Src ON Src.ObjectId=@oObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
	WHERE Dst.ObjectId=@dstObjectId
	SET @rc = @rc + @@ROWCOUNT
	INSERT INTO dbo.PropertyInt(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment)
		SELECT @dstObjectId as ObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment
		FROM [RUB_MDI].dbo.PropertyInt AS Src 
		LEFT OUTER JOIN dbo.PropertyInt AS Dst ON Dst.ObjectId=@dstObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
		WHERE Src.ObjectId=@oObjectId AND Dst.PropertyIntId IS NULL
	SET @rc = @rc + @@ROWCOUNT

	-- PropertyString
/*
	MERGE INTO /*[RUB_CRC1625].*/dbo.PropertyString AS Dst
	USING [RUB_MDI].dbo.PropertyString AS Src
	ON Dst.ObjectId=@dstObjectId AND Src.ObjectId=@oObjectId AND Dst.PropertyName=Src.PropertyName AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) 
		--AND Dst.SortCode=Src.SortCode and Dst.[Value]=Src.[Value] and ISNULL(Dst.ValueEpsilon, 0)=ISNULL(Src.ValueEpsilon, 0) and ISNULL(Dst.Comment,'')=ISNULL(Src.Comment,'')
	WHEN MATCHED THEN
		--UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=@dstUserId, _updated=Src._updated, _updatedBy=@dstUserId, [Value]=Src.[Value], Comment=Src.Comment
		UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	WHEN NOT MATCHED BY Target THEN
		INSERT (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment) 
		--VALUES (@dstObjectId, Src.SortCode, Src._created, @dstUserId, Src._updated, @dstUserId, Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
		VALUES (@dstObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
*/
	UPDATE Dst 
		SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	FROM /*[RUB_CRC1625].*/dbo.PropertyString Dst
		INNER JOIN [RUB_MDI].dbo.PropertyString as Src ON Src.ObjectId=@oObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
	WHERE Dst.ObjectId=@dstObjectId
	SET @rc = @rc + @@ROWCOUNT
	INSERT INTO dbo.PropertyString(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment)
		SELECT @dstObjectId as ObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment
		FROM [RUB_MDI].dbo.PropertyString AS Src 
		LEFT OUTER JOIN dbo.PropertyString AS Dst ON Dst.ObjectId=@dstObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
		WHERE Src.ObjectId=@oObjectId AND Dst.PropertyStringId IS NULL
	SET @rc = @rc + @@ROWCOUNT

	-- PropertyBigString
/*
	MERGE INTO /*[RUB_CRC1625].*/dbo.PropertyBigString AS Dst
	USING [RUB_MDI].dbo.PropertyBigString AS Src
	ON Dst.ObjectId=@dstObjectId AND Src.ObjectId=@oObjectId AND Dst.PropertyName=Src.PropertyName AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) 
		--AND Dst.SortCode=Src.SortCode and Dst.[Value]=Src.[Value] and ISNULL(Dst.ValueEpsilon, 0)=ISNULL(Src.ValueEpsilon, 0) and ISNULL(Dst.Comment,'')=ISNULL(Src.Comment,'')
	WHEN MATCHED THEN
		--UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=@dstUserId, _updated=Src._updated, _updatedBy=@dstUserId, [Value]=Src.[Value], Comment=Src.Comment
		UPDATE SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	WHEN NOT MATCHED BY Target THEN
		INSERT (ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment) 
		--VALUES (@dstObjectId, Src.SortCode, Src._created, @dstUserId, Src._updated, @dstUserId, Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
		VALUES (@dstObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment);
*/
	UPDATE Dst 
		SET SortCode=Src.SortCode, _created=Src._created, _createdBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), _updated=Src._updated, _updatedBy=dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), [Value]=Src.[Value], Comment=Src.Comment
	FROM /*[RUB_CRC1625].*/dbo.PropertyBigString Dst
		INNER JOIN [RUB_MDI].dbo.PropertyBigString as Src ON Src.ObjectId=@oObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
	WHERE Dst.ObjectId=@dstObjectId
	SET @rc = @rc + @@ROWCOUNT
	INSERT INTO dbo.PropertyBigString(ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, [Row], [Value], PropertyName, Comment)
		SELECT @dstObjectId as ObjectId, Src.SortCode, Src._created, dbo.fn_GetUserId_ByUserIdFromMDI(Src._createdBy, @dstUserId), Src._updated, dbo.fn_GetUserId_ByUserIdFromMDI(Src._updatedBy, @dstUserId), Src.[Row], Src.[Value], Src.PropertyName, Src.Comment
		FROM [RUB_MDI].dbo.PropertyBigString AS Src 
		LEFT OUTER JOIN dbo.PropertyBigString AS Dst ON Dst.ObjectId=@dstObjectId AND ISNULL(Dst.[Row], 0)=ISNULL(Src.[Row], 0) AND Dst.PropertyName=Src.PropertyName
		WHERE Src.ObjectId=@oObjectId AND Dst.PropertyBigStringId IS NULL
	SET @rc = @rc + @@ROWCOUNT
-- FOR ALL Objects - Update PROPERTIES: 4 x tables Property* (PARAMETERS: @oObjectId, @dstObjectId, @dstUserId) - END
	RETURN @rc
END
GO
/****** Object:  StoredProcedure [dbo].[TransferInfProjects_RubricText]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferInfProjects_RubricText]
@srcRubricId int,
@dstRubricId int
AS
-- EXEC [dbo].[TransferInfProjects_RubricText] @srcRubricId=, @dstRubricId=
BEGIN
	DECLARE @RubricText varchar(max)=null
	select top 1 @RubricText=RubricText from [RUB_MDI].dbo.RubricInfoAdds WHERE RubricId=@srcRubricId
	IF @RubricText IS NOT NULL
	begin
		IF EXISTS (select top 1 RubricId from /*[RUB_CRC1625].*/dbo.RubricInfoAdds WHERE RubricId=@dstRubricId)
			UPDATE /*[RUB_CRC1625].*/dbo.RubricInfoAdds SET RubricText=@RubricText WHERE RubricId=@dstRubricId
		ELSE
			INSERT INTO /*[RUB_CRC1625].*/dbo.RubricInfoAdds(RubricId, RubricText) VALUES(@dstRubricId, @RubricText)
	end
		--SET @ParmDefinition=N'@srcRubricId int, @dstRubricId int';
		--SET @sqlCommand='DECLARE @RubricText varchar(max)=null;
--	select top 1 @RubricText=RubricText from '+@srcDatabase+'.dbo.RubricInfoAdds WHERE RubricId=@srcRubricId
--	IF @RubricText IS NOT NULL
--	begin
--		IF EXISTS (select top 1 RubricId from '+@dstDatabase+'.dbo.RubricInfoAdds WHERE RubricId=@dstRubricId)
--			UPDATE '+@dstDatabase+'.dbo.RubricInfoAdds SET RubricText=@RubricText WHERE RubricId=@dstRubricId
--		ELSE
--			INSERT INTO '+@dstDatabase+'.dbo.RubricInfoAdds(RubricId, RubricText) VALUES(@dstRubricId, @RubricText)
--	end
		--EXECUTE dbo.sp_executesql @sqlCommand, @ParmDefinition, @srcRubricId=@srcRubricId, @dstRubricId=@dstRubricId;
END
GO
/****** Object:  StoredProcedure [dbo].[TransferSample]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TransferSample]
@SampleId int output,-- ObjectID of Sample (created or already exists)
@projectId int,		-- projectId in COMPACT database
@TenantId int,	-- crc1625.mdi.ruhr-uni-bochum.de
@TypeIdRubric int=2,	-- Type for rubric == Sample	(0 - Rubric is ready - take @ParentRubricId)
@ParentRubricId int=140, -- Area A / A01 / Preliminary work for proposal and evaluation Ag-Au-Cu-Pd-Pt (Rubric Where we need to create subrubric for Sample) -- rubric to create sample-rubric
@AccessControl int=1,	-- protected
@IsPublished bit=1,		-- true
@_userId int = 1,		-- some user
@RubricId_Substrate int,	-- if new substrate needs to be added, then this the RubricId for substrates
@DeletePreviousProperties bit=0,		-- delete all destination object properties (and recreate them)
@TemplateObjectIdSynthesis int=0		-- ObjectId of "_Template" object for synthesys (TypeId=18)
-- RETURN VALUE: 0 == sample Exists; 1 == sample added
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 8457, 4, 2, 140, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 8250, 4, 2, 140, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 1575, 4, 2, 270, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 8279, 4, 2, 270, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 8281, 4, 2, 270, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 8289, 4, 2, 270, 1, 1, 1
-- DECLARE @SampleId int; EXEC dbo.[TransferSample] @SampleId output, 3837, 5, 0, 198, 1, 1, 1, 202
as
DECLARE @TypeId_Sample int = [dbo].[GetTypeIdForCompact]('Sample', 'Sample', null)	-- TypeId==6 for Sample Object
DECLARE @retval int = 0;
DECLARE @Created datetime
DECLARE @DepositionCount int
DECLARE @CharacterizationCount int
DECLARE @Chamber varchar(32)
DECLARE @CreatedByPerson varchar(32)
DECLARE @ProjectName varchar(128)
DECLARE @SampleMaterial varchar(255)
DECLARE @SubstrateMaterial varchar(50)
DECLARE @CN_PROJEKT_ID varchar(20)
DECLARE @ProjectComment varchar(256)
DECLARE @CompactAccessControl int

DECLARE @SampleName varchar(512)=''
DECLARE @SampleDescription varchar(1024)=''

DECLARE @ObjectId int
DECLARE @_date datetime = getdate()
DECLARE @TypeId int = 6 -- Sample
DECLARE @RubricId int
DECLARE @SortCode int = -100
DECLARE @ExternalId int
DECLARE @ObjectName varchar(512)=''
DECLARE @ObjectNameUrl varchar(256)=null	-- IGNORE
DECLARE @ObjectFilePath varchar(256)=null
DECLARE @ObjectDescription varchar(1024)=null
--
DECLARE @ElemNumber int = 0
DECLARE @Elements varchar(256) = ''
DECLARE @showResultsInRecordset bit=0
DECLARE @SamplesCountAdded int = 0, @SamplesCountExists int = 0
DECLARE @RubricName varchar(256)=''

-- DOCUMENTS
DECLARE @DocumentCount int=0, @DocumentCountAdded int=0, @DocumentCountExists int=0
DECLARE @DocumentId int, @ProcessingState varchar(256), @Characterization varchar(256), @CadRefFileName varchar(256), @Directory varchar(256), @FileName varchar(256)
-- SYNTHESIS DOCUMENTS
DECLARE @SynthCount int=0
DECLARE @SynthId int, @CN_SAMPLE_MATERIAL varchar(256), @CN_SAMPLE_DESCRIPTION varchar(256), @DepositionDescription varchar(256), @DepositionId varchar(256)

-- [EdgePLM COMPACT].dbo.Samples
select @projectId=DS.ProjectId, @CompactAccessControl=DS.AccessControl, @Created=Created, @ElemNumber=ElemNumber, @DepositionCount=DepositionCount, @CharacterizationCount=CharacterizationCount, 
	@Chamber=Chamber, @CreatedByPerson=CreatedByPerson, @ProjectName=ProjectName, @SampleMaterial=SampleMaterial, @Elements=[Elements], 
	@SubstrateMaterial=SubstrateMaterial, @CN_PROJEKT_ID=DS.CN_PROJEKT_ID, @ProjectComment=P.CN_PROJ_COMMENT
from [EdgePLM COMPACT].dbo.Samples as DS
	INNER JOIN [EdgePLM COMPACT].isap.TN_PROJECTS as P ON CAST(P.CN_PROJEKT_ID as int)=DS.ProjectId
		where DS.ProjectId=@projectId

	if @AccessControl=1 AND @CompactAccessControl>0
		SET @AccessControl = @AccessControl + @CompactAccessControl

	IF LEN(@CreatedByPerson)>0	-- find user by Name	// if not found old (default) @_userId is used
	begin
		DECLARE @UserId int = [dbo].[fn_GetUserIdByName](@CreatedByPerson)
		if @UserId>0
			SET @_userId = @UserId
	end
	SET @SampleId=NULL
	SET @ExternalId = @projectId
print '@ExternalId = ' + CAST(@ExternalId as varchar(16))
-- declare links table
DECLARE @LinkedObjects dbo.ObjectLinkObjectItem

-- check if sample is already in DB
	SELECT @SampleId=ObjectId, @RubricId=RubricId from dbo.ObjectInfo where TenantId=@TenantId AND TypeId=@TypeId_Sample AND ExternalId=@ExternalId
print '@SampleId = ' + CAST(ISNULL(@SampleId, 0) as varchar(16)) + ', @RubricId = ' + CAST(ISNULL(@RubricId, 0) as varchar(16))
	if @SampleId>0
	begin
		PRINT 'Sample already exists: 	ObjectId=SampleId=' + CAST(@SampleId as varchar(16)) + ' done [ExternalId=' + CAST(@ExternalId as varchar(16)) + ']'
		SET @retval = 0;
	end 
	ELSE	-- Add Sample
	begin
		SET @retval = 1;

		-- 0. Check rubric (add if not exist)
		IF @TypeIdRubric>0	-- create/check rubric 'Sample...'
		begin
			SET @RubricName = TRIM('Sample ' + CAST(@projectId as varchar(16)) + ' ' + ISNULL(@SampleMaterial,''))
			SET @RubricId=NULL
			SELECT @RubricId=RubricId from dbo.RubricInfo WHERE TenantId=@TenantId AND ParentId=@ParentRubricId AND RubricName=@RubricName
			if @RubricId IS NULL	-- create rubric
			begin
				EXEC [dbo].[RubricInfo_UpdateInsert] @RubricId output, @TenantId, @_date, @_userId, @_date, @_userId, @TypeIdRubric, @ParentRubricId, 0/*@Level*/, 0/*@LeafFlag*/, 0/*@Flags*/, 0/*@SortCode*/, @AccessControl, @IsPublished, @RubricName, null/*RubricNameUrl*/, null/*@RubricPath*/, 1/*@skipOutput*/
				PRINT '   RubricId=' + CAST(@RubricId as varchar(16)) + ' ADDED [' + @RubricName + ', ParentId=' + CAST(@ParentRubricId as varchar(16)) + ']'
			end
			else 
			begin
				PRINT '   RubricId=' + CAST(@RubricId as varchar(16)) + ' EXISTS [' + @RubricName + ', ParentId=' + CAST(@ParentRubricId as varchar(16)) + ']'
			end
		end
		ELSE	-- USE specified rubric in @ParentRubricId
		begin
			SET @RubricId = @ParentRubricId
		end
	end

	-- required in both cases
	--SET @ObjectName = TRIM('Sample ' + CAST(@projectId as varchar(16)) + ISNULL(' ' + @ProjectName,'') + ISNULL(' ' + @SampleMaterial,''))
	SET @ObjectName = TRIM(CAST(@projectId as varchar(16)) + ISNULL(' ' + @ProjectName,'') + ISNULL(' ' + @SampleMaterial,''))
	SET @SampleName = @ObjectName
	SET @ObjectDescription = TRIM('Sample' + ISNULL(' for '+@ProjectName,'') + ' (' + ISNULL(@SampleMaterial,'') + ISNULL(' at ' + @SubstrateMaterial,'') + ', ID=' + ISNULL(@CN_PROJEKT_ID,'') + ISNULL(', ' + @Chamber,'') + ') by ' + ISNULL(@CreatedByPerson,'') + '. ' + ISNULL(@ProjectComment,''))
	SET @SampleDescription = @ObjectDescription
 -- 1. Add sample
	--SET @SortCode = -100;
	SET @SortCode = 0;
	if @retval = 1 
	begin
		SET @ObjectFilePath=null
		SET @SampleId=0
		EXEC /*@retval = */[dbo].[ObjectInfo_Sample_UpdateInsert] @SampleId output, @TenantId, @_date, @_userId, @_date, @_userId, @TypeId_Sample, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId,
			@ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription, @ElemNumber, @Elements, @showResultsInRecordset
		PRINT '=== SAMPLE ADDED: ' + ISNULL(@ProjectName,'') + ISNULL(' ' + @SampleMaterial,'') + ' done [projectId=' + CAST(@projectId as varchar(16)) + ', SampleId=ObjectId='+CAST(@SampleId as varchar(16))+']'
	end

 -- 2. Check substrate
	if LEN(ISNULL(@SubstrateMaterial,''))>0 AND @SubstrateMaterial<>'<unknown>'
	begin
		DECLARE @SubstrateId int;
		EXEC @SubstrateId=[dbo].[_GetObjectIdOfTypeByName] @TenantId, 0 /* TypeId */, 'Substrate' /* TypeName */, @RubricId_Substrate /* RubricId */, @SubstrateMaterial;
		PRINT '		SubstrateId=' + CAST(@SubstrateId as varchar(8)) + ' done [' + ISNULL(@SubstrateMaterial,'') + ']'
		-- add links: 1 Substrate
		INSERT INTO @LinkedObjects(ObjectLinkObjectId, ObjectId, LinkedObjectId, SortCode)
			VALUES(NULL, @SampleId, @SubstrateId, -100)
	end


-- DOCUMENTS

--- ========================================================== DOCUMENTS with links ========================================================== BEGIN ---
declare cDoc cursor local for 
select CAST(D.OBJECT_ID as int) as DocumentId, 
/*CAST(P.CN_PROJEKT_ID as int) as ProjectId, CAST(D.OBJECT_ID as int) as DocumentId, --D.CN_DOC_SAMPLE_ID as SampleID, 
P.CN_SAMPLE_DESCRIPTION as SampleDescription,		--== TN_PROJECTS
D.CN_DOC_SUBSTRATE_MATERIAL as SubstrateMaterial, S.[DESCRIPTION] as SubstrateDescription,      -- TN_SUBSTRATE_MATERIAL (SAME)
*/CT.[DESCRIPTION] AS ProcessingState,                    -- TN_DOC_CHARACT_TYPE
C.[DESCRIPTION] as Characterization,                -- TN_DOC_CHARACTERIZATION
D.CAD_REF_FILE_NAME as CadRefFileName, D.DIRECTORY as Directory, D.[FILE_NAME] as [FileName]
FROM [EdgePLM COMPACT].dbo.Samples as DS
INNER JOIN [EdgePLM COMPACT].isap.TN_PROJECTS as P ON CAST(P.CN_PROJEKT_ID as int)=DS.ProjectId
INNER JOIN [EdgePLM COMPACT].isap.TN_DOCUMENTATION as D ON D.OBJECT_ID IN (SELECT OBJECT_ID FROM [EdgePLM COMPACT].[dbo].[GetLinksForSampleById] (288, P.OBJECT_ID))
INNER JOIN [EdgePLM COMPACT].isap.TN_DOC_CHARACTERIZATION as C ON D.CN_DOC_CHARACTERIZATION=C.OBJECT_ID
INNER JOIN [EdgePLM COMPACT].isap.TN_DOC_CHARACT_TYPE as CT ON CT.OBJECT_ID= D.CN_DOC_CHARACT_TYPE
LEFT OUTER JOIN [EdgePLM COMPACT].isap.TN_SUBSTRATE_MATERIAL as S ON D.CN_DOC_SUBSTRATE_MATERIAL=S.OBJECT_ID
WHERE P.CLASS_ID IN (462, 463)	-- sampleproject + subsampleproject
AND D.CLASS_ID=288	-- characterization     (4237 rows)
AND DS.ProjectId = @projectId
Order by CHARACTERIZATION
--@TypeName varchar(64)
SET @DocumentCount=0
SET @DocumentCountAdded=0
SET @DocumentCountExists=0
open cDoc
while (1=1)
begin
	fetch cDoc into @DocumentId, @ProcessingState, @Characterization, @CadRefFileName, @Directory, @FileName
	if @@fetch_status <> 0 break
	SET @TypeId = [dbo].[GetTypeIdForCompact](@Characterization, @ProcessingState, @CadRefFileName)
	SET @Characterization = UPPER(LEFT(@Characterization, 1)) + RIGHT(@Characterization, LEN(@Characterization)-1)
	SET @DocumentCount=@DocumentCount+1
	SET @ObjectId=NULL
	select @ObjectId=ObjectId from ObjectInfo where TenantId=@TenantId AND TypeId=@TypeId AND ExternalId=@DocumentId
	if @ObjectId>0	-- EXISTS
	begin
		PRINT '      Document already exists: ' + @Characterization + ' / ' + @ProcessingState + '. ' + @CadRefFileName + ' ExternalId=DocumentId=['+CAST(@DocumentId as varchar(16))+']'
		SET @DocumentCountExists = @DocumentCountExists + 1
	end
	else	-- NOT EXISTS
	begin
		--SET @SortCode = -90+@DocumentCount
		SET @SortCode = 0
		SET @ObjectId=0
		--SET @ObjectName = @Characterization + ' for ' + @SampleName + ' (' + @ProcessingState + ', ' + CAST(@DocumentId as varchar(16)) + ')'
		SET @ObjectName = TRIM(CAST(@projectId as varchar(16))) + ISNULL(' ' + @Characterization,'') + ' (' + @ProcessingState + ', ' + CAST(@DocumentId as varchar(16)) + ')'
		SET @ObjectDescription = @Characterization + ' for ' + @SampleDescription + ' (' + @ProcessingState + ', ' + CAST(@DocumentId as varchar(16)) + ')'
		SET @ObjectFilePath = @Directory + '\' + @FileName
		EXEC [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_date, @_userId, @_date,	@_userId, @TypeId, @RubricId, @SortCode,
		@AccessControl, @IsPublished, @DocumentId/*@ExternalId*/, @ObjectName, null/*@ObjectNameUrl*/, @ObjectFilePath,  @ObjectDescription, 0/*showResultsInRecordset*/ 
		PRINT '      Document CREATED: ' + @Characterization + ' / ' + @ProcessingState + '. ' + @CadRefFileName + ' ExternalId=DocumentId=['+CAST(@DocumentId as varchar(16))+', ObjectId='+CAST(@ObjectId as varchar(16))+']'
		SET @DocumentCountAdded = @DocumentCountAdded + 1
	end
PRINT @Directory + '\' + @FileName

	-- add links: 2 Document
	INSERT INTO @LinkedObjects(ObjectLinkObjectId, ObjectId, LinkedObjectId, SortCode)
		VALUES(NULL, @SampleId, @ObjectId, @SortCode)
end
close cDoc
deallocate cDoc
PRINT '   Total Documents: ' + CAST(@DocumentCount as varchar(16)) + ' (Added: ' + CAST(@DocumentCountAdded as varchar(16)) + '; Exists: ' + CAST(@DocumentCountExists as varchar(16)) + ')'
--- ========================================================== DOCUMENTS with links ========================================================== END ---

--- ========================================================== SYNTHESIS DOCUMENTS ========================================================== BEGIN ---
-- SYNTHESIS DOCUMENTS
SET @SynthCount=0;
declare cSynth cursor local for 
select D.OBJECT_ID as DocumentId, P.CN_SAMPLE_MATERIAL, P.CN_SAMPLE_DESCRIPTION,
DT.[DESCRIPTION] as DepositionDescription, 
D.CN_DOC_DEPOSITION_ID as DepositionId, 
--[EdgePLM COMPACT].[dbo].[GetChamberFromString](D.CN_DOC_DEPOSITION_ID) as ChamberDeposition,--------------------------
C.[DESCRIPTION] as Chamber
from [EdgePLM COMPACT].dbo.Samples as DS
INNER JOIN [EdgePLM COMPACT].isap.TN_PROJECTS as P ON CAST(P.CN_PROJEKT_ID as int)=DS.ProjectId
INNER JOIN [EdgePLM COMPACT].isap.TN_DOCUMENTATION as D ON D.OBJECT_ID IN (SELECT OBJECT_ID FROM [EdgePLM COMPACT].[dbo].[GetLinksForSampleById] (287, P.OBJECT_ID))
LEFT OUTER JOIN [EdgePLM COMPACT].isap.TN_CHAMBER as C ON C.OBJECT_ID=D.CN_DOC_CHAMBER
LEFT OUTER JOIN [EdgePLM COMPACT].isap.TN_DOC_DEPOSITION_TYPE as DT ON D.CN_DOC_DEPOSITION_TYPE=DT.OBJECT_ID
WHERE P.CLASS_ID IN (462, 463)	-- sampleproject + subsampleproject
AND D.CLASS_ID=287		-- deposition (118189 rows)
AND DS.ProjectId = @projectId
ORDER BY DepositionId
SET @DocumentCount=0
SET @DocumentCountAdded=0
SET @DocumentCountExists=0
SET @TypeId=[dbo].[GetTypeIdForCompact]('Synthesis', 'Synthesis', null)	-- Synthesis Document
open cSynth
while (1=1)
begin
	fetch cSynth into @DocumentId, @CN_SAMPLE_MATERIAL, @CN_SAMPLE_DESCRIPTION, @DepositionDescription, @DepositionId, @Chamber
	if @@fetch_status <> 0 break
	SET @DocumentCount=@DocumentCount+1
	--@TypeName varchar(64)
	SET @ObjectId=NULL
	select @ObjectId=ObjectId from ObjectInfo where TenantId=@TenantId AND TypeId=@TypeId AND ExternalId=@DocumentId
	if @ObjectId>0	-- EXISTS
	begin
		PRINT '      Synthesis document already exists: ' + @CN_SAMPLE_MATERIAL + ' / ' + @CN_SAMPLE_DESCRIPTION + '. ' + @DepositionDescription + ', ' + @DepositionId + ', ' + @Chamber + ' ExternalId=DocumentId=['+CAST(@DocumentId as varchar(16))+']'
		SET @DocumentCountExists = @DocumentCountExists + 1
	end
	else	-- NOT EXISTS
	begin
		-- SET @SortCode = -99+@DocumentCount
		SET @SortCode = 0
		SET @ObjectId=0
		--SET @ObjectName = 'Synthesis for Sample ' + CAST(@projectId as varchar(16))+ ' (' + ISNULL(@DepositionDescription,'') + ISNULL(', '+@DepositionId,'') + ISNULL(', id='+CAST(@DocumentId as varchar(16)),'') + ')'
		SET @ObjectName = CAST(@projectId as varchar(16))+ ' synthesis (' + ISNULL(@DepositionDescription,'') + ISNULL(', '+@DepositionId,'') + ISNULL(', id='+CAST(@DocumentId as varchar(16)),'') + ')'
		SET @ObjectDescription = 'Synthesis for Sample ' + CAST(@projectId as varchar(16))+ ' (' + ISNULL(@DepositionDescription,'') + ISNULL(', '+@DepositionId,'') + ISNULL(', '+@Chamber,'') + ISNULL(', '+@CN_SAMPLE_DESCRIPTION,'') + ')'
		SET @ObjectFilePath = null
		EXEC [dbo].[ObjectInfo_UpdateInsert] @ObjectId output, @TenantId, @_date, @_userId, @_date,	@_userId, @TypeId, @RubricId, @SortCode,
		@AccessControl, @IsPublished, @DocumentId/*@ExternalId*/, @ObjectName, null/*@ObjectNameUrl*/, @ObjectFilePath,  @ObjectDescription, 0/*showResultsInRecordset*/ 
		PRINT '      Synthesis document CREATED: ' + @ObjectName + ' ExternalId=DocumentId=['+CAST(@DocumentId as varchar(16))+', ObjectId='+CAST(@ObjectId as varchar(16))+']'
		SET @DocumentCountAdded = @DocumentCountAdded + 1

		-- Create Properties: @projectId, @DocumentId => @ObjectId
		EXEC dbo.[TransferSynthesisProperties] @projectId, @DocumentId, 1/*@SkipEmptyValues*/, @TenantId, @ObjectId, @_date, @_userId, @DeletePreviousProperties, @TemplateObjectIdSynthesis
	end

	-- add links: 3 Synthesis
	INSERT INTO @LinkedObjects(ObjectLinkObjectId, ObjectId, LinkedObjectId, SortCode)
		VALUES(NULL, @SampleId, @ObjectId, @SortCode)

end
close cSynth
deallocate cSynth
PRINT '   Total Synthesis Documents: ' + CAST(@DocumentCount as varchar(16)) + ' (Added: ' + CAST(@DocumentCountAdded as varchar(16)) + '; Exists: ' + CAST(@DocumentCountExists as varchar(16)) + ')'
--- ========================================================== SYNTHESIS DOCUMENTS ========================================================== END ---



-- select * from [EdgePLM COMPACT].isap.TN_DOC_CHARACT_TYPE	-- Raw Data / Processed Data / Quality assured / ML-ready data set / Final result
-- select * from [EdgePLM COMPACT].isap.TN_DOC_CHARACTERIZATION	-- photo / XRD / chem. composition / thickness / SEM (image) / TEM image / nanoindentation / oscilloscope / el. resistance / XPS / synchrotron / ERDA (deprecated) / topography / other / magnetic properties / VSM (deprecated) / UV-VIS / APT / TEM diffraction


-- put links into DB
	--select * from @LinkedObjects
	EXEC [dbo].[ObjectLinkObject_LinksUpdate] @LinkedObjects, @TenantId, @SampleId, @_date, @_userId, @_date, @_userId, 1/*skipOutput*/ -- skip final recordset output
PRINT 'Links written'
	RETURN @retval;	-- sample added
GO
/****** Object:  StoredProcedure [dbo].[TransferSamples]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TransferSamples]
@projectsIds dbo.Integers readonly,
@TenantId int=4,	-- crc1625.mdi.ruhr-uni-bochum.de
@TypeIdRubric int=2,	-- Type for rubric == Sample	(0 - Rubric is ready - take @ParentRubricId)
@ParentRubricId int=140, -- Area A / A01 / Preliminary work for proposal and evaluation Ag-Au-Cu-Pd-Pt (Rubric Where we need to create subrubric for Sample)
@AccessControl int=1,	-- protected
@IsPublished bit=1,		-- true
@_userId int=1,		-- some user
@RubricId_Substrate int=269,	-- if new substrate needs to be added, then this the RubricId for substrates
@DeletePreviousProperties bit=0,		-- delete all destination object properties (and recreate them)
@TemplateObjectIdSynthesis int=0		-- ObjectId of "_Template" object for synthesys (TypeId=18)
-- EXEC dbo.[TransferSample] 8457, 4, 2, 140, 1, 1, 1
-- EXEC dbo.[TransferSample] 8250, 4, 2, 140, 1, 1, 1
-- RubricId=140 - 25 samples (Area A / A01 / Preliminary work for proposal and evaluation Ag-Au-Cu-Pd-Pt)
-- DECLARE @projectsIds as dbo.Integers; declare @Elements dbo.Elements; insert into @Elements values('Ag'),('Au'),('Cu'),('Pd'),('Pt'); INSERT INTO @projectsIds([Value]) SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1; EXEC dbo.[TransferSamples] @projectsIds, 4, 2, 140, 1, 1, 1
-- RubricId=228 - 22 samples (Area A / A01 / Preliminary work for proposal and evaluation Ir-Pd-Pt-Rh-Ru)
-- DECLARE @projectsIds as dbo.Integers; declare @Elements dbo.Elements; insert into @Elements values('Ir'),('Pd'),('Pt'),('Rh'),('Ru'); INSERT INTO @projectsIds([Value]) SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1; EXEC dbo.[TransferSamples] @projectsIds, 4, 2, 228, 1, 1, 1
-- RubricId=270 - 803 (Added: 756; Exists: 47) (Area A / A01 / Preliminary work for proposal and evaluation - other)
/*
declare @Elements dbo.Elements;
declare @projectsIds dbo.Integers;
DELETE FROM @Elements; insert into @Elements values('Ag'),('Au'),('Cu'),('Pd'),('Pt');
INSERT INTO @projectsIds
	SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 ORDER BY ElemNumber, [Elements]
DELETE FROM @Elements; insert into @Elements values('Ir'),('Pd'),('Pt'),('Rh'),('Ru');
INSERT INTO @projectsIds
	SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 ORDER BY ElemNumber, [Elements]
-- SELECT * FROM @Projects

DELETE FROM @Elements; Insert into @Elements values('Ag');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Au');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Cu');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Pd');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Pt');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Ir');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Rh');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
DELETE FROM @Elements; Insert into @Elements values('Ru');
	INSERT INTO @projectsIds SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples WHERE dbo.IsSystemContainsAllElements([Elements], @Elements)=1 AND ProjectId NOT IN (select Value from @projectsIds);
--SELECT * FROM @projectsIds
--select * from [EdgePLM COMPACT].dbo.Samples WHERE ProjectId in (select Value from @projectsIds) ORDER BY ElemNumber, Elements
EXEC dbo.[TransferSamples] @projectsIds, 4, 2, 270, 1, 1, 1
*/
-- select * from ObjectInfo WHERE TenantId=4
as

DECLARE @retval int;
DECLARE @SampleId int;
DECLARE @projectId int;
DECLARE @SamplesCountAdded int = 0, @SamplesCountExists int = 0;
-- [EdgePLM COMPACT].dbo.Samples
declare c1 cursor local for select [Value] from @projectsIds
		order by [Value]
open c1
while (1=1)
begin
	fetch c1 into @projectId
	if @@fetch_status <> 0 break
	PRINT '--- Processing ProjectId=' + CAST(@projectId as varchar(16))
	EXEC @retval = dbo.[TransferSample] @SampleId output, @projectId, @TenantId, @TypeIdRubric, @ParentRubricId, @AccessControl, @IsPublished, @_userId, @RubricId_Substrate, @DeletePreviousProperties, @TemplateObjectIdSynthesis
	if @retval=0
		SET @SamplesCountExists = @SamplesCountExists + 1
	else
		SET @SamplesCountAdded = @SamplesCountAdded + 1
end
close c1
deallocate c1
PRINT 'TransferSamples. Total samples: ' + CAST(@SamplesCountExists+@SamplesCountAdded as varchar(16)) + ' (Added: ' + CAST(@SamplesCountAdded as varchar(16)) + '; Exists: ' + CAST(@SamplesCountExists as varchar(16)) + ')'
----- ========== CLEANUP - BEGIN ============== -----
-- select * from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=4)
/*

-- delete links	: select * from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=4)
delete from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=4 AND ExternalId IS NOT NULL)
-- delete Properties (in Synthesis Objects)
delete from PropertyString WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=4 AND ExternalId IS NOT NULL)
-- delete synthesis
delete from ObjectInfo WHERE TenantId=4 AND TypeId=18 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228, 270))
-- delete documents (raw 7)
delete from ObjectInfo WHERE TenantId=4 AND TypeId IN (7, 12, 13, 15) AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228, 270))
-- delete samples
delete from ObjectInfo WHERE TenantId=4 AND TypeId=6 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228, 270))
-- DELETE RUBRICS
DELETE FROM dbo.RubricInfo WHERE TenantId=4 and ParentID IN (140, 228, 270)
*/
-- select * from ObjectInfo WHERE _created>'20230324'
-- DUPLICATION of ExternalId
-- select count(ObjectId) as count, ExternalId from ObjectInfo WHERE TenantId=4 GROUP BY ExternalId HAVING count(ExternalId)>1
-- select * from ObjectInfo WHERE TenantId=4 
----- ========== CLEANUP - END   ============== -----

----- ========== FILE NAMES - BEGIN   ============== -----
-- select * from ObjectInfo WHERE TenantId=4 /*AND TypeId=7*/ AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))
-- 0. Prepare FileNames By Running SQL:
-- select REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\registriert\', '') as [File] from ObjectInfo WHERE TenantId=4 /*AND TypeId=7*/ AND ExternalId IS NOT NULL /*AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND ObjectFilePath IS NOT NULL ORDER BY [File]
-- 1. Copy FileNames to .171 : D:\SQL_Backup\CopyList.txt
-- 2. Run on .171 : D:\SQL_Backup\Copy.bat
-- 3. Copy Files from .171 : D:\SQL_Backup\Files folder to VM .37 in D:\RUB_INF\tenant4\compact
-- 4. Update filePaths In INF db by running:
-- UPDATE ObjectInfo SET ObjectFilePath = '/tenant4/compact/' + REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\registriert\', '')  WHERE TenantId=4 /*AND TypeId=7*/ AND ExternalId IS NOT NULL /*AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND LEFT(ObjectFilePath, 15)='\\wdm-sql01\EPC'
-- 5. Recalculate hash by visiting /srv/ and pressing "Recalculate File Hash" button
-- 6. Track errors on missing files:
-- select * from ObjectInfo where LEN(ObjectFilePath)>0 AND ObjectFileHash IS NULL
----- ========== FILE NAMES - END   ============== -----
GO
/****** Object:  StoredProcedure [dbo].[TransferSamplesWithRubrics]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TransferSamplesWithRubrics]
@projectsIds dbo.Integers readonly,
@TenantId int=1,	-- inf.mdi.ruhr-uni-bochum.de
@TypeIdRubric int=2,	-- Type for rubric == Sample	(0 - Rubric is ready - take @ParentRubricId)
@RubricPathStart varchar(256)='COMPACT}', -- '}'-separated path to arrach compact project tree (empty - root)
@AccessControl int=1,	-- protected
@IsPublished bit=1,		-- true
@_userId int=2,		-- some user
@RubricId_Substrate int=269,	-- if new substrate needs to be added, then use this the RubricId for substrates
@DeletePreviousProperties bit=0,		-- delete all destination object properties (and recreate them)
@TemplateObjectIdSynthesis int=0		-- ObjectId of "_Template" object for synthesys (TypeId=18)
/*	-- select * from [EdgePLM COMPACT].dbo.Samples
declare @projectsIds dbo.Integers;
INSERT INTO @projectsIds
	SELECT ProjectId FROM [EdgePLM COMPACT].dbo.Samples -- WHERE ProjectId=1993 -- CreatedByPerson='Piotrowiak Tobias'
	order by ProjectId
EXEC dbo.[TransferSamplesWithRubrics] @projectsIds, 7, 2, 'COMPACT}', 1, 1, 2, 1093, 1, 12865
--EXEC dbo.[TransferSamplesWithRubrics] @projectsIds, 1, 2, 'Area C}C04}', 1, 1, 13, 202
--EXEC dbo.[TransferSamplesWithRubrics] @projectsIds, 5, 2, 'Area C}C04}', 1, 1, 13, 202
*/
-- select * from ObjectInfo WHERE TenantId=4
as
DECLARE @Separator varchar(16)='}'	-- separator between rubrics
DECLARE @RubricPath varchar(256)
DECLARE @CreateRubric bit=1			-- create rubrics by path (0 - no, 1 - yes)
DECLARE @retval int;
DECLARE @SampleId int;
DECLARE @projectId int, @RubricId int;
DECLARE @SamplesCountAdded int = 0, @SamplesCountExists int = 0;

-- [EdgePLM COMPACT].dbo.Samples
declare c1 cursor local for select [Value] from @projectsIds
		order by [Value]
open c1
while (1=1)
begin
	fetch c1 into @projectId
	if @@fetch_status <> 0 break
	PRINT '--- Processing ProjectId=' + CAST(@projectId as varchar(16))
	SET @RubricPath = [EdgePLM COMPACT].[dbo].[GetRubricPathString](@projectId, @Separator)
	SET @RubricPath = @RubricPathStart + @RubricPath
	EXEC @RubricId = [dbo].[_GetRubricIdByRubricPath] @TenantId, @RubricPath, @Separator, @CreateRubric, @TypeIdRubric, @_userId, @AccessControl, @IsPublished;
	--SET @RubricPath = ((@RubricPathStart collate Latin1_General_CI_AS) + [EdgePLM COMPACT].[dbo].[GetRubricPathString](@projectId, @Separator collate Latin1_General_CI_AS) collate Latin1_General_100_CI_AS_KS_SC_UTF8)
	EXEC @retval = dbo.[TransferSample] @SampleId output, @projectId, @TenantId, /*@TypeIdRubric*/0, @RubricId, @AccessControl, @IsPublished, @_userId, @RubricId_Substrate, @DeletePreviousProperties, @TemplateObjectIdSynthesis
	if @retval=0
		SET @SamplesCountExists = @SamplesCountExists + 1
	else
		SET @SamplesCountAdded = @SamplesCountAdded + 1
end
close c1
deallocate c1
EXEC [dbo].[ProcRubric_NormaliseTree] @TenantId, @TypeIdRubric
PRINT 'TransferSamples. Total samples: ' + CAST(@SamplesCountExists+@SamplesCountAdded as varchar(16)) + ' (Added: ' + CAST(@SamplesCountAdded as varchar(16)) + '; Exists: ' + CAST(@SamplesCountExists as varchar(16)) + ')'
----- ========== CLEANUP - BEGIN ============== -----
-- select * from Tenant
-- select * from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=7)
/*
--DECLARE @TenantId int=5	-- CRC247
--DECLARE @RubricPath varchar(256)='Area C}C04}%'	-- CRC247
DECLARE @TenantId int=7	-- mdi.matinf.pro
DECLARE @RubricPath varchar(256)='COMPACT}%'	-- mdi.matinf.pro
-- delete links	: select * from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=@TenantId)
delete from ObjectLinkObject WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=@TenantId AND ExternalId IS NOT NULL)
-- delete Properties (in Synthesis Objects)
delete from PropertyInt WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=@TenantId AND ExternalId IS NOT NULL)
delete from PropertyFloat WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=@TenantId AND ExternalId IS NOT NULL)
delete from PropertyString WHERE ObjectId IN (select ObjectId from ObjectInfo where TenantId=@TenantId AND ExternalId IS NOT NULL)
-- delete synthesis (TypeID=18)
delete from ObjectInfo WHERE TenantId=@TenantId AND TypeId=18 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE RubricPath LIKE @RubricPath)
-- delete documents (raw)
delete from ObjectInfo WHERE TenantId=@TenantId AND /*TypeId IN (7, 12, 13, 15) AND */ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE RubricPath LIKE @RubricPath)
-- delete samples
delete from ObjectInfo WHERE TenantId=@TenantId AND TypeId=6 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE RubricPath LIKE @RubricPath)
-- DELETE RUBRICS
DELETE FROM dbo.RubricInfo WHERE TenantId=@TenantId and RubricPath LIKE @RubricPath
*/


-- select * from ObjectInfo WHERE _created>'20230324'
-- DUPLICATION of ExternalId
-- select count(ObjectId) as count, ExternalId from ObjectInfo WHERE TenantId=4 GROUP BY ExternalId HAVING count(ExternalId)>1
-- select * from ObjectInfo WHERE TenantId=4 
----- ========== CLEANUP - END ============== -----

----- ========== FILE NAMES - BEGIN   ============== -----
-- select * from ObjectInfo WHERE TenantId=7 /*AND TypeId=7*/ AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))
-- 0. Prepare FileNames By Running SQL:
-- select REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\registriert\', '') as [File] from ObjectInfo WHERE TenantId=7 /*AND TypeId=7 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND ObjectFilePath IS NOT NULL ORDER BY [File]
-- select REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\freigegeben\', '') as [File] from ObjectInfo WHERE TenantId=7 /*AND TypeId=7 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND ObjectFilePath IS NOT NULL ORDER BY [File]
-- 1. Copy FileNames to .171 : D:\SQL_Backup\CopyList.txt
-- 2. Run on .171 : D:\SQL_Backup\Copy.bat
-- 3. Copy Files from .171 : D:\SQL_Backup\Files folder to VM .37 in D:\RUB_INF\tenant4\compact
-- 4. Update filePaths In INF db by running:
-- UPDATE ObjectInfo SET ObjectFilePath = '/tenant7/compact/' + REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\registriert\', '')  WHERE TenantId=7 /*AND TypeId=7 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND LEFT(ObjectFilePath, 36)='\\wdm-sql01\EPC\Tresore\registriert\'
-- UPDATE ObjectInfo SET ObjectFilePath = '/tenant7/compact/' + REPLACE(ObjectFilePath, '\\wdm-sql01\EPC\Tresore\freigegeben\', '')  WHERE TenantId=7 /*AND TypeId=7 AND ExternalId IS NOT NULL AND RubricId IN (select RubricId from dbo.RubricInfo WHERE ParentID IN (140, 228))*/ AND LEFT(ObjectFilePath, 36)='\\wdm-sql01\EPC\Tresore\freigegeben\'
-- 5. Recalculate hash by visiting /srv/ and pressing "Recalculate File Hash" button
-- 6. Track errors on missing files:
-- select * from ObjectInfo where LEN(ObjectFilePath)>0 AND ObjectFileHash IS NULL
----- ========== FILE NAMES - END   ============== -----
GO
/****** Object:  StoredProcedure [dbo].[TransferSynthesisProperties]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TransferSynthesisProperties]
@ProjectId int,
@DocumentId int=null, -- NOT NULL!
@SkipEmptyValues bit=0,	-- 1 - preffered
@TenantId int,
@ObjectIdDestination int=0,
@_date datetime=null,
@_userId int=1,
@DeletePreviousProperties bit=0,		-- delete all destination object properties (and recreate them)
@TemplateObjectIdSynthesis int=0		-- ObjectId of "_Template" object for synthesys (TypeId=18)
-- EXEC [EdgePLM COMPACT].dbo.GetSampleSynthesisWithTree 8457, 66968, 1		-- 50 rows
-- DECLARE @_date datetime=getdate(); EXEC dbo.[TransferSynthesisProperties] 8220, 64237, 1, 7, 15270, @_date, 1, 1 /*DeletePreviousProperties*/, 12865 /*@TemplateObjectIdSynthesis*/
AS
-- ========================= SYNTHESIS  JOINED WITH TREE =====================
DECLARE @Row int, @SortCode int=0, @retval int = 0, @spret int = 0, @FloatCount int=0, @StringCount int=0
DECLARE @Path varchar(128), @Description varchar(255), @Value varchar(20), @Unit varchar(255), @IsString int, @TemplSortCode int, @sort int
DECLARE @PropertyId int, @ValueInt bigint, @ValueFloat float, @ValueString varchar(4096), @ValueEpsilon float, @PropertyName varchar(256), @Comment varchar(256)
DECLARE @msg varchar(256)
SET @_date = getdate()
IF NOT EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId>0 AND ObjectId=@ObjectIdDestination)
begin
	SET @msg = 'Error (TransferSynthesisProperties): ObjectId must be in the same tenant [@TenantId='+CAST(@TenantId as varchar(8))+']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end

IF @DeletePreviousProperties=1	-- delete all destination object properties
BEGIN
	DELETE FROM dbo.PropertyBigString WHERE ObjectId=@ObjectIdDestination;
	DELETE FROM dbo.PropertyFloat WHERE ObjectId=@ObjectIdDestination;
	DELETE FROM dbo.PropertyInt WHERE ObjectId=@ObjectIdDestination;
	DELETE FROM dbo.PropertyString WHERE ObjectId=@ObjectIdDestination;
END;
declare cSynthProp cursor local for 
select T.[Path], K.CN_DESCRIPTION as [Description], L.CN_CHAR_VALUE as [Value], K.CN_UNIT as Unit, T.ValueType as IsString, Templ.SortCode--, T.ValueTypeDescription
from [EdgePLM COMPACT].dbo.Samples as DS
INNER JOIN [EdgePLM COMPACT].isap.TN_PROJECTS as P ON CAST(P.CN_PROJEKT_ID as int)=DS.ProjectId
INNER JOIN [EdgePLM COMPACT].isap.TN_DOCUMENTATION as D ON D.OBJECT_ID IN (SELECT OBJECT_ID FROM [EdgePLM COMPACT].[dbo].[GetLinksForSampleById] (287, P.OBJECT_ID))
INNER JOIN [EdgePLM COMPACT].isap.TDM_K_LINKS as L ON L.OBJECT_ID1=D.OBJECT_ID
INNER JOIN [EdgePLM COMPACT].isap.TN_KLASSIFIZIERUNG as K ON L.OBJECT_ID2=K.OBJECT_ID
LEFT OUTER JOIN [EdgePLM COMPACT].dbo.TREE as T ON T.ObjectId=L.OBJECT_ID2	 -- NEW WAY==OLD WAY (TheSame)
	AND T.ParentId IN (select OBJECT_ID2 FROM [EdgePLM COMPACT].isap.TDM_K_LINKS WHERE OBJECT_ID1=D.OBJECT_ID)						-- OK, the best
LEFT OUTER JOIN dbo.fn_GetObjectNonTableProperties(@TemplateObjectIdSynthesis) as Templ ON (Templ.PropertyName collate Latin1_General_CI_AS)=T.[Path]
-- 	SELECT PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
--		ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment FROM dbo.fn_GetObjectNonTableProperties
WHERE P.CLASS_ID IN (462, 463)	-- sampleproject + subsampleproject
AND D.CLASS_ID=287		-- deposition (118189 rows)
AND DS.ProjectId = @ProjectId
	and T.[Path] IS NOT NULL	-- to omit bare classes
	and CAST(D.OBJECT_ID as int) = @DocumentId
	AND L.CN_CHAR_VALUE=IIF(@SkipEmptyValues=1 AND L.CN_CHAR_VALUE='', 'Q', L.CN_CHAR_VALUE)
ORDER BY D.CN_DOC_DEPOSITION_ID, T.Path2SortString, K.CN_KL_ID
open cSynthProp
while (1=1)
begin
	fetch cSynthProp into @Path, @Description, @Value, @Unit, @IsString, @TemplSortCode
	-- @Description => 'Name' -- IGNORED
	if @@fetch_status <> 0 break
	SET @SortCode = @SortCode+10
	SET @Row = @Row+1	-- not a row (just for count)
	if LEN(ISNULL(@Path,''))>0 AND LEN(ISNULL(@Value,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = @Path
		SET @Comment = @Unit
		IF @IsString=0
		begin
			SET @Value = REPLACE(@Value, 'x10^', 'E')
			SET @Value = REPLACE(@Value, 'x10', 'E')
			SET @Value = REPLACE(@Value, '*10^', 'E')
			SET @Value = REPLACE(@Value, '*10', 'E')
			SET @Value = REPLACE(@Value, ',', '.')
		end
		SET @ValueFloat = TRY_PARSE(@Value AS float USING 'en-US')
		IF @IsString=0 AND @ValueFloat IS NULL	-- float ==> string
		BEGIN
			RAISERROR (N'WARNING TransferSynthesisProperties: downgrading to string for unparsed float property value "%s" [%s; Unit=%s; ProjectId=%d; DocumentId=%d]', -- Message text.
				10, -- Severity,
				1, -- State,
				@Value, -- First argument
				@Path, -- Second argument
				@Unit, -- Third argument
				@ProjectId, @DocumentId); -- 4/5
			SET @retval = @retval + 1;
		END
		SET @sort = ISNULL(@TemplSortCode, @SortCode);
		IF @IsString=0 AND @ValueFloat IS NOT NULL	-- float
		begin
			EXEC @spret = dbo.PropertyFloat_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @sort, @_date, @_userId, @_date, @_userId, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment
			SET @FloatCount = @FloatCount + 1
		end
		ELSE	-- string
		begin
			EXEC @spret = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @sort, @_date, @_userId, @_date, @_userId, @Row, @Value, @ValueEpsilon, @PropertyName, @Comment
			SET @StringCount = @StringCount + 1
		end
	end
end
close cSynthProp
deallocate cSynthProp
PRINT 'Total Synthesis Properties: ' + CAST(@Row as varchar(16)) + ' properties (' + CAST(@FloatCount as varchar(16)) + ' float; ' + CAST(@StringCount as varchar(16)) + ' string) added [ProjectId='+ CAST(@ProjectId as varchar(16)) +', DocumentId=' + CAST(@DocumentId as varchar(16)) + ']'
GO
/****** Object:  StoredProcedure [dbo].[TransferSynthesisProperties_Batch]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferSynthesisProperties_Batch]
@TenantId int,
@_date datetime=null,
@_userId int=1,
@DeletePreviousProperties bit=1,		-- delete all destination object properties (and recreate them)
@TemplateObjectIdSynthesis int=0		-- ObjectId of "_Template" object for synthesys (TypeId=18)
-- DECLARE @_date datetime=getdate(); EXEC [dbo].[TransferSynthesisProperties_Batch] 5, @_date, 2, 1, 1956;
AS
DECLARE @i int=0;
DECLARE @projectId int, @DocumentId int, @ObjectId int;
declare cSynthProp cursor local FAST_FORWARD for
	select ObjectId, ExternalId from ObjectInfo WHERE TypeId=[dbo].[GetTypeIdForCompact]('Synthesis', 'Synthesis', null) ORDER BY ObjectId
open cSynthProp
while (1=1)
begin
	fetch cSynthProp into @ObjectId, @DocumentId
	if @@fetch_status <> 0 break
	SET @projectId=NULL
	select @projectId = CAST(CN_DOC_SAMPLE_ID as int) from [EdgePLM COMPACT].isap.TN_DOCUMENTATION where OBJECT_ID=@DocumentId
	
	-- Create Properties: @projectId, @DocumentId => @ObjectId
	EXEC dbo.[TransferSynthesisProperties] @projectId, @DocumentId, 1/*@SkipEmptyValues*/, @TenantId, @ObjectId, @_date, @_userId, @DeletePreviousProperties
	SET @i = @i + 1
	PRINT CAST(@i as varchar(32)) + '. DocumentId: ' + CAST(@DocumentId as varchar(32))
end
close cSynthProp
deallocate cSynthProp


GO
/****** Object:  StoredProcedure [dbo].[TransferSynthesisProperties_TableString]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TransferSynthesisProperties_TableString]
@ProjectId int,
@DocumentId int=null, -- NOT NULL!
@SkipEmptyValues bit=0,	-- 1 - preffered
@TenantId int,
@ObjectIdDestination int=0,
@_date datetime=null,
@_userId int=1
-- EXEC [EdgePLM COMPACT].dbo.GetSampleSynthesisWithTree 8457, 66968, 1		-- 50 rows
-- DECLARE @_date datetime=getdate(); EXEC dbo.[TransferSynthesisProperties] 8457, 66968, 1, 4, 6742, @_date, 1
AS
-- ========================= SYNTHESIS  JOINED WITH TREE =====================
DECLARE @Row int=0, @SortCode int, @retval int
DECLARE @Path varchar(128), @Description varchar(255), @Value varchar(20), @Unit varchar(255), @IsString int
DECLARE @PropertyId int, @ValueInt bigint, @ValueFloat float, @ValueString varchar(4096), @ValueEpsilon float, @PropertyName varchar(256), @Comment varchar(256)
SET @_date = getdate()
declare cSynthProp cursor local for 
select T.[Path], K.CN_DESCRIPTION as [Description], L.CN_CHAR_VALUE as [Value], K.CN_UNIT as Unit, T.ValueType as IsString--, T.ValueTypeDescription
from [EdgePLM COMPACT].dbo.Samples as DS
INNER JOIN [EdgePLM COMPACT].isap.TN_PROJECTS as P ON CAST(P.CN_PROJEKT_ID as int)=DS.ProjectId
INNER JOIN [EdgePLM COMPACT].isap.TN_DOCUMENTATION as D ON D.OBJECT_ID IN (SELECT OBJECT_ID FROM [EdgePLM COMPACT].[dbo].[GetLinksForSampleById] (287, P.OBJECT_ID))
INNER JOIN [EdgePLM COMPACT].isap.TDM_K_LINKS as L ON L.OBJECT_ID1=D.OBJECT_ID
INNER JOIN [EdgePLM COMPACT].isap.TN_KLASSIFIZIERUNG as K ON L.OBJECT_ID2=K.OBJECT_ID
LEFT OUTER JOIN [EdgePLM COMPACT].dbo.TREE as T ON T.ObjectId=L.OBJECT_ID2	 -- NEW WAY==OLD WAY (TheSame)
	AND T.ParentId IN (select OBJECT_ID2 FROM [EdgePLM COMPACT].isap.TDM_K_LINKS WHERE OBJECT_ID1=D.OBJECT_ID)						-- OK, the best
WHERE P.CLASS_ID IN (462, 463)	-- sampleproject + subsampleproject
AND D.CLASS_ID=287		-- deposition (118189 rows)
AND DS.ProjectId = @ProjectId
	and T.[Path] IS NOT NULL	-- to omit bare classes
	and CAST(D.OBJECT_ID as int) = @DocumentId
	AND L.CN_CHAR_VALUE=IIF(@SkipEmptyValues=1 AND L.CN_CHAR_VALUE='', 'Q', L.CN_CHAR_VALUE)
ORDER BY D.CN_DOC_DEPOSITION_ID, T.Path2SortString, K.CN_KL_ID
open cSynthProp
while (1=1)
begin
	fetch cSynthProp into @Path, @Description, @Value, @Unit, @IsString
	if @@fetch_status <> 0 break
	SET @Row=@Row+1
	if LEN(ISNULL(@Path,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Path'
		SET @ValueString = @Path
		SET @Comment = NULL
		SET @SortCode=10
		EXEC @retval = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Description,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Name'
		SET @ValueString = @Description
		SET @Comment = NULL
		SET @SortCode=20
		EXEC @retval = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Value,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Value'
		SET @ValueString = @Value
		SET @Comment = NULL
		SET @SortCode=30
		EXEC @retval = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end
	if LEN(ISNULL(@Unit,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = 'Unit'
		SET @ValueString = @Unit
		SET @Comment = NULL
		SET @SortCode=40
		EXEC @retval = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueString, @ValueEpsilon, @PropertyName, @Comment
	end

end
close cSynthProp
deallocate cSynthProp
PRINT 'Total Synthesis Properties: ' + CAST(@Row as varchar(16)) + ' rows added [ProjectId='+ CAST(@ProjectId as varchar(16)) +', DocumentId=' + CAST(@DocumentId as varchar(16)) + ']'
GO
/****** Object:  StoredProcedure [dbo].[TransferSynthesisProperties_Template]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[TransferSynthesisProperties_Template]
@TenantId int,
@ObjectIdDestination int,	-- with name == "_Template"
@_date datetime,
@_userId int
-- select * from Tenant WHERE TenantId=4	-- crc1625.mdi.ruhr-uni-bochum.de
-- select * from ObjectInfo where ObjectId=11087
-- DELETE FROM PropertyFloat WHERE ObjectId=11087; DELETE FROM PropertyInt WHERE ObjectId=11087; DELETE FROM PropertyString WHERE ObjectId=11087
-- DECLARE @_date datetime=getdate(); EXEC dbo.TransferSynthesisProperties_Template 4, 11087, @_date, 1
as
DECLARE @Row int, @SortCode int=0, @retval int = 0, @spret int = 0, @FloatCount int=0, @StringCount int=0, @IntCount int=0
DECLARE @Path varchar(128), @Description varchar(255), @Value varchar(20), @Unit varchar(255), @IsString int
DECLARE @PropertyId int, @ValueInt bigint, @ValueFloat float=0, @ValueString varchar(4096)='', @ValueEpsilon float, @PropertyName varchar(256), @Comment varchar(256)
DECLARE @msg varchar(256)
DECLARE @Level int, @DeleteOnNullValues bit=1

declare cSynthProp cursor local for 
SELECT ROW_NUMBER() over (order by Path2SortString)*10 as SortCode, [Level], [Path]
      ,[Unit]      ,IIF([ValueType]=0, 0, IIF([ValueType] IS NULL, NULL, 1)) as IsString--     ,[ValueTypeDescription]
  FROM [EdgePLM COMPACT].[dbo].[TREE]
  -- WHERE ValueType IS NOT NULL
  ORDER BY Path2SortString
open cSynthProp
while (1=1)
begin
	fetch cSynthProp into @SortCode, @Level, @Path, @Unit, @IsString
	-- @Description => 'Name' -- IGNORED
	if @@fetch_status <> 0 break
	if LEN(ISNULL(@Path,''))>0
	begin
		SET @PropertyId=NULL
		SET @PropertyName = @Path
		SET @Comment = @Unit

		IF @IsString=0	-- float
		begin
			SET @ValueFloat=-1
			EXEC @spret = dbo.PropertyFloat_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueFloat, @ValueEpsilon, @PropertyName, @Comment, @DeleteOnNullValues
			SET @FloatCount = @FloatCount + 1
		end
		ELSE IF @IsString=1	-- string
		begin
			SET @Value='-1'
			EXEC @spret = dbo.PropertyString_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @Value, @ValueEpsilon, @PropertyName, @Comment, @DeleteOnNullValues
			SET @StringCount = @StringCount + 1
		end
		ELSE
		begin
			SET @ValueInt = @Level
			SET @Comment = 'SEPARATOR'
			EXEC @spret = dbo.PropertyInt_UpdateInsert @TenantId, @PropertyId output, @ObjectIdDestination, @SortCode, @_date, @_userId, @_date, @_userId, @Row, @ValueInt, @ValueEpsilon, @PropertyName, @Comment, @DeleteOnNullValues
			SET @IntCount = @IntCount + 1
		end
	end
end
close cSynthProp
deallocate cSynthProp
PRINT 'Total Synthesis Template Properties: ' + CAST(@FloatCount+@StringCount+@IntCount as varchar(16)) + ' properties (' + CAST(@FloatCount as varchar(16)) + ' float; ' + CAST(@StringCount as varchar(16)) + ' string; ' + CAST(@IntCount as varchar(16)) + ' int) added [TenantId='+ CAST(@TenantId as varchar(16)) +', ObjectIdDestination=' + CAST(@ObjectIdDestination as varchar(16)) + ']'
GO
/****** Object:  StoredProcedure [dbo].[TypeInfo_UpdateInsert]    Script Date: 16/10/2024 18:34:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[TypeInfo_UpdateInsert]
@TypeId int output,
@IsHierarchical bit,
@TypeIdForRubric int,
@TypeName varchar(64),
@TableName varchar(64),
@UrlPrefix varchar(64),
@TypeComment varchar(256),
@ValidationSchema varchar(256),
@DataSchema varchar(256),
@FileRequired bit,
@SettingsJson varchar(8000)=null
AS
-- EXEC dbo.ProcRubric_NormaliseTree 1, 1
SET NOCOUNT ON;
DECLARE @msg varchar(256)
IF @TypeName IS NULL OR LEN(@TypeName)=0
begin
	RAISERROR ('Error (TypeInfo_UpdateInsert): Name can not be empty', 16, 0);
	RETURN 0;
end
IF NOT EXISTS(select t.name from sys.tables t where schema_name(t.schema_id) = 'dbo' and LEFT(t.name,6)<>'AspNet' AND t.name<>'__EFMigrationsHistory' and t.name=@TableName)
begin
	SET @msg = 'Error (TypeInfo_UpdateInsert): Table ['+@TableName+'] can not be found'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end
DECLARE @TableNameDB varchar(64), @IsHierarchicalDB bit, @TypeIdForRubricDB int
SELECT @TableNameDB=TableName, @IsHierarchicalDB=IsHierarchical, @TypeIdForRubricDB=TypeIdForRubric FROM dbo.TypeInfo WHERE TypeId>0 AND TypeId=@TypeId
IF @TypeId>0 AND (@TableNameDB<>@TableName OR @IsHierarchicalDB<>@IsHierarchical OR (@TypeIdForRubricDB IS NOT NULL AND @TypeIdForRubricDB<>@TypeIdForRubric)) 
	AND EXISTS(select Top 1 ObjectId From dbo.ObjectInfo WHERE TypeId=@TypeId)
begin
	SET @msg = 'Error (TypeInfo_UpdateInsert): Can not change TableName or IsHierarchical since there are already objects of given type [TableDB='+@TableNameDB+', IsHierarchicalDB='+ CAST(@IsHierarchicalDB as varchar(16)) +', Table='+@TableName+', IsHierarchical='+ CAST(@IsHierarchical as varchar(16)) +', TypeId=' + CAST(@TypeId as varchar(16)) + ']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end

SET @IsHierarchical = IIF(@TableName='RubricInfo',1,0)
IF @IsHierarchical=1
	SET @TypeIdForRubric=NULL
IF @IsHierarchical=0 AND ((@TypeIdForRubric IS NULL) OR NOT EXISTS(select * from TypeInfo WHERE TypeId=@TypeIdForRubric AND IsHierarchical=1))
begin
	SET @msg = 'Error (TypeInfo_UpdateInsert): TypeIdForRubric is not properly set [TypeIdForRubric='+ CAST(@TypeIdForRubric as varchar(16)) +', Table='+@TableName+', IsHierarchical='+ CAST(@IsHierarchical as varchar(16)) +', TypeId=' + CAST(@TypeId as varchar(16)) + ']'
	RAISERROR (@msg, 16, 0);
	RETURN 0;
end

IF @UrlPrefix IS NULL OR LEN(@UrlPrefix)<1
	SET @UrlPrefix = dbo.fn_Transliterate4URL(@TypeName)
IF @TableNameDB IS NOT NULL -- EXISTS
BEGIN
	UPDATE dbo.TypeInfo SET _date = getdate(),
		IsHierarchical=@IsHierarchical, TypeIdForRubric=@TypeIdForRubric,
		TypeName=@TypeName, TableName=@TableName, UrlPrefix=@UrlPrefix, TypeComment=@TypeComment, ValidationSchema=@ValidationSchema, DataSchema=@DataSchema, FileRequired=@FileRequired, SettingsJson=@SettingsJson
	WHERE TypeId=@TypeId
END
ELSE    -- add record
BEGIN
	IF @TypeId=0
		SET @TypeId=ISNULL((SELECT MAX(TypeId)+1 FROM dbo.TypeInfo), 1)
	INSERT INTO dbo.TypeInfo (TypeId, IsHierarchical, TypeIdForRubric, TypeName, TableName, UrlPrefix, TypeComment, ValidationSchema, DataSchema, FileRequired, SettingsJson, _date)
	VALUES (@TypeId, @IsHierarchical, @TypeIdForRubric, @TypeName, @TableName, @UrlPrefix, @TypeComment, @ValidationSchema, @DataSchema, @FileRequired, @SettingsJson, getdate())
END
SET NOCOUNT OFF;
SELECT top 1 * FROM dbo.TypeInfo WHERE TypeId=@TypeId
RETURN @TypeId
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Migration identifier (for ASP.Net Core identity; Entity Framework ORM)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'__EFMigrationsHistory', @level2type=N'COLUMN',@level2name=N'MigrationId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Migration Version' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'__EFMigrationsHistory', @level2type=N'COLUMN',@level2name=N'ProductVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains migration state for ASP.Net Core identity via Entity Framework ORM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'__EFMigrationsHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Id (identity, primary key)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoleClaims', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Id (from AspNetRoles.Id)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoleClaims', @level2type=N'COLUMN',@level2name=N'RoleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of a claim' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoleClaims', @level2type=N'COLUMN',@level2name=N'ClaimType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of a claim' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoleClaims', @level2type=N'COLUMN',@level2name=N'ClaimValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains claims for roles from AspNetRoles' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoleClaims'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'RoleId' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoles', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoles', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name in uppercase' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoles', @level2type=N'COLUMN',@level2name=N'NormalizedName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Stamp' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoles', @level2type=N'COLUMN',@level2name=N'ConcurrencyStamp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains roles available in the application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetRoles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Id (identity, primary key)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserClaims', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id (from AspNetUsers.Id)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserClaims', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Claim Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserClaims', @level2type=N'COLUMN',@level2name=N'ClaimType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Claim value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserClaims', @level2type=N'COLUMN',@level2name=N'ClaimValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains claims for users from AspNetUsers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserClaims'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'OAuth Login Provider' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserLogins', @level2type=N'COLUMN',@level2name=N'LoginProvider'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Provider Key (provider-specific key for the user)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserLogins', @level2type=N'COLUMN',@level2name=N'ProviderKey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'OAuth Login Provider Name (to display)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserLogins', @level2type=N'COLUMN',@level2name=N'ProviderDisplayName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id from AspNetUsers.Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserLogins', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains external OAuth authentification providers for users' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserLogins'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id from AspNetUsers.Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserRoles', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Role Id from AspNetRoles.Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserRoles', @level2type=N'COLUMN',@level2name=N'RoleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains user-group relation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserRoles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserId' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'Id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Login in the authorisation form' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'UserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserName in uppercase' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'NormalizedUserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User E-mail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'E-mail in uppercase' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'NormalizedEmail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'whether the E-mail has been confirmed (using the link from the e-mail)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'EmailConfirmed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Password hash' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'PasswordHash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security Stamp' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'SecurityStamp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Stamp' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'ConcurrencyStamp'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Phone Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'PhoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'whether the PhoneNumber has been confirmed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'PhoneNumberConfirmed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Two-factor authorisation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'TwoFactorEnabled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Once LockoutEnd has a future date then the user is considered locked out whether LockoutEnabled is true or false' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'LockoutEnd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'enable a user lockout for a specific period of time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'LockoutEnabled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'how many times the user has entered an incorrect password' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers', @level2type=N'COLUMN',@level2name=N'AccessFailedCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains registered users of the application (users are shared by all tenants in the same database)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUsers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'UserId from AspNetUsers.Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserTokens', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Login Provider' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserTokens', @level2type=N'COLUMN',@level2name=N'LoginProvider'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of a token' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserTokens', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token Value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserTokens', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains user tokens for a specific OAuth provider' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AspNetUserTokens'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CompositionId - uniqie row identifier, primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'CompositionId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to a Sample  (identifier from Sample table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'SampleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort chemical elements in a formula (list) in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'CompoundIndex'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Element name as specified in the Periodic Table (ElementInfo table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'ElementName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Absolute value in chemical formula (element contents)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'ValueAbsolute'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Percent value in chemical formula (element contents), calculated automatically if ValueAbsolute is set' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition', @level2type=N'COLUMN',@level2name=N'ValuePercent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains the quantitative composition for a sample (from Sample), identified by SampleId' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Composition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Element Identifier (atomic number), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElementInfo', @level2type=N'COLUMN',@level2name=N'ElementId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Element name as specified in the Periodic Table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElementInfo', @level2type=N'COLUMN',@level2name=N'ElementName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains chemical elements from the Periodic Table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ElementInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'HandoverId==ObjectId (in this table information from ObjectInfo is extended)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'HandoverId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to a Sample (from Sample table == ObjectId from ObjectInfo) that should be physically transferred to other person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'SampleObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Target user (from AspNetUser) who will receive the sample' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'DestinationUserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Time stamp as a receivement confirmation (NULL - not confirmed)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'DestinationConfirmed'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments from a target/destination user' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'DestinationComments'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'JSON containing additional data regarding the handover' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'Json'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount of a sample (in case of powder) / NULL in case of items (materials library wafer)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'Amount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measurement unit for amount (if specified) / NULL in case of items (materials library wafer)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover', @level2type=N'COLUMN',@level2name=N'MeasurementUnit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains handovers for tracking physical objects/samples, but potentially could be extended for any type/logic (extension for ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Handover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Object Identifier (assigned automatically, identity), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tenant Identifier (assigned automatically based on URL address) from Tenant table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'TenantId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Object Type (identifier from TypeInfo table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifier of the RubricId from RubricInfo (specifies the location of the object within a project tree)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'RubricId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort objects in a list (project) in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Object Availability: 
0 - Public (visible for anonymous users), 
1 - Protected (visible for users with at least the "User" group), 
2 - ProtectedNDA (visible for users with at least the "User" group and assigned "NDA" claim), 
3 - Private (visible for user-creator and administrators).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'AccessControl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reserved (not used so far):
1 - published;
0 - draft (do not display in lists).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'IsPublished'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Auxiliary Id from external information system to support coherence and consistency (if needed)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ExternalId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique (within type) object name, must be specified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique (within tenant) object URL (used in web application to refer to object page)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectNameUrl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'relative path (in future could be an absolute link to an external cloud storage) to the object document stored on the disk (reference to the data file uploaded by the user)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectFilePath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SHA-256 hash (hex) for document in ObjectFilePath (must be unique within a tenant)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectFileHash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Optional Object description (showed in project list)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo', @level2type=N'COLUMN',@level2name=N'ObjectDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects of all types' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique ObjectLinkObject Identifier (assigned automatically, identity), primary key; to link objects to other objects, thus creating a graph' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'ObjectLinkObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ObjectId (reference to a parent object) from ObjectInfo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Linked ObjectId (reference to a child object) from ObjectInfo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'LinkedObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort objects in a list of references in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Object to characterise a link (thus providing semantics for an oriented graph edge)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject', @level2type=N'COLUMN',@level2name=N'LinkTypeObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains directed edges (ObjectId -> LinkedObjectId) to form the oriented object graph. The semantic of the edge could be specified in LinkTypeObjectId which characterises the edge.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique ObjectLinkRubric Identifier (assigned automatically, identity), primary key; to link objects to other objects, thus creating a graph' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'ObjectLinkRubricId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to a rubric (from RubricInfo) that should show a specified object (thus object is shown in several rubrics)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'RubricId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to an object (from ObjectsInfo) that should be displayed in the rubric' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The sort code for an object link; to sort objects in a list (rubric) of objects/references in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains additional rubrics (in addition to ObjectInfo.RubricId) where the object should be visible, allowing multiple locations for an object in the project tree.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ObjectLinkRubric'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Big String Property Identifier (assigned automatically, identity), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'PropertyBigStringId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to an object, that owns the property (ObjectId from ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort properties in a list of properties in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row number (1, 2, 3...) for a table properties (NULL - no table, scalar property). In templates -1 - table property; NULL - scalar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property value (-1 for templates as a fake value)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the property. Attention: triplet (ObjectId, PropertyName, Row) must be unique, ensured by unique index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'PropertyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment for a property (could be a measurement unit in a template)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ObjectId of a source object, that created this property (or data from which was saved to this property)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString', @level2type=N'COLUMN',@level2name=N'SourceObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains large strings (BLOBs) for object description (aka extended properties)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyBigString'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Float Property Identifier (assigned automatically, identity), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'PropertyFloatId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to an object, that owns the property (ObjectId from ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort properties in a list of properties in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row number (1, 2, 3...) for a table properties (NULL - no table, scalar property). In templates -1 - table property; NULL - scalar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property value (-1 for templates as a fake value)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Measurement accuracy' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'ValueEpsilon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the property. Attention: triplet (ObjectId, PropertyName, Row) must be unique, ensured by unique index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'PropertyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment for a property (could be a measurement unit in a template)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ObjectId of a source object, that created this property (or data from which was saved to this property)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat', @level2type=N'COLUMN',@level2name=N'SourceObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains real numbers for object description (aka extended properties)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyFloat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Integer Property Identifier (assigned automatically, identity), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'PropertyIntId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to an object, that owns the property (ObjectId from ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort properties in a list of properties in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row number (1, 2, 3...) for a table properties (NULL - no table, scalar property). In templates -1 - table property; NULL - scalar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property value (-1 for templates as a fake value)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the property. Attention: triplet (ObjectId, PropertyName, Row) must be unique, ensured by unique index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'PropertyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment for a property (could be a measurement unit in a template)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ObjectId of a source object, that created this property (or data from which was saved to this property)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt', @level2type=N'COLUMN',@level2name=N'SourceObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains integer numbers for object description (aka extended properties)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyInt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique String Property Identifier (assigned automatically, identity), primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'PropertyStringId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference to an object, that owns the property (ObjectId from ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'ObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort properties in a list of properties in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the property (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row number (1, 2, 3...) for a table properties (NULL - no table, scalar property). In templates -1 - table property; NULL - scalar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'Row'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Property value (-1 for templates as a fake value)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the property. Attention: triplet (ObjectId, PropertyName, Row) must be unique, ensured by unique index.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'PropertyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment for a property (could be a measurement unit in a template)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ObjectId of a source object, that created this property (or data from which was saved to this property)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString', @level2type=N'COLUMN',@level2name=N'SourceObjectId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains strings (up to 4096 characters) for object description (aka extended properties)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertyString'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ReferenceId==ObjectId (in this table information from ObjectInfo is extended)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'ReferenceId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'All authors in a comma-separated list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Authors'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Title of manuscript' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Title'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Title' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Journal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'publication year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Year'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'volume descriptor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Volume'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'issue number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'Number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Start page of a publication' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'StartPage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End page of a publication' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'EndPage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DOI (Digital Object Identifier)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'DOI'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Publication URL (Uniform Resource Locator)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'URL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description in a BibTeX format' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference', @level2type=N'COLUMN',@level2name=N'BibTeX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains description for literature references (extension for ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Reference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Rubric Identifier, primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'RubricId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tenant Identifier (assigned automatically based on URL address) from Tenant table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'TenantId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'_created'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'_createdBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'_updated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User who created/modified the object (from AspNetUsers table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'_updatedBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rubric Type (identifier from TypeInfo table)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'RubricId of a parent rubric (or NULL in case of top-level rubric)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'ParentId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Level of rubric nesting (0 - root rubric; 1 - next level, etc...)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'Level'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Set of flags. From the least significant bit:

0x1 - presence of objects (in ObjectInfo): 0 - no objects; 1 - there are objects;

0x2 - presence of objects (in ObjectLinkRubric): 0 - no objects; 1 - links exist;

0x4 - Is Rubric End / Leaf (child free): 0 - no children (leaf); 1 - there are children (not leaf).
Calculated automatically on the server (see dbo.ProcRubric_NormaliseTree)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'LeafFlag'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reserved (not used so far)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'Flags'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'To sort rubrics within a parent (project) in ascending order, by default 0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'SortCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rubric Availability: 
0 - Public (visible for anonymous users), 
1 - Protected (visible for users with at least the "User" group), 
2 - ProtectedNDA (visible for users with at least the "User" group and assigned "NDA" claim), 
3 - Private (visible for user-creator and administrators).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'AccessControl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reserved (not used so far):
1 - published;
0 - draft (do not display in lists).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'IsPublished'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Rubric, must be specified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'RubricName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique (within tenant) rubric URL (used in web application to refer to rubric page)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'RubricNameUrl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'''}''-separated rubric path from the root (calculated automatically on the server, see dbo.ProcRubric_NormaliseTree)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo', @level2type=N'COLUMN',@level2name=N'RubricPath'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains tree structures for the application (project tree, organisational structure)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rubric Identifier from RubricInfo table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfoAdds', @level2type=N'COLUMN',@level2name=N'RubricId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rubric Description (HTML) to shown in the app' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfoAdds', @level2type=N'COLUMN',@level2name=N'RubricText'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains text description for a rubric from RubricInfo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RubricInfoAdds'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SampleId==ObjectId (in this table information from ObjectInfo is extended)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Sample', @level2type=N'COLUMN',@level2name=N'SampleId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of chemical elements (number of elements in the chemical system)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Sample', @level2type=N'COLUMN',@level2name=N'ElemNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'List of chemical elements (in ascending order by name) separated by "-" (to search using "-El-" expression).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Sample', @level2type=N'COLUMN',@level2name=N'Elements'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains sample information (essentially a chemical system, i.e. qualitative description of composition (extension for ObjectInfo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Sample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique tenant identifier (TenantId must be unique within an application instance that supports multiple databases, i.e. TenantId is unique across all instance databases)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'TenantId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Interface Language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'Language'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tenant URL (unique across instances)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'TenantUrl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Short name of a tenant (displayed in the top left corner of the UI)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'TenantName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default access control value (see ObjectsInfo.AccessControl description) in UI for new objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant', @level2type=N'COLUMN',@level2name=N'AccessControl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains list of tenants in the database (tenants share common users and types)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Tenant'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Type Identifier, primary key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - Hierarchical types (such as project tree) are stored in the RubricInfo table; 0 - List types (such as chemical objects, measurement results) are stored in the ObjectInfo table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'IsHierarchical'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TypeId for the hierarchical classifier where the object should be displayed (in most cases - id of Rubric Type)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'TypeIdForRubric'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique Type Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'TypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Name to store data (one of: RubricInfo; ObjectInfo, Sample, Composition, Reference, Handover)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'TableName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL prefix for type (reserved, not used so far)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'UrlPrefix'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment for type, describing it''s purpose' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'TypeComment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Schema to validate type objects data (type:ClassName or https://WebServiceURL)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'ValidationSchema'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Schema to extract data from objects'' data documents (type:ClassName or https://WebServiceURL)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'DataSchema'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'JSON with settings for the type (see documentation)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'SettingsJson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 - impossible to create object without a file in ObjectInfo.ObjectFilePath; 0 - optional file' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'FileRequired'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the record creation/modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo', @level2type=N'COLUMN',@level2name=N'_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains types of objects that could be present in the application, regarding their configuration (allowed file type extensions, validation and data extraction schema, etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TypeInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'View that combines Composition with Sample and ObjectInfo tables to get all quantitative compositions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vComposition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 119
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 120
               Left = 260
               Bottom = 250
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vComposition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vComposition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'View that combines Handover with ObjectInfo table to get complete handovers data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vHandover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vHandover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vHandover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'View that combines ObjectLinkObject with ObjectInfo table two times (for parent - ObjectId; and for Child - LinkedObjectId) to get information about interconnected objects (except edge type characterisation in LinkTypeObjectId)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OLO"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Parent"
            Begin Extent = 
               Top = 6
               Left = 267
               Bottom = 136
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Child"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'View that combines Reference with ObjectInfo table to get complete literature reference data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vReference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 136
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vReference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vReference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'View that combines Sample with ObjectInfo table to get complete sample data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OI"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 119
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vSample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetRoleClaims table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetRoleClaims'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetRoles table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetRoles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetUserClaims table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetUserClaims'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetUserLogins table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetUserLogins'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetUserRoles table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetUserRoles'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetUsers table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetUsers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for AspNetUserTokens table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroAspNetUserTokens'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for Composition table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroComposition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for ElementInfo table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroElementInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for Handover table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroHandover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for ObjectInfo table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroObjectInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for ObjectLinkObject table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for ObjectLinkRubric table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroObjectLinkRubric'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for PropertyBigString table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroPropertyBigString'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for PropertyFloat table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroPropertyFloat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for PropertyInt table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroPropertyInt'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for PropertyString table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroPropertyString'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for Reference table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroReference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for RubricInfo table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroRubricInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for RubricInfoAdds table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroRubricInfoAdds'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for Sample table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroSample'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for Tenant table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroTenant'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for TypeInfo table' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vroTypeInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for vComposition view' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vrovComposition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for vHandover view' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vrovHandover'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for vObjectLinkObject view' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vrovObjectLinkObject'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for vReference view' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vrovReference'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Read-only view for vSample view' , @level0type=N'SCHEMA',@level0name=N'vro', @level1type=N'VIEW',@level1name=N'vrovSample'
GO
USE [master]
GO
ALTER DATABASE [RUB_Clear] SET  READ_WRITE 
GO
