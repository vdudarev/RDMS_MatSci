using Microsoft.AspNetCore.Http;
using System.Data;
using System.Linq;
using System.Security.Claims;
using System.Xml.Linq;

namespace WebUtilsLib;

public static partial class UserUtils
{
    public static string GetText(string role)
    {
        switch (role)
        {
            case "User": return "Read-only access to protected information";
            case "PowerUser": return "Read-write access to protected information";
            case "Administrator": return "User access control list";
            default: return string.Empty;
        }
    }

    public static int GetUserId(this HttpContext context) {
        int.TryParse(context.User.FindFirstValue(ClaimTypes.NameIdentifier), out int userId);
        return userId;
    }

    /// <summary>
    /// Main function: Get User Security Context
    /// </summary>
    /// <param name="context">HttpContext</param>
    /// <returns>UserContext</returns>
    public static UserContext GetUserContext(this HttpContext context) {
        int userId = GetUserId(context);
        AccessControl access = AccessControl.Public;
        bool isAdmin = context.User.IsInRole(UserGroups.Administrator);
        bool userCanAdd = isAdmin;
        if (isAdmin)
        {
            access = AccessControl.None;
        }
        else {
            userCanAdd = context.User.IsInRole(UserGroups.PowerUser);
            if (context.User.IsInRole(UserGroups.User) || userCanAdd)
            {
                access = context.User.HasNdaAccess() ? AccessControl.ProtectedNDA : AccessControl.Protected;
            }
        }
        return new UserContext(userId, isAdmin, userCanAdd, access);
    }

    public static AccessControlFilter GetAccessControlFilter(this HttpContext context)
    {
        UserContext ctx = context.GetUserContext();
        return new AccessControlFilter(ctx.access, ctx.userId);
    }

    /// <summary>
    /// for WebCompact (get value for AccessControl depending on NDA claim | Admininstrator role)
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    public static int GetWCAccessControlInt(this HttpContext context)
        => context.User.HasNdaAccess() ? 1 : 0;

    public static List<string> GetUserRoles(this HttpContext context)
    {
        List<string> roles = (context.User.Identity as ClaimsIdentity)?.Claims
                    .Where(c => c.Type == ClaimTypes.Role)
                    .Select(c => c.Value).ToList() ?? new List<string>();
        return roles;
    }

    /// <summary>
    /// Get user Roles as a IEnumerable<string>
    /// </summary>
    /// <param name="user">HttpContext.User</param>
    /// <returns>IEnumerable<string></returns>
    public static IEnumerable<string> GetRoles(this ClaimsPrincipal user) {
        return ((ClaimsIdentity)user.Identity).Claims
            .Where(c => c.Type == ClaimTypes.Role)
            .Select(c => c.Value);
    }

    public static bool IsInRole(this ClaimsPrincipal user, UserGroups singleRole) 
        => user.IsInRole(singleRole.ToString());

    public static bool IsSpecifiedClaimActive(this ClaimsPrincipal user, string name)
    {
        string readClaim = user.FindFirstValue(name);    // Read _SputterRate.read claim
        int.TryParse(readClaim, out int readResult);
        return readResult != 0;
    }


    public static bool IsReadDenied(this HttpContext context, AccessControl objectAccess, int object_createdBy) {
        if (objectAccess == AccessControl.Public)   // open access
            return false;
        int userId;
        int.TryParse(context.User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
        List<string> roles = context.GetUserRoles();
        if (objectAccess == AccessControl.Protected) {  // any group member (User, PowerUser, Administrator) can read
            if (context.User.IsInRole(UserGroups.Administrator)
                || context.User.IsInRole(UserGroups.PowerUser)
                || context.User.IsInRole(UserGroups.User))
                return false;
        }
        else if (objectAccess == AccessControl.ProtectedNDA) { // only Administrator OR created the record user OR any group member (User, PowerUser, Administrator) with "NDA" claim
            if (userId > 0 && userId == object_createdBy || context.User.IsInRole(UserGroups.Administrator) || context.User.HasNdaAccess())
                return false;
        } else if (objectAccess == AccessControl.Private) { // only Administrator OR created the record user
            if (userId>0 && userId==object_createdBy || context.User.IsInRole(UserGroups.Administrator))
                return false;
        }
        return true;    // read denied
    }

    /// <summary>
    /// Checks whether current user from context has write permissions
    /// </summary>
    /// <param name="context">HttpContext to get currently logged on user</param>
    /// <param name="objectAccess">AccessControl of the object to edit</param>
    /// <param name="object_createdBy">_createdBy of the object to edit</param>
    /// <returns>true - WRITE DENIED; false - CAN WRITE</returns>
    public static bool IsWriteDenied(this HttpContext context, AccessControl objectAccess, int object_createdBy)
    {
        if (context.User.IsInRole(UserGroups.Administrator))    // Administrator can write anything
            return false;
        int userId;
        int.TryParse(context.User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
        if (context.User.IsInRole(UserGroups.PowerUser) && userId>0 && userId==object_createdBy)    // PowerUser can write only his/her objects
            return false;
        return true;    // write denied
    }


    public static bool HasDownloadSputterRatePermission(this ClaimsPrincipal user)
        => HasClaim(user, "_SputterRate.read");

    public static bool HasUploadSputterRatePermission(this ClaimsPrincipal user) 
        => HasClaim(user, "_SputterRate.write");

    public static bool HasNdaAccess(this ClaimsPrincipal user)
        => HasClaim(user, "NDA") || user.IsInRole(UserGroups.Administrator);

    public static bool HasClaim(this ClaimsPrincipal user, string claimName)
    {
        bool isAdmin = user.IsInRole(UserGroups.Administrator);
        if (isAdmin)
            return true;
        bool claimValue = user.IsSpecifiedClaimActive(claimName);
        return claimValue;
    }

}
