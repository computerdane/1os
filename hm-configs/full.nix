{ ... }:

{
  oneos = {
    development.enable = true;
    gaming.enable = true;
    media.enable = true;
    social.enable = true;
  };
  programs.shell-gpt = {
    enable = true;
    settings = {
      API_BASE_URL = "https://llm.nf6.sh";
      DEFAULT_MODEL = "gemini-1.5-flash";
    };
  };
}
