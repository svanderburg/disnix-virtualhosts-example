{
  ports = {
    webapp1 = 3001;
    webapp2 = 3002;
    webapp3 = 3003;
    webapp4 = 3004;
  };
  portConfiguration = {
    globalConfig = {
      lastPort = 3004;
      minPort = 3000;
      maxPort = 4000;
      servicesToPorts = {
        webapp1 = 3001;
        webapp2 = 3002;
        webapp3 = 3003;
        webapp4 = 3004;
      };
    };
    targetConfigs = {
    };
  };
}
