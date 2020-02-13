# template-bash

## `bash`

- .bash_aliases
- .bash_history
- .bash_logout
- .bashrc


```bash
# append in ~/.bashrc
eval HOME="~"
bash_aliases_dir="${HOME}/template-bash/config/bash_aliases"
if [ -d "${bash_aliases_dir}" ] ; then
    source ${bash_aliases_dir}/psql.sh
    source ${bash_aliases_dir}/sf.sh
    source ${bash_aliases_dir}/ubuntu.sh
else
    echo >2 "directory does not exist: ${bash_aliases_dir}"
fi
# . ~/.bashrc
```

- __psql.sh__
    - `psql_restart`
    - `psql_start`
    - `psql_status`
    - `psql_stop`
    - `psql_su`
- __sf.sh__
    - `sf`
    - `sf_serve`
- __ubuntu.sh__
    - `ubuntu_upgrade`

## References

- [bash:tip_colors_and_formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)
- [Termination Signals - GNU C library](https://www.gnu.org/software/libc/manual/html_node/Termination-Signals.html)
- https://doc.ubuntu-fr.org/alias