class Testimonial {
  final String id;
  final String title;
  final String igUrl;
  final String? thumbnailUrl;

  Testimonial({
    required this.id,
    required this.title,
    required this.igUrl,
    this.thumbnailUrl,
  });
}
