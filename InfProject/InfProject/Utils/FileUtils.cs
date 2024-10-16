using Microsoft.AspNetCore.StaticFiles;
using System.Collections.Generic;
using System.IO;

namespace InfProject.Utils;

// thanks to https://harrybellamy.com/posts/getting-mime-types-from-file-extensions-in-net-core/
public class FileUtils
{
    private readonly IConfiguration config;
    private readonly Dictionary<string, bool> fileExists = new Dictionary<string, bool>();

    public FileUtils(IConfiguration config)
    {
        this.config = config;
    }

    /// <summary>
    /// check relative file exists
    /// </summary>
    /// <param name="relFileName"></param>
    /// <returns></returns>
    public bool FileExists(string relFileName) {
        if (fileExists.ContainsKey(relFileName))
            return fileExists[relFileName];
        string absFileName = config.MapStorageFile(relFileName);
        bool exists = File.Exists(absFileName);
        fileExists.Add(relFileName, exists);
        return exists;
    }


    public bool FileExists(string directory, string fileName)
    {
        string relFileName = GetRelativeFileName(directory + '\\' + fileName);
        return FileExists(relFileName);
    }


    public static bool IsTiff(string fileName) { 
        string extension = Path.GetExtension(fileName).ToLower(); 
        return string.Compare(extension, ".tif") == 0 || string.Compare(extension, ".tif") == 0;
    }


    public static string GetMimeTypeForFileExtension(string filePath)
    {
        const string DefaultContentType = "application/octet-stream";

        var provider = new FileExtensionContentTypeProvider();

        if (!provider.TryGetContentType(filePath, out string? contentType))
        {
            contentType = DefaultContentType;
        }

        return contentType;
    }


    public static string GetRelativeFileName(string directory, string fileName)
    {
        return GetRelativeFileName(directory + '\\' + fileName);
    }

    /// <summary>
    /// get relative file path from db
    /// </summary>
    /// <param name="dbFilename">file path from DB (e.g. "\\wdm-sql01\EPC\Tresore\registriert\000009813_00.00_10531.opj")</param>
    /// <returns>relative file path to apeend to appSettings:PathToCompactFiles, e.g. \Tresore\registriert\000009813_00.00_10531.opj</returns>
    public static string GetRelativeFileName(string dbFilename)
    {
        dbFilename = dbFilename.Replace(@"\\wdm-sql01\EPC\", @"\");
        return dbFilename;
    }

    public static string GetExtensionWithoutDot(string filePath) {
        string extension = Path.GetExtension(filePath) ?? string.Empty; // first symbol is '.'
        return extension.Length>1 ? extension.Substring(1).ToLower() : string.Empty;
    }

    public static string GetFileTypeClass(string filePath)
    {
        return "filetype-" + GetExtensionWithoutDot(filePath);
    }

    public static string Version() {
        var fileName = System.Reflection.Assembly.GetExecutingAssembly().Location;
        FileInfo fi = new FileInfo(fileName);
        return fi.LastWriteTime.ToString("dd.MM.yyyy");
    }

}
