import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'core/config/theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/update_password_screen.dart';
import 'features/feed/presentation/home_screen.dart';
import 'features/feed/presentation/create_post_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/navigation/presentation/scaffold_with_navbar.dart';
import 'features/feed/presentation/post_detail_screen.dart';
import 'features/feed/domain/post_model.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/edit_profile_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/auth/domain/user_model.dart';
import 'features/chat/presentation/chat_list_screen.dart';
import 'features/chat/presentation/chat_room_screen.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'core/router/auth_notifier.dart';

import 'package:timeago/timeago.dart' as timeago;

Future<void> setupFcmForAuthenticatedUsers() async {
  try {
    final auth = Supabase.instance.client.auth;
    final user = auth.currentUser;

    if (user != null) {
      final messaging = FirebaseMessaging.instance;

      // Request permission for iOS
      await messaging.requestPermission();

      // Get FCM token
      String? token = await messaging.getToken();

      if (token != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', user.id);
      }

      // Setup token refresh listener
      messaging.onTokenRefresh.listen((newToken) async {
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': newToken})
            .eq('id', user.id);
      });
    }
  } catch (e) {
    debugPrint('Failed to setup FCM: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/core/config/.env");

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Setup FCM for already authenticated users
  setupFcmForAuthenticatedUsers();

  timeago.setLocaleMessages('id', timeago.IdMessages());

  runApp(const ProviderScope(child: LvoApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isStartingUp = state.matchedLocation == '/';
      final isGoingToReset =
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/update-password';

      // If not authenticated and not going to public pages, redirect to login
      if (!isAuthenticated &&
          !isGoingToLogin &&
          !isGoingToSignup &&
          !isGoingToOnboarding &&
          !isStartingUp &&
          !isGoingToReset) {
        return '/login'; // Or /onboarding if you prefer
      }

      // If authenticated and trying to access login/signup/onboarding, redirect to home
      if (isAuthenticated &&
          (isGoingToLogin || isGoingToSignup || isGoingToOnboarding)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/update-password',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreatePostScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final post = state.extra as PostModel?; // Changed to nullable
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(post: post, postId: postId); // Pass postId
        },
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id'];
          return ProfileScreen(userId: userId);
        },
      ),

      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return EditProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          final otherUser = state.extra as UserModel?; // Nullable just in case
          return ChatRoomScreen(chatId: chatId, otherUser: otherUser);
        },
      ),
      GoRoute(
        path: '/chat/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final otherUser = state.extra as UserModel;
          return ChatResolverScreen(otherUserId: userId, otherUser: otherUser);
        },
      ),
    ],
  );
});

class LvoApp extends ConsumerStatefulWidget {
  const LvoApp({super.key});

  @override
  ConsumerState<LvoApp> createState() => _LvoAppState();
}

class _LvoAppState extends ConsumerState<LvoApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        ref.read(routerProvider).go('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'LVO',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

class ChatResolverScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final UserModel otherUser;

  const ChatResolverScreen({
    super.key,
    required this.otherUserId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatResolverScreen> createState() => _ChatResolverScreenState();
}

class _ChatResolverScreenState extends ConsumerState<ChatResolverScreen> {
  @override
  void initState() {
    super.initState();
    _resolveChat();
  }

  Future<void> _resolveChat() async {
    try {
      final chatId = await ref
          .read(chatRepositoryProvider)
          .createChat(widget.otherUserId);

      if (mounted) {
        context.pushReplacement('/chat/$chatId', extra: widget.otherUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
