using System.Text;

namespace TypeValidationLibrary
{
    /// <summary>
    /// base class
    /// </summary>
    public interface IFileValidator : IResource
    {
        /// <summary>
        /// event to extend functionality BEFORE validation
        /// </summary>
        public event EventHandler<IResource> BeforeValidation;

        /// <summary>
        /// event to extend functionality AFTER validation
        /// </summary>
        public event EventHandler<TypeValidatorResult> AfterValidation;



        /// <summary>
        /// Validate (file or stream) defined via IResource
        /// </summary>
        /// <returns></returns>
        public TypeValidatorResult Validate();


        /// <summary>
        /// List of allowed extensions
        /// </summary>
        public List<string> AllowedExtensions { get; set; }
    }
}