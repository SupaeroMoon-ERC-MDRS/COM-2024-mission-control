import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:supaeromoon_mission_control/io/file_system.dart';
import 'package:supaeromoon_mission_control/io/terminal.dart';

abstract class FTP{
  static Future<void> upload(final String localFolder, final String localFileName, final String remoteFolder, final String remoteFileName) async {
    final Uint8List bytes = FileSystem.tryLoadBytesFromLocalSync(localFolder, localFileName);
    if(bytes.isEmpty){
      return;
    }

    try{ await manager.sftp.mkdir(remoteFolder); }
    catch(_){}

    await (await manager.sftp.open("$remoteFolder/$remoteFileName", mode: SftpFileOpenMode.create)).close();
    final SftpFile remoteFile = await manager.sftp.open("$remoteFolder/$remoteFileName", mode: SftpFileOpenMode.write);
    await remoteFile.writeBytes(bytes);
    await remoteFile.close();
    return;
  }

  static Future<void> uploadZip(final String localFolder, final String tarName, final String remoteFolder) async {
    print([localFolder, tarName, remoteFolder]);
    await Tar.tar(localFolder, "${FileSystem.getCurrentDirectory}Local/${FileSystem.tmpDir}$tarName");
    await upload(FileSystem.tmpDir, tarName, remoteFolder, tarName);
    FileSystem.tryDeleteFromLocalSync(FileSystem.tmpDir, tarName);
    return;
  }

  static Future<void> download(final String localFolder, final String localFileName, final String remotePath) async {
    final SftpFile remoteFile = await manager.sftp.open(remotePath, mode: SftpFileOpenMode.read);
    final Uint8List bytes = await remoteFile.readBytes();
    await remoteFile.close();

    if(bytes.isEmpty){
      return;
    }

    FileSystem.trySaveBytesToLocalSync(localFolder, localFileName, bytes);
    return;
  }

  static Future<void> downloadZip(final String localFolder, final String remotePath) async {
    final String tempFileName = remotePath.split('/').last;
    await download(localFolder, tempFileName, remotePath);
    await Tar.untar("${FileSystem.getCurrentDirectory}Local/$localFolder$tempFileName", "${FileSystem.getCurrentDirectory}Local/$localFolder");
    FileSystem.tryDeleteFromLocalSync(localFolder, tempFileName);
    return;
  }
}

abstract class Tar{
  static String get sh => Platform.isWindows ? "cmd.exe" : Platform.isLinux ? "bash" : throw Exception();

  static Future<void> tar(final String from, final String to) async {
    final String command = "tar -cf $to $from\n";
    final Pty pty = Pty.start(sh);
    Uint8List? _;
    bool sent = false;
    int i = 0;
    await for(final Uint8List bytes in pty.output){
      final bool wait = _ == null;
      if(_ == null && bytes.length > 10){ // TODO contains some character sequence like ": "
        _ = bytes;
      }
      if(!sent && _ != null){
        pty.write(utf8.encode(command));
        sent = true;
      }
      if(wait){
        continue;
      }
      if(utf8.decode(bytes).substring(bytes.length ~/ 2) == utf8.decode(_!).substring(bytes.length ~/ 2)){
        break;
      }
    }
    pty.kill();
  }

  static Future<void> untar(final String from, final String to) async {
    final String command = "tar -xf $from -C $to\n";
    final Pty pty = Pty.start(sh);
    Uint8List? _;
    bool sent = false;
    int i = 0;
    await for(final Uint8List bytes in pty.output){
      final bool wait = _ == null;
      if(_ == null && bytes.length > 10){ // TODO contains some character sequence like ": "
        _ = bytes;
      }
      if(!sent && _ != null){
        pty.write(utf8.encode(command));
        sent = true;
      }
      if(wait){
        continue;
      }
      if(utf8.decode(bytes).substring(bytes.length ~/ 2) == utf8.decode(_!).substring(bytes.length ~/ 2)){
        break;
      }
    }
    pty.kill();
  }
}