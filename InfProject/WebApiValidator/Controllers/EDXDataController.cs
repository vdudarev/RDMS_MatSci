using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.IO;
using System.Net.Mime;
using TypeValidationLibrary;
using static WebUtilsLib.DBUtils;

namespace WebApiValidator.Controllers;

/// <summary>
/// Controller to validate EDX documents
/// </summary>
[ApiController]
[Route("edx/data")]
public class EDXDataController : ControllerBase
{
    private readonly ILogger<EDXDataController> logger;

    public EDXDataController(ILogger<EDXDataController> logger)
    {
        this.logger = logger;
    }

    #region CoordinatesResult

    ///// <summary>
    ///// Validation of incoming stream to get CoordinatesResult (post call to /EDX/data/ContainsCoordinatesBody)
    ///// </summary>
    ///// <param name="array">binary request body (POST)</param>
    ///// <returns>CoordinatesResult, specifying coordinates</returns>
    //[HttpPost("containscoordinatesbody")]
    //[Consumes(MediaTypeNames.Application.Octet)] // application/octet-stream
    //[Produces(typeof(CoordinatesResult))]
    //public CoordinatesResult ContainsCoordinatesBody([FromBody] byte[] array) {
    //    Request.EnableBuffering();  // important, otherwise can't seek input stream
    //    Stream request = Request.Body;
    //    if (request.CanSeek)
    //    {
    //        // Reset the position to zero to read from the beginning.
    //        request.Seek(0, System.IO.SeekOrigin.Begin);
    //    }

    //    TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
    //    TypeValidatorResult validationResult = v.ValidateStream(request);
    //    if (validationResult) {
    //        Table table = v.GetTable();
    //        return table.Coordinates;
    //    }
    //    else
    //        throw new ArgumentException(validationResult.ToString());
    //}



    ///// <summary>
    ///// Validation of incoming file from form sent with multipart/form-data content-type to get CoordinatesResult (post call to /EDX/data/ContainsCoordinatesFile)
    ///// </summary>
    ///// <param name="file">file to verify</param>
    ///// <returns>CoordinatesResult, specifying coordinates</returns>
    //[HttpPost("containscoordinatesfile")]
    //[Produces(typeof(CoordinatesResult))]
    //public CoordinatesResult ContainsCoordinatesFile(IFormFile file)
    //{
    //    TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
    //    Stream stream = file.OpenReadStream();
    //    TypeValidatorResult validationResult = v.ValidateStream(stream);
    //    if (validationResult) {
    //        Table table = v.GetTable();
    //        return table.Coordinates;
    //    }
    //    else
    //        throw new ArgumentException(validationResult.ToString());
    //}

    #endregion // CoordinatesResult



    #region DataTable

    /// <summary>
    /// Incoming stream processing to get DataTable (post call to /EDX/data/DataTableBody)
    /// </summary>
    /// <param name="array">binary request body (POST)</param>
    /// <returns>CoordinatesResult, specifying coordinates</returns>
    [HttpPost("tablebody")]
    [Consumes(MediaTypeNames.Application.Octet)] // application/octet-stream
    [Produces(typeof(Table))]
    public Table TableBody([FromBody] byte[] array)
    {
        Request.EnableBuffering();  // important, otherwise can't seek input stream
        Stream request = Request.Body;
        if (request.CanSeek)
        {
            // Reset the position to zero to read from the beginning.
            request.Seek(0, System.IO.SeekOrigin.Begin);
        }

        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        TypeValidatorResult validationResult = v.ValidateStream(request);
        if (validationResult) {
            Table table = v.GetTable();
            return table;
        }
        else
            throw new ArgumentException(validationResult.ToString());
    }



    /// <summary>
    /// Incoming file processing from form sent with multipart/form-data content-type to get DataTable (post call to /EDX/data/DataTableFile)
    /// </summary>
    /// <param name="file">file to verify</param>
    /// <returns>CoordinatesResult, specifying coordinates</returns>
    [ApiExplorerSettings(IgnoreApi = true)]
    [NonAction]
    [HttpPost("tablefile")]
    [Produces(typeof(Table))]
    public Table TableFile(IFormFile file)
    {
        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        Stream stream = file.OpenReadStream();
        TypeValidatorResult validationResult = v.ValidateStream(stream);
        if (validationResult) {
            Table table = v.GetTable();
            return table;
        }
        else
            throw new ArgumentException(validationResult.ToString());
    }

    #endregion // DataTable



    #region DatabaseValues

    /// <summary>
    /// Incoming stream processing to get DataTable (post call to /EDX/data/DatabaseValuesBody)
    /// </summary>
    /// <param name="array">binary request body (POST)</param>
    /// <returns>CoordinatesResult, specifying coordinates</returns>
    [HttpPost("databasevaluesbody")]
    [Consumes(MediaTypeNames.Application.Octet)] // application/octet-stream
    [Produces(typeof(DatabaseValues))]
    public DatabaseValues DatabaseValuesBody([FromBody] byte[] array)
    {
        Request.EnableBuffering();  // important, otherwise can't seek input stream
        Stream req = Request.Body;
        if (req.CanSeek)
        {
            // Reset the position to zero to read from the beginning.
            req.Seek(0, System.IO.SeekOrigin.Begin);
        }

        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        TypeValidatorResult validationResult = v.ValidateStream(req);
        if (validationResult)
            return v.GetDatabaseValues();
        else
            throw new ArgumentException(validationResult.ToString());
    }



    /// <summary>
    /// Incoming file processing from form sent with multipart/form-data content-type to get DataTable (post call to /EDX/data/DatabaseValuesFile)
    /// </summary>
    /// <param name="file">file to verify</param>
    /// <returns>CoordinatesResult, specifying coordinates</returns>
    [ApiExplorerSettings(IgnoreApi = true)]
    [NonAction]
    [HttpPost("databasevaluesfile")]
    [Produces(typeof(DatabaseValues))]
    public DatabaseValues DatabaseValuesFile(IFormFile file)
    {
        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        var validationResult = v.ValidateStream(file.OpenReadStream());
        if (validationResult)
            return v.GetDatabaseValues();
        else
            throw new ArgumentException(validationResult.ToString());
    }

    #endregion // DatabaseValues
}