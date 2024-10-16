using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Reflection;
using System.Text;
using System.Text.Json;
using WebUtilsLib;

namespace TypeValidationLibrary
{
    /// <summary>
    /// base class
    /// </summary>
    public static class ValidatorTypeHelper
    {
        private static readonly HttpClient client = new HttpClient();

        /// <summary>
        /// Use reflection to create arbitrary type that supports IFileValidator
        /// </summary>
        /// <param name="typeName">name of a class or structure that supports IFileValidator</param>
        /// <returns>IFileValidator instance</returns>
        public static T CreateObject<T>(string typeName) {
            T resObject = default(T);
            try
            {
                Type t = Type.GetType(typeName);
                object obj = Activator.CreateInstance(t);
                resObject = (T)obj;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error instantiating a type {typeName} - check type settings", ex);
            }
            return resObject;
        }


        /*
        /// <summary>
        /// Validates a file against validationSchema
        /// </summary>
        /// <param name="validationSchema"></param>
        /// <param name="filePath">full file path</param>
        /// <returns>TypeValidatorResult</returns>
        public static TypeValidatorResult ValidateFile(string? validationSchema, string filePath)
        {
            var res = new TypeValidatorResult();
            if (string.IsNullOrEmpty(validationSchema)) {  // ok (by default)
                return res;
            }
            IFileValidator validator = GetValidator(validationSchema);
            validator.File = new FileInfo(filePath);
            res = validator.Validate();
            return res;
        }
        

        /// <summary>
        /// Validates a file against validationSchema AndGetDataValues
        /// </summary>
        /// <param name="validationSchema"></param>
        /// <param name="filePath">full file path</param>
        /// <returns>TypeValidatorResult</returns>
        public static (TypeValidatorResult res, DBUtils.DatabaseValues data) ValidateFileAndGetDataValues(string? validationSchema, string? dataSchema, string filePath)
        {
            (TypeValidatorResult res, DBUtils.DatabaseValues data) ret = (new TypeValidatorResult(), new DBUtils.DatabaseValues());
            if (string.IsNullOrEmpty(validationSchema))
            {  // ok (by default)
                return ret;
            }
            if (validationSchema.StartsWith("type:"))
            { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
                var className = validationSchema.Substring(5);
                IFileValidator validator = CreateObject<IFileValidator>(className);
                validator.File = new FileInfo(filePath);
                ret.res = validator.Validate();
                IDatabaseValuesGetter pg = validator as IDatabaseValuesGetter;
                if (pg == null && !string.IsNullOrEmpty(dataSchema) && dataSchema.StartsWith("type:")) {
                    className = dataSchema.Substring(5);
                    pg = CreateObject<IDatabaseValuesGetter>(className);
                }
                if (ret.res && pg!=null) {
                    ret.data = pg.GetDatabaseValues();
                }
            }
            else if (validationSchema.StartsWith("http://") || validationSchema.StartsWith("https://"))
            {
                ret.res = GetDataThroughWebService<TypeValidatorResult>(validationSchema, filePath).Result;
                ret.data = GetDataThroughWebService<DBUtils.DatabaseValues>(dataSchema, filePath).Result;
            }
            return ret;
        }
                



        /// <summary>
        /// Validates a file against validationSchema
        /// </summary>
        /// <param name="validationSchema"></param>
        /// <param name="filePath">full file path</param>
        /// <returns>TypeValidatorResult</returns>
        public static TypeValidatorResult ValidateStream(string? validationSchema, Stream inputStream)
        {
            var res = new TypeValidatorResult();
            if (string.IsNullOrEmpty(validationSchema)) {  // ok (by default)
                return res;
            }
            if (validationSchema.StartsWith("type:"))
            { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
                var className = validationSchema.Substring(5);
                IFileValidator validator = CreateObject<IFileValidator>(className);
                validator.Stream = inputStream;
                res = validator.Validate();
            }
            else if (validationSchema.StartsWith("http://") || validationSchema.StartsWith("https://"))
            {
                res = GetDataThroughWebService<TypeValidatorResult>(validationSchema, inputStream).Result;
            }
            return res;
        }
        

        /// <summary>
        /// Validates a file against validationSchema AndGetDataValues
        /// </summary>
        /// <param name="validationSchema"></param>
        /// <param name="filePath">full file path</param>
        /// <returns>TypeValidatorResult</returns>
        public static (TypeValidatorResult res, DBUtils.DatabaseValues data) ValidateStreamAndGetDataValues(string? validationSchema, string? dataSchema, Stream inputStream)
        {
            (TypeValidatorResult res, DBUtils.DatabaseValues data) ret = (new TypeValidatorResult(), new DBUtils.DatabaseValues());
            if (string.IsNullOrEmpty(validationSchema))
            {  // ok (by default)
                return ret;
            }
            if (validationSchema.StartsWith("type:"))
            { // type:TypeValidationLibrary.TypeValidator_EDX_CSV
                var className = validationSchema.Substring(5);
                IFileValidator validator = CreateObject<IFileValidator>(className);
                validator.Stream = inputStream;
                ret.res = validator.Validate();
                IDatabaseValuesGetter pg = validator as IDatabaseValuesGetter;
                if (pg == null && !string.IsNullOrEmpty(dataSchema) && dataSchema.StartsWith("type:"))
                {
                    className = dataSchema.Substring(5);
                    pg = CreateObject<IDatabaseValuesGetter>(className);
                }
                if (ret.res && pg != null)
                {
                    ret.data = pg.GetDatabaseValues();
                }
            }
            else if (validationSchema.StartsWith("http://") || validationSchema.StartsWith("https://"))
            {
                ret.res = GetDataThroughWebService<TypeValidatorResult>(validationSchema, inputStream).Result;
                ret.data = GetDataThroughWebService<DBUtils.DatabaseValues>(dataSchema, inputStream).Result;
            }
            return ret;
        }
        */

    }
}