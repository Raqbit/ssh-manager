# SSH Manager


A simple script to manage ssh connections on *inx ( Such as UNIX, Linux, Mac OS, etc)

![screenshot](https://github.com/Raqbit/ssh-manager/raw/master/screenshot.png)

## Basic introduction

This shell script maintains a file database named ".ssh_servers " which located in "$HOME/.ssh_servers".
With this tool you can easily manage your ssh servers. 
Add new servers, get an overview of online & offline servers and connect to them.

    # ./ssh-manager.sh add local:root:localhost:22
	new alias 'local:root:localhost:22' added
    # ./ssh-manager.sh add local:root:127.0.0.1:22
	new alias 'local:root:127.0.0.1:22' added
    # ./ssh-manager.sh add local:root:10.20.0.7:22
	new alias 'local:root:10.20.0.7:22' added
    # ./ssh-manager.sh
	--------------------------------------------------------------------------------
	List of available servers 
	--------------------------------------------------------------------------------
	[UP]   local ==> root@localhost -> 22
	[UP]   local ==> root@127.0.0.1 -> 22
	[UP]   local ==> root@10.20.0.7 -> 22
	--------------------------------------------------------------------------------
	Available commands
	--------------------------------------------------------------------------------
	<alias> [username]			connect to server
	connect	<alias>	[username]		connect to server
	add	<alias>:<user>:<host>:[port]	add new server
	delete	<alias>				delete server
	export					export config
    # cat .ssh_servers 
	local:root:localhost:22:
	local:root:127.0.0.1:22:
	local:root:10.20.0.7:22:
    #

## Installation

    $ cd ~
    $ wget https://raw.github.com/Raqbit/ssh-manager/master/ssh-manager.sh
    $ chmod +x ssh-manager.sh
    $ ./ssh-manager.sh
    
For more convenience, you can create an alias in your `.bashrc` or `.zshrc`.

For example :

    alias sshs="/Users/robin/ssh-manager.sh"

## Use

	<alias> [username]			connect to server
	connect	<alias>	[username]		connect to server
	add	<alias>:<user>:<host>:[port]	add new server
	delete	<alias>				delete server
	export					export config                                     

### Authors and Contributors

Original script by Errol Byrd
Copyright (c) 2010, Errol Byrd 

Modified by Robin Parisi (@robinparisi)

Modified by Raqbit (@Raqbit)
