using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;
using System.Reflection.Emit;
using Dapper;
using InfProject.DTO;
using InfProject.Models;
using Microsoft.AspNetCore.Mvc;
using WebUtilsLib;
using static InfProject.Models.Composition;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// return list of associated (additional) rubrics for object 
    /// </summary>
    /// <param name="objectId">Filter</param>
    /// <returns>IEnumerable of additional ObjectLinkRubric</returns>
    public async Task<IEnumerable<ObjectLinkRubric>> GetObjectLinkRubricByObject(int objectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var list = await connection.QueryAsync<ObjectLinkRubric>("select RubricId, SortCode from dbo.ObjectLinkRubric WHERE ObjectId=@objectId",
                new { objectId });
            return list;
        }
    }


    /// <summary>
    /// return ObjectLinkRubric by Id
    /// </summary>
    /// <param name="objectLinkRubricId">Filter</param>
    /// <returns>ObjectLinkRubric</returns>
    public async Task<ObjectLinkRubric?> GetObjectLinkRubricById(int objectLinkRubricId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<ObjectLinkRubric>("select * from dbo.ObjectLinkRubric WHERE ObjectLinkRubricId=@objectLinkRubricId",
                new { objectLinkRubricId });
            return res.FirstOrDefault();
        }
    }


    /// <summary>
    /// Adds (or updates) link in ObjectLinkRubric table by (rubricId, objectId) key
    /// </summary>
    /// <param name="rubricId">RubricId to control objects integrity</param>
    /// <param name="objectId">ObjectId to control objects integrity</param>
    /// <param name="sortCode">SortCode (to sort within a list ASCENDING)</param>
    /// <param name="userId">user, who adds/modifies the record</param>
    /// <returns>rows affected</returns>
    public async Task<int> ObjectLinkRubric_AddOrUpdateLink(int rubricId, int objectId, int sortCode, int userId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($@"
IF EXISTS(select ObjectLinkRubricId from dbo.ObjectLinkRubric where RubricId=@rubricId and ObjectId=@objectId)
    UPDATE dbo.ObjectLinkRubric SET SortCode=@sortCode, _updated=getdate(), _updatedBy=@userId 
    WHERE RubricId=@rubricId AND ObjectId=@objectId
ELSE IF EXISTS (select top 1 ObjectId from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@objectId)
    INSERT INTO dbo.ObjectLinkRubric(RubricId, ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy) 
    VALUES(@rubricId, @objectId, @sortCode, getdate(), @userId, getdate(), @userId)", 
        new { TenantId, rubricId, objectId, sortCode, userId });
            return res;
        }
    }



    /// <summary>
    /// Updates SortCode in ObjectLinkRubric
    /// </summary>
    /// <param name="objectLinkRubricId">primary key</param>
    /// <param name="objectId">ObjectId to control objects integrity</param>
    /// <param name="rubricId">RubricId to control objects integrity</param>
    /// <param name="sortCode">SortCode (to sort within a list ASCENDING)</param>
    /// <param name="userId">user, who modifies the record</param>
    /// <returns>rows affected</returns>
    public async Task<int> ObjectLinkRubric_UpdateSortCode(int objectLinkRubricId, int objectId, int rubricId, int sortCode, int userId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($@"UPDATE dbo.ObjectLinkRubric 
SET SortCode=@sortCode, _updated=getdate(), _updatedBy=@userId 
WHERE ObjectLinkRubricId=@objectLinkRubricId AND RubricId=@rubricId AND ObjectId=@objectId", new { objectLinkRubricId, objectId, rubricId, sortCode, userId });
            return res;
        }
    }


    /// <summary>
    /// delete ObjectLinkRubric (linkage of object to rubric)
    /// </summary>
    /// <param name="objectLinkRubricId">primary key</param>
    /// <param name="objectId">ObjectId to control objects integrity</param>
    /// <param name="rubricId">RubricId to control objects integrity</param>
    /// <returns>rows affected</returns>
    public async Task<int> ObjectLinkRubric_Delete(int objectLinkRubricId, int objectId, int rubricId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($@"DELETE FROM dbo.ObjectLinkRubric WHERE ObjectLinkRubricId=@objectLinkRubricId AND RubricId=@rubricId AND ObjectId=@objectId", 
                new { objectLinkRubricId, objectId, rubricId });
            return res;
        }
    }

    /// <summary>
    /// delete ObjectLinkRubric (linkage of object to rubric) for a specified object (probably multiple rows)
    /// </summary>
    /// <param name="objectId">ObjectId to control objects integrity</param>
    /// <param name="skipRubrics">Array of RubricId that sjould not be deelted</param>
    /// <returns>rows affected</returns>
    public async Task<int> ObjectLinkRubric_DeleteForObject(int objectId, int[]? skipRubrics=null)
    {
        int rowsAffected = 0;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            if (skipRubrics == null || skipRubrics.Length == 0) {   // no filter - delete all links for ObjectId
                rowsAffected = await connection.ExecuteAsync($@"DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId=@objectId", new { objectId });
            }
            else { // delete EXCEPT skipRubrics
                string csv = string.Join(',', skipRubrics);
                rowsAffected = await connection.ExecuteAsync($@"DELETE FROM dbo.ObjectLinkRubric WHERE ObjectId=@objectId AND RubricId NOT IN ({csv})", new { objectId, csv });
            }
            return rowsAffected;
        }
    }

}
