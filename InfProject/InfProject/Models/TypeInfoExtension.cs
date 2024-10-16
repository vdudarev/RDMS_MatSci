using WebUtilsLib;
using TypeValidationLibrary;
using Newtonsoft.Json.Linq;

namespace InfProject.Models;

/// <summary>
/// Extensions for TypeInfo class
/// </summary>
public static class TypeInfoExtension
{
    /// <summary>
    /// Gets settings from JSON document from Type information
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>JObject</returns>
    public static JObject GetJsonSettings(this TypeInfo type) {
        if (string.IsNullOrEmpty(type.SettingsJson))
            return new JObject();
        var json = JObject.Parse(type.SettingsJson);
        return json;
    }

    /// <summary>
    /// Gets string settings from JSON document from Type information
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="name">parameter name from json</param>
    /// <returns>parameter value or string.empty</returns>
    public static string GetJsonSettingsString(this TypeInfo type, string name)
    {
        var json = GetJsonSettings(type);
        return json[name]?.ToString() ?? string.Empty;
    }


    /// <summary>
    /// Gets ApplyForTypeIds array
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>list of ints (type identifiers)</returns>
    public static List<int> GetSettingsApplyForTypeIds(this TypeInfo type) {
        var json = GetJsonSettings(type);
        var value = json["ApplyForTypeIds"];
        var arr = value?.Values().Select(x => int.Parse(x.ToString())).ToList() ?? new List<int>(new int[] { 6 });
        return arr;
    }

    /// <summary>
    /// Gets AllowedExtensions array
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>string with URL for external POST request to visualize the object</returns>
    public static List<string> GetSettingsAllowedExtensions(this TypeInfo type)
    {
        var json = GetJsonSettings(type);
        var value = json["AllowedExtensions"];
        var arr = value?.Values().Select(x => x.ToString()).ToList() ?? new List<string>();
        return arr;
    }

    /// <summary>
    /// Gets URL to visualize the object (or string.Empty). Supposed to be user for VALID files (IFileValidator should return success)
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>string with URL for external POST request to visualize the object</returns>
    public static string GetSettingsUrlPostVisualizer(this TypeInfo type) =>
        GetJsonSettingsString(type, "UrlPostVisualizer");

    /// <summary>
    /// Gets CustomEditPath to provide customized edit experience for a type
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>string with path prefix to the edit form to create/edit the object if a given type</returns>
    public static string GetSettingsCustomEditPath(this TypeInfo type) =>
        GetJsonSettingsString(type, "CustomEditPath");

    /// <summary>
    /// Gets IncludePropertiesFrom settings
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <returns>true - show properties form in object creation/modification UI and update properties accordingly; false - default behavior (without properties form)</returns>
    public static bool GetSettingsIncludePropertiesForm(this TypeInfo type)
    {
        var value = GetJsonSettingsString(type, "IncludePropertiesForm");
        int.TryParse(value, out int retVal);
        return retVal!=0;
    }

    /// <summary>
    /// Creates an object for validating documents for type
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="currentContextObject">ObjectInfo for ehich we are going to extract values, i.e. the context is determined by it</param>
    /// <returns>IFileValidator</returns>
    public static IFileValidator GetValidator(this TypeInfo type, Context currentContext)
    {
        IFileValidator obj = null!;
        var schema = type.ValidationSchema;
        if (string.IsNullOrEmpty(schema))
        {  // ok (by default)
            obj = new TypeValidator_Ok();
            var allowedExt = type.GetSettingsAllowedExtensions();
            if (allowedExt?.Count > 0) {
                obj.AllowedExtensions = allowedExt;
            }
            return obj;
        }
        if (schema.StartsWith("type:"))
        { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
            var className = schema.Substring(5);
            obj = ValidatorTypeHelper.CreateObject<IFileValidator>(className);
            var allowedExt = type.GetSettingsAllowedExtensions();
            if (allowedExt?.Count>0) {
                obj.AllowedExtensions = allowedExt;
            }
            EmbedContext(obj, currentContext);
        }
        else if (schema.StartsWith("http://") || schema.StartsWith("https://"))
        {
            obj = new HttpTypeValidatorProxy(schema);
        }
        return obj;
    }



    /// <summary>
    /// Creates an object for getting full table data
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="validator"></param>
    /// <returns>ITableGetter</returns>
    public static ITableGetter? GetTableGetter(this TypeInfo type, IFileValidator validator = null)
    {
        ITableGetter obj = validator as ITableGetter;
        if (obj != null)
        {
            return obj;
        }
        var schema = type.DataSchema;
        if (string.IsNullOrEmpty(schema))
        {  
            return null;
        }
        if (schema.StartsWith("type:"))
        { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
            var className = schema.Substring(5);
            obj = ValidatorTypeHelper.CreateObject<ITableGetter>(className);
        }
        else if (schema.StartsWith("http://") || schema.StartsWith("https://"))
        {
            obj = new HttpTypeDataProxy(schema);
        }
        return obj;
    }


    /// <summary>
    /// Creates an object for getting full table data
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="prevValidatorObject">validator object, that can be also a data extractor object (no repeatable objects creation => performance boosting, )</param>
    /// <param name="currentContextObject">ObjectInfo for ehich we are going to extract values, i.e. the context is determined by it</param>
    /// <returns>IDatabaseValuesGetter?</returns>
    public static IDatabaseValuesGetter? GetDatabaseValuesGetter(this TypeInfo type, object prevValidatorObject, Context currentContext)
    {
        EmbedContext(prevValidatorObject as IContext, currentContext);
        IDatabaseValuesGetter obj = prevValidatorObject as IDatabaseValuesGetter;
        if (obj != null)
        {
            return obj;
        }
        var schema = type.DataSchema;
        if (string.IsNullOrEmpty(schema))   // https://validation.matinf.pro/edx/data
        {
            return null;
        }
        if (schema.StartsWith("type:"))
        { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
            var className = schema.Substring(5);
            obj = ValidatorTypeHelper.CreateObject<IDatabaseValuesGetter>(className);
        }
        else if (schema.StartsWith("http://") || schema.StartsWith("https://"))
        {
            obj = new HttpTypeDataProxy(schema);
        }
        return obj;
    }





    /// <summary>
    /// Validates file of type by given absolute file path
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="filePath">absolute file path</param>
    /// <returns>TypeValidatorResult</returns>
    public static TypeValidatorResult ValidateFile(this TypeInfo type, string filePath)
    {
        if (string.IsNullOrEmpty(filePath)) {
            if (type.FileRequired) {
                return new TypeValidatorResult(404, $"FileRequired is set for type {type.TypeName}, but no file was provided");
            }
            return new TypeValidatorResult();
        }
        var validator = type.GetValidator(null);    // TODO: implement context: null => ObjectInfo 
        validator.File = new FileInfo(filePath);
        var res = validator.Validate();
        return res;
    }
    /// <summary>
    /// Validates object data of type by given stream
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="inputStream">stream with object data</param>
    /// <returns></returns>
    public static TypeValidatorResult ValidateStream(this TypeInfo type, Stream inputStream)
    {
        if (inputStream==null)
        {
            if (type.FileRequired) {
                return new TypeValidatorResult(404, $"FileRequired is set for type {type.TypeName}, but no file was provided");
            }
            return new TypeValidatorResult();
        }
        var validator = type.GetValidator(null);    // TODO: implement context: null => ObjectInfo 
        validator.Stream = inputStream;
        var res = validator.Validate();
        return res;
    }

    /// <summary>
    /// Validates file and (if ok) returns DatabaseValues
    /// </summary>
    /// <param name="type">Object Type</param>
    /// <param name="absoluteFilePath">absolute path to the file</param>
    /// <param name="currentContext">Context (current Object) with which we are going to extract values</param>
    /// <returns></returns>
    public static (TypeValidatorResult res, DBUtils.DatabaseValues data) ValidateFileAndGetDataValues(this TypeInfo type, string absoluteFilePath, Context currentContext)
    {
        TypeValidatorResult res;
        DBUtils.DatabaseValues data;
        if (string.IsNullOrEmpty(absoluteFilePath))
        {
            if (type.FileRequired)
            {
                res = new TypeValidatorResult() { Code = 404, Message = $"required file is not defined [ObjectFilePath is empty]" };
            }
            else {
                res = new TypeValidatorResult(); // ok
            }
            data = new DBUtils.DatabaseValues() { DeletePreviousProperties = false, DeletePreviousCompositions = false }; // important not to delete all data if no file is there

        }
        else {
            var validator = type.GetValidator(currentContext);
            validator.File = new FileInfo(absoluteFilePath);
            res = validator.Validate();

            var dbValuesGetter = type.GetDatabaseValuesGetter(validator, currentContext);   // could be other object
            if (dbValuesGetter != null)
            {
                dbValuesGetter.File = new FileInfo(absoluteFilePath);   // in case it is other object
                data = dbValuesGetter.GetDatabaseValues();
            }
            else
            {
                data = new DBUtils.DatabaseValues();
            }
        }
        return (res, data);
    }


    /// <summary>
    /// Set Up Context (important to correctly validate or import data
    /// </summary>
    /// <param name="extractorContext">IContext interface of data extractor</param>
    /// <param name="currentContext"></param>
    private static void EmbedContext(IContext extractorContext, Context currentContext)
    {
        if (extractorContext == null || currentContext == null)
            return;
        extractorContext.Context = currentContext;

        // //TODO: Set Context
        // 0. Extract currentContextObject in Dictionary
        //Dictionary<string, string> dict = ExtractContextToDictionary(currentContextObject);
        // 1. Fill Dictionary 
        // 2. Call SetContext
    }


    //public static Dictionary<string, string> ExtractContextToDictionary(this DataContext dataContext, ObjectInfo currentContextObject) {
    //    Dictionary<string, string> dict = new Dictionary<string, string>();


    //    return dict;
    //}

}
