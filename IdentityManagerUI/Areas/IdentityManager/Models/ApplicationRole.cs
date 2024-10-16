using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityManagerUI.Models
{
    public class ApplicationRole : IdentityRole<int>
    {
        public ApplicationRole() { }

        public ApplicationRole(string roleName)
            : base(roleName) { }

        public virtual ICollection<ApplicationRoleClaim> Claims { get; set; }

        public virtual ICollection<ApplicationUserRole> Roles { get; set; }
    }
}
