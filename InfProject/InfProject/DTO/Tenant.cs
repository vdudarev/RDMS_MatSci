using WebUtilsLib;

namespace InfProject.DTO;

public class Tenant
{
    /// <summary>
    /// Id - base unit for administration
    /// </summary>
    public int TenantId { get; set; }

    /// <summary>
    /// modification date
    /// </summary>
    public DateTime _date { get; set; } = new DateTime(2000, 1, 1);

    /// <summary>
    /// User Interface Lamngusge
    /// </summary>
    public string? Language { get; set; }

    /// <summary>
    /// Tenant domain name (without https://)
    /// </summary>
    public string TenantUrl { get; set; } = null!;

    /// <summary>
    /// Unique tenant name
    /// </summary>
    public string TenantName { get; set; } = null!;

    /// <summary>
    /// Default AccessControl for newly created objects
    /// </summary>
    public AccessControl AccessControl { get; set; }

    public override string ToString() => $"{TenantName} [{TenantUrl}, Id={TenantId}, AccessControl={AccessControl}]";
}
