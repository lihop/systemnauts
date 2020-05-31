# start a bash shell for running commands.
socat -d -d tcp-l:1747,bind=127.0.0.1,reuseaddr,fork exec:bash,pty,setsid,stderr,login,ctty &

# start inotifywait for monitoring a directory.
socat -d -d tcp-l:1746,bind=127.0.0.1,reuseaddr,fork exec:"$(which inotifywait) -q -m /home/leroy/tmp/test/",pty,setsid,stderr,login,ctty &

# start a bash shell for the player.
socat -d -d tcp-l:1748,bind=127.0.0.1,reuseaddr,fork exec:bash,pty,setsid,stderr,login,ctty &

# start ssh connection for the player.
socat -d -d tcp-l:1778,bind=127.0.0.1,reuseaddr,fork exec:"ssh nix",pty,setsid,stderr,login,ctty &
