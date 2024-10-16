using System.Data;
using WebUtilsLib;
using static WebUtilsLib.DBUtils;

namespace TypeValidationLibrary
{
    public interface IDatabaseValuesGetter : IResource
    {
        DatabaseValues GetDatabaseValues();
    }
}