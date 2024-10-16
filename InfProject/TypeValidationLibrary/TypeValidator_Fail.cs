// TypeInfo.ValidationSchema = type:TypeValidationLibrary.TypeValidator_Fail
namespace TypeValidationLibrary
{
    /// <summary>
    /// Test Validator for FAIL
    /// </summary>
    public class TypeValidator_Fail : TypeValidatorBase
    {

        /// <summary>
        /// Type-specific logic
        /// </summary>
        /// <returns></returns>
        protected override TypeValidatorResult ValidateSpecific() {
            return new TypeValidatorResult() { Code = 500, Message = "always fail from TypeValidator_Fail" };
        }
    }
}