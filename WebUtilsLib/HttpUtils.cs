using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace WebUtilsLib
{
    public class HttpUtils
    {
        // public static Action<string> Log { get; set; }


        public static async Task<string> GetStringByHttpGet(string url)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;

            using (HttpWebResponse response = (HttpWebResponse)await request.GetResponseAsync())
            using (Stream stream = response.GetResponseStream())
            using (StreamReader reader = new StreamReader(stream))
            {
                return await reader.ReadToEndAsync();
            }
        }


        public static async Task<string> GetStringByHttpPost(string url, byte[] dataBytes, string contentType = "application/octet-stream" /*"application/x-www-form-urlencoded"*/)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;
            request.ContentLength = dataBytes.Length;
            request.ContentType = contentType;
            request.Method = "POST";

            using (Stream requestBody = request.GetRequestStream())
            {
                await requestBody.WriteAsync(dataBytes, 0, dataBytes.Length);
            }
            string ret = null;
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (Stream stream = response.GetResponseStream())
            using (StreamReader reader = new StreamReader(stream))
            {
                ret = await reader.ReadToEndAsync();
            }
            // Log?.Invoke($"GetStringByHttpPost to {url} with {dataBytes.Length} bytes returned:\r\n{ret}");
            return ret;
        }



        public static async Task<T> GetDataThroughWebService<T>(string postUrl, string filePath)
        {
            byte[] dataBytes = await File.ReadAllBytesAsync(filePath);
            return await _GetDataThroughWebService<T>(postUrl, dataBytes);
        }



        public static async Task<T> GetDataThroughWebService<T>(string postUrl, Stream inputStream)
        {
            byte[] dataBytes = new byte[inputStream.Length];
            await inputStream.ReadAsync(dataBytes);
            return await _GetDataThroughWebService<T>(postUrl, dataBytes);
        }

        private static async Task<T> _GetDataThroughWebService<T>(string postUrl, byte[] dataBytes)
        {
            string jsonData = await GetStringByHttpPost(postUrl, dataBytes);
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            T res = JsonSerializer.Deserialize<T>(jsonData, options);
            return res;
        }
    }
}
