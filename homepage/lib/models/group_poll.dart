class PollOption {
  final String id;
  final String text;
  int voteCount;
  List<String> votedUserIds;

  PollOption({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.votedUserIds = const [],
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: json['voteCount'] as int? ?? 0,
      votedUserIds: (json['votedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'voteCount': voteCount,
        'votedUserIds': votedUserIds,
      };

  PollOption copyWith({
    String? id,
    String? text,
    int? voteCount,
    List<String>? votedUserIds,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
      votedUserIds: votedUserIds ?? this.votedUserIds,
    );
  }
}

class GroupPoll {
  final String id;
  final String question;
  final bool allowMultipleAnswers;
  bool isExpanded;
  bool isClosed;
  final List<PollOption> options;

  GroupPoll({
    required this.id,
    required this.question,
    this.allowMultipleAnswers = true,
    this.isExpanded = false,
    this.isClosed = false,
    required this.options,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votedUserIds.length);

  factory GroupPoll.fromJson(Map<String, dynamic> json) {
    return GroupPoll(
      id: json['id'] as String,
      question: json['question'] as String,
      allowMultipleAnswers: json['allowMultipleAnswers'] as bool? ?? true,
      isExpanded: json['isExpanded'] as bool? ?? false,
      isClosed: json['isClosed'] as bool? ?? false,
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  GroupPoll copyWith({
    String? id,
    String? question,
    bool? allowMultipleAnswers,
    bool? isExpanded,
    bool? isClosed,
    List<PollOption>? options,
  }) {
    return GroupPoll(
      id: id ?? this.id,
      question: question ?? this.question,
      allowMultipleAnswers: allowMultipleAnswers ?? this.allowMultipleAnswers,
      isExpanded: isExpanded ?? this.isExpanded,
      isClosed: isClosed ?? this.isClosed,
      options: options ?? this.options,
    );
  }
}