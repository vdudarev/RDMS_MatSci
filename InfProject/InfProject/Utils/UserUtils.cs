using IdentityManagerUI.Models;
using Microsoft.AspNetCore.Identity;
using Newtonsoft.Json;
using System.Security;

namespace InfProject.Utils;

public class WebAppUser : ApplicationUser
{
    /// <summary>
    /// Name from a claim
    /// </summary>
    public string Name { get; set; } = null!;

    /// <summary>
    /// Project (could be a CSV of projects (if comma exists))
    /// </summary>
    public string Project { get; set; } = null!;

    /// <summary>
    /// normalised array of projects for a person (usually a single project is here, but could be more...)
    /// </summary>
    public string[] Projects { 
        get {
            if (string.IsNullOrEmpty(Project))
                return new string[0];
            string[] ret = Project.Split(", ", StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            return ret;
        }
    }

    public string NameOrEmail =>
        string.IsNullOrEmpty(Name) ? Email : Name;


    public override string ToString() => 
        string.IsNullOrEmpty(Project) ? $"{Name} [{Email}]" : $"{Project}) {Name} [{Email}]";

    /// <summary>
    /// True - user has NDA access; False - user has no NDA access (default)
    /// </summary>
    public bool NDA { get; set; }

    [JsonIgnore]
    public string ToJson => $"{{ 'id':{Id},  'name':'{Name}' }}";

    /// <summary>
    /// Used to cleanup security (e.g. before serialization)
    /// </summary>
    public void CleanUpSecurity() {
        NormalizedUserName = null;
        NormalizedEmail = null;
        PasswordHash = null;
        SecurityStamp = null;
        ConcurrencyStamp = null;
        PhoneNumber = null;
        LockoutEnd = null;
        AccessFailedCount = 0;
    }
}
