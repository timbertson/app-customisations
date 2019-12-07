rec {
	home = builtins.getEnv "HOME";
	loadSessionVars = "eval \"$(/${home}/.bin/session-vars --all --process gnome-session --export)\"";
}
