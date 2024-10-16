using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json.Serialization;
using System.Reflection;
using WebApiValidator;
using WebUtilsLib;

LocalizationUtils.SetCulture();
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
//builder.Services.AddControllers();
builder.Services.AddControllers(o => o.ModelBinderProviders.Insert(0, new CustomModelBinderProvider()))
    // No fields remaning to camelCase for standard serilization
    //.AddJsonOptions(options => options.JsonSerializerOptions.PropertyNamingPolicy = null)   // https://stackoverflow.com/questions/59559560/change-json-serialization-from-camelcase-to-pascalcase-duplicate-no-solution
    .AddNewtonsoftJson(options => {
        options.SerializerSettings.ContractResolver = null;
    });    // to JSONofy DataTable and etc + keep Case
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory,
    $"{Assembly.GetExecutingAssembly().GetName().Name}.xml"), includeControllerXmlComments: true);

    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory,
    $"TypeValidationLibrary.xml"), includeControllerXmlComments: true);
});

// builder.Services.AddSwaggerGen(c => { c.SwaggerDoc("v1", new OpenApiInfo { Title = "Task01_WebAPI_ProductList", Version = "v1" }); });

builder.Services.Configure<KestrelServerOptions>(o => { o.AllowSynchronousIO = true; });
builder.Services.Configure<IISServerOptions>    (o => { o.AllowSynchronousIO = true; });


var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "WebAPI_MatSci_Validation");
        c.RoutePrefix = string.Empty;  // Set Swagger UI at apps root    
    });
}


app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
