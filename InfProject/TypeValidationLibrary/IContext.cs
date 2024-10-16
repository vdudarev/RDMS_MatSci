namespace TypeValidationLibrary
{


    /// <summary>
    /// Interface that provides access to the Context
    /// </summary>
    public interface IContext {
        /// <summary>
        /// Context, that defines validation and data upload context
        /// </summary>
        public Context Context { 
            get => new Context();
            set { } 
        }

        /// <summary>
        /// Default Set Context Implementation
        /// </summary>
        /// <param name="dict">key-value dictionary</param>
        //public void SetContext(Dictionary<string, string> dict) { }
    }
}