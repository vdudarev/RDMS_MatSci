// TypeInfo.ValidationSchema = type:TypeValidationLibrary.TypeValidator_Ok
namespace TypeValidationLibrary
{
    /// <summary>
    /// Test Validator for Ok
    /// </summary>
    public class TypeValidator_Ok : TypeValidatorBase
    {
        /// <summary>
        /// Type-specific logic
        /// </summary>
        /// <returns></returns>
        protected override TypeValidatorResult ValidateSpecific() {
            return new TypeValidatorResult();   // basic checks + success
        }
    }
}