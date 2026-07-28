import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/catalog/presentation/catalog_edit_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/diagnostics/application/diagnostics.dart';
import '../features/projects/presentation/project_detail_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/analysis/presentation/sampling_report_screen.dart';
import '../features/analysis/presentation/time_study_report_screen.dart';
import '../features/studies/presentation/study_detail_screen.dart';
import '../features/studies/presentation/study_edit_screen.dart';
import '../features/templates/presentation/template_custom_operation_screen.dart';
import '../features/templates/presentation/template_sequence_screen.dart';
import '../features/templates/presentation/templates_screen.dart';
import 'app_shell.dart';

part 'router.g.dart';

/// The app router. Two top-level branches (Projects, Settings) live inside a
/// stateful shell so each keeps its own navigation stack.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
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
                            path: 'report',
                            builder: (context, state) => TimeStudyReportScreen(
                              projectId: state.pathParameters['projectId']!,
                              studyId: state.pathParameters['studyId']!,
                            ),
                          ),
                          // The aggregate report of a Sampling Study. A separate
                          // route from `report` rather than a branch inside it,
                          // because they are different reports over different
                          // grains (DESIGN.md §11.6).
                          GoRoute(
                            path: 'sampling-report',
                            builder: (context, state) => SamplingReportScreen(
                              projectId: state.pathParameters['projectId']!,
                              studyId: state.pathParameters['studyId']!,
                            ),
                          ),
                          // One pass of a Sampling Study. The pass is a route
                          // parameter rather than screen state (DESIGN.md
                          // §11.1), so the workspace never has to ask which
                          // one it is timing.
                          GoRoute(
                            path: 'passes/:observationId',
                            builder: (context, state) => PassWorkspaceScreen(
                              projectId: state.pathParameters['projectId']!,
                              studyId: state.pathParameters['studyId']!,
                              observationId:
                                  state.pathParameters['observationId']!,
                            ),
                            routes: [
                              // One pass IS a time study (§11.6), so its report
                              // is the Time Study report screen with the pass
                              // named — not a parallel implementation.
                              GoRoute(
                                path: 'report',
                                builder: (context, state) =>
                                    TimeStudyReportScreen(
                                  projectId:
                                      state.pathParameters['projectId']!,
                                  studyId: state.pathParameters['studyId']!,
                                  observationId:
                                      state.pathParameters['observationId']!,
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
                path: '/templates',
                builder: (context, state) => const TemplatesScreen(),
                routes: [
                  GoRoute(
                    path: ':templateId/sequence',
                    builder: (context, state) => TemplateSequenceScreen(
                      templateId: state.pathParameters['templateId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'custom',
                        builder: (context, state) =>
                            TemplateCustomOperationScreen(
                          templateId: state.pathParameters['templateId']!,
                        ),
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
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Route breadcrumbs (DESIGN.md §10). Taken from the route information
  // provider rather than a NavigatorObserver, because that yields the actual
  // location string — go_router does not guarantee a `Route.settings.name`.
  // Locations carry ids, never names or notes, per the ids-only rule.
  final routes = router.routeInformationProvider;
  // The initial location is logged explicitly: `addListener` only fires on
  // change, so without this the session's first screen — the one the user was
  // looking at when something went wrong on launch — is the one route missing.
  Diag.event('route', routes.value.uri.path);
  routes.addListener(() => Diag.event('route', routes.value.uri.path));

  return router;
}
