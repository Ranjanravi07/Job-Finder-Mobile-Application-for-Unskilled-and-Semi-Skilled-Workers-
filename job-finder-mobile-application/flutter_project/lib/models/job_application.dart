/// Mirrors the React `JobApplication` interface from `src/types.ts`.
class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerPhone;
  final String workerSkill;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final String appliedAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.workerSkill,
    this.status = 'pending',
    required this.appliedAt,
  });

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? workerId,
    String? workerName,
    String? workerPhone,
    String? workerSkill,
    String? status,
    String? appliedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerSkill: workerSkill ?? this.workerSkill,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'jobId': jobId,
        'workerId': workerId,
        'workerName': workerName,
        'workerPhone': workerPhone,
        'workerSkill': workerSkill,
        'status': status,
        'appliedAt': appliedAt,
      };

  factory JobApplication.fromMap(Map<String, dynamic> map) => JobApplication(
        id: map['id'] as String? ?? '',
        jobId: map['jobId'] as String? ?? '',
        workerId: map['workerId'] as String? ?? '',
        workerName: map['workerName'] as String? ?? '',
        workerPhone: map['workerPhone'] as String? ?? '',
        workerSkill: map['workerSkill'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        appliedAt: map['appliedAt'] as String? ?? '',
      );
}
