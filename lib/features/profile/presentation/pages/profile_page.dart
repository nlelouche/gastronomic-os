import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(sl<IOnboardingRepository>())..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
           if (state is ProfileLoaded) {
             return FloatingActionButton.extended(
               onPressed: state.isSaving 
                   ? null 
                   : () {
                       context.read<ProfileCubit>().updateName(_nameController.text);
                       context.read<ProfileCubit>().updateBio(_bioController.text);
                       context.read<ProfileCubit>().saveProfile();
                     },
               label: state.isSaving 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : Text(AppLocalizations.of(context)!.actionSave),
               icon: state.isSaving ? null : const Icon(Icons.check),
             );
           }
           return const SizedBox.shrink();
        },
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ProfileLoaded && !state.isSaving) {
             // Sync controllers if they are empty (first load)
             if (_nameController.text.isEmpty && state.primaryMember.name.isNotEmpty) {
                _nameController.text = state.primaryMember.name;
             }
             if (_bioController.text.isEmpty && state.primaryMember.bio != null) {
                _bioController.text = state.primaryMember.bio!;
             }
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ProfileLoaded) {
            final member = state.primaryMember;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingPage),
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.spaceL),
                  
                  // Avatar Section
                  GestureDetector(
                    onTap: () async {
                       final picker = ImagePicker();
                       final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Or show dialog for Camera/Gallery
                       if (pickedFile != null) {
                         // Check if mounted
                         if (context.mounted) {
                           context.read<ProfileCubit>().uploadAvatar(pickedFile.path);
                         }
                       }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: member.avatarPath != null 
                             ? NetworkImage(member.avatarPath!) 
                             : null,
                          child: member.avatarPath == null 
                            ? Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : "?", style: const TextStyle(fontSize: 40))
                            : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ).animate().scale(),
                  
                  const SizedBox(height: AppDimens.spaceXL),
                  
                  // Name Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.profileNameLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  
                  const SizedBox(height: AppDimens.spaceM),
                  
                  // Bio Field
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.profileBioLabel,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: AppDimens.spaceL),
                  
                  // Badges / Stats (Static for V1 Audit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(context, "Recipes", "0"), // TODO: Fetch Real Stats
                      _buildStat(context, "Likes", "0"),
                      if (member.isVerifiedChef)
                        _buildBadge(context, "Verified Chef", Icons.verified, Colors.blue),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            );
          }
          
          return Center(child: Text(AppLocalizations.of(context)!.errorGeneric));
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
