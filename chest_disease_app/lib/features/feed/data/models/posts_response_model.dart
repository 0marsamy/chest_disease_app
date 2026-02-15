class PostsResponseModel {
  List<Posts>? posts;
  int? nextCursor;

  PostsResponseModel({this.posts, this.nextCursor});

  PostsResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      posts = <Posts>[];
      json['data'].forEach((v) {
        posts!.add(Posts.fromJson(v));
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

class Posts {
  int? id;
  String? userId;
  String? title;
  String? content;
  bool? isLiked;
  bool? isSaved;
  int? likesCount;
  int? commentsCount;
  String? userName;
  String? userProfilePicture;
  String? createdAt;

  Posts(
      {this.id,
      this.title,
      this.content,
      this.isLiked,
      this.isSaved,
      this.likesCount,
      this.commentsCount,
      this.userName,
      this.userProfilePicture,
      this.userId,
      this.createdAt});

  Posts.fromJson(Map<String, dynamic> json) {
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
    userId = json['userId'];
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
    data['userId'] = userId;
    return data;
  }
}

class PostsRequestModel {
  int? cursor;

  PostsRequestModel({this.cursor,});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cursor'] = cursor;
    return data;
  }
}
