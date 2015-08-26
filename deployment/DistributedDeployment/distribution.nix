{infrastructure}:

let
  inherit (builtins) listToAttrs attrNames getAttr;
in
{
  webapp1 = [ infrastructure.test1 ];
  webapp2 = [ infrastructure.test1 ];
  webapp3 = [ infrastructure.test2 ];
  webapp4 = [ infrastructure.test2 ];
} //

# To each target, distribute a reverse proxy

listToAttrs (map (targetName: {
  name = "nginx-wrapper-${targetName}";
  value = [ (getAttr targetName infrastructure) ];
}) (attrNames infrastructure))
