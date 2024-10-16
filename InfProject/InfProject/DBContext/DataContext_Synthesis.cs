using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Reflection.Metadata;
using System.Text;
using Dapper;
using IdentityManagerUI.Models;
using InfProject.DTO;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.CodeAnalysis.Elfie.Diagnostics;
using Newtonsoft.Json.Linq;
using TypeValidationLibrary;
using WebUtilsLib;
using static InfProject.Controllers.CustomController;
using static InfProject.Models.Handover;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using static OfficeOpenXml.ExcelErrorValue;
using static WebUtilsLib.DBUtils;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// updates synthesis data from JSON batch for sample
    /// </summary>
    /// <param name="userId">user Id</param>
    /// <param name="sampleObject">sample object</param>
    /// <param name="jsonObj">json with synthesis documents</param>
    /// <returns>Task</returns>
    public async Task<TypeValidatorResult> UpdateSynthesisBatch(int userId, ObjectInfo sampleObject, JObject jsonObj)
    {
        // read a template to match properties (by name), other should be rejected
        List<PropertyValue> templateProperties = await Property_GetTemplatePropertiesForType(SynthesisTypeId);

        var objectsArray = jsonObj["ProcessingStep"];
        DateTime dt = DateTime.Now.AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)

        TypeValidatorResult vr = new TypeValidatorResult();
        StringBuilder sb = new StringBuilder();
        bool deleteOnNullValues = true;
        int inserted = 0, updated = 0, deletedOnNullValues = 0, deletedOld = 0;
        string type = null;
        string svalue = null;
        object? value = null;
        string name = null;
        string ssortcode = null;
        int sortcode = 0;
        string objectOldToDelete = null;
        try
        {
            using (var connection = new SqlConnection(ConnectionString))
            {
                connection.Open();
                /*
                            DynamicParameters parameters = new DynamicParameters(); // new DynamicParameters(par);
                            parameters.Add("retval", 0, DbType.Int32, direction: ParameterDirection.ReturnValue);
                            parameters.Add("TenantId", TenantId, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("PropertyId", value.PropertyId, DbType.Int32, direction: ParameterDirection.InputOutput);
                            parameters.Add("ObjectId", objectId, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("SortCode", value.SortCode, // row == 2 ? col*10 : 0, 
                                DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("_created", created, DbType.DateTime, direction: ParameterDirection.Input);
                            parameters.Add("_createdBy", userId, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("_updated", created, DbType.DateTime, direction: ParameterDirection.Input);
                            parameters.Add("_updatedBy", userId, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("Row", value.Row, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("Value", value.Value, GetDbTypeByPropertyType(value.PropertyType), direction: ParameterDirection.Input);
                            parameters.Add("ValueEpsilon", value.ValueEpsilon == null ? DBNull.Value : value.ValueEpsilon, DbType.Double, direction: ParameterDirection.Input);
                            parameters.Add("PropertyName", value.PropertyName, DbType.String, direction: ParameterDirection.Input);
                            parameters.Add("Comment", value.Comment == null ? DBNull.Value : value.Comment, DbType.String, direction: ParameterDirection.Input);
                            parameters.Add("SourceObjectId", value.SourceObjectId, DbType.Int32, direction: ParameterDirection.Input);
                            parameters.Add("DeleteOnNullValues", deleteOnNullValues, DbType.Boolean, direction: ParameterDirection.Input);

                            // UPDATE / INSERT in database
                            PropertyType mode = value.PropertyType;
                            return await Property_UpdateInsert(mode, parameters, connection);
                */
                using (var transaction = connection.BeginTransaction())
                {
                    using (var command = new SqlCommand(string.Empty, connection, transaction) { CommandType = CommandType.StoredProcedure })
                    {
                        var returnParam = new SqlParameter("@Return", SqlDbType.Int, 4, ParameterDirection.ReturnValue, false, 0, 0, "Return", DataRowVersion.Current, 0);
                        command.Parameters.Add(returnParam);
                        var tenantParam = new SqlParameter("@TenantId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "TenantId", DataRowVersion.Current, TenantId);
                        command.Parameters.Add(tenantParam);
                        var propertyIdParam = new SqlParameter("@PropertyId", SqlDbType.Int, 4, ParameterDirection.InputOutput, false, 0, 0, "PropertyId", DataRowVersion.Current, 0);
                        command.Parameters.Add(propertyIdParam);
                        var objectIdParam = new SqlParameter("@ObjectId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "ObjectId", DataRowVersion.Current, 0);
                        command.Parameters.Add(objectIdParam);
                        var sortCodeParam = new SqlParameter("@SortCode", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "SortCode", DataRowVersion.Current, 0);
                        command.Parameters.Add(sortCodeParam);
                        var _createdParam = new SqlParameter("@_created", SqlDbType.DateTime, 8, ParameterDirection.Input, false, 0, 0, "_created", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(_createdParam);
                        var _createdByParam = new SqlParameter("@_createdBy", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "_createdBy", DataRowVersion.Current, userId);
                        command.Parameters.Add(_createdByParam);
                        var _updatedParam = new SqlParameter("@_updated", SqlDbType.DateTime, 8, ParameterDirection.Input, false, 0, 0, "_created", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(_updatedParam);
                        var _updatedByParam = new SqlParameter("@_updatedBy", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "_updatedBy", DataRowVersion.Current, userId);
                        command.Parameters.Add(_updatedByParam);
                        var rowParam = new SqlParameter("@Row", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "Row", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(rowParam);

                        var valueIntParam = new SqlParameter("@Value", SqlDbType.BigInt, 8, ParameterDirection.Input, false, 0, 0, "Value", DataRowVersion.Current, DBNull.Value);
                        //command.Parameters.Add(valueIntParam);
                        var valueFloatParam = new SqlParameter("@Value", SqlDbType.Float, 8, ParameterDirection.Input, false, 0, 0, "Value", DataRowVersion.Current, DBNull.Value);
                        //command.Parameters.Add(valueFloatParam);
                        var valueStringParam = new SqlParameter("@Value", SqlDbType.VarChar, 4096, ParameterDirection.Input, false, 0, 0, "Value", DataRowVersion.Current, DBNull.Value);
                        //command.Parameters.Add(valueStringParam);
                        var valueBigStringParam = new SqlParameter("@Value", SqlDbType.VarChar, int.MaxValue, ParameterDirection.Input, false, 0, 0, "Value", DataRowVersion.Current, DBNull.Value);
                        //command.Parameters.Add(valueBigStringParam);

                        var valueEpsilonParam = new SqlParameter("@ValueEpsilon", SqlDbType.Float, 8, ParameterDirection.Input, false, 0, 0, "ValueEpsilon", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(valueEpsilonParam);
                        var propertyNameParam = new SqlParameter("@PropertyName", SqlDbType.VarChar, 256, ParameterDirection.Input, false, 0, 0, "PropertyName", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(propertyNameParam);
                        var commentParam = new SqlParameter("@Comment", SqlDbType.VarChar, 256, ParameterDirection.Input, false, 0, 0, "Comment", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(commentParam);
                        var sourceObjectIdParam = new SqlParameter("@SourceObjectId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "SourceObjectId", DataRowVersion.Current, DBNull.Value);
                        command.Parameters.Add(sourceObjectIdParam);
                        var deleteOnNullValuesParam = new SqlParameter("@DeleteOnNullValues", SqlDbType.Bit, 1, ParameterDirection.Input, false, 0, 0, "DeleteOnNullValues", DataRowVersion.Current, deleteOnNullValues);
                        command.Parameters.Add(deleteOnNullValuesParam);

                        // synthesis objects
                        foreach (var obj in objectsArray)
                        {
                            int objectId = obj["ObjectId"]?.ToObject<int>() ?? 0;
                            objectIdParam.Value = objectId;
                            sb.AppendLine($"======================== objectId: {objectId} ========================");
                            if (obj["Parameters"] != null) {
                                foreach (var parameter in obj["Parameters"])
                                {
                                    // update/insert a parameter for obj.ObjectId
                                    type = parameter["type"].ToString();
                                    // value = parameter["value"].ToObject(GetTypeByPropertyType(type));
                                    svalue = parameter["value"].ToString();
                                    name = parameter["name"].ToString();
                                    ssortcode = parameter.Contains("sortcode") ? parameter["sortcode"].ToString() : null;
                                    int.TryParse(ssortcode, out sortcode);
                                    value = GetValueByPropertyType(type, svalue);

                                    PropertyValue? matchTemplate = templateProperties.Find(x => (x.PropertyType.ToString() == type && x.PropertyName == name));
                                    if (matchTemplate != null)
                                    {
                                        // TODO
                                        //PropertyValue pvalue = new PropertyValue()
                                        //{
                                        //    PropertyId = 0,
                                        //    PropertyType = (PropertyType)Enum.Parse(typeof(PropertyType), type),
                                        //    PropertyName = name,
                                        //    Value = value,
                                        //    ValueEpsilon = null,
                                        //    SortCode = matchTemplate.SortCode, // sortcode
                                        //    Row = null,
                                        //    Comment = matchTemplate.Comment,
                                        //    SourceObjectId = null
                                        //};


                                        propertyIdParam.Value = 0;
                                        sortCodeParam.Value = matchTemplate.SortCode; // sortcode
                                        propertyNameParam.Value = matchTemplate.PropertyName;
                                        commentParam.Value = matchTemplate.Comment;
                                        if (command.Parameters.Contains(valueIntParam) && matchTemplate.PropertyType != PropertyType.Int)
                                            command.Parameters.Remove(valueIntParam);
                                        if (command.Parameters.Contains(valueFloatParam) && matchTemplate.PropertyType != PropertyType.Float)
                                            command.Parameters.Remove(valueFloatParam);
                                        if (command.Parameters.Contains(valueStringParam) && matchTemplate.PropertyType != PropertyType.String)
                                            command.Parameters.Remove(valueStringParam);
                                        if (command.Parameters.Contains(valueBigStringParam) && matchTemplate.PropertyType != PropertyType.BigString)
                                            command.Parameters.Remove(valueBigStringParam);
                                        switch (matchTemplate.PropertyType)
                                        {
                                            case PropertyType.Int:
                                                valueIntParam.Value = value;
                                                if (!command.Parameters.Contains(valueIntParam))
                                                    command.Parameters.Add(valueIntParam);
                                                break;
                                            case PropertyType.Float:
                                                valueFloatParam.Value = value;
                                                if (!command.Parameters.Contains(valueFloatParam))
                                                    command.Parameters.Add(valueFloatParam);
                                                break;
                                            case PropertyType.String:
                                                valueStringParam.Value = value;
                                                if (!command.Parameters.Contains(valueStringParam))
                                                    command.Parameters.Add(valueStringParam);
                                                break;
                                            case PropertyType.BigString:
                                                valueBigStringParam.Value = value;
                                                if (!command.Parameters.Contains(valueBigStringParam))
                                                    command.Parameters.Add(valueBigStringParam);
                                                break;
                                            default:
                                                throw new Exception($"UpdateSynthesisBatch: unknown matchTemplate.PropertyType=={matchTemplate.PropertyType}");
                                        }
                                        //int propertyId = await Property_UpdateInsert(pvalue, created: DateTime.Now, userId, objectId, deleteOnNullValues, connection);
                                        //transaction.Execute(sql, new { CustomerName = "Mark" });
                                        command.CommandText = $"Property{matchTemplate.PropertyType}_UpdateInsert";
                                        int rv = await command.ExecuteNonQueryAsync();
                                        int pid = (int)propertyIdParam.Value;
                                        if (pid < 0)
                                        {
                                            updated++;
                                        }
                                        else if (pid > 0)
                                        {
                                            inserted++;
                                        }
                                        else
                                        {   //==0
                                            deletedOnNullValues++;
                                        }
                                        sb.AppendLine($"FOUND: {parameter} => \tpropertyId: {pid} [{(pid < 0 ? "updated" : (pid > 0 ? "inserted" : "deletedOnNullValues"))}]");
                                    }
                                    else
                                    {
                                        sb.AppendLine($"NOT FOUND => IGNORED: {parameter}");
                                    }

                                }
                            }
                            // delete all old properties (non-existent any more)                       // await Property_DeleteNonTableBefore(objectId, dt, connection);
                            // sqlProperty_EnlistNonTableBeforeDelete
                            using (var enlistCommand = new SqlCommand(sqlProperty_EnlistNonTableBeforeDelete, connection, transaction) { CommandType = CommandType.Text }) {
                                var _tenantParam = new SqlParameter("@TenantId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "TenantId", DataRowVersion.Current, TenantId);
                                enlistCommand.Parameters.Add(_tenantParam);
                                var _objectIdParam = new SqlParameter("@ObjectId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "ObjectId", DataRowVersion.Current, objectId);
                                enlistCommand.Parameters.Add(_objectIdParam);
                                var beforeParam = new SqlParameter("@before", SqlDbType.DateTime, 8, ParameterDirection.Input, false, 0, 0, "before", DataRowVersion.Current, dt);
                                enlistCommand.Parameters.Add(beforeParam);
                                objectOldToDelete = enlistCommand.ExecuteScalar() as string;
                                sb.AppendLine($"\t\tdeleteCommand, records to delete [objectId={objectId}]:\r\n{objectOldToDelete}");
                            }


                            using (var deleteCommand = new SqlCommand(sqlProperty_DeleteNonTableBefore, connection, transaction) { CommandType = CommandType.Text })
                            {
                                var _tenantParam = new SqlParameter("@TenantId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "TenantId", DataRowVersion.Current, TenantId);
                                deleteCommand.Parameters.Add(_tenantParam);
                                var _objectIdParam = new SqlParameter("@ObjectId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "ObjectId", DataRowVersion.Current, objectId);
                                deleteCommand.Parameters.Add(_objectIdParam);
                                var beforeParam = new SqlParameter("@before", SqlDbType.DateTime, 8, ParameterDirection.Input, false, 0, 0, "before", DataRowVersion.Current, dt);
                                deleteCommand.Parameters.Add(beforeParam);
                                object rowsAffected = deleteCommand.ExecuteScalar();
                                deletedOld += (int)rowsAffected;
                                sb.AppendLine($"\t\tdeleteCommand rowsAffected: {rowsAffected} [objectId={objectId}]");
                            }
                            //var tenantParam = new SqlParameter("@TenantId", SqlDbType.Int, 4, ParameterDirection.Input, false, 0, 0, "TenantId", DataRowVersion.Current, TenantId);
                        }
                    }
                    transaction.Commit();   // commit (if not - rollback on using...)
                }
            }
            sb.AppendLine($"{Environment.NewLine}SUMMARY: inserted: {inserted}, updated: {updated}, deletedOnNullValues: {deletedOnNullValues}, deletedOld: {deletedOld}");
            vr.Warning = sb.ToString();
        }
        catch (Exception ex)
        {
            vr.Code = 500;
            vr.Message = ex.GetType() + ": " + ex.Message;
            vr.Warning = $"type={type}, svalue={svalue}, value={value}, name={name}, ssortcode={ssortcode}, sortcode={sortcode}{Environment.NewLine}{ex.StackTrace}";
        }

        // File.WriteAllText("C:\\!\\!.txt", sb.ToString());
        return vr;
    }


}

