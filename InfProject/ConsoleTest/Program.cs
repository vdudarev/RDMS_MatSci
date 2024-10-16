using System.IO;
using System.Reflection.Metadata;
using System.Text;
using TypeValidationLibrary;

string dirPath = @"C:\RUB\!WORK\COMPACT\chem. composition\_ALL";
DirectoryInfo dir = new DirectoryInfo(dirPath);

DateTime dt1 = DateTime.Now, dt2;
IFileValidator validator = new TypeValidator_EDX_CSV();
ITableGetter tableGetter = (ITableGetter)validator;
var files = dir.GetFiles();
var ok = 0;
var failExtension = 0;
var fail = 0;
int rows, containsCoordinatesCount=0;
bool containsCoordinates;
StringBuilder sb = new StringBuilder();
StringBuilder sbCsv = new StringBuilder();
sbCsv.AppendLine($"N;FileName;Rows;ContainsCoordinates;Code;Message");


for (var i = 0; i < files.Length; i++)
{
    FileInfo file = files[i];
    //Console.WriteLine(file.Name);
    validator.File = new FileInfo(file.FullName);
    var res = validator.Validate();
    //rows = tableGetter.DataTable?.Rows.Count ?? 0;
    //containsCoordinates = tableGetter.GetCoordinates;
    Table table = tableGetter.GetTable();
    rows = table?.DataTable?.Rows.Count ?? 0;
    containsCoordinates = table?.Coordinates ?? false;
    containsCoordinatesCount += containsCoordinates ? 1 : 0;
    if (res)
    {
        ok++;
    }
    else
    {
        if (res.Code == 1)
            failExtension++;
        else
            fail++;
    }
    sb.AppendLine($"{i + 1}) {file.Name} {res}");
    sbCsv.AppendLine($"{i + 1};{file.Name};{rows};{(containsCoordinates ? 1 : 0)};{res.Code};{res}");
}

dt2 = DateTime.Now;
sb.AppendLine($"=== TOTAL({ok+fail+failExtension}): ok={ok}, fail={fail}; failExtension={failExtension} === ContainsCoordinatesCount: {containsCoordinatesCount}. Completed in {(dt2-dt1).TotalMilliseconds} ms");
Console.WriteLine(sb.ToString());

File.WriteAllText("report.csv", sbCsv.ToString());   
