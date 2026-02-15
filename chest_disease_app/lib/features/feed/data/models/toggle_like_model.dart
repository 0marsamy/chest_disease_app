class ToggleLikeRequestModel {
  final String postId;

  ToggleLikeRequestModel({required this.postId});
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
    };
  }
}

class ToggleLikeResponseModel {
  bool? isLiked;
  int? postId;

  ToggleLikeResponseModel({this.isLiked, this.postId});

  ToggleLikeResponseModel.fromJson(Map<String, dynamic> json) {
    isLiked = json['isLiked'];
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isLiked'] = isLiked;
    data['postId'] = postId;
    return data;
  }
}
