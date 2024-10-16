using System.Collections.Concurrent;
using System.Collections.Concurrent;
using System.Data;
using System.Data.SqlClient;
using System.Reflection.Emit;
using Dapper;
using InfProject.DTO;
using InfProject.Models;
using WebUtilsLib;
using static InfProject.Models.Composition;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// Scans DB for available chemical elements, regarding currently selected filter (chemical system, SearchPhrase, etc)
    /// </summary>
    /// <param name="filter">Filter</param>
    /// <returns>list of available for choosing chemical elements</returns>
    public async Task<List<string>> GetAvailableElements(Filter filter)
    {
        return await SearchByFilter<string>(SearchStoredProcedure_Filter.GetElements_Filter, filter);
    }

    public async Task<List<T>> SearchByFilter<T>(SearchStoredProcedure_Filter spMode, Filter? filter = null)
    {
        //if (filter == null || filter.IsEmpty)
        //    return await GetSamples();

        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var FilterCompositionItems = filter.CompositionItems.ToDataTable().AsTableValuedParameter("dbo.FilterCompositionItem");
            var FilterPropertyItems = filter.PropertyItems.ToDataTable().AsTableValuedParameter("dbo.FilterPropertyItem");
            IEnumerable<T> res = await connection.QueryAsync<T>($@"EXEC dbo.{spMode} @TenantId, @AccessControl, @UserId, @FilterCompositionItems, @FilterPropertyItems, @TypeId, @SearchPhrase, @CreatedByUser, @CreatedMin, @CreatedMax, @ObjectId, @ExternalId, @JSON",
            new
            {
                TenantId,
                filter.AccessFilter.AccessControl,
                filter.AccessFilter.UserId,
                FilterCompositionItems,
                FilterPropertyItems,
                filter.TypeId,
                filter.SearchPhrase,
                filter.CreatedByUser,
                filter.CreatedMin,
                filter.CreatedMax,
                filter.ObjectId,
                filter.ExternalId,
                JSON = filter.Json
            });
            return res.ToList();
        }
    }

    /// <summary>
    /// delete Compositions for EDX file
    /// </summary>
    /// <param name="edxObjectId"></param>
    /// <returns></returns>
    public async Task<int> EdxCompositions_Delete(int edxObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int retVal = await connection.ExecuteAsync("EXEC dbo.Delete_CompositionsForEdx @TenantId, @edxObjectId",
            new { TenantId, edxObjectId});
            return retVal;
        }
    }

    /// <summary>
    /// ObjectId==SampleId for Measurement Area
    /// </summary>
    /// <param name="typeId_MeasurementArea">"Measurement Area" or "Composition" TypeId</param>
    /// <param name="edxObjectId">objectId for file with EDX data (EDX CSV type)</param>
    /// <param name="measurementArea">value of Integer Property called "Measurement Area"</param>
    /// <returns>ObjectId==SampleId (if != 0 - object found; ==0 - not found)</returns>
    public async Task<int> FindEdxCompositionByMeasurementArea(int typeId_MeasurementArea, int edxCsvObjectId, int measurementArea)
    {
        const string measurementAreaPropertyName = "Measurement Area";
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            int retVal = await connection.ExecuteScalarAsync<int>("SELECT dbo.fn_GetMeasurementAreaObjectId(@TenantId, @TypeId_MeasurementArea, @edxCsvObjectId, @measurementAreaPropertyName, @measurementArea)",
            new { TenantId, typeId_MeasurementArea, edxCsvObjectId, measurementAreaPropertyName, measurementArea });
            return retVal;
        }
    }



    /// <summary>
    /// Finalizes sample name by changing an ObjectName with adding a specified prefix
    /// </summary>
    /// <param name="objectId">objectId to change</param>
    /// <param name="namePrefix">some string value to be prefix in ObjectName</param>
    /// <returns>Task</returns>
    public async Task FinalizeSampleName(int objectId, string namePrefix)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            await connection.ExecuteAsync("UPDATE dbo.ObjectInfo SET ObjectName=@namePrefix + ObjectName WHERE TenantId=@TenantId AND ObjectId=@objectId and LEFT(ObjectName, LEN(@namePrefix))<>@namePrefix",
            new { TenantId, objectId, namePrefix });
        }
    }



}
