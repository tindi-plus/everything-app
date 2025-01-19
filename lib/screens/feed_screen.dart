import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  // ScrollController for detecting scroll direction to show/hide navigation bar
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  // Controller for managing pagination
  final PagingController<FeedRetrievalProps?, String> _pagingController =
      PagingController(firstPageKey: null);

  final int _postsPerPage = 25; // Number of posts per page for efficient fetching

  @override
  void initState() {
    super.initState();

    // Listener for pagination requests when the user scrolls to the bottom
    _pagingController.addPageRequestListener((lastDocument) {
      fetchPosts(lastDocument); // Fetch posts starting from the last document
    });

    // Scroll listener to dynamically hide/show the navigation bar based on scroll direction
    scrollController.addListener(() {
      final isNavBarVisible = ref.read(navigationBarNotifierProvider);
      if (_debounce?.isActive ?? false) return;

      _debounce = Timer(const Duration(milliseconds: 400), () {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!isNavBarVisible) {
            ref
                .read(navigationBarNotifierProvider.notifier)
                .setIsNavBarVisible = true; // Show navigation bar
          }
        } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (isNavBarVisible) {
            ref
                .read(navigationBarNotifierProvider.notifier)
                .setIsNavBarVisible = false; // Hide navigation bar
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up resources to avoid memory leaks
    scrollController.dispose();
    _pagingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Fetches posts from Firebase Firestore and updates the pagination controller
  Future<void> fetchPosts(FeedRetrievalProps? incomingProps) async {
    final loopUserState = ref.read(loopUserNotifierProvider).requireValue;

    // Check if the user's profile is created before fetching posts
    if (loopUserState.isProfileCreated == false) return;

    // Start with the provided FeedRetrievalProps or a default starter
    var internalProps = incomingProps ?? const FeedRetrievalProps.starter();

    // Define Firestore queries for feed and general posts
    Query feedQuery = FirebaseFirestore.instance
        .collection("users/${loopUserState.loopUser!.uid}/feed")
        .orderBy("createdAt", descending: true)
        .limit(_postsPerPage);

    Query generalQuery = FirebaseFirestore.instance
        .collection("posts")
        .where('audience',
            arrayContainsAny: loopUserState.loopUser!.residenceCombo)
        .orderBy('audience', descending: true)
        .limit(_postsPerPage);

    // Retrieve feed posts
    try {
      if (incomingProps != null && !incomingProps.feedEnded) {
        feedQuery = feedQuery.startAfterDocument(incomingProps.lastFeedPost!);
      }
      final feedSnapshot = await feedQuery.get();

      // Update props based on feed query results
      if (feedSnapshot.docs.isEmpty) {
        internalProps = internalProps.copyWith(feedEnded: true);
      } else {
        internalProps = internalProps.copyWith(
          lastFeedPost: feedSnapshot.docs.last,
        );
      }

      // Retrieve general posts
      if (incomingProps != null && !incomingProps.generalEnded) {
        generalQuery =
            generalQuery.startAfterDocument(incomingProps.lastGeneralPost!);
      }
      final generalSnapshot = await generalQuery.get();

      // Update props based on general query results
      if (generalSnapshot.docs.isEmpty) {
        internalProps = internalProps.copyWith(generalEnded: true);
      } else {
        internalProps = internalProps.copyWith(
          lastGeneralPost: generalSnapshot.docs.last,
        );
      }

      // Combine results and update the pagination controller
      final postIds = [
        ...feedSnapshot.docs.map((doc) => doc.id),
        ...generalSnapshot.docs.map((doc) => doc.id),
      ];
      if (internalProps.feedEnded && internalProps.generalEnded) {
        _pagingController.appendLastPage(postIds);
      } else {
        _pagingController.appendPage(postIds, internalProps);
      }
    } on SocketException {
      // Handle network issues gracefully
      _pagingController.error = 'No Internet Connection';
    } catch (e) {
      // Catch and display other errors
      _pagingController.error = 'Could not retrieve posts at this time.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Feed', style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: PagedListView(
          scrollController: scrollController,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<String>(
            itemBuilder: (context, postId, index) {
              // Use ProviderScope to optimize rebuilds of individual posts
              return ProviderScope(
                overrides: [postIdProvider.overrideWithValue(postId)],
                child: const PostWidget(),
              );
            },
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => _pagingController.refresh(),
                child: const Text('Try Again'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
