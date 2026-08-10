/// Mirrors the React `Job` interface from `src/types.ts`.
class Job {
  final String id;
  final String title;
  final String category;
  final String description;
  final int wage;
  final String wageType; // 'daily' | 'weekly'
  final String location;
  final String employerId;
  final String employerName;
  final String employerPhone;
  final String employerWhatsApp;
  final List<String> requiredSkills;
  final String datePosted;
  final double lat;
  final double lng;
  final int applicantsCount;
  final String status; // 'open' | 'closed'

  const Job({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.wage,
    required this.wageType,
    required this.location,
    required this.employerId,
    required this.employerName,
    required this.employerPhone,
    required this.employerWhatsApp,
    required this.requiredSkills,
    required this.datePosted,
    required this.lat,
    required this.lng,
    required this.applicantsCount,
    this.status = 'open',
  });

  Job copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    int? wage,
    String? wageType,
    String? location,
    String? employerId,
    String? employerName,
    String? employerPhone,
    String? employerWhatsApp,
    List<String>? requiredSkills,
    String? datePosted,
    double? lat,
    double? lng,
    int? applicantsCount,
    String? status,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      wage: wage ?? this.wage,
      wageType: wageType ?? this.wageType,
      location: location ?? this.location,
      employerId: employerId ?? this.employerId,
      employerName: employerName ?? this.employerName,
      employerPhone: employerPhone ?? this.employerPhone,
      employerWhatsApp: employerWhatsApp ?? this.employerWhatsApp,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      datePosted: datePosted ?? this.datePosted,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'wage': wage,
        'wageType': wageType,
        'location': location,
        'employerId': employerId,
        'employerName': employerName,
        'employerPhone': employerPhone,
        'employerWhatsApp': employerWhatsApp,
        'requiredSkills': requiredSkills,
        'datePosted': datePosted,
        'lat': lat,
        'lng': lng,
        'applicantsCount': applicantsCount,
        'status': status,
      };

  factory Job.fromMap(Map<String, dynamic> map) => Job(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        category: map['category'] as String? ?? '',
        description: map['description'] as String? ?? '',
        wage: (map['wage'] as num?)?.toInt() ?? 0,
        wageType: map['wageType'] as String? ?? 'daily',
        location: map['location'] as String? ?? '',
        employerId: map['employerId'] as String? ?? '',
        employerName: map['employerName'] as String? ?? '',
        employerPhone: map['employerPhone'] as String? ?? '',
        employerWhatsApp: map['employerWhatsApp'] as String? ?? '',
        requiredSkills: (map['requiredSkills'] as List?)?.cast<String>() ?? [],
        datePosted: map['datePosted'] as String? ?? '',
        lat: (map['lat'] as num?)?.toDouble() ?? 27.7172,
        lng: (map['lng'] as num?)?.toDouble() ?? 85.3240,
        applicantsCount: (map['applicantsCount'] as num?)?.toInt() ?? 0,
        status: map['status'] as String? ?? 'open',
      );
}
