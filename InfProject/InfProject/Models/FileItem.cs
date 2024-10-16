using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Xml.Linq;
using System;
using System.IO;
using InfProject.Utils;
using System.Reflection.Metadata;

namespace InfProject.Models;

public class FileItem
{
    public int ObjectId { get; set; }
    public int TypeId { get; set; }
    public string RelativeFilePath { get; set; } = null!;

    /// <summary>
    /// create FileItem class to represent external data
    /// </summary>
    /// <param name="objectId">ObjectId</param>
    /// <param name="typeId">TypeId</param>
    /// <param name="relFilePath">relative file path</param>
    /// <param name="enableAnalysis">enable time-consuming analysis (external validation, CSV outcome, etc...)</param>
    public FileItem(int objectId, int typeId, string relFilePath, bool enableAnalysis=false) {
        ObjectId = objectId;
        TypeId = typeId;
        RelativeFilePath = relFilePath;
        EnableAnalysis = enableAnalysis;
    }

    public string MimeType => FileUtils.GetMimeTypeForFileExtension(Path.GetExtension(RelativeFilePath));

    public bool IsImage => MimeType.StartsWith("image/");
    public static bool IsImageFile(string relFilePath) => FileUtils.GetMimeTypeForFileExtension(Path.GetExtension(relFilePath)).StartsWith("image/");

    /// <summary>
    /// false - default - no validation / analysis (time consuming)
    /// true - enable time-consuming analysis (external validation, CSV outcome, etc...)
    /// </summary>
    public bool EnableAnalysis { get; set; }
}
