FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["services/gateway-api/Gestalt.GatewayApi/Gestalt.GatewayApi.csproj", "services/gateway-api/Gestalt.GatewayApi/"]
RUN dotnet restore "services/gateway-api/Gestalt.GatewayApi/Gestalt.GatewayApi.csproj"
COPY . .
WORKDIR "/src/services/gateway-api/Gestalt.GatewayApi"
RUN dotnet build "./Gestalt.GatewayApi.csproj" -c $BUILD_CONFIGURATION -o /native/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Gestalt.GatewayApi.csproj" -c $BUILD_CONFIGURATION -o /native/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Gestalt.GatewayApi.dll"]
