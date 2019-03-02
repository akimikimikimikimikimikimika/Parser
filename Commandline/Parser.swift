#! /usr/bin/swift

import Foundation
import CoreServices

func showHelp(){
	print("\nUsage: parser [verb] [input file path] ([output file path])\n")
	print("verb:")
	print("   help: show this help")
	print("   b: base64 encoding")
	print("   c: compress")
	print("   bc: both compressing and base64 encoding")
	print("   x: neither compressing nor base64 encoding")
	print("\n")
}

struct ParseOption {
	var base64:Bool = false
	var compress:Bool = false
	var saveAt:URL?
}
var o=ParseOption()

func RegExp(_ s:String) -> NSRegularExpression? {
	let ro=NSRegularExpression.Options.self
	do{
		return try NSRegularExpression(pattern: s, options: [ro.caseInsensitive,ro.anchorsMatchLines])
	}catch{return nil}
}
func exist(_ s:String, _ p:String) -> Bool {
	return RegExp(p)!.numberOfMatches(in: s, options: [], range: NSRange(location: 0, length: s.count))>0
}
func replace(_ s:String, _ p:String,_ r:String) -> String {
	return RegExp(p)!.stringByReplacingMatches(in: s, options: [], range: NSRange(location: 0, length: s.count), withTemplate: r)
}

func omitComment(_ s:String,start:String,end:String) -> String {
	var r=""
	let l=s.components(separatedBy: end)
	for p in l {r+=p.components(separatedBy: start)[0]}
	return r
}
func compress(_ s:String) -> String {
	var r=s
	r=omitComment(r, start: "/*", end: "*/")
	r=omitComment(r, start: "<!--", end: "-->")
	r=replace(r, "[ \t]+//.+$", "")
	r=replace(r, "^//.+$", "")
	r=replace(r, "\\<\\/?editing\\-folder\\>", "")
	r=replace(r, " +xml:space=[\"']?preserve[\"']? +", " ")
	r=replace(r, " *xml:space=[\"']?preserve[\"']? *", "")
	for s in [";",":",",","\\{","\\}"] {r=replace(r, s+"[\\n\\t ]*\\n[\\n\\t ]*", s)}
	r=replace(r, "  +", " ")
	r=replace(r, "^ ", "")
	r=replace(r, " $", "")
	r=replace(r, "[\\t\\n]+", "")
	r=replace(r, "> +", ">")
	return r
}

func mimeType(_ u:URL) -> String {
	var m:String = ""
	let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, u.pathExtension as CFString, nil)?.takeUnretainedValue()
	if let u = uti {
		m = UTTypeCopyPreferredTagWithClass(u,kUTTagClassMIMEType)?.takeUnretainedValue() as String? ?? ""
	}
	return m
}

let fm = FileManager.default
var args = CommandLine.arguments
let c = args.count

if c>1 && args[1]=="help" {
	showHelp()
	exit(0)
}
else if c>2 {
	o.base64 = exist(args[1], "b")
	o.compress = exist(args[1], "c")
	if c>3 {o.saveAt = URL(fileURLWithPath: args[3], relativeTo: nil)}
	let url = URL(fileURLWithPath: args[2], relativeTo: nil)
	var r = ""
	if o.base64 && !o.compress {
		do{
			let d = try Data(contentsOf: url)
			r="data:"+mimeType(url)+";base64,"+d.base64EncodedString()
		}catch{
			print("Cannot read this file or does not exist: "+url.path)
			exit(1)
		}
	}
	else {
		do{
			r = try String(contentsOf: url)
		}catch{
			print("Cannot read this file or does not exist: "+url.path)
			exit(1)
		}
		if (o.compress) {r=compress(r)}
		if (o.base64) {
			if let b = r.data(using: .utf8)?.base64EncodedString() {
				r="data:"+mimeType(url)+";base64,"+b
			}
			else {
				print("Fail to encode to base64 format")
				exit(1)
			}
		}
	}
	if let u = o.saveAt {
		if (fm.fileExists(atPath: u.path)) {
				do{
				try r.write(toFile: u.path, atomically: true, encoding: .utf8)
				exit(0)
			}catch{
				print("Fail to write the data into the existing file")
				exit(1)
			}
		}
		else {
			if fm.createFile(atPath: u.path, contents: r.data(using: .utf8), attributes: nil) {exit(0)}
			else {
				print("Fail to write the data to the destination you chose")
				exit(1)
			}
		}
	}
	else {print(r)}
	exit(0)
}
else {
	print("Not enough arguments!\n\n")
	showHelp()
	exit(1)
}