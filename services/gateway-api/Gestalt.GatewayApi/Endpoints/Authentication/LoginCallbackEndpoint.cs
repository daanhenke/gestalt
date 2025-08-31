using FastEndpoints;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;

namespace Gestalt.GatewayApi.Endpoints.Authentication;

[HttpGet("/auth/callback"), AllowAnonymous]
public class LoginCallbackEndpoint : EndpointWithoutRequest
{
  public override async Task HandleAsync(CancellationToken ct)
  {
    var provider  = Query<string>("provider")!;
    var returnUrl = Query<string>("returnUrl", false) ?? "/";

    var result = await HttpContext.AuthenticateAsync("external");
    if (! result.Succeeded)
    {
      return;
    }


  }
}
