using InfProject.DBContext;
using System.IO.Pipelines;
using TypeValidationLibrary;
using InfProject.Models;
using WebUtilsLib;
using InfProject.Controllers;

namespace InfProject.Utils
{
    public class ObjectValidationResult
    {
        public int objectId { get; set; }
        public TypeValidatorResult result { get; set; }
    }

    public class ObjectReloadResult : ObjectValidationResult
    {
        public TypeValidatorResult reloadResult { get; set; }
    }

    public class ValidationAndUploadDatabaseValues
    {

        public async static Task<(TypeValidatorResult result, TypeValidatorResult reloadResult)> 
            UploadDatabaseValues(HttpContext HttpContext, DataContext dataContext, IConfiguration config, int userId, int objectId) {
            string absFileName;
            Models.TypeInfo type = null;
            TypeValidatorResult vr;
            TypeValidatorResult reloadResult;
            int rowsAffected;

            ObjectInfo obj = await dataContext.ObjectInfo_Get(objectId);
            DBUtils.DatabaseValues data = new DBUtils.DatabaseValues();
            if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy) && !HttpContext.User.HasClaim(AdminObjectController.ClaimNameToShowAllObjects, "1"))
            {
                reloadResult = vr = new TypeValidatorResult(403, "access denied");
            }
            else
            {
                if (type == null || type.TypeId != obj.TypeId)
                {
                    type = await dataContext.GetType(obj.TypeId);
                }
                if (string.IsNullOrEmpty(obj.ObjectFilePath))
                {
                    if (type.FileRequired)
                    {
                        vr = new TypeValidatorResult() { Code = 404, Message = $"required file is not defined [ObjectFilePath is empty]" };
                        reloadResult = new TypeValidatorResult(400, "no mandatory file = no action");
                    }
                    else
                    {
                        vr = new TypeValidatorResult(); // ok
                        reloadResult = new TypeValidatorResult(0, string.Empty, "no optional file = no action");
                    }
                }
                else
                {
                    absFileName = config.MapStorageFile(obj.ObjectFilePath);
                    vr = new TypeValidatorResult(-1, "init");
                    data = new DBUtils.DatabaseValues();
                    try
                    {
                        var context = await dataContext.ExtractContext(obj);
                        (vr, data) = type.ValidateFileAndGetDataValues(absFileName, context);    // verification And GetData
                    }
                    catch (Exception ex)
                    {
                        vr = new TypeValidatorResult(500, "ValidateFileAndGetDataValues failed: " + ex.Message);
                    }
                    if (vr) // ok => write to DB
                    {
                        if (HttpContext.IsWriteDenied(obj.AccessControl, (int)obj._createdBy) && !HttpContext.User.HasClaim(AdminObjectController.ClaimNameToUploadDatabaseValuesForAllObjects, "1"))  // has write access?
                        {
                            reloadResult = new TypeValidatorResult(403, "access denied");
                        }
                        else
                        {
                            // SAVE DATA from file to Object (Properties, etc)
                            try
                            {
                                DateTime dt = DateTime.Now.AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)
                                rowsAffected = await dataContext.Object_UpdateInsertDatabaseValues(data, dt, userId, obj);
                                reloadResult = new TypeValidatorResult();
                            }
                            catch (Exception ex)
                            {
                                reloadResult = new TypeValidatorResult(500, ex.Message);
                            }
                        }
                    }
                    else
                    { // fail
                        reloadResult = new TypeValidatorResult(400, "validation failed = no action");
                    }
                }
            }
            return (vr, reloadResult);
        }

    }
}
