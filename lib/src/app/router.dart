import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/catalog/presentation/catalog_edit_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/projects/presentation/project_detail_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/studies/presentation/study_detail_screen.dart';
import '../features/studies/presentation/study_edit_screen.dart';
import '../features/studies/presentation/study_sequence_screen.dart';
import 'app_shell.dart';

part 'router.g.dart';

/// The app router. Two top-level branches (Projects, Settings) live inside a
/// stateful shell so each keeps its own navigation stack.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/projects',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/projects',
                builder: (context, state) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: ':projectId',
                    builder: (context, state) => ProjectDetailScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'studies/:studyId',
                        builder: (context, state) => StudyDetailScreen(
                          projectId: state.pathParameters['projectId']!,
                          studyId: state.pathParameters['studyId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) => StudyEditScreen(
                              projectId: state.pathParameters['projectId']!,
                              studyId: state.pathParameters['studyId']!,
                            ),
                          ),
                          GoRoute(
                            path: 'sequence',
                            builder: (context, state) => StudySequenceScreen(
                              studyId: state.pathParameters['studyId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const CatalogEditScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:operationId',
                    builder: (context, state) => CatalogEditScreen(
                      operationId: state.pathParameters['operationId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
