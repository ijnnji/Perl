#!/bin/bash
exec_func(){
	RETVAL=1
	FUNCTION=$1
	echo "Executing $FUNCTION"
	$FUNCTION
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
	        echo "$FUNCTION success"
	else
	        echo "$FUNCTION FAIL" && exit
	fi
}

get_cpanm(){
	if [ \! -f /usr/local/bin/cpanm ]; then
		cd /tmp/ && curl --insecure -L http://cpanmin.us | perl - App::cpanminus
		if [ \! -f /usr/local/bin/cpanm ]; then
			echo "Downloading from cpanmin.us failed, downloading from xrl.us"
			curl -LO http://xrl.us/cpanm &&
	    	chmod +x cpanm &&
	    	mv cpanm /usr/local/bin/cpanm
		fi
	fi
	CPANM=$(which cpanm);
	if [ \! -f "$CPANM" ]; then
		echo "ERROR: Unable to find cpanm"
		return 1;
	fi
	return 0
}

install_modules(){
	for RETRY in 1 2 3; do
		cpanm -v Starman Moose Data::Dumper Plack::Request Plack::Component DBI strict Data::Dumper Log::Log4perl Config::JSON Plack::Builder Plack::Middleware::CrossOrigin FindBin
		RETVAL=$?
		if [ "$RETVAL" = 0 ]; then
			break;
		fi
		echo "Retry $RETRY"
	done
 }


for FUNCTION in "get_cpanm"  "install_modules"; do
	exec_func $FUNCTION
done
