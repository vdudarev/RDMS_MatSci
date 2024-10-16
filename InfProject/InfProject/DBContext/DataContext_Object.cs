using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using System.Security.Claims;
using InfProject.DTO;
using System;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Newtonsoft.Json.Linq;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Text;
using static InfProject.Models.Composition;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Diagnostics.Metrics;
using Microsoft.CodeAnalysis;
using OfficeOpenXml.Packaging.Ionic.Zlib;
using OfficeOpenXml.Style;
using System.Collections.Generic;
using System.Security.AccessControl;

namespace InfProject.DBContext;

public partial class DataContext
{
    #region Object

    public async Task<int?> GetObjectByTypeAndObjectName(int typeId, string objectName)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int? res = await connection.ExecuteScalarAsync<int?>($"SELECT TOP 1 ObjectId FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@typeId AND ObjectName=@objectName",
                new { TenantId, typeId, objectName });
            return res;
        }
    }

    public async Task<ObjectInfo?> GetObjectByFileHash(string hash)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"SELECT TOP 1 * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectFileHash=@hash",
                new { TenantId, hash });
            return res.FirstOrDefault();
        }
    }

    public async Task<ObjectInfo?> GetObjectByUrl(string url)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"SELECT TOP 1 * FROM dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectNameUrl=@url",
                new { TenantId, url });
            return res.FirstOrDefault();
        }
    }

    public async Task<List<CompositionItem>> GetComposition(int sampleId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<CompositionItem>($@"select * from dbo.Composition
WHERE SampleId=@sampleId AND EXISTS(select top 1 TenantId from dbo.ObjectInfo where TenantId=@TenantId AND ObjectId=@sampleId) 
ORDER BY CompoundIndex, ElementName", new { TenantId, sampleId });
            return res?.ToList();
        }
    }

    public async Task<ObjectInfo?> ObjectInfo_Get(int objectId, int typeId = 0)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            string sql = "select top 1 * from dbo.ObjectInfo where TenantId=@TenantId AND ObjectId=@objectId";
            if (typeId != 0)
            {
                sql += " AND TypeId=@typeId";
            }
            var res = await connection.QueryAsync<ObjectInfo>(sql, new { TenantId, objectId, typeId });
            return res.FirstOrDefault();
        }
    }



    public async Task<ObjectInfo?> ObjectInfo_GetByExternalId(int externalId, int typeId=0)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            string sql = "select top 1 * from dbo.ObjectInfo where TenantId=@TenantId AND ExternalId=@externalId";
            if (typeId != 0) {
                sql += " AND TypeId=@typeId";
            }
            var res = await connection.QueryAsync<ObjectInfo>(sql, new { TenantId, externalId, typeId });
            return res.FirstOrDefault();
        }
    }

    public async Task<List<ObjectInfo>> ObjectInfo_GetList_AccessControlModify(int typeId, int isAdmin, int userId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"EXEC dbo.GetObjectList_AccessControlModify @TenantId, @TypeId, @IsAdmin, @UserId",
                new { TenantId, TypeId=typeId, IsAdmin=isAdmin, UserId=userId });
            return res.ToList();
        }
    }

    public async Task<List<ObjectInfo>> ObjectInfo_GetList_AccessControl(int typeId, int accessControl, int userId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"EXEC dbo.GetObjectList_AccessControl @TenantId, @TypeId, @AccessControl, @UserId",
                new { TenantId, TypeId = typeId, AccessControl = accessControl, UserId = userId });
            return res.ToList();
        }
    }


    /*
    public async Task<T> ObjectInfo_GetVirtualByObjectId<T>(int objectId) where T : ObjectInfo
    {
        var typeObj = await GetTypeByObjectId(objectId);
        if (typeObj.TableName == "ObjectInfo") {
            return (T)await ObjectInfo_Get(objectId);
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<T>($@"select * from dbo.ObjectInfo AS OI 
INNER JOIN dbo.{typeObj.TableName} as T ON T.{typeObj.TableName}Id=OI.ObjectId
WHERE OI.ObjectId=@objectId", new { objectId });
            return res?.FirstOrDefault();
        }
    }
    */

    public async Task<(ObjectInfo, Models.TypeInfo)> ObjectInfo_GetVirtualWrapper(int objectId, Models.TypeInfo? dbType = null)
    { 
        ObjectInfo obj = null!;
        if (dbType == null)
            dbType = await GetTypeByObjectId(objectId);
        if (dbType == null)
            return (obj, dbType);   // null, null - object not found
        if (dbType.TableName == "ObjectInfo") {
            obj = await ObjectInfo_Get(objectId);
        }
        else {  // for complex inherited objects
            // Goal (e.g. Sample): obj = await dataContext.ObjectInfo_GetVirtual<Sample>(idObject);
            // Make it type-universal:
            // https://stackoverflow.com/questions/325156/calling-generic-method-with-a-type-argument-known-only-at-execution-time
            Type t = Type.GetType($"InfProject.Models.{dbType.TableName}");
            MethodInfo methodInfo = typeof(DataContext).GetMethod("ObjectInfo_GetVirtual");
            MethodInfo genericMethodInfo = methodInfo.MakeGenericMethod(t);
            dynamic res = genericMethodInfo.Invoke(this, new object[] { objectId });
            obj = res.Result;
        }
        return (obj, dbType);
    }

    public async Task<T?> ObjectInfo_GetVirtual<T>(int objectId) where T : ObjectInfo
    {
        string name = typeof(T).Name;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            string sql;
            if (name == "Composition")
            {
                sql = $@"select *, (select * from dbo.Composition WHERE SampleId=@ObjectId for xml path('item'), root('root')) as [Xml] --CompositionItems
from dbo.ObjectInfo AS OI 
INNER JOIN dbo.Sample as T ON T.SampleId=OI.ObjectId
WHERE OI.TenantId=@TenantId AND OI.ObjectId=@objectId";
            }
            else {
                sql = $@"select * from dbo.ObjectInfo AS OI 
INNER JOIN dbo.{name} as T ON T.{name}Id=OI.ObjectId
WHERE OI.TenantId=@TenantId AND OI.ObjectId=@objectId";
            }
            var res = await connection.QueryAsync<T>(sql, new { TenantId, objectId });
            return res.FirstOrDefault();
        }
    }

    public async Task<T?> ObjectInfo_UpdateInsertVirtual<T>(T obj) where T : ObjectInfo
    {
        string name = typeof(T).Name;
        string parametersCSV = ReflectionUtils.GetStoredProcedureParametersByType<T>();
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            DynamicParameters parameters = ReflectionUtils.GetDynamicParametersFromObject(obj);
            Composition c = obj as Composition;
            if (c != null) {
                var value = Composition.GetTableParameter(c.CompositionItems).AsTableValuedParameter("dbo.CompositionItem");
                parameters.Add("CompositionItems", value);
                //parameters.CompositionItems = Composition.GetTableParameter(c.CompositionItems).AsTableValuedParameter("dbo.CompositionItem");
            }
            // ObjectInfo_Sample_UpdateInsert
            // ObjectInfo_Composition_UpdateInsert
            // ObjectInfo_Reference_UpdateInsert
            var res = await connection.QueryAsync<T>($"EXEC dbo.ObjectInfo_{name}_UpdateInsert @ObjectId, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription {parametersCSV}",
                parameters);
            return res.FirstOrDefault();
        }
    }


    public async Task<List<ObjectInfo>> ObjectInfo_Find(string query, int typeId, int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"select * from dbo.ObjectInfo where TenantId=@TenantId AND TypeId=IIF(@typeId!=0, @typeId, typeId) AND ObjectName LIKE '%' + @query + '%' AND ObjectId!=@objectId", 
                new { TenantId, query, typeId, objectId });
            return res.ToList();
        }
    }

    /// <summary>
    /// Get all objects from the specified rubric regardless data access permissions
    /// </summary>
    /// <param name="rubricId">RubricId</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<List<ObjectInfo>> ObjectInfo_GetByRubricId(int rubricId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"select * from dbo.ObjectInfo where TenantId=@TenantId AND RubricId=@rubricId", 
                new { TenantId, rubricId });
            return res.ToList();
        }
    }

    /// <summary>
    /// Get only objects from the specified rubric considering current User permissions
    /// </summary>
    /// <param name="rubricId">RubricId</param>
    /// <param name="accessFilter">accessFilter - access rights</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<List<ObjectInfo>> ObjectInfo_GetByRubricId(int rubricId, AccessControlFilter accessFilter)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($@"EXEC dbo.GetRubricObjects_AccessControl @TenantId, @RubricId, @AccessControl, @UserId",
            new { TenantId, RubricId = rubricId, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }

    /// <summary>
    /// Get last (top maxCount) objects, that were last added to database by userId (Order by _created desc)
    /// </summary>
    /// <param name="targetUserId">userId, who added objects (0 - all users)</param>
    /// <param name="accessFilter">accessFilter - access rights</param>
    /// <param name="maxCount">maxCount - max Number of returned items</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<List<ObjectInfo>> ObjectInfo_GetLastAdditions(int targetUserId, AccessControlFilter accessFilter, int maxCount = 10)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($@"EXEC dbo.GetLastAdditions_AccessControl @TenantId, @TargetUserId, @MaxCount, @AccessControl, @UserId",
            new { TenantId, TargetUserId = targetUserId, MaxCount = maxCount, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }


    public async Task<ObjectInfo?> ObjectInfo_UpdateInsert(ObjectInfo obj)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>($"EXEC dbo.ObjectInfo_UpdateInsert @ObjectId, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @RubricId, @SortCode, @AccessControl, @IsPublished, @ExternalId, @ObjectName, @ObjectNameUrl, @ObjectFilePath, @ObjectDescription", obj);
            return res.FirstOrDefault();
        }
    }


    public async Task<int> ObjectInfo_UpdateObjectFilePath(int objectId, string objectFilePath, string hash)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var rowsAffected = await connection.ExecuteAsync(
                $"UPDATE dbo.ObjectInfo SET ObjectFilePath=@ObjectFilePath, ObjectFileHash=@hash WHERE TenantId=@TenantId AND ObjectId=@ObjectId", 
                new { TenantId, objectId, objectFilePath, hash });
            return rowsAffected;
        }
    }

    public async Task<int> ObjectInfo_Delete(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var rowsAffected = await connection.ExecuteAsync($"EXEC dbo.ObjectInfo_Delete @TenantId, @objectId", new { TenantId, objectId });
            return rowsAffected;
        }
    }

    public async Task<int> ObjectInfo_DeleteNestedObjects(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var rowsAffected = await connection.ExecuteAsync($"EXEC dbo.Delete_NestedObjects @TenantId, @objectId", new { TenantId, objectId });
            return rowsAffected;
        }
    }

    #endregion // Object


    /// <summary>
    /// Get files and hashes from DB
    /// </summary>
    /// <param name="allTenants">true - consider all tenants in DB, othrwise - the current tenant only</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<List<dynamic>> ObjectInfo_GetFilesAndHashes(bool allTenants = true)
    {
        string where = allTenants ? string.Empty : $"TenantId={TenantId} AND";
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>(
                $"select ObjectId, TenantId, ObjectNameUrl, ObjectFilePath, ObjectFileHash from dbo.ObjectInfo WHERE {where} (ObjectFilePath IS NOT NULL OR ObjectFileHash IS NOT NULL)");
            return res.ToList();
        }
    }

    /// <summary>
    /// Get files and hashes from DB
    /// </summary>
    /// <param name="allTenants">true - consider all tenants in DB, othrwise - the current tenant only</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<int> ObjectInfo_UpdateObjectFileHash(int objectId, string objectFileHash)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync(
                $"UPDATE dbo.ObjectInfo SET ObjectFileHash=@ObjectFileHash WHERE ObjectId=@objectId", 
                new { objectId, ObjectFileHash=objectFileHash }
                );
            return res;
        }
    }

}
