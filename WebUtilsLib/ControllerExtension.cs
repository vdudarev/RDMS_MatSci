using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace WebUtilsLib;

public static class ControllerExtension
{
    /// <summary>
    /// Provides fancy 403 (with authorization attempt)
    /// </summary>
    /// <param name="controller"></param>
    /// <param name="httpContext"></param>
    /// <returns></returns>
    public static IActionResult RedirectToLoginOrAccessDenied(this Microsoft.AspNetCore.Mvc.Controller controller, Microsoft.AspNetCore.Http.HttpContext httpContext)
    {
        if (!httpContext.User.Identity.IsAuthenticated)
        {
            // User is not authenticated, redirect to login page with a returnUrl parameter
            string returnUrl = httpContext.Request.Path + httpContext.Request.QueryString;
            return new RedirectToActionResult("Login", "Account", new { area = "identity", returnUrl });
        }
        else // bye-bye!
        {
            return controller.StatusCode(StatusCodes.Status403Forbidden, "access denied"); // show dissappointing "access denied"
        }
    }
}
