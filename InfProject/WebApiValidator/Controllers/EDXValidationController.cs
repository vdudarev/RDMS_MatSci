using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Net.Mime;
using TypeValidationLibrary;

namespace WebApiValidator.Controllers;

/// <summary>
/// Controller to validate EDX documents
/// </summary>
[ApiController]
[Route("edx/validation")]
public class EDXValidationController : ControllerBase
{
    private readonly ILogger<EDXValidationController> logger;

    public EDXValidationController(ILogger<EDXValidationController> logger)
    {
        this.logger = logger;
    }


    /// <summary>
    /// Validation of incoming stream from POST body (post call to /EDX/Validation/body)
    /// </summary>
    /// <param name="array">binary request body (POST)</param>
    /// <returns>TypeValidatorResult, specifying validation success</returns>
    [HttpPost("body")]
    [Consumes(MediaTypeNames.Application.Octet)] // application/octet-stream
    [Produces(typeof(TypeValidatorResult))]
    public TypeValidatorResult Body([FromBody] byte[] array) {
        Request.EnableBuffering();  // important, otherwise can't seek input stream
        Stream req = Request.Body;
        if (req.CanSeek)
        {
            // Reset the position to zero to read from the beginning.
            req.Seek(0, System.IO.SeekOrigin.Begin);
        }

        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        TypeValidatorResult vr = v.ValidateStream(req);
        return vr;
    }




    /// <summary>
    /// Validation of incoming file from form sent with multipart/form-data content-type (post call to /EDX/Validation/file)
    /// </summary>
    /// <param name="file">file to verify</param>
    /// <returns>TypeValidatorResult, specifying validation success</returns>
    [ApiExplorerSettings(IgnoreApi = true)]
    [NonAction]
    [HttpPost("file")]
    [Produces(typeof(TypeValidatorResult))]
    public TypeValidatorResult File(IFormFile file)
    {
        TypeValidator_EDX_CSV v = new TypeValidator_EDX_CSV();
        TypeValidatorResult vr = v.ValidateStream(file.OpenReadStream());
        return vr;
    }

}