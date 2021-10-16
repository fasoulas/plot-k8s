#!/bin/sh

#Dependencies, assumed they are all in the user path
KUBECTL=kubectl
AWK=awk
K8SD=k8s-diagrams
DOT=dot

#Other constants
DEFAULT_OUTPUT="`pwd`/k8s-ns-diagrams"
WORK_DIR=`pwd`

#Clear previous runs
if [ -d "$DEFAULT_OUTPUT" ]
then
   rm -rf $DEFAULT_OUTPUT
fi

#get all k8s namespaces
namespaces=`$KUBECTL get namespaces| $AWK 'NR>1 {print $1}'`

#Iterate through namespaces and generate diagrams
for name in $namespaces;do

	#create namespace directory if it does not exist
	if [ ! -d "$DEFAULT_OUTPUT/$name" ]
	then
		mkdir -p "$DEFAULT_OUTPUT/$name"	
	fi

	#generate dot diagram and cd into its directory
	$K8SD -d $DEFAULT_OUTPUT/$name/diagram -n $name
	cd "$DEFAULT_OUTPUT/$name/diagram"

	#convert dot file into png
	$DOT -q -Tpng k8s.dot > $name.png

	#move png and delete temp namespace directories
	mv $name.png $DEFAULT_OUTPUT
	rm -rf "$DEFAULT_OUTPUT/$name"
	echo "Generated K8S diagram for namespace:$name"

	#change back to the working dir so K8SD has correct relative references
	cd $WORK_DIR
done

