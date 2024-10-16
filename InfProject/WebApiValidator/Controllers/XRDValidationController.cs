using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Net.Mime;
using TypeValidationLibrary;

namespace WebApiValidator.Controllers;

//[ApiController]
[NonController]
[Route("xrd/validation")]
public class XRDValidationController : ControllerBase
{
    private readonly ILogger<XRDValidationController> logger;

    public XRDValidationController(ILogger<XRDValidationController> logger)
    {
        this.logger = logger;
    }


    /// <summary>
    /// TO BE DONE: Validation of incoming stream from POST body
    /// https://localhost:7254/XRD/Validation/body
    /// </summary>
    /// <param name="array">binary POST data</param>
    /// <returns>TypeValidatorResult</returns>
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

        // req
        throw new NotImplementedException();
    }




    /// <summary>
    /// TO BE DONE: Validation of incoming file from form sent with multipart/form-data
    /// https://localhost:7254/XRD/Validation/File
    /// </summary>
    /// <param name="file">binary file data</param>
    /// <returns>TypeValidatorResult</returns>
    [HttpPost("file")]
    [Produces(typeof(TypeValidatorResult))]
    public TypeValidatorResult File(IFormFile file)
    {
        // file.OpenReadStream()
        throw new NotImplementedException();
    }
}