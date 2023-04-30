function v() {
    if [[ "$#" != 0 ]]; then
        nvim "$@";
        return
    fi
    nvim $(fzf --height 60% --reverse --preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window right:60%)
}

function cd() {
    if [[ "$#" != 0 ]]; then
        builtin cd "$@";
        return
    fi
    while true; do
        local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
        local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                ls -p --color=always "${__cd_path}";
        ')"
        [[ ${#dir} != 0 ]] || return 0
        builtin cd "$dir" &> /dev/null
    done
}

function jcurl {
    curl "$@" -so /dev/null  -w %{json} | jq '
    .calc_timing.dns_time_msec = (.time_namelookup*10000|floor/10)
    | .calc_timing.tcp_time_msec = ((.time_connect - .time_namelookup)*10000|floor/10)
    | if (.scheme == "HTTP") then .calc_timing.tls_time_msec = 0
        else .calc_timing.tls_time_msec = ((.time_appconnect - .time_connect)*10000|floor/10)
        end
    | if (.scheme == "HTTP") then .calc_timing.tcp_tls_msec = ((.time_connect - .time_namelookup)*10000|floor/10)
        else .calc_timing.tcp_tls_msec = ((.time_appconnect - .time_namelookup)*10000|floor/10)
        end
    | if (.scheme == "HTTP") then .calc_timing.internal_queue_msec = ((.time_pretransfer - .time_connect)*10000|floor/10)
        else .calc_timing.internal_queue_msec = ((.time_pretransfer - .time_appconnect)*10000|floor/10)
        end
    | .calc_timing.ttfb_msec = ((.time_starttransfer - .time_pretransfer)*10000|floor/10)
    | .calc_timing.download_msec = ((.time_total - .time_starttransfer)*10000|floor/10)
    | .calc_timing.bandwidth_kbps = (.speed_download*8)/1000
    '
}

function aws_ssm () {
        aws --profile "$2" ssm start-session --target "$(aws_instances "$1" "$2" | jq -r "nth($3; .[]) | .id")"
}

function aws_instances () {
        aws --profile "$2" --output json ec2 describe-instances --filter "Name=instance-state-name,Values=running" "Name=tag:Name,Values=*$1*" --query Reservations[].Instances[] | jq '.[] | {name: (.Tags[] | select(.Key == "Name") | .Value ), id: .InstanceId}' | jq -s '. |= sort_by(.name)'
}
