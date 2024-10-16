using System.Data;
using System.Text;
using System.Text.RegularExpressions;

namespace WebUtilsLib
{
    public static class StringUtils
    {
        /// <summary>
        /// Replaces all non-ASCII characters by accripriate \\u0000
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static string ConverToASCIIonly(this string source) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < source.Length; i++)
            {
                if (source[i] < ' ' || source[i] >= 127)
                {
                    string s = BitConverter.ToString(Encoding.BigEndianUnicode.GetBytes(source, i, 1)).Replace("-", string.Empty);
                    s = s.PadLeft(4, '0');
                    sb.Append("\\u").Append(s);
                }
                else
                    sb.Append(source[i]);
            }
            return sb.ToString();
        }

        /// <summary>
        /// delete Html tags
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static string DeleteHtmlTags(this string input) {
            if (string.IsNullOrEmpty(input))
                return string.Empty;
            return Regex.Replace(input, "<.*?>", string.Empty);
        }

        /// <summary>
        /// Check email for validity
        /// </summary>
        /// <param name="email"></param>
        /// <returns></returns>
        public static bool IsValidEmail(string email)
        {
            try
            {
                System.Net.Mail.MailAddress addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch { }
            return false;
        }

        public static string Left(string st, int MaxLen)
        {
            if (string.IsNullOrEmpty(st))
                return string.Empty;
            if (st.Length > MaxLen)
                st = st.Substring(0, MaxLen);
            return st;
        }

        public static string Right(string st, int Len)
        {
            if (string.IsNullOrEmpty(st))
                return string.Empty;
            if (st.Length > Len)
                st = st.Substring(st.Length - Len, Len);
            return st;
        }

        /// <summary>
        /// Get Extension without dot
        /// </summary>
        /// <param name="fileName">file name</param>
        /// <returns>Extension without dot</returns>
        public static string GetExtensionNoDot(string fileName)
        {
            string ext = Path.GetExtension(fileName);
            if (!string.IsNullOrEmpty(ext))
                ext = ext.Substring(1);
            return ext;
        }
    }
}
