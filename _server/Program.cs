var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var fileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.GetFullPath(Path.Combine(builder.Environment.ContentRootPath, "..")));

var options = new StaticFileOptions
{
    FileProvider = fileProvider,
    RequestPath = "",
    ServeUnknownFileTypes = true,
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Cross-Origin-Opener-Policy", "same-origin");
        ctx.Context.Response.Headers.Append("Cross-Origin-Embedder-Policy", "require-corp");

        var headers = ctx.Context.Response.GetTypedHeaders();
        if (headers.ContentType?.MediaType.ToString().StartsWith("text/") == true ||
            headers.ContentType?.MediaType == "application/javascript" ||
            headers.ContentType?.MediaType == "application/json")
        {
             headers.ContentType.Charset = "utf-8";
        }
    }
};

app.UseStaticFiles(options);

app.MapGet("/", async context =>
{
    context.Response.Redirect("/CodingGamePrototype.html");
    await Task.CompletedTask;
});

app.MapGet("/favicon.ico", async context =>
{
    context.Response.ContentType = "image/png";
    await context.Response.SendFileAsync(Path.Combine(fileProvider.Root, "CodingGamePrototype.icon.png"));
});

Console.WriteLine($"Server running locally. Serving files from: {fileProvider.Root}");

app.Run();
