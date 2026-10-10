class Ticket {
  final String id;
  final String ticketNumber; // #TKT-001
  final String customerId;
  final String customerName;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final List<TicketComment>? comments;
  final List<String>? attachments;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.comments,
    this.attachments,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TicketCategory.values.firstWhere(
        (e) => e.toString() == 'TicketCategory.${json['category']}',
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.toString() == 'TicketPriority.${json['priority']}',
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.toString() == 'TicketStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      assignedTo: json['assignedTo'] as String?,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((e) => TicketComment.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'comments': comments?.map((e) => e.toJson()).toList(),
      'attachments': attachments,
    };
  }
}

class TicketComment {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;

  TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum TicketCategory {
  connection,
  billing,
  technical,
  upgrade,
  complaint,
  other,
}

enum TicketPriority { low, normal, high, urgent }

enum TicketStatus { open, inProgress, waiting, resolved, closed }
