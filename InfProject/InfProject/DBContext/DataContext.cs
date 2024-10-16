using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using System.Security.Claims;
using InfProject.DTO;
using System.Configuration;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using Microsoft.AspNetCore.Http;

namespace InfProject.DBContext;

public partial class DataContext
{
    #region General

    private static object myLock = new object();
    private static int smainVersion;
    /// <summary>
    /// Main version os SQL Server (12, 13, 14, etc...)
    /// </summary>
    public int MainVersion {
        get { 
            if (smainVersion > 0)
                return smainVersion;
            using (IDbConnection connection = new SqlConnection(ConnectionString)) {
                string res = connection.QueryFirst<string>(@"select SERVERPROPERTY ('productversion') as ver"); // "12.0.6433.1" for SQL Server 2014
                res = res.Substring(0, res.IndexOf('.'));
                int version = int.Parse(res);
                lock (myLock) {
                    smainVersion = version;
                }
            }
            return smainVersion;
        }
    }

    /// <summary>
    /// get STRING_SPLIT functionality on SQL Server of all versions
    /// </summary>
    /// <returns>STRING_SPLIT function name (build-in or manual)</returns>
    public string GetSTRING_SPLIT =>
        MainVersion > 12 ? "STRING_SPLIT" : "dbo.mySTRING_SPLIT";



    /// <summary>
    /// Database Connection String
    /// </summary>
    public string ConnectionString { get; init; }

    /// <summary>
    /// creates datacontext
    /// </summary>
    /// <param name="conn">ConnectionString</param>
    /// <param name="hostname">hostname (without https://)</param>
    public DataContext(string? conn, string hostname)
    {
        ConnectionString = conn ?? string.Empty;
        Tenant = GetTenant(hostname).Result;
    }

    public DataContext(IConfiguration configuration, IHttpContextAccessor httpContext) {
        string hostname = ConfigHelpers.ConfigHttpHelpers.GetHostByHttpContext(configuration, httpContext);
        ConnectionString = GetConnectionString(configuration, hostname);
        Tenant = GetTenant(hostname).Result;
    }

    public string GetConnectionString(IConfiguration configuration, string hostname) 
    {
        string conn = ConfigHelpers.ConfigHelpers.GetConnectionString(configuration, hostname);
        return conn ?? string.Empty;
    }

    public string GetConnectionString(IConfiguration configuration, IHttpContextAccessor httpContext)
    {
        string hostname = ConfigHelpers.ConfigHttpHelpers.GetHostByHttpContext(configuration, httpContext);
        return GetConnectionString(configuration, hostname);
    }


    /// <summary>
    /// Current Tenant (determined based on host name, e.g., inf.mdi.ruhr-uni-bochum.de)
    /// </summary>
    public Tenant Tenant { get; init; }

    /// <summary>
    /// Current TenantId (defined by host header)
    /// </summary>
    public int TenantId => Tenant.TenantId;



    /// <summary>
    /// Get name of the file
    /// </summary>
    /// <param name="id">ObjectId</param>
    /// <returns>relative file name</returns>
    public async Task<string> GetFileName(int id) {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<string>(@"select ObjectFilePath as FilePath from dbo.ObjectInfo WHERE TenantId=@TenantId AND ObjectId=@id", 
                new { TenantId, id });
            return res?.FirstOrDefault();
        }
    }


    /// <summary>
    /// Get Chemical Elements
    /// </summary>
    /// <returns>collection of Chemical Elements</returns>
    public async Task<List<string>> GetChemicalElements()
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<string>("SELECT ElementName FROM dbo.ElementInfo ORDER BY ElementName");
            return res.ToList();
        }
    }


    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql"></param>
    /// <param name="param"></param>
    /// <returns></returns>
    [Obsolete("REPLACE Execute")]
    public async Task Execute(string sql, object? param = null)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteAsync(sql, param);
        }
    }


    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql">sql query</param>
    /// <param name="connectionString">optional connectionString</param>
    /// <returns></returns>
    [Obsolete("REPLACE GetTable_ExecDevelopment")]
    public async Task<DataTable> GetTable_ExecDevelopment(string sql)
    {
        DataTable dt = await GetTable_ExecDevelopment(sql, ConnectionString);
        return dt;
    }

    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql">sql query</param>
    /// <param name="connectionString">optional connectionString</param>
    /// <returns></returns>
    [Obsolete("REPLACE GetTable_ExecDevelopment")]
    public static async Task<DataTable> GetTable_ExecDevelopment(string sql, string connectionString)
    {
        DataTable dt = new DataTable();
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand(sql, connection))
            {
                await connection.OpenAsync();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }
        }
        return dt;
    }


    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql">sql query</param>
    /// <param name="param">sql query parameters</param>
    /// <param name="connectionString">optional connectionString</param>
    /// <returns></returns>
    [Obsolete("REPLACE GetList_ExecDevelopment")]
    public async Task<List<T>> GetList_ExecDevelopment<T>(string sql, object? param = null, string? connectionString = null)
    {
        if (connectionString == null) {
            connectionString = ConnectionString;
        }
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            var res = await connection.QueryAsync<T>(sql, param);
            return res.ToList();
        }
    }


    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql"></param>
    /// <param name="connectionString">optional connectionString</param>
    /// <param name="param"></param>
    /// <returns></returns>
    [Obsolete("REPLACE GetList_ExecDevelopmentScalar")]
    public async Task<T> GetList_ExecDevelopmentScalar<T>(string sql, object? param = null)
    {
        return await GetList_ExecDevelopmentScalar<T>(sql, ConnectionString, param);
    }

    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="sql"></param>
    /// <param name="connectionString">optional connectionString</param>
    /// <param name="param"></param>
    /// <returns></returns>
    [Obsolete("REPLACE GetList_ExecDevelopmentScalar")]
    public static async Task<T> GetList_ExecDevelopmentScalar<T>(string sql, string connectionString, object? param = null)
    {
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            var res = await connection.ExecuteScalarAsync<T>(sql, param);
            return res;
        }
    }


    /// <summary>
    /// INSECURE: SQL INJECTION POSSIBLE (just for rapid development, then subject for replacement)
    /// </summary>
    /// <param name="tableName"></param>
    /// <param name="filter"></param>
    /// <returns></returns>
    [Obsolete("REPLACE GetItem_Development")]
    public async Task<dynamic> GetItem_Development(string tableName, string filter)
    {
        if (string.IsNullOrEmpty(tableName))
        {
            throw new ArgumentNullException(nameof(tableName));
        }
        if (string.IsNullOrEmpty(filter))
        {
            throw new ArgumentNullException(nameof(filter));
        }
        filter = " WHERE " + filter;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<dynamic>($"SELECT * FROM dbo.{tableName} {filter}");
            return res.First();
        }
    }

    #endregion // General

}
