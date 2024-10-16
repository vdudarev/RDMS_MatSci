namespace WebUtilsLib
{ 
    /// <summary>
    /// настройки почтовой компоненты
    /// https://mail.ruhr-uni-bochum.de/mail/faq/allgemeine_e-mail_konfiguration
    /// </summary>
    public class SmtpConfiguration
    {
        public string Host { get; set; } = "localhost";
        public int Port { get; set; } = 25;

        public string FromName { get; set; } = string.Empty;
        public string FromEmail { get; set; } = "noreply@wdm.ruhr-uni-bochum.de";

        public bool UseSSL { get; set; } = false;
        public string? CredentialsUserName { get; set; }
        public string? CredentialsPassword { get; set; }
        public string? CredentialsDomain { get; set; }
    }
}
