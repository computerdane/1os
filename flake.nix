{
  outputs =
    { ... }:
    {
      templates.new-project = {
        path = ./templates/new-project;
        description = "starter for new projects";
      };
    };
}
