{ lib }:

with lib;
with types;

{
  genDomains =
    subdomains: domains:
    flatten (map (subdomain: (map (domain: "${subdomain}.${domain}") domains)) subdomains);

  ip =
    let
      prependQuartetCollapsingZeros =
        quartet: addressEnd:
        if quartet == "0" then
          if substring 0 1 addressEnd == ":" then
            addressEnd
          else
            (if addressEnd == "" then "::" else ":") + addressEnd
        else
          quartet + ":" + addressEnd;

      removeLastCharacter = str: substring 0 ((stringLength str) - 1) str;

      replaceLastElements = a: b: (take ((length a) - (length b)) a) ++ b;

      zeroFillIpv6Quartets = quartets: (quartets ++ (replicate (8 - (length quartets)) "0"));

      toIpv4Address = octets: concatStringsSep "." (map toString octets);
      toIpv6Address = quartets: removeLastCharacter (foldr prependQuartetCollapsingZeros "" quartets);
      toCidr = address: prefixLength: "${address}/${toString prefixLength}";
    in
    rec {
      toIpv4 =
        ipv4OrOctets: prefixLength:
        let
          octets = if builtins.typeOf ipv4OrOctets == "set" then ipv4OrOctets.octets else ipv4OrOctets;
        in
        rec {
          inherit octets prefixLength;
          address = toIpv4Address octets;
          cidr = toCidr address prefixLength;
        };

      fromIpv4Cidr =
        cidr:
        let
          tokens = splitString "/" cidr;
        in
        toIpv4 (map toInt (splitString "." (elemAt tokens 0))) (toInt (elemAt tokens 1));

      pickIpv4 =
        ipv4: octetOrOctets:
        let
          octets = if builtins.typeOf octetOrOctets == "int" then [ octetOrOctets ] else octetOrOctets;
        in
        (toIpv4 (replaceLastElements ipv4.octets octets) ipv4.prefixLength);

      toIpv6 =
        ipv6OrQuartets: prefixLength:
        let
          quartets = zeroFillIpv6Quartets (
            if builtins.typeOf ipv6OrQuartets == "set" then ipv6OrQuartets.quartets else ipv6OrQuartets
          );
        in
        rec {
          inherit quartets prefixLength;
          address = toIpv6Address quartets;
          cidr = toCidr address prefixLength;
        };

      fromIpv6Cidr =
        cidr:
        let
          tokens = splitString "/" cidr;
        in
        toIpv6 (remove "" (splitString ":" (elemAt tokens 0))) (elemAt tokens 1);

      pickIpv6 =
        ipv6: quartetOrQuartets:
        let
          quartets =
            if builtins.typeOf quartetOrQuartets == "string" then [ quartetOrQuartets ] else quartetOrQuartets;
        in
        (toIpv6 (replaceLastElements ipv6.quartets quartets) ipv6.prefixLength);
    };
}
