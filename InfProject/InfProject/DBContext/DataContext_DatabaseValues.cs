using System.Data;
using System.Data.SqlClient;
using System.Text;
using Dapper;
using InfProject.Models;
using static Dapper.SqlMapper;
using static InfProject.Models.Composition;
using static WebUtilsLib.DBUtils;

namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// modify data for object
    /// </summary>
    /// <param name="obj">parent object, i.e. object with FILE (to which data should be referred)</param>
    /// <param name="created">Date that should be specified in all possible cases on document creation</param>
    /// <param name="userId">user who is authorised to create objects</param>
    /// <param name="subRubricName">user who modifies data</param>
    /// <returns>rows affected</returns>
    public async Task<RubricInfo> Object_CreateSubRubricIfNecessary(ObjectInfo obj, DateTime created, int userId, string subRubricName)
    {
        if (obj.ObjectId < 1 || obj.RubricId < 1)
            throw new Exception("obj.ObjectId<1 || obj.RubricId<1");
        RubricInfo rubric = await GetRubricById((int)obj.RubricId); // rubric of EDX CSV

        RubricInfo subRubric = await GetRubricByRubricPath(rubric.RubricPath + "}" + subRubricName);
        if (subRubric!=null && subRubric.RubricId!=0)    // already exists
            return subRubric;

        // create rubric
        subRubric = new RubricInfo() {
            TenantId = TenantId,
            _createdBy = userId,
            _updatedBy = userId,
            TypeId = rubric.TypeId,
            ParentId = rubric.RubricId,
            LeafFlag = 0,
            Flags = 0,
            SortCode = 0,
            AccessControl = obj.AccessControl,
            IsPublished = obj.IsPublished,
            RubricName = subRubricName
        };
        RubricInfo createdRubric = await RubricInfo_UpdateInsert(subRubric);
        return createdRubric;
    }


    /// <summary>
    /// modify data for object
    /// </summary>
    /// <param name="data">DatabaseValues object with data for object</param>
    /// <param name="created">Date for records creation</param>
    /// <param name="userId">user who modifies data</param>
    /// <param name="obj">parent object, i.e. object with FILE (to which data should be referred)</param>
    /// <returns>rows affected</returns>
    public async Task<int> Object_UpdateInsertDatabaseValues(DatabaseValues data, DateTime created, int userId, ObjectInfo obj)
    {
        int res = 0;
        // properties (add properties to the object)
        res += await Property_UpdateInsertBatch(data?.Properties, created, userId, obj.ObjectId, data?.DeletePreviousProperties ?? false, sourceObjectId: obj.ObjectId);

        // create Compositions (add Compositions to the parent sample)
        res += await Composition_UpdateInsertBatch(data?.Compositions, created, userId, obj, data?.DeletePreviousCompositions ?? false);

        // update Compositions Properties (add properties to compositions [])
        res += await CompositionsForSampleUpdate_UpdateInsertBatch(data?.CompositionsForSampleUpdate, created, userId, obj);
        return res;
    }


    private async Task<TypeInfo> GetSampleType() {
        TypeInfo typeSample = await GetType(SampleTypeId);
        return typeSample;
    }


    private async Task<TypeInfo> GetMeasurementAreaType() {
        var types = await GetTypes();
        TypeInfo typeMA = types.FirstOrDefault(x => string.Compare(x.TypeName, "measurement area composition", true) == 0);
        if (typeMA == null || typeMA.TypeId < 1)
        {
            typeMA = types.FirstOrDefault(x => string.Compare(x.TypeName, "measurement area", true) == 0);
        }
        if (typeMA == null || typeMA.TypeId < 1)
        {
            typeMA = types.FirstOrDefault(x => string.Compare(x.TypeName, "composition", true) == 0);
        }
        if (typeMA == null || typeMA.TypeId < 1)
        {
            throw new Exception("Type for \"Measurement Area\" composition is not found (measurement area composition, measurement area, composition)");
        }
        return typeMA;
    }


    /// <summary>
    /// process BATCH compositions from EDX file
    /// </summary>
    /// <param name="values">list of compositions on the materials library</param>
    /// <param name="created">Date that should be specified in all possible cases on document creation</param>
    /// <param name="userId">user who is authorised to create objects</param>
    /// <param name="obj">Object (of EDX CSV type), that contains CSV-file, from which data is taken</param>
    /// <param name="deletePreviousCompositions">whether to delete previous compositions (associated with objectId)</param>
    /// <returns></returns>
    public async Task<int> Composition_UpdateInsertBatch(List<CompositionValue> values, DateTime created, int userId, ObjectInfo obj, bool deletePreviousCompositions = false) {
        if (deletePreviousCompositions) {   // not recommended
            await EdxCompositions_Delete(obj.ObjectId);
        }

        TypeInfo typeMA = await GetMeasurementAreaType();   // Type for Measurement Area
        ObjectInfoLinked sample = await FindParentSample(obj.ObjectId); // find a parent sample
        if (sample == null) {   // sample is not found
            throw new Exception($"Composition_UpdateInsertBatch: Parent sample was not found. Please define a characterization document as a child for the corresponding sample [TenantId={TenantId}; UserId={userId}; ObjectId={obj.ObjectId}]");
        }

        int res = 0;
        if (values != null && values.Count > 0) {
            string subRubricName = "Measurement Areas";
            if (sample.ExternalId != 0) {
                subRubricName = $"{sample.ExternalId} Measurement Areas";
            } else if (sample.ObjectId != 0) {
                subRubricName = $"{sample.ObjectId} Measurement Areas";
            }
            RubricInfo subRubric = await Object_CreateSubRubricIfNecessary(obj, created, userId, subRubricName);

            for (int i = 0; i < values.Count; i++)
            {
                res += await Composition_UpdateInsert(typeMA.TypeId, i, values[i], created, userId, obj, subRubric.RubricId);
            }
        }
        return res;
    }


    /// <summary>
    /// Get a single measurement area object that satisfies a predicate 
    /// </summary>
    /// <param name="parentSample_ObjectId">ObjectId for a sample</param>
    /// <param name="measurementAreaTypeId">typeId for a measurement area type (Compound)</param>
    /// <param name="predicate">the predicate as a set of properties</param>
    /// <returns>dynamic object of composition (measurement area) together with additional columns (from predicate)</returns>
    public async Task<dynamic> GetMeasurementAreaObjectByPredicate(int parentSample_ObjectId, int measurementAreaTypeId, Predicate predicate) {
/*
DECLARE @TenantId int=2
DECLARE @TypeIdMA int=8
DECLARE @ObjectId int=6673
-- EXEC [dbo].Get_ObjectInfoLinked 1, 8
select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, O.*
, [PI].[Value] as [Measurement Area]
, PF.[Value] as [Thickness]
FROM dbo.ObjectLinkObject as L
INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
INNER JOIN dbo.PropertyInt as [PI] ON [PI].ObjectId=O.ObjectId AND [PI].PropertyName='Measurement Area'
LEFT OUTER JOIN dbo.PropertyFloat as PF ON PF.ObjectId=O.ObjectId AND PF.PropertyName='Thickness'
WHERE L.ObjectId=@objectId AND O.TypeId=@TypeIdMA
--and [PI].[Value]
ORDER BY O.TypeId, L.SortCode, O.ObjectName 
 */
        DynamicParameters parameters = new DynamicParameters();
        parameters.Add("TenantId", TenantId);
        parameters.Add("objectId", parentSample_ObjectId);
        parameters.Add("TypeIdMA", measurementAreaTypeId);

        StringBuilder additionalSqlFields = new StringBuilder();
        StringBuilder additionalSqlJoins = new StringBuilder();
        StringBuilder additionalSqlWhere = new StringBuilder();
        for (int i = 0; i < predicate.Properties.Count; i++)
        {
            PropertyValue prop = predicate.Properties[i];
            string shortType = prop.PropertyType.ToString();
            string tableName = $"P{shortType}{i}";
            additionalSqlFields.AppendLine($", [{tableName}].[Value] as [{prop.PropertyName}]");
            additionalSqlJoins.AppendLine($"INNER JOIN dbo.Property{shortType} as [{tableName}] ON [{tableName}].ObjectId=O.ObjectId AND [{tableName}].PropertyName=@PropertyName{tableName}");
            additionalSqlJoins.AppendLine($" AND [{tableName}].[Value]=@PropertyValue{tableName}");
            parameters.Add($"PropertyName{tableName}", prop.PropertyName);
            parameters.Add($"PropertyValue{tableName}", prop.Value);
        }
        string sql = $@"select L.ObjectLinkObjectId, L.ObjectId as MainObjectId, L.SortCode as SortCodeLink, 
L._created as Link_created, L._createdBy as Link_createdBy, L._updated as Link_updated, L._updatedBy as Link_updatedBy, O.*
-- additionalFields - BEGIN
{additionalSqlFields}
-- additionalFields - END
FROM dbo.ObjectLinkObject as L
INNER JOIN dbo.ObjectInfo as O ON L.LinkedObjectId=O.ObjectId AND O.TenantId=@TenantId
-- additionalJoins - BEGIN
{additionalSqlJoins}
-- additionalJoins - END
WHERE L.ObjectId=@objectId AND O.TypeId=@TypeIdMA
{additionalSqlWhere}
ORDER BY O.TypeId, L.SortCode, O.ObjectName";
        using (IDbConnection connection = new SqlConnection(ConnectionString))
        {
            var res = (await connection.QueryAsync<dynamic>(sql, parameters)).ToList();
            if (res.Count < 1) {
                throw new IndexOutOfRangeException($"Unable to find Measurement Area object for parentSample_ObjectId={parentSample_ObjectId}, predicate={predicate}");
            }
            return res[0];
        }

    }



    /// <summary>
    /// Find parent Sample
    /// </summary>
    /// <param name="objectId">characterization object ObjectId (parent should be sample!)</param>
    /// <returns>ObjectInfoLinked - sample or null</returns>
    public async Task<ObjectInfoLinked?> FindParentSample(int objectId) {
        List<ObjectInfoLinked> parents = await ObjectLinkObject_GetLinkedObjects_Reverse(objectId);
        ObjectInfoLinked? sample = parents.FirstOrDefault(x => x.TypeId == SampleTypeId);
        return sample==null || sample.ObjectId==0 ? null : sample;
    }


    /// <summary>
    /// process BATCH compositions from EDX file
    /// </summary>
    /// <param name="values">list of CompositionsForSampleUpdatecompositions on the materials library</param>
    /// <param name="created">Date that should be specified in all possible cases on document creation</param>
    /// <param name="userId">user who is authorised to create objects</param>
    /// <param name="obj">Object (of EDX CSV or other type to which file belongs), that contains file, from which data is taken</param>
    ///// <param name="deletePreviousCompositions">whether to delete previous compositions (associated with objectId)</param>
    /// <returns></returns>
    public async Task<int> CompositionsForSampleUpdate_UpdateInsertBatch(List<CompositionsForSampleUpdate> values, DateTime created, int userId, ObjectInfo obj/*, bool deletePreviousCompositions = false*/)
    {
        TypeInfo typeMA = await GetMeasurementAreaType();   // Type for Measurement Area
        TypeInfo typeSample = await GetSampleType();   // Type for Sample
        int rowsAffected = 0;

        // obj - current object (For example, EDX, Resistance ot Thickness measurement)
        // 1 step. Find parent Sample
        ObjectInfoLinked sample = await FindParentSample(obj.ObjectId);
        if (sample == null) { // could be null (on first EDX upload)
            // so.. nothing to do
            return rowsAffected;
        }
        List<ObjectInfoLinked> sampleChildren = await ObjectLinkObject_GetLinkedObjects(sample.ObjectId);
        List<ObjectInfoLinked> compositions = sampleChildren.Where(x => x.TypeId == typeMA.TypeId).ToList();

        // 2 step. Having the Sample (from step 1) as a current object, find all Measurements Areas to deal with...
        for (int i = 0; i < values.Count; i++)
        {
            // every Predicate to find One Measurement Area Object
            dynamic maObject = await GetMeasurementAreaObjectByPredicate(sample.ObjectId, typeMA.TypeId, values[i].Predicate);

            // 3 step. update corresponding Measurement Area == deal with properties...
            rowsAffected += await Property_UpdateInsertBatch(values[i].Properties, created, userId, maObject.ObjectId, values[i]?.DeletePreviousProperties ?? false, sourceObjectId: obj.ObjectId);
        }

        return rowsAffected;
    }



    /// <summary>
    /// process composition from a single measurement area (specified by index)
    /// </summary>
    /// <param name="typeId_MeasurementArea">"Measurement Area" or "Composition" TypeId</param>
    /// <param name="index">zero-based index of measurement area</param>
    /// <param name="compositionValue">CompositionValue - composition (probably, with properties)</param>
    /// <param name="created">Date that should be specified in all possible cases on document creation</param>
    /// <param name="userId">user who is authorised to create objects</param>
    /// <param name="obj">Object (of EDX CSV type), that contains CSV-file, from which data is taken</param>
    /// <param name="rubricId">Rubric for Measurement Area Compounds</param>
    /// <returns>rowsAffected</returns>
    public async Task<int> Composition_UpdateInsert(int typeId_MeasurementArea, int index, CompositionValue compositionValue, DateTime created, int userId, ObjectInfo obj, int rubricId) {
        // find a composition ObjectId==SampleId by Property "Measurement Area" value (probably already in DB and we need to update it) and parent objectId
        string valMA = compositionValue.Properties.FirstOrDefault(p => p.PropertyName == "Measurement Area" && p.PropertyType == PropertyType.Int)?.Value?.ToString() ?? string.Empty;
        if (!int.TryParse(valMA, out int measurementArea) || measurementArea < 0) { // Felix starts MA with 0...
            throw new Exception("\"Measurement Area\" should be specified");
        }
        if (valMA.Length < 3) {
            valMA = new string('0', 3 - valMA.Length) + valMA;
        }
        int compositionObjectId = await FindEdxCompositionByMeasurementArea(typeId_MeasurementArea, obj.ObjectId, measurementArea);
        // if compositionObjectId==0 - create object; if compositionObjectId != 0 - update

        // Get Composition from CompositionValue and obj
        var comp = new Composition() {
            TenantId = TenantId,
            SampleId = compositionObjectId,
            TypeId = typeId_MeasurementArea,
            _created = created,
            _updated = created,
            _createdBy = userId,
            _updatedBy = userId,
            IsPublished = obj.IsPublished,
            AccessControl = obj.AccessControl,
            ObjectName = $"Measurement Area {valMA} from {obj.ObjectName}",
            RubricId = rubricId,
            SortCode = measurementArea,
            ExternalId = obj.ExternalId,
            ObjectDescription = $"Automatically created via import from file (MA {valMA})",
            Elements = string.Join('-', compositionValue.CompositionElements.Select(x => x.ElementName)) 
        };
        for (int i = 0; i < compositionValue.CompositionElements.Count; i++)
        {
            comp.CompositionItems.Add(new CompositionItem()
            {
                SampleId = compositionObjectId,
                CompoundIndex = compositionValue.CompositionElements[i].CompoundIndex,
                ElementName = compositionValue.CompositionElements[i].ElementName,
                ValueAbsolute = compositionValue.CompositionElements[i].ValueAbsolute ?? 0,
                ValuePercent = compositionValue.CompositionElements[i].ValuePercent
            });
        }

        // create / update Composition
        var compositionRet = await ObjectInfo_UpdateInsertVirtual<Composition>(comp);    // dbo.ObjectInfo_Composition_UpdateInsert => dbo.ObjectInfo_Sample_UpdateInsert => dbo.ObjectInfo_UpdateInsert

        // deal with properties for Composition
        int rowsAffected = compositionValue.CompositionElements.Count;
        rowsAffected += await Property_UpdateInsertBatch(compositionValue?.Properties, created, userId, compositionRet.ObjectId, compositionValue?.DeletePreviousProperties ?? false, sourceObjectId: obj.ObjectId);

        // add link to EDX
        int? linkTypeObjectIdToEdx = null;
        rowsAffected += await ObjectLinkObject_LinkAdd(obj.ObjectId, compositionRet.ObjectId, userId, SortCode: null, linkTypeObjectId: linkTypeObjectIdToEdx);  // EDX CSV => MA Composition

        // add link to sample(s) (should be upper links of EDX object)
        int? linkTypeObjectIdToSample = null;
        List<ObjectInfoLinked> upperEdxList = await ObjectLinkObject_GetLinkedObjects_Reverse(obj.ObjectId);    // upper objects full list
        for (int i = 0; i < upperEdxList.Count; i++)
        {
            int upperObjectId = upperEdxList[i].ObjectId;
            rowsAffected += await ObjectLinkObject_LinkAdd(upperObjectId, compositionRet.ObjectId, userId, SortCode: null, linkTypeObjectId: linkTypeObjectIdToSample);  // Sample => MA Composition
        }
        return rowsAffected;
    }




    /// <summary>
    /// Update properties for object objectId
    /// </summary>
    /// <param name="values">list of properties</param>
    /// <param name="created">Date for properties creation</param>
    /// <param name="userId">user who modifies data</param>
    /// <param name="objectId">parent object (to which data should be referred)</param>
    /// <param name="deletePreviousProperties">remove previous properties for the object _date < created ( = true by default)</param>
    /// <param name="sourceObjectId">object that is a source of data</param>
    /// <returns>rows affected</returns>
    public async Task<int> Property_UpdateInsertBatch(List<PropertyValue> values, DateTime created, int userId, int objectId, bool deletePreviousProperties, int sourceObjectId)
    {
        if (values == null)
            return 0;
        foreach (var value in values)
        {
            if (sourceObjectId > 0) {
                value.SourceObjectId = sourceObjectId;
            }
            int newPropertyId = await Property_UpdateInsert(value, created, userId, objectId);
        }
        if (deletePreviousProperties)
        {
            await Property_DeleteTableBefore(objectId, created);
            await Property_DeleteNonTableBefore(objectId, created);
        }
        return values.Count;
    }
}
