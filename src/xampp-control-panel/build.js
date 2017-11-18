//var sh = new ActiveXObject("WScript.Shell");
//var root = sh.RegRead("HKCU\\Software\\Embarcadero\\BDS\\17.0\\RootDir");
//var search = sh.RegRead("HKCU\\Software\\Embarcadero\\BDS\\17.0\\Library\\Win32\\Search Path")
//WScript.echo(root + "\n" + search);
function RegRead(root, path, key) {
	var sh = new ActiveXObject("WScript.Shell");
	try {
		return sh.RegRead(root + '\\' + path + '\\' + key);
	} catch(ex){
		if(root == 'HKLM'){
			path = path.replace(/^Software/, 'Software\\Wow6432Node');
			try {
				return sh.RegRead(root + '\\' + path + '\\' + key);
			} catch(ex){
				return '';
			}
		}
	}
}
function DirectoryExists(){
	
}
function ReadTargetInfo(IDEVersion) {
	var info = {};
	info.Id = 'd';
	if(IDEVersion < 6) {
		info.KeyName = 'Software\\Borland\\BDS\\' + IDEVersion + '.0';
	} else if(IDEVersion < 8) {
		info.KeyName = 'Software\\Codegear\\BDS\\' + IDEVersion + '.0';
	} else {
		info.KeyName = 'Software\\Embarcadero\\BDS\\' + IDEVersion + '.0';
	}
	info.RootDir = RegRead('HKLM', info.KeyName, 'RootDir');
	if(info.RootDir == '') {
		return null;
	}
	info.Version = IDEVersion;
	if(IDEVersion < 7) {
		info.Version += 6;  // 3.0 => 9
	} else if(IDEVersion < 14) {
		info.Version += 7; // 7.0 => 14
	} else {
		info.Version += 6; // 14.0 => 20  // there is no 13.0
	}
	info.IDEVersion = IDEVersion;
	info.Id += info.Version;
	info.Name = 'Delphi ' + info.Version;
	switch(info.IDEVersion) {
		case 1: info.Name = 'C#Builder'; break;
		case 2: info.Name = 'Delphi 8'; break;
		case 3: info.Name = 'Delphi 2005'; break;
		case 4: info.Name = 'Borland Developer Studio 2006'; break;
		case 5: info.Name = 'CodeGear Delphi 2007 for Win32'; break;
		case 6: info.Name = 'CodeGear RAD Studio 2009'; break;
		case 7: info.Name = 'Embarcadero RAD Studio 2010'; break;
		case 8: info.Name = 'Embarcadero RAD Studio XE'; break;
		case 17: info.Name = 'Embarcadero RAD Studio 10 Seattle'; break;
		default:
			if(info.IDEVersion > 17) {
				info.Name = 'Embarcadero RAD Studio 10.' + (info.IDEVersion - 17); // just a guess
			} else if( info.IDEVersion > 13) {
				info.Name = 'Embarcadero RAD Studio XE' + (2 + (info.IDEVersion - 10));
			} else {
				info.Name = 'Embarcadero RAD Studio XE' + (2 + (info.IDEVersion - 9));
			}
	}
	if (info.IDEVersion >= 8) {
		info.LibDirs = info.RootDir + '\\lib\\' + target + '\\release';
    } else {
		info.LibDirs = info.RootDir + '\Lib';
		if(DirectoryExists(info.RootDir + '\\Lib\\Obj')) {
			info.LibDirs = info.LibDirs + ';' + info.RootDir + '\Lib\Obj';
		}
	}
	var KeyName = info.KeyName + '\\Jedi\\JCL';
	if(info.Version >= 16) {
		KeyName += '\\' + target;
	}
	var DcpDir = RegRead('HKCU', KeyName, 'DcpDir');
	var RootDir = RegRead('HKCU', KeyName, 'RootDir');
	info.JclRootDir = RootDir;
	info.JclVersion = RegRead('HKCU', KeyName, 'Version');
	info.JclLibDirs = DcpDir ;//+ ';' + RootDir + '\\source;' + RootDir + '\\source\include' + RootDir + '\\source\\common;' + RootDir + '\\source\\vcl;' + RootDir + '\\source\\windows';
	return info;
}
//WScript.echo(WScript.Arguments.item(0));
var target = 'win32';
if(WScript.Arguments.Count() > 0) {
	if(WScript.Arguments.Item(0).toLowerCase() == 'win32'){
		target = 'win32';
	} else if(WScript.Arguments.Item(0).toLowerCase() == 'win64'){
		target = 'win64';
	} else {
		WScript.echo('target ' + WScript.Arguments.Item(0) + ' not support!');
	}
}
var info = null;
for(var i = 1; i < 40 && !info; i++){
	info = ReadTargetInfo(i);
}
//for(var i in info){
//	WScript.echo(i + '=' +info[i]);
//}
if(!info){
	WScript.quit();
}
var stream = new ActiveXObject('Adodb.Stream');
stream.Type=2
stream.Mode=3
stream.Open();

stream.WriteText('-U"' + info.LibDirs + '"\n');
stream.WriteText('-I"' + info.LibDirs + '"\n');
stream.WriteText('-R"' + info.LibDirs + '"\n');
stream.WriteText('-O"' + info.LibDirs + '"\n');
stream.WriteText('-I"' + info.JclLibDirs + '"\n');
stream.WriteText('-U"' + info.JclLibDirs + '"\n');
//stream.WriteText('-LUrtl\n');
//stream.WriteText('-LUvcl\n');
stream.WriteText('-DRELEASE\n');
stream.WriteText('-nsSystem;System.Win;WinAPI;Vcl;Vcl.Imaging\n');
//stream.WriteText('-AGenerics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Winapi.Windows;WinProcs=Winapi.Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE\n');
//stream.WriteText('-NSData.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;\n');
if(target == 'win32'){
	stream.SaveToFile('dcc32.cfg', 2);
} else if(target == 'win64'){
	stream.SaveToFile('dcc64.cfg', 2);
}