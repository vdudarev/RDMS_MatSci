using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using System.Linq;
using InfProject.DTO;
using System;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Newtonsoft.Json.Linq;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Text;
using static InfProject.Models.Composition;
using Microsoft.AspNetCore.Http.HttpResults;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using System.Diagnostics.Metrics;
using System.Runtime.InteropServices.JavaScript;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using static WebUtilsLib.DBUtils;
using static TypeValidationLibrary.TypeValidator_EDX_CSV;
using Azure.Core.GeoJson;
using static OfficeOpenXml.ExcelErrorValue;
using System.Collections.Generic;
using Microsoft.CodeAnalysis;

namespace InfProject.DBContext;

public partial class DataContext
{
    #region Property
    /// <summary>
    /// Returns all (of all types) Properties for selected Object typeId
    /// </summary>
    /// <param name="typeId">typeId or 0 == consider all object types</param>
    /// <returns></returns>
    public async Task<List<dynamic>> Property_GetPropertyNameByType(int typeId=0)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>($"EXEC [dbo].[Get_PropertyNameByType] @TenantId, @TypeId",
                new { TenantId, TypeId = typeId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Returns properties for selected Object typeId
    /// </summary>
    /// <param name="propertyType">PropertyType enum OR 0 == consider all properties types</param>
    /// <param name="typeId">typeId or 0 == consider all object types</param>
    /// <returns></returns>
    public async Task<List<string>> Property_GetPropertyNameByType(PropertyType propertyType, int typeId=0)
    {
        if ((int)propertyType == 0) { 
            var list = (await Property_GetPropertyNameByType(typeId)).Select(x => (string)x.PropertyName).ToList();
            return list;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<string>($@"
IF @TypeId!=0
    SELECT DISTINCT PropertyName FROM dbo.Property{propertyType} as P
	    INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
	    WHERE O.TypeId=@TypeId
    ORDER BY PropertyName
ELSE
    SELECT DISTINCT PropertyName FROM dbo.Property{propertyType} as P
	    INNER JOIN dbo.ObjectInfo as O ON O.ObjectId=P.ObjectId AND O.TenantId=@TenantId
    ORDER BY PropertyName
",
                new { TenantId, TypeId = typeId });
            return res.ToList();
        }
    }

    public async Task<List<PropertyValue>> Property_GetTemplatePropertiesForType(int typeId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<PropertyValue>($"EXEC dbo.GetTemplatePropertiesForType @TenantId, @typeId",
                new { TenantId, typeId });
            return res.ToList();
        }
    }


    public async Task<List<dynamic>> Property_GetTemplateTablePropertiesForType(int typeId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>($"EXEC dbo.GetTemplateTablePropertiesForType @TenantId, @typeId",
                new { TenantId, typeId });
            return res.ToList();
        }
    }



    /// <summary>
    /// Get ALL Properties Count for specified object
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>count</returns>
    public async Task<int> Property_GetAllPropertiesCount(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<int>($@"SELECT SUM(cnt) as cnt FROM (
select count(PropertyIntId) as cnt from dbo.PropertyInt WHERE ObjectId=@ObjectId
UNION ALL 
select count(PropertyFloatId) from dbo.PropertyFloat WHERE ObjectId=@ObjectId
UNION ALL 
select count(PropertyStringId) from dbo.PropertyString WHERE ObjectId=@ObjectId
UNION ALL 
select count(PropertyBigStringId) from dbo.PropertyBigString WHERE ObjectId=@ObjectId) as T", new { TenantId, objectId });
            return res;
        }
    }



    /// <summary>
    /// Get all (of all types) properties for object OUTER JOINED with _Template
    /// </summary>
    /// <param name="objectId">could be 0, then typeId must be specified</param>
    /// <param name="typeId">must be specified if objectId is not set</param>
    /// <returns></returns>
    public async Task<List<dynamic>> Property_GetPropertiesAllUnionForObject_Join_Template(int objectId, int typeId = 0)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>($"EXEC dbo.GetPropertiesAllForObject_Join_Template @TenantId, @ObjectId, @TypeId",
                new { TenantId, ObjectId = objectId, TypeId = typeId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Get all (of all types) properties for object 
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns></returns>
    public async Task<List<dynamic>> Property_GetPropertiesAllUnionForObject(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>($"EXEC dbo.GetPropertiesAllForObject @TenantId, @ObjectId",
                new { TenantId, ObjectId = objectId });
            return res.ToList();
        }
    }

    public async Task<List<dynamic>> Property_GetPropertyFloat(int objectId) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
SELECT * FROM dbo.PropertyFloat WHERE ObjectId=@objectId ORDER BY Row, SortCode, PropertyName",
                new { TenantId, objectId });
            return res.ToList();
        }
    }

    public async Task<dynamic> Property_GetPropertyFloatByName(int objectId, string name, int? row = null)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryFirstOrDefaultAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
begin
    IF @row IS NULL
        SELECT top 1 * FROM dbo.PropertyFloat WHERE ObjectId=@objectId AND PropertyName=@name ORDER BY Row, SortCode, PropertyName
    ELSE    
        SELECT top 1 * FROM dbo.PropertyFloat WHERE ObjectId=@objectId AND PropertyName=@name AND Row=@row ORDER BY Row, SortCode, PropertyName
end",
                new { TenantId, objectId, name, row });
            return res;
        }
    }

    public async Task<List<dynamic>> Property_GetPropertyInt(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
SELECT * FROM dbo.PropertyInt WHERE ObjectId=@objectId ORDER BY Row, SortCode, PropertyName",
                new { TenantId, objectId });
            return res.ToList();
        }
    }

    public async Task<dynamic> Property_GetPropertyIntByName(int objectId, string name, int? row=null)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryFirstOrDefaultAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
begin
    IF @row IS NULL
        SELECT top 1 * FROM dbo.PropertyInt WHERE ObjectId=@objectId AND PropertyName=@name ORDER BY Row, SortCode, PropertyName
    ELSE    
        SELECT top 1 * FROM dbo.PropertyInt WHERE ObjectId=@objectId AND PropertyName=@name AND Row=@row ORDER BY Row, SortCode, PropertyName
end",
                new { TenantId, objectId, name, row });
            return res;
        }
    }


    public async Task<List<dynamic>> Property_GetPropertyString(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
SELECT * FROM dbo.PropertyString WHERE ObjectId=@objectId ORDER BY Row, SortCode, PropertyName",
                new { TenantId, objectId });
            return res.ToList();
        }
    }

    public async Task<dynamic> Property_GetPropertyStringByName(int objectId, string name, int? row = null)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryFirstOrDefaultAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
begin
    IF @row IS NULL
        SELECT top 1 * FROM dbo.PropertyString WHERE ObjectId=@objectId AND PropertyName=@name ORDER BY Row, SortCode, PropertyName
    ELSE    
        SELECT top 1 * FROM dbo.PropertyString WHERE ObjectId=@objectId AND PropertyName=@name AND Row=@row ORDER BY Row, SortCode, PropertyName
end",
                new { TenantId, objectId, name, row });
            return res;
        }
    }

    public async Task<List<dynamic>> Property_GetPropertyBigString(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
SELECT * FROM dbo.PropertyBigString WHERE ObjectId=@objectId ORDER BY Row, SortCode, PropertyName",
                new { TenantId, objectId });
            return res.ToList();
        }
    }

    public async Task<dynamic> Property_GetPropertyBigStringByName(int objectId, string name, int? row = null)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryFirstOrDefaultAsync<dynamic>(
                @"IF EXISTS(select TenantId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
begin
    IF @row IS NULL
        SELECT top 1 * FROM dbo.PropertyBigString WHERE ObjectId=@objectId AND PropertyName=@name ORDER BY Row, SortCode, PropertyName
    ELSE    
        SELECT top 1 * FROM dbo.PropertyBigString WHERE ObjectId=@objectId AND PropertyName=@name AND Row=@row ORDER BY Row, SortCode, PropertyName
end",
                new { TenantId, objectId, name, row });
            return res;
        }
    }


    public async Task<int> Property_UpdateInsert(PropertyValue value, DateTime created, int userId, int objectId, bool deleteOnNullValues = true, IDbConnection connection = null)
    {
        DynamicParameters parameters = new DynamicParameters(); // new DynamicParameters(par);
        parameters.Add("retval", 0, DbType.Int32, direction: ParameterDirection.ReturnValue);
        parameters.Add("TenantId", TenantId, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("PropertyId", value.PropertyId, DbType.Int32, direction: ParameterDirection.InputOutput);
        parameters.Add("ObjectId", objectId, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("SortCode", value.SortCode, // row == 2 ? col*10 : 0, 
            DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("_created", created, DbType.DateTime, direction: ParameterDirection.Input);
        parameters.Add("_createdBy", userId, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("_updated", created, DbType.DateTime, direction: ParameterDirection.Input);
        parameters.Add("_updatedBy", userId, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("Row", value.Row, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("Value", value.Value, GetDbTypeByPropertyType(value.PropertyType), direction: ParameterDirection.Input);
        parameters.Add("ValueEpsilon", value.ValueEpsilon == null ? DBNull.Value : value.ValueEpsilon, DbType.Double, direction: ParameterDirection.Input);
        parameters.Add("PropertyName", value.PropertyName, DbType.String, direction: ParameterDirection.Input);
        parameters.Add("Comment", value.Comment == null ? DBNull.Value : value.Comment, DbType.String, direction: ParameterDirection.Input);
        parameters.Add("SourceObjectId", value.SourceObjectId, DbType.Int32, direction: ParameterDirection.Input);
        parameters.Add("DeleteOnNullValues", deleteOnNullValues, DbType.Boolean, direction: ParameterDirection.Input);

        // UPDATE / INSERT in database
        PropertyType mode = value.PropertyType;
        return await Property_UpdateInsert(mode, parameters, connection);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="mode">PropertyType</param>
    /// <param name="parameters">DynamicParameters for stored procedure</param>
    /// <param name="connection">connection to use (could be null - new connection is created)</param>
    /// <returns>PropertyId</returns>
    /// <exception cref="NotSupportedException"></exception>
    public async Task<int> Property_UpdateInsert(PropertyType mode, DynamicParameters parameters, IDbConnection connection=null)
    {
        if (parameters.Get<int>("TenantId") == null) {
            parameters.Add("TenantId", TenantId, DbType.Int32, ParameterDirection.Input);
        }
        int res, propId;
        string sql = $"EXEC dbo.Property{mode}_UpdateInsert @TenantId, @PropertyId, @ObjectId, @SortCode, @_created, @_createdBy, @_updated, @_updatedBy, @Row, @Value, @ValueEpsilon, @PropertyName, @Comment, @SourceObjectId, @DeleteOnNullValues";
        if (connection != null)
        {
            res = await connection.ExecuteAsync(sql, parameters);
            propId = parameters.Get<int>("PropertyId");
        }
        else {
            using (connection = new SqlConnection(ConnectionString))
            {
                res = await connection.ExecuteAsync(sql, parameters);
                propId = parameters.Get<int>("PropertyId");
            }
        }
        return propId;
    }

    public async Task<int> Property_Delete(string mode, int propertyId)
    {
        if (mode != "Float" && mode != "Int" && mode != "String" && mode != "BigString")
        {
            throw new NotSupportedException($"Property_Delete: mode={mode} is not supported");
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int rowsAffected = await connection.ExecuteAsync($"EXEC dbo.Property_Delete @TenantId, @mode, @PropertyId", new { TenantId, mode, propertyId });
            return rowsAffected;
        }
    }


    public async Task<int> Property_Delete(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int rowsAffected = await connection.ExecuteScalarAsync<int>(@"DECLARE @retVal int=0;
IF EXISTS (select TOP 1 ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
    DELETE FROM dbo.PropertyBigString   WHERE ObjectId=@ObjectId;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyFloat       WHERE ObjectId=@ObjectId;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyInt         WHERE ObjectId=@ObjectId;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyString      WHERE ObjectId=@ObjectId;
    SET @retVal = @retVal + @@ROWCOUNT;
end; 
SELECT @retVal as RowsAffected",
new { TenantId, ObjectId = objectId });
            return rowsAffected;
        }
    }

    public async Task<int> Property_DeleteTableBefore(int objectId, DateTime before)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int rowsAffected = await connection.ExecuteScalarAsync<int>(@"DECLARE @retVal int=0;
IF EXISTS (select TOP 1 ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
    DELETE FROM dbo.PropertyBigString   WHERE ObjectId=@ObjectId AND Row>0 AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyFloat       WHERE ObjectId=@ObjectId AND Row>0 AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyInt         WHERE ObjectId=@ObjectId AND Row>0 AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyString      WHERE ObjectId=@ObjectId AND Row>0 AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
end; 
SELECT @retVal as RowsAffected", 
new { TenantId, ObjectId=objectId, before });
            return rowsAffected;
        }
    }


    public const string sqlProperty_DeleteNonTableBefore = @"DECLARE @retVal int=0;
IF EXISTS (select TOP 1 ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@ObjectId)
begin
    DELETE FROM dbo.PropertyBigString   WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyFloat       WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyInt         WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
    DELETE FROM dbo.PropertyString      WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before;
    SET @retVal = @retVal + @@ROWCOUNT;
end; 
SELECT @retVal as RowsAffected";

    public const string sqlProperty_EnlistNonTableBeforeDelete = @"DECLARE @res VARCHAR(max);
SELECT @res = COALESCE(@res + CHAR(13)+CHAR(10), '') + res
FROM (
select 'BigString: '+PropertyName as res FROM dbo.PropertyBigString   WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before
UNION ALL
select 'Float: '+PropertyName FROM dbo.PropertyFloat       WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before
UNION ALL
select 'Int: '+PropertyName FROM dbo.PropertyInt         WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before
UNION ALL
select 'String: '+PropertyName FROM dbo.PropertyString      WHERE ObjectId=@ObjectId AND Row IS NULL AND _updated<@before
) as q	order by res
select @res as res";


    public async Task<int> Property_DeleteNonTableBefore(int objectId, DateTime before, IDbConnection connection = null)
    {
        int rowsAffected;
        if (connection != null) {
            rowsAffected = await connection.ExecuteScalarAsync<int>(sqlProperty_DeleteNonTableBefore,
new { TenantId, ObjectId = objectId, before });
        }
        using (connection = new SqlConnection(ConnectionString))
        {
            rowsAffected = await connection.ExecuteScalarAsync<int>(sqlProperty_DeleteNonTableBefore,
new { TenantId, ObjectId = objectId, before });
            return rowsAffected;
        }
    }

    #endregion // Property

}
