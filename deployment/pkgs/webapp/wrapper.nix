{stdenv, webapp}:
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
}
