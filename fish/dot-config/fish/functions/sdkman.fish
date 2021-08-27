function sdkman
    __sdkman_run_in_bash "source /home/viargentum/.sdkman/bin/sdkman-init.sh && sdk $argv"
    echo
end

function __sdkman_run_in_bash
    set pipe (mktemp)
    bash -c "$argv[1];
             echo -e \"\$?\" > $pipe;
             env | grep -e '^SDKMAN_\|^PATH' >> $pipe;
             env | grep -i -E \"^(`echo \${SDKMAN_CANDIDATES_CSV} | sed 's/,/|/g'`)_HOME\" >> $pipe;
             echo \"SDKMAN_OFFLINE_MODE=\${SDKMAN_OFFLINE_MODE}\" >> $pipe" # it's not an environment variable!
    set bashDump (cat $pipe; rm $pipe)

    set sdkStatus $bashDump[1]
    set bashEnv $bashDump[2..-1]

    if [ $sdkStatus = 0 ]
        for line in $bashEnv
            set parts (string split "=" $line)
            set var $parts[1]
            set value (string join "=" $parts[2..-1])

            switch "$var"
            case "PATH"
                set value (string split : "$value")
            end

            if test -n value
                set -gx $var $value
            end
        end
    end

    return $sdkStatus
end
