using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;

namespace InfProject.Areas.VroApi.Controllers
{
    [Area("VroApi")]
    [ApiVersion(2.0)]
    [ApiController]
    //[Route("vroapi/v{version:apiVersion:int}")]
    //[Route("vroapi/v{v:apiVersion}")]
    [Route("vroapi/v2")]
    public class VroApi2Controller : ControllerBase
    {
        public string Get() => "Not implemented (stub for future versions)";
    }
}
