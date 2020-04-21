/*{stdenv, webapp}:
{port, name}:

stdenv.mkDerivation {
  name = "${name}-wrapper";
  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/run-webapp <<EOF
    #! ${stdenv.shell} -e

    # Configure the port number
    export PORT=${toString port}

    # Run the web application process
    ${webapp}/bin/webapp
    EOF
    chmod +x $out/bin/run-webapp
  '';
}*/

{createManagedProcess, webapp}:
{port, instanceSuffix ? ""}:

let
  instanceName = "webapp${instanceSuffix}";
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
      "${instanceName}" = {};
    };
    users = {
      "${instanceName}" = {
        group = instanceName;
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
