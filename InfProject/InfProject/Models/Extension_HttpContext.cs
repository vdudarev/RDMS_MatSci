using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using InfProject.Utils;
using WebUtilsLib;
using System.Security.Claims;
using InfProject.DTO;
using System.Configuration;
using InfProject.DBContext;

namespace InfProject.Models;

public static class Extension_HttpContext
{
    /// <summary>
    /// gets old object from database before update and checks whether write is possible with respect to current user context
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>ObjectInfo</returns>
    /// <exception cref="UnauthorizedAccessException"></exception>
    public static async Task<ObjectInfo> GetObjectAndCheckWriteAccess(this HttpContext context, DataContext dataContext, int objectId)
    {
        ObjectInfo objOld = objectId != 0 ? await dataContext.ObjectInfo_Get(objectId) : new ObjectInfo();  // read old
        if (objOld.ObjectId == 0)
        { // add
            if (!context.User.IsInRole(UserGroups.PowerUser) && !context.User.IsInRole(UserGroups.Administrator))
                throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
        }
        else if (!context.User.IsInRole(UserGroups.Administrator))
        { // update and not admin!
            if (!context.User.IsInRole(UserGroups.PowerUser))
                throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
            if (context.IsWriteDenied(objOld.AccessControl, (int)objOld._createdBy))
                throw new UnauthorizedAccessException($"User can not update this item [ObjectId={objectId}]");
        }
        return objOld;
    }


    /// <summary>
    /// gets old ObjectLinkRubric from database before update and checks whether write is possible with respect to current user context
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>ObjectInfo</returns>
    /// <exception cref="UnauthorizedAccessException"></exception>
    public static async Task<ObjectLinkRubric> GetObjectLinkRubricAndCheckWriteAccess(this HttpContext context, DataContext dataContext, int objectLinkRubricId)
    {
        ObjectLinkRubric objOld = objectLinkRubricId != 0 ? await dataContext.GetObjectLinkRubricById(objectLinkRubricId) : new ObjectLinkRubric();  // read old
        if (objOld.ObjectLinkRubricId == 0)
        {
            throw new UnauthorizedAccessException("ObjectLinkRubricId");
        }
        else if (!context.User.IsInRole(UserGroups.Administrator))
        { // update and not admin!
            if (!context.User.IsInRole(UserGroups.PowerUser))
                throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
            if (context.IsWriteDenied(AccessControl.Public, (int)objOld._createdBy))
                throw new UnauthorizedAccessException("User can not update this item");
        }
        return objOld;
    }
}
