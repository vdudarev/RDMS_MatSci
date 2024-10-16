// See https://aka.ms/new-console-template for more information
using InfProject.Controllers;
using InfProject.DBContext;
using System.Text;

List<int> objectIds = new List<int>();
StringBuilder err = new StringBuilder();
//string[] args = Environment.GetCommandLineArgs();
if (args.Length < 3) {
    Console.WriteLine("USAGE: *.exe [storageRoot] [connectionString] [hostname]");
    return;
}
string storageRoot = args[0];
string connectionString = args[1];
string hostname = args[2];
Console.WriteLine($@"storageRoot: {storageRoot}
connectionString: {connectionString}
hostname: {hostname}
");
DataContext dataContext = new DataContext(connectionString, hostname);

await SrvController.RecalculateFileHashMain(false, dataContext, s => storageRoot + s.Replace('/', '\\'), (string s) => {
    int i1 = s.IndexOf("[ObjectId=");
    int i2 = s.IndexOf(',', i1>0 ? i1 : 0);
    if (i1 > 0 && i2 > i1) {
        s = s.Substring(i1+10, i2-i1-10);
        int.TryParse(s, out i2);
        objectIds.Add(i2);
    }
    err.AppendLine(s); 
}, Console.WriteLine);
Console.WriteLine("=== Done! ===");
Console.WriteLine("ERRORS: ");
Console.WriteLine(err.ToString());
Console.WriteLine("=== objectIds ===");
Console.WriteLine(string.Join(", ", objectIds));
