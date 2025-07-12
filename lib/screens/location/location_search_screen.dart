import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../providers/location_provider.dart';

class LocationSearchScreen extends StatefulWidget {
  static const routeName = '/location-search';

  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  List<LocationModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load current location when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getCurrentLocation();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final results = await locationProvider.searchLocations(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء البحث عن المواقع')),
        );
      }
    }
  }

  void _selectLocation(LocationModel location) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.setCurrentLocation(location);
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد الموقع'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن عنوانك',
                prefixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                _searchLocations(value);
              },
            ),
          ),

          // Current location
          if (locationProvider.currentLocation != null)
            _buildLocationTile(
              locationProvider.currentLocation!,
              isCurrent: true,
              onTap: () => _selectLocation(locationProvider.currentLocation!),
            ),

          // Search results or recent locations
          Expanded(
            child: _searchResults.isNotEmpty
                ? _buildSearchResults()
                : _buildRecentLocations(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return _buildLocationTile(
          location,
          onTap: () => _selectLocation(location),
        );
      },
    );
  }

  Widget _buildRecentLocations() {
    final locationProvider = Provider.of<LocationProvider>(context);
    final recentLocations = locationProvider.recentLocations;

    if (recentLocations.isEmpty) {
      return const Center(
        child: Text('لا توجد مواقع سابقة'),
      );
    }

    return ListView.builder(
      itemCount: recentLocations.length,
      itemBuilder: (context, index) {
        final location = recentLocations[index];
        return _buildLocationTile(
          location,
          onTap: () => _selectLocation(location),
        );
      },
    );
  }

  Widget _buildLocationTile(
    LocationModel location, {
    bool isCurrent = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        isCurrent ? Icons.my_location : Icons.location_on,
        color: isCurrent ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        isCurrent ? 'موقعي الحالي' : (location.name),
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        location.address ?? '${location.latitude}, ${location.longitude}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'الحالي',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
