<?php

include("./phpdev/util/bin_connect.inc");



	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");


$memcache->flush();
?>    

