/// An office/location in a company, used for GPS attendance validation.
class Office {
  const Office({
    required this.id,
    required this.label,
    required this.companyId,
    this.address,
    this.latitude,
    this.longitude,
    this.wifiSsids,
    this.wifiMacAddresses,
  });

  final String id;
  final String label;
  final String companyId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? wifiSsids;
  final String? wifiMacAddresses;

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'] as String,
      label: json['label'] as String,
      companyId: json['company_id'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      wifiSsids: json['wifi_ssids'] as String?,
      wifiMacAddresses: json['wifi_mac_addresses'] as String?,
    );
  }
}
