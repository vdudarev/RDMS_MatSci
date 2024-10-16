using Dapper;
using InfProject.Models;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.Extensions.Primitives;
using System;
using System.Data;
using System.Net.NetworkInformation;
using System.Reflection;
using System.Text;
using System.Xml.Linq;
using WebUtilsLib;
using static Azure.Core.HttpHeader;
using static System.Net.Mime.MediaTypeNames;
using static WebUtilsLib.DBUtils;

namespace InfProject.Utils
{
    public class ReflectionUtils
    {

        public static string GetIdName(string tableName) =>
            tableName == "ObjectInfo" ? "ObjectId" : tableName + "Id";


        /// <summary>
        /// Get CSV parameters for stored procedure
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public static string GetStoredProcedureParametersByType<T>() where T : ObjectInfo
        {
            StringBuilder sb = new StringBuilder(64);
            GetStoredProcedureParametersByType<T>(typeof(T), sb);
            return sb.ToString();
        }

        private static void GetStoredProcedureParametersByType<T>(Type type, StringBuilder sb) where T : ObjectInfo
        {
            string name = type.Name;
            string idName = GetIdName(name);
            if (type.BaseType != typeof(ObjectInfo))
            {
                GetStoredProcedureParametersByType<T>(type.BaseType, sb);
            }
            // var list = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            var list = from property in type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly)
                       where Attribute.IsDefined(property, typeof(OrderAttribute))
                       orderby ((OrderAttribute)property.GetCustomAttributes(typeof(OrderAttribute), false).Single()).Order
                       select property;
            foreach (PropertyInfo propertyInfo in list)
            {
                if (propertyInfo.Name == idName) continue;
                sb.Append($", @{propertyInfo.Name}");
            }
        }





        public static Dapper.DynamicParameters GetDynamicParametersFromObject<T>(T obj) where T : ObjectInfo {
            Type t = obj.GetType();
            var parameters = new DynamicParameters();
            GetDynamicParametersFromObject(obj, t, parameters);
            return parameters;
        }

        private static void GetDynamicParametersFromObject<T>(T obj, Type type, DynamicParameters parameters) where T : ObjectInfo
        {
            string idName = GetIdName(type.Name);
            var bt = type.BaseType;
            if (type != typeof(ObjectInfo)) {
                GetDynamicParametersFromObject(obj, bt, parameters);
            }
            //var list = type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            var list = from property in type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly)
                       where Attribute.IsDefined(property, typeof(OrderAttribute))
                       orderby ((OrderAttribute)property.GetCustomAttributes(typeof(OrderAttribute), false).Single()).Order
                       select property;
            foreach (PropertyInfo propertyInfo in list)
            {
                if (propertyInfo.Name == idName && idName != "ObjectId") 
                    continue;
                dynamic val = propertyInfo.GetValue(obj);
                parameters.Add(propertyInfo.Name, val);
            }
        }


        public static dynamic GetObjectFromRequest(ObjectInfo obj, string tableName, IFormCollection requestCollection, int? index=null) {
            Type t = Type.GetType($"InfProject.Models.{tableName}");
            dynamic dObj = Activator.CreateInstance(t);

            // dObj <- obj
            dObj.ObjectId = obj.ObjectId;
            dObj.TenantId = obj.TenantId;
            dObj._created = obj._created;
            dObj._createdBy = obj._createdBy;
            dObj._updated = obj._updated;
            dObj._updatedBy = obj._updatedBy;
            dObj.TypeId = obj.TypeId;
            dObj.RubricId = obj.RubricId;
            dObj.SortCode = obj.SortCode;
            dObj.AccessControl = obj.AccessControl;
            dObj.IsPublished = obj.IsPublished;
            dObj.ExternalId = obj.ExternalId;
            dObj.ObjectName = obj.ObjectName;
            dObj.ObjectNameUrl = obj.ObjectNameUrl;
            dObj.ObjectFilePath = obj.ObjectFilePath;
            dObj.ObjectDescription = obj.ObjectDescription;
            // foreach (PropertyInfo propertyInfo in t.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly))
            foreach (PropertyInfo propertyInfo in t.GetProperties(BindingFlags.Public | BindingFlags.Instance)) // VIC 2023-09-26 to support longer inheritance chain
            {
                if (propertyInfo.DeclaringType == typeof(ObjectInfo)) { // VIC 2023-09-26
                    continue;
                }
                if (propertyInfo.Name == GetIdName(tableName))
                {
                    propertyInfo.SetValue(dObj, obj.ObjectId);
                }
                else
                {
                    dynamic val = requestCollection[index == null ? propertyInfo.Name : $"{propertyInfo.Name}{index}"];
                    if (val.Count > 0)
                    {
                        if (!SetIfNumericType(propertyInfo, dObj, val[0]))
                        {
                            propertyInfo.SetValue(dObj, val[0]);
                        }
                    }
                }
            }
            ExtendCompositionFromRequest(dObj, tableName, requestCollection, index);
            return dObj;
        }

        public static void ExtendCompositionFromRequest(dynamic dObj, string tableName, IFormCollection requestCollection, int? index = null) {
            if (string.CompareOrdinal(tableName, "Composition") != 0)
                return;
            if (requestCollection.TryGetValue(index == null ? "Elements" : $"Elements{index}", out StringValues elements) && elements.Count>0) {
                dObj.Elements = elements[0];
            }
            List<Composition.CompositionItem> items = GetCompositionItemsFromRequest(requestCollection, index);
            dObj.CompositionItems = items;
        }

        public static List<Composition.CompositionItem> GetCompositionItemsFromRequest(IFormCollection requestCollection, int? index = null)
        {
            List<Composition.CompositionItem> items = new List<Composition.CompositionItem>();
            if (requestCollection == null || !requestCollection.TryGetValue(index == null ? "element" : $"element{index}", out StringValues elements))
                return items;
            int idx = 0;
            foreach (string element in elements)
            {
                if (string.IsNullOrEmpty(element))
                    continue;
                Composition.CompositionItem item = new Composition.CompositionItem()
                {
                    ElementName = element,
                    CompoundIndex = ++idx
                };
                if (requestCollection.TryGetValue(index == null ? $"{element}_ValueAbsolute" : $"{element}_ValueAbsolute{index}", out StringValues abs))
                {
                    double.TryParse(LocalizationUtils.AdjustNumberString(abs[0]), out double d);
                    item.ValueAbsolute = d;
                }
                if (requestCollection.TryGetValue(index == null ? $"{element}_ValuePercent" : $"{element}_ValuePercent{index}", out StringValues per))
                {
                    double.TryParse(LocalizationUtils.AdjustNumberString(per[0]), out double d);
                    item.ValuePercent = d;
                }
                items.Add(item);
            }
            return items;
        }


        public static bool SetIfNumericType(PropertyInfo propertyInfo, dynamic target, dynamic value)
        {
            Type? nullableTypeUnderlying = Nullable.GetUnderlyingType(propertyInfo.PropertyType);
            TypeCode tc = Type.GetTypeCode(propertyInfo.PropertyType);
            if (nullableTypeUnderlying != null) { 
                tc = Type.GetTypeCode(nullableTypeUnderlying);
            }
            switch (tc)
            {
                case TypeCode.Byte:
                    propertyInfo.SetValue(target, Convert.ToByte(value));
                    return true;
                case TypeCode.SByte:
                    propertyInfo.SetValue(target, Convert.ToSByte(value));
                    return true;
                case TypeCode.UInt16:
                    propertyInfo.SetValue(target, Convert.ToUInt16(value));
                    return true;
                case TypeCode.UInt32:
                    propertyInfo.SetValue(target, Convert.ToUInt32(value));
                    return true;
                case TypeCode.UInt64:
                    propertyInfo.SetValue(target, Convert.ToUInt64(value));
                    return true;
                case TypeCode.Int16:
                    propertyInfo.SetValue(target, Convert.ToInt16(value));
                    return true;
                case TypeCode.Int32:
                    propertyInfo.SetValue(target, Convert.ToInt32(value));
                    return true;
                case TypeCode.Int64:
                    propertyInfo.SetValue(target, nullableTypeUnderlying != null && string.IsNullOrEmpty(value) ? null : Convert.ToInt64(value));
                    return true;
                case TypeCode.Decimal:
                    propertyInfo.SetValue(target, Convert.ToDecimal(value));
                    return true;
                case TypeCode.Double:
                    propertyInfo.SetValue(target, Convert.ToDouble(value));
                    return true;
                case TypeCode.Single:
                    propertyInfo.SetValue(target, Convert.ToSingle(value));
                    return true;
                default:
                    return false;
            }
        }
    }
}
