tmux  new-window -d -c './scripts/live-test.sh' \; split-window -h \; -c './scripts/live-build.sh' \; attach