using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace WebUtilsLib
{
    public class HashUtils
    {
        public static string? GetHash(string filePathFull) {
            using (SHA256 sha256 = SHA256.Create()) {
                return CalculateHash(sha256, filePathFull);
            }
        }

        public static string? CalculateHash(SHA256 sha256, string filePathFull)
        {
            string? retVal = null;
            if (!File.Exists(filePathFull))
                return retVal;
            using (FileStream fileStream = File.OpenRead(filePathFull))
            {
                retVal = BitConverter.ToString(sha256.ComputeHash(fileStream)).Replace("-", string.Empty) ?? string.Empty;
            }
            return retVal;
        }

    }
}
