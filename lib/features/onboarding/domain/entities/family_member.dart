import 'package:equatable/equatable.dart';

class FamilyMember extends Equatable {
  final String id;
  final String name;
  final String role; // 'Dad', 'Mom', 'Son', 'Daughter', 'Roommate', etc.
  final String diet; // 'Omnivore', 'Vegan', 'Keto', etc.
  final List<String> allergies;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.diet = 'Omnivore',
    this.allergies = const [],
  });

  FamilyMember copyWith({
    String? name,
    String? role,
    String? diet,
    List<String>? allergies,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      diet: diet ?? this.diet,
      allergies: allergies ?? this.allergies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'diet': diet,
      'allergies': allergies,
    };
  }

  @override
  List<Object> get props => [id, name, role, diet, allergies];
}
