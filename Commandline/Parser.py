#! /usr/local/bin/python3.7
# -*- coding: utf-8 -*-

import os
import sys
import re
import base64
import mimetypes

def showHelp():
	print("\nUsage: parser [verb] [input file path] ([output file path])\n")
	print("verb:")
	print("   help: show this help")
	print("   b: base64 encoding")
	print("   c: compress")
	print("   bc: both compressing and base64 encoding")
	print("   x: neither compressing nor base64 encoding")
	print("\n")

def exist(s,p):
	return re.search(re.compile("(?i)"+p),s) != None

def omitComment(s,st,en):
	r=""
	l=s.split(en)
	for p in l:
		r+=p.split(st)[0]
	return r

def compress(s):
	s=omitComment(s, "/*", "*/")
	s=omitComment(s, "<!--", "-->")
	s=re.sub(r"(?m)[ \t]+\/\/.+$","",s)
	s=re.sub(r"(?m)^\/\/.+$","",s)
	s=re.sub(r"\<\/?editing\-folder\>","",s)
	s=re.sub(r" +xml:space=[\"']?preserve[\"']? +"," ",s)
	s=re.sub(r" +xml:space=[\"']?preserve[\"']? *","",s)
	for t in [";",":",",","{","}"]:
		s=re.sub(re.compile("(?m)"+t+"[\\n\\t ]*\\n[\\n\\t ]*"),t,s)
	s=re.sub(r"  +"," ",s)
	s=re.sub(r"(?m)^ ","",s)
	s=re.sub(r"(?m) $","",s)
	s=re.sub(r"[\t\n]+","",s)
	s=re.sub(r"> +",">",s)
	return s

args=sys.argv
l=len(args)

if l>1 and args[1]=="help":
	showHelp()
	exit(0)
elif l>2:
	b = exist(args[1], "b")
	c = exist(args[1], "c")
	if l>3:
		sa = args[3]
	else:
		sa = None
	r=""
	inf=args[2]
	if os.path.isfile(inf):
		m=mimetypes.guess_type(inf)[0]
		if b and not c:
			try:
				f=open(inf,"rb")
			except:
				sys.stderr.write("Cannot read this file or does not exist: "+inf+"\n")
				exit(1)
			r=base64.b64encode(f.read()).decode()
			f.close()
			r="data:"+m+";base64,"+r
		else:
			try:
				f=open(inf,"r")
			except:
				sys.stderr.write("Cannot read this file or does not exist: "+inf+"\n")
				exit(1)
			r=f.read()
			f.close()
			if c:
				r=compress(r)
			if b:
				r="data:"+m+";base64,"+base64.b64encode(r.encode()).decode()
		if sa != None:
			try:
				f=open(sa,"w")
			except:
				sys.stderr.write("Cannot write into this file: "+sa+"\n")
				exit(1)
			f.write(r)
			f.close()
		else:
			sys.stdout.write(r)
		exit(0)
	else:
		sys.stderr.write("Cannot read this file or does not exist: "+inf+"\n")
		exit(1)
else:
	sys.stderr.write("Not enough arguments!\n\n")
	showHelp()
	exit(1)
