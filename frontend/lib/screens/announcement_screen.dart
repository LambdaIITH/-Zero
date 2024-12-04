import 'package:dashbaord/models/announcement_model.dart';
import 'package:dashbaord/widgets/announcement_card.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final ApiServices apiServices = ApiServices();
  final List<String> _highlightedFilterOptions = ['All', 'Personalised', 'Personalised', 'Filters'];
  final ScrollController _scrollController = ScrollController();

  int _selectedChipIndex = 0;
  int limit = 10;
  int offset = 0;
  bool isLoading = false;
  bool loadedAll = false;
  List<AnnouncementModel> announcements = [];

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> fetchAnnouncements() async {
    if (loadedAll) return;
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await ApiServices().getAnnouncements(limit, offset);

    if (response == null) {
      setState(() {
        loadedAll = true;
      });
      showError(msg: "You are at the end of list");
    } else {
      setState(() {
        announcements.addAll(response);
        offset += 1;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.blue),
          title: const Text(
            'Announcements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                return Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.7,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 5, 8, 5),
                        child: Row(
                          children: List.generate(
                            _highlightedFilterOptions.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: _selectedChipIndex == index,
                                label: Text(_highlightedFilterOptions[index]),
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedChipIndex = selected ? index : 0;
                                  });
                                },
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: _selectedChipIndex == index ? Colors.white : Colors.blue,
                                ),
                                backgroundColor: Colors.transparent,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: _selectedChipIndex == index
                                        ? Colors.blue
                                        : Colors.blue.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: FilterChip(
                        selected: _selectedChipIndex == 3,
                        label: Text(_highlightedFilterOptions[3]),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedChipIndex = selected ? 3 : 0;
                          });
                        },
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedChipIndex == 3 ? Colors.white : Colors.blue,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: _selectedChipIndex == 3
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length + 1,
        itemBuilder: (context, index) {
          if (index < announcements.length) {
            final announcement = announcements[index];

            return AnnouncementCard(
              image: announcement.imageUrl,
              source: announcement.createdBy,
              date: announcement.createdAt.toString(),
              title: announcement.title,
              description: announcement.description,
            );
          } else if (isLoading) {
            return Center(
                child: LoadingAnimationWidget.beat(
                color: Colors.blue,
                size: 50,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
    // );
  }
}
