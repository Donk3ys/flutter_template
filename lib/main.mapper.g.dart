import 'package:dart_mappable/dart_mappable.dart';
import 'package:dart_mappable/internals.dart';

import 'data_models/user.dart';


// === ALL STATICALLY REGISTERED MAPPERS ===

var _mappers = <BaseMapper>{
  // class mappers
  UserMapper._(),
  // enum mappers
  UserStatusMapper._(),
  // custom mappers
};


// === GENERATED CLASS MAPPERS AND EXTENSIONS ===

class UserMapper extends BaseMapper<User> {
  UserMapper._();

  @override Function get decoder => decode;
  User decode(dynamic v) => checked(v, (Map<String, dynamic> map) => fromMap(map));
  User fromMap(Map<String, dynamic> map) => User(uuid: Mapper.i.$get(map, 'user_uuid'), password: Mapper.i.$getOpt(map, 'password') ?? "", email: Mapper.i.$get(map, 'email'), username: Mapper.i.$get(map, 'username'), profileImageUrl: Mapper.i.$get(map, 'profile_image_url'), createdAt: Mapper.i.$get(map, 'created_at'), status: Mapper.i.$get(map, 'status'));

  @override Function get encoder => (User v) => encode(v);
  dynamic encode(User v) => toMap(v);
  Map<String, dynamic> toMap(User u) => {'user_uuid': Mapper.i.$enc(u.uuid, 'uuid'), 'password': Mapper.i.$enc(u.password, 'password'), 'email': Mapper.i.$enc(u.email, 'email'), 'username': Mapper.i.$enc(u.username, 'username'), 'profile_image_url': Mapper.i.$enc(u.profileImageUrl, 'profileImageUrl'), 'created_at': Mapper.i.$enc(u.createdAt, 'createdAt'), 'status': Mapper.i.$enc(u.status, 'status')};

  @override String stringify(User self) => 'User(uuid: ${Mapper.asString(self.uuid)}, email: ${Mapper.asString(self.email)}, password: ${Mapper.asString(self.password)}, username: ${Mapper.asString(self.username)}, profileImageUrl: ${Mapper.asString(self.profileImageUrl)}, createdAt: ${Mapper.asString(self.createdAt)}, status: ${Mapper.asString(self.status)})';
  @override int hash(User self) => Mapper.hash(self.uuid) ^ Mapper.hash(self.email) ^ Mapper.hash(self.password) ^ Mapper.hash(self.username) ^ Mapper.hash(self.profileImageUrl) ^ Mapper.hash(self.createdAt) ^ Mapper.hash(self.status);
  @override bool equals(User self, User other) => Mapper.isEqual(self.uuid, other.uuid) && Mapper.isEqual(self.email, other.email) && Mapper.isEqual(self.password, other.password) && Mapper.isEqual(self.username, other.username) && Mapper.isEqual(self.profileImageUrl, other.profileImageUrl) && Mapper.isEqual(self.createdAt, other.createdAt) && Mapper.isEqual(self.status, other.status);

  @override Function get typeFactory => (f) => f<User>();
}

extension UserMapperExtension  on User {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);
  UserCopyWith<User> get copyWith => UserCopyWith(this, $identity);
}

abstract class UserCopyWith<$R> {
  factory UserCopyWith(User value, Then<User, $R> then) = _UserCopyWithImpl<$R>;
  $R call({String? uuid, String? password, String? email, String? username, String? profileImageUrl, DateTime? createdAt, UserStatus? status});
  $R apply(User Function(User) transform);
}

class _UserCopyWithImpl<$R> extends BaseCopyWith<User, $R> implements UserCopyWith<$R> {
  _UserCopyWithImpl(User value, Then<User, $R> then) : super(value, then);

  @override $R call({String? uuid, String? password, String? email, String? username, String? profileImageUrl, DateTime? createdAt, UserStatus? status}) => $then(User(uuid: uuid ?? $value.uuid, password: password ?? $value.password, email: email ?? $value.email, username: username ?? $value.username, profileImageUrl: profileImageUrl ?? $value.profileImageUrl, createdAt: createdAt ?? $value.createdAt, status: status ?? $value.status));
}


// === GENERATED ENUM MAPPERS AND EXTENSIONS ===

class UserStatusMapper extends EnumMapper<UserStatus> {
  UserStatusMapper._();

  @override  UserStatus decode(dynamic value) {
    switch (value) {
      case 0: return UserStatus.removed;
      case 1: return UserStatus.activated;
      case 2: return UserStatus.deactivated;
      default: throw MapperException.unknownEnumValue(value);
    }
  }

  @override  dynamic encode(UserStatus self) {
    switch (self) {
      case UserStatus.removed: return 0;
      case UserStatus.activated: return 1;
      case UserStatus.deactivated: return 2;
    }
  }
}

extension UserStatusMapperExtension on UserStatus {
  dynamic toValue() => Mapper.toValue(this);
}


// === GENERATED UTILITY CODE ===

class Mapper {
  Mapper._();

  static MapperContainer i = MapperContainer(_mappers);

  static T fromValue<T>(dynamic value) => i.fromValue<T>(value);
  static T fromMap<T>(Map<String, dynamic> map) => i.fromMap<T>(map);
  static T fromIterable<T>(Iterable<dynamic> iterable) => i.fromIterable<T>(iterable);
  static T fromJson<T>(String json) => i.fromJson<T>(json);

  static dynamic toValue(dynamic value) => i.toValue(value);
  static Map<String, dynamic> toMap(dynamic object) => i.toMap(object);
  static Iterable<dynamic> toIterable(dynamic object) => i.toIterable(object);
  static String toJson(dynamic object) => i.toJson(object);

  static bool isEqual(dynamic value, Object? other) => i.isEqual(value, other);
  static int hash(dynamic value) => i.hash(value);
  static String asString(dynamic value) => i.asString(value);

  static void use<T>(BaseMapper<T> mapper) => i.use<T>(mapper);
  static BaseMapper<T>? unuse<T>() => i.unuse<T>();
  static void useAll(List<BaseMapper> mappers) => i.useAll(mappers);

  static BaseMapper<T>? get<T>([Type? type]) => i.get<T>(type);
  static List<BaseMapper> getAll() => i.getAll();
}

mixin Mappable implements MappableMixin {
  String toJson() => Mapper.toJson(this);
  Map<String, dynamic> toMap() => Mapper.toMap(this);

  @override
  String toString() {
    return _guard(() => Mapper.asString(this), super.toString);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            _guard(() => Mapper.isEqual(this, other), () => super == other));
  }

  @override
  int get hashCode {
    return _guard(() => Mapper.hash(this), () => super.hashCode);
  }

  T _guard<T>(T Function() fn, T Function() fallback) {
    try {
      return fn();
    } on MapperException catch (e) {
      if (e.isUnsupportedOrUnallowed()) {
        return fallback();
      } else {
        rethrow;
      }
    }
  }
}
