using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebUtilsLib
{
    public class LocalizationUtils
    {
        public static void SetCulture(string localeName = "en-US", string currencySymbol = "€")
        {
            var cultureInfo = new CultureInfo(localeName);
            cultureInfo.NumberFormat.CurrencySymbol = currencySymbol;

            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;
        }

        public static string? AdjustNumberString(string? value) {
            return value?.Replace(',', '.').Replace(" ", string.Empty);
        }
    }
}
