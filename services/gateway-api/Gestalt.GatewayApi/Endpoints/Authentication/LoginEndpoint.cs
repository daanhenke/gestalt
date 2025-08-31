using FastEndpoints;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;

namespace Gestalt.GatewayApi.Endpoints.Authentication;

[HttpGet("/auth/login/{provider}"), AllowAnonymous]
public class LoginEndpoint : EndpointWithoutRequest
{
  private string[] _supportedProviders = ["google", "discord"];

  public override async Task HandleAsync(CancellationToken ct)
  {
    var provider = Route<string>("provider");
    if (!_supportedProviders.Contains(provider))
    {
      throw new BadHttpRequestException("Provider not found");
    }
    var returnUrl = Query<string>("returnUrl", false) ?? "/";

    var props = new AuthenticationProperties
    {
      RedirectUri = $"/api/v1/auth/callback?returnUrl={Uri.EscapeDataString(returnUrl)}&provider={provider}",
    };

    await HttpContext.ChallengeAsync(provider, props);
  }
}
