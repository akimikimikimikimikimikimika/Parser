#! /usr/local/bin/ruby
# -*- coding: utf-8 -*-

require "base64";

def showHelp()
	print "\nUsage: parser [verb] [input file path] ([output file path])\n\n";
	print "verb:\n";
	print "   help: show this help\n";
	print "   b: base64 encoding\n";
	print "   c: compress\n";
	print "   bc: both compressing and base64 encoding\n";
	print "   x: neither compressing nor base64 encoding\n";
	print "\n\n";
end

def omitComment(s,st,en)
	r="";
	l=s.split(/#{en}/);
	l.each do |p|
		r+=p.split(/#{st}/)[0];
	end
	r;
end

def compress(s)
	s=omitComment(s, "\\/\\*", "\\*\\/");
	s=omitComment(s, "<!\-\-", "\-\->");
	s=s.gsub(/[ \t]+\/\/.+$/,"");
	s=s.gsub(/^\/\/.+$/,"");
	s=s.gsub(/\<\/?editing\-folder\>/,"");
	s=s.gsub(/ +xml:space=[\"']?preserve[\"']? +/," ");
	s=s.gsub(/ +xml:space=[\"']?preserve[\"']? */,"");
	[";",":",",","{","}"].each do |t|
		s=s.gsub(/#{t}[ \t\n\v\f\r]*[\n\v\f\r][ \t\n\v\f\r]*/,t);
	end
	s=s.gsub(/  +/," ");
	s=s.gsub(/^ /,"");
	s=s.gsub(/ $/,"");
	s=s.gsub(/[\t\n\v\f\r]+/,"");
	s=s.gsub(/> +/,">");
	s;
end

l=ARGV.length;

if l>0 and ARGV[0]=="help"
	showHelp();
	!exit(0);
elsif l>1
	b=ARGV[0] =~ /b/i;
	c=ARGV[0] =~ /c/i;
	if l>2
		sa=ARGV[2];
	else
		sa=nil;
	end
	r="";
	inf=ARGV[1];
	if File.readable?(inf)
		if `type file` !~ /not found/
			md=`file --mime-type #{inf}`;
			m=md.scan(/[a-z0-9\-\+]+\/[a-z0-9\-\+]+$/i);
		else
			m="";
		end
		f=File.open(inf,"r");
		r=f.read;
		f.close();
		if c
			r=compress(r);
		end
		if b
			r="data:#{m[0]};base64,#{Base64.strict_encode64(r)}";
		end
		if sa!=nil
			if File.writable?(sa) or !File.exist?(sa)
				f=File.open(sa,"w");
			else
				STDERR.print "Cannot write into this file: #{sa}\n";
				!exit(1);
			end
			f.write(r);
			f.close();
		else
			print r;
		end
		!exit(0);
	else
		STDERR.print "Cannot read this file or does not exist: #{inf}\n";
		!exit(1);
	end
else
	STDERR.print "Not enough arguments!\n\n\n";
	showHelp();
	!exit(1);
end
