{ ... }:
{
  programs.taskwarrior = {
    enable = true;
    colorTheme = "light-256";

    # https://taskwarrior.org/docs/urgency.html
    config = {
      urgency.user.tag.home.coefficient = 2.0;
      urgency.user.tag.bak.coefficient = 2.0;
      urgency.user.tag.idea.coefficient = -15.0;

      news.version = "2.6.0";
    };
  };
}
