{
  test1 = import ../configurations/test-vm.nix;
  test2 = import ../configurations/test-vm.nix;
  client = import ../configurations/test-vm3-client.nix;
}
