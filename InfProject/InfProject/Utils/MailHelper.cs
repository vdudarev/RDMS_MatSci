using Azure.Core;
using InfProject.Models;
using Microsoft.AspNetCore.Identity.UI.Services;

namespace InfProject.Utils
{
    public class MailHelper
    {
        private IEmailSender mailSender;
        private HttpContext httpContext;
        public MailHelper(IEmailSender mailSender, HttpContext httpContext) {
            this.mailSender = mailSender;
            this.httpContext = httpContext;
        }

        public string Host => httpContext.Request.Host.ToString();
        public string URL => $"http{(httpContext.Request.IsHttps ? "s" : string.Empty)}://{Host}";
        public string Footer => $"<br /><br /><a href=\"{URL}\">{Host}</a> automatic notification service";

        /// <summary>
        /// send e-Mail regarding handover event
        /// </summary>
        /// <param name="handover">handover event object</param>
        /// <param name="sample">sample</param>
        /// <param name="senderUser">sender</param>
        /// <param name="destinationUser">target user</param>
        /// <returns></returns>
        public async Task SendHandoverMail(Handover handover, ObjectInfo sample, WebAppUser senderUser, WebAppUser destinationUser) {
            string htmlMessage;
            if (handover.DestinationConfirmed.HasValue) {   // STEP 2: confirmation (on sample receivement)
                htmlMessage = $@"<p>Dear {senderUser.Name},<br /><br />
<a href=""mailto:{destinationUser.Email}"">{destinationUser.Name}{(string.IsNullOrEmpty(destinationUser.Project) ? string.Empty : $" {destinationUser.Project}")}</a> confirmed your handover receivement: {handover.ObjectName}<br />
It was done on {handover.DestinationConfirmed} with the folliwing comment: <i>{handover.DestinationComments}</i>.
{Footer}
</p>";
                // send letter to Destination User;
                await mailSender.SendEmailAsync(senderUser.Email, subject: $"Handover confirmed: {handover.ObjectName}", htmlMessage: htmlMessage);
            }
            else { // STEP 1: initial event spawned
                htmlMessage = $@"<p>Dear {destinationUser.Name},<br /><br />
<a href=""mailto:{senderUser.Email}"">{senderUser.Name}{(string.IsNullOrEmpty(senderUser.Project) ? string.Empty : $" {senderUser.Project}")}</a> registered a handover event for you: {handover.ObjectName}<br />
{(handover.Amount>0 ? $"Amount: <i>{handover.Amount} {handover.MeasurementUnit}</i>.<br />" : string.Empty)}
Comment: <i>{(string.IsNullOrEmpty(handover.ObjectDescription) ? "not specified" : handover.ObjectDescription)}<i>.<br />
When you receive the sample, please <a href=""{URL}/object/{sample.ObjectNameUrl}"">confirm this</a> in the system by specifying your comments for sender!
{Footer}
</p>";
                // send letter to Destination User;
                await mailSender.SendEmailAsync(destinationUser.Email, subject: $"Handover event registered: {handover.ObjectName}", htmlMessage: htmlMessage);
            }
        }

    }
}
