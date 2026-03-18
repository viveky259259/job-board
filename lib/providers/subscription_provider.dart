import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/services/subscription_service.dart';

final subscriptionServiceProvider =
    Provider<SubscriptionService>((ref) => SubscriptionService());

final subscriptionStreamProvider = StreamProvider<UserSubscription>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(UserSubscription.free());
  return ref.watch(subscriptionServiceProvider).subscriptionStream(user.uid);
});

final subscriptionProvider = Provider<UserSubscription>((ref) {
  return ref.watch(subscriptionStreamProvider).value ?? UserSubscription.free();
});

final currentTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).effectiveTier;
});

final usageLimitsProvider = Provider<UsageLimits>((ref) {
  return ref.watch(subscriptionProvider).usage;
});

final canUseCoverLetterProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierProvider);
  final usage = ref.watch(usageLimitsProvider);
  return usage.canUseCoverLetter(tier);
});

final canUseIntroMessageProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierProvider);
  final usage = ref.watch(usageLimitsProvider);
  return usage.canUseIntroMessage(tier);
});
