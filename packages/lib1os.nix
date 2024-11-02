{ lib }:

with lib;

{
  genDomains =
    subdomains: domains:
    lists.flatten (map (subdomain: (map (domain: "${subdomain}.${domain}") domains)) subdomains);
}
