class SavedPostsResponseModel {
  List<SavedPost>? posts;
  int? nextCursor;

  SavedPostsResponseModel({this.posts, this.nextCursor});

  SavedPostsResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      posts = <SavedPost>[];
      json['data'].forEach((v) {
        posts!.add(SavedPost.fromJson(v));
      });
    }
    nextCursor = json['nextCursor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (posts != null) {
      data['data'] = posts!.map((v) => v.toJson()).toList();
    }
    data['nextCursor'] = nextCursor;
    return data;
  }
}

class SavedPost {
  int? id;
  String? title;
  String? content;
  bool? isLiked;
  bool? isSaved;
  int? likesCount;
  int? commentsCount;
  String? userName;
  String? userProfilePicture;
  String? createdAt;

  SavedPost(
      {this.id,
      this.title,
      this.content,
      this.isLiked,
      this.isSaved,
      this.likesCount,
      this.commentsCount,
      this.userName,
      this.userProfilePicture,
      this.createdAt});

  SavedPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    isLiked = json['isLiked'];
    isSaved = json['isSaved'];
    likesCount = json['likesCount'];
    commentsCount = json['commentsCount'];
    userName = json['userName'];
    userProfilePicture = json['userProfilePicture'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['isLiked'] = isLiked;
    data['isSaved'] = isSaved;
    data['likesCount'] = likesCount;
    data['commentsCount'] = commentsCount;
    data['userName'] = userName;
    data['userProfilePicture'] = userProfilePicture;
    data['createdAt'] = createdAt;
    return data;
  }
}


class SavedPostsRequestModel {
  int? cursor;

  SavedPostsRequestModel({this.cursor,});

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
    };
  }
}
