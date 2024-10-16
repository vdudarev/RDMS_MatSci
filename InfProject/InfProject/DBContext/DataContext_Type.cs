using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;
using Dapper;
using System.Linq;
using InfProject.Models;
using System;
using InfProject.DTO;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Server.HttpSys;
//using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace InfProject.DBContext;

public partial class DataContext
{
    // private static List<TypeInfo> _Types; // to cache types (THEY ARE TENANT INDEPENDENT! To bring added value to all the tenants at once)
    //private static List<TypeInfo> Types
    //{
    //    get => _Types;
    //    set
    //    {
    //        lock (myLock)
    //        {
    //            _Types = value;
    //        }
    //    }
    //}

    // types are database-wide (here we conclude to have different DBs for some tenants, so types COULD BE tenant specific now)
    private static ConcurrentDictionary<int, List<TypeInfo>> _TenantTypes = new ConcurrentDictionary<int, List<TypeInfo>>(); // tenant-dependent types

    /// <summary>
    /// Get types for the current Tenant (hides complexity with TenantId)
    /// </summary>
    /// <returns>List<TypeInfo></returns>
    public async Task<List<TypeInfo>> GetTypes() {
        List<TypeInfo> types;
        if (_TenantTypes.TryGetValue(TenantId, out types))
            return types;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>("SELECT * FROM dbo.TypeInfo ORDER BY TypeName");
            types = res.ToList();
            lock (myLock)
            {
                _TenantTypes[TenantId] = types;
            }
            return types;
        }
    }

    /// <summary>
    /// Gets list with Type information from DB (hierarchical types only == rubrics)
    /// </summary>
    /// <returns>TypeInfo</returns>
    public async Task<List<TypeInfo>> GetTypesHierarchical()
    {
        return (await GetTypes()).Where(x => x.IsHierarchical).OrderBy(x => x.TypeName).ToList();
        /*
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>("SELECT * FROM dbo.TypeInfo WHERE IsHierarchical=1 ORDER BY TypeId ASC");
            return res.ToList();
        }*/
    }


    /// <summary>
    /// Gets list with Type information from DB (hierarchical types only == rubrics), including current objects count
    /// </summary>
    /// <returns>TypeInfo</returns>
    public async Task<List<TypeInfo>> GetTypesHierarchicalWithCount()
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>(
                @"SELECT *, (select count(RubricId) from dbo.RubricInfo where TenantId=@TenantId and TypeId=T.TypeId) as [Count] 
FROM dbo.TypeInfo as T WHERE IsHierarchical=1 ORDER BY TypeName ASC", new { TenantId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Gets list with Type information from DB (flat types only == objects)
    /// </summary>
    /// <returns>TypeInfo</returns>
    public async Task<List<TypeInfo>> GetTypesFlat()
    {
        return (await GetTypes()).Where(x => !x.IsHierarchical).OrderBy(x => x.TypeName).ToList();
        /*
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>("SELECT * FROM dbo.TypeInfo WHERE IsHierarchical=0 ORDER BY TypeId ASC");
            return res.ToList();
        }
        */
    }


    /// <summary>
    /// Gets list with Type information from DB (flat types only == objects), including current objects count
    /// </summary>
    /// <returns>TypeInfo</returns>
    public async Task<List<TypeInfo>> GetTypesFlatWithCount()
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>(
                @"SELECT *, (select count(ObjectId) from dbo.ObjectInfo where TenantId=@TenantId and TypeId=T.TypeId) as [Count] 
FROM dbo.TypeInfo as T WHERE IsHierarchical=0 ORDER BY TypeName ASC", new { TenantId });
            return res.ToList();
        }
    }




    /// <summary>
    /// Get Type information from DB
    /// </summary>
    /// <param name="typeId">identifier (primary key) in dbo.TypeInfo</param>
    /// <returns>TypeInfo</returns>
    public async Task<TypeInfo> GetType(int typeId)
    {
        return (await GetTypes()).FirstOrDefault(x => x.TypeId == typeId);
        /*
        using (IDbConnection connection = new SqlConnection(ConnectionString)) {
            var res = await connection.QueryAsync<TypeInfo>("SELECT * FROM dbo.TypeInfo WHERE TypeId=@typeId", new { typeId });
            return res?.FirstOrDefault();
        }
        */
    }


    /// <summary>
    /// Get _Template ObjectId for a type
    /// </summary>
    /// <param name="typeId">identifier (primary key) in dbo.TypeInfo</param>
    /// <returns>int</returns>
    public async Task<int> GetTypeTemplateObjectId(int typeId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString)) {
            var res = await connection.ExecuteScalarAsync<int>("select TOP 1 ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName='_Template'", new { TenantId, typeId });
            return res;
        }
    }



    /// <summary>
    /// Get _Template Object for a type
    /// </summary>
    /// <param name="typeId">identifier (primary key) in dbo.TypeInfo</param>
    /// <returns>ObjectInfo</returns>
    public async Task<ObjectInfo?> GetTypeTemplateObject(int typeId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfo>("select TOP 1 * from dbo.ObjectInfo WHERE TenantId=@TenantId AND TypeId=@TypeId AND ObjectName='_Template'", new { TenantId, typeId });
            return res.FirstOrDefault();
        }
    }



    /// <summary>
    /// get Type for object
    /// </summary>
    /// <param name="objectId">object identifier</param>
    /// <returns>TypeInfo</returns>
    public async Task<TypeInfo> GetTypeByObjectId(int objectId)
    {
        int typeId;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            typeId = await connection.ExecuteScalarAsync<int>(@"SELECT TypeId FROM dbo.ObjectInfo WHERE ObjectId=@objectId", new { objectId });
        }
        var t = (await GetTypes()).FirstOrDefault(x => x.TypeId == typeId);
        return t;
        /*
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<TypeInfo>(@"
SELECT TI.* FROM dbo.TypeInfo as TI
INNER JOIN dbo.ObjectInfo as OI ON TI.TypeId=OI.TypeId
WHERE OI.ObjectId=@objectId", new { objectId });
            return res?.FirstOrDefault();
        }
        */
    }

    /// <summary>
    /// Update type
    /// </summary>
    /// <param name="type">type</param>
    /// <returns>Rows Affected (1 - ok, otherwise - fault)</returns>
    public async Task<int> UpdateType(Models.TypeInfo type)
    {
        int rowsAffected;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = @"EXEC dbo.TypeInfo_UpdateInsert @TypeId, @IsHierarchical, @TypeIdForRubric, @TypeName, @TableName, @UrlPrefix, @TypeComment, @ValidationSchema, @DataSchema, @FileRequired, @SettingsJson";
            rowsAffected = await connection.ExecuteScalarAsync<int>(sqlQuery, type);
        }
        _TenantTypes.Clear();
        return rowsAffected;
    }

    /// <summary>
    /// add type
    /// </summary>
    /// <param name="type">type (TypeId is ignored)</param>
    /// <returns>identifier of added type (it is replaced inside the object also!)</returns>
    public async Task<int> InsertType(Models.TypeInfo type)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = "EXEC dbo.TypeInfo_UpdateInsert @TypeId, @IsHierarchical, @TypeIdForRubric, @TypeName, @TableName, @UrlPrefix, @TypeComment, @ValidationSchema, @DataSchema, @FileRequired, @SettingsJson";
            type.TypeId = await connection.ExecuteScalarAsync<int>(sqlQuery, type);
        }
        _TenantTypes.Clear();
        return type.TypeId;
    }


    /// <summary>
    /// Delete type
    /// </summary>
    /// <param name="type">type</param>
    /// <returns>Rows Affected (1 - ok, otherwise - fault)</returns>
    public async Task<int> DeleteType(int typeId)
    {
        int rowsAffected;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = @"DELETE FROM dbo.TypeInfo WHERE TypeId=@typeId";
            rowsAffected = await connection.ExecuteAsync(sqlQuery, new { typeId });
        }
        _TenantTypes.Clear();
        return rowsAffected;
    }

}
