using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.Intrinsics.X86;
using System.Text.Json;
using System.Threading.Tasks;

namespace ASP.NET_Core_Empty.Line
{

    public class Login
    {
        private readonly string _clientId;
        private readonly string _clientSecret;
        private readonly string _redirectUri;

        public Login(string clientId, string clientSecret, string redirectUri)
        {
            _clientId = clientId;
            _clientSecret = clientSecret;
            _redirectUri = redirectUri;
        }

        public object LineLoginService { get => lineLoginService; set => lineLoginService = value; }
        public object LineLoginService1 { get => lineLoginService; set => lineLoginService = value; }

        public async Task<string> GetAccessToken(string code)
        {
            // Construct the request URL
            var requestUrl = $"https://api.line.me/oauth2/v2.1/token" +
                $"?grant_type=authorization_code" +
                $"&code={code}" +
                $"&redirect_uri={_redirectUri}" +
                $"&client_id={_clientId}" +
                $"&client_secret={_clientSecret}";

            // Create an HTTP client
            using var client = new HttpClient();

            // Set the content type
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/x-www-form-urlencoded"));

            // Send the request
            var response = await client.PostAsync(requestUrl, null);

            // Check for success
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"Error obtaining access token: {response.StatusCode}");
            }

            // Read the response content
            var responseContent = await response.Content.ReadAsStringAsync();

            // Deserialize the response
            var accessTokenResponse = JsonSerializer.Deserialize<AccessTokenResponse>(responseContent);

            // Return the access token
            return accessTokenResponse.AccessToken;
        }
    }

    public class AccessTokenResponse
    {
        public string AccessToken { get; set; }
        public string TokenType { get; set; }
        public int ExpiresIn { get; set; }
        public string RefreshToken { get; set; }
        public string Scope { get; set; }
    }

}