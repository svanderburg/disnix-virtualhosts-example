{services, infrastructure, initialDistribution, previousDistribution, filters}:

let
  inherit (builtins) listToAttrs attrNames getAttr removeAttrs;
  productionTargets = removeAttrs infrastructure [ "client" ]; # Do not distribute a proxy to the test client
in
filters.divide {
  strategy = "greedy";
  distribution = initialDistribution;
  serviceProperty = "weight";
  targetProperty = "capacity";
  inherit services infrastructure;
}

//

# To each target (except the test client machine), distribute a reverse proxy

listToAttrs (map (targetName: {
  name = "nginx-wrapper-${targetName}";
  value = [ targetName ];
}) (attrNames productionTargets))
