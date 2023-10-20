import 'package:flutter/material.dart';
import 'package:le_test/view_models.dart';
import 'package:le_test/views.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel viewModel;
  late final PageController viewController;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    viewController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: viewController,
        itemBuilder: (context, i) {
          switch (i) {
            case 0:
              return const ConnectionsTestView();
            case 1:
              return const SpeedTestView();
            default:
              throw ArgumentError.value(i);
          }
        },
        itemCount: 2,
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: viewController,
        builder: (context, child) {
          return BottomNavigationBar(
            onTap: (i) {
              viewController.jumpToPage(i);
            },
            currentIndex: viewController.page?.round() ?? 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded),
                label: 'Connections Test',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.speed_rounded),
                label: 'Speed Test',
              ),
            ],
          );
        },
      ),
    );
  }
}
