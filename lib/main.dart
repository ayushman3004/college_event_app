import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CollegeEventApp());
}

class CollegeEventApp extends StatelessWidget {
  const CollegeEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Events',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// A map to associate category names with specific icons.
final Map<String, IconData> categoryIcons = {
  'Technology': Icons.computer,
  'Music': Icons.music_note,
  'Career': Icons.work,
  'Art': Icons.palette,
  'Sports': Icons.sports_basketball,
  'Academics': Icons.school,
  'Hobbies': Icons.camera_alt,
  'Health': Icons.favorite,
  'General': Icons.event,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<Event> _filteredEvents = [];
  String _searchQuery = '';

  // List of pages for the BottomNavigationBar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _filteredEvents = List.from(events);
    _searchController.addListener(_filterEvents);

    // Initialize the pages list
    _pages = [
      _buildHomePageContent(), // Index 0: Home
      _buildHomePageContent(), // Index 1: Search - Now functional
      CategoriesScreen(
        onCategorySelected: _onCategoryTapped,
      ), // Index 2: Categories
      const Center(
        child: Text(
          'Profile Page - Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ), // Index 3: Profile
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Callback function for when a category is selected from the CategoriesScreen.
  void _onCategoryTapped(String category) {
    // Set the search text to the category name
    _searchController.text = category;
    // Switch to the Home tab (index 0) to display the filtered results
    setState(() {
      _currentIndex = 0;
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredEvents =
          events.where((event) {
            final titleMatch = event.title.toLowerCase().contains(query);
            final descriptionMatch = event.description.toLowerCase().contains(
              query,
            );
            final categoryMatch = event.category.toLowerCase().contains(query);
            final organizerMatch = event.organizer.toLowerCase().contains(
              query,
            );
            return titleMatch ||
                descriptionMatch ||
                categoryMatch ||
                organizerMatch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B73FF), Color(0xFF9B59B6), Colors.white],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              // The body of the scaffold now shows the selected page
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Builds the content specific to the Home page (index 0).
  Widget _buildHomePageContent() {
    return Column(
      children: [_buildSearchBar(), Expanded(child: _buildEventFeed())],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Student! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Discover Campus Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined, () {}),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF6B73FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events, categories...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEventFeed() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              "Try searching for something else.",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: _filteredEvents.length,
          itemBuilder: (context, index) {
            return _buildEventCard(_filteredEvents[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventImage(event),
              _buildEventContent(event),
              _buildEventActions(event),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage(Event event) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: event.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(event.icon, size: 50, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: event.categoryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                onPressed: () => _showDeleteConfirmationDialog(event),
                tooltip: 'Delete Event',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent(Event event) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                event.date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                event.time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.red[400]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.blue[400]),
              const SizedBox(width: 8),
              Text(
                'Organized by ${event.organizer}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventActions(Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            'RSVP',
            event.isRSVP ? Colors.green : Colors.blue,
            () {
              setState(() {
                event.isRSVP = !event.isRSVP;
                if (event.isRSVP) {
                  event.attendees++;
                } else {
                  event.attendees--;
                }
              });
            },
            event.isRSVP ? Icons.check : Icons.add,
          ),
          const SizedBox(width: 12),
          _buildActionButton('Share', Colors.purple, () {
            _shareEvent(event);
          }, Icons.share),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${event.attendees} attending',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    VoidCallback onPressed,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF6B73FF),
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _showCreateEventDialog();
      },
      backgroundColor: const Color(0xFF6B73FF),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      key: const Key('title_field'),
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    TextField(
                      key: const Key('description_field'),
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      key: const Key('location_field'),
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      titleController.text.trim().isEmpty
                          ? null
                          : () {
                            final newEvent = Event(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              location: locationController.text.trim(),
                              date: 'April 20, 2024',
                              time: '5:00 PM',
                              organizer: 'Student Gov.',
                              category: 'General',
                              categoryColor: Colors.grey,
                              icon: Icons.event,
                              gradientColors: [Colors.grey, Colors.blueGrey],
                              attendees: 0,
                            );

                            setState(() {
                              events.insert(0, newEvent);
                              _filterEvents();
                            });

                            Navigator.pop(context);
                          },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: Text(
            'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteEvent(event);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(Event event) {
    setState(() {
      events.remove(event);
      _filterEvents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${event.title}" was deleted.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _shareEvent(Event event) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event shared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _refreshEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _searchController.clear();
      _filteredEvents = List.from(events);
    });
  }
}

/// A new screen that displays event categories in a grid.
class CategoriesScreen extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoriesScreen({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    // Get a unique list of category names from the main events list
    final uniqueCategories = events.map((e) => e.category).toSet().toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: uniqueCategories.length,
      itemBuilder: (context, index) {
        final category = uniqueCategories[index];
        final icon = categoryIcons[category] ?? Icons.label; // Fallback icon

        return InkWell(
          onTap: () => onCategorySelected(category),
          borderRadius: BorderRadius.circular(20),
          child: Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    category,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Event {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final String category;
  final Color categoryColor;
  final IconData icon;
  final List<Color> gradientColors;
  int attendees;
  bool isRSVP;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.category,
    required this.categoryColor,
    required this.icon,
    required this.gradientColors,
    required this.attendees,
    this.isRSVP = false,
  });
}

// Your static list of events remains the same
List<Event> events = [
  Event(
    title: 'Tech Talk: AI & ML',
    description:
        'Join us for an exciting discussion about Artificial Intelligence and Machine Learning trends in 2024. Learn from industry experts and network with fellow tech enthusiasts.',
    date: 'March 15, 2024',
    time: '2:00 PM',
    location: 'Computer Science Building, Room 101',
    organizer: 'CS Department',
    category: 'Technology',
    categoryColor: Colors.blue,
    icon: Icons.computer,
    gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    attendees: 245,
  ),
  Event(
    title: 'Spring Music Festival',
    description:
        'Experience the best of student talent at our annual Spring Music Festival. Live performances, food trucks, and amazing vibes!',
    date: 'March 20, 2024',
    time: '6:00 PM',
    location: 'Main Campus Quad',
    organizer: 'Student Union',
    category: 'Music',
    categoryColor: Colors.orange,
    icon: Icons.music_note,
    gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    attendees: 892,
  ),
  Event(
    title: 'Career Fair 2024',
    description:
        'Meet with top employers and explore career opportunities. Bring your resume and dress professionally for this networking event.',
    date: 'March 25, 2024',
    time: '10:00 AM',
    location: 'University Center',
    organizer: 'Career Services',
    category: 'Career',
    categoryColor: Colors.green,
    icon: Icons.work,
    gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    attendees: 567,
  ),
  Event(
    title: 'Art Exhibition',
    description:
        'Discover amazing artwork created by our talented art students. From paintings to sculptures, explore creativity at its finest.',
    date: 'March 30, 2024',
    time: '1:00 PM',
    location: 'Art Gallery, Fine Arts Building',
    organizer: 'Art Department',
    category: 'Art',
    categoryColor: Colors.purple,
    icon: Icons.palette,
    gradientColors: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
    attendees: 156,
  ),
  Event(
    title: 'Basketball Championship',
    description:
        'Cheer for our college team in the final championship game. Free snacks and drinks for all students!',
    date: 'April 5, 2024',
    time: '7:00 PM',
    location: 'Sports Complex',
    organizer: 'Athletics Department',
    category: 'Sports',
    categoryColor: Colors.red,
    icon: Icons.sports_basketball,
    gradientColors: [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
    attendees: 1234,
  ),
  Event(
    title: 'Debate Championship',
    description:
        'Witness the sharpest minds battle with words in the annual debate finals. Topics range from politics to pop culture.',
    date: 'April 10, 2024',
    time: '3:00 PM',
    location: 'Auditorium Hall',
    organizer: 'Literary Club',
    category: 'Academics',
    categoryColor: Colors.indigo,
    icon: Icons.record_voice_over,
    gradientColors: [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
    attendees: 310,
  ),
  Event(
    title: 'Photography Workshop',
    description:
        'Learn the basics of composition, lighting, and editing from a professional photographer. DSLR and mobile photography covered.',
    date: 'April 12, 2024',
    time: '11:00 AM',
    location: 'Media Lab, Block C',
    organizer: 'Photography Club',
    category: 'Hobbies',
    categoryColor: Colors.teal,
    icon: Icons.camera_alt,
    gradientColors: [const Color(0xFFfad0c4), const Color(0xFFffd1ff)],
    attendees: 75,
  ),
  Event(
    title: 'Yoga & Wellness Session',
    description:
        'De-stress before the final exams with a calming yoga and meditation session. Mats will be provided.',
    date: 'April 15, 2024',
    time: '8:00 AM',
    location: 'Campus Garden',
    organizer: 'Health & Wellness Center',
    category: 'Health',
    categoryColor: Colors.lightGreen,
    icon: Icons.self_improvement,
    gradientColors: [const Color(0xFF84fab0), const Color(0xFF8fd3f4)],
    attendees: 95,
  ),
];
