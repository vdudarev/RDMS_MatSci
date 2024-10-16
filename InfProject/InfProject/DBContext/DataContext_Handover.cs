using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Dapper;
using IdentityManagerUI.Models;
using InfProject.DTO;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using static InfProject.Models.Handover;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// Handover event list
    /// </summary>
    /// <param name="userId">user identifier</param>
    /// <param name="hType">type of handovers to output (HandoverType)</param>
    /// <param name="filterPendingOnly">if true - shows only pending handovers (DestinationConfirmed IS NULL)</param>
    /// <returns>List<Handover></returns>
    public async Task<List<Handover>> GetHandoversForUser(int userId, HandoverType hType = HandoverType.All, bool filterPendingOnly = false)
    {
        var sql = "select * from dbo.vHandover WHERE TenantId=@TenantId and #COND# ORDER BY _created DESC";
        switch (hType) {
            case HandoverType.Incoming:
                sql = sql.Replace("#COND#", "DestinationUserId=@userId" + (filterPendingOnly ? " AND DestinationConfirmed IS NULL" : string.Empty));
                break;
            case HandoverType.Outcoming:
                sql = sql.Replace("#COND#", "_createdBy=@userId" + (filterPendingOnly ? " AND DestinationConfirmed IS NULL" : string.Empty));
                break;
            default:
                sql = sql.Replace("#COND#", "(_createdBy=@userId OR DestinationUserId=@userId)" + (filterPendingOnly ? " AND DestinationConfirmed IS NULL" : string.Empty));
                break;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<Handover>(sql, 
                new { TenantId, userId });
            return res.ToList();
        }
    }


    /// <summary>
    /// Handover with samples event list
    /// </summary>
    /// <param name="userId">user identifier</param>
    /// <param name="hType">type of handovers to output (HandoverType)</param>
    /// <param name="filterPendingOnly">if true - shows only pending handovers (DestinationConfirmed IS NULL)</param>
    /// <returns>List<HandoverSample></returns>
    public async Task<List<HandoverSample>> GetHandoverSamplesForUser(int userId, HandoverType hType = HandoverType.All, bool filterPendingOnly = false)
    {
        var sql = @"select H.*, S.ElemNumber as SampleElemNumber, S.Elements as SampleElements, S.ObjectName as SampleObjectName, S.ObjectNameUrl as SampleObjectNameUrl
FROM dbo.vHandover as H 
INNER JOIN dbo.vSample as S ON H.SampleObjectId = S.SampleId 
WHERE H.TenantId=@TenantId and #COND# ORDER BY H._created DESC";
        switch (hType)
        {
            case HandoverType.Incoming:
                sql = sql.Replace("#COND#", "H.DestinationUserId=@userId" + (filterPendingOnly ? " AND H.DestinationConfirmed IS NULL" : string.Empty));
                break;
            case HandoverType.Outcoming:
                sql = sql.Replace("#COND#", "H._createdBy=@userId" + (filterPendingOnly ? " AND H.DestinationConfirmed IS NULL" : string.Empty));
                break;
            default:
                sql = sql.Replace("#COND#", "(H._createdBy=@userId OR H.DestinationUserId=@userId)" + (filterPendingOnly ? " AND H.DestinationConfirmed IS NULL" : string.Empty));
                break;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<HandoverSample>(sql,
                new { TenantId, userId });
            return res.ToList();
        }
    }




    /// <summary>
    /// Handover event list
    /// </summary>
    /// <param name="userId">user identifier</param>
    /// <param name="hType">type of handovers to output (HandoverType)</param>
    /// <returns>List<Handover></returns>
    public async Task<List<Handover>> GetHandoversForUsers(int[] userIds, HandoverType hType = HandoverType.All)
    {
        var sql = "select * from dbo.vHandover WHERE TenantId=@TenantId and #COND# ORDER BY _created DESC";
        switch (hType)
        {
            case HandoverType.Incoming:
                sql = sql.Replace("#COND#", "DestinationUserId IN (select [Value] from @userIds)"); break;
            case HandoverType.Outcoming:
                sql = sql.Replace("#COND#", "_createdBy IN (select [Value] from @userIds)"); break;
            default:
                sql = sql.Replace("#COND#", "((_createdBy IN (select [Value] from @userIds)) OR (DestinationUserId IN (select [Value] from @userIds)))"); break;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<Handover>(sql,
                new { TenantId, userIds = DBUtils.GetTableParameterFromSingleColumn(userIds).AsTableValuedParameter("dbo.Integers") });
            return res.ToList();
        }
    }



    /// <summary>
    /// Handover event list
    /// </summary>
    /// <param name="userIds">users identifiers</param>
    /// <param name="hType">type of handovers to output (HandoverType)</param>
    /// <returns>List<HandoverSample></returns>
    public async Task<List<HandoverSample>> GetHandoverSamplesForUsers(int[] userIds, HandoverType hType = HandoverType.All)
    {
        var sql = @"select H.*, S.ElemNumber as SampleElemNumber, S.Elements as SampleElements, S.ObjectName as SampleObjectName, S.ObjectNameUrl as SampleObjectNameUrl
FROM dbo.vHandover as H 
INNER JOIN dbo.vSample as S ON H.SampleObjectId = S.SampleId 
WHERE H.TenantId=@TenantId and #COND# ORDER BY H._created DESC";
        switch (hType)
        {
            case HandoverType.Incoming:
                sql = sql.Replace("#COND#", "H.DestinationUserId IN (select [Value] from @userIds)"); break;
            case HandoverType.Outcoming:
                sql = sql.Replace("#COND#", "H._createdBy IN (select [Value] from @userIds)"); break;
            default:
                sql = sql.Replace("#COND#", "((H._createdBy IN (select [Value] from @userIds)) OR (H.DestinationUserId IN (select [Value] from @userIds)))"); break;
        }
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<HandoverSample>(sql,
                new { TenantId, userIds = DBUtils.GetTableParameterFromSingleColumn(userIds).AsTableValuedParameter("dbo.Integers") });
            return res.ToList();
        }
    }



    /// <summary>
    /// Gets current samples (according to last handover infromation) that are for the user
    /// </summary>
    /// <param name="userId">user identifier</param>
    /// <returns>List<HandoverSample></returns>
    public async Task<List<HandoverSample>> GetCurrentSamplesForUserAccordingToHandovers(int userId)
    {
        var sql = @"select H.*, S.ElemNumber as SampleElemNumber, S.Elements as SampleElements, S.ObjectName as SampleObjectName, S.ObjectNameUrl as SampleObjectNameUrl
FROM dbo.vHandover as H 
INNER JOIN dbo.vSample as S ON H.SampleObjectId = S.SampleId 
WHERE H.TenantId=@TenantId 
and H.HandoverId IN (SELECT MAX(HandoverId) from dbo.Handover GROUP BY SampleObjectId)  -- last handover in the sample
and H.DestinationUserId=@userId ORDER BY H._created DESC";
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<HandoverSample>(sql,
                new { TenantId, userId });
            return res.ToList();
        }
    }



    /// <summary>
    /// Gets current samples (according to last handover infromation) that are in the group of users (userIds)
    /// </summary>
    /// <param name="userIds">users identifiers</param>
    /// <returns>List<HandoverSample></returns>
    public async Task<List<HandoverSample>> GetCurrentSamplesForUsersAccordingToHandovers(int[] userIds)
    {
        var sql = @"select H.*, S.ElemNumber as SampleElemNumber, S.Elements as SampleElements, S.ObjectName as SampleObjectName, S.ObjectNameUrl as SampleObjectNameUrl
FROM dbo.vHandover as H 
INNER JOIN dbo.vSample as S ON H.SampleObjectId = S.SampleId 
WHERE H.TenantId=@TenantId 
and H.HandoverId IN (SELECT MAX(HandoverId) from dbo.Handover GROUP BY SampleObjectId)  -- last handover in the sample
and H.DestinationUserId IN (select [Value] from @userIds) ORDER BY H._created DESC";
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<HandoverSample>(sql,
                new { TenantId, userIds = DBUtils.GetTableParameterFromSingleColumn(userIds).AsTableValuedParameter("dbo.Integers") });
            return res.ToList();
        }
    }



    public async Task<List<Handover>> GetHandoversForObject(int sampleObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryAsync<Handover>("select * from dbo.vHandover WHERE TenantId=@TenantId and SampleObjectId=@sampleObjectId ORDER BY _created DESC",
                new { TenantId, sampleObjectId });
            return res.ToList();
        }
    }


    public async Task<Handover> GetHandover(int handoverObjectId)
    {
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = await connection.QueryFirstAsync<Handover>("select * from dbo.vHandover WHERE TenantId=@TenantId and ObjectId=@handoverObjectId",
                new { TenantId, handoverObjectId });
            return res;
        }
    }


    /// <summary>
    /// Add Handover For Object
    /// </summary>
    /// <param name="senderUser">current context user (sender)</param>
    /// <param name="sample">sample</param>
    /// <param name="destinationUser">destination user</param>
    /// <param name="objectDescription">comment from sender</param>
    /// <param name="Amount">Amount - optional</param>
    /// <param name="MeasurementUnit">Measurement Unit - optional</param>
    /// <returns>Handover</returns>
    /// <exception cref="Exception"></exception>
    public async Task<Handover> AddHandoverForObject(WebAppUser senderUser, ObjectInfo sample, WebAppUser destinationUser, string objectDescription, double Amount, string MeasurementUnit)
    {
        if (sample == null) {
            throw new Exception($"Sample is not found");
        }
        if (string.IsNullOrEmpty(senderUser?.Email)) {
            throw new Exception($"Sender e-mail is not defined");
        }
        if (string.IsNullOrEmpty(senderUser.Name))
        {
            senderUser.Name = senderUser.Email; // Name claim is optional
            // throw new Exception($"Sender name is not defined [specify \"Name\" claim]");
        }
        if (string.IsNullOrEmpty(destinationUser?.Email))
        {
            throw new Exception($"Destination user e-mail is not defined");
        }
        if (string.IsNullOrEmpty(destinationUser.Name))
        {
            destinationUser.Name = destinationUser.Email;   // Name claim is optional
            // throw new Exception($"Destination name is not defined [specify \"Name\" claim]");
        }
        string amoutWithUnit = Amount > 0 ? $"{Amount} {MeasurementUnit} ".Replace("  ", " ") : string.Empty;
        string objName = $"{(sample.ExternalId!=0 ? sample.ExternalId.ToString() : sample.ObjectName)} sample {amoutWithUnit}handover to {destinationUser.Name} [{destinationUser.Email}] on {DateTime.Now}";
        
        Handover handover = new Handover() {
            TenantId = TenantId, TypeId = HandoverTypeId, 
            RubricId=sample.RubricId, AccessControl = sample.AccessControl,
            _createdBy = senderUser.Id, SampleObjectId = sample.ObjectId, DestinationUserId = destinationUser.Id, 
            Amount = Amount, MeasurementUnit = MeasurementUnit,
            ObjectName = objName, ObjectDescription = objectDescription
        };

        Handover handoverRet = await ObjectInfo_UpdateInsertVirtual<Handover>(handover);

        return handoverRet;
    }


    /// <summary>
    /// Confirm Handover For Object
    /// </summary>
    /// <param name="userId">current context user (recepient)</param>
    /// <param name="sampleObjectId">sample</param>
    /// <param name="handoverId">Handover ObjectId</param>
    /// <param name="destinationComments">comment from sender</param>
    /// <returns>Handover</returns>
    /// <exception cref="Exception"></exception>
    public async Task<Handover> ConfirmHandover(int userId, int sampleObjectId, int handoverId, string destinationComments)
    {
        var handover = await GetHandover(handoverId);
        if (handover.DestinationConfirmed.HasValue)
        {
            throw new Exception("This handover was already confirmed");
        }
        if (handover.SampleObjectId != sampleObjectId)
        {
            throw new Exception($"Current handover is designated for another sample [handover.SampleObjectId={handover.SampleObjectId}, sampleObjectId={sampleObjectId}]");
        }
        if (string.IsNullOrEmpty(destinationComments))
        {
            throw new Exception("Recepient comments are mandatory");
        }

        handover._updatedBy = userId;
        handover.DestinationConfirmed = DateTime.Now;
        handover.DestinationComments = destinationComments;

        Handover handoverRet = await ObjectInfo_UpdateInsertVirtual<Handover>(handover);

        return handoverRet;
    }

}
