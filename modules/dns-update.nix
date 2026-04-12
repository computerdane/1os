{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.dns-update;

  safeRecordName = record: builtins.replaceStrings [ "." ] [ "-" ] "${record.name}-${record.type}";

  recordSubmodule = lib.types.submodule {
    options = {
      zone = lib.mkOption {
        description = "DNS zone to update (e.g. example.com).";
        type = lib.types.str;
      };

      name = lib.mkOption {
        description = "Record name (e.g. myhost.example.com).";
        type = lib.types.str;
      };

      type = lib.mkOption {
        description = "DNS record type (e.g. A, AAAA, CNAME, TXT, MX, SRV).";
        type = lib.types.str;
      };

      data = lib.mkOption {
        description = "Record data (e.g. an IP address, hostname, or quoted TXT string).";
        type = lib.types.str;
      };

      ttl = lib.mkOption {
        description = "TTL in seconds.";
        type = lib.types.int;
        default = 3600;
      };
    };
  };
in
{
  options.oneos.dns-update = {
    enable = lib.mkEnableOption "dynamic DNS record updates via TSIG";

    server = lib.mkOption {
      description = "IP address or hostname of the authoritative DNS server.";
      type = lib.types.str;
    };

    keyFile = lib.mkOption {
      description = ''
        Path to file containing the TSIG key in CLI format:
        hmac-sha256:keyname:base64secret
      '';
      type = lib.types.path;
    };

    records = lib.mkOption {
      description = "List of DNS records to maintain.";
      type = lib.types.listOf recordSubmodule;
      default = [ ];
    };

    serviceNames = lib.mkOption {
      description = "Generated systemd service names for each record.";
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = map (record: "dns-update-${safeRecordName record}") cfg.records;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.records != [ ]) {
    systemd.services = builtins.listToAttrs (
      map (
        record:
        let
          safeName = safeRecordName record;
          updateScript = pkgs.writeScript "dns-update-${safeName}" ''
            #!/bin/sh
            ${pkgs.knot-dns}/bin/knsupdate -k ${cfg.keyFile} <<EOF
            server ${cfg.server}
            zone ${record.zone}
            update delete ${record.name}. ${record.type}
            update add ${record.name}. ${record.ttl} ${record.type} ${record.data}
            send
            EOF
          '';
        in
        {
          name = "dns-update-${safeName}";
          value = {
            description = "Update DNS ${record.type} record for ${record.name}";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = updateScript;
            };
          };
        }
      ) cfg.records
    );
  };
}
