import 'package:flutter/material.dart';

class FloatingSearch extends StatefulWidget {
  @override
  _FloatingSearchState createState() => _FloatingSearchState();
}

class _FloatingSearchState extends State<FloatingSearch> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<String> _searchResults = [];
  List<String> _allItems = ['Apple', 'Banana', 'Orange', 'Grapes', 'Mango'];

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    // Compact sizing values
    final double compactWidth = 180.0;
    final double itemHeight = 32.0;
    final int maxItems = 5;
    final int displayCount = _searchResults.length > maxItems ? maxItems : _searchResults.length;
    final double compactHeight = displayCount * itemHeight + 2;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: compactWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, 42), // Slightly reduced offset for compactness
          child: Material(
            elevation: 2.0,
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: compactWidth,
                maxHeight: compactHeight,
              ),
              child: Container(
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: displayCount > 0
                      ? ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: displayCount,
                          separatorBuilder: (context, index) => Divider(
                            height: 0.14,
                            thickness: 0.18,
                            color: Color(0xFFF3F4F6),
                            indent: 5,
                            endIndent: 5,
                          ),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: itemHeight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print('Selected: ${_searchResults[index]}');
                                    _controller.text = _searchResults[index];
                                    _overlayEntry?.remove(); // Remove overlay when an item is selected
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _searchResults[index],
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchTextChanged(String query) {
    setState(() {
      _searchResults = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });

    if (query.isNotEmpty) {
      _showOverlay();
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floating Search'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.cyan,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _controller,
            onChanged: _onSearchTextChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: FloatingSearch()));
