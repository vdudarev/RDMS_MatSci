using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.EntityFrameworkCore;
using InfProject.DBContext;
using InfProject.Data;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.DependencyInjection;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using System;
using Microsoft.AspNetCore.Authentication.OAuth;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.AspNetCore.Authentication.Google;
using InfProject.Utils;
using Serilog;
using Serilog.Extensions.Hosting;
using WebUtilsLib;
using FluentValidation;
using InfProject.Models;
using FormHelper;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using System.Globalization;
using OfficeOpenXml;
using Microsoft.DotNet.Scaffolding.Shared;
using System.Configuration;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.AspNetCore.Http.Features;
using System.Reflection;
using InfProject;
using Serilog.Core;
using InfProject.Enrichers;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Serilog.Formatting.Display;

ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
LocalizationUtils.SetCulture();
var builder = WebApplication.CreateBuilder(args);
builder.WebHost.ConfigureKestrel(c => {
    c.Limits.KeepAliveTimeout = TimeSpan.FromMinutes(60);
    // MaxRequestBodySize: nullable property
    c.Limits.MaxRequestBodySize = null; // no limits // int.MaxValue;   // 2L * 1024 * 1024 * 1024;   // 2 Gb
    // c.Limits.MaxRequestBodySize = 10_737_418_240; // 10 Gb
});



LoggerConfiguration loggerConfig = new LoggerConfiguration();
if (builder.Environment.IsDevelopment())
    loggerConfig.MinimumLevel.Information();
else
    loggerConfig.MinimumLevel.Warning();
loggerConfig.Enrich.FromLogContext().Enrich.With(new ControllerAreaNameEnricher(new HttpContextAccessor()));

//.ReadFrom.Configuration(builder.Configuration)
Serilog.Core.Logger logger = loggerConfig.WriteTo.Console()
//.WriteTo.Sink(new DynamicFileSink(new MessageTemplateTextFormatter("{Timestamp:yyyy-MM-dd HH:mm:ss} [{Level}] {Message}{NewLine}{Exception}{NewLine}[{Properties:j}]")))
.WriteTo.Sink(new DynamicFileSink(new MessageTemplateTextFormatter("{Timestamp:yyyy-MM-dd HH:mm:ss} [{Level}] {Message}{NewLine}{Exception} ip={Ip}; Url={Url}; User={User}{NewLine}")))
//.File(
//    //Path.Combine(builder.Environment.ContentRootPath, "Logs\\log-{AreaName}-{ControllerName}.txt"),
//    "Logs\\log-{AreaName}.txt", //     Path.Combine(builder.Environment.ContentRootPath, "Logs\\log-{AreaName}.txt"),
//    rollingInterval: RollingInterval.Day
//)
.CreateLogger();
Log.Logger = logger;
Log.Information("The global logger has been configured");


builder.Host.UseSerilog(logger);

// https://learn.microsoft.com/en-us/aspnet/core/security/authentication/social/google-logins?view=aspnetcore-6.0
// https://console.cloud.google.com/apis/credentials/consent?project=materialsproject
builder.Services.AddAuthentication().AddGoogle(options => InfProject.Utils.AuthGoogle.GoogleConfigureOptions(options, builder));


builder.Services.Configure<RouteOptions>(options =>
    options.LowercaseUrls = true);

// Session


builder.Services.AddHttpContextAccessor();  //.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();
builder.Services.TryAddSingleton<IActionContextAccessor, ActionContextAccessor>();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession();

// https://github.com/dotnet/aspnetcore/issues/20369
builder.Services.Configure<IISServerOptions>(options => {
    options.MaxRequestBodySize = int.MaxValue; // 2 Gb
    // options.MaxRequestBodySize = 10_737_418_240; // 10 Gb
    // options.MaxRequestBodySize = null; // no limit
    // options.MaxRequestBodyBufferSize = int.MaxValue;
});
builder.Services.Configure<KestrelServerOptions>(options =>
{
    options.Limits.MaxRequestBodySize = int.MaxValue; // 2 Gb - if don't set default value is: 30 MB
    // options.Limits.MaxRequestBodySize = 10_737_418_240; // 10 Gb
    // options.Limits.MaxRequestBodySize = null; // no limit
});
builder.Services.Configure<FormOptions>(x =>
{
    x.ValueLengthLimit = int.MaxValue; // 2 Gb
    
    x.MultipartBodyLengthLimit = int.MaxValue; // 2 Gb - if don't set default value is: 128 MB
    // x.MultipartBodyLengthLimit = 10_737_418_240; // 10 Gb
    // x.MultipartHeadersLengthLimit = int.MaxValue; // 2 Gb
});

// validation: https://docs.fluentvalidation.net/en/latest/aspnet.html#getting-started
// builder.Services.AddScoped<IValidator<ObjectInfo>, ObjectInfoValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<ObjectInfoValidator>();

//string host = "inf.mdi.ruhr-uni-bochum.de"; // GetHost(services.GetService<IHttpContextAccessor>())
//// SQL Server + Dapper
//builder.Services.AddTransient<DataContext>(provider => new DataContext(
//    builder?.Configuration?.GetConnectionString("InfDB") ?? string.Empty,
//    host));
//builder.Services.AddTransient<DataContext>(provider => new DataContext(
builder.Services.AddScoped<DataContext>(provider => new DataContext(
    builder?.Configuration, provider.GetService<IHttpContextAccessor>()));

// Add services to the container.
//var connectionString = builder.Configuration.GetConnectionString("IdentityDB");
//builder.Services.AddDbContext<ApplicationDbContext>(options =>
//    options.UseSqlServer(connectionString));
builder.Services.AddScoped<ApplicationDbContext>(provider => {
    var options = new DbContextOptionsBuilder<ApplicationDbContext>();
    string hostName = ConfigHelpers.ConfigHttpHelpers.GetHostByHttpContext(builder?.Configuration, provider.GetService<IHttpContextAccessor>());
    var connectionString = ConfigHelpers.ConfigHelpers.GetConnectionString(builder?.Configuration, hostName);
    options.UseSqlServer(connectionString);
    return new ApplicationDbContext(options.Options);
});


builder.Services.AddDatabaseDeveloperPageExceptionFilter();
// VIC 2024-08 - begin (Global exception gandler for logging)
// https://medium.com/@MilanJovanovicTech/global-error-handling-in-asp-net-core-8-22e30dadc1fe
// builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
// builder.Services.AddProblemDetails();
// VIC 2024-08 - end (Global exception gandler for logging)

// Add email senders which is currently setup for SendGrid and SMTP
builder.Services.AddEmailSenders<SimpleMailSender>(builder.Configuration);


builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdministratorRole", policy => policy.RequireRole("Administrator"));
    options.AddPolicy("RequirePowerUserRole", policy => policy.RequireRole("PowerUser"));
    options.AddPolicy("RequireUserRole", policy => policy.RequireRole("User"));
});

builder.Services.AddDefaultIdentity<IdentityManagerUI.Models.ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = true)
    // https://learn.microsoft.com/en-us/aspnet/core/security/authorization/roles?view=aspnetcore-6.0
    .AddRoles<IdentityManagerUI.Models.ApplicationRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>();
// https://stackoverflow.com/questions/77007138/asp-net-core-mvc-api-versioning-by-url-segment-with-asp-versioning-mvc
builder.Services.AddApiVersioning();
builder.Services.AddRazorPages();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory,
    $"{Assembly.GetExecutingAssembly().GetName().Name}.xml"), includeControllerXmlComments: true);

    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory,
    $"TypeValidationLibrary.xml"), includeControllerXmlComments: true);
});

builder.Services.AddMvc().AddFormHelper();

// StartUpUsers.CreateRolesAndUsers(builder.Services.BuildServiceProvider(), builder.Configuration["Authentication:Admin:Email"], builder.Configuration["Authentication:Admin:Password"]);    // run once only to feed DB

var app = builder.Build();
//if (app.Environment.IsDevelopment())
{
    app.UseMiddleware<LogContextMiddleware>();
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "VroApi");
        c.RoutePrefix = "/vroapi";  // Set Swagger UI at apps root    
    });
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// add HttpContext to Exception handling
ExceptionHandler.SetHttpContextAccessor(app.Services.GetService<IHttpContextAccessor>());

app.UseStatusCodePagesWithReExecute("/StatusCode/{0}");

app.UseSession();
app.UseHttpsRedirection();
app.UseStaticFiles();


//app.UseWhen(
//    ctx => ctx.Request.Path.StartsWithSegments("/typevalidation"),
//    ab => ab.UseMiddleware<EnableRequestBodyBufferingMiddleware>()
//);

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "areas",
    pattern: "{area}/{controller=Home}/{action=Index}/{id?}");
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
app.MapRazorPages();
app.UseFormHelper();
app.Run();
