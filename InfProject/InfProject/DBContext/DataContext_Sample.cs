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

    /// <summary>
    /// Gets Substrate(ObjectId) for Sample (ObjectId)
    /// For Substrate TypeId == 5
    /// </summary>
    /// <param name="objectId">true - consider all tenants in DB, otherwise - the current tenant only</param>
    /// <returns>List of objects derived from ObjectInfo</returns>
    public async Task<int> GetSubstrateIdForSample(int sampleObjectId)
    {
        if (sampleObjectId <= 0)
            return sampleObjectId;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<int>(@"SELECT TOP 1 LinkedObjectId from dbo.ObjectLinkObject as LI
INNER JOIN dbo.ObjectInfo as OI ON LI.LinkedObjectId=OI.ObjectId AND OI.TypeId=5
WHERE LI.ObjectId=@sampleObjectId", 
                new { sampleObjectId });
            return res;
        }
    }


    /// <summary>
    /// Adds Processing Step as a new sample (by copying Sample From previous state ObjectId)
    /// Gets new sample ObjectId
    /// For Sample TypeId == 6
    /// </summary>
    /// <param name="sampleObjectId">parent sample objectId (to copy)</param>
    /// <param name="stepDescription">Description for a new sample</param>
    /// <param name="userId"></param>
    /// <returns></returns>
    public async Task<int> SampleAddProcessingStep(int sampleObjectId, string stepDescription, int userId)
    {
        int typeId = SampleTypeId;
        if (sampleObjectId <= 0)
            return sampleObjectId;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<int>(@"EXEC dbo.SampleAddProcessingStep @ObjectId, @TenantId, @_createdBy, @StepDescription, @TypeId",
                new { ObjectId = sampleObjectId, TenantId, _createdBy = userId, StepDescription = stepDescription, TypeId = typeId });
            return res;
        }
    }


    /// <summary>
    /// Adds several pieces as new samples (by copying Sample From previous state ObjectId)
    /// Gets new sample ObjectId
    /// </summary>
    /// <param name="sampleObjectId">parent sample ObjectId (to copy)</param>
    /// <param name="pieceDescription">Description for a piece</param>
    /// <param name="userId">UserId</param>
    /// <param name="piecesCount">number of pieces to divide a sample</param>
    /// <returns></returns>
    public async Task<int> SampleSplitIntoPieces(int sampleObjectId, string pieceDescription, int userId, int piecesCount)
    {
        int typeId = SampleTypeId;
        if (sampleObjectId <= 0)
            return sampleObjectId;
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.ExecuteScalarAsync<int>(@"EXEC dbo.SampleSplitIntoPieces @ObjectId, @TenantId, @_createdBy, @PieceDescription, @PieceCount, @TypeId",
                new { ObjectId = sampleObjectId, TenantId, _createdBy = userId, PieceDescription = pieceDescription, PieceCount = piecesCount, TypeId = typeId });
            return res;
        }
    }

}
