using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebUtilsLib;

public enum AccessControl
{
    None = -1,      // AdminMode
    Public = 0,
    Protected = 1,
    ProtectedNDA = 2,   // Industry(NDA)==PrivateProtected
    Private = 3
}
