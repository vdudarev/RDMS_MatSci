using IdentityManagerUI.Models;
using Microsoft.AspNetCore.Authentication.Google;
using Microsoft.AspNetCore.Identity;

namespace InfProject.Utils;

public class StartUpUsers
{
    public static async Task CreateRolesAndUsers(IServiceProvider serviceProvider, string email, string password)
    {
        var roleManager = serviceProvider.GetRequiredService<RoleManager<ApplicationRole>>();
        var userManager = serviceProvider.GetRequiredService<UserManager<ApplicationUser>>();

        // first we create Admin role
        await CreateRole(roleManager, "Administrator");

        var poweruser = await userManager.FindByEmailAsync(email);
        if (poweruser == null)
        {
            poweruser = new ApplicationUser() { UserName = email, Email = email, EmailConfirmed = true };
            var createPowerUser = await userManager.CreateAsync(poweruser, password);
            if (createPowerUser.Succeeded)
            {
                // here we tie the new user to the role
                await userManager.AddToRoleAsync(poweruser, "Administrator");
            }
            else
            {
                foreach (var item in createPowerUser.Errors)
                {
                    Console.WriteLine(item);
                }
            }
        }

        // creating Creating PowerUser role     
        await CreateRole(roleManager, "PowerUser");

        // creating Creating User role
        await CreateRole(roleManager, "User");
    }

    public static async Task CreateRole(RoleManager<ApplicationRole> roleManager, string roleName)
    {
        bool x = await roleManager.RoleExistsAsync(roleName);
        if (x)
            return;
        var role = new ApplicationRole() { Name = roleName };
        await roleManager.CreateAsync(role);
    }

    // https://www.scottbrady91.com/aspnet-identity/identity-manager-using-aspnet-identity
    // https://github.com/mguinness/IdentityManagerUI => https://github.com/GSGBen/IdentityManagerUI-NetCore6-Template
}
