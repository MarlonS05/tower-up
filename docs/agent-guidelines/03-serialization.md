# JSON serialization

HTTP / remote DTOs use `json_annotation` + `json_serializable` in the **repo**
(or dedicated DTO) layer. Persistence stays DAO-based: DAOs return **domain**
entities; repository impls map DTO ↔ domain (and DAO ↔ domain).

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class UserDto {
  final String firstName;
  final String lastName;
  UserDto({required this.firstName, required this.lastName});
  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
```

- Prefer `fieldRename: FieldRename.snake` when the API uses snake_case keys.
- After changing annotated files, run the project codegen rule
  (typically `dart run build_runner build --delete-conflicting-outputs`).
- Do not put `json_serializable` types in `db/daos/` or replace DAOs with
  generated JSON models.
