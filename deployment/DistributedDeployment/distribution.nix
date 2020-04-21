{infrastructure}:

let
  inherit (builtins) listToAttrs attrNames getAttr removeAttrs;
  productionTargets = removeAttrs infrastructure [ "client" ]; # Do not distribute a proxy to the test client
in
{
  webapp1 = [ infrastructure.test1 ];
  webapp2 = [ infrastructure.test1 ];
  webapp3 = [ infrastructure.test2 ];
  webapp4 = [ infrastructure.test2 ];
} //

# To each target (except the test client machine), distribute a reverse proxy

listToAttrs (map (targetName: {
  name = "nginx-reverse-proxy-${targetName}";
  value = [ (getAttr targetName infrastructure) ];
}) (attrNames productionTargets))
