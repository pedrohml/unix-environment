# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
function ggrepo() {
	git grep $1 ${@:2} | grep -o -e $1
}

# git branch
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
function apagabranch() {
	git push origin :$1
	git branch -D $1
	echo git branch -D $1
}
# Helper function to get regress ports
function genport() {
	echo $(expr \( $(id -u) - \( $(id -u) / 100 \) \* 100 \) \* 200 + 20000 + ${1})
}
function trans() {
	trans_port=$(genport 5)
	printf "cmd:$(echo "$@" | tr ' ' '\n' | tr '\#' ' ')\ncommit:1\nend\n---\n"
	printf "cmd:$(echo "$@" | tr ' ' '\n' | tr '\#' ' ')\ncommit:1\nend\n" | nc localhost ${trans_port}
}
function get_ip(){
	ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | head -1
}
function bdb_cmd(){
	echo "$(make -C $HOME/bomnegocio rinfo 2>/dev/null| grep -e '^psql' |tr ';' ' ')"
}
function generate_dev_token(){
	curl -X POST -d "username=dev&cpasswd=&login=Login" -k https://dev03c6.srv.office:23811/controlpanel
	last_dev_token
}
function last_dev_token(){
	$(bdb_cmd) -tc 'select token from tokens where admin_id=9999 order by created_at desc limit 1' | tr -d '\n '
}
function last_ad(){
	$(bdb_cmd) -tc 'select ad_id from ads order by ad_id desc limit 1' | tr -d '\n '
}
function last_unreview_ad(){
	$(bdb_cmd) -tc "select ad_id from ad_actions where state in ('pending_review', 'locked') order by ad_id desc limit 1" | tr -d '\n '
}
function review_ad(){
	ad_id=$1
	last_action_id=$($(bdb_cmd) -tc 'select action_id from ad_actions where ad_id='$ad_id' order by action_id desc limit 1' | tr -d '\n ')
	token=$(generate_dev_token)
	trans review token:$token ad_id:$ad_id action_id:$last_action_id remote_addr:$(get_ip) action:accept filter_name:accepted
}
function review_last_ad(){
	if [[ $(last_unreview_ad | wc -c) > 0 ]]; then
	  review_ad $(last_unreview_ad)
	else
	  echo "WARNING: There is not ad in the pending review queue"
	fi
}
function testtrans(){
	if [ -n "$1" ]; then
		DISPLAY=:$(id -u) BROWSER=firefox bundle exec rspec -e "Legacy Trans Tests $1"
	else
		rake test $(find spec/transactions/ -type f)
	fi
}
function testapi(){
	if [ -n "$1" ]; then
		DISPLAY=:$(id -u) BROWSER=firefox bundle exec rspec -e "Legacy API Tests $1"
	else
		rake firefox test $(find spec/api/ -type f)
	fi
}

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

source ~/.git-prompt.sh

PS1="\[$Green\]\t\[$Red\]-\[$Cyan\]\u\[$Yellow\]\[$Yellow\]\w\[\033[m\]\[$Magenta\]\$(__git_ps1)\[$White\]\$ "

complete -C ~/.rake_completion.rb -o default rake

alias bdb='$(bdb_cmd)'
alias bdbstage='psql -h 172.16.1.59 -U postgres blocketdb'
alias redis_account='$(make rinfo | grep "redis accounts server" | perl -pe "s/ - redis accounts server//g")'
alias redis_linkmanager='$(make rinfo | grep "redis link manager server" | perl -F"\s+-\s+" -nale "print @F[0]")'
alias redis_paymentapi='$(make rinfo | grep "redis payment api server" | perl -F"\s+-\s+" -nale "print @F[0]")'
alias redis_mobile='$(make rinfo | grep "redismobile server" | perl -F"\s+-\s+" -nale "print @F[0]")'
alias redis_fav='$(make rinfo | grep "redis favorites server" | perl -F"\s+-\s+" -nale "print @F[0]")'
alias flushdb='echo flushdb | redis_account'
alias makesfa='make -C ~/bomnegocio rc kill cleandir++ && ~/bomnegocio/compile.sh && make -C ~/bomnegocio rall'
alias gerastage='make -C ~/bomnegocio rc kill && make -C ~/bomnegocio cleandir++ && rm -rf rpm/{ia32e,noarch} && make -C ~/bomnegocio rpm-staging'
alias liga_xiti='trans bconf_overwrite key:*.*.common.stat_counter.xiti.display value:1 && make apache-regress-restart'
alias pega="git fetch origin; git pull --rebase origin \$(parse_git_branch)"
alias manda="git push origin \$(parse_git_branch)"
alias desfaztudo="git reset --hard origin/\$(parse_git_branch)"

export PAGER="less"
export PSQL_EDITOR='vim +"set syntax=sql" '
export GREP_OPTIONS='--color=auto'

alias joia='token=$(trans authenticate username:dev passwd:da39a3ee5e6b4b0d3255bfef95601890afd80709 remote_addr:127.0.0.1 | grep token) && trans nb_tool_copy_from_production remote_addr:127.0.0.1 $token'
alias superjoia='make rall && bdb < release.txt && > regress_final/logs/trans.log && joia'
alias joiainvbconf='token=$(trans authenticate username:dev passwd:da39a3ee5e6b4b0d3255bfef95601890afd80709 remote_addr:127.0.0.1 | grep token) && trans nb_tool_copy_to_bconf_production deploy_id:1 remote_addr:127.0.0.1 $token'
alias joiainvdb='token=$(trans authenticate username:dev passwd:da39a3ee5e6b4b0d3255bfef95601890afd80709 remote_addr:127.0.0.1 | grep token) && trans nb_tool_copy_to_database_production deploy_id:1 remote_addr:127.0.0.1 $token'

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
