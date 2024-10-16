using InfProject.DBContext;
using InfProject.Models;
using System.IO;
using System.Text;
using static WebUtilsLib.DBUtils;
using WebUtilsLib;

namespace InfProject.Utils
{
    public class PropertiesUtils
    {
        public class PropertyForOutput {
            public int PropertyId;
            public string path;
            public int level; 
            public bool isSeparapor;
            public int countFilledChildren;
            public string value;
            public string nameNormalized;
        }

        public static PropertyForOutput[] GetPropertiesDesctiptionForOutput(List<dynamic> listAll) {
            PropertyForOutput[] desc = new PropertyForOutput[listAll.Count];
            string path;
            int level;
            for (var i = 0; i < listAll.Count; i++) {   // First Iteration: fill all the array
                path = listAll[i].PropertyName.Replace(" => ", "}");    // replace " => " with "}"
                level = path.Length - path.Replace("}", string.Empty).Length;   // level(determined as number of '}'): 0, 1, 2, ...
                string[] arrNames = (listAll[i].PropertyName ?? string.Empty).Split(" => ", StringSplitOptions.RemoveEmptyEntries);
                desc[i] = new PropertyForOutput() { 
                    PropertyId = listAll[i].PropertyId ?? listAll[i].TemplatePropertyId,
                    path = path,
                    level = level,
                    isSeparapor = listAll[i].TemplateComment == "SEPARATOR",
                    countFilledChildren = 0,
                    value = listAll[i].Value,
                    nameNormalized = arrNames[arrNames.Length - 1]
                };
            }
            for(var i = 0; i < listAll.Count; i++){   // Second Iteration: calculate countFilledChildren
                if (desc[i].isSeparapor)
                {
                    desc[i].countFilledChildren = desc.Where(x => !x.isSeparapor && x.path.StartsWith(desc[i].path + "}") && (
                        !string.IsNullOrEmpty(x.value)
                    )).Count();
                }
            }
            return desc;
        }


        /// <summary>
        /// Updates object properties based on HttpRequest form and template
        /// </summary>
        /// <param name="objectId">object identifier</param>
        /// <param name="httpContext">HttpHttpContext to take data from a request (html form is used) and get user from context</param>
        /// <param name="dataContext">DataContext to work with DB</param>
        /// <param name="objectFormPrefix">Form prefix for the object (required on batch operations to distinguish between several forms placed together for several objects), see also pEditItem_PropertiesForm.cshtml</param>
        /// <returns>(int updatedInserted, // updatedInserted properties count, 
        /// int deleted, // deleted properties count
        /// string log) // detailed log as a string</returns>
        /// <exception cref="Exception">Exception if no access to the object from the current user context</exception>
        public static async Task<(int updatedInserted, int deleted, string log)> UpdateInsert_PropertiesFromForm(int objectId, HttpContext httpContext, DataContext dataContext, string objectFormPrefix = null)
        {
            if (objectFormPrefix == null) 
                objectFormPrefix = string.Empty;
            ObjectInfo objOld = await httpContext.GetObjectAndCheckWriteAccess(dataContext, objectId);   // Exception if no access
            HttpRequest Request = httpContext.Request;
            int userId = httpContext.GetUserId();
            DateTime dt = DateTime.Now.AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)
            StringBuilder sb = new StringBuilder();
            int updatedInserted = 0;
            foreach (string item in Request.Form[$"{objectFormPrefix}prop_templ"])
            {
                int i = item.IndexOf('_');
                if (i < 0)
                {
                    throw new Exception($"Underscore is not found in prop_templ value: \"{item}\"");
                }
                int.TryParse(item.Substring(0, i), out int PropertyId);   // existing PropertyId
                int.TryParse(item.Substring(i + 1, item.Length - i - 1), out int TemplatePropertyId);    // Template PropertyId
                string name = Request.Form[$"{objectFormPrefix}nam" + item][0] ?? string.Empty;
                string? sortStr = Request.Form[$"{objectFormPrefix}sor" + item][0];
                string? typeStr = Request.Form[$"{objectFormPrefix}typ" + item][0];
                string? valueForm = Request.Form[$"{objectFormPrefix}val" + item][0];
                string? epsilonStr = Request.Form[$"{objectFormPrefix}eps" + item].ToString(); // may not exist
                string? comment = Request.Form[$"{objectFormPrefix}com" + item][0];
                // Source ObjectId (optional field)
                string? sourceObjectIdStr = string.IsNullOrEmpty(Request.Form[$"{objectFormPrefix}soid" + item]) ? string.Empty : Request.Form[$"{objectFormPrefix}soid" + item][0];

                sb.AppendLine($"PropertyId={PropertyId}; TemplatePropertyId={TemplatePropertyId}. type={typeStr}, value={valueForm}, epsilon={epsilonStr}, comment={comment}");
                // UPDATE / INSERT in database
                //newObject = await dataContext.ObjectInfo_UpdateInsert(obj);

                if (!string.IsNullOrEmpty(valueForm))
                {
                    PropertyType type = (PropertyType)Enum.Parse(typeof(PropertyType), typeStr);
                    int.TryParse(sortStr, out int sortCode);
                    int.TryParse(sourceObjectIdStr, out int sourceObjectId);
                    double? epsilon = null;
                    if (double.TryParse(epsilonStr, out double eps))
                    {
                        epsilon = eps;
                    }
                    object val = valueForm;
                    if (type == PropertyType.Float)
                    {
                        double.TryParse(valueForm, out double v);
                        val = v;
                    }
                    if (type == PropertyType.Int)
                    {
                        long.TryParse(valueForm, out long v);
                        val = v;
                    }
                    PropertyValue value = new PropertyValue()
                    {
                        PropertyId = PropertyId,
                        PropertyType = type,
                        PropertyName = name,
                        Value = val,
                        ValueEpsilon = epsilon,
                        SortCode = sortCode,
                        Row = null,
                        Comment = comment,
                        SourceObjectId = sourceObjectId
                    };
                    int newPropertyId = await dataContext.Property_UpdateInsert(value, dt, userId, objectId);
                    updatedInserted++;
                }
            }
            // clean up previous properties by date 
            int deleted = await dataContext.Property_DeleteNonTableBefore(objectId, dt);
            return (updatedInserted, deleted, log: sb.ToString());
        }

    }
}
