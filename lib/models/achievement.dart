import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement unlock() => Achievement(
        id: id,
        name: name,
        description: description,
        icon: icon,
        xpReward: xpReward,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [id, isUnlocked];

  static List<Achievement> get all => [
        const Achievement(
          id: 'first_blood',
          name: 'First Blood',
          description: 'Apply to your first job',
          icon: Icons.flag,
          xpReward: 50,
        ),
        const Achievement(
          id: 'wordsmith',
          name: 'Wordsmith',
          description: 'Generate 10 cover letters',
          icon: Icons.edit_document,
          xpReward: 100,
        ),
        const Achievement(
          id: 'on_fire',
          name: 'On Fire',
          description: '7-day application streak',
          icon: Icons.local_fire_department,
          xpReward: 150,
        ),
        const Achievement(
          id: 'perfect_match',
          name: 'Perfect Match',
          description: 'Apply to a 95%+ match job',
          icon: Icons.stars,
          xpReward: 100,
        ),
        const Achievement(
          id: 'interview_champ',
          name: 'Interview Champion',
          description: 'Get 5 interviews',
          icon: Icons.emoji_events,
          xpReward: 200,
        ),
        const Achievement(
          id: 'profile_master',
          name: 'Profile Master',
          description: '100% profile completeness',
          icon: Icons.verified,
          xpReward: 100,
        ),
        const Achievement(
          id: 'networker',
          name: 'Networker',
          description: 'Send 20 intro messages',
          icon: Icons.connect_without_contact,
          xpReward: 150,
        ),
        const Achievement(
          id: 'quick_draw',
          name: 'Quick Draw',
          description: 'Apply within 1 hour of job posting',
          icon: Icons.bolt,
          xpReward: 75,
        ),
        const Achievement(
          id: 'explorer',
          name: 'Explorer',
          description: 'Apply to jobs in 5 different cities',
          icon: Icons.explore,
          xpReward: 100,
        ),
        const Achievement(
          id: 'diamond_hands',
          name: 'Diamond Hands',
          description: 'Maintain a 30-day streak',
          icon: Icons.diamond,
          xpReward: 500,
        ),
        const Achievement(
          id: 'centurion',
          name: 'Centurion',
          description: 'Apply to 100 jobs',
          icon: Icons.military_tech,
          xpReward: 300,
        ),
        const Achievement(
          id: 'offer_collector',
          name: 'Offer Collector',
          description: 'Receive 3 job offers',
          icon: Icons.card_giftcard,
          xpReward: 500,
        ),
      ];
}
