{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.oneos.dns-update;

  safeServerName = builtins.replaceStrings [ "." ] [ "-" ];
  safeRecordName = record: builtins.replaceStrings [ "." ] [ "-" ] "${record.name}-${record.type}";

  isDynamic = record: record.dynamic != null;

  mkAcmeEnvName = serverName: "acme-env-${safeServerName serverName}";
  mkAcmeEnvPath = serverName: "/run/${mkAcmeEnvName serverName}";

  mkAcmeEnvScript =
    serverName: serverCfg:
    pkgs.writeScript "${mkAcmeEnvName serverName}" ''
      #!/bin/sh
      KEY_LINE=$(cat ${serverCfg.keyFile})
      ALGO=$(echo "$KEY_LINE" | ${pkgs.coreutils}/bin/cut -d: -f1)
      KEY_NAME=$(echo "$KEY_LINE" | ${pkgs.coreutils}/bin/cut -d: -f2)
      SECRET=$(echo "$KEY_LINE" | ${pkgs.coreutils}/bin/cut -d: -f3)
      ${pkgs.coreutils}/bin/cat > ${mkAcmeEnvPath serverName} <<ENVEOF
      RFC2136_NAMESERVER=${serverCfg.address}
      RFC2136_TSIG_ALGORITHM=$ALGO
      RFC2136_TSIG_KEY=$KEY_NAME
      RFC2136_TSIG_SECRET=$SECRET
      ENVEOF
    '';

  mkUpdateScript =
    serverCfg: record:
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
      ${pkgs.knot-dns}/bin/knsupdate -k ${serverCfg.keyFile} <<EOF
      server ${serverCfg.address}
      zone ${record.zone}
      update delete ${record.name}. ${record.type}
      update add ${record.name}. ${toString record.ttl} ${record.type} $RECORD_DATA
      send
      EOF
    '';

  recordSubmodule = lib.types.submodule {
    options = {
      zone = lib.mkOption {
        description = "DNS zone to update (e.g. example.com). Defaults to the server-level zone if set.";
        type = lib.types.nullOr lib.types.str;
        default = null;
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

  serverSubmodule = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        address = lib.mkOption {
          description = "IP address or hostname of the authoritative DNS server. Defaults to the attribute name.";
          type = lib.types.str;
          default = name;
        };

        zone = lib.mkOption {
          description = "Default DNS zone for records on this server.";
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        keyFile = lib.mkOption {
          description = ''
            Path to file containing the TSIG key in CLI format:
            hmac-sha256:keyname:base64secret
          '';
          type = lib.types.path;
        };

        acme = lib.mkOption {
          description = "List of domains to obtain ACME/Let's Encrypt certificates for via DNS-01 challenge.";
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        acmeEmail = lib.mkOption {
          description = "Email address for ACME account registration. Defaults to admin@{zone}.";
          type = lib.types.str;
          default =
            if config.zone != null then
              "admin@${config.zone}"
            else
              throw "dns-update: server '${name}' has acme domains but no zone set. Set a server-level zone or set acmeEmail explicitly.";
        };

        records = lib.mkOption {
          description = "List of DNS records to maintain on this server.";
          type = lib.types.listOf recordSubmodule;
          default = [ ];
        };
      };
    }
  );

  resolveZone =
    serverCfg: record:
    let
      zone =
        if record.zone != null then
          record.zone
        else if serverCfg.zone != null then
          serverCfg.zone
        else
          throw "dns-update: record '${record.name}' (${record.type}) has no zone set, and its server has no default zone. Set zone on the record or on the server.";
    in
    record // { inherit zone; };

  # Flatten all servers into a list of { serverName, serverCfg, record } for generating units
  allRecords = lib.concatLists (
    lib.mapAttrsToList (
      serverName: serverCfg:
      map (record: {
        inherit serverName serverCfg;
        record = resolveZone serverCfg record;
      }) serverCfg.records
    ) cfg.servers
  );

  acmeServers = lib.filterAttrs (_: serverCfg: serverCfg.acme != [ ]) cfg.servers;

  mkServiceName =
    serverName: record: "dns-update-${safeServerName serverName}-${safeRecordName record}";
in
{
  options.oneos.dns-update = {
    enable = lib.mkEnableOption "dynamic DNS record updates via TSIG";

    servers = lib.mkOption {
      description = "Per-nameserver DNS update configuration.";
      type = lib.types.attrsOf serverSubmodule;
      default = { };
    };

    serviceNames = lib.mkOption {
      description = "Generated systemd service names for each record.";
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      default = map (entry: mkServiceName entry.serverName entry.record) allRecords;
    };
  };

  config = lib.mkIf (cfg.enable && allRecords != [ ]) (
    lib.mkMerge [
      {
        systemd.services = builtins.listToAttrs (
          map (
            {
              serverName,
              serverCfg,
              record,
            }:
            {
              name = mkServiceName serverName record;
              value = {
                description = "Update DNS ${record.type} record for ${record.name} on ${serverName}";
                after = [ "network-online.target" ];
                wants = [ "network-online.target" ];
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = mkUpdateScript serverCfg record;
                };
              };
            }
          ) allRecords
        );

        systemd.timers = builtins.listToAttrs (
          map (
            {
              serverName,
              record,
              ...
            }:
            {
              name = mkServiceName serverName record;
              value = {
                description = "Periodically update dynamic DNS ${record.type} record for ${record.name} on ${serverName}";
                wantedBy = [ "timers.target" ];
                timerConfig = {
                  OnCalendar = record.refreshInterval;
                  Persistent = true;
                };
              };
            }
          ) (builtins.filter (entry: isDynamic entry.record) allRecords)
        );
      }

      (lib.mkIf (acmeServers != { }) {
        systemd.services = lib.mkMerge (
          lib.mapAttrsToList (
            serverName: serverCfg:
            let
              envName = mkAcmeEnvName serverName;
              envService = {
                ${envName} = {
                  description = "Generate ACME environment file for ${serverName}";
                  after = [ "network-online.target" ];
                  wants = [ "network-online.target" ];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                    ExecStart = mkAcmeEnvScript serverName serverCfg;
                  };
                };
              };
              acmeDeps = builtins.listToAttrs (
                map (domain: {
                  name = "acme-${domain}";
                  value = {
                    requires = [ "${envName}.service" ];
                    after = [ "${envName}.service" ];
                  };
                }) serverCfg.acme
              );
            in
            envService // acmeDeps
          ) acmeServers
        );

        security.acme.certs = lib.mkMerge (
          lib.mapAttrsToList (
            serverName: serverCfg:
            builtins.listToAttrs (
              map (domain: {
                name = domain;
                value = {
                  inherit domain;
                  email = serverCfg.acmeEmail;
                  dnsProvider = "rfc2136";
                  environmentFile = mkAcmeEnvPath serverName;
                };
              }) serverCfg.acme
            )
          ) acmeServers
        );
      })
    ]
  );
}
