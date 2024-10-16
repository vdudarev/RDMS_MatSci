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
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using System.Diagnostics.Metrics;
using OfficeOpenXml.Packaging.Ionic.Zlib;
using System.Collections.Generic;

namespace InfProject.DBContext;

public partial class DataContext
{
    #region ObjectLinkObjects

    /// <summary>
    /// Get ALL Linked Objects count for specified object
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>count</returns>
    public async Task<int> ObjectLinkObject_GetLinkedObjectsCount(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<int>(
                "select count (ObjectLinkObjectId) as cnt FROM dbo.ObjectLinkObject WHERE ObjectId=@objectId", 
                new { TenantId, objectId });
            return res;
        }
    }

    /// <summary>
    /// Get ALL Linked Objects
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns></returns>
    public async Task<List<ObjectInfoLinked>> ObjectLinkObject_GetLinkedObjects(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfoLinked>($@"EXEC dbo.Get_ObjectInfoLinked @TenantId, @objectId", new { TenantId, objectId });
            return res.ToList();
        }
    }

    /// <summary>
    /// Get ALL Linked Objects with respect to access filter
    /// </summary>
    /// <param name="objectId"></param>
    /// <param name="accessFilter"></param>
    /// <returns></returns>
    public async Task<List<ObjectInfoLinked>> ObjectLinkObject_GetLinkedObjects(int objectId, AccessControlFilter accessFilter)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfoLinked>($@"EXEC dbo.Get_ObjectInfoLinked_AccessControl @TenantId, @objectId, @AccessControl, @UserId",
                new { TenantId, objectId, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Get ALL Reversely Linked Objects
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns></returns>
    public async Task<List<ObjectInfoLinked>> ObjectLinkObject_GetLinkedObjects_Reverse(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfoLinked>($@"EXEC dbo.Get_ObjectInfoLinked_Reverse @TenantId, @objectId", new { TenantId, objectId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Get ALL Reversely Linked Objects with respect to access filter
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns></returns>
    public async Task<List<ObjectInfoLinked>> ObjectLinkObject_GetLinkedObjects_Reverse(int objectId, AccessControlFilter accessFilter)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfoLinked>($@"EXEC dbo.Get_ObjectInfoLinked_Reverse_AccessControl @TenantId, @objectId, @AccessControl, @UserId", 
                new { TenantId, objectId, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }


    public async Task<int> ObjectLinkObject_Delete(int objectLinkObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync(
@"IF EXISTS (select L.ObjectLinkObjectId from dbo.ObjectLinkObject as L INNER JOIN dbo.ObjectInfo as OI ON L.ObjectId=OI.ObjectId WHERE L.ObjectLinkObjectId=@objectLinkObjectId AND OI.TenantId=@TenantId)
    DELETE FROM dbo.ObjectLinkObject as L WHERE ObjectLinkObjectId=@objectLinkObjectId", 
                new { TenantId, objectLinkObjectId });
            return res;
        }
    }

    public async Task<int> ObjectLinkObject_Delete(int ObjectId, int LinkedObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync(
@"IF EXISTS (select L.ObjectLinkObjectId from dbo.ObjectLinkObject as L INNER JOIN dbo.ObjectInfo as OI ON L.ObjectId=OI.ObjectId WHERE L.ObjectLinkObjectId=@objectLinkObjectId AND OI.TenantId=@TenantId)
    DELETE FROM dbo.ObjectLinkObject WHERE ObjectId=@ObjectId AND LinkedObjectId=@LinkedObjectId", 
                new { TenantId, ObjectId, LinkedObjectId });
            return res;
        }
    }

    public async Task<List<ObjectInfoLinked>> ObjectLinkObject_LinksUpdate(int userId, ObjectLinks links)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectInfoLinked>($"EXEC dbo.ObjectLinkObject_LinksUpdate @LinkedObjects, @TenantId, @ObjectId, @_created, @_createdBy, @_updated, @_updatedBy", 
                new { LinkedObjects = ObjectLinks.Link.GetTableParameter(links.ObjectId, links.Links).AsTableValuedParameter("dbo.ObjectLinkObjectItem"),
                    TenantId, ObjectId = links.ObjectId, _created=DateTime.Now, _createdBy=userId, _updated=DateTime.Now, _updatedBy=userId });
            return res.ToList();
        }
    }

    public async Task<int> ObjectLinkObject_LinksInsertForStagedFiles(int userId, IEnumerable<(int ObjectId, int LinkedObjectId, int SortCode, int LinkTypeObjectId)> links)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($"EXEC dbo.ObjectLinkObject_LinksInsertForStagedFiles @LinkedObjects, @TenantId, @UserId",
                new
                {
                    LinkedObjects = ObjectLinks.GetTableParameter(links).AsTableValuedParameter("dbo.ObjectLinkObjectItem"),
                    TenantId,
                    UserId = userId
                });
            return res;
        }
    }

    public async Task<int> ObjectLinkObject_LinkAdd(int objectId, int linkedObjectId, int userId, int? SortCode, int? linkTypeObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int rowsAffected = await connection.ExecuteAsync($"EXEC dbo.ObjectLinkObject_LinkAdd @TenantId, @ObjectId, @LinkedObjectId, @_created, @_createdBy, @_updated, @_updatedBy, @SortCode, @LinkTypeObjectId",
                new
                {
                    TenantId,
                    ObjectId = objectId,
                    LinkedObjectId = linkedObjectId,
                    _created = DateTime.Now,
                    _createdBy = userId,
                    _updated = DateTime.Now,
                    _updatedBy = userId,
                    SortCode = SortCode,
                    LinkTypeObjectId = linkTypeObjectId
                });
            return rowsAffected;
        }
    }

    #endregion // ObjectLinkObjects

}
