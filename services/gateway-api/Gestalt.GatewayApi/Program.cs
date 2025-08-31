using System.Buffers.Text;
using FastEndpoints;
using FastEndpoints.Swagger;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

var authenticationBuilder = builder.Services.AddAuthentication(o =>
{
  o.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
  o.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
});

authenticationBuilder.AddJwtBearer(o =>
{
  o.TokenValidationParameters = new TokenValidationParameters()
  {
    ValidateIssuer = true,
    ValidIssuer = "gateway-api",
    ValidateAudience = true,
    ValidAudience = "gestalt-app",
    IssuerSigningKey = new SymmetricSecurityKey(Convert.FromBase64String("sQIGKQr+DQeyF5bBkn5NiU75LB2OHa4mAZK6Frhr3Ns="))
  };
});

authenticationBuilder.AddCookie("external", o =>
{
  o.LoginPath = "/api/v1/auth/login";
  o.ExpireTimeSpan = TimeSpan.FromMinutes(30);
  o.SlidingExpiration = true;
});

authenticationBuilder.AddDiscord("discord", o =>
{
  o.ClientId = "1411828052480098335";
  o.ClientSecret = "kEoOMeE43930xSxE8XW_ljNi0E3rA8_a";
  o.SignInScheme = "external";
  o.SaveTokens = true;
  o.Scope.Add("email");
  o.Scope.Add("identify");
});

builder.Services.AddAuthorization();

builder.Services.AddFastEndpoints()
  .SwaggerDocument(o =>
  {
    o.DocumentSettings = s => s.DocumentName = "v1";
  });

var app = builder.Build();

app.UseAuthorization();
app.UseAuthentication();

app.UseFastEndpoints(c =>
  {
    c.Endpoints.RoutePrefix = "api/v1";
  })
  .UseSwaggerGen();

await app.RunAsync();
