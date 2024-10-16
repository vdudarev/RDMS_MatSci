using Dapper;
using InfProject.DTO;
using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;

namespace InfProject.DBContext;

public partial class DataContext
{
    static ConcurrentDictionary<string, Tenant> TenantByUrl = new ConcurrentDictionary<string, Tenant>();


    public async Task<List<Tenant>> GetTenants() {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<Tenant>("SELECT * FROM dbo.Tenant ORDER BY TenantUrl");
            return res.ToList();
        }
    }

    /// <summary>
    /// Get Tenant (basic administrative unit) from DB
    /// </summary>
    /// <param name="tenantUrl">Tenant Url</param>
    /// <returns>Tenant</returns>
    public async Task<Tenant> GetTenant(string tenantUrl)
    {
        tenantUrl = tenantUrl.ToLower();
        Tenant t;
        if (TenantByUrl.TryGetValue(tenantUrl, out t)) {
            return t;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<Tenant>("SELECT TOP 1 * FROM dbo.Tenant WHERE TenantUrl=@tenantUrl", new { tenantUrl });
            t = res.First();
            TenantByUrl[tenantUrl] = t;
        }
        return t;
    }

    /// <summary>
    /// Get Tenant (basic administrative unit) from DB
    /// </summary>
    /// <param name="tenantId">tenant's identifier</param>
    /// <returns>Tenant</returns>
    public async Task<Tenant> GetTenant(int tenantId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString)) {
            var res = await connection.QueryAsync<Tenant>("SELECT * FROM dbo.Tenant WHERE TenantId=@tenantId", new { tenantId });
            return res.First();
        }
    }

    /// <summary>
    /// Delete tenant
    /// </summary>
    /// <param name="tenantId">tenant's identifier</param>
    /// <returns>(Rows Affected: 1 - ok, otherwise - fault, TenantUrl - Tenant url for redirect)</returns>
    public async Task<(int rc, string TenantUrl)> DeleteTenant(int tenantId) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = "EXEC dbo.DeleteTenant @tenantId";
            (int rc, string TenantUrl) pair = await connection.QueryFirstAsync<(int rc, string TenantUrl)>(sqlQuery, new { tenantId });
            return pair;
        }
    }

    /// <summary>
    /// Update tenant
    /// </summary>
    /// <param name="tenant">tenant</param>
    /// <returns>Rows Affected (1 - ok, otherwise - fault)</returns>
    public async Task<int> UpdateTenant(Tenant tenant) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = @"EXEC dbo.UpdateTenant @TenantId, @_date, @TenantUrl, @TenantName, @AccessControl";
            return await connection.ExecuteScalarAsync<int>(sqlQuery, tenant);
        }
    }

    /// <summary>
    /// add tenant
    /// </summary>
    /// <param name="tenant">tenant (TenantId is ignored)</param>
    /// <returns>identifier of added tenant (it is replaced inside the object also!)</returns>
    public async Task<int> InsertTenant(Tenant tenant) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var sqlQuery = "EXEC dbo.InsertTenant @TenantId, @_date, @TenantUrl, @TenantName, @AccessControl";
            return tenant.TenantId = await connection.ExecuteScalarAsync<int>(sqlQuery, tenant);
        }
    }

}
