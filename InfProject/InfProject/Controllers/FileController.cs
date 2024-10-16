using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using InfProject.Models;
using InfProject.Utils;
using InfProject.DBContext;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using OfficeOpenXml;
using static WebUtilsLib.DBUtils;
using System.IO;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Dapper;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Text;
using WebUtilsLib;
using TypeValidationLibrary;

namespace InfProject.Controllers;

//[Authorize(Roles = "User,PowerUser,Administrator")]
public class FileController : Controller
{
    private readonly ILogger<FileController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
	private Encoding enc = Encoding.UTF8;

	public FileController(ILogger<FileController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }

    public IActionResult Index() {
        return NotFound();
    }

    /// <summary>
    /// Get File Stream
    /// </summary>
    /// <param name="id">ObjectId FROM ObjectInfo</param>
    /// <returns>file stream for browser</returns>
    //[HttpGet("{id:int}")]
    public async Task<IActionResult> Download([FromRoute]int id)
    {
        try
        {
            var obj = await dataContext.ObjectInfo_Get(id);
            if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
            {
				return this.RedirectToLoginOrAccessDenied(HttpContext);
            }
            string relFileName = obj.ObjectFilePath;
            string extension = Path.GetExtension(relFileName);
            string mime = FileUtils.GetMimeTypeForFileExtension(extension);
            string absFileName = config.MapStorageFile(relFileName);

            if (!System.IO.File.Exists(absFileName))
                return NotFound(); // returns a NotFoundResult with Status404NotFound response.

            Stream stream = System.IO.File.OpenRead(absFileName);

            if (stream == null)
                return NotFound(); // returns a NotFoundResult with Status404NotFound response.

            var fileName = Path.GetFileName(relFileName);
            return File(stream, mime, fileName); // returns a FileStreamResult
        }
        catch (Exception ex)
        {
            logger.LogError($"Download({id}): " + ex.ToStringForLog());
            return NotFound(); // return Forbid();
        }
    }


	/// <summary>
	/// Output CSV as a table
	/// </summary>
	/// <param name="id">ObjectId FROM ObjectInfo</param>
	/// <returns>View with a table</returns>
	public async Task<IActionResult> Csv([FromRoute] int id)
	{
		try
		{
			var obj = await dataContext.ObjectInfo_Get(id);
			if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
			{
            			return this.RedirectToLoginOrAccessDenied(HttpContext);
			}
			string relFileName = obj.ObjectFilePath;
			string extension = Path.GetExtension(relFileName);
			string mime = FileUtils.GetMimeTypeForFileExtension(extension);
			string absFileName = config.MapStorageFile(relFileName);

			if (!System.IO.File.Exists(absFileName))
				return NotFound(); // returns a NotFoundResult with Status404NotFound response.

			// TO DO: CSV to DataTable -> Search Graph
			string csv = System.IO.File.ReadAllText(absFileName, enc);
			bool firstLineContainsHeader = true;
			string delimiter = CSVParser.GuessDelimiter(csv);
			DataTable dt = CSVParser.VB_Parse(csv, delimiter, firstLineContainsHeader);
			return View((dt, id, delimiter, prefix: "/file/download/", csv: csv));
		}
		catch (Exception ex)
		{
			logger.LogError($"Csv({id}): " + ex.ToStringForLog());
			return NotFound(); // return Forbid();
		}
	}

	[HttpPost]
	public async Task<IActionResult> PostCsv() {
		try
		{
			Request.EnableBuffering();  // important, otherwise can't seek input stream
			Stream req = Request.Body;
			if (req.CanSeek)
			{
				req.Seek(0, SeekOrigin.Begin);
			}
			byte[] buffer = new byte[16 * 1024], data;
			using (MemoryStream ms = new MemoryStream())
			{
				int read;
				while ((read = await req.ReadAsync(buffer, 0, buffer.Length)) > 0)
				{
					await ms.WriteAsync(buffer, 0, read);
				}
				data = ms.ToArray();
			}
			string csv = enc.GetString(data);
			bool firstLineContainsHeader = true;
			string delimiter = CSVParser.GuessDelimiter(csv);
			DataTable dt = CSVParser.VB_Parse(csv, delimiter, firstLineContainsHeader);
			return View((dt, delimiter, data, enc));
		}
		catch (Exception ex)
		{
			logger.LogError($"PostCsv(): " + ex.ToStringForLog());
			return NotFound(); // return Forbid();
		}
	}

	/// <summary>
	/// Converts object to DataTable and outputs CSV as a file
	/// </summary>
	/// <param name="id">ObjectId FROM ObjectInfo</param>
	/// <returns>View with a table</returns>
	public async Task<IActionResult> DownloadAsCsv([FromRoute] int id)
	{
		try
		{
			var obj = await dataContext.ObjectInfo_Get(id);
			if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
			{
				return this.RedirectToLoginOrAccessDenied(HttpContext);
			}
			string relFileName = obj.ObjectFilePath;
			string absFileName = config.MapStorageFile(relFileName);

			if (!System.IO.File.Exists(absFileName))
				return NotFound(); // returns a NotFoundResult with Status404NotFound response.

			var type = await dataContext.GetType(obj.TypeId);
			var tableGetter = type.GetTableGetter();
			tableGetter.File = new FileInfo(absFileName);
			var table = tableGetter?.GetTable();

			string str = table.GetCSV(delimiter: "\t");
			return File(enc.GetBytes(str), "text/csv", $"toCsv{id}");
		}
		catch (Exception ex)
		{
			logger.LogError($"DownloadAsCsv({id}): " + ex.ToStringForLog());
			return NotFound(); // return Forbid();
		}
	}


	/// <summary>
	/// Output CSV as a table
	/// </summary>
	/// <param name="id">ObjectId FROM ObjectInfo</param>
	/// <returns>View with a table</returns>
	public async Task<IActionResult> ToCsv([FromRoute] int id)
	{
		try
		{
			var obj = await dataContext.ObjectInfo_Get(id);
			if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
			{
				return this.RedirectToLoginOrAccessDenied(HttpContext);
			}
			string relFileName = obj.ObjectFilePath;
			string absFileName = config.MapStorageFile(relFileName);

			if (!System.IO.File.Exists(absFileName))
				return NotFound(); // returns a NotFoundResult with Status404NotFound response.

            var type = await dataContext.GetType(obj.TypeId);

			var tableGetter = type.GetTableGetter();
			tableGetter.File = new FileInfo(absFileName);
			var table = tableGetter?.GetTable();
            string csv = table.GetCSV();
            return View("Csv", (table.DataTable, id, delimiter: "\t", prefix: "/file/downloadascsv/", csv: csv));
        }
		catch (Exception ex)
		{
			logger.LogError($"ToCsv({id}): " + ex.ToStringForLog());
			return NotFound(); // return Forbid();
		}
	}

	/// <summary>
	/// POST request to External resource for visualization
	/// </summary>
	/// <returns></returns>
	public async Task<IActionResult> PostExternalStatic()
	{
		return View();
	}


        /// <summary>
        /// POST request to External resource for visualization
        /// </summary>
        /// <param name="id">object Id</param>
        /// <returns></returns>
    public async Task<IActionResult> PostExternal([FromRoute] int id)
    {
        try
        {
            ObjectInfo obj = await dataContext.ObjectInfo_Get(id);
            if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
            {
		return this.RedirectToLoginOrAccessDenied(HttpContext);
            }
            string relFileName = obj.ObjectFilePath;
            string absFileName = config.MapStorageFile(relFileName);

            if (!System.IO.File.Exists(absFileName))
                return NotFound(); // returns a NotFoundResult with Status404NotFound response.

            return View(obj);
        }
        catch (Exception ex)
        {
            logger.LogError($"PostExternal({id}): " + ex.ToStringForLog());
            return BadRequest();
        }
    }

}