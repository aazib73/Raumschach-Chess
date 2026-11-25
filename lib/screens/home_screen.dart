import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import 'game_options_screen.dart';

/// Landing screen for the app: start a game, or open Tutorial, Practice, or Settings.
///
/// This screen creates the shared [GameController] when the player starts a
/// new game, passes that instance into [GameOptionsScreen], and disposes it
/// when the game session is popped back to Home.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameController? _sessionController;

  @override
  void dispose() {
    _sessionController?.dispose();
    super.dispose();
  }

  Future<void> _openNewGame() async {
    final controller = GameController();
    _sessionController?.dispose();
    setState(() => _sessionController = controller);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: GameOptionsScreen.routeName),
        builder: (context) => GameOptionsScreen(controller: controller),
      ),
    );

    controller.dispose();
    if (mounted && identical(_sessionController, controller)) {
      setState(() => _sessionController = null);
    }
  }

  void _showComingSoon() {
    _showSnackBar('Coming soon');
  }

  void _showInDevelopment() {
    _showSnackBar('In development');
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            size: 72,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Raumschach',
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '3D Chess on a 5×5×5 cube',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 56),
                          FilledButton.icon(
                            onPressed: _openNewGame,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('New Game'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: _showComingSoon,
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text('Tutorial'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InDevelopmentButton(
                            icon: Icons.touch_app_outlined,
                            label: 'Practice',
                            onPressed: _showInDevelopment,
                          ),
                          const SizedBox(height: 12),
                          _InDevelopmentButton(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onPressed: _showInDevelopment,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


/// Full-width outlined action with an "In development" subtitle.
class _InDevelopmentButton extends StatelessWidget {
  const _InDevelopmentButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: textTheme.titleMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'In development',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
