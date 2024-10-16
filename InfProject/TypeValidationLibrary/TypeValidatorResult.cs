using System.Runtime.InteropServices;
using System.Runtime.Serialization;

namespace TypeValidationLibrary
{
    /// <summary>
    /// validation operation result
    /// </summary>
    public class TypeValidatorResult
    {
        /// <summary>
        /// 0 - validation successful; !=0 - fail
        /// </summary>
        public int Code { get; set; }
        /// <summary>
        /// if code!=0 then Message must contain text message describing error
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// if code==0 then Warning could contain warning message (hacks to make work as good as possible)
        /// </summary>
        public string? Warning { get; set; }

        public TypeValidatorResult() { }
        public TypeValidatorResult(int code, string message, string? warning=null)
        {
            Code = code;
            Message = message;
            Warning = warning;
        }

        public override string ToString() 
            => Code == 0 ? 
                $"ok {Warning}".TrimEnd() : 
                $"fail {Code}: {Message}" + (string.IsNullOrEmpty(Warning) ? "" : $" // {Warning}");

        public static implicit operator bool(TypeValidatorResult obj) 
            => obj.Code == 0;
    }
}