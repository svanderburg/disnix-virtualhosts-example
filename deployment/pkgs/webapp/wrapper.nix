{createManagedProcess, webapp}:
{port, instanceSuffix ? "", instanceName ? "webapp${instanceSuffix}"}:

let
  user = instanceName;
  group = instanceName;
in
createManagedProcess {
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
