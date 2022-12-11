{ dotnet-sdk
, stdenvNoCC
, fetchnuget
, mkNugetSource
}:
{ name, version, hash }:
let 
  _nugetDeps = fetchnuget { inherit name version; };
in
stdenvNoCC.mkDerivation rec {
  inherit name version;
  nativeBuildInputs = [ dotnet-sdk ];
  dependenciesSource = mkNugetSource {
    name = "${name}-dependencies-source";
    description = "A Nuget source with the dependencies for ${name}";
    deps = [ _nugetDeps ];
  };


  buildPhase = ''
    export NUGET_PACKAGES=${dependenciesSource}
    dotnet tool install --global ${name}
  '';

}
