using System.Text;

namespace TypeValidationLibrary
{
    /// <summary>
    /// base class
    /// </summary>
    public abstract class TypeValidatorBase : IFileValidator
    {
        public static readonly string[] elements = { "Ac", "Ag", "Al", "Am", "Ar", "As", "At", "Au", "B", "Ba", "Be", "Bh", "Bi", "Bk", "Br", "C", "Ca", "Cd", "Ce", "Cf", "Cl", "Cm", "Cn", "Co", "Cr", "Cs", "Cu", "Db", "Ds", "Dy", "Er", "Es", "Eu", "F", "Fe", "Fl", "Fm", "Fr", "Ga", "Gd", "Ge", "H", "He", "Hf", "Hg", "Ho", "Hs", "I", "In", "Ir", "K", "Kr", "La", "Li", "Lr", "Lu", "Lv", "Mc", "Md", "Mg", "Mn", "Mo", "Mt", "N", "Na", "Nb", "Nd", "Ne", "Nh", "Ni", "No", "Np", "O", "Og", "Os", "P", "Pa", "Pb", "Pd", "Pm", "Po", "Pr", "Pt", "Pu", "Ra", "Rb", "Re", "Rf", "Rg", "Rh", "Rn", "Ru", "S", "Sb", "Sc", "Se", "Sg", "Si", "Sm", "Sn", "Sr", "Ta", "Tb", "Tc", "Te", "Th", "Ti", "Tl", "Tm", "Ts", "U", "V", "W", "Xe", "Y", "Yb", "Zn", "Zr" };
        protected int version;

        /// <summary>
        /// for IFileValidator
        /// </summary>
        public Encoding Encoding { get; set; } = Encoding.UTF8;

        private FileInfo? _File;
        /// <summary>
        /// for IFileValidator
        /// </summary>
        public FileInfo? File { 
            get => _File; 
            set {
                if (_File?.FullName != value?.FullName) 
                {
                    _File = value;
                    if (value != null && !string.IsNullOrEmpty(value?.FullName)) {
                        _Stream = null;
                    }
                    version++;
                }
            }
        }

        private Stream? _Stream;
        /// <summary>
        /// for IFileValidator
        /// </summary>
        public Stream? Stream {
            get => _Stream;
            set
            {
                if (_Stream != value)
                {
                    _Stream = value;
                    if (value != null) {
                        _File = null;
                    }
                    version++;
                }
            }
        }


        /// <summary>
        /// List of allowed extension
        /// </summary>
        public List<string> AllowedExtensions { get; set; } = new List<string>();


        /// <summary>
        /// string splitter to List<string>
        /// </summary>
        /// <param name="input">input string with extensions list</param>
        /// <param name="separator">"|" by default</param>
        /// <returns>List<string></returns>
        public static List<string> GetListFromString(string input, string separator = "|") {
            string[] res = input.Split(separator, StringSplitOptions.TrimEntries);
            return res.ToList();
        }


        /// <summary>
        /// List of disallowed extension
        /// </summary>
        public List<string> DisallowedExtensions { get; set; } = new List<string>();


        protected virtual TypeValidatorResult CheckExtensions() {
            string? ext = File?.Extension;
            if (ext!=null && DisallowedExtensions.Contains(ext))
                return new TypeValidatorResult(1, $"Disallowed Extension: {ext}");
            if (ext != null && AllowedExtensions.Count>0 && !AllowedExtensions.Contains(ext, new StringIEqualityComparer()))
                return new TypeValidatorResult(1, $"Allowed Extensions list does not include: {ext}");
            return new TypeValidatorResult();
        }

        /// <summary>
        /// event to extend functionality BEFORE validation
        /// for IFileValidator
        /// </summary>
        public event EventHandler<IResource>? BeforeValidation;

        /// <summary>
        /// event to extend functionality AFTER validation
        /// for IFileValidator
        /// </summary>
        public event EventHandler<TypeValidatorResult>? AfterValidation;

        protected TypeValidatorResult BasicValidation() {
            if (File!=null && !File.Exists)
            {
                return new TypeValidatorResult(404, "file not found");
            }

            TypeValidatorResult res = CheckExtensions();
            return res;
        }

        /// <summary>
        /// method to redefine for inherited class
        /// </summary>
        /// <returns></returns>
        protected abstract TypeValidatorResult ValidateSpecific();
        
        protected virtual void InitValidation() { }


        protected TypeValidatorResult CoreValidate() {
            InitValidation();

            BeforeValidation?.Invoke(this, this);

            TypeValidatorResult res = BasicValidation();
            if (!res)
            {
                return res;
            }

            res = ValidateSpecific();

            AfterValidation?.Invoke(this, res);
            return res;
        }

        /// <summary>
        /// Main validation method for files
        /// for IFileValidator
        /// </summary>
        /// <returns></returns>
        public virtual TypeValidatorResult Validate() 
        {
            TypeValidatorResult res = null!;
            try
            {
                res = CoreValidate();
            }
            catch (Exception ex)
            {
                res = new TypeValidatorResult(500, ex.Message, ex.StackTrace);
            }
            return res;
        }

        /// <summary>
        /// Wrapper to validate file
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public TypeValidatorResult ValidateFile(string path)
        {
            File = new FileInfo(path);
            return Validate();
        }

        /// <summary>
        /// Wrapper to validate stream
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        public TypeValidatorResult ValidateStream(Stream data)
        {
            Stream = data;
            return Validate();
        }
    }
}