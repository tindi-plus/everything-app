import 'package:flutter/foundation.dart';

import 'package:loop_fa/src/commons/models/user_residence.dart';

class Post {
  Key? key;
  String postId;
  String postTitle;
  String content;
  String firstname;
  String lastname;
  String uid;
  DateTime createdAt;
  DateTime? editedAt;
  int likesCount;
  bool isBroadcast;
  int sharesCount;
  String creatorPhotoUrl;
  String creatorUsername;
  List media;
  int commentsCount;
  List<UserResidence> audience;
  List<String>? blockedUsers;
  List? reportedUsers;
  Post({
    this.key,
    required this.postId,
    required this.content,
    required this.postTitle,
    required this.createdAt,
    required this.firstname,
    required this.lastname,
    required this.uid,
    required this.creatorPhotoUrl,
    required this.creatorUsername,
    this.isBroadcast = false,
    required this.likesCount,
    required this.sharesCount,
    required this.media,
    required this.audience,
    this.commentsCount = 0,
    this.editedAt,
    this.blockedUsers,
    this.reportedUsers,
  });

  Map<String, dynamic> toMap() {
    //Get the string representation of each UserResidence in [audience]
    List<String> mapAudiences = [];
    if (audience.isNotEmpty) {
      for (var element in audience) {
        mapAudiences.add(element.strLocation());
      }
    }
    return {
      'postId': postId,
      'content': content,
      'postTitle': postTitle,
      'createdAt': createdAt,
      'firstname': firstname,
      'lastname': lastname,
      'uid': uid,
      'creatorPhotoUrl': creatorPhotoUrl,
      'creatorUsername': creatorUsername,
      'isBroadcast': isBroadcast,
      'likesCount': likesCount,
      'sharesCount': sharesCount,
      'media': media,
      'audience': mapAudiences,
      'editedAt': editedAt,
      'commentsCount': commentsCount,
      'blockedUsers': blockedUsers,
      'reportedUsers': reportedUsers,
    };
  }

  static Post toPost(Map<String, dynamic> mapData) {
    List<UserResidence> mapAudience = [];
    //Handle earlier posts where the residence locations were stored as string
    // in firebase
    if (mapData['audience'] is String) {
      mapData['audience'] = [mapData['audience']];
    }

    //If the audience list is not empty, convert to a list of [UserResidence]
    if (mapData['audience'].isNotEmpty) {
      for (var element in mapData['audience']) {
        mapAudience.add(UserResidence(locationData: element));
      }
    }

    return Post(
      postId: mapData['postId'],
      content: mapData['content'],
      postTitle: mapData['postTitle'],
      createdAt: mapData['createdAt'].toDate(),
      firstname: mapData['firstname'],
      lastname: mapData['lastname'],
      uid: mapData['uid'],
      creatorPhotoUrl: mapData['creatorPhotoUrl'],
      creatorUsername: mapData['creatorUsername'],
      isBroadcast: mapData['isBroadcast'],
      likesCount: mapData['likesCount'],
      media: mapData['media'],
      sharesCount: mapData['sharesCount'],
      audience: mapAudience,
      editedAt: mapData['editedAt']?.toDate(),
      commentsCount: mapData['commentsCount'],
      blockedUsers: mapData['blockedUsers'],
      reportedUsers: mapData['reportedUsers'],
    );
  }

  @override
  String toString() {
    return 'Post(key: $key, postId: $postId, postTitle: $postTitle, content: $content, firstname: $firstname, lastname: $lastname, uid: $uid, createdAt: $createdAt, editedAt: $editedAt, likesCount: $likesCount, isBroadcast: $isBroadcast, sharesCount: $sharesCount, creatorPhotoUrl: $creatorPhotoUrl, creatorUsername: $creatorUsername, media: $media, commentsCount: $commentsCount, audience: $audience, blockedUsers: $blockedUsers, reportedUsers: $reportedUsers)';
  }

  Post copyWith({
    ValueGetter<Key?>? key,
    String? postId,
    String? postTitle,
    String? content,
    String? firstname,
    String? lastname,
    String? uid,
    DateTime? createdAt,
    ValueGetter<DateTime?>? editedAt,
    int? likesCount,
    bool? isBroadcast,
    int? sharesCount,
    String? creatorPhotoUrl,
    String? creatorUsername,
    List? media,
    int? commentsCount,
    List<UserResidence>? audience,
    ValueGetter<List<String>?>? blockedUsers,
    List? reportedUsers,
  }) {
    return Post(
      key: key != null ? key() : this.key,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      content: content ?? this.content,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt != null ? editedAt() : this.editedAt,
      likesCount: likesCount ?? this.likesCount,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      sharesCount: sharesCount ?? this.sharesCount,
      creatorPhotoUrl: creatorPhotoUrl ?? this.creatorPhotoUrl,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      media: media ?? this.media,
      commentsCount: commentsCount ?? this.commentsCount,
      audience: audience ?? this.audience,
      blockedUsers: blockedUsers != null ? blockedUsers() : this.blockedUsers,
      reportedUsers: reportedUsers ?? this.reportedUsers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Post &&
      other.key == key &&
      other.postId == postId &&
      other.postTitle == postTitle &&
      other.content == content &&
      other.firstname == firstname &&
      other.lastname == lastname &&
      other.uid == uid &&
      other.createdAt == createdAt &&
      other.editedAt == editedAt &&
      other.likesCount == likesCount &&
      other.isBroadcast == isBroadcast &&
      other.sharesCount == sharesCount &&
      other.creatorPhotoUrl == creatorPhotoUrl &&
      other.creatorUsername == creatorUsername &&
      listEquals(other.media, media) &&
      other.commentsCount == commentsCount &&
      listEquals(other.audience, audience) &&
      listEquals(other.blockedUsers, blockedUsers) &&
      listEquals(other.reportedUsers, reportedUsers);
  }

  @override
  int get hashCode {
    return key.hashCode ^
      postId.hashCode ^
      postTitle.hashCode ^
      content.hashCode ^
      firstname.hashCode ^
      lastname.hashCode ^
      uid.hashCode ^
      createdAt.hashCode ^
      editedAt.hashCode ^
      likesCount.hashCode ^
      isBroadcast.hashCode ^
      sharesCount.hashCode ^
      creatorPhotoUrl.hashCode ^
      creatorUsername.hashCode ^
      media.hashCode ^
      commentsCount.hashCode ^
      audience.hashCode ^
      blockedUsers.hashCode ^
      reportedUsers.hashCode;
  }
}
