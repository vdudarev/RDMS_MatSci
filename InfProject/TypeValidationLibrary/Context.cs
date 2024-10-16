namespace TypeValidationLibrary
{
    /// <summary>
    /// Context for adding Data (it could affect data from file in IResource)
    /// Actually: all "parent" objects in database should contribute to the context with all their data to make it full (but so far for real use case we need only ObjectId OR chemical system)
    /// </summary>
    public class Context {
        ///// <summary>
        ///// ObjectId for which data is being uploaded (pointer to the "parent" sample object)
        ///// </summary>
        //public int ObjectId
        //{   // auto-implement for reverse compatibility
        //    get => 0;
        //    set { }
        //}

        /// <summary>
        /// Dictionary with properties, that define context
        /// </summary>
        public Dictionary<string, string> Dictionary {
            // auto-implement for reverse compatibility
            get => new Dictionary<string, string>();
            set { }
        }

        /// <summary>
        /// Chemical system (in context of which we upload data set)
        /// </summary>
        public string[] ChemicalSystem
        {   // auto-implement for reverse compatibility
            get => TypeValidatorBase.elements; // all elements are present; new string[0]; // 
            set { }     // ignore
        }

        /// <summary>
        /// Version of the Context (0 - default stub, non-zero - something is implemented)
        /// </summary>
        public int Version {
            get => 0;
            set { }
        }
    }
}