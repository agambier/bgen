#!/bin/bash
#
#	(C) Alexandre Gambier <agambier.dev@gmail.com>
#	bgen - Bubble syntax diagram generator
#	based on a modified version of the SQLite syntax diagram generator bubble-generator.tcl
#
SCRIPT_APP="bgen"
SCRIPT_NAME="Bubble generator"

EXIT_SUCCESS=0
EXIT_WISH_NOT_INSTALLED=1
EXIT_INPUT_FILE_NOT_FOUND=2

action_showhelp=0
link_file="/tmp/bubble-generator-data.tcl"
input_file="./input.bgen"
dpi_flag="-dpi 90"
gif_flag=""
preview_flag="-preview 0"
show_flag="-show 0"
graph_flag=""


parseCommandLine()
{
	while [[ $# > 0 ]]
	do
		arg="$1"
		case $arg in 
			# display help
			"--help")
				action_showhelp=1
			;;

			# input file
			"--input" )
				if [ -n "$2" ]; then
					input_file="$2"
					shift
				fi
			;;
			
			# input file
			"--graph" )
				if [ -n "$2" ]; then
					graph_flag="-graph $2"
					shift
				fi
			;;
			
			# dpi
			"--dpi" )
				if [ -n "$2" ]; then
					dpi_flag="-dpi $2"
					shift
				fi
			;;
			
			# gif
			"--gif" )
				gif_flag="-gif 1"
			;;
			
			# preview
			"--preview" )
				preview_flag="-preview 1"
			;;
			
			# interactive
			"--interactive" )
				show_flag="-show 1"
			;;
			
			# unknown option
			*)
				echo "WARNING: unsupported option '$1'"
			;;
		esac
		shift		
	done
}

displayHelp()
{
	echo "Usage: $SCRIPT_NAME [options]"
	echo "Options:"
	echo "  -h, --help     Display this help"
	echo "                 bsp_name must be in the list."
	echo ""
	echo "Notice: $SCRIPT_NAME must be sourced when calling it (i.e. source bsp-setenv <bsp_name>)"
}
# parse command line
parseCommandLine $@

# make sure wish is installed
if [ -z "`which wish`" ]; then
	echo "ERROR: $SCRIPT_NAME requires wish to run. Please install it."
	exit $EXIT_WISH_NOT_INSTALLED
fi

# make sure input file exit
input_file=`readlink -f "$input_file"`
if [ ! -f "$input_file" ]; then
	echo "ERROR: File not found : $input_file"
	exit $EXIT_INPUT_FILE_NOT_FOUND
fi

# make sure we can convert to gif format
if [ -n "$gif_flag" ]; then
	if [ -z "`which convert`" ]; then
		echo "WARNING: ImageMagick is not installed, GIF conversion is disabled."
		gif_flag=""
	fi
fi

# create a symbolic link to this file, 
# so the bubble_generator wish script will source it
if [ -f "$link_file" ] || [ -h "$link_file" ]; then
	rm "$link_file"
fi
ln -s "$input_file" "$link_file"

# start bubble_generator.tcl
exec ./bubble-generator.tcl $show_flag $gif_flag $dpi_flag $preview_flag $graph_flag 2>/dev/null
