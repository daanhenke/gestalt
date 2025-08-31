using FastEndpoints;
using Microsoft.AspNetCore.Authorization;

namespace Gestalt.GatewayApi.Endpoints;

public record ContextResponse(
  string Alias
);

[HttpGet("context"), AllowAnonymous]
public class GetContextEndpoint : Endpoint<EmptyRequest, ContextResponse>
{
  public override Task<ContextResponse> ExecuteAsync(EmptyRequest req, CancellationToken ct)
  {
    return Task.FromResult<ContextResponse>(new("ey"));
  }
}
