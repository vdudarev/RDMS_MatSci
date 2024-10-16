using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace WebApiValidator
{
    
    // https://learn.microsoft.com/en-us/answers/questions/920018/web-api-415-unsupported-media-type

    public class CustomModelBinderProvider : IModelBinderProvider { 
        public IModelBinder GetBinder(ModelBinderProviderContext context) {
            if (context.Metadata.ModelType == typeof(byte[]))
                return new CustomModelBinder();
            return null;
        }
    }

    public class CustomModelBinder : IModelBinder
    {
        public Task BindModelAsync(ModelBindingContext bindingContext)
        {
            if (bindingContext == null)
                throw new ArgumentNullException(nameof(bindingContext));

            if (bindingContext.HttpContext.Request.ContentType == "application/octet-stream") {
                byte[] arr = new byte[0];
                bindingContext.Result = ModelBindingResult.Success(arr);
            }
            return Task.CompletedTask;
        }
    }
    
}
