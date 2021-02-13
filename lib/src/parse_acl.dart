import 'dart:async';

import 'parse_role.dart';
import 'parse_user.dart';

/// A [ParseACL] is used to control which users can access or modify a particular object.
/// Each [ParseObject] can have its own [ParseACL]. You can grant read and write permissions
/// separately to specific users, to groups of users that belong to roles, or you can grant
/// permissions to "the public" so that, for example, any user could read a particular object
/// but only a particular set of users could write to that object.
class ParseACL {
  /// Creates an ACL with no permissions granted.
  ParseACL() : _map = {};

  /// Clone an ACL from another ACL.
  ParseACL.fromACL(ParseACL acl) : _map = acl._map;

  /// Creates an ACL where only the provided user has access.
  ParseACL.fromUser(ParseUser user) : _map = {user.objectId: _Permissions()};

  /// A helper for creating a ParseACL from the wire.
  /// We iterate over it rather than just copying to permissionsById so that we
  /// can ensure it's the right format.
  factory ParseACL.fromMap(dynamic map) {
    final parseACL = ParseACL();

    if (map is Map<String, dynamic>) {
      map.forEach((key, value) {
        parseACL._map[key] = _Permissions.fromMap(value);
      });
    }

    return parseACL;
  }

  final Map<String, _Permissions> _map;

  /// Get whether the public is allowed to read this object.
  bool get publicReadAccess => _map['*']?.read ?? false;

  /// Get whether the public is allowed to write this object.
  bool get publicWriteAccess => _map['*']?.write ?? false;

  /// Set whether the public is [allowed] to read this object.
  set publicReadAccess(bool allowed) {
    _map['*'] = _Permissions(read: allowed, write: publicWriteAccess);
  }

  /// Set whether the public is [allowed] to read this object.
  set publicWriteAccess(bool allowed) {
    _map['*'] = _Permissions(read: publicReadAccess, write: allowed);
  }

  static void _validateUserState(ParseUser user) {
    assert(user != null);
    assert(user.objectId != null, "cannot get or set access for null userId");
  }

  /// Get whether the given [user] is *explicitly* allowed to read this object. Even if this returns
  /// `false`, the [user] may still be able to access it if [publicReadAccess] returns
  /// `true` or a role that the user belongs to has read access.
  bool getUserReadAccess(ParseUser user) {
    _validateUserState(user);
    return _map[user.objectId]?.read ?? false;
  }

  /// Get whether the given [user] is *explicitly* allowed to write this object. Even if this
  /// returns `false`, the user may still be able to write it if [publicWriteAccess] returns
  /// `true` or a role that the user belongs to has write access.
  bool getUserWriteAccess(ParseUser user) {
    _validateUserState(user);
    return _map[user.objectId]?.write ?? false;
  }

  /// Set whether the given [user] is [allowed] to write this object.
  void setUserWriteAccess(ParseUser user, bool allowed) {
    _validateUserState(user);
    _map[user.objectId] =
        _Permissions(read: getUserReadAccess(user), write: allowed);
  }

  /// Set whether the given [user] is [allowed] to read this object.
  void setUserReadAccess(ParseUser user, bool allowed) {
    _validateUserState(user);
    _map[user.objectId] =
        _Permissions(read: allowed, write: getUserWriteAccess(user));
  }

  static void _validateRoleState(ParseRole role) {
    assert(role != null && role.objectId != null,
        "Roles must be saved to the server before they can be used in an ACL.");
  }

  /// Get whether users belonging to the given role are allowed to read this object. Even if this
  /// returns `false`, the role may still be able to read it if a parent role has read access.
  /// The [role] must already be saved on the server and its data must have been fetched in order to
  /// use this method.
  bool getRoleReadAccess(ParseRole role) {
    _validateRoleState(role);
    return _map['role:${role.name}']?.read ?? false;
  }

  /// Get whether users belonging to the given role are allowed to write this object. Even if this
  /// returns `false`, the [role] may still be able to write it if a parent role has write
  /// access. The role must already be saved on the server and its data must have been fetched in
  /// order to use this method.
  bool getRoleWriteAccess(ParseRole role) {
    _validateRoleState(role);
    return _map['role:${role.name}']?.write ?? false;
  }

  /// Set whether users belonging to the [role] with the given roleName are [allowed] to read this
  /// object.
  void setRoleReadAccess(ParseRole role, bool allowed) {
    _validateRoleState(role);
    _map['role:${role.name}'] =
        _Permissions(write: getRoleReadAccess(role), read: allowed);
  }

  /// Set whether users belonging to the [role] with the given roleName are [allowed] to write this
  /// object.
  void setRoleWriteAccess(ParseRole role, bool allowed) {
    _validateRoleState(role);
    _map['role:${role.name}'] =
        _Permissions(write: allowed, read: getRoleWriteAccess(role));
  }

  /// Return this ACL into Map format
  dynamic get map => _map.map((k, v) => MapEntry(k, v._map));

  /// Sets a default ACL that will be applied to all {@link ParseObject}s when they are created.
  static void setDefaultACL(ParseACL acl, bool withAccessForCurrentUser) =>
      _parseDefaultACLController.set(acl, withAccessForCurrentUser);

  static Future<ParseACL> defaultACL() => _parseDefaultACLController.get();
}

final _ParseDefaultACLController _parseDefaultACLController =
    _ParseDefaultACLController._internal();

class _ParseDefaultACLController {
  _ParseDefaultACLController._internal();

  ParseACL defaultACL;
  bool defaultACLUsesCurrentUser;
  ParseUser lastCurrentUser;
  ParseACL defaultACLWithCurrentUser;

  void set(ParseACL acl, bool withAccessForCurrentUser) {
    defaultACLWithCurrentUser = null;
    lastCurrentUser = null;
    if (acl != null) {
      ParseACL newDefaultACL = ParseACL.fromACL(acl);
      defaultACL = newDefaultACL;
      defaultACLUsesCurrentUser = withAccessForCurrentUser;
    } else {
      defaultACL = null;
    }
  }

  Future<ParseACL> get() async {
    if (defaultACLUsesCurrentUser && defaultACL != null) {
      ParseUser currentUser = await ParseUser.currentUser;
      if (currentUser != null) {
        // If the currentUser has changed, generate a new ACL from the defaultACL.
        ParseUser last = lastCurrentUser != null ? lastCurrentUser : null;
        if (last != currentUser) {
          ParseACL newDefaultACLWithCurrentUser = ParseACL.fromACL(defaultACL);
          newDefaultACLWithCurrentUser.setUserReadAccess(currentUser, true);
          newDefaultACLWithCurrentUser.setUserWriteAccess(currentUser, true);
          defaultACLWithCurrentUser = newDefaultACLWithCurrentUser;
          lastCurrentUser = currentUser;
        }
        return defaultACLWithCurrentUser;
      }
    }
    return defaultACL;
  }
}

class _Permissions {
  _Permissions({this.read = true, this.write = true});

  _Permissions.fromMap(dynamic map)
      : this(read: map['read'], write: map['write']);

  final bool read;

  final bool write;

  dynamic get _map {
    final map = <String, bool>{};

    if (read != null) {
      map['read'] = read;
    }

    if (write != null) {
      map['write'] = write;
    }

    return map;
  }
}
