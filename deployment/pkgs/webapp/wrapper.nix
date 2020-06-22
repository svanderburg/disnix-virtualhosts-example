{createManagedProcess, webapp}:
{port, instanceSuffix ? ""}:

let
  instanceName = "webapp${instanceSuffix}";
  user = instanceName;
  group = instanceName;
in
createManagedProcess {
  name = instanceName;
  inherit instanceName;
  description = "Simple Node.js web application";
  foregroundProcess = "${webapp}/lib/node_modules/webapp/app.js";
  environment = {
    PORT = port;
  };
  user = instanceName;

  credentials = {
    groups = {
      "${group}" = {};
    };
    users = {
      "${user}" = {
        inherit group;
        description = "Webapp";
      };
    };
  };

  overrides = {
    sysvinit = {
      runlevels = [ 3 4 5 ];
    };
  };
}
