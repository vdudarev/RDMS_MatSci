using Microsoft.EntityFrameworkCore;
using System.Text;

namespace TypeValidationLibrary
{
    /// <summary>
    /// resource from file or stream interface (new IContext added to specify, for example, chemical system for EDX data)
    /// </summary>
    public interface IResource : IContext
    {
        public Encoding Encoding { get; set; }
        public FileInfo? File { get; set; }
        public Stream? Stream { get; set; }
    }
}