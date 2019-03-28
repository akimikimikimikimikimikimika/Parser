#! /usr/local/bin/php
<?php

function showHelp() {
	print <<<"Help"

Usage: parser [verb] [input file path] ([output file path])

verb:
   help: show this help
   b: base64 encoding
   c: compress
   bc: both compressing and base64 encoding
   x: neither compressing nor base64 encoding


Help;
}

function omitComment($s,$st,$en) {
	$r="";
	$l=preg_split("/$en/",$s);
	foreach ($l as $p) {
		$r.=preg_split("/$st/",$p)[0];
	}
	return $r;
}

function compress($s) {
	$s=omitComment($s, "\\/\\*", "\\*\\/");
	$s=omitComment($s, "<!\\-\\-", "\\-\\->");
	$s=preg_replace("/[ \t]+\/\/.+$/m","",$s);
	$s=preg_replace("/^\/\/.+$/m","",$s);
	$s=preg_replace("/\<\/?editing\-folder\>/","",$s);
	$s=preg_replace("/ +xml:space=[\"']?preserve[\"']? +/"," ",$s);
	$s=preg_replace("/ +xml:space=[\"']?preserve[\"']? */","",$s);
	foreach (array(";",":",",","{","}") as $t) {
		$s=preg_replace("/${t}[ \t\n\v\f\r]*[\n\v\f\r][ \t\n\v\f\r]*/",$t,$s);
	}
	$s=preg_replace("/  +/"," ",$s);
	$s=preg_replace("/^ /m","",$s);
	$s=preg_replace("/ $/m","",$s);
	$s=preg_replace("/[\t\n\v\f\r]+/","",$s);
	$s=preg_replace("/> +/",">",$s);
	return $s;
}

$l=count($argv);

if ($l>1 and $argv[0]=="help") {
	showHelp();
	exit(0);
}
elseif ($l>2) {
	$b=preg_match("/b/i",$argv[1]);
	$c=preg_match("/c/i",$argv[1]);
	if ($l>3) {
		$sa=$argv[3];
	}
	else {
		$sa=null;
	}
	$r="";
	$inf=$argv[2];
	if (is_readable($inf)) {
		$m=mime_content_type($inf);
		$f=fopen($inf,"rb");
		$r=fread($f,filesize($inf));
		fclose($f);
		if ($c) {
			$r=compress($r);
		}
		if ($b) {
			$r="data:$m;base64,".base64_encode($r);
		}
	}
	else {
		fputs(STDERR,"Cannot read this file or does not exist: $inf\n");
		exit(1);
	}
	if ($sa != null) {
		if (is_writable($sa) or !file_exists($sa)) {
			$f=fopen($sa,"w");
			fwrite($f,$r);
			fclose($f);
			exit(0);
		}
		else {
			fputs(STDERR,"Cannot write into this file: $sa\n");
			exit(1);
		}
	}
	else {
		print $r;
		exit(0);
	}
}
else {
	fputs(STDERR,"Not enough arguments!\n\n");
	showHelp();
	exit(1);
}

?>