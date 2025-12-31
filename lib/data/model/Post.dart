class Post {
  final String title;
  final String body;
  final String script;

  Post({
    required this.body,
    required this.title,
    required this.script,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        script: json['script'], title: json['title'], body: json['body']);
  }
}

