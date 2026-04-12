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
        description = "Record data (e.g. an IP address, hostname, or quoted TXT string). Ignored when dynamic is set.";
        type = lib.types.str;
        default = "";
      };

      ttl = lib.mkOption {
        description = "TTL in seconds.";
        type = lib.types.int;
        default = 3600;
      };

      dynamic = lib.mkOption {
        description = "Automatically detect the public IP. Set to \"ipv4\" or \"ipv6\" to enable.";
        type = lib.types.nullOr (
          lib.types.enum [
            "ipv4"
            "ipv6"
          ]
        );
        default = null;
      };

      refreshInterval = lib.mkOption {
        description = "How often to re-check and update dynamic records (systemd calendar spec).";
        type = lib.types.str;
        default = "*:0/5";
      };
    };
  };

  isDynamic = record: record.dynamic != null;

  mkUpdateScript =
    record:
    let
      safeName = safeRecordName record;
      dynamicPreamble =
        if record.dynamic == "ipv4" then
          ''
            RECORD_DATA=$(${pkgs.curl}/bin/curl -4 -sf https://icanhazip.com | ${pkgs.coreutils}/bin/tr -d '[:space:]')
            if [ -z "$RECORD_DATA" ]; then
              echo "Failed to detect public IPv4 address" >&2
              exit 1
            fi
          ''
        else if record.dynamic == "ipv6" then
          ''
            RECORD_DATA=$(${pkgs.curl}/bin/curl -6 -sf https://icanhazip.com | ${pkgs.coreutils}/bin/tr -d '[:space:]')
            if [ -z "$RECORD_DATA" ]; then
              echo "Failed to detect public IPv6 address" >&2
              exit 1
            fi
          ''
        else
          ''
            RECORD_DATA='${record.data}'
          '';
    in
    pkgs.writeScript "dns-update-${safeName}" ''
      #!/bin/sh
      ${dynamicPreamble}
      ${pkgs.knot-dns}/bin/knsupdate -k ${cfg.keyFile} <<EOF
      server ${cfg.server}
      zone ${record.zone}
      update delete ${record.name}. ${record.type}
      update add ${record.name}. ${toString record.ttl} ${record.type} $RECORD_DATA
      send
      EOF
    '';
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
          updateScript = mkUpdateScript record;
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

    systemd.timers = builtins.listToAttrs (
      map (
        record:
        let
          safeName = safeRecordName record;
        in
        {
          name = "dns-update-${safeName}";
          value = {
            description = "Periodically update dynamic DNS ${record.type} record for ${record.name}";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = record.refreshInterval;
              Persistent = true;
            };
          };
        }
      ) (builtins.filter isDynamic cfg.records)
    );
  };
}
