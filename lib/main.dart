import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(CollegeEventApp());
}

class CollegeEventApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Events',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Inter',
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9B59B6),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildEventFeed(),
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

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
              _buildIconButton(Icons.search, () {}),
              SizedBox(width: 12),
              _buildIconButton(Icons.notifications_outlined, () {}),
              SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
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
        borderRadius: BorderRadius.only(
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
              borderRadius: BorderRadius.only(
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
                Icon(
                  event.icon,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  event.title,
                  style: TextStyle(
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
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: event.categoryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent(Event event) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                event.date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
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
          SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.red[400]),
              SizedBox(width: 8),
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
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.blue[400]),
              SizedBox(width: 8),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
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
          SizedBox(width: 12),
          _buildActionButton(
            'Share',
            Colors.purple,
            () {
              _shareEvent(event);
            },
            Icons.share,
          ),
          Spacer(),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
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

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed, IconData icon) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            offset: Offset(0, -5),
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
        selectedItemColor: Color(0xFF6B73FF),
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _showCreateEventDialog();
      },
      backgroundColor: Color(0xFF6B73FF),
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Event'),
        content: Text('Event creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareEvent(Event event) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event shared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _refreshEvents() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      // Refresh events logic here
    });
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

List<Event> events = [
  Event(
    title: 'Tech Talk: AI & ML',
    description: 'Join us for an exciting discussion about Artificial Intelligence and Machine Learning trends in 2024. Learn from industry experts and network with fellow tech enthusiasts.',
    date: 'March 15, 2024',
    time: '2:00 PM',
    location: 'Computer Science Building, Room 101',
    organizer: 'CS Department',
    category: 'Technology',
    categoryColor: Colors.blue,
    icon: Icons.computer,
    gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
    attendees: 245,
  ),
  Event(
    title: 'Spring Music Festival',
    description: 'Experience the best of student talent at our annual Spring Music Festival. Live performances, food trucks, and amazing vibes!',
    date: 'March 20, 2024',
    time: '6:00 PM',
    location: 'Main Campus Quad',
    organizer: 'Student Union',
    category: 'Music',
    categoryColor: Colors.orange,
    icon: Icons.music_note,
    gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    attendees: 892,
  ),
  Event(
    title: 'Career Fair 2024',
    description: 'Meet with top employers and explore career opportunities. Bring your resume and dress professionally for this networking event.',
    date: 'March 25, 2024',
    time: '10:00 AM',
    location: 'University Center',
    organizer: 'Career Services',
    category: 'Career',
    categoryColor: Colors.green,
    icon: Icons.work,
    gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    attendees: 567,
  ),
  Event(
    title: 'Art Exhibition',
    description: 'Discover amazing artwork created by our talented art students. From paintings to sculptures, explore creativity at its finest.',
    date: 'March 30, 2024',
    time: '1:00 PM',
    location: 'Art Gallery, Fine Arts Building',
    organizer: 'Art Department',
    category: 'Art',
    categoryColor: Colors.purple,
    icon: Icons.palette,
    gradientColors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
    attendees: 156,
  ),
  Event(
    title: 'Basketball Championship',
    description: 'Cheer for our college team in the final championship game. Free snacks and drinks for all students!',
    date: 'April 5, 2024',
    time: '7:00 PM',
    location: 'Sports Complex',
    organizer: 'Athletics Department',
    category: 'Sports',
    categoryColor: Colors.red,
    icon: Icons.sports_basketball,
    gradientColors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
    attendees: 1234,
  ),
];