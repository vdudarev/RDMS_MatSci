using Azure.Core;
using Azure.Core.GeoJson;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Data;
using System.Diagnostics.Metrics;
using System.Net;
using System.Reflection;
using System.Runtime.InteropServices.JavaScript;
using System.Security.Claims;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using TypeValidationLibrary;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Authorize]
public class HandoverController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<HandoverController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;
    private readonly IEmailSender mailSender;

    public HandoverController(IValidator<ObjectInfo> validator, ILogger<HandoverController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine, IEmailSender mailSender)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
        this.mailSender = mailSender;
    }

    /// <summary>
    /// select TYPE to edit
    /// </summary>
    /// <returns></returns>
    public async Task<IActionResult> Index() {
        UserContext userCtx = UserUtils.GetUserContext(HttpContext);
        List<HandoverSample> current = await dataContext.GetCurrentSamplesForUserAccordingToHandovers(userCtx.userId);
        List<HandoverSample> incoming = await dataContext.GetHandoverSamplesForUser(userCtx.userId, Handover.HandoverType.Incoming);
        List<HandoverSample> outcoming = await dataContext.GetHandoverSamplesForUser(userCtx.userId, Handover.HandoverType.Outcoming);
        return View((userCtx, current, incoming, outcoming));
    }


    #region HandoverInObject

    /// <summary>
    /// Add Handover event
    /// </summary>
    /// <param name="SampleObjectId">ObjectId (Sample to handover)</param>
    /// <param name="DestinationUserId">Recipient</param>
    /// <param name="ObjectDescription">Sender's comment for the recipient</param>
    /// <param name="Amount">Amount - optional</param>
    /// <param name="MeasurementUnit">Measurement Unit - optional</param>
    /// <returns>IActionResult</returns>
    [HttpPost]
    public async Task<IActionResult> AddHandover(int SampleObjectId, int DestinationUserId, string ObjectDescription, double Amount, string MeasurementUnit)
    {
        string returl = WebUtility.UrlDecode(Request.Form["returl"]);
        try {
            var userId = HttpContext.GetUserId();
            ObjectInfo sample = await dataContext.ObjectInfo_Get(SampleObjectId);
            WebAppUser senderUser = await dataContext.GetUser(userId);
            WebAppUser destinationUser = await dataContext.GetUser(DestinationUserId);
            Handover handover = await dataContext.AddHandoverForObject(senderUser, sample, destinationUser, ObjectDescription, Amount, MeasurementUnit);
            if (handover != null && handover.ObjectId != 0)
            {     // send e-Mail regarding handover event
                MailHelper mail = new MailHelper(mailSender, HttpContext);
                await mail.SendHandoverMail(handover, sample, senderUser, destinationUser);
            }
            TempData["Suc"] = "Handover event creation successful";
            returl = $"/object/{sample?.ObjectNameUrl}";
            logger.LogInformation($"Handover event creation successful [HandoverId={handover.ObjectId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error adding handover event({ex.GetType()}): {ex.Message}";
            logger.LogError($"Error AddHandover {ex.ToStringForLog()} [SampleObjectId={SampleObjectId}, DestinationUserId={DestinationUserId}]");
        }
        return Redirect(returl);
    }



    /// <summary>
    /// Confirm (complete) Handover event
    /// </summary>
    /// <param name="SampleObjectId">ObjectId (Sample to handover)</param>
    /// <param name="HandoverObjectId">ObjectId for Handover event</param>
    /// <param name="DestinationComments">Recipient's comment for sender</param>
    /// <returns>IActionResult</returns>
    [HttpPost]
    public async Task<IActionResult> ConfirmHandover(int SampleObjectId, int HandoverObjectId, string DestinationComments)
    {
        string returl = WebUtility.UrlDecode(Request.Form["returl"]);
        try
        {
            Handover handover = await dataContext.GetHandover(HandoverObjectId);
            var userCtx = HttpContext.GetUserContext();
            if (handover.DestinationUserId != userCtx.userId && !userCtx.isAdmin) {
                throw new Exception($"Current user can't confirm the handover [handover.DestinationUserId={handover.DestinationUserId}, userId={userCtx.userId}, isAdmin={userCtx.isAdmin}]");
            }

            ObjectInfo sample = await dataContext.ObjectInfo_Get(SampleObjectId);
            WebAppUser senderUser = await dataContext.GetUser(userCtx.userId);
            WebAppUser destinationUser = await dataContext.GetUser(handover.DestinationUserId);

            var handoverRet = await dataContext.ConfirmHandover(userCtx.userId, SampleObjectId, HandoverObjectId, DestinationComments);
            if (handoverRet != null)
            {     // send e-Mail regarding handover event
                MailHelper mail = new MailHelper(mailSender, HttpContext);
                await mail.SendHandoverMail(handoverRet, sample, senderUser, destinationUser);
            }
            TempData["Suc"] = "Handover event confirmation successful";
            returl = $"/object/{sample?.ObjectNameUrl}";
            logger.LogInformation($"Handover event confirmation successful [handoverId={handoverRet.ObjectId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error confirming handover event({ex.GetType()}): {ex.Message}";
            logger.LogError($"Error ConfirmHandover {ex.ToStringForLog()} [SampleObjectId={SampleObjectId}, HandoverObjectId={HandoverObjectId}]");
        }
        return Redirect(returl);
    }
    #endregion // HandoverInObject
}