using ASP.NET_Core_Empty.Line;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

var lineLoginService = new Login("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET", "YOUR_REDIRECT_URI");
string code = Request.Query["code"];
string accessToken = await lineLoginService.GetAccessToken(code);

app.Run();