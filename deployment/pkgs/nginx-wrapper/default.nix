{stdenv, nginx}:
interDeps:

let
  stateDir = "/var/spool/nginx";
in
stdenv.mkDerivation {
  name = "nginx-wrapper";
  buildCommand = ''
    # Generate wrapper script
    
    mkdir -p $out/bin
    cat > $out/bin/wrapper <<EOF
    #! ${stdenv.shell} -e
    
    case "\$1" in
        activate)
            mkdir -p ${stateDir}/logs
            chmod 700 ${stateDir}
            chown -R nginx:nginx ${stateDir}
            
            ${nginx}/bin/nginx -c $out/etc/nginx.conf -p ${stateDir}
            ;;
    esac
    
    EOF
    chmod +x $out/bin/wrapper
    
    # Generate configuration file
    mkdir -p $out/etc
    cat > $out/etc/nginx.conf << "EOF"
    user nginx nginx;
    
    events {
      worker_connections 190000;
    }
    
    http {
      ${stdenv.lib.concatMapStrings (serviceName:
        ''
          upstream ${serviceName} {
            ip_hash;
            ${let
              service = builtins.getAttr serviceName interDeps;
              targets = service.targets;
            in
            stdenv.lib.concatMapStrings (target: "server ${target.properties.hostname}:${toString service.port};\n") targets}
          }
        ''
      ) (builtins.attrNames interDeps)}
      
      # Fallback virtual host displaying an error page. This is what users see
      # if they connect to a non-deployed web application.
      # Without it, nginx redirects to the first available virtual host, giving
      # unpredictable results. This could happen while an upgrade is in progress.
      
      server {
        listen 80;
        server_name aaaa;
        root ${./errorpage};
      }
      
      ${stdenv.lib.concatMapStrings (serviceName:
        let
          service = builtins.getAttr serviceName interDeps;
        in
        ''
          server {
            server_name ${service.dnsName};
            
            location / {
              proxy_pass    http://${serviceName};
            }
          }
        '') (builtins.attrNames interDeps)}
    }
    EOF
  '';
}
