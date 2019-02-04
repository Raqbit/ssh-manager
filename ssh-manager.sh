#!/bin/bash
#########################################
# Original script by Errol Byrd
# Copyright (c) 2010, Errol Byrd <errolbyrd@gmail.com>
#########################################
# Modified by Robin Parisi
# Contact at parisi.robin@gmail.com
# Github https://github.com/robinparisi/ssh-manager
# github.io Page https://robinparisi.github.io/ssh-manager/
#
# Modified by Raqbit
# Github https://github.com/Raqbit/ssh-manager

#================== Globals ==================================================

# Version
VERSION="0.6"

# Configuration
HOST_FILE="$HOME/.ssh_servers"
DATA_DELIM=":"
DATA_ALIAS=1
DATA_HUSER=2
DATA_HADDR=3
DATA_HPORT=4
PING_DEFAULT_TTL=20
SSH_DEFAULT_PORT=22

#================== Functions ================================================

function exec_ping() {
	case $(uname) in 
		MINGW*)
			ping -n 1 -i $PING_DEFAULT_TTL $@
			;;
		*)
			ping -c1 -t$PING_DEFAULT_TTL $@
			;;
	esac
}

function test_host() {
	exec_ping $* > /dev/null
	if [ $? != 0 ] ; then
		echo -n "["
		cecho -n -red "KO"
		echo -n "]"
	else
		echo -n "["
		cecho -n -green "UP"
		echo -n "]"
	fi 
}

function separator() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function print_error() {
	cecho -red "$1"
}

function list_commands() {
	separator
	echo -e "Available commands"
	separator
	echo -e "<alias> [username]\t\t\tconnect to server"
	echo -e "connect\t<alias>\t[username]\t\tconnect to server"
	echo -e "add\t<alias>:<user>:<host>:[port]\tadd new server"
	echo -e "delete\t<alias>\t\t\t\tdelete server"
	echo -e "export\t\t\t\t\texport config"
}

function probe ()
{
	als=$1
	grep -w -e $als $HOST_FILE > /dev/null
	return $?
}

function get_raw ()
{
	als=$1
	grep -w -e $als $HOST_FILE 2> /dev/null
}

function get_addr ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HADDR' }'
}

function get_port ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HPORT'}'
}

function get_user ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HUSER' }'
}
function server_add() {
	alias=$1
	echo $alias
	probe "$alias"
	if [ $? -eq 0 ]; then
		as	print_error "Alias '$alias' is in use"
	else
		echo "$alias$DATA_DELIM$user" >> $HOST_FILE
		cecho -green "New alias '$alias' added"
	fi
}

function cecho() {
	while [ "$1" ]; do
		case "$1" in 
			-normal)        color="\033[00m" ;;
			-black)         color="\033[30;01m" ;;
			-red)           color="\033[31;01m" ;;
			-green)         color="\033[32;01m" ;;
			-yellow)        color="\033[33;01m" ;;
			-blue)          color="\033[34;01m" ;;
			-magenta)       color="\033[35;01m" ;;
			-cyan)          color="\033[36;01m" ;;
			-white)         color="\033[37;01m" ;;
			-n)             one_line=1;   shift ; continue ;;
			*)              echo -n "$1"; shift ; continue ;;
		esac
	shift
	echo -en "$color"
	echo -en "$1"
	echo -en "\033[00m"
	shift
done
if [ ! $one_line ]; then
	echo
fi
}

function connect() {
	alias=$1
	user=$2
	probe "$alias"
	if [ $? -eq 0 ]; then
		if [ "$user" == ""  ]; then
			user=$(get_user "$alias")
		fi
		addr=$(get_addr "$alias")
		port=$(get_port "$alias")
		# Use default port when parameter is missing
		if [ "$port" == "" ]; then
			port=$SSH_DEFAULT_PORT
		fi
		echo "Connecting to '$alias' ($addr:$port)..."
		ssh $user@$addr -p $port
	else
		print_error "Unknown alias '$alias'"
		print_servers
		exit 1
	fi
}

function print_servers() {
	separator 
	echo "List of availables servers "
	separator
	while IFS=: read label user ip port         
	do    
		test_host $ip
		echo -ne "\t"
		cecho -n -blue $label
		echo -ne ' ==> '
		cecho -n -red $user 
		cecho -n -yellow "@"
		cecho -n -white $ip
		echo -ne ' -> '
		if [ "$port" == "" ]; then
			port=$SSH_DEFAULT_PORT
		fi
		cecho -yellow $port
		echo
	done < $HOST_FILE
}

#=============================================================================

cmd=$1

# if config file doesn't exist
if [ ! -f $HOST_FILE ]; then touch "$HOST_FILE"; fi

# without args
if [ $# -eq 0 ]; then
	print_servers
	list_commands
	exit 0
fi

case "$cmd" in
	# Connect to host
	connect )
		if [ $# -lt 2 ]; then
			print_error "Please specify an alias"
			exit 1
		fi
		connect $2 $3
		;;

	# Add new alias
	add )
		if [ $# -ne 2 ]; then
			print_error "Please specify an alias"
			exit 1
		fi
		server_add $2
		;;
	# Export config
	export )
		echo
		cat $HOST_FILE
		;;
	# Delete alias
	delete )
		if [ $# -ne 2 ]; then
			print_error "Please specify an alias"
			exit 1
		fi
		probe $2
		if [ $? -eq 0 ]; then
			cat $HOST_FILE | sed '/^'$2$DATA_DELIM'/d' > /tmp/.tmp.$$
			mv /tmp/.tmp.$$ $HOST_FILE
			echo "Alias '$2' removed"
		else
			print_error "Unknown alias '$2'"
		fi
		;;
	* )
		connect $1 $2
		;;
esac
