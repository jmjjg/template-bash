#!/usr/bin/env bash

__db_pg_su_exec__()
{
    sudo sudo -u postgres psql --no-align --tuples-only --variable=ON_ERROR_STOP=1 --quiet --command="${1}"
    return "${?}"
}

alias db_pg_restart='sudo service postgresql restart'
alias db_pg_start='sudo service postgresql start'
#alias db_pg_status='sudo service postgresql status'
alias db_pg_stop='sudo service postgresql stop'
alias db_pg_su_exec=__db_pg_su_exec__
