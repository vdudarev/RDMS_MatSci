using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;
using Dapper;
using IdentityManagerUI.Models;
using InfProject.DTO;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// USERS ARE TENANT INDEPENDENT, BUT DB-DEPENDANT!!!
    
    // local cache (for performance)
    private ConcurrentDictionary<int, WebAppUser> users = new ConcurrentDictionary<int, WebAppUser>();



    /// <summary>
    /// static cache for projects (tenant aware)
    /// </summary>
    private static ConcurrentDictionary<int, HashSet<string>> tenantProjects = new ConcurrentDictionary<int, HashSet<string>>();

    /// <summary>
    /// HashSet with Projects
    /// </summary>
    public HashSet<string> Projects { get {
            HashSet<string> ret;
            if (tenantProjects.TryGetValue(TenantId, out ret)) {
                return ret;
            }
            IEnumerable<string> proj = GetDistinctClaims("Project").Result;
            ret = [.. proj];
            tenantProjects.TryAdd(TenantId, ret);
            return ret;
        }
    }

    /// <summary>
    /// Get all distinct claims from AspNetUserClaims by ClaimType (initialy done for 'Project')
    /// </summary>
    /// <param name="claimType">claim name</param>
    /// <returns>IEnumerable<string></returns>
    public async Task<IEnumerable<string>> GetDistinctClaims(string claimType)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            IEnumerable<string> res = await connection.QueryAsync<string>(@"SELECT DISTINCT ClaimValue FROM dbo.AspNetUserClaims WHERE ClaimType=@claimType", new { claimType });
            return res;
        }
    }


	/// <summary>
	/// Get all distinct UserIds from AspNetUserClaims by ClaimType and ClaimValue (initialy done for 'Project' and '<ProjectName>')
	/// </summary>
	/// <param name="claimType">claim name</param>
	/// <param name="claimValue">claim value</param>
	/// <returns>IEnumerable<string></returns>
	public async Task<IEnumerable<int>> GetUserIdsByClaim(string claimType, string claimValue)
	{
		using (IDbConnection connection = new SqlConnection(ConnectionString))
		{
			IEnumerable<int> res = await connection.QueryAsync<int>(@"SELECT DISTINCT UserId FROM dbo.AspNetUserClaims WHERE ClaimType=@claimType and ClaimValue=@claimValue", 
                new { claimType, claimValue });
			return res;
		}
	}


	public async Task<WebAppUser> GetUser(int userId)
    {
        WebAppUser user;
        if (users.TryGetValue(userId, out user)) {
            return user;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString)) {
            var res = await connection.QueryAsync<WebAppUser>(@"SELECT U.*,
[dbo].[fn_GetUserClaimCSV](U.Id, 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name') as [Name], 
CAST(IIF( CONVERT(INT, CASE WHEN IsNumeric([dbo].[fn_GetUserClaimCSV](U.Id, 'NDA')) = 1 THEN [dbo].[fn_GetUserClaimCSV](U.Id, 'NDA') ELSE 0 END) <> 0, 1, 0) as bit) as NDA, 
[dbo].[fn_GetUserClaimCSV](U.Id, 'Project') as Project
FROM dbo.AspNetUsers as U 
WHERE U.Id=@id", new { id = userId });
            user = res.First();
            users.TryAdd(userId, user);
            return user;
        }
    }


    public async Task<List<WebAppUser>> GetAvailableUsers(Filter filter) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<WebAppUser>($@"EXEC dbo.GetUserList_AccessControl @TenantId, @AccessControl, @UserId",
                new { TenantId, AccessControl = filter.AccessFilter.AccessControl, UserId = filter.AccessFilter.UserId });
            return res.ToList();
        }
    }

    public async Task<List<WebAppUser>> GetUserListAll()
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<WebAppUser>("EXEC dbo.GetUserListAll");
            return res.ToList();
        }
    }

    public async Task<List<WebAppUser>> GetUserListActive()
    {
        var res = await GetUserListAll();
        return res.Where(x => !x.LockoutEnd.HasValue || x.LockoutEnd.Value > DateTime.SpecifyKind(DateTime.Now, DateTimeKind.Local)).ToList();
    }

    /// <summary>
    /// Gets UserId of active user with specified claim (name, value)
    /// </summary>
    /// <param name="apiKeyName">claim name</param>
    /// <param name="apiKeyValue">claim value</param>
    /// <returns>UserId of a user (0 - not found)</returns>
    public async Task<int> GetActiveUserIdWithClaimValue(string apiKeyName, string apiKeyValue)
    {
        int userId = await GetList_ExecDevelopmentScalar<int>(
            sql: $@"DECLARE @UserId int;
select @UserId=C.UserId FROM dbo.AspNetUserClaims as C 
    INNER JOIN dbo.AspNetUsers as U ON C.UserId=U.Id
WHERE U.LockoutEnd IS NULL AND C.ClaimType=@ClaimType and C.ClaimValue=@ClaimValue;
select ISNULL(@UserId, 0) as UserId",
            new { ClaimType = apiKeyName, ClaimValue = apiKeyValue });
        return userId;
    }

}
