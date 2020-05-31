# start ssh connection for the player.
socat -d -d tcp-l:1778,bind=127.0.0.1,reuseaddr,fork exec:"ssh nix",pty,setsid,stderr,login,ctty &
