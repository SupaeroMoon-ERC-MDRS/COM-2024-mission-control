class Version{
  final int major;
  final int minor;
  final int patch;

  const Version._({required this.major, required this.minor, required this.patch});

  factory Version.fromString(final String str){
    final Iterable<int> parts = str.split('.').map((e) => int.parse(e));
    return Version._(major: parts.elementAt(0), minor: parts.elementAt(1), patch: parts.elementAt(2));
  }

  bool isSuperiorTo(final Version other){
    return major > other.major ||
      (major == other.major && minor > other.minor) ||
      (major == other.major && minor == other.minor && patch > other.patch);
  }

  bool operator>(covariant Version other){
    return isSuperiorTo(other);
  }

  @override
  bool operator==(covariant Version other){
    return major == other.major && minor == other.minor && patch == other.patch;
  }
  
  @override
  int get hashCode => major^minor^patch;

  static int compareTo(final Version a, final Version b){
    return a > b ? -1 : a == b ? 0 : 1;
  }

  @override
  String toString(){
    return "$major.$minor.$patch";
  }
  
}

class DBCDescriptor{
  final Version version;

  const DBCDescriptor._({required this.version});

  factory DBCDescriptor.fromMap(final Map data){
    return DBCDescriptor._(version: Version.fromString(data["version"]));
  }

  Map asMap(){
    return {"version": version};
  }
}

class NetCodeDescriptor{
  final Version version;

  const NetCodeDescriptor._({required this.version});

  factory NetCodeDescriptor.fromMap(final Map data){
    return NetCodeDescriptor._(version: Version.fromString(data["version"]));
  }

  Map asMap(){
    return {"version": version};
  }
}

class RemoteControlDescriptor{
  final Version version;
  final Version requiredNetCode;

  const RemoteControlDescriptor._({required this.version, required this.requiredNetCode});

  factory RemoteControlDescriptor.fromMap(final Map data){
    return RemoteControlDescriptor._(
      version: Version.fromString(data["version"]),
      requiredNetCode: Version.fromString(data["requiredNetCode"]),
    );
  }

  Map asMap(){
    return {
      "version": version,
      "requiredNetCode": requiredNetCode
    };
  }
}

class GroundStationDescriptor{
  final Version version;
  final Version requiredDBC;
  final Version requiredNetCode;

  const GroundStationDescriptor._({required this.version, required this.requiredDBC, required this.requiredNetCode});

  factory GroundStationDescriptor.fromMap(final Map data){
    return GroundStationDescriptor._(
      version: Version.fromString(data["version"]),
      requiredDBC: Version.fromString(data["requiredDBC"]),
      requiredNetCode: Version.fromString(data["requiredNetCode"]),
    );
  }

  Map asMap(){
    return {
      "version": version,
      "requiredDBC": requiredDBC,
      "requiredNetCode": requiredNetCode,
    };
  }
}