# vim: set ft=sh:

CWD=`pwd`
NAME=`basename $CWD`

tmux has-session -t $NAME
if [ $? != 0 ] ; then
    tmux new-session -s $NAME -n editor -d

    #tmux set-environment -t $NAME <name> <value>

    tmux send-keys -t $NAME:1 'vim' C-m

    tmux new-window -n phoenix -t $NAME
    tmux send-keys -t $NAME:2 'mix phoenix.server' C-m

    tmux new-window -n postgres -t $NAME
    tmux send-keys -t $NAME:3 'postgres -D db' C-m

    tmux select-window -t $NAME:1
fi

tmux attach -t $NAME
