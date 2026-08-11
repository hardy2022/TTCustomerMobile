/*
import 'package:dots_indicator/dots_indicator.dart';

class ReviewsWidget extends StatefulWidget {
  @override
  _ReviewsWidgetState createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 150, // Adjust the height to fit your content
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildReview(
                  'https://example.com/reviewer_image.jpg', 'Theodore Roosevelt',
                  'In sagittis adipiscing velit vestibulum, ante feugiat enim.'),
              _buildReview(
                  'https://example.com/reviewer_image2.jpg', 'Albert Einstein',
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
              // Add more reviews here
            ],
          ),
        ),
        SizedBox(height: 10),
        DotsIndicator(
          dotsCount: 3, // Total number of pages (adjust according to your data)
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
            activeColor: Colors.black,
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReview(String imageUrl, String name, String review) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(review),
            ],
          ),
        ),
      ],
    );
  }
}
*/
