using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Diagnostics.CodeAnalysis;
using Dapper;
using FluentValidation;
using InfProject.Utils;
using Newtonsoft.Json;

namespace InfProject.Models;

/// <summary>
/// parser for property Comment field
/// </summary>
public class PropertyComment
{
    private readonly string comment;
    private readonly string userComment = string.Empty;
    private readonly string serviceInformation = string.Empty;
    
    /// <summary>
    /// constructor: initilizes PropertyComment class by a comment string
    /// </summary>
    /// <param name="comment"></param>
    public PropertyComment(string comment)
    {
        this.comment = comment;
        int i = comment?.IndexOf("--//") ?? -1;
        if (i >= 0)
        {
            userComment = comment.Substring(0, i).Trim();
            serviceInformation = comment.Substring(i + 4);
        }
        else {
            userComment = comment;
        }
    }
    public string UserComment => userComment;
    public string ServiceInformation => serviceInformation;

    public bool IsRequired => serviceInformation.Contains("required");

    public override string ToString() => UserComment;
}
