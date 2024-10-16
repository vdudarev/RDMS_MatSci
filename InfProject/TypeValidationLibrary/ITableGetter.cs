namespace TypeValidationLibrary
{
    /// <summary>
    /// Interface to extract table data
    /// </summary>
    public interface ITableGetter : IResource
    {
        /// <summary>
        /// Gets Table
        /// </summary>
        public Table GetTable();


        ///// <summary>
        ///// Main validation method for file
        ///// </summary>
        ///// <param name="filePath"></param>
        ///// <returns></returns>
        //[Obsolete("Use GetTable() method", true)]
        //public Table? GetDataTableFile(string filePath);


        ///// <summary>
        ///// Main validation method for stream
        ///// </summary>
        ///// <param name="inputStream"></param>
        ///// <returns></returns>
        //[Obsolete("Use GetTable() method", true)]
        //public Table? GetDataTableStream(Stream inputStream);
    }
}