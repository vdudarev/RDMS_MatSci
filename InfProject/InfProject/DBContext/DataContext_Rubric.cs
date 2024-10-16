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
using System.Runtime.InteropServices.JavaScript;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Diagnostics.Metrics;
using System.Collections.Generic;

namespace InfProject.DBContext;

public partial class DataContext
{
    #region Rubric
    [Obsolete("Use GetList_RubricTree_AccessControl", true)]
    public async Task<List<RubricInfo>> GetList_RubricTree(int idType, int maxLevel = 10)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.GetRubricTree @TenantId, @TypeId, @MaxLevel",
                new { TenantId, TypeId = idType, MaxLevel = maxLevel });
            return res.ToList();
        }
    }

    public async Task<List<RubricInfo>> GetList_RubricTree_AccessControl(int idType, AccessControlFilter accessFilter, int maxLevel = 10)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.GetRubricTree_AccessControl @TenantId, @TypeId, @MaxLevel, @AccessControl, @UserId",
                new { TenantId, TypeId = idType, MaxLevel = maxLevel, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }

    /// <summary>
    /// To show rubric tree with current path open in the app 
    /// </summary>
    /// <param name="idType"></param>
    /// <param name="idRubric">current RubricID</param>
    /// <param name="accessControl"></param>
    /// <param name="idUser"></param>
    /// <returns></returns>
    public async Task<List<RubricInfo>> GetList_Rubric_AccessControl(int idType, int idRubric, AccessControlFilter accessFilter, int maxLevel = 0)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.GetRubricWithPathOpened_AccessControl @TenantId, @TypeId, @RubricId, @MaxLevel, @AccessControl, @UserId",
                new { TenantId, TypeId = idType, RubricId = idRubric, MaxLevel = maxLevel, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
        }
    }


    public async Task<RubricInfo> GetRubricByUrl(string url)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"SELECT TOP 1 * FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricNameUrl=@url", 
                new { TenantId, url });
            return res.FirstOrDefault();
        }
    }


    public async Task<RubricInfo> GetRubricByRubricPath(string rubricPath)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"SELECT TOP 1 * FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricPath=@rubricPath",
                new { TenantId, rubricPath });
            return res.FirstOrDefault();
        }
    }



    public async Task<RubricInfo> GetRubricById(int id)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"SELECT TOP 1 * FROM dbo.RubricInfo WHERE TenantId=@TenantId AND RubricId=@id",
                new { TenantId, id });
            return res.FirstOrDefault();
        }
    }

    public async Task<List<RubricInfo>> GetRubricChildren(int idRubric, AccessControlFilter accessFilter)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.GetRubricChildren_AccessControl @TenantId, @RubricId, @AccessControl, @UserId",
                new { TenantId, RubricId = idRubric, AccessControl = (int)accessFilter.AccessControl, UserId = accessFilter.UserId });
            return res.ToList();
		}
    }

    public async Task<string> GetRubricPathString(int rubricId)
    {
        List<RubricInfo> list = await GetRubricPath(rubricId);
        var str = string.Join(" / ", list.Select(x => x.RubricName));
        return str;
    }

    public async Task<List<RubricInfo>> GetRubricPath(int rubricId)
	{
		using (IDbConnection connection = new SqlConnection(ConnectionString))
		{
			var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.GetRubricPath @TenantId, @RubricId",
				new { TenantId, RubricId = rubricId });
			return res.ToList();
		}
	}


	public async Task<RubricInfo> RubricInfo_UpdateInsert(RubricInfo rubric)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<RubricInfo>($"EXEC dbo.RubricInfo_UpdateInsert @RubricId, @TenantId, @_created, @_createdBy, @_updated, @_updatedBy, @TypeId, @ParentId, @Level, @LeafFlag, @Flags, @SortCode, @AccessControl, @IsPublished, @RubricName, @RubricNameUrl, @RubricPath", rubric);
            return res.FirstOrDefault();
        }
    }

    public async Task<int> RubricInfo_Delete(int rubricId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($"EXEC dbo.RubricInfo_Delete @TenantId, @rubricId", new { TenantId, rubricId });
            return res;
        }
    }

    #endregion // Rubric




    
    #region RubricInfoAdds

    public async Task<string?> GetRubricText(int rubricId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<string>($@"SELECT TOP 1 RubricText FROM dbo.RubricInfoAdds as RIA
INNER JOIN dbo.RubricInfo as RI ON RIA.RubricId=RI.RubricId AND RI.TenantId=@TenantId
WHERE RIA.RubricId=@rubricId",
                new { TenantId, rubricId });
            return res;
        }
    }


    /// <summary>
    /// Delete / Update / Insert in RubricInfoAdds ()
    /// </summary>
    /// <param name="rubricId"></param>
    /// <param name="rubricText"></param>
    /// <returns>rows affected (could be 0 or 1)</returns>
    public async Task<int> RubricInfoAdds_Update(int rubricId, string rubricText)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync($"EXEC dbo.RubricInfoAdds_Update @RubricId, @TenantId, @RubricText", 
                new { TenantId, RubricId = rubricId, RubricText = rubricText });
            return res;
        }
    }

    #endregion // RubricInfoAdds
}
