import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';

/// Reusable profile summary card widget
/// Displays compact profile information for use in job listings, applications, and other contexts
class ProfileSummaryCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onTap;
  final bool showRating;
  final bool showStatus;
  final bool showExperience;
  final bool isCompact;
  final String language;

  const ProfileSummaryCard({
    super.key,
    required this.profile,
    this.onTap,
    this.showRating = true,
    this.showStatus = false,
    this.showExperience = true,
    this.isCompact = false,
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isCompact ? _buildCompactLayout(context) : _buildFullLayout(context),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile Photo
          _buildProfilePhoto(context, 56),
          const SizedBox(width: 16),

          // Profile Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.getDisplayName(language),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showStatus) _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 4),

                // Skill/Industry
                Text(
                  profile.role == 'worker'
                      ? (profile.skill ??
                          (language == 'ne'
                              ? 'सीप उल्लेख नाइँ'
                              : 'Skill not specified'))
                      : (profile.industry ??
                          (language == 'ne'
                              ? 'उद्योग उल्लेख नाइँ'
                              : 'Industry not specified')),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.getDisplayLocation(language),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Rating and Experience
                if (showRating || showExperience) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (showRating) _buildRatingBadge(),
                      if (showRating && showExperience)
                        const SizedBox(width: 12),
                      if (showExperience && profile.experience != null)
                        _buildExperienceBadge(),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Arrow Icon
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Profile Photo
          _buildProfilePhoto(context, 40),
          const SizedBox(width: 12),

          // Name and Skill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.getDisplayName(language),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  profile.role == 'worker'
                      ? (profile.skill ?? '')
                      : (profile.industry ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Rating Badge
          if (showRating && profile.rating != null && profile.rating! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    profile.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF10B981),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: profile.profilePhotoUrl != null
          ? ClipOval(
              child: Image.network(
                profile.profilePhotoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials(context, size);
                },
              ),
            )
          : _buildInitials(context, size),
    );
  }

  Widget _buildInitials(BuildContext context, double size) {
    return Center(
      child: Text(
        profile.initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: context.appColors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (profile.status) {
      case 'active':
        statusColor = const Color(0xFF10B981);
        statusText = language == 'ne' ? 'सक्रिय' : 'Active';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = language == 'ne' ? 'पेन्डिङ' : 'Pending';
        break;
      case 'inactive':
        statusColor = Colors.red;
        statusText = language == 'ne' ? 'निष्क्रिय' : 'Inactive';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusText = profile.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    if (profile.rating == null || profile.rating! == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            profile.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            language == 'ne' ? 'मूल्यांकन' : 'rating',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timeline_outlined,
              size: 16, color: Color(0xFF0F172A)),
          const SizedBox(width: 4),
          Text(
            profile.experience!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini profile avatar widget for use in app bars and small spaces
class ProfileAvatar extends StatelessWidget {
  final UserProfile? profile;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.profile,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF10B981),
          border: Border.all(
            color: context.appColors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: profile?.profilePhotoUrl != null
            ? ClipOval(
                child: Image.network(
                  profile!.profilePhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials(context);
                  },
                ),
              )
            : _buildInitials(context),
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final initials = profile?.initials ?? '?';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: context.appColors.white,
        ),
      ),
    );
  }
}
