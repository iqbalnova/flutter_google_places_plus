import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_plus/flutter_google_places_plus.dart';

void main() {
  runApp(const PlacesExampleApp());
}

class PlacesExampleApp extends StatelessWidget {
  const PlacesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Places Plus Example',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const PlacesSearchScreen(),
    );
  }
}

class PlacesSearchScreen extends StatefulWidget {
  const PlacesSearchScreen({super.key});

  @override
  State<PlacesSearchScreen> createState() => _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<PlacesSearchScreen> {
  final _places = FlutterGooglePlacesPlus();

  final _apiKeyController = TextEditingController(
    text: const String.fromEnvironment('PLACES_API_KEY', defaultValue: ''),
  );
  final _searchController = TextEditingController();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AutocompleteSessionToken? _currentSessionToken;
  List<AutocompletePrediction> _predictions = [];
  Place? _selectedPlace;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (_apiKeyController.text.trim().isNotEmpty) {
      _initializeSdk();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _apiKeyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeSdk() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(
        () => _errorMessage = 'Please enter a valid Google Places API Key',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _places.initialize(apiKey: key);
      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _currentSessionToken = _places.newSessionToken();
      });
    } on PlacesException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${e.code}: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchPredictions(query.trim());
    });
  }

  Future<void> _fetchPredictions(String query) async {
    if (!_isInitialized) {
      setState(() => _errorMessage = 'Initialize the Places SDK first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _currentSessionToken ??= _places.newSessionToken();

    try {
      final results = await _places.findAutocompletePredictions(
        query: query,
        sessionToken: _currentSessionToken,
      );
      setState(() {
        _predictions = results;
        _isLoading = false;
      });
    } on PlacesException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${e.code}: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onSelectPrediction(AutocompletePrediction prediction) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final place = await _places.fetchPlace(
        placeId: prediction.placeId,
        fields: {
          PlaceField.id,
          PlaceField.displayName,
          PlaceField.formattedAddress,
          PlaceField.location,
          PlaceField.viewport,
          PlaceField.addressComponents,
          PlaceField.types,
          PlaceField.internationalPhoneNumber,
          PlaceField.rating,
          PlaceField.userRatingCount,
          PlaceField.businessStatus,
          PlaceField.priceLevel,
          PlaceField.websiteUri,
          PlaceField.googleMapsUri,
          PlaceField.utcOffsetMinutes,
        },
        sessionToken: _currentSessionToken,
      );

      setState(() {
        _selectedPlace = place;
        _predictions = [];
        _searchController.clear();
        _isLoading = false;
        // Session concluded by fetchPlace, create a new one for next search
        _currentSessionToken = _places.newSessionToken();
      });
    } on PlacesException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${e.code}: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Places Plus'), elevation: 1),
      body: SafeArea(
        child: Column(
          children: [
            _buildConfigBar(),
            if (_errorMessage != null) _buildErrorBanner(),
            _buildSearchBar(),
            if (_isLoading) const LinearProgressIndicator(),
            Expanded(child: _buildMainContent()),
            _buildAttributionFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigBar() {
    if (_isInitialized) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Places SDK Initialized',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isInitialized = false),
              child: const Text('Change Key'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Google Places API Key',
                hintText: 'AIzaSy...',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _initializeSdk,
            child: const Text('Initialize'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: _onQueryChanged,
        enabled: _isInitialized,
        decoration: InputDecoration(
          hintText: _isInitialized
              ? 'Search places, streets, points of interest...'
              : 'Initialize SDK above to search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onQueryChanged('');
                  },
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_predictions.isNotEmpty) {
      return ListView.separated(
        itemCount: _predictions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _predictions[index];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(item.primaryText),
            subtitle: item.secondaryText != null
                ? Text(item.secondaryText!)
                : null,
            trailing: item.distanceMeters != null
                ? Text('${item.distanceMeters} m')
                : null,
            onTap: () => _onSelectPrediction(item),
          );
        },
      );
    }

    if (_selectedPlace != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedPlace!.displayName ?? 'Unknown Name',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (_selectedPlace!.rating != null)
                      Chip(
                        avatar: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        label: Text(
                          '${_selectedPlace!.rating} (${_selectedPlace!.userRatingCount ?? 0})',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedPlace!.formattedAddress != null)
                  Text(
                    _selectedPlace!.formattedAddress!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const Divider(height: 24),
                if (_selectedPlace!.location != null)
                  Text(
                    'Coordinates: ${_selectedPlace!.location!.latitude.toStringAsFixed(6)}, ${_selectedPlace!.location!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (_selectedPlace!.businessStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Status: ${_selectedPlace!.businessStatus}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (_selectedPlace!.internationalPhoneNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Phone: ${_selectedPlace!.internationalPhoneNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (_selectedPlace!.types != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selectedPlace!.types!
                        .map(
                          (type) => Chip(
                            label: Text(
                              type,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.place_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _isInitialized
                ? 'Type in the search box to find places'
                : 'Enter your API key and tap Initialize to begin',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributionFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        'Powered by Google',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
