﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System.IO;
using System.Reflection;
using System.Threading.Tasks;

namespace InfProject.Utils;

public static class ControllerExtensions
{

    /// <summary>
    /// Then just implement with:
    /// viewHtml = await this.RenderViewAsync("Report", model);
    /// Or this for a PartialView:
    /// partialViewHtml = await this.RenderViewAsync("Report", model, true);
    /// </summary>
    /// <typeparam name="TModel"></typeparam>
    /// <param name="controller"></param>
    /// <param name="viewName"></param>
    /// <param name="model"></param>
    /// <param name="partial"></param>
    /// <returns></returns>
    public static async Task<string> RenderViewAsync<TModel>(this Controller controller, string viewName, TModel model, bool partial = false)
    {
        if (string.IsNullOrEmpty(viewName))
        {
            viewName = controller.ControllerContext.ActionDescriptor.ActionName;
        }

        controller.ViewData.Model = model;

        using (var writer = new StringWriter())
        {
            IViewEngine? viewEngine = controller.HttpContext.RequestServices.GetService(typeof(ICompositeViewEngine)) as ICompositeViewEngine;
            ViewEngineResult? viewResult = viewEngine?.FindView(controller.ControllerContext, viewName, !partial);

            if (viewResult == null || viewResult.Success == false)
            {
                return $"A view with the name {viewName} could not be found";
            }

            ViewContext viewContext = new ViewContext(
                controller.ControllerContext,
                viewResult.View,
                controller.ViewData,
                controller.TempData,
                writer,
                new HtmlHelperOptions()
            );

            await viewResult.View.RenderAsync(viewContext);

            return writer.GetStringBuilder().ToString();
        }
    }
    


}
