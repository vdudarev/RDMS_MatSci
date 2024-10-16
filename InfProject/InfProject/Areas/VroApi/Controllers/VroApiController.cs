using Asp.Versioning;
using IdentityManagerUI.Models;
using InfProject.Controllers;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Data;
using System.Net.Mime;
using System.Security.Claims;
using TypeValidationLibrary;
using WebUtilsLib;

namespace InfProject.Areas.VroApi.Controllers
{
    [Area("VroApi")]
    [ApiVersion(1.0)]
    [ApiController]
    //[Route("vroapi/v{version:apiVersion:int}/helloworld")]
    //[Route("vroapi/v{v:apiVersion}")]
    [Route("vroapi/v1")]
    public class VroApiController : ControllerBase
    {
        // as a suggestion to generate values: https://www.uuidgenerator.net/version4
        // Claim name to use Vro Api and Api key name
        public const string ApiKeyName = "VroApi";  // ClaimType в AspNetUserClaims
        public string Version => ((ApiVersionAttribute)Attribute.GetCustomAttribute(typeof(VroApiController), typeof(ApiVersionAttribute))).Versions[0].ToString();
        public string Get() => $"VRO (View Read Only) API on MatInf database. Version {Version}";


        private readonly ILogger<VroApiController> logger;
        private readonly IConfiguration config;
        private readonly DataContext dataContext;
        private readonly IHttpContextAccessor httpContextAccessor;

        public VroApiController(ILogger<VroApiController> logger, IConfiguration config, DataContext dataContext, IHttpContextAccessor httpContextAccessor)
        {
            this.logger = logger;
            this.config = config;
            this.dataContext = dataContext;
            this.httpContextAccessor = httpContextAccessor;
        }

        private string connectionString;
        private string databaseName;
        private string ip;
        private int userId;

        /// <summary>
        /// 1) initialize appropriate database name and connection string to use
        /// 2) Check API Security
        /// </summary>
        /// <returns>true - ok; false - no access</returns>
        private async Task<bool> InitVro()
        {
            var sourceConnectionString = dataContext.GetConnectionString(config, httpContextAccessor);
            (connectionString, databaseName) = VroUiController.GetVroConnectionString(sourceConnectionString, config);
            string apiKeyValue = Request.Headers[ApiKeyName];
            ip = Request.HttpContext.Connection.RemoteIpAddress.ToString();
            userId = await dataContext.GetActiveUserIdWithClaimValue(ApiKeyName, apiKeyValue);
            if (userId == 0) {
                logger.LogError("Authorisation failed for user provided claimValue {apiKeyValue} [ip={ip}]", apiKeyValue, ip);
            }
            return userId != 0;
        }

        private async Task<(DataTable dt, string error)> ExecWithAccessCheck(string sql, string connectionString)
        {
            DataTable dt = null;
            string error = null;
            try
            {
                //if (!User.HasClaim(ClaimNameToUseVroApi))
                //{
                //    throw new Exception("You don't have access to this functionality");
                //}
                dt = await DataContext.GetTable_ExecDevelopment(sql, connectionString);
            }
            catch (Exception ex)
            {
                error = ex.GetType() + " " + ex.Message;
            }
            return (dt, error);
        }

        
        /// <summary>
        /// Executes SQL-query (vro schema) to return data
        /// </summary>
        /// <param name="sql">SQL query on VRO (View Read Only) schema</param>
        /// <returns>JsonResult - table result</returns>
        [HttpPost("execute")]
        //[Consumes(MediaTypeNames.Application.Octet)] // application/octet-stream
        [Produces(typeof(JsonResult))]
        public async Task<ActionResult> Execute([FromForm] string sql)
        {
            if (! await InitVro()) {  // get connectionString and database Name
                return Unauthorized();
            }
            logger.LogInformation("Execute {sql} [userId={userId}, ip={ip}]", sql, userId, ip);
            (DataTable dt, string error) = await ExecWithAccessCheck(sql, connectionString);
            if (!string.IsNullOrEmpty(error)) {
                return BadRequest(error);
            }
            string json = DBUtils.ConvertDataTableToJson(dt/*, Newtonsoft.Json.Formatting.Indented*/);
            return Content(json, "application/json");
        }



        /// <summary>
        /// Get File Stream
        /// </summary>
        /// <param name="id">ObjectId FROM ObjectInfo</param>
        /// <returns>file stream for browser</returns>
        [HttpGet("download")]
        public async Task<IActionResult> Download([FromQuery] int id)
        {
            if (!await InitVro()) {  // get connectionString and database Name
                return Unauthorized();
            }
            try
            {
                var obj = await dataContext.ObjectInfo_Get(id);

                string relFileName = obj?.ObjectFilePath;
                if (string.IsNullOrEmpty(relFileName)) {
                    return NotFound(); // returns a NotFoundResult with Status404NotFound response.
                }

                string extension = Path.GetExtension(relFileName);
                string mime = FileUtils.GetMimeTypeForFileExtension(extension);
                string absFileName = config.MapStorageFile(relFileName);

                if (!System.IO.File.Exists(absFileName)) {
                    return NotFound(); // returns a NotFoundResult with Status404NotFound response.
                }

                logger.LogInformation("Download id={id}, {relFileName} [userId={userId}, ip={ip}]", id, relFileName, userId, ip);
                Stream stream = System.IO.File.OpenRead(absFileName);

                //if (stream == null)
                //    return NotFound(); // returns a NotFoundResult with Status404NotFound response.

                var fileName = Path.GetFileName(relFileName);
                return File(stream, mime, fileName); // returns a FileStreamResult
            }
            catch (Exception ex)
            {
                logger.LogError($"VroApi Download({id}): " + ex.ToStringForLog());
                return NotFound(); // return Forbid();
            }
        }

    }
}
