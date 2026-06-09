class Room {
  Room({
    required this.id,
    required this.name,
    this.building,
    this.unit,
    this.floor,
    this.type,
    this.capacity,
  });

  final String id;
  final String name;
  final String? building;
  final String? unit;
  final String? floor;
  final String? type;
  final int? capacity;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id']?.toString() ?? json['compartimentoId']?.toString() ?? '',
    name: json['nome'] ?? json['name'] ?? json['compartimento'] ?? '',
    building: json['predio'] ?? json['building'] as String?,
    unit: json['unidade'] ?? json['unit'] as String?,
    floor: json['pavimento'] ?? json['floor'] as String?,
    type: json['tipo'] ?? json['type'] as String?,
    capacity: json['capacidade'] is int
        ? json['capacidade'] as int
        : (json['capacidade'] is String
              ? int.tryParse(json['capacidade'])
              : null),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'building': building,
    'unit': unit,
    'floor': floor,
    'type': type,
    'capacity': capacity,
  };
}
