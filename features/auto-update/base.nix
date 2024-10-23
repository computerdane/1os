{
  name,
  path,
  script,
  startAt,
}:

{
  systemd.services.${name} = {
    inherit path script startAt;
    environment.GIT_SSH_COMMAND = "ssh -i /home/dane/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new";
    serviceConfig = {
      Type = "oneshot";
      RuntimeDirectory = name;
    };
  };
}
