class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String get displayName {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    address: json['address'] as String?,
  );
}
