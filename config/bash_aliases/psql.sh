#!/usr/bin/env bash

__psql_su__()
{
    sudo sudo -u postgres psql --no-align --tuples-only --variable=ON_ERROR_STOP=1 --quiet --command="${1}"
    return "${?}"
}

alias psql_restart='sudo service postgresql restart'
alias psql_start='sudo service postgresql start'
alias psql_status='sudo service postgresql status'
alias psql_stop='sudo service postgresql stop'
alias psql_su=__psql_su__
