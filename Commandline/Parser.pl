#! /usr/local/bin/perl
# -*- coding: utf-8 -*-

use MIME::Base64;

sub showHelp {
	print "\nUsage: parser [verb] [input file path] ([output file path])\n\n";
	print "verb:\n";
	print "   help: show this help\n";
	print "   b: base64 encoding\n";
	print "   c: compress\n";
	print "   bc: both compressing and base64 encoding\n";
	print "   x: neither compressing nor base64 encoding\n";
	print "\n\n";
}

sub omitComment {
	my $r="";
	my $s=$_[0];
	my $st=$_[1];
	my $en=$_[2];
	my @l=split(/${en}/g,$s);
	foreach my $p (@l) {
		my @sl=split(/${st}/g,$p);
		$r.=$sl[0];
	}
	return $r;
}

sub compress {
	my $s=$_[0];
	$s=&omitComment($s, "\\/\\*", "\\*\\/");
	$s=&omitComment($s, "<!\\-\\-", "\\-\\->");
	$s=~s/[ \t]+\/\/.+$//gm;
	$s=~s/^\/\/.+$//gm;
	$s=~s/\<\/?editing\-folder\>//g;
	$s=~s/ +xml:space=[\"']?preserve[\"']? +/ /gm;
	$s=~s/ +xml:space=[\"']?preserve[\"']? *//gm;
	foreach my $t (";",":",",","{","}") {
		$s=~s/$t[ \t\n\v\f\r]*[\n\v\f\r][ \t\n\v\f\r]*/$t/g;
	}
	$s=~s/  +/ /g;
	$s=~s/^ //gm;
	$s=~s/ $//gm;
	$s=~s/[\t\n\v\f\r]+//g;
	$s=~s/> +/>/g;
	return $s;
}

my $l=scalar(@ARGV);

if ($l>0 and @ARGV[0] eq "help") {
	&showHelp();
	exit(0);
}
elsif ($l>1) {
	my $b=@ARGV[0] =~ /b/i;
	my $c=@ARGV[0] =~ /c/i;
	my $sa="";
	if ($l>2) {
		$sa = @ARGV[2];
	}
	else {
		$sa = "";
	}
	my $r="";
	my $inf=@ARGV[1];
	if (-r $inf) {
		my $md=`file --mime-type ${inf}`;
		$md =~ /[a-z0-9\-\+]+\/[a-z0-9\-\+]+$/i;
		my $m=$&;
		open(F,"<",$inf);
		$r=join("",<F>);
		close(F);
		if ($c) {
			$r=&compress($r);
		}
		if ($b) {
			$r=encode_base64($r,"");
			$r="data:${m};base64,${r}"
		}
		if ($sa ne "") {
			if (-w $sa or !-e $sa) {
				open(F,">",$sa);
				print F $r;
				close(F);
			}
			else {
				print STDERR "Cannot write into this file: ${sa}\n";
				exit(1);
			}
		}
		else {
			print $r;
		}
		exit(0);
	}
	else {
		print STDERR "Cannot read this file or does not exist: ${inf}\n";
		exit(1);
	}
}
else {
	print STDERR "Not enough arguments!\n\n\n";
	&showHelp();
	exit(1);
}
