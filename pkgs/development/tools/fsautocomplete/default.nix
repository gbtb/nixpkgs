{ buildDotnetModule, fsautocomplete, mkNugetDeps }:
let
in
buildDotnetModule rec {
  pname = "fsautocomplete";
  version = "0.58.2";
  src = ./.;
  nugetDeps = mkNugetDeps {
    name = pname;
    nugetDeps = { fetchNuGet }: [ (fetchNuGet { inherit pname version; sha256 = "sha256-xZFTxdD4ma5IlPZNqOSwJv/1ixicm21FY+WVS574QiI="; }) ];
  };
  dontConfigure = true;
  dontInstall = true;
  isDotnetTool = true;
  executables = ".dotnet/tools/${pname}";
  #makeWrapperArgs=[ "--set DOTNET_CLI_HOME $out/lib/${pname}"];
  fixupPhase = ''
    echo Hello
    echo ''${makeWrapperArgs[@]}
    runHook preFixup
    echo ''${makeWrapperArgs[@]}
    runHook postFixup
  '';
  buildPhase = ''
    export NUGET_PACKAGES=${fsautocomplete.passthru.nuget-source}/lib
   # Generate a NuGet.config file to make sure everything,
    # including things like <Sdk /> dependencies, is restored from the proper source
cat <<EOF > "./NuGet.config"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nugetSource" value="${fsautocomplete.passthru.nuget-source}/lib" />
  </packageSources>
</configuration>
EOF
    export DOTNET_CLI_HOME=$out/lib/${pname}
    dotnet tool install --configfile ./NuGet.config --global fsautocomplete --version ${version} 
  '';
}
