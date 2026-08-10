import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileViewScreen extends StatelessWidget {
  final UserProfile? profile;

  const ProfileViewScreen({Key? key, this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userProfile = profile ?? profileProvider.profile;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          title: Text(
            lang == 'ne' ? 'प्रोफाइल' : 'Profile',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                lang == 'ne' ? 'प्रोफाइल भेटिएन' : 'Profile not found',
                style: const TextStyle(fontSize: 18, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final role = 'worker'; // Default to worker
                  Navigator.pushReplacementNamed(
                    context,
                    '/profile-setup',
                    arguments: lang,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  lang == 'ne' ? 'प्रोफाइल सिर्जना गर्नुहोस्' : 'Create Profile',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App bar with profile header
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Photo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF10B981), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: userProfile.profilePhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  userProfile.profilePhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildInitialsAvatar(userProfile);
                                  },
                                ),
                              )
                            : _buildInitialsAvatar(userProfile),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        userProfile.getDisplayName(lang),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981), width: 1),
                        ),
                        child: Text(
                          userProfile.role == 'worker'
                              ? (lang == 'ne' ? 'कामदार' : 'Worker')
                              : (lang == 'ne' ? 'रोजगारदाता' : 'Employer'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/profile-edit',
                    arguments: lang,
                  );
                },
                tooltip: lang == 'ne' ? 'सम्पादन गर्नुहोस्' : 'Edit',
              ),
            ],
          ),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Rating Card
                  _buildStatusRatingCard(userProfile, lang),
                  const SizedBox(height: 20),

                  // Contact Information
                  _buildSectionTitle(
                    lang == 'ne' ? 'सम्पर्क जानकारी' : 'Contact Information',
                    Icons.contact_phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: lang == 'ne' ? 'मोबाइल नम्बर' : 'Mobile Number',
                      value: '+977 ${userProfile.phone}',
                    ),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: lang == 'ne' ? 'स्थान' : 'Location',
                      value: userProfile.getDisplayLocation(lang),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Professional Information
                  _buildSectionTitle(
                    userProfile.role == 'worker'
                        ? (lang == 'ne' ? 'व्यावसायिक जानकारी' : 'Professional Details')
                        : (lang == 'ne' ? 'व्यवसाय जानकारी' : 'Business Details'),
                    Icons.work_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    if (userProfile.role == 'worker') ...[
                      _buildInfoRow(
                        icon: Icons.build_outlined,
                        label: lang == 'ne' ? 'मुख्य सीप' : 'Primary Skill',
                        value: userProfile.skill ?? (lang == 'ne' ? 'उल्लेख गरिएको छैन' : 'Not specified'),
                      ),
                      if (userProfile.experience != null)
                        _buildInfoRow(
                          icon: Icons.timeline_outlined,
                          label: lang == 'ne' ? 'अनुभव' : 'Experience',
                          value: userProfile.experience!,
                        ),
                    ] else ...[
                      _buildInfoRow(
                        icon: Icons.business_outlined,
                        label: lang == 'ne' ? 'उद्योग' : 'Industry',
                        value: userProfile.industry ?? (lang == 'ne' ? 'उल्लेख गरिएको छैन' : 'Not specified'),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // Government ID Verification
                  _buildSectionTitle(
                    lang == 'ne' ? 'परिचय पत्र प्रमाणीकरण' : 'ID Verification',
                    Icons.verified_user_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                      icon: Icons.credit_card_outlined,
                      label: lang == 'ne' ? 'परिचय पत्रको प्रकार' : 'ID Type',
                      value: _getGovIdTypeName(userProfile.governmentIdType, lang),
                    ),
                    if (userProfile.governmentIdNumber != null &&
                        userProfile.governmentIdNumber!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.numbers,
                        label: lang == 'ne' ? 'परिचय पत्र नम्बर' : 'ID Number',
                        value: userProfile.governmentIdNumber!,
                      ),
                  ]),
                  const SizedBox(height: 16),

                  // Government ID Image
                  if (userProfile.governmentIdImageUrl != null &&
                      userProfile.governmentIdImageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullImage(
                        context,
                        userProfile.governmentIdImageUrl!,
                        lang == 'ne' ? 'सरकारी परिचय पत्र' : 'Government ID',
                      ),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                userProfile.governmentIdImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 160,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: Icon(Icons.broken_image_outlined, size: 48, color: Color(0xFF94A3B8)),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.zoom_in_outlined,
                                    size: 18,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    lang == 'ne' ? 'ठूलो आकारमा हेर्नुहोस्' : 'Tap to view full size',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(UserProfile profile) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF10B981),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRatingCard(UserProfile profile, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF0F172A).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          // Status
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: profile.status == 'active'
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : profile.status == 'pending'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    profile.status == 'active'
                        ? Icons.check_circle
                        : profile.status == 'pending'
                            ? Icons.pending
                            : Icons.block,
                    color: profile.status == 'active'
                        ? const Color(0xFF10B981)
                        : profile.status == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.status == 'active'
                      ? (lang == 'ne' ? 'सक्रिय' : 'Active')
                      : profile.status == 'pending'
                          ? (lang == 'ne' ? 'पेन्डिङ' : 'Pending')
                          : (lang == 'ne' ? 'निष्क्रिय' : 'Inactive'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 50,
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
          // Rating
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profile.rating ?? 0.0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  lang == 'ne' ? 'मूल्यांकन' : 'Rating',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 50,
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
          // Jobs Completed
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.work_history_outlined,
                    color: Color(0xFF0F172A),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profile.jobsCompleted ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  profile.role == 'worker'
                      ? (lang == 'ne' ? 'काम पूरा' : 'Jobs Done')
                      : (lang == 'ne' ? 'कामदार' : 'Hired'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGovIdTypeName(String? idType, String lang) {
    if (idType == null) return lang == 'ne' ? 'उल्लेख गरिएको छैन' : 'Not specified';
    
    final idTypes = {
      'citizenship': {'en': 'Citizenship', 'ne': 'नागरिकता'},
      'nid': {'en': 'National ID (NID)', 'ne': 'राष्ट्रिय परिचयपत्र (NID)'},
      'license': {'en': 'Driving License', 'ne': 'सवारी चालक अनुमति'},
      'pan': {'en': 'PAN Card', 'ne': 'प्यान कार्ड'},
    };
    
    return idTypes[idType]?[lang] ?? idType;
  }

  void _showFullImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 64, color: Color(0xFF94A3B8)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
